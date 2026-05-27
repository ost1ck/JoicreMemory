const db = require('../config/db');

function mapEvent(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    creatorUserId: row.creator_user_id,
    title: row.title,
    description: row.description,
    category: row.category,
    status: row.status,
    locationName: row.location_name,
    address: row.address,
    latitude: Number(row.latitude),
    longitude: Number(row.longitude),
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    maxParticipants: row.max_participants,
    imageUrl: row.image_url,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    participantCount: Number(row.participant_count || 0),
    distanceMeters: row.distance_meters === null || row.distance_meters === undefined
      ? null
      : Number(row.distance_meters),
    creator: row.creator_id
      ? {
          id: row.creator_id,
          fullName: row.creator_full_name,
          avatarUrl: row.creator_avatar_url
        }
      : undefined,
    chatChannelId: row.stream_channel_id || undefined,
    chatAvatarUrl: row.chat_avatar_url || undefined
  };
}

function buildEventSelect(distanceSql = 'NULL') {
  return `
    SELECT
      e.*,
      ${distanceSql} AS distance_meters,
      creator.id AS creator_id,
      creator.full_name AS creator_full_name,
      creator.avatar_url AS creator_avatar_url,
      chat.stream_channel_id,
      chat.avatar_url AS chat_avatar_url,
      COUNT(participants.user_id) FILTER (WHERE participants.status = 'joined') AS participant_count
    FROM events e
    JOIN users creator ON creator.id = e.creator_user_id
    LEFT JOIN event_chat_channels chat ON chat.event_id = e.id
    LEFT JOIN event_participants participants ON participants.event_id = e.id
  `;
}

async function create(data) {
  const result = await db.query(
    `
      INSERT INTO events (
        creator_user_id,
        title,
        description,
        category,
        location_name,
        address,
        latitude,
        longitude,
        starts_at,
        ends_at,
        max_participants,
        image_url
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `,
    [
      data.creatorUserId,
      data.title,
      data.description,
      data.category,
      data.locationName,
      data.address,
      data.latitude,
      data.longitude,
      data.startsAt,
      data.endsAt,
      data.maxParticipants,
      data.imageUrl
    ]
  );

  return mapEvent(result.rows[0]);
}

async function findById(id) {
  const result = await db.query(
    `
      ${buildEventSelect()}
      WHERE e.id = $1
      GROUP BY e.id, creator.id, chat.stream_channel_id, chat.avatar_url
    `,
    [id]
  );

  return mapEvent(result.rows[0]);
}

async function list(filters) {
  const values = [];
  const conditions = [];

  let distanceSql = 'NULL';

  if (filters.latitude !== undefined && filters.longitude !== undefined && filters.radiusMeters !== undefined) {
    values.push(filters.latitude);
    const latParam = `$${values.length}`;
    values.push(filters.longitude);
    const lngParam = `$${values.length}`;
    values.push(filters.radiusMeters);
    const radiusParam = `$${values.length}`;

    const searchPointSql = `
      ST_SetSRID(
        ST_MakePoint(${lngParam}::double precision, ${latParam}::double precision),
        4326
      )::geography
    `;

    distanceSql = `
      ST_Distance(e.geo, ${searchPointSql})
    `;

    conditions.push(`ST_DWithin(e.geo, ${searchPointSql}, ${radiusParam})`);
  }

  values.push(filters.status || 'published');
  conditions.push(`e.status = $${values.length}`);

  if (filters.category) {
    values.push(filters.category);
    conditions.push(`e.category = $${values.length}`);
  }

  if (filters.search) {
    values.push(`%${filters.search}%`);
    conditions.push(`(e.title ILIKE $${values.length} OR e.description ILIKE $${values.length})`);
  }

  values.push(filters.limit);
  const limitParam = `$${values.length}`;
  values.push(filters.offset);
  const offsetParam = `$${values.length}`;

  const result = await db.query(
    `
      ${buildEventSelect(distanceSql)}
      WHERE ${conditions.join(' AND ')}
      GROUP BY e.id, creator.id, chat.stream_channel_id, chat.avatar_url
      ORDER BY
        distance_meters ASC NULLS LAST,
        e.starts_at ASC
      LIMIT ${limitParam}
      OFFSET ${offsetParam}
    `,
    values
  );

  return result.rows.map(mapEvent);
}

async function listByUser(userId) {
  const result = await db.query(
    `
      ${buildEventSelect()}
      JOIN event_participants current_user_participation
        ON current_user_participation.event_id = e.id
       AND current_user_participation.user_id = $1
       AND current_user_participation.status = 'joined'
      GROUP BY e.id, creator.id, chat.stream_channel_id, chat.avatar_url
      ORDER BY e.starts_at ASC
    `,
    [userId]
  );

  return result.rows.map(mapEvent);
}

async function update(id, data) {
  const fields = [];
  const values = [];

  const mapping = {
    title: 'title',
    description: 'description',
    category: 'category',
    status: 'status',
    locationName: 'location_name',
    address: 'address',
    latitude: 'latitude',
    longitude: 'longitude',
    startsAt: 'starts_at',
    endsAt: 'ends_at',
    maxParticipants: 'max_participants',
    imageUrl: 'image_url'
  };

  Object.entries(mapping).forEach(([inputKey, column]) => {
    if (Object.prototype.hasOwnProperty.call(data, inputKey)) {
      values.push(data[inputKey]);
      fields.push(`${column} = $${values.length}`);
    }
  });

  if (fields.length === 0) {
    return findById(id);
  }

  values.push(id);

  const result = await db.query(
    `
      UPDATE events
      SET ${fields.join(', ')}
      WHERE id = $${values.length}
      RETURNING *
    `,
    values
  );

  return mapEvent(result.rows[0]);
}

async function remove(id) {
  const result = await db.query('DELETE FROM events WHERE id = $1 RETURNING id', [id]);
  return result.rowCount > 0;
}

async function upsertParticipant(eventId, userId, status = 'joined') {
  const result = await db.query(
    `
      INSERT INTO event_participants (event_id, user_id, role, status)
      VALUES ($1, $2, 'participant', $3)
      ON CONFLICT (event_id, user_id)
      DO UPDATE SET status = EXCLUDED.status
      RETURNING *
    `,
    [eventId, userId, status]
  );

  return result.rows[0];
}

async function findParticipant(eventId, userId) {
  const result = await db.query(
    'SELECT * FROM event_participants WHERE event_id = $1 AND user_id = $2',
    [eventId, userId]
  );
  return result.rows[0] || null;
}

async function createChatChannel(eventId, createdByUserId, streamChannelId) {
  const result = await db.query(
    `
      INSERT INTO event_chat_channels (event_id, created_by_user_id, stream_channel_id)
      VALUES ($1, $2, $3)
      ON CONFLICT (event_id)
      DO UPDATE SET stream_channel_id = EXCLUDED.stream_channel_id
      RETURNING *
    `,
    [eventId, createdByUserId, streamChannelId]
  );

  return result.rows[0];
}

async function findChatChannelByEventId(eventId) {
  const result = await db.query(
    'SELECT * FROM event_chat_channels WHERE event_id = $1',
    [eventId]
  );

  return result.rows[0] || null;
}

module.exports = {
  mapEvent,
  create,
  findById,
  list,
  listByUser,
  update,
  remove,
  upsertParticipant,
  findParticipant,
  createChatChannel,
  findChatChannelByEventId
};
