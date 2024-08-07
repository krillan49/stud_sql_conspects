-- Todo:
-- Потом проверить по тестовой БД нортвинд все примеры, чтоб разделить MySQL и PostgreSQL


-- https://github.com/EngineerSpock/postgres-course-ru/tree/master
-- В папке первого урока есть скрпт(весь SQL код) для наполнения учебной БД таблицами и данными. Саму БД надо создать просто без доп опций, задать только название(задумано как northwind)


-- Нормализация — это процесс удаления избыточности данных из базы данных. Сокращение дублированных данных означает меньшую вероятность несоответствий и большую гибкость.
-- Нормальные формы — это этапы, между которыми из таблицы удаляются различные формы избыточности данных. Для того чтобы высшая нормальная форма была удовлетворена, все низшие нормальные формы также должны быть удовлетворены.
-- Первая нормальная форма (1NF)
-- Для достижения первой нормальной формы (1NF) каждый столбец в таблице должен быть атомарным, т. е. он не может содержать набор значений.


-- (потом мб во всех разделах поделить на общие постгрэ итд)


-- если тип цены float то ее рекомендуется хранить в базе в минимальных величинах(в центах, копейках итд), но лучше decimal

-- Создание временной таблицы на основе запроса (Постгрэ)
SELECT *
INTO other_table_name
FROM tablr_name;


SELECT * FROM information_schema.tables;   -- инфа о всех таблицах в БД



-- https://www.postgresql.org/docs/current/functions-net.html   -- функции для айпи адресов


-- https://learndb.ru/articles  - курс


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



-- Отношение один ко многим. В одной из таблиц (многие) есть/добавляется колонка содержащая внешние ключи для каждой записи ссылающиеся на первичный ключ к таблице (один)

-- Отношение один к одному отличается от один ко многим, только тем что для каждой записи в одной таблице есть только одна запись в другой

-- Отношение многие ко многим - всегда моделируется при помщи введения 3й таблицы содержащей не уникальные(тк могут повторяться) ключи для обеих таблиц, но каждая пара(строка) этих ключей уникальна, тоесть первичный ключ состоит из обоих этих ключей. Обычно доп таблица называется именами обоих таблиц через подчеркивание.










--
