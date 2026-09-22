const test = require('node:test');
const assert = require('node:assert/strict');
function stub(path, exports) { const id = require.resolve(path); require.cache[id] = { id, filename:id, loaded:true, exports }; }
let stored, provisioned, updates;
const repository = {
  create: async data => (stored={...data,id:'event',participantCount:1,status:data.status || 'published'}),
  findById: async () => stored,
  findParticipant: async (_,id) => ({role:id==='owner'?'organizer':'participant',status:'joined'}),
  update: async (_,data) => { updates++; return (stored={...stored,...data}); },
  findChatChannelByEventId: async () => null,
  createChatChannel: async () => ({stream_channel_id:'channel'}),
  upsertParticipant: async () => { throw Error('Unexpected participation'); },
};
stub('../src/config/db', {withEventLock: async (_,action) => action()});
stub('../src/repositories/eventRepository', repository);
stub('../src/repositories/userRepository', {findByFirebaseUid:async uid=>({id:uid}),findById:async id=>({id,firebaseUid:id})});
stub('../src/services/streamService', {buildEventChannelId:()=> 'channel',upsertUsers:async()=>{},ensureEventChannel:async()=> {provisioned++;}});
stub('../src/services/eventLifecycleService', {cleanup:async()=>{}});
const service = require('../src/services/eventService');
const payload={title:'Test',description:'Description',startsAt:'2099-01-01T10:00:00Z',endsAt:'2099-01-01T12:00:00Z',status:'draft'};
test.beforeEach(()=> {stored={...payload,id:'event',creatorUserId:'owner',participantCount:1};provisioned=0;updates=0;});
test('draft creation does not create Stream channel', async()=> {
 const result=await service.createEvent({firebaseUid:'owner'},payload);
 assert.equal(result.status,'draft'); assert.equal(provisioned,0);
});
test('draft details are private even when the id is known', async()=> {
 await assert.rejects(service.getVisibleEvent('event'),{statusCode:404});
 await assert.rejects(service.getVisibleEvent('event',{firebaseUid:'other'}),{statusCode:404});
 assert.equal((await service.getVisibleEvent('event',{firebaseUid:'owner'})).status,'draft');
});
test('publishing provisions chat and non-owner cannot change status', async()=> {
 await assert.rejects(service.updateEvent({firebaseUid:'other'},'event',{status:'published'}),{statusCode:403});
 assert.equal(updates,0);
 assert.equal((await service.updateEvent({firebaseUid:'owner'},'event',{status:'published'})).status,'published');
 assert.equal(provisioned,1);
});
test('drafts and terminal events reject joining before any chat work', async()=> {
 for(const status of ['draft','cancelled','completed']) {
   stored.status=status;
   await assert.rejects(service.joinEvent({firebaseUid:'other'},'event'),{statusCode:409});
 }
 assert.equal(provisioned,0);
});
