--                                             Группировка и агрегация


-- GROUP BY (группировка функций/значений) группирует строки выбранных колонок по их значениям(одинаковые значения группирует в одно - одну строку). Соттветсвенно число подгуп равно числу всех значений в данной колонке или колонках без повторов, к значениям других колонок нужно применить агрегатную функцию.

-- Группируем по 1й колонке
SELECT home_type FROM Rooms GROUP BY home_type                     -- все сгруппированные типы значений в home_type
SELECT home_type FROM Rooms GROUP BY home_type ORDER BY home_type  -- сортировка идет после группировки
SELECT home_type, AVG(price) AS ap FROM Rooms GROUP BY home_type   -- группы значений home_type и среднее значение price для каждой из этих групп

-- Группировка по нескольким колонкам
SELECT home_type, street, AVG(price) ap FROM Rooms GROUP BY home_type, street  -- для обобщения в одну группу одинаковыми дожны быть значения во всех группируемых колонках

-- Группируем по результату функции над колонкой
SELECT YEAR(OrderTime) yr, SUM(OrderTotal) st FROM Orders GROUP BY YEAR(OrderTime) -- группируем по годам из OrderTime, соотв сумма OrderTotal будет за каждый год, а не за каждую полную дату



--                                 [Postgres  ??]  ROLLUP и GROUPING SETS

-- ROLLUP(col1, col2, ... coln) - группировка по разному колличеству полей сразу - сначала по всем, потом по всем кроме последнего, потом по всем кроме последних 2х ..итд, потом по первому.
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY ROLLUP(name, month, day)
-- получаем сначала общую цену по товару за каждый день, потом за месяц, потом за все время


-- GROUPING SETS() - группировка по разному коллич полей сразу - по кастомным наборам
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY GROUPING SETS ((name, month), (name, month, day), (name, day), (name))



--                                             Агрегатные функции

-- https://www.postgresql.org/docs/current/functions-aggregate.html

-- Агрегатная функция – это функция, которая выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Запрос с агрегатной функцией без GROUP BY обрабатывает всю таблицу и возвращает одну строку
-- Агрегатные функции(за исключением COUNT(*)) применяются только для значений, не равных NULL.


-- COUNT(имя_столбца) - агрегатная функция возвращает колличество сгруппированных строк в подгруппе
SELECT COUNT(*) FROM Orders                                         -- считает все строки в таблице "Orders"
SELECT home_type, COUNT(*) AS amount FROM Rooms GROUP BY home_type  -- считает колич различных значений в home_type


-- SUM(имя_столбца) - агрегатная функция суммирует значения заданного столбца в подгруппе
SELECT SUM(OrderTotal) FROM Orders WHERE OrderTime > '2013-01-01'   -- выводим сумму тех значений столбца OrderTotal в которых в столбце OrderTime значение больше указанного


-- MIN/MAX(имя_столбца) - возвращают наименьшее или наибольшее значение для подгруппы указанного столбца, работает не только на числа но и на символы и на даты.
SELECT MIN(OrderTime) AS min, MAX(OrderTime) AS max FROM Orders     -- строка с самой маленькой и самой большой датой
SELECT YEAR(Otime) AS year, MAX(Total) AS max FROM Orders GROUP BY YEAR(Otime) -- максимальные значения колонки Total по годам
SELECT room_id, MAX(end_date) AS last_end_date FROM Reservations GROUP BY room_id  -- самые позние даты выезда сгруппированные по номерам комнат


-- AVG/STDEV(имя_столбца) - считает среднее значение/стандартное отклонение столбца
SELECT YEAR(Otime) AS year, AVG(Total) AS AvDelTime FROM Orders GROUP BY YEAR(Otime) -- среднее значение Total за каждый год
SELECT plane, AVG(TIMESTAMPDIFF(SECOND, time_out, time_in)) AS fly_time FROM Trip GROUP BY plane  -- среднее время полета по моделям самолетов


-- PERCENTILE_DISC(v)/PERCENTILE_CONT(v) - [ ?? PostgreSQL] медианное значение столбца
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY score) AS median FROM result  -- больше подходит для целых чисел
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY some) AS median FROM result   -- больше подходит для непрерывных значений ??


-- ARRAY_AGG(column, order) [PostgreSQL ??] создание массива из сгруппированных значений столбца, с возможностью сортировки массива
SELECT name, ARRAY_AGG(rating) AS total_rentals FROM customer GROUP BY name     -- группируем по имени, создавая массив всех рэйтингов к нему относящихся
SELECT ARRAY_AGG(name ORDER BY id DESC) AS names FROM students GROUP BY subject -- группируем имена в массив, в котором они будут отсортированы по столбцу id в порядке убывания
SELECT manager_id, ARRAY_AGG(name || ' - ' || id ORDER BY id) AS employee_names FROM employees WHERE GROUP BY manager_id
SELECT category, (ARRAY_AGG(range))[1] AS st, (ARRAY_AGG(range))[2] AS en FROM ranked GROUP BY category  -- разбиваем массив во время группировки


-- ?? Проверить работает ли так ??
-- EVERY( boolean ) => boolean. [PostgreSQL] - тоесть где все сгруппированные значения соответствуют условию (true)
SELECT customer_id, EVERY(delivery_date IS NULL) FROM orders GROUP BY customer_id;


-- Функция от вычислений
SELECT name, SUM(count * (handedness = 'Right-handed')::INT) AS "Right-handed" FROM customer GROUP BY name
-- Тоесть TRUE::INT это 1, соотв FALSE::INT это 0. В итоге получаем всегда 0 если значения не 'Right-handed'

SELECT product_id, COUNT(DISTINCT(color_id, size_id)) AS total_unique_variants FROM product_variants GROUP BY product_id
-- тоесть считаем только уникальные комбинации по полям color_id и size_id



--                                   Оконные функции с OVER при группировке

-- RANK() OVER() [PostgreSQL] Функция RANK() присваивает ранг каждой подгруппе в разделе результирующего набора(после группировки).
SELECT sale, RANK() OVER(ORDER BY sale DESC) AS srank FROM sales GROUP BY sale             -- создаем колонку рангов цен у наибольшей(DESC) лучший ранг(1й) у одинаковых одинаковый ранг.
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales GROUP BY sale  -- ранг по 2м полям, 2 не используется в основном запросе


-- COUNT(*) OVER  и PARTITION BY   -  Разбиение группировки по значениям столбца
SELECT COUNT(*) OVER (PARTITION BY supplier_id) total_products FROM products


-- ?? Суммирует все строки до по условиям группировки OVER(ORDER BY date, id) включая данную
SELECT *, SUM(CASE WHEN op = 'add' THEN amount ELSE -amount END) OVER(ORDER BY date, id) AS fl_sum FROM actions ORDER BY date, id;



--                            Применение условного оператора в функции группировки

-- Тоесть сначала условный оператор создает значения, а потом функция их считает при группировке ??
SELECT id, COUNT(CASE stock WHEN true THEN 1 ELSE null END) AS variants FROM product_variants GROUP BY id



--                                                  HAVING

-- HAVING (наличие): фильтрует группы по условию, чемто похоже на WHERE, но нужен для того чтоб фильтровать после агрегирования(суммы, подсчет итд) с GROUP BY.
-- Прописывается после GROUP BY но до ORDER BY

SELECT id, COUNT(*) AS Count FROM Orders GROUP BY id HAVING COUNT(*) > 5;  -- отфильтрует только клиентов с более чем 5 заказами
SELECT home, AVG(price) AS avp FROM Rooms GROUP BY home HAVING avp > 50;   -- только те сгруппированные данные где avp больше 50
SELECT home_type, MIN(price) AS min FROM Rooms WHERE price > 30 GROUP BY home_type HAVING COUNT(*) >= 5; -- выводит только для тех типов с ценой больше 30, которых есть >= 5

-- используем HAVING с колонкой которую не выводим
SELECT name, SUM(price) FROM customer GROUP BY name HAVING 'NC-17' != ALL(ARRAY_AGG(f.rating));
SELECT film_id
FROM film LEFT JOIN inventory USING(film_id) LEFT JOIN rental USING(inventory_id)
GROUP BY film_id HAVING SUM(CASE WHEN rental_id IS NULL THEN 1 ELSE 0 END) < 7;

-- EVERY( boolean ) => boolean. [PostgreSQL] тоесть где все сгруппированные значения соответствуют условию (true)
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL);




SELECT a1.client_id,COUNT(DISTINCT a2.client_id) as num_siblings
FROM client_parents a1



-- count в условном операторе
select
    s.id as student_id
  , s.name
  , case
      when count(c.id) = 0 then 'quit studying'
      else concat('failed in ', string_agg(c.course_name || '(' || c.score || ')', ', ' order by c.course_name))
    end as reason
from students s
left outer join courses c on c.student_id = s.id
where c.student_id is null or c.score < 60
group by s.id, s.name
having count(c.id) = 0 or count(c.id) > 2
order by s.id;


-- ?? Дистинкт до группировки или после хз ??
SELECT date, count(DISTINCT customer_id) num_new_customers
FROM customer_purchases GROUP BY date ORDER BY date


--                                          ?? FILTER

-- ??
SELECT
  order_id,
  order_id - MAX(order_id) FILTER(WHERE status_code = 4) OVER(ORDER BY order_id) AS sbn
FROM order_status
-- Тоесть берем части таблицы между строками со значениями 4 в столбце status_code и заполняем их значениями  order_id - MAX(order_id)


-- Оконная фунуция sum() over() Выводит суммы в каждой строке: сумму во всех строках(в каждой строке), сумму для каждого customer_id(в каждой строке с эти customer_id) итд
select sales_id, customer_id, cnt,
sum(cnt) over () as total,
sum(cnt) over (order by customer_id) as running_total,
sum(cnt) over (order by customer_id, sales_id) as running_total_unique
from sales
order by customer_id, sales_id;












--
