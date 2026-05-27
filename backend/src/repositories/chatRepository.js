const db = require('../config/db');

function mapChat(row) {
  if (!row) {
    return null;
  }

  return {
    eventId: row.event_id,
    eventTitle: row.event_title,
    locationName: row.location_name,
    startsAt: row.starts_at,
    status: row.status,
    creatorUserId: row.creator_user_id,
    streamChannelId: row.stream_channel_id,
    avatarUrl: row.avatar_url,
    participantCount: Number(row.participant_count || 0),
    isOrganizer: row.current_user_role === 'organizer'
  };
}

function mapMember(row) {
  if (!row) {
    return null;
  }

  return {
    userId: row.user_id,
    fullName: row.full_name,
    avatarUrl: row.avatar_url,
    streamUserId: row.stream_user_id,
    role: row.role,
    joinedAt: row.joined_at
  };
}

async function listByUser(userId) {
  const result = await db.query(
    `
      SELECT
        e.id AS event_id,
        e.title AS event_title,
        e.location_name,
        e.starts_at,
        e.status,
        e.creator_user_id,
        chat.stream_channel_id,
        chat.avatar_url,
        current_user_participation.role AS current_user_role,
        COUNT(participants.user_id) FILTER (WHERE participants.status = 'joined') AS participant_count
      FROM events e
      JOIN event_chat_channels chat ON chat.event_id = e.id
      JOIN event_participants current_user_participation
        ON current_user_participation.event_id = e.id
       AND current_user_participation.user_id = $1
       AND current_user_participation.status = 'joined'
      LEFT JOIN event_participants participants
        ON participants.event_id = e.id
       AND participants.status = 'joined'
      WHERE e.status IN ('published', 'completed')
      GROUP BY e.id, chat.id, current_user_participation.role
      ORDER BY e.starts_at ASC
    `,
    [userId]
  );

  return result.rows.map(mapChat);
}

async function findByEventId(eventId) {
  const result = await db.query(
    `
      SELECT
        e.id AS event_id,
        e.title AS event_title,
        e.location_name,
        e.starts_at,
        e.status,
        e.creator_user_id,
        chat.stream_channel_id,
        chat.avatar_url,
        COUNT(participants.user_id) FILTER (WHERE participants.status = 'joined') AS participant_count
      FROM events e
      JOIN event_chat_channels chat ON chat.event_id = e.id
      LEFT JOIN event_participants participants
        ON participants.event_id = e.id
       AND participants.status = 'joined'
      WHERE e.id = $1
      GROUP BY e.id, chat.id
    `,
    [eventId]
  );

  return mapChat(result.rows[0]);
}

async function updateAvatar(eventId, avatarUrl) {
  const result = await db.query(
    `
      UPDATE event_chat_channels
      SET avatar_url = $2
      WHERE event_id = $1
      RETURNING *
    `,
    [eventId, avatarUrl]
  );

  return result.rows[0] || null;
}

async function listMembers(eventId) {
  const result = await db.query(
    `
      SELECT
        users.id AS user_id,
        users.full_name,
        users.avatar_url,
        users.stream_user_id,
        participants.role,
        participants.created_at AS joined_at
      FROM event_participants participants
      JOIN users ON users.id = participants.user_id
      WHERE participants.event_id = $1
        AND participants.status = 'joined'
      ORDER BY
        CASE participants.role WHEN 'organizer' THEN 0 ELSE 1 END,
        users.full_name ASC
    `,
    [eventId]
  );

  return result.rows.map(mapMember);
}

module.exports = {
  listByUser,
  findByEventId,
  updateAvatar,
  listMembers
};
