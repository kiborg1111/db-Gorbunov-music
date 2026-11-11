-- Карточка трека с альбомом и исполнителем
CREATE OR REPLACE VIEW v_track_card AS
SELECT 
    t.id,
    t.title AS track_title,
    t.duration_sec,
    a.title AS album_title,
    a.genre,
    ar.name AS artist_name
FROM tracks t
JOIN albums a ON a.id = t.album_id
JOIN artists ar ON ar.id = a.artist_id;

-- Плейлист с количеством треков и общей длительностью
CREATE OR REPLACE VIEW v_playlist_summary AS
SELECT 
    p.id,
    p.name,
    p.description,
    count(pt.track_id) AS track_count,
    coalesce(sum(t.duration_sec), 0) AS total_duration_sec
FROM playlists p
LEFT JOIN playlist_tracks pt ON pt.playlist_id = p.id
LEFT JOIN tracks t ON t.id = pt.track_id
GROUP BY p.id, p.name, p.description;

-- Материализованное представление: топ треков по количеству прослушиваний
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_top_tracks AS
SELECT 
    t.id,
    t.title,
    count(l.id) AS listen_count
FROM tracks t
LEFT JOIN listenings l ON l.track_id = t.id
GROUP BY t.id, t.title
ORDER BY listen_count DESC;

CREATE UNIQUE INDEX IF NOT EXISTS mv_top_tracks_id ON mv_top_tracks (id);