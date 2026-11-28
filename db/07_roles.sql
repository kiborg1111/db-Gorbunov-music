\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

GRANT SELECT ON v_track_card TO app_reader;
GRANT SELECT ON v_playlist_summary TO app_reader;

-- Запрещаем читателю менять таблицы
REVOKE ALL ON tracks FROM app_reader;
REVOKE ALL ON albums FROM app_reader;
REVOKE ALL ON artists FROM app_reader;
REVOKE ALL ON playlists FROM app_reader;
REVOKE ALL ON playlist_tracks FROM app_reader;
REVOKE ALL ON listenings FROM app_reader;

-- Писатель не трогает таблицы напрямую
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_writer;

-- Писатель может вызывать безопасную функцию
GRANT EXECUTE ON FUNCTION add_track_safe(integer, integer, integer) TO app_writer;
GRANT EXECUTE ON FUNCTION track_listen_count(integer) TO app_writer;