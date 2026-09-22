const test = require('node:test');
const assert = require('node:assert/strict');
const { listEventsSchema } = require('../src/schemas/eventSchemas');
let statement, parameters;
const dbPath=require.resolve('../src/config/db');
require.cache[dbPath]={id:dbPath,filename:dbPath,loaded:true,exports:{query:async(sql,params)=>{statement=sql;parameters=params;return {rows:[]};}}};
const events=require('../src/repositories/eventRepository');
test('multiple categories and UTC date bounds parse together',()=> {
 const value=listEventsSchema.parse({categories:'cleanup,education',startsFrom:'2026-10-01T00:00:00Z',startsBefore:'2026-10-03T00:00:00Z',radiusMeters:'5000'});
 assert.deepEqual(value.categories,['cleanup','education']); assert.equal(value.radiusMeters,5000);
});
test('invalid dates, reversed range, unknown category and excessive radius are rejected',()=> {
 for(const value of [{categories:'cleanup,nope'},{startsFrom:'tomorrow'},{startsFrom:'2026-10-03T00:00:00Z',startsBefore:'2026-10-01T00:00:00Z'},{radiusMeters:100001}]) assert.equal(listEventsSchema.safeParse(value).success,false);
});
test('combined search uses category set, inclusive start and exclusive end with bound parameters',async()=>{
 await events.list({categories:['cleanup','education'],startsFrom:'2026-10-01T00:00:00Z',startsBefore:'2026-10-03T00:00:00Z',latitude:49,longitude:24,radiusMeters:5000,limit:100,offset:0});
 assert.match(statement,/e.category = ANY\(/); assert.match(statement,/e.starts_at >=/); assert.match(statement,/e.starts_at </); assert.match(statement,/ST_DWithin/);
 assert.ok(parameters.some(p=>Array.isArray(p)&&p.length===2)); assert.ok(parameters.includes(5000));
 assert.equal(statement.includes('education'),false);
});
