const { z } = require('zod');

const syncUserSchema = z.object({
  email: z.string().email().optional(),
  fullName: z.string().min(2).max(120).optional(),
  avatarUrl: z.string().url().optional().nullable()
});

const updateProfileSchema = z.object({
  fullName: z.string().min(2).max(120).optional(),
  avatarUrl: z.string().url().optional().nullable(),
  bio: z.string().max(500).optional().nullable(),
  phone: z.string().max(40).optional().nullable()
});

module.exports = {
  syncUserSchema,
  updateProfileSchema
};

