CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

DROP TABLE IF EXISTS event_chat_channels CASCADE;
DROP TABLE IF EXISTS event_participants CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS add_event_creator_as_organizer() CASCADE;
DROP FUNCTION IF EXISTS set_updated_at() CASCADE;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid TEXT NOT NULL UNIQUE,
    email CITEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    stream_user_id TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT users_full_name_length CHECK (char_length(full_name) BETWEEN 2 AND 120),
    CONSTRAINT users_bio_length CHECK (bio IS NULL OR char_length(bio) <= 500),
    CONSTRAINT users_email_not_blank CHECK (char_length(trim(email::TEXT)) > 3)
);

CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'published',
    location_name TEXT NOT NULL,
    address TEXT,
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    geo GEOGRAPHY(Point, 4326) GENERATED ALWAYS AS (
        ST_SetSRID(
            ST_MakePoint(longitude::DOUBLE PRECISION, latitude::DOUBLE PRECISION),
            4326
        )::GEOGRAPHY
    ) STORED,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    max_participants INTEGER,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT events_title_length CHECK (char_length(title) BETWEEN 3 AND 140),
    CONSTRAINT events_description_length CHECK (char_length(description) BETWEEN 10 AND 5000),
    CONSTRAINT events_category_valid CHECK (
        category IN (
            'volunteering',
            'charity',
            'cleanup',
            'education',
            'community',
            'emergency',
            'other'
        )
    ),
    CONSTRAINT events_status_valid CHECK (
        status IN ('draft', 'published', 'cancelled', 'completed')
    ),
    CONSTRAINT events_latitude_valid CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT events_longitude_valid CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT events_time_range_valid CHECK (ends_at IS NULL OR ends_at >= starts_at),
    CONSTRAINT events_max_participants_valid CHECK (
        max_participants IS NULL OR max_participants BETWEEN 1 AND 10000
    )
);

CREATE TABLE event_participants (
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'participant',
    status TEXT NOT NULL DEFAULT 'joined',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (event_id, user_id),
    CONSTRAINT event_participants_role_valid CHECK (role IN ('organizer', 'participant')),
    CONSTRAINT event_participants_status_valid CHECK (status IN ('joined', 'pending', 'cancelled'))
);

CREATE TABLE event_chat_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL UNIQUE REFERENCES events(id) ON DELETE CASCADE,
    stream_channel_id TEXT NOT NULL UNIQUE,
    avatar_url TEXT,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT event_chat_channels_avatar_url_valid CHECK (
        avatar_url IS NULL OR avatar_url ~* '^https?://'
    )
);

CREATE OR REPLACE FUNCTION add_event_creator_as_organizer()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO event_participants (event_id, user_id, role, status)
    VALUES (NEW.id, NEW.creator_user_id, 'organizer', 'joined')
    ON CONFLICT (event_id, user_id)
    DO UPDATE SET role = 'organizer', status = 'joined', updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_events_set_updated_at
BEFORE UPDATE ON events
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_event_participants_set_updated_at
BEFORE UPDATE ON event_participants
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_event_chat_channels_set_updated_at
BEFORE UPDATE ON event_chat_channels
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_events_add_creator_as_organizer
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION add_event_creator_as_organizer();

CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_stream_user_id ON users(stream_user_id);

CREATE INDEX idx_events_creator_user_id ON events(creator_user_id);
CREATE INDEX idx_events_status_starts_at ON events(status, starts_at);
CREATE INDEX idx_events_category_status ON events(category, status);
CREATE INDEX idx_events_geo ON events USING GIST (geo);
CREATE INDEX idx_events_published_geo ON events USING GIST (geo)
WHERE status = 'published';

CREATE INDEX idx_event_participants_user_id ON event_participants(user_id);
CREATE INDEX idx_event_participants_event_role ON event_participants(event_id, role);

CREATE INDEX idx_event_chat_channels_event_id ON event_chat_channels(event_id);
