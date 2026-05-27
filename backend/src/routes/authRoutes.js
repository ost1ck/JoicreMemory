const router = require('express').Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middlewares/authMiddleware');
const validate = require('../middlewares/validate');
const asyncHandler = require('../utils/asyncHandler');
const { syncUserSchema } = require('../schemas/userSchemas');

router.post(
  '/sync',
  authenticate,
  validate(syncUserSchema),
  asyncHandler(authController.syncCurrentUser)
);

module.exports = router;

