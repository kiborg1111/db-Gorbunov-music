-- Все треки с названием альбома и исполнителем (JOIN)
SELECT t.title AS track, a.title AS album, ar.name AS artist
FROM tracks t
JOIN albums a ON a.id = t.album_id
JOIN artists ar ON ar.id = a.artist_id
ORDER BY ar.name, a.title, t.track_number;

-- Сколько треков в каждом альбоме (JOIN + GROUP BY + count)
SELECT a.title AS album, count(*) AS track_count
FROM albums a
JOIN tracks t ON t.album_id = a.id
GROUP BY a.id, a.title
ORDER BY track_count DESC;

-- Альбомы, в которых больше 1 трека (JOIN + GROUP BY + HAVING)
SELECT a.title AS album, count(*) AS track_count
FROM albums a
JOIN tracks t ON t.album_id = a.id
GROUP BY a.id, a.title
HAVING count(*) > 1;

-- Треки, которые ни разу не прослушивались (LEFT JOIN + IS NULL (сироты))
SELECT t.title AS track, a.title AS album
FROM tracks t
JOIN albums a ON a.id = t.album_id
LEFT JOIN listenings l ON l.track_id = t.id
WHERE l.id IS NULL;

-- Треки, которые ни разу не прослушивались (LEFT JOIN + IS NULL)
SELECT t.title
FROM tracks t
LEFT JOIN listenings l ON l.track_id = t.id
WHERE l.id IS NULL;

-- Треки из плейлиста "Chill Vibes" (IN)
SELECT title
FROM tracks
WHERE id IN (
    SELECT track_id
    FROM playlist_tracks
    WHERE playlist_id = (SELECT id FROM playlists WHERE name = 'Chill Vibes')
);

-- Исполнители, у которых есть альбомы после 2020 года (EXISTS)
SELECT name
FROM artists ar
WHERE EXISTS (
    SELECT 1 FROM albums a
    WHERE a.artist_id = ar.id AND a.release_date >= '2020-01-01'
);

-- Средняя длительность треков по жанрам альбомов (JOIN + GROUP BY + avg)
SELECT a.genre, round(avg(t.duration_sec), 1) AS avg_duration
FROM tracks t
JOIN albums a ON a.id = t.album_id
GROUP BY a.genre
ORDER BY avg_duration DESC;

-- Самый длинный трек в каждом альбоме (JOIN)
SELECT a.title AS album, t.title AS longest_track, t.duration_sec
FROM tracks t
JOIN albums a ON a.id = t.album_id
WHERE t.duration_sec = (
    SELECT max(duration_sec)
    FROM tracks t2
    WHERE t2.album_id = t.album_id
);

-- Добавление нового прослушивания (INSERT + BEGIN/ROLLBACK)
BEGIN;
SELECT count(*) AS before FROM listenings;
INSERT INTO listenings (track_id, duration_listened_sec)
VALUES (1, 180);
SELECT count(*) AS after FROM listenings;
ROLLBACK;

-- Увеличение длительности всех треков длиннее 300 сек на 10 секунд (UPDATE + BEGIN/ROLLBACK)
BEGIN;
SELECT title, duration_sec FROM tracks WHERE duration_sec > 300;
UPDATE tracks SET duration_sec = duration_sec + 10 WHERE duration_sec > 300;
SELECT title, duration_sec FROM tracks WHERE duration_sec > 310;
ROLLBACK;

-- Удаление прослушиваний старше 30 дней (DELETE + BEGIN/ROLLBACK)
BEGIN;
SELECT count(*) AS before FROM listenings WHERE listened_at < now() - interval '30 days';
DELETE FROM listenings WHERE listened_at < now() - interval '30 days';
SELECT count(*) AS after FROM listenings WHERE listened_at < now() - interval '30 days';
ROLLBACK;

-- Топ-3 самых длинных трека в каждом жанре (CTE (WITH) + оконная функция ROW_NUMBER)
WITH ranked_tracks AS (
    SELECT
        a.genre,
        t.title,
        t.duration_sec,
        ROW_NUMBER() OVER (PARTITION BY a.genre ORDER BY t.duration_sec DESC) AS rn
    FROM tracks t
    JOIN albums a ON a.id = t.album_id
)
SELECT genre, title, duration_sec
FROM ranked_tracks
WHERE rn <= 3
ORDER BY genre, rn;

-- Накопительное количество прослушиваний по дням (оконная функция SUM() OVER (ORDER BY))
SELECT
    listened_at::date AS day,
    count(*) AS listens_per_day,
    SUM(count(*)) OVER (ORDER BY listened_at::date) AS cumulative_listens
FROM listenings
GROUP BY listened_at::date
ORDER BY day;

-- По каждому жанру: сколько треков всего, сколько длиннее 300 сек, сколько короче 200 сек и процент длинных (GROUP BY + count(*) FILTER (WHERE ...) + доля в процентах)
SELECT
    a.genre,
    count(*) AS total_tracks,
    count(*) FILTER (WHERE t.duration_sec > 300) AS long_tracks,
    count(*) FILTER (WHERE t.duration_sec < 200) AS short_tracks,
    round(100.0 * count(*) FILTER (WHERE t.duration_sec > 300) / count(*), 1) AS long_pct
FROM tracks t
JOIN albums a ON a.id = t.album_id
GROUP BY a.genre
ORDER BY total_tracks DESC;