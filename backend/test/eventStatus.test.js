const test = require('node:test');
const assert = require('node:assert/strict');
const { validateEventChange, effectiveStatus } = require('../src/services/eventStatusPolicy');
const { createEventSchema, listEventsSchema } = require('../src/schemas/eventSchemas');
const now = new Date('2026-09-21T12:00:00Z');
const event = { status: 'draft', startsAt: '2026-09-22T12:00:00Z', endsAt: '2026-09-22T14:00:00Z', participantCount: 3, maxParticipants: 10 };
test('draft can publish, save, or cancel, but cannot complete', () => {
  for (const status of ['draft','published','cancelled']) assert.equal(validateEventChange(event,{status},now).status,status);
  assert.throws(() => validateEventChange(event,{status:'completed'},now));
});
test('published event cannot become private or complete before start', () => {
  for (const status of ['draft','completed']) assert.throws(() => validateEventChange({...event,status:'published'},{status},now));
  assert.equal(validateEventChange({...event,status:'published'},{status:'cancelled'},now).status,'cancelled');
});
test('ongoing event can complete; expired event cannot be revived or edited', () => {
  const started={...event,status:'published',startsAt:'2026-09-21T10:00:00Z'};
  assert.equal(validateEventChange(started,{status:'completed'},now).status,'completed');
  const expired={...started,endsAt:now.toISOString()};
  assert.equal(effectiveStatus(expired,now),'completed');
  assert.throws(() => validateEventChange(expired,{endsAt:'2026-09-23T10:00:00Z'},now));
});
test('terminal states prohibit all edits and reopening', () => {
  for (const status of ['completed','cancelled']) {
    assert.throws(() => validateEventChange({...event,status},{status:'published'},now));
    assert.throws(() => validateEventChange({...event,status},{title:'Changed'},now));
  }
});
test('validates merged dates and capacity for partial updates', () => {
  assert.throws(() => validateEventChange(event,{endsAt:event.startsAt},now));
  assert.throws(() => validateEventChange(event,{maxParticipants:2},now));
  assert.throws(() => validateEventChange({...event,startsAt:'2026-09-20T10:00:00Z'},{status:'published'},now));
});
test('public list rejects draft status and create rejects terminal status', () => {
  assert.equal(listEventsSchema.safeParse({status:'draft'}).success,false);
  assert.equal(createEventSchema.shape.status.safeParse('completed').success,false);
  assert.equal(createEventSchema.shape.status.safeParse('draft').success,true);
});
