--                                             Pivot / поворот данных

-- https://www.cyberforum.ru/postgresql/thread1951350.html

-- В PostgreSQL нет встроенной функции для "поворота" (pivot) данных, как в некоторых других СУБД, но это можно реализовать с помощью других подходов:
-- комбинация операторов `CASE`, `GROUP BY` и агрегации.
-- использования `crosstab` из расширения `tablefunc`
-- с помощью динамического SQL



--                                           CASE, GROUP BY и агрегация

-- Можно достичь эффекта поворота таблицы, используя комбинацию операторов `CASE`, `GROUP BY` и агрегации. Это решение хорошо работает, если количество уникальных дат заранее известно и не слишком велико.

-- Есть таблица `sales`, которая содержит данные о продажах:
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  product TEXT,
  sale_date DATE,
  amount NUMERIC
);

INSERT INTO sales (product, sale_date, amount) VALUES
('Product A', '2023-01-01', 100),
('Product A', '2023-01-02', 150),
('Product B', '2023-01-01', 200),
('Product B', '2023-01-02', 250),
('Product C', '2023-01-01', 300);

-- Нужно представить данные о продажах в формате, где каждая дата становится отдельным столбцом, а значения представляют собой сумму продаж за эту дату:

--             | 2023-01-01 | 2023-01-02 |
-- ------------|------------|------------|
-- Product A   |        100 |        150 |
-- Product B   |        200 |        250 |
-- Product C   |        300 |          0 |


-- 1. Определение динамических столбцов - перед тем как написать запрос для поворота данных, нужно определить, какие уникальные значения у нас есть в `sale_date`. Чтобы сделать это, можно использовать следующий запрос:
SELECT DISTINCT sale_date FROM sales;

-- 2. Запрос с использованием `CASE` - теперь мы можем написать запрос, который использует конструкцию `CASE` для формирования новых столбцов на основе значений `sale_date`:
SELECT
  product,
  SUM(CASE WHEN sale_date = '2023-01-01' THEN amount ELSE 0 END) AS "2023-01-01",
  SUM(CASE WHEN sale_date = '2023-01-02' THEN amount ELSE 0 END) AS "2023-01-02"
FROM sales GROUP BY product ORDER BY product;

-- 3. Несколько столбцов - если нужно добавить больше столбцов для `sale_date`, просто добавляйте больше условий в операторе `SUM(CASE ...)`



--                                              Динамический SQL

-- Динамический SQL позволяет вам генерировать запросы на лету, что может быть полезно при работе с произвольным числом новых столбцов. Например, если количество уникальных значений для поворота в новые столбцы может меняться, рекомендуется использовать PL/pgSQL, чтобы сначала построить динамический SQL-запрос.

-- Есть таблица `sales`, которая имеет следующую структуру:
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  product VARCHAR(50),
  region VARCHAR(50),
  amount NUMERIC
);
-- Нужно преобразовать данные так, чтобы каждое уникальнок значение `region` стало отдельным столбцом с общими суммами продаж.

-- 1. Сначала получите уникальные значения для `region`:
SELECT DISTINCT region FROM sales;

-- 2. Затем вы можете использовать динамический SQL для создания запроса. Пример реализации функции:
DO $$
DECLARE
  str_querry TEXT;
  col_list TEXT;
BEGIN
  -- Получение списка уникальных значений regions:
  SELECT string_agg(DISTINCT format('SUM(CASE WHEN region = %L THEN amount END) AS %I', region, region), ', ')
  -- `string_agg` - функция для объединения уникальных значений `region` в форматированный текст.
  -- `format` - помогает создать корректный SQL-запрос с учетом имен столбцов и значений.
  INTO col_list
  FROM sales;

  -- Формирование полного SQL-запроса:
  str_querry := format('SELECT product, %s FROM sales GROUP BY product ORDER BY product;', col_list);

  -- Выполнение запроса
  EXECUTE str_querry; -- выполняется созданный запрос с помощью `EXECUTE`.
END $$;


-- 2б. Пример для таблицы из пункта CASE, GROUP BY и агрегация
DO $$
DECLARE
  col_names TEXT;
  sql TEXT;
BEGIN
  SELECT STRING_AGG(DISTINCT 'SUM(CASE WHEN sale_date = ''' || sale_date || ''' THEN amount ELSE 0 END) AS "' || sale_date || '"', ', ')
  INTO col_names
  FROM sales;

  sql := 'SELECT product, ' || col_names || ' FROM sales GROUP BY product ORDER BY product;';

  EXECUTE sql;
END $$;



--                                                 crosstab

-- Использование `crosstab` из расширения `tablefunc`

-- 1. Убедитесь, что extension `tablefunc` установлено:
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- 2. Создайте функцию для получения данных в нужном формате:
--  Предположим, у нас есть таблица `sales` со следующими столбцами: `product`, `month` и `amount`. Мы хотим создать сводную таблицу, где строки — это продукты, а столбцы — это месяца.
CREATE TABLE sales (
  product TEXT,
  month TEXT,
  amount NUMERIC
);

-- 3. Используйте `crosstab` для поворота таблицы:
-- Создайте запрос, используя `crosstab`. Вам нужно будет подготовить запрос, который вернет данные в нужном формате.
SELECT *
FROM crosstab(
   'SELECT product, month, amount FROM sales ORDER BY 1, 2',
   'SELECT DISTINCT month FROM sales ORDER BY 1'
) AS ct(product TEXT, jan NUMERIC, feb NUMERIC, mar NUMERIC);  -- Замените на ваши значения
-- Обратите внимание, что колонки, возвращаемые `crosstab`, должны быть заранее определены.



--                                             crosstab + Динамический SQL

-- Использование `crosstab` из расширения `tablefunc` или с помощью динамического SQL. Рассмотрим оба варианта.

-- 1. Соберите уникальные значения для столбцов:
SELECT DISTINCT month FROM sales ORDER BY month;

-- 2. Создайте динамический SQL - Используйте PL/pgSQL для создания строки запроса:
DO $$
DECLARE
   sql TEXT;
   col_list TEXT;
BEGIN
   SELECT STRING_AGG(DISTINCT quote_ident(month), ', ')
   INTO col_list
   FROM sales;

   sql := 'SELECT product, ' || col_list || '
           FROM crosstab(
               ''SELECT product, month, amount FROM sales ORDER BY 1, 2'',
               ''SELECT DISTINCT month FROM sales ORDER BY 1''
           ) AS ct(product TEXT, ' || col_list || ' NUMERIC);';
   EXECUTE sql;
END $$;



--                                    Задача с кодварс, которую нужно дорешать

-- 2 kyu Advanced Pivoting Data (remastered)

-- SELECT id, name FROM categories;
-- SELECT id, name FROM departments;
-- SELECT id, category_id FROM products;
-- SELECT product_id, department_id, amount FROM sales;
-- SELECT c.id AS c_id, c.name AS c_name, d.id AS d_id, d.name AS d_name FROM categories AS c CROSS JOIN departments AS d;
-- SELECT p.category_id AS c_id, department_id AS d_id, SUM(amount) FROM products AS p JOIN sales AS s ON p.id = s.product_id
-- GROUP BY p.category_id, department_id;

WITH
-- Джойним чтоб у каждой категории был каждый депрартамент
cd AS (SELECT c.id AS c_id, c.name AS c_name, d.id AS d_id, d.name AS d_name
       FROM categories AS c CROSS JOIN departments AS d),
-- Джойним с группировкой 2 таблицы, для быстродействия, чтоб джойнить меньше строк далее
ps AS (SELECT p.category_id AS c_id, department_id AS d_id, SUM(amount)
       FROM products AS p JOIN sales AS s ON p.id = s.product_id
       GROUP BY p.category_id, department_id),
-- правильно сджойненые(по условиям задачи) все 4 таблицы
cdps AS (SELECT cd.*, COALESCE(sum, 0::MONEY) AS sum FROM cd LEFT JOIN ps USING(c_id, d_id)),
-- Категории в уоторых ничего не куплено
empty_c AS (SELECT c_id FROM cdps GROUP BY c_id HAVING SUM(sum) = 0::MONEY),
-- Департаменты в которых ничего не куплено
empty_d AS (SELECT d_id FROM cdps GROUP BY d_id HAVING SUM(sum) = 0::MONEY),
-- Только все необходимые данные
res AS (SELECT * FROM cdps WHERE c_id NOT IN (SELECT * FROM empty_c) AND d_id NOT IN (SELECT * FROM empty_d)),
-- все дерартаменты в нужном порядке
d_names AS (SELECT DISTINCT d_id, d_name FROM res ORDER BY d_name, d_id)
-- А теперь как-то надо повернуть строки в столцы:

-- d.name || ' (' || d.id || ')' AS department














--
