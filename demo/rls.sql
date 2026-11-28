-- Под ролью app_user видно только свои строки
SET ROLE app_user;
SELECT count(*) FROM listenings;  -- только свои
RESET ROLE;

-- Под postgres видно всё
SELECT count(*) FROM listenings;  -- все строки