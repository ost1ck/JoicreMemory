const router = require('express').Router();
const eventController = require('../controllers/eventController');
const { authenticate } = require('../middlewares/authMiddleware');
const validate = require('../middlewares/validate');
const asyncHandler = require('../utils/asyncHandler');
const {
  createEventSchema,
  updateEventSchema,
  listEventsSchema
} = require('../schemas/eventSchemas');

router.get('/', validate(listEventsSchema, 'query'), asyncHandler(eventController.listEvents));
router.get('/mine', authenticate, asyncHandler(eventController.listMyEvents));
router.post('/', authenticate, validate(createEventSchema), asyncHandler(eventController.createEvent));
router.get('/:id', asyncHandler(eventController.getEvent));
router.patch('/:id', authenticate, validate(updateEventSchema), asyncHandler(eventController.updateEvent));
router.delete('/:id', authenticate, asyncHandler(eventController.deleteEvent));
router.post('/:id/join', authenticate, asyncHandler(eventController.joinEvent));
router.post('/:id/leave', authenticate, asyncHandler(eventController.leaveEvent));

module.exports = router;

