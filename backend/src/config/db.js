const { AsyncLocalStorage } = require('node:async_hooks');
const transactions = new AsyncLocalStorage();
const { Pool } = require('pg');
const env = require('./env');

const shouldUseSsl =
  env.databaseUrl.includes('sslmode=require') ||
  env.databaseUrl.includes('supabase.com') ||
  env.nodeEnv === 'production';

function removeSslMode(connectionString) {
  try {
    const url = new URL(connectionString);
    url.searchParams.delete('sslmode');
    return url.toString();
  } catch (error) {
    return connectionString.replace(/[?&]sslmode=[^&]+&?/, (match) =>
      match.startsWith('?') && match.endsWith('&') ? '?' : ''
    );
  }
}

const pool = new Pool({
  connectionString: shouldUseSsl ? removeSslMode(env.databaseUrl) : env.databaseUrl,
  ssl: shouldUseSsl
    ? {
        rejectUnauthorized: false
      }
    : undefined
});

pool.on('error', (error) => {
  console.error('Unexpected PostgreSQL pool error', error);
});

module.exports = {
  query: (text, params) => (transactions.getStore() || pool).query(text, params),
  async withEventLock(id, action) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('SELECT id FROM events WHERE id = $1 FOR UPDATE', [id]);
      const result = await transactions.run(client, action);
      await client.query('COMMIT');
      return result;
    } catch (error) { await client.query('ROLLBACK'); throw error; }
    finally { client.release(); }
  },
  pool
};
