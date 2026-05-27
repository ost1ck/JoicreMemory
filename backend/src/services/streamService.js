const { getStreamClient } = require('../config/stream');

function buildEventChannelId(eventId) {
  return `event_${eventId.replace(/-/g, '')}`;
}

function isMissingChannelError(error) {
  return (
    error?.code === 16 ||
    error?.response?.data?.code === 16 ||
    String(error?.message || error).includes("Can't find channel")
  );
}

function isAlreadyExistsError(error) {
  const message = String(error?.message || error).toLowerCase();
  return error?.code === 4 || message.includes('already exists');
}

async function createEventChannel({
  eventId,
  creatorUserId,
  creatorStreamUserId,
  title,
  image
}) {
  const streamClient = getStreamClient();
  const channelId = buildEventChannelId(eventId);

  if (!streamClient) {
    return channelId;
  }

  const channel = streamClient.channel('messaging', channelId, {
    name: title,
    image: image || undefined,
    joicrememory_event_chat: true,
    joicrememory_event_id: eventId,
    joicrememory_creator_user_id: creatorUserId,
    created_by_id: creatorStreamUserId,
    members: [creatorStreamUserId]
  });

  await channel.create();
  return channelId;
}

async function ensureEventChannel({
  eventId,
  streamChannelId,
  creatorUserId,
  creatorStreamUserId,
  title,
  image,
  memberStreamUserIds = []
}) {
  const streamClient = getStreamClient();
  const channelId = streamChannelId || buildEventChannelId(eventId);

  if (!streamClient) {
    return channelId;
  }

  const members = [
    ...new Set(
      [creatorStreamUserId, ...memberStreamUserIds].filter(Boolean)
    )
  ];
  const channel = streamClient.channel('messaging', channelId, {
    name: title,
    image: image || undefined,
    joicrememory_event_chat: true,
    joicrememory_event_id: eventId,
    joicrememory_creator_user_id: creatorUserId,
    created_by_id: creatorStreamUserId,
    members
  });

  try {
    await channel.create();
  } catch (error) {
    if (!isAlreadyExistsError(error)) {
      throw error;
    }
  }

  if (members.length > 0) {
    await channel.addMembers(members);
  }

  return channelId;
}

async function upsertUser({ streamUserId, fullName, avatarUrl }) {
  const streamClient = getStreamClient();

  if (!streamClient) {
    return;
  }

  await streamClient.upsertUser({
    id: streamUserId,
    name: fullName,
    image: avatarUrl || undefined
  });
}

async function upsertUsers(users) {
  const streamClient = getStreamClient();

  if (!streamClient) {
    return;
  }

  const uniqueUsers = new Map();

  users
    .filter(Boolean)
    .forEach((user) => {
      const streamUserId = user.streamUserId || user.firebaseUid;

      if (!streamUserId) {
        return;
      }

      uniqueUsers.set(streamUserId, {
        id: streamUserId,
        name: user.fullName,
        image: user.avatarUrl || undefined
      });
    });

  if (uniqueUsers.size === 0) {
    return;
  }

  await streamClient.upsertUsers([...uniqueUsers.values()]);
}

async function addChannelMember({ streamChannelId, streamUserId }) {
  const streamClient = getStreamClient();

  if (!streamClient || !streamChannelId || !streamUserId) {
    return;
  }

  const channel = streamClient.channel('messaging', streamChannelId);
  await channel.addMembers([streamUserId]);
}

async function removeChannelMember({ streamChannelId, streamUserId }) {
  const streamClient = getStreamClient();

  if (!streamClient || !streamChannelId || !streamUserId) {
    return;
  }

  const channel = streamClient.channel('messaging', streamChannelId);
  try {
    await channel.removeMembers([streamUserId]);
  } catch (error) {
    if (!isMissingChannelError(error)) {
      throw error;
    }
  }
}

async function updateChannel({ streamChannelId, name, image }) {
  const streamClient = getStreamClient();

  if (!streamClient || !streamChannelId) {
    return;
  }

  const channel = streamClient.channel('messaging', streamChannelId);
  try {
    await channel.update({
      ...(name === undefined ? {} : { name }),
      ...(image === undefined ? {} : { image })
    });
  } catch (error) {
    if (!isMissingChannelError(error)) {
      throw error;
    }
  }
}

async function deleteChannel(streamChannelId) {
  const streamClient = getStreamClient();

  if (!streamClient || !streamChannelId) {
    return;
  }

  const channel = streamClient.channel('messaging', streamChannelId);
  try {
    await channel.delete({ hard_delete: true });
  } catch (error) {
    if (!isMissingChannelError(error)) {
      throw error;
    }
  }
}

function createUserToken(streamUserId) {
  const streamClient = getStreamClient();

  if (!streamClient) {
    return null;
  }

  return streamClient.createToken(streamUserId);
}

module.exports = {
  buildEventChannelId,
  createEventChannel,
  ensureEventChannel,
  upsertUser,
  upsertUsers,
  addChannelMember,
  removeChannelMember,
  updateChannel,
  deleteChannel,
  createUserToken
};
