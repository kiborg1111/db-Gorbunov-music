-- 1. Запоминаем текущее описание плейлиста
SELECT description FROM playlists WHERE id = 1;

-- 2. Транзакция, которая падает на середине
-- expect: error
BEGIN;
UPDATE playlists SET description = 'тест' WHERE id = 1;
INSERT INTO listenings (track_id, duration_listened_sec) VALUES (1, 999999);
COMMIT;

-- 3. Описание не изменилось
-- expect: same 1
SELECT description FROM playlists WHERE id = 1;