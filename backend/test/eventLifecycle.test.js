const test = require('node:test');
const assert = require('node:assert/strict');
const { createLifecycleService } = require('../src/services/eventLifecycleWorker');
function fixture({ configured = true, fail = false } = {}) {
  const actions = [];
  const worker = createLifecycleService({
    query: async (sql, params) => {
      if (sql.startsWith('UPDATE')) { actions.push('complete'); return { rows: [] }; }
      if (sql.startsWith('SELECT')) return { rows: [{ event_id: 'event', stream_channel_id: 'channel' }] };
      actions.push(['remove-row', ...params]); return { rows: [] };
    },
    canDelete: () => configured,
    deleteChannel: async (id) => { actions.push(['delete-stream', id]); if (fail) throw Error('offline'); }
  });
  return { worker, actions };
}
test('deletes Stream history before removing the local chat reference', async () => {
  const { worker, actions } = fixture();
  await worker.cleanup();
  assert.deepEqual(actions, ['complete', ['delete-stream', 'channel'], ['remove-row', 'event', 'channel']]);
});
test('failed deletion keeps the reference for retry', async () => {
  const { worker, actions } = fixture({ fail: true });
  await worker.cleanup(); await worker.cleanup();
  assert.equal(actions.filter(x => Array.isArray(x) && x[0] === 'delete-stream').length, 2);
  assert.equal(actions.some(x => Array.isArray(x) && x[0] === 'remove-row'), false);
});
test('missing Stream credentials never discard pending deletion records', async () => {
  const { worker, actions } = fixture({ configured: false });
  await worker.cleanup(); assert.deepEqual(actions, ['complete']);
});
test('overlapping sweeps share the same work', async () => {
  const { worker, actions } = fixture();
  await Promise.all([worker.cleanup(), worker.cleanup()]);
  assert.equal(actions.filter(x => x === 'complete').length, 1);
});
