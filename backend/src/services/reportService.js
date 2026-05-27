const reportRepository = require('../repositories/reportRepository');
const userRepository = require('../repositories/userRepository');
const ApiError = require('../utils/apiError');

async function requireSyncedUser(auth) {
  const user = await userRepository.findByFirebaseUid(auth.firebaseUid);

  if (!user) {
    throw new ApiError(404, 'User profile is not synced. Call POST /api/auth/sync first.');
  }

  return user;
}

function eventDurationHours(event) {
  if (!event.endsAt) {
    return 0;
  }

  const startsAt = new Date(event.startsAt).getTime();
  const endsAt = new Date(event.endsAt).getTime();

  if (!Number.isFinite(startsAt) || !Number.isFinite(endsAt) || endsAt <= startsAt) {
    return 0;
  }

  return Math.round((endsAt - startsAt) / 36_000) / 100;
}

function buildCategoryBreakdown(events) {
  const byCategory = new Map();

  events.forEach((event) => {
    const current = byCategory.get(event.category) || {
      category: event.category,
      createdCount: 0,
      joinedCount: 0,
      totalCount: 0,
      participantCount: 0,
      durationHours: 0
    };

    if (event.reportRole === 'created') {
      current.createdCount += 1;
    } else {
      current.joinedCount += 1;
    }

    current.totalCount += 1;
    current.participantCount += event.participantCount;
    current.durationHours += eventDurationHours(event);
    byCategory.set(event.category, current);
  });

  return [...byCategory.values()].sort((a, b) => {
    if (b.totalCount !== a.totalCount) {
      return b.totalCount - a.totalCount;
    }

    return a.category.localeCompare(b.category);
  });
}

function buildSummary(createdEvents, joinedEvents) {
  const allEvents = [
    ...createdEvents.map((event) => ({ ...event, reportRole: 'created' })),
    ...joinedEvents.map((event) => ({ ...event, reportRole: 'joined' }))
  ];
  const now = Date.now();
  const createdWithCapacity = createdEvents.filter(
    (event) => event.maxParticipants && event.maxParticipants > 0
  );
  const averageFillRatePercent =
    createdWithCapacity.length === 0
      ? 0
      : Math.round(
          createdWithCapacity.reduce(
            (sum, event) =>
              sum + Math.min(event.participantCount / event.maxParticipants, 1),
            0
          ) *
            100 /
            createdWithCapacity.length
        );

  return {
    createdEvents: createdEvents.length,
    joinedEvents: joinedEvents.length,
    totalEvents: allEvents.length,
    organizedParticipantTotal: createdEvents.reduce(
      (sum, event) => sum + event.participantCount,
      0
    ),
    totalParticipationHours: allEvents.reduce(
      (sum, event) => sum + eventDurationHours(event),
      0
    ),
    averageFillRatePercent,
    upcomingEvents: allEvents.filter((event) => new Date(event.startsAt).getTime() >= now).length,
    completedEvents: allEvents.filter((event) => {
      const endsAt = event.endsAt ? new Date(event.endsAt).getTime() : null;
      return event.status === 'completed' || (endsAt !== null && endsAt < now);
    }).length,
    categories: buildCategoryBreakdown(allEvents)
  };
}

async function getCurrentUserReport(auth) {
  const user = await requireSyncedUser(auth);
  const [createdEvents, joinedEvents] = await Promise.all([
    reportRepository.listCreatedEvents(user.id),
    reportRepository.listJoinedEvents(user.id)
  ]);

  return {
    generatedAt: new Date().toISOString(),
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      avatarUrl: user.avatarUrl,
      bio: user.bio
    },
    summary: buildSummary(createdEvents, joinedEvents),
    createdEvents,
    joinedEvents
  };
}

module.exports = {
  getCurrentUserReport
};
