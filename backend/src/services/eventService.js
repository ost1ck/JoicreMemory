const db = require('../config/db');
const { effectiveStatus, validateEventChange } = require('./eventStatusPolicy');
const lifecycle = require('./eventLifecycleService');
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

  return { ...event, status: effectiveStatus(event) };
}

async function getVisibleEvent(id, auth) {
  const event = await getEvent(id);
  if (event.status === 'draft') {
    const user = auth ? await requireSyncedUser(auth) : null;
    if (user?.id !== event.creatorUserId) throw new ApiError(404, 'Event not found');
  }
  return event;
}

async function ensureEventChatChannel(event, memberUsers = []) {
  if (event.status !== 'published' || (event.endsAt && new Date(event.endsAt) <= new Date())) {
    throw new ApiError(410, 'Подія завершена. Приєднання до чату недоступне.');
  }
  const creator = await userRepository.findById(event.creatorUserId);

  if (!creator) {
    throw new ApiError(404, 'Event creator not found');
  }


  let chat = await eventRepository.findChatChannelByEventId(event.id);
  const streamChannelId =
    chat?.stream_channel_id || streamService.buildEventChannelId(event.id);

  if (!chat) chat = await eventRepository.createChatChannel(event.id, creator.id, streamChannelId);
  await streamService.upsertUsers([creator, ...memberUsers]);
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


  return chat;
}

async function createEvent(auth, payload) {
  const user = await requireSyncedUser(auth);

  const status = payload.status || 'published';
  validateEventChange({ ...payload, status: 'draft', participantCount: 1 }, { status });
  const event = await eventRepository.create({
    ...payload,
    creatorUserId: user.id
  });

  if (event.status === 'published') {
    // Keep creation successful if Stream is temporarily unavailable; chat list repairs it.
    try { await ensureEventChatChannel(event, [user]); }
    catch (_) { console.error('Event chat provisioning deferred', event.id); }
  }

  return getEvent(event.id);
}

async function updateEvent(auth, eventId, payload) {
  const user = await requireSyncedUser(auth);
  const event = await getEvent(eventId);
  const participation = await eventRepository.findParticipant(eventId, user.id);

  if (event.creatorUserId !== user.id && (event.status === 'draft' || participation?.role !== 'organizer' || participation?.status !== 'joined')) {
    throw new ApiError(403, 'Only event organizer can update this event');
  }

  validateEventChange(event, payload);
  const updated = await eventRepository.update(eventId, payload);

  if (!updated) {
    throw new ApiError(404, 'Event not found');
  }

  if (updated.status === 'published' && event.status === 'draft') {
    try { await ensureEventChatChannel(updated, [user]); }
    catch (_) { console.error('Event chat provisioning deferred', eventId); }
  }
  if (payload.title && updated.status === 'published') {
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
  if (event.status !== 'published') throw new ApiError(409, 'Подія недоступна для участі.');
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

  if (event.status !== 'published') throw new ApiError(409, 'Участь у завершеній події не змінюється.');
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
  const events = await eventRepository.listByUser(user.id);
  return events.map(event => ({ ...event, status: effectiveStatus(event) }));
}

module.exports = {
  listEvents,
  getEvent,
  getVisibleEvent,
  createEvent,
  updateEvent: async (auth, id, payload) => {
    const result = await db.withEventLock(id, () => updateEvent(auth, id, payload));
    if (['completed', 'cancelled'].includes(result.status)) {
      lifecycle.cleanup().catch(() => console.error('Cleanup deferred'));
    }
    return result;
  },
  deleteEvent: (auth, id) => db.withEventLock(id, () => deleteEvent(auth, id)),
  joinEvent: (auth, id) => db.withEventLock(id, () => joinEvent(auth, id)),
  leaveEvent: (auth, id) => db.withEventLock(id, () => leaveEvent(auth, id)),
  listMyEvents
};
