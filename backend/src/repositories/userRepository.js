const db = require('../config/db');

function mapUser(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    firebaseUid: row.firebase_uid,
    email: row.email,
    fullName: row.full_name,
    avatarUrl: row.avatar_url,
    bio: row.bio,
    phone: row.phone,
    streamUserId: row.stream_user_id,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

async function findById(id) {
  const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
  return mapUser(result.rows[0]);
}

async function findByFirebaseUid(firebaseUid) {
  const result = await db.query('SELECT * FROM users WHERE firebase_uid = $1', [firebaseUid]);
  return mapUser(result.rows[0]);
}

async function upsertFromAuth({ firebaseUid, email, fullName, avatarUrl }) {
  const result = await db.query(
    `
      INSERT INTO users (firebase_uid, email, full_name, avatar_url, stream_user_id)
      VALUES ($1, $2, $3, $4, $1)
      ON CONFLICT (firebase_uid)
      DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(NULLIF(EXCLUDED.full_name, ''), users.full_name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url),
        stream_user_id = COALESCE(users.stream_user_id, EXCLUDED.stream_user_id)
      RETURNING *
    `,
    [firebaseUid, email, fullName, avatarUrl]
  );

  return mapUser(result.rows[0]);
}

async function updateProfile(userId, data) {
  const fields = [];
  const values = [];

  const mapping = {
    fullName: 'full_name',
    avatarUrl: 'avatar_url',
    bio: 'bio',
    phone: 'phone'
  };

  Object.entries(mapping).forEach(([inputKey, column]) => {
    if (Object.prototype.hasOwnProperty.call(data, inputKey)) {
      values.push(data[inputKey]);
      fields.push(`${column} = $${values.length}`);
    }
  });

  if (fields.length === 0) {
    return findById(userId);
  }

  values.push(userId);

  const result = await db.query(
    `
      UPDATE users
      SET ${fields.join(', ')}
      WHERE id = $${values.length}
      RETURNING *
    `,
    values
  );

  return mapUser(result.rows[0]);
}

module.exports = {
  mapUser,
  findById,
  findByFirebaseUid,
  upsertFromAuth,
  updateProfile
};

