const router = require('express').Router();
const chatController = require('../controllers/chatController');
const { authenticate } = require('../middlewares/authMiddleware');
const validate = require('../middlewares/validate');
const { updateChatSchema } = require('../schemas/chatSchemas');
const asyncHandler = require('../utils/asyncHandler');

router.get('/', authenticate, asyncHandler(chatController.listChats));
router.get('/stream-token', authenticate, asyncHandler(chatController.getStreamToken));
router.get('/:eventId/members', authenticate, asyncHandler(chatController.listMembers));
router.patch(
  '/:eventId',
  authenticate,
  validate(updateChatSchema),
  asyncHandler(chatController.updateChat)
);
router.delete(
  '/:eventId/members/:userId',
  authenticate,
  asyncHandler(chatController.kickMember)
);

module.exports = router;
