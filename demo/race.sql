-- [setup] Оставляем 2 трека
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id NOT IN (3, 7);

-- [A]
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position) VALUES (1, 1, 3);

-- [B]
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position) VALUES (1, 2, 4);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check]
-- expect: false
SELECT count(*) <= 3 FROM playlist_tracks WHERE playlist_id = 1;

-- [cleanup]
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id IN (1, 2);