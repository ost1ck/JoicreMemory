const { Pool } = require('pg');
const env = require('./env');

const shouldUseSsl =
  env.databaseUrl.includes('sslmode=require') ||
  env.databaseUrl.includes('supabase.com') ||
  env.nodeEnv === 'production';

const pool = new Pool({
  connectionString: env.databaseUrl,
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
