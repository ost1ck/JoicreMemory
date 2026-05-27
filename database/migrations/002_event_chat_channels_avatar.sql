ALTER TABLE event_chat_channels
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

ALTER TABLE event_chat_channels
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'event_chat_channels_avatar_url_valid'
    ) THEN
        ALTER TABLE event_chat_channels
        ADD CONSTRAINT event_chat_channels_avatar_url_valid CHECK (
            avatar_url IS NULL OR avatar_url ~* '^https?://'
        );
    END IF;
END;
$$;

DROP TRIGGER IF EXISTS trg_event_chat_channels_set_updated_at
ON event_chat_channels;

CREATE TRIGGER trg_event_chat_channels_set_updated_at
BEFORE UPDATE ON event_chat_channels
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
