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
  query: (text, params) => pool.query(text, params),
  pool
};
