--                                        DROP DATABASE - Удаление БД

DROP DATABASE имя_базы_данных;                  -- Удаление БД во всех СУБД:
DROP DATABASE IF EXISTS имя_базы_данных;        -- [ PostgreSQL, MySQL ] удаление БД только если она существует (?? во всех СУБД)


-- [PostgreSQL] У той БД которую хотим удалить не должен существовать сеанс подключения иначе возникнет ошибка. Чтобы удалить все подключения к некой БД:
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'имя_бд' AND pid <> pg_backend_pid()
