-- 1. Выборка из представления карточки трека
SELECT * FROM v_track_card LIMIT 5;

-- 2. Выборка из сводки плейлистов
SELECT * FROM v_playlist_summary;

-- 3. Вызов функции подсчёта прослушиваний
SELECT track_listen_count(1);

-- 4. Добавление трека в плейлист
BEGIN;
SELECT add_track_to_playlist(1, 1, 10);
SELECT * FROM playlist_tracks WHERE playlist_id = 1 AND track_id = 1;
ROLLBACK;

-- 5. Нарушение правила: прослушивание дольше длительности трека
INSERT INTO listenings (track_id, duration_listened_sec)
VALUES (1, 99999);

-- 6. Работа служебного триггера
BEGIN;
SELECT name, updated_at FROM playlists WHERE id = 1;
UPDATE playlists SET description = description || ' (обновлено)' WHERE id = 1;
SELECT name, updated_at FROM playlists WHERE id = 1;
ROLLBACK;

-- 7. Обновление материализованного представления
REFRESH MATERIALIZED VIEW mv_top_tracks;
SELECT * FROM mv_top_tracks LIMIT 5;

-- 8. Поиск треков (фильтр только по жанру)
SELECT * FROM search_tracks('Hip-Hop', NULL, NULL);

-- 9. Поиск треков (минимальная длительность)
SELECT * FROM search_tracks(NULL, 300, NULL);

-- 10. Журнал изменений (после UPDATE)
BEGIN;
UPDATE tracks SET title = title || ' (тест)' WHERE id = 1;
SELECT operation, old_data->>'title' AS old_title, new_data->>'title' AS new_title
FROM tracks_history
WHERE track_id = 1
ORDER BY changed_at DESC
LIMIT 1;
ROLLBACK;

-- 11. Состояние трека на дату
SELECT track_state_at(1, now());