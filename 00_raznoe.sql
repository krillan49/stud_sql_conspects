-- Todo:
-- Потом проверить по тестовой БД нортвинд все примеры, чтоб разделить MySQL и PostgreSQL
-- (потом мб во всех разделах поделить на общие постгрэ итд)


-- https://www.postgresql.org/docs/current/functions-net.html   -- функции для айпи адресов


-- если тип цены float то ее рекомендуется хранить в базе в минимальных величинах(в центах, копейках итд), но лучше decimal


-- Отношение один ко многим. В одной из таблиц (многие) есть/добавляется колонка содержащая внешние ключи для каждой записи ссылающиеся на первичный ключ к таблице (один)
-- Отношение один к одному отличается от один ко многим, только тем что для каждой записи в одной таблице есть только одна запись в другой
-- Отношение многие ко многим - всегда моделируется при помщи введения 3й таблицы содержащей не уникальные(тк могут повторяться) ключи для обеих таблиц, но каждая пара(строка) этих ключей уникальна, тоесть первичный ключ состоит из обоих этих ключей. Обычно доп таблица называется именами обоих таблиц через подчеркивание.


-- Создание временной таблицы на основе запроса (Постгрэ)
SELECT *
INTO other_table_name
FROM table_name;


SELECT * FROM information_schema.tables;   -- инфа о всех таблицах в БД
SELECT table_name AS total FROM information_schema.tables;  -- инфа об именах таблиц


-- Создание индексов для ускорения запроса с большим числом строк
CREATE INDEX ON customers (lower(first_name || ' ' || last_name), lower(first_name || ',' || last_name));
CREATE INDEX ON prospects (lower(full_name));
SELECT a.first_name,
       a.last_name,
       a.credit_limit AS old_limit,
       max(b.credit_limit) AS new_limit
FROM customers a JOIN prospects b
  ON lower(full_name) IN (
    lower(a.first_name || ' ' || a.last_name),
    lower(a.last_name || ', ' || a.first_name)
  )
GROUP BY a.id
  HAVING max(b.credit_limit) > a.credit_limit
ORDER BY first_name, last_name


-- 14. Query to Display User Tables
-- A user-defined table is a representation of defined information in a table, and they can be used as arguments for procedures or user-defined functions. Because they’re so useful, it’s useful to keep track of them using the following query.
SELECT * FROM Sys.objects WHERE Type='u'
-- 15. Query to Display Primary Keys
-- A primary key uniquely identifies all values within a table. The following SQL query lists all the fields in a table’s primary key.
SELECT * from Sys.Objects WHERE Type='PK'
-- 16. Query for Displaying Unique Keys
-- A Unique Key allows a column to ensure that all of its values are different.
SELECT * FROM Sys.Objects WHERE Type='uq'
-- 17. Displaying Foreign Keys
-- Foreign keys link one table to another – they are attributes in one table which refer to the primary key of another table.
SELECT * FROM Sys.Objects WHERE Type='f'
-- 18. Displaying Triggers
-- A Trigger is sort of an ‘event listener’ – i.e, it’s a pre-specified set of instructions that execute when a certain event occurs. The list of defined triggers can be viewed using the following query.
SELECT * FROM Sys.Objects WHERE Type='tr'
-- 19. Displaying Internal Tables
-- Internal tables are formed as a by-product of a user-action and are usually not accessible. The data in internal tables cannot be manipulated; however, the metadata of the internal tables can be viewed using the following query.
SELECT * FROM Sys.Objects WHERE Type='it'
-- 20. Displaying a List of Procedures
-- A stored procedure is a group of advanced SQL queries that logically form a single unit and perform a particular task. Thus, using the following query you can keep track of them:
SELECT * FROM Sys.Objects WHERE Type='p'



-- Попарное сравнение (тут ищем все возможные пары актеров, что снимались вместе в одном и том же фильме) для соединительной талицы типа многие ко многим:
-----------------------
-- actor_id	 |  film_id
-----------------------
-- 1	       |  1
-- 1	       |  23
-- 1	       |  25
-- ...       |  ...
-- 2	       |  3
-- 2	       |  31
-- 2	       |  47
-- ...       |  ...
-- 3	       |  17
-- 3	       |  40
-- 3	       |  42
-- ...       |  ...
----------------------
-- Соединим эту таблицу саму с собой и в дополнительном условии укажем не просто неравенств айдишников актеров, а один меньше другого, чтобы исключить все повторы и соотв улучшить производительность запроса
SELECT f1.actor_id AS a1_id, f2.actor_id AS a2_id, f1.film_id
FROM film_actor f1 JOIN film_actor f2 ON f1.film_id = f2.film_id AND f1.actor_id < f2.actor_id









--
