-- Включаем RLS на таблице прослушиваний
ALTER TABLE listenings ENABLE ROW LEVEL SECURITY;

-- Политика: пользователь видит только свои прослушивания
-- (для примера создадим колонку user_name, если её нет)
ALTER TABLE listenings ADD COLUMN IF NOT EXISTS user_name text DEFAULT current_user;

CREATE POLICY listenings_own ON listenings
    FOR ALL
    USING (user_name = current_user);

-- Роль обычного пользователя
CREATE ROLE app_user LOGIN PASSWORD 'user123';
GRANT SELECT, INSERT ON listenings TO app_user;