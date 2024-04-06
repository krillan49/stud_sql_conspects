-- Нормализация — это процесс удаления избыточности данных из базы данных. Сокращение дублированных данных означает меньшую вероятность несоответствий и большую гибкость.
-- Нормальные формы — это этапы, между которыми из таблицы удаляются различные формы избыточности данных. Для того чтобы высшая нормальная форма была удовлетворена, все низшие нормальные формы также должны быть удовлетворены.
-- Первая нормальная форма (1NF)
-- Для достижения первой нормальной формы (1NF) каждый столбец в таблице должен быть атомарным, т. е. он не может содержать набор значений.


-- если тип цены float то ее рекомендуется хранить в базе в минимальных величинах(в центах, копейках итд), но лучше decimal


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











--
