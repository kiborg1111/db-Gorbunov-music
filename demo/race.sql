-- [setup] Оставляем в плейлисте 1 место (максимум 3 трека)
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id NOT IN (3, 7, 13);

-- [A] Окно A добавляет 4-й трек
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position)
VALUES (1, 1, 4);

-- [B] Окно B в тот же момент добавляет ещё один
BEGIN;
INSERT INTO playlist_tracks (playlist_id, track_id, position)
VALUES (1, 2, 5);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] В плейлисте не больше 3 треков?
-- expect: false
SELECT count(*) <= 3 FROM playlist_tracks WHERE playlist_id = 1;

-- [cleanup]
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id IN (1, 2);