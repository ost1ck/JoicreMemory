const router = require('express').Router();
const reportController = require('../controllers/reportController');
const { authenticate } = require('../middlewares/authMiddleware');
const asyncHandler = require('../utils/asyncHandler');

router.get('/me', authenticate, asyncHandler(reportController.getMyReport));

module.exports = router;
