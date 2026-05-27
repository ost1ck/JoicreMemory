const chatService = require('../services/chatService');

async function getStreamToken(req, res) {
  const tokenData = await chatService.getCurrentUserStreamToken(req.auth);
  res.status(200).json({ data: tokenData });
}

async function listChats(req, res) {
  const chats = await chatService.listCurrentUserChats(req.auth);
  res.status(200).json({ data: chats });
}

async function listMembers(req, res) {
  const members = await chatService.listChatMembers(req.auth, req.params.eventId);
  res.status(200).json({ data: members });
}

async function updateChat(req, res) {
  const chat = await chatService.updateChat(req.auth, req.params.eventId, req.body);
  res.status(200).json({ data: chat });
}

async function kickMember(req, res) {
  const members = await chatService.kickMember(
    req.auth,
    req.params.eventId,
    req.params.userId
  );

  res.status(200).json({ data: members });
}

module.exports = {
  getStreamToken,
  listChats,
  listMembers,
  updateChat,
  kickMember
};
