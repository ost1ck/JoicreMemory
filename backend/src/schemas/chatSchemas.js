const { z } = require('zod');

const updateChatSchema = z.object({
  avatarUrl: z.string().url().optional().nullable()
});

module.exports = {
  updateChatSchema
};
