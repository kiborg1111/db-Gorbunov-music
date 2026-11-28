-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.
--
-- Пример, замените своими таблицами:
-- Исполнители
CREATE TABLE artists (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          text NOT NULL,
    country       text,
    founded_date  date,
    CONSTRAINT artists_name_unique UNIQUE (name)
);

-- Альбомы
CREATE TABLE albums (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_id     integer NOT NULL REFERENCES artists (id) ON DELETE RESTRICT,
    title         text NOT NULL,
    release_date  date NOT NULL,
    genre         text,
    CONSTRAINT albums_artist_title_unique UNIQUE (artist_id, title),
    CONSTRAINT albums_release_date_check CHECK (release_date <= CURRENT_DATE)
);

-- Треки
CREATE TABLE tracks (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    album_id      integer NOT NULL REFERENCES albums (id) ON DELETE CASCADE,
    title         text NOT NULL,
    duration_sec  integer NOT NULL,
    track_number  integer NOT NULL,
    CONSTRAINT tracks_duration_positive CHECK (duration_sec > 0),
    CONSTRAINT tracks_number_positive CHECK (track_number > 0),
    CONSTRAINT tracks_album_number_unique UNIQUE (album_id, track_number)
);

-- Плейлисты
CREATE TABLE playlists (
    id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          text NOT NULL,
    description   text,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT playlists_name_unique UNIQUE (name)
);

-- Связующая таблица
CREATE TABLE playlist_tracks (
    playlist_id   integer NOT NULL REFERENCES playlists (id) ON DELETE CASCADE,
    track_id      integer NOT NULL REFERENCES tracks (id) ON DELETE CASCADE,
    position      integer NOT NULL,
    added_at      timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (playlist_id, track_id),
    CONSTRAINT playlist_tracks_position_positive CHECK (position > 0)
);

-- Прослушивания
CREATE TABLE listenings (
    id                    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_id              integer NOT NULL REFERENCES tracks (id) ON DELETE CASCADE,
    listened_at           timestamptz NOT NULL DEFAULT now(),
    duration_listened_sec integer NOT NULL,
    CONSTRAINT listenings_duration_positive CHECK (duration_listened_sec > 0)
);
