-- [A] Первое чтение
BEGIN;
SELECT count(*) FROM playlist_tracks WHERE playlist_id = 1;
-- expect: value 3

-- [B] Меняем данные
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position) VALUES (1, 5, 4);
COMMIT;

-- [A] Второе чтение (видит новое значение)
SELECT count(*) FROM playlist_tracks WHERE playlist_id = 1;
-- expect: value 4
COMMIT;