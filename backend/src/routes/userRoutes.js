const router = require('express').Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middlewares/authMiddleware');
const validate = require('../middlewares/validate');
const asyncHandler = require('../utils/asyncHandler');
const { updateProfileSchema } = require('../schemas/userSchemas');

router.get('/me', authenticate, asyncHandler(userController.getMe));
router.patch('/me', authenticate, validate(updateProfileSchema), asyncHandler(userController.updateMe));
router.get('/:id', asyncHandler(userController.getUserById));

module.exports = router;

