const eventService = require('../services/eventService');
const { parsePagination } = require('../utils/pagination');

async function listEvents(req, res) {
  const events = await eventService.listEvents({
    ...req.query,
    ...parsePagination(req.query)
  });

  res.status(200).json({ data: events });
}

async function listMyEvents(req, res) {
  const events = await eventService.listMyEvents(req.auth);
  res.status(200).json({ data: events });
}

async function createEvent(req, res) {
  const event = await eventService.createEvent(req.auth, req.body);
  res.status(201).json({ data: event });
}

async function getEvent(req, res) {
  const event = await eventService.getEvent(req.params.id);
  res.status(200).json({ data: event });
}

async function updateEvent(req, res) {
  const event = await eventService.updateEvent(req.auth, req.params.id, req.body);
  res.status(200).json({ data: event });
}

async function deleteEvent(req, res) {
  await eventService.deleteEvent(req.auth, req.params.id);
  res.status(204).send();
}

async function joinEvent(req, res) {
  const event = await eventService.joinEvent(req.auth, req.params.id);
  res.status(200).json({ data: event });
}

async function leaveEvent(req, res) {
  const event = await eventService.leaveEvent(req.auth, req.params.id);
  res.status(200).json({ data: event });
}

module.exports = {
  listEvents,
  listMyEvents,
  createEvent,
  getEvent,
  updateEvent,
  deleteEvent,
  joinEvent,
  leaveEvent
};

