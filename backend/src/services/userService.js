const userRepository = require('../repositories/userRepository');
const streamService = require('./streamService');
const ApiError = require('../utils/apiError');

async function syncCurrentUser(auth, payload = {}) {
  const email = payload.email || auth.email;
  const fullName = payload.fullName || auth.fullName || email;

  if (!email) {
    throw new ApiError(400, 'Email is required to sync user');
  }

  const user = await userRepository.upsertFromAuth({
    firebaseUid: auth.firebaseUid,
    email,
    fullName,
    avatarUrl: payload.avatarUrl
  });

  await streamService.upsertUser({
    streamUserId: user.streamUserId || user.firebaseUid,
    fullName: user.fullName,
    avatarUrl: user.avatarUrl
  });

  return user;
}

async function getCurrentUser(auth) {
  const user = await userRepository.findByFirebaseUid(auth.firebaseUid);

  if (!user) {
    throw new ApiError(404, 'User profile is not synced');
  }

  return user;
}

async function updateCurrentUser(auth, payload) {
  const user = await getCurrentUser(auth);
  const updated = await userRepository.updateProfile(user.id, payload);

  await streamService.upsertUser({
    streamUserId: updated.streamUserId || updated.firebaseUid,
    fullName: updated.fullName,
    avatarUrl: updated.avatarUrl
  });

  return updated;
}

async function getUserById(id) {
  const user = await userRepository.findById(id);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  return user;
}

module.exports = {
  syncCurrentUser,
  getCurrentUser,
  updateCurrentUser,
  getUserById
};
