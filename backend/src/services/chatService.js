const userRepository = require('../repositories/userRepository');
const eventRepository = require('../repositories/eventRepository');
const chatRepository = require('../repositories/chatRepository');
const streamService = require('./streamService');
const ApiError = require('../utils/apiError');

async function requireSyncedUser(auth) {
  const user = await userRepository.findByFirebaseUid(auth.firebaseUid);

  if (!user) {
    throw new ApiError(404, 'User profile is not synced. Call POST /api/auth/sync first.');
  }

  return user;
}

async function requireChatMember(eventId, user) {
  const participation = await eventRepository.findParticipant(eventId, user.id);

  if (!participation || participation.status !== 'joined') {
    throw new ApiError(403, 'Join the event before opening its chat');
  }

  return participation;
}

async function requireOrganizer(eventId, user) {
  const event = await eventRepository.findById(eventId);

  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  const participation = await requireChatMember(eventId, user);

  if (event.creatorUserId !== user.id && participation.role !== 'organizer') {
    throw new ApiError(403, 'Only event organizer can manage this chat');
  }

  return event;
}

async function getCurrentUserStreamToken(auth) {
  const user = await requireSyncedUser(auth);
  const streamUserId = user.streamUserId || user.firebaseUid;
  const token = streamService.createUserToken(streamUserId);

  if (!token) {
    return {
      streamUserId,
      fullName: user.fullName,
      avatarUrl: user.avatarUrl,
      token: null,
      message: 'Stream credentials are not configured. Add STREAM_API_KEY and STREAM_API_SECRET.'
    };
  }

  return {
    streamUserId,
    fullName: user.fullName,
    avatarUrl: user.avatarUrl,
    token
  };
}

async function listCurrentUserChats(auth) {
  const user = await requireSyncedUser(auth);
  const chats = await chatRepository.listByUser(user.id);

  await Promise.all(
    chats.map(async (chat) => {
      const creator = await userRepository.findById(chat.creatorUserId);

      await streamService.upsertUsers([creator, user]);
      await streamService.ensureEventChannel({
        eventId: chat.eventId,
        streamChannelId: chat.streamChannelId,
        creatorUserId: chat.creatorUserId,
        creatorStreamUserId: creator?.streamUserId || creator?.firebaseUid,
        title: chat.eventTitle,
        image: chat.avatarUrl,
        memberStreamUserIds: [user.streamUserId || user.firebaseUid]
      });
    })
  );

  return chats;
}

async function listChatMembers(auth, eventId) {
  const user = await requireSyncedUser(auth);
  await requireChatMember(eventId, user);
  return chatRepository.listMembers(eventId);
}

async function updateChat(auth, eventId, payload) {
  const user = await requireSyncedUser(auth);
  await requireOrganizer(eventId, user);

  const chat = await chatRepository.findByEventId(eventId);

  if (!chat) {
    throw new ApiError(404, 'Chat not found');
  }

  await chatRepository.updateAvatar(eventId, payload.avatarUrl || null);
  await streamService.updateChannel({
    streamChannelId: chat.streamChannelId,
    image: payload.avatarUrl || null
  });

  return chatRepository.findByEventId(eventId);
}

async function kickMember(auth, eventId, targetUserId) {
  const user = await requireSyncedUser(auth);
  const event = await requireOrganizer(eventId, user);

  if (event.creatorUserId === targetUserId) {
    throw new ApiError(400, 'Event creator cannot be kicked');
  }

  if (user.id === targetUserId) {
    throw new ApiError(400, 'Use leave event instead of kicking yourself');
  }

  const target = await userRepository.findById(targetUserId);

  if (!target) {
    throw new ApiError(404, 'User not found');
  }

  const participation = await eventRepository.findParticipant(eventId, target.id);

  if (!participation || participation.status !== 'joined') {
    throw new ApiError(404, 'User is not a member of this event');
  }

  await eventRepository.upsertParticipant(eventId, target.id, 'cancelled');

  const chat = await chatRepository.findByEventId(eventId);
  await streamService.removeChannelMember({
    streamChannelId: chat?.streamChannelId,
    streamUserId: target.streamUserId || target.firebaseUid
  });

  return chatRepository.listMembers(eventId);
}

module.exports = {
  getCurrentUserStreamToken,
  listCurrentUserChats,
  listChatMembers,
  updateChat,
  kickMember
};
