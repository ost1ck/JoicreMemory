const router = require('express').Router();

router.use('/health', require('./healthRoutes'));
router.use('/auth', require('./authRoutes'));
router.use('/users', require('./userRoutes'));
router.use('/events', require('./eventRoutes'));
router.use('/chats', require('./chatRoutes'));
router.use('/reports', require('./reportRoutes'));

module.exports = router;
