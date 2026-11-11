-- Сколько раз прослушали трек
CREATE OR REPLACE FUNCTION track_listen_count(p_track_id integer)
RETURNS integer
LANGUAGE sql
AS $$
    SELECT count(*)::integer
    FROM listenings
    WHERE track_id = p_track_id;
$$;

-- Добавить трек в плейлист
CREATE OR REPLACE FUNCTION add_track_to_playlist(
    p_playlist_id integer,
    p_track_id integer,
    p_position integer
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO playlist_tracks (playlist_id, track_id, position)
    VALUES (p_playlist_id, p_track_id, p_position);
END;
$$;

-- Поиск треков с фильтрам
CREATE OR REPLACE FUNCTION search_tracks(
    p_genre text DEFAULT NULL,
    p_min_duration integer DEFAULT NULL,
    p_artist text DEFAULT NULL
)
RETURNS TABLE (
    track_id integer,
    track_title text,
    album_title text,
    artist_name text,
    duration_sec integer,
    genre text
)
LANGUAGE sql
AS $$
    SELECT 
        t.id,
        t.title,
        a.title,
        ar.name,
        t.duration_sec,
        a.genre
    FROM tracks t
    JOIN albums a ON a.id = t.album_id
    JOIN artists ar ON ar.id = a.artist_id
    WHERE (p_genre IS NULL OR a.genre = p_genre)
      AND (p_min_duration IS NULL OR t.duration_sec >= p_min_duration)
      AND (p_artist IS NULL OR ar.name ILIKE '%' || p_artist || '%');
$$;