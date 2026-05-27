CREATE EXTENSION IF NOT EXISTS postgis;

ALTER TABLE events
ADD COLUMN IF NOT EXISTS geo GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (
    ST_SetSRID(
        ST_MakePoint(longitude::DOUBLE PRECISION, latitude::DOUBLE PRECISION),
        4326
    )::GEOGRAPHY
) STORED;

DROP INDEX IF EXISTS idx_events_latitude_longitude;
DROP INDEX IF EXISTS idx_events_status_latitude_longitude;

CREATE INDEX IF NOT EXISTS idx_events_geo ON events USING GIST (geo);
CREATE INDEX IF NOT EXISTS idx_events_published_geo ON events USING GIST (geo)
WHERE status = 'published';
