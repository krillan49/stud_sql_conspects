--                                        Создание, удаление баз данных.

SHOW DATABASES;   -- (?? в скюлайт не работает ??) выведет все БД и таблицы, в том числе служебные(information_schema, mysql, performance_schema, sys)



--                                        CREATE DATABASE - Создание БД

-- https://www.postgresql.org/docs/current/sql-createdatabase.html

-- Для имени БД можно использовать буквы, цифры, а также символы "_" и "$". Имя может начинаться с цифр, но не может состоять только из них. Максимальная длина имени составляет 64 знака.

CREATE DATABASE имя_базы_данных;                -- создание БД

-- [ PostgreSQL ] Создание БД по заданным параметрам:
CREATE DATABASE db_name
  WITH                     -- Параметры создания БД:
  OWNER = postgres         -- пользователь/владелец
  ENCODING = 'UTF8'        -- кодировка в которой будут символы нашей БД
  LOCALE_PROVIDER = 'libc' -- локаль определяет для разных регионов например формат Float(точка или запятая), дат итд
  CONNECTION LIMIT = -1    -- ограничение на количество подключений к БД (-1 значит что ограничений нет)
  IS_TEMPLATE = False;
-- По умолчанию, именно такие параметры будут заданы автоматически, если создать без них



--                                        CREATE DATABASE IF NOT EXISTS

-- [ MySQL ] создание БД только если ее не существует
CREATE DATABASE IF NOT EXISTS имя_базы_данных;


-- [ PostgreSQL ] В PostgreSQL нет операции CREATE DATABASE IF NOT EXISTS, но её можно сэмулировать:
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'ваша_бд') THEN
    EXECUTE 'CREATE DATABASE ваша_бд';
  END IF;
END $$;

-- Можно обернуть логику в функцию для последующего применения:
CREATE OR REPLACE FUNCTION create_database_if_not_exists(dbname TEXT) RETURNS void AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = dbname) THEN
    EXECUTE format('CREATE DATABASE %I', dbname);
  END IF;
END
$$ LANGUAGE plpgsql;
-- Теперь вы можете создать базу данных, вызвав:
create_database_if_not_exists('ваша_бд')



--                                        DROP DATABASE Удаление БД

DROP DATABASE имя_базы_данных;                  -- Удаление БД во всех СУБД:
DROP DATABASE IF EXISTS имя_базы_данных;        -- [ PostgreSQL, MySQL ] удаление БД только если она существует (?? во всех СУБД)


-- [PostgreSQL] У той БД которую хотим удалить не должен существовать сеанс подключения иначе возникнет ошибка. Чтобы удалить все подключения к некой БД:
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'имя_бд' AND pid <> pg_backend_pid()















--
