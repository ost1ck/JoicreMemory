const ApiError = require('../utils/apiError');
function effectiveStatus(event, now = new Date()) {
  return event.status === 'published' && event.endsAt && new Date(event.endsAt) <= now ? 'completed' : event.status;
}
function validateEventChange(event, payload, now = new Date()) {
  const current = effectiveStatus(event, now);
  const next = payload.status || current;
  const allowed = { draft: ['draft', 'published', 'cancelled'], published: ['published', 'completed', 'cancelled'], completed: [], cancelled: [] };
  if (!allowed[current]?.includes(next)) throw new ApiError(409, 'Ця зміна статусу вже недоступна. Онови подію.');
  if (next === 'completed' && new Date(event.startsAt) > now) throw new ApiError(400, 'Завершити можна лише подію, яка вже почалася.');
  const merged = { ...event, ...payload };
  if (current === 'published' && payload.startsAt && new Date(payload.startsAt).getTime() !== new Date(event.startsAt).getTime() && new Date(payload.startsAt) <= now) throw new ApiError(400, 'Новий час початку має бути в майбутньому.');
  if (merged.endsAt && new Date(merged.endsAt) <= new Date(merged.startsAt)) throw new ApiError(400, 'Завершення має бути пізніше за початок.');
  if (next === 'published' && merged.endsAt && new Date(merged.endsAt) <= now) throw new ApiError(400, 'Час завершення вже минув.');
  if (current === 'draft' && next === 'published' && new Date(merged.startsAt) <= now) throw new ApiError(400, 'Перед публікацією обери майбутній час початку.');
  if (current === 'published' && payload.startsAt && new Date(payload.startsAt).getTime() !== new Date(event.startsAt).getTime() && new Date(event.startsAt) <= now) throw new ApiError(400, 'Не можна переносити початок події, яка вже почалася.');
  if (merged.maxParticipants != null && merged.maxParticipants < (event.participantCount || 0)) throw new ApiError(400, 'Ліміт не може бути меншим за кількість учасників.');
  return merged;
}
module.exports = { effectiveStatus, validateEventChange };
