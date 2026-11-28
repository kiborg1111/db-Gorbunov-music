-- 1. Транзакция, которая падает на середине
-- expect: error
BEGIN;
UPDATE playlists SET description = 'тест' WHERE id = 1;
INSERT INTO listenings (track_id, duration_listened_sec) VALUES (1, 999999);
COMMIT;

-- 2. Данные не изменились
-- expect: same 0
SELECT count(*) FROM playlists WHERE id = 1 AND description = 'тест';