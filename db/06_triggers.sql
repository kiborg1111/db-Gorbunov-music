-- Правило: нельзя прослушать трек дольше, чем его длительность
CREATE OR REPLACE FUNCTION check_listening_duration()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_track_duration integer;
BEGIN
    SELECT duration_sec INTO v_track_duration
    FROM tracks
    WHERE id = NEW.track_id;

    IF NEW.duration_listened_sec > v_track_duration THEN
        RAISE EXCEPTION 'Нельзя прослушать трек % дольше его длительности (% сек)', 
            NEW.track_id, v_track_duration;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_listening_duration
BEFORE INSERT OR UPDATE ON listenings
FOR EACH ROW
EXECUTE FUNCTION check_listening_duration();

-- Служебный триггер: обновляет updated_at у плейлистов
ALTER TABLE playlists ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_playlists_updated_at
BEFORE UPDATE ON playlists
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Журнал изменений для таблицы tracks
CREATE TABLE IF NOT EXISTS tracks_history (
    id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_id    integer NOT NULL,
    operation   text NOT NULL,
    old_data    jsonb,
    new_data    jsonb,
    changed_by  text NOT NULL DEFAULT session_user,
    changed_at  timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE OR REPLACE FUNCTION log_tracks_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO tracks_history (track_id, operation, new_data)
        VALUES (NEW.id, 'INSERT', to_jsonb(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO tracks_history (track_id, operation, old_data, new_data)
        VALUES (NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO tracks_history (track_id, operation, old_data)
        VALUES (OLD.id, 'DELETE', to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_tracks_history
AFTER INSERT OR UPDATE OR DELETE ON tracks
FOR EACH ROW
EXECUTE FUNCTION log_tracks_changes();

-- Функция: состояние трека на определённую дату
CREATE OR REPLACE FUNCTION track_state_at(p_track_id integer, p_moment timestamptz)
RETURNS jsonb
LANGUAGE sql
AS $$
    SELECT new_data
    FROM tracks_history
    WHERE track_id = p_track_id
      AND changed_at <= p_moment
    ORDER BY changed_at DESC
    LIMIT 1;
$$;