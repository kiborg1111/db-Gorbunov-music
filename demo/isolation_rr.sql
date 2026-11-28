-- [A] Уровень REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) FROM playlist_tracks WHERE playlist_id = 1;
-- expect: value 3

-- [B]
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position) VALUES (1, 6, 5);
COMMIT;

-- [A] Второе чтение (видит старое значение)
SELECT count(*) FROM playlist_tracks WHERE playlist_id = 1;
-- expect: value 3
COMMIT;