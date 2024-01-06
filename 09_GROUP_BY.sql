--                                             Группировка и агрегация


-- GROUP BY (группировка функций/значений): возврат значений или функций для нескольких подмножеств данных. Мы какбы группируем выбранные колонки(или результаты функций по этим колонкам) по подтипам, группируя все одинаковые значения в подтип(в одну строку), соттв число подгуп равно числу всех значений в данной колонке или колонках без повторов, к значениям других колонок нужно применить агрегатную функцию.

-- Группируем по колонке
SELECT home_type FROM Rooms GROUP BY home_type                          -- выдаст все типы значений в home_type сгруппированные (объединенные/нет одинаковых) по значениям home_type
SELECT home_type, AVG(price) AS avg_price FROM Rooms GROUP BY home_type -- выводим группы значений home_type и среднее значение price для каждой из этих групп

-- Группировка по нескольким колонкам
SELECT home_type, street, AVG(price) ap FROM Rooms GROUP BY home_type, street ORDER BY home_type  -- для обобщения в одну группу одинаковыми дожны быть значения во всех группируемых колонках, сортировка идет после группировки

-- Группируем по результату функции над колонкой
SELECT YEAR(OrderTime) yr, SUM(OrderTotal) st FROM Orders GROUP BY YEAR(OrderTime) -- группируем по годам из OrderTime, соотв сумма OrderTotal будет за каждый год, а не за каждую полную дату


-- ROLLUP(col1, col2, coln) [Postgres  ??]  - группировка по разному коллич полей сразу(сначала по всем, потом по всем кроме последнего, потом по всем кроме последних 2х ..итд, потом по первому)

SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY ROLLUP(name, month, day)
-- получаем сначала общую цену по товару за определенный день, потом за месяц, потом за все время


-- GROUPING SETS() [Postgres  ??]  - группировка по разному коллич полей сразу по кастомным наборам
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY GROUPING SETS ((name, month), (name, month, day), (name, day), (name))



--                                             Агрегатные функции

-- https://www.postgresql.org/docs/current/functions-aggregate.html

-- Агрегатная функция – это функция, которая выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Запрос с агрегатной функцией без GROUP BY обрабатывает всю таблицу и возвращает одну строку
-- Агрегатные функции(за исключением COUNT(*)) применяются только для значений, не равных NULL.


-- COUNT(имя_столбца) - агрегатная функция возвращает колличество сгруппированных строк в подгруппе
SELECT COUNT(*) FROM Orders                                         -- считает все строки в таблице "Orders"
SELECT home_type, COUNT(*) AS amount FROM Rooms GROUP BY home_type  -- считает колич жилья каждого типа


-- SUM(имя_столбца) - агрегатная функция суммирует значения заданного столбца в подгруппе
SELECT SUM(OrderTotal) FROM Orders WHERE OrderTime > '2013-01-01'   -- выводим сумму тех значений столбца OrderTotal в которых в столбце OrderTime значение больше указанного


-- MIN/MAX(имя_столбца) - возвращают наименьшее или наибольшее значение для подгруппы указанного столбца, работает не только на числа но и на символы и мб на даты ??.
SELECT MIN(OrderTime) AS min, MAX(OrderTime) AS max FROM Orders                             -- выводит в 2х однострочных колонках самую маленькую и самую большую даты
SELECT YEAR(OrderTime) AS year, MAX(OrderTotal) AS max FROM Orders GROUP BY YEAR(OrderTime) -- максимальные значения колонки OrderTotal по годам
SELECT room_id, MAX(end_date) AS last_end_date FROM Reservations GROUP BY room_id           -- самые позние даты выезда сгруппированные по номерам комнат


-- AVG/STDEV(имя_столбца) - считает среднее значение/стандартное отклонение столбца
SELECT YEAR(OrderTime) AS year, AVG(OrderTotal) AS AvDelTime FROM Orders GROUP BY YEAR(OrderTime) -- среднее значение OrderTotal за каждый год
SELECT plane, AVG(TIMESTAMPDIFF(SECOND, time_out, time_in)) AS fly_time FROM Trip GROUP BY plane  -- среднее время полета по моделям самолетов


-- PERCENTILE_DISC(v)/PERCENTILE_CONT(v) - [ ?? PostgreSQL] медианное значение столбца
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY score) AS median FROM result  -- больше подходит для целых чисел
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY some) AS median FROM result   -- больше подходит для непрерывных значений ??


-- Оконные функции RANK() OVER другая тема отдельня от агрегатных функций и применяются втч без группировки

-- RANK() [PostgreSQL] Функция RANK()присваивает ранг каждой строке/подгруппе в разделе результирующего набора.
SELECT sale, RANK() OVER(ORDER BY sale DESC) AS srank FROM sales GROUP BY sale             -- создаем колонку рангов цен у наибольшей(DESC) лучший ранг(1й) у одинаковых одинаковый ранг.
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales GROUP BY sale  -- ранг по 2м полям, если 1е равно использует 2е


-- PARTITION BY [postgresql  + ??]   Разбиение группировки по значениям столбца
SELECT COUNT(*) OVER (PARTITION BY supplier_id) total_products FROM products

-- PARTITION BY + ORDER BY
SELECT depname, empno, salary, RANK() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;


-- ARRAY_AGG(column, order) [PostgreSQL ??] создание массива из сгруппированных значений столбца, с возможностью сортировки массива
SELECT name, ARRAY_AGG(rating) AS total_rentals FROM customer GROUP BY name     -- группируем по имени, создавая массив всех рэйтингов к нему относящихся
SELECT ARRAY_AGG(name ORDER BY id DESC) AS names FROM students GROUP BY subject -- группируем имена в массив, в котором они будут отсортированы по столбцу id в порядке убывания



--                                                  HAVING

-- HAVING (наличие): фильтрует группы по условию, чемто похоже на WHERE, но нужен для того чтоб фильтровать после агрегирования(суммы, подсчет итд) для GROUP BY. (раполагается после GROUP BY но до ORDER BY)

SELECT id, COUNT(*) AS Count FROM Orders GROUP BY id HAVING COUNT(*) > 5;  -- отфильтрует только клиентов с более чем 5 заказами
SELECT home_type, AVG(price) AS avg_price FROM Rooms GROUP BY home_type HAVING avg_price > 50;  -- отфильтрует только те сгруппированные данные по типам домов где средняя цена больше 50
SELECT home_type, MIN(price) AS min FROM Rooms WHERE price > 30 GROUP BY home_type HAVING COUNT(*) >= 5; -- выводит только для тех типов с ценой больше 30, которых есть >= 5
SELECT name AS total_rentals FROM customer GROUP BY name HAVING 'NC-17' != ALL(ARRAY_AGG(f.rating));  -- используем HAVING с колонкой которую не выводим


-- ?? Проверить только для HAVING или и группировать можно по ней
-- EVERY   -  EVERY ( boolean ) => boolean. [PostgreSQL] тоесть где все сгруппированные значения соответствуют условию (true)
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL) ORDER BY 1 DESC;


-- Применение условного оператора функции группировки
SELECT
  product_id,
  COUNT(product_id) AS total_unique_variants,
  COUNT(CASE in_stock WHEN true THEN 1 ELSE null END) AS in_stock_variants
FROM product_variants
  GROUP BY product_id

-- применение еще всякого в условиях группировки
select
  product_id, count(distinct(color_id, size_id)) as total_unique_variants,
  count(distinct(color_id, size_id)) filter (where in_stock) as in_stock_variants from product_variants p
group by 1

SELECT
  product_id,
  COUNT(DISTINCT(color_id, size_id)) AS total_unique_variants,
  SUM (in_stock::integer) AS in_stock_variants
FROM product_variants
GROUP BY product_id

-- Суммирует все строки до по условиям группировки OVER(ORDER BY date, id) включая данную
SELECT *, SUM(CASE WHEN operation = 'add' THEN amount WHEN operation = 'remove' THEN -amount ELSE 0 END) OVER(ORDER BY date, id) AS flexible_sum
FROM transactions
ORDER BY date, id;















--
