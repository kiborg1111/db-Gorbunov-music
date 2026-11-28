-- [setup] Оставляем 2 трека
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id NOT IN (3, 7);

-- [A] Добавляем 3-й трек и блокируем
BEGIN;
SELECT add_track_safe(1, 1, 3);

-- [B] Ждёт, а после COMMIT окна A получит ошибку
BEGIN;
-- expect: blocked
-- expect: error "уже 3 трека"
SELECT add_track_safe(1, 2, 4);

-- [A]
COMMIT;

-- [B]
ROLLBACK;

-- [check]
-- expect: true
SELECT count(*) <= 3 FROM playlist_tracks WHERE playlist_id = 1;

-- [cleanup]
DELETE FROM playlist_tracks WHERE playlist_id = 1 AND track_id IN (1, 2);