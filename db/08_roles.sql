\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

-- Создаём роли
CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

-- Сначала забираем все права у всех
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_reader;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_writer;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

-- Читатель: только представления
GRANT SELECT ON v_track_card TO app_reader;
GRANT SELECT ON v_playlist_summary TO app_reader;

-- Писатель: только безопасные функции
GRANT EXECUTE ON FUNCTION add_track_safe(integer, integer, integer) TO app_writer;
GRANT EXECUTE ON FUNCTION track_listen_count(integer) TO app_writer;