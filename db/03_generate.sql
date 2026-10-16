INSERT INTO listenings (track_id, listened_at, duration_listened_sec)
SELECT
    (random() * 15 + 1)::int,
    now() - (random() * interval '60 days'),
    (random() * 280 + 30)::int
FROM generate_series(1, 2000);