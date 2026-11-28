CREATE OR REPLACE FUNCTION add_track_safe(p_playlist_id integer, p_track_id integer, p_position integer)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT 1 INTO v_dummy FROM playlists WHERE id = p_playlist_id FOR UPDATE;

    SELECT count(*) INTO v_count
    FROM playlist_tracks
    WHERE playlist_id = p_playlist_id;

    IF v_count >= 3 THEN
        RAISE EXCEPTION 'В плейлисте уже 3 трека';
    END IF;

    INSERT INTO playlist_tracks (playlist_id, track_id, position)
    VALUES (p_playlist_id, p_track_id, p_position);
END;
$$;