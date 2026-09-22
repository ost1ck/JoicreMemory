const test = require('node:test');
const assert = require('node:assert/strict');
function stub(path, exports) {
  const id = require.resolve(path);
  require.cache[id] = { id, filename: id, loaded: true, exports };
}
const auth = (req, res, next) => { req.auth = { firebaseUid: 'owner' }; next(); };
stub('../src/middlewares/authMiddleware', { authenticate: auth, optionalAuthenticate: auth });
stub('../src/controllers/eventController', new Proxy({}, { get: (_, name) => name === 'createEvent' ? async (req, res) => res.json(req.body) : () => {} }));
const router = require('../src/routes/eventRoutes');
test('dedicated draft endpoint forces draft status before validation', async () => {
  const route = router.stack.find(layer => layer.route?.path === '/drafts').route;
  assert.equal(route.methods.post, true);
  const request = { body: { status: 'published', title: 'Draft', description: 'A valid description', category: 'cleanup', locationName: 'Park', latitude: 49, longitude: 24, startsAt: '2099-01-01T10:00:00Z' } };
  const result = await new Promise((resolve, reject) => {
    let index = 0;
    const response = { json: resolve };
    function next(error) {
      if (error) return reject(error);
      const layer = route.stack[index++];
      if (!layer) return reject(new Error('No response'));
      try { layer.handle(request, response, next); } catch (failure) { reject(failure); }
    }
    next();
  });
  assert.equal(result.status, 'draft');
  assert.equal(request.auth.firebaseUid, 'owner');
});
