-- [setup]
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id NOT IN (3, 7, 13);

-- [A]
BEGIN;
SELECT add_track_safe(1, 1, 4);

-- [B]
BEGIN;
SELECT add_track_safe(1, 2, 5);
-- expect: blocked

-- [A]
COMMIT;

-- [B]
-- expect: error "уже 3 трека"
COMMIT;

-- [check]
-- expect: true
SELECT count(*) <= 3 FROM playlist_tracks WHERE playlist_id = 1;

-- [cleanup]
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id IN (1, 2);