const eventRepository = require('../repositories/eventRepository');
const userRepository = require('../repositories/userRepository');
const streamService = require('./streamService');
const ApiError = require('../utils/apiError');

async function requireSyncedUser(auth) {
  const user = await userRepository.findByFirebaseUid(auth.firebaseUid);

  if (!user) {
    throw new ApiError(404, 'User profile is not synced. Call POST /api/auth/sync first.');
  }

  return user;
}

async function listEvents(filters) {
  return eventRepository.list({
    ...filters,
    radiusMeters: filters.radiusMeters || 10000
  });
}

async function getEvent(id) {
  const event = await eventRepository.findById(id);

  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  return event;
}

async function ensureEventChatChannel(event, memberUsers = []) {
  const creator = await userRepository.findById(event.creatorUserId);

  if (!creator) {
    throw new ApiError(404, 'Event creator not found');
  }

  await streamService.upsertUsers([creator, ...memberUsers]);

  let chat = await eventRepository.findChatChannelByEventId(event.id);
  const streamChannelId =
    chat?.stream_channel_id || streamService.buildEventChannelId(event.id);

  await streamService.ensureEventChannel({
    eventId: event.id,
    streamChannelId,
    creatorUserId: creator.id,
    creatorStreamUserId: creator.streamUserId || creator.firebaseUid,
    title: event.title,
    image: chat?.avatar_url || event.imageUrl,
    memberStreamUserIds: memberUsers.map(
      (member) => member.streamUserId || member.firebaseUid
    )
  });

  if (!chat) {
    chat = await eventRepository.createChatChannel(
      event.id,
      creator.id,
      streamChannelId
    );
  }

  return chat;
}

async function createEvent(auth, payload) {
  const user = await requireSyncedUser(auth);

  const event = await eventRepository.create({
    ...payload,
    creatorUserId: user.id
  });

  await streamService.upsertUser({
    streamUserId: user.streamUserId || user.firebaseUid,
    fullName: user.fullName,
    avatarUrl: user.avatarUrl
  });

  const streamChannelId = await streamService.createEventChannel({
    eventId: event.id,
    creatorUserId: user.id,
    creatorStreamUserId: user.streamUserId || user.firebaseUid,
    title: event.title,
    image: event.imageUrl
  });

  await eventRepository.createChatChannel(event.id, user.id, streamChannelId);

  return getEvent(event.id);
}

async function updateEvent(auth, eventId, payload) {
  const user = await requireSyncedUser(auth);
  const event = await getEvent(eventId);
  const participation = await eventRepository.findParticipant(eventId, user.id);

  if (event.creatorUserId !== user.id && participation?.role !== 'organizer') {
    throw new ApiError(403, 'Only event organizer can update this event');
  }

  const updated = await eventRepository.update(eventId, payload);

  if (!updated) {
    throw new ApiError(404, 'Event not found');
  }

  if (payload.title) {
    const chat = await eventRepository.findChatChannelByEventId(eventId);
    await streamService.updateChannel({
      streamChannelId: chat?.stream_channel_id,
      name: payload.title
    });
  }

  return getEvent(eventId);
}

async function deleteEvent(auth, eventId) {
  const user = await requireSyncedUser(auth);
  const event = await getEvent(eventId);

  if (event.creatorUserId !== user.id) {
    throw new ApiError(403, 'Only event creator can delete this event');
  }

  const chat = await eventRepository.findChatChannelByEventId(eventId);
  await streamService.deleteChannel(chat?.stream_channel_id);

  await eventRepository.remove(eventId);
}

async function joinEvent(auth, eventId) {
  const user = await requireSyncedUser(auth);
  const event = await getEvent(eventId);
  const participation = await eventRepository.findParticipant(eventId, user.id);

  if (participation?.status === 'joined') {
    await ensureEventChatChannel(event, [user]);
    return getEvent(eventId);
  }

  if (
    event.maxParticipants !== null &&
    event.maxParticipants !== undefined &&
    event.participantCount >= event.maxParticipants
  ) {
    throw new ApiError(400, 'У події вже немає вільних місць.');
  }

  await ensureEventChatChannel(event, [user]);
  await eventRepository.upsertParticipant(eventId, user.id, 'joined');

  return getEvent(eventId);
}

async function leaveEvent(auth, eventId) {
  const user = await requireSyncedUser(auth);
  const event = await getEvent(eventId);

  if (event.creatorUserId === user.id) {
    throw new ApiError(400, 'Event creator cannot leave their own event');
  }

  const chat = await eventRepository.findChatChannelByEventId(eventId);
  await streamService.removeChannelMember({
    streamChannelId: chat?.stream_channel_id,
    streamUserId: user.streamUserId || user.firebaseUid
  });

  await eventRepository.upsertParticipant(eventId, user.id, 'cancelled');

  return getEvent(eventId);
}

async function listMyEvents(auth) {
  const user = await requireSyncedUser(auth);
  return eventRepository.listByUser(user.id);
}

module.exports = {
  listEvents,
  getEvent,
  createEvent,
  updateEvent,
  deleteEvent,
  joinEvent,
  leaveEvent,
  listMyEvents
};
