-- Включаем RLS на таблице прослушиваний
ALTER TABLE listenings ENABLE ROW LEVEL SECURITY;

ALTER TABLE listenings ADD COLUMN IF NOT EXISTS user_name text DEFAULT current_user;

CREATE POLICY listenings_own ON listenings
    FOR ALL
    USING (user_name = current_user);

-- Роль обычного пользователя (пароль из .env)
\getenv user_password APP_USER_PASSWORD
CREATE ROLE app_user LOGIN PASSWORD :'user_password';

REVOKE ALL ON listenings FROM app_user;
GRANT SELECT, INSERT ON listenings TO app_user;