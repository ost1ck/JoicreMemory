const userService = require('../services/userService');

async function getMe(req, res) {
  const user = await userService.getCurrentUser(req.auth);
  res.status(200).json({ data: user });
}

async function updateMe(req, res) {
  const user = await userService.updateCurrentUser(req.auth, req.body);
  res.status(200).json({ data: user });
}

async function getUserById(req, res) {
  const user = await userService.getUserById(req.params.id);
  res.status(200).json({ data: user });
}

module.exports = {
  getMe,
  updateMe,
  getUserById
};

