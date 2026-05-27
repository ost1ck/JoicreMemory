const swaggerSpec = {
  openapi: '3.0.3',
  info: {
    title: 'JoicreMemory API',
    version: '1.0.0',
    description: 'REST API for local social initiatives.'
  },
  servers: [
    {
      url: 'http://localhost:3000/api',
      description: 'Local development'
    }
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'Firebase ID Token'
      },
      devFirebaseUid: {
        type: 'apiKey',
        in: 'header',
        name: 'x-dev-firebase-uid'
      }
    },
    schemas: {
      User: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          firebaseUid: { type: 'string' },
          email: { type: 'string', format: 'email' },
          fullName: { type: 'string' },
          avatarUrl: { type: 'string', nullable: true },
          bio: { type: 'string', nullable: true },
          phone: { type: 'string', nullable: true },
          streamUserId: { type: 'string', nullable: true },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' }
        }
      },
      Event: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          creatorUserId: { type: 'string', format: 'uuid' },
          title: { type: 'string' },
          description: { type: 'string' },
          category: {
            type: 'string',
            enum: ['volunteering', 'charity', 'cleanup', 'education', 'community', 'emergency', 'other']
          },
          status: {
            type: 'string',
            enum: ['draft', 'published', 'cancelled', 'completed']
          },
          locationName: { type: 'string' },
          address: { type: 'string', nullable: true },
          latitude: { type: 'number' },
          longitude: { type: 'number' },
          startsAt: { type: 'string', format: 'date-time' },
          endsAt: { type: 'string', format: 'date-time', nullable: true },
          maxParticipants: { type: 'integer', nullable: true },
          imageUrl: { type: 'string', nullable: true },
          participantCount: { type: 'integer' },
          distanceMeters: { type: 'number', nullable: true },
          chatChannelId: { type: 'string' }
        }
      },
      EventChat: {
        type: 'object',
        properties: {
          eventId: { type: 'string', format: 'uuid' },
          eventTitle: { type: 'string' },
          locationName: { type: 'string' },
          startsAt: { type: 'string', format: 'date-time' },
          status: { type: 'string' },
          creatorUserId: { type: 'string', format: 'uuid' },
          streamChannelId: { type: 'string' },
          avatarUrl: { type: 'string', nullable: true },
          participantCount: { type: 'integer' },
          isOrganizer: { type: 'boolean' }
        }
      },
      ChatMember: {
        type: 'object',
        properties: {
          userId: { type: 'string', format: 'uuid' },
          fullName: { type: 'string' },
          avatarUrl: { type: 'string', nullable: true },
          streamUserId: { type: 'string', nullable: true },
          role: { type: 'string', enum: ['organizer', 'participant'] },
          joinedAt: { type: 'string', format: 'date-time' }
        }
      },
      SyncUserInput: {
        type: 'object',
        properties: {
          email: { type: 'string', example: 'ostap@example.com' },
          fullName: { type: 'string', example: 'Остап Котула' },
          avatarUrl: { type: 'string', nullable: true }
        }
      },
      CreateEventInput: {
        type: 'object',
        required: ['title', 'description', 'category', 'locationName', 'latitude', 'longitude', 'startsAt'],
        properties: {
          title: { type: 'string', example: 'Прибирання парку' },
          description: { type: 'string', example: 'Збираємося, щоб прибрати територію парку після вихідних.' },
          category: { type: 'string', example: 'cleanup' },
          locationName: { type: 'string', example: 'Стрийський парк' },
          address: { type: 'string', example: 'Львів, вул. Паркова' },
          latitude: { type: 'number', example: 49.8223 },
          longitude: { type: 'number', example: 24.0232 },
          startsAt: { type: 'string', format: 'date-time', example: '2026-06-01T10:00:00.000Z' },
          endsAt: { type: 'string', format: 'date-time', nullable: true, example: '2026-06-01T13:00:00.000Z' },
          maxParticipants: { type: 'integer', nullable: true, example: 30 },
          imageUrl: { type: 'string', nullable: true }
        }
      },
      UpdateProfileInput: {
        type: 'object',
        properties: {
          fullName: { type: 'string', example: 'Остап Котула' },
          avatarUrl: { type: 'string', nullable: true },
          bio: { type: 'string', nullable: true },
          phone: { type: 'string', nullable: true }
        }
      },
      UpdateChatInput: {
        type: 'object',
        properties: {
          avatarUrl: { type: 'string', nullable: true }
        }
      },
      ReportEvent: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          title: { type: 'string' },
          category: { type: 'string' },
          status: { type: 'string' },
          locationName: { type: 'string' },
          address: { type: 'string', nullable: true },
          startsAt: { type: 'string', format: 'date-time' },
          endsAt: { type: 'string', format: 'date-time', nullable: true },
          maxParticipants: { type: 'integer', nullable: true },
          participantCount: { type: 'integer' },
          participants: {
            type: 'array',
            items: { $ref: '#/components/schemas/ChatMember' }
          }
        }
      },
      UserReport: {
        type: 'object',
        properties: {
          generatedAt: { type: 'string', format: 'date-time' },
          user: { $ref: '#/components/schemas/User' },
          summary: {
            type: 'object',
            properties: {
              createdEvents: { type: 'integer' },
              joinedEvents: { type: 'integer' },
              totalEvents: { type: 'integer' },
              organizedParticipantTotal: { type: 'integer' },
              totalParticipationHours: { type: 'number' },
              averageFillRatePercent: { type: 'integer' },
              upcomingEvents: { type: 'integer' },
              completedEvents: { type: 'integer' }
            }
          },
          createdEvents: {
            type: 'array',
            items: { $ref: '#/components/schemas/ReportEvent' }
          },
          joinedEvents: {
            type: 'array',
            items: { $ref: '#/components/schemas/ReportEvent' }
          }
        }
      },
      Error: {
        type: 'object',
        properties: {
          message: { type: 'string' },
          details: { type: 'object' }
        }
      }
    }
  },
  paths: {
    '/health': {
      get: {
        tags: ['Health'],
        summary: 'Check API health',
        responses: {
          200: { description: 'API is healthy' }
        }
      }
    },
    '/auth/sync': {
      post: {
        tags: ['Auth'],
        summary: 'Create or update current user profile from Firebase auth',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        requestBody: {
          required: false,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/SyncUserInput' }
            }
          }
        },
        responses: {
          200: {
            description: 'Synced user',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { data: { $ref: '#/components/schemas/User' } }
                }
              }
            }
          }
        }
      }
    },
    '/users/me': {
      get: {
        tags: ['Users'],
        summary: 'Get current user',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        responses: { 200: { description: 'Current user' } }
      },
      patch: {
        tags: ['Users'],
        summary: 'Update current user profile',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/UpdateProfileInput' }
            }
          }
        },
        responses: { 200: { description: 'Updated user' } }
      }
    },
    '/users/{id}': {
      get: {
        tags: ['Users'],
        summary: 'Get public user by id',
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 200: { description: 'User' } }
      }
    },
    '/events': {
      get: {
        tags: ['Events'],
        summary: 'List events with optional geo search',
        parameters: [
          { name: 'latitude', in: 'query', schema: { type: 'number' } },
          { name: 'longitude', in: 'query', schema: { type: 'number' } },
          { name: 'radiusMeters', in: 'query', schema: { type: 'integer', default: 10000 } },
          { name: 'category', in: 'query', schema: { type: 'string' } },
          { name: 'search', in: 'query', schema: { type: 'string' } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 20 } },
          { name: 'offset', in: 'query', schema: { type: 'integer', default: 0 } }
        ],
        responses: { 200: { description: 'Event list' } }
      },
      post: {
        tags: ['Events'],
        summary: 'Create event',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/CreateEventInput' }
            }
          }
        },
        responses: { 201: { description: 'Created event' } }
      }
    },
    '/events/mine': {
      get: {
        tags: ['Events'],
        summary: 'List current user events',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        responses: { 200: { description: 'Current user events' } }
      }
    },
    '/events/{id}': {
      get: {
        tags: ['Events'],
        summary: 'Get event by id',
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 200: { description: 'Event' } }
      },
      patch: {
        tags: ['Events'],
        summary: 'Update event as organizer',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/CreateEventInput' }
            }
          }
        },
        responses: { 200: { description: 'Updated event' } }
      },
      delete: {
        tags: ['Events'],
        summary: 'Delete event as creator',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 204: { description: 'Deleted' } }
      }
    },
    '/events/{id}/join': {
      post: {
        tags: ['Events'],
        summary: 'Join event',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 200: { description: 'Joined event' } }
      }
    },
    '/events/{id}/leave': {
      post: {
        tags: ['Events'],
        summary: 'Leave event',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 200: { description: 'Left event' } }
      }
    },
    '/reports/me': {
      get: {
        tags: ['Reports'],
        summary: 'Build current user report with analytics data',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        responses: {
          200: {
            description: 'Current user report',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { data: { $ref: '#/components/schemas/UserReport' } }
                }
              }
            }
          }
        }
      }
    },
    '/chats/stream-token': {
      get: {
        tags: ['Chats'],
        summary: 'Get Stream user token',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        responses: { 200: { description: 'Stream token data' } }
      }
    },
    '/chats': {
      get: {
        tags: ['Chats'],
        summary: 'List event chats available to current user',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        responses: { 200: { description: 'Event chats' } }
      }
    },
    '/chats/{eventId}': {
      patch: {
        tags: ['Chats'],
        summary: 'Update event chat settings as organizer',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'eventId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/UpdateChatInput' }
            }
          }
        },
        responses: { 200: { description: 'Updated chat' } }
      }
    },
    '/chats/{eventId}/members': {
      get: {
        tags: ['Chats'],
        summary: 'List event chat members',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [{ name: 'eventId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
        responses: { 200: { description: 'Chat members' } }
      }
    },
    '/chats/{eventId}/members/{userId}': {
      delete: {
        tags: ['Chats'],
        summary: 'Kick participant from event and chat as organizer',
        security: [{ bearerAuth: [] }, { devFirebaseUid: [] }],
        parameters: [
          { name: 'eventId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } },
          { name: 'userId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }
        ],
        responses: { 200: { description: 'Updated chat members' } }
      }
    }
  }
};

module.exports = swaggerSpec;
