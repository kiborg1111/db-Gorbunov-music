-- Повтор уникального значения: ошибка UNIQUE
INSERT INTO artists (name, country) VALUES ('Smash Mouth', 'США');

-- Отрицательная длительность трека: ошибка CHECK
INSERT INTO tracks (album_id, title, duration_sec, track_number)
VALUES (1, 'Broken Track', -10, 99);

-- Ссылка на несуществующую строку: ошибка внешнего ключа
INSERT INTO listenings (track_id, duration_listened_sec)
VALUES (99999, 180);
