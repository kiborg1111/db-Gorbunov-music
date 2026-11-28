-- [A] Блокирует плейлист 1
BEGIN;
SELECT * FROM playlists WHERE id = 1 FOR UPDATE;

-- [B] Блокирует плейлист 2
BEGIN;
SELECT * FROM playlists WHERE id = 2 FOR UPDATE;

-- [A] Ждёт плейлист 2
SELECT * FROM playlists WHERE id = 2 FOR UPDATE;
-- expect: blocked

-- [B] Ждёт плейлист 1 → deadlock
SELECT * FROM playlists WHERE id = 1 FOR UPDATE;
-- expect: error deadlock

-- [cleanup]
ROLLBACK;