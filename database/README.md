# JoicreMemory Database

PostgreSQL + PostGIS schema for JoicreMemory.

Required extensions:

- `postgis` for geo points, distance calculation, and radius search.
- `pgcrypto` for UUID generation.
- `citext` for case-insensitive emails.

Recommended local database:

```bash
docker compose -f database/docker-compose.yml up -d
psql "postgres://postgres:postgres@localhost:5433/joicrememory" -f database/schema.sql
```

If you already have an existing database without PostGIS, apply the migration:

```bash
psql "$DATABASE_URL" -f database/migrations/001_enable_postgis.sql
```

For event chat avatars on an existing database:

```bash
psql "$DATABASE_URL" -f database/migrations/002_event_chat_channels_avatar.sql
```

Important for Homebrew users: PostGIS must match the PostgreSQL server version.
For this project the Docker database avoids local `postgresql@14` / PostGIS
version conflicts.

Backend connection string for the Docker database:

```env
DATABASE_URL=postgres://postgres:postgres@localhost:5433/joicrememory
```

Example nearby events query:

```sql
SELECT
    id,
    title,
    category,
    location_name,
    starts_at,
    ST_Distance(
        geo,
        ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography
    ) AS distance_meters
FROM events
WHERE status = 'published'
  AND ST_DWithin(
      geo,
      ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography,
      :radius_meters
  )
ORDER BY distance_meters ASC, starts_at ASC;
```
