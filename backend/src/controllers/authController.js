const userService = require('../services/userService');

async function syncCurrentUser(req, res) {
  const user = await userService.syncCurrentUser(req.auth, req.body);
  res.status(200).json({ data: user });
}

module.exports = {
  syncCurrentUser
};

