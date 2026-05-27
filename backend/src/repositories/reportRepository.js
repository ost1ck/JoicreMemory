const db = require('../config/db');

function mapParticipant(row) {
  return {
    userId: row.userId,
    fullName: row.fullName,
    email: row.email,
    avatarUrl: row.avatarUrl,
    role: row.role,
    joinedAt: row.joinedAt
  };
}

function normalizeParticipants(value) {
  if (!value) {
    return [];
  }

  if (Array.isArray(value)) {
    return value.map(mapParticipant);
  }

  try {
    return JSON.parse(value).map(mapParticipant);
  } catch (_) {
    return [];
  }
}

function mapReportEvent(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    title: row.title,
    description: row.description,
    category: row.category,
    status: row.status,
    locationName: row.location_name,
    address: row.address,
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    maxParticipants: row.max_participants,
    participantCount: Number(row.participant_count || 0),
    role: row.current_user_role || undefined,
    joinedAt: row.current_user_joined_at || undefined,
    participants: normalizeParticipants(row.participants)
  };
}

async function listCreatedEvents(userId) {
  const result = await db.query(
    `
      SELECT
        e.id,
        e.title,
        e.description,
        e.category,
        e.status,
        e.location_name,
        e.address,
        e.starts_at,
        e.ends_at,
        e.max_participants,
        COUNT(joined.user_id) FILTER (WHERE joined.status = 'joined') AS participant_count,
        COALESCE(
          json_agg(
            json_build_object(
              'userId', users.id,
              'fullName', users.full_name,
              'email', users.email,
              'avatarUrl', users.avatar_url,
              'role', joined.role,
              'joinedAt', joined.created_at
            )
            ORDER BY
              CASE joined.role WHEN 'organizer' THEN 0 ELSE 1 END,
              users.full_name ASC
          ) FILTER (WHERE joined.user_id IS NOT NULL AND joined.status = 'joined'),
          '[]'::json
        ) AS participants
      FROM events e
      LEFT JOIN event_participants joined
        ON joined.event_id = e.id
       AND joined.status = 'joined'
      LEFT JOIN users ON users.id = joined.user_id
      WHERE e.creator_user_id = $1
      GROUP BY e.id
      ORDER BY e.starts_at DESC
    `,
    [userId]
  );

  return result.rows.map(mapReportEvent);
}

async function listJoinedEvents(userId) {
  const result = await db.query(
    `
      SELECT
        e.id,
        e.title,
        e.description,
        e.category,
        e.status,
        e.location_name,
        e.address,
        e.starts_at,
        e.ends_at,
        e.max_participants,
        current_user_participation.role AS current_user_role,
        current_user_participation.created_at AS current_user_joined_at,
        COUNT(joined.user_id) FILTER (WHERE joined.status = 'joined') AS participant_count,
        COALESCE(
          json_agg(
            json_build_object(
              'userId', users.id,
              'fullName', users.full_name,
              'email', users.email,
              'avatarUrl', users.avatar_url,
              'role', joined.role,
              'joinedAt', joined.created_at
            )
            ORDER BY
              CASE joined.role WHEN 'organizer' THEN 0 ELSE 1 END,
              users.full_name ASC
          ) FILTER (WHERE joined.user_id IS NOT NULL AND joined.status = 'joined'),
          '[]'::json
        ) AS participants
      FROM event_participants current_user_participation
      JOIN events e ON e.id = current_user_participation.event_id
      LEFT JOIN event_participants joined
        ON joined.event_id = e.id
       AND joined.status = 'joined'
      LEFT JOIN users ON users.id = joined.user_id
      WHERE current_user_participation.user_id = $1
        AND current_user_participation.status = 'joined'
        AND e.creator_user_id <> $1
      GROUP BY e.id, current_user_participation.role, current_user_participation.created_at
      ORDER BY e.starts_at DESC
    `,
    [userId]
  );

  return result.rows.map(mapReportEvent);
}

module.exports = {
  listCreatedEvents,
  listJoinedEvents
};
