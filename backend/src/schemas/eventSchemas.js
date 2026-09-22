const { z } = require('zod');

const eventCategories = [
  'volunteering',
  'charity',
  'cleanup',
  'education',
  'community',
  'emergency',
  'other'
];

const createEventSchema = z.object({
  status: z.enum(['draft', 'published']).optional(),
  title: z.string().trim().min(3).max(140),
  description: z.string().min(10).max(5000),
  category: z.enum(eventCategories),
  locationName: z.string().min(2).max(180),
  address: z.string().max(240).optional().nullable(),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  startsAt: z.string().datetime(),
  endsAt: z.string().datetime().optional().nullable(),
  maxParticipants: z.number().int().min(1).max(10000).optional().nullable(),
  imageUrl: z.string().url().optional().nullable()
});

const updateEventSchema = createEventSchema.partial().extend({
  status: z.enum(['draft', 'published', 'cancelled', 'completed']).optional()
});

const listEventsSchema = z.object({
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
  radiusMeters: z.coerce.number().min(100).max(100000).optional(),
  categories: z.preprocess(value => typeof value === 'string' ? value.split(',') : value, z.array(z.enum(eventCategories)).min(1).max(7).optional()),
  startsFrom: z.string().datetime().optional(),
  startsBefore: z.string().datetime().optional(),
  category: z.enum(eventCategories).optional(),
  status: z.enum(['published', 'cancelled', 'completed']).optional(),
  search: z.string().max(120).optional(),
  limit: z.coerce.number().int().min(1).max(100).optional(),
  offset: z.coerce.number().int().min(0).optional()
}).refine(value => !value.startsFrom || !value.startsBefore || new Date(value.startsFrom) < new Date(value.startsBefore), {message: 'Невірний діапазон дат', path: ['startsBefore']});

module.exports = {
  createEventSchema,
  updateEventSchema,
  listEventsSchema,
  eventCategories
};

