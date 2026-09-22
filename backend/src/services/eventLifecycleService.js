const db = require('../config/db');
const streamService = require('./streamService');
const { getStreamClient } = require('../config/stream');

const { createLifecycleService } = require('./eventLifecycleWorker');
const lifecycle = createLifecycleService({query: db.query,
  deleteChannel: streamService.deleteChannel, canDelete: () => Boolean(getStreamClient())});
module.exports = { ...lifecycle, createLifecycleService };
