--                                             Группировка и агрегация

-- GROUP BY - группирует строки выбранных колонок по их значениям или выражениям(одинаковые значения группирует в одно - одну строку). Число групп равно числу всех уникальных значений в колонке или колонках по которым проводим группировку, к значениям группируемых колонок нужно применить агрегатную функцию, чтобы объединить их тем или иным способом
-- На каждую группу в итоге будет выведена одна строка


-- 1. Если группировать колонку и выводить только ее это будет ранозначно SELECT DISTINCT
SELECT home_type FROM Rooms GROUP BY home_type; -- все сгруппированные типы значений в home_type

-- GROUP BY pасполагается между WHERE и ORDER BY. WHERE фильтрует строки до группировки
SELECT home_type FROM Rooms WHERE sum > 10 GROUP BY home_type ORDER BY home_type;

-- При группировке можем ссылаться на псевдонимы
SELECT home_type h FROM Rooms GROUP BY h;


-- 2. Группируем по 1й колонке и применяем агрегатную функцию к остальным выводимым колонкам, иначе выдаст ошибку
SELECT home_type, AVG(price) AS ap FROM rooms GROUP BY home_type;  -- группы значений home_type и среднее значение price для каждой из этих групп


-- 3. Группировка по нескольким колонкам. для обобщения в одну группу одинаковыми дожны быть значения во всех группируемых колонках. Тоесть отдельная группа будет браться по каждой существующей паре значений
SELECT home_type, street, AVG(price) ap FROM Rooms GROUP BY home_type, street;


-- 4. Группируем по результату функции(по выражению) над колонкой
SELECT YEAR(OrderTime) yr, SUM(OrderTotal) st FROM Orders GROUP BY YEAR(OrderTime); -- группируем по годам из OrderTime, соотв сумма OrderTotal будет за каждый год, а не за каждую полную дату
SELECT SUBSTRING(name, 1, 1) AS a, SUM(OrderTotal) st FROM Orders GROUP BY SUBSTRING(name, 1, 1); -- по первой букве имени
SELECT f_name || l_name AS name, SUM(OrderTotal) st FROM Orders GROUP BY f_name || l_name;



--                                 [Postgres ??]  ROLLUP и GROUPING SETS

-- ROLLUP(col1, col2, ... coln) - группировка по разному колличеству полей сразу - сначала по всем, потом по всем кроме последнего, потом по всем кроме последних 2х ..итд, потом по первому.
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY ROLLUP(name, month, day);
-- получаем сначала общую цену по товару за каждый день, потом за месяц, потом за все время


-- GROUPING SETS() - группировка по разному колличеству полей сразу - по кастомным наборам
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY GROUPING SETS ((name, month), (name, month, day), (name, day), (name));



--                                             Агрегатные функции

-- https://www.postgresql.org/docs/current/functions-aggregate.html

-- Агрегатная функция – это функция, которая выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Агрегатные функции(за исключением COUNT) применяются только для значений, не равных NULL.

-- Запрос с агрегатной функцией без GROUP BY обрабатывает всю таблицу как одну группу и возвращает одну строку
SELECT COUNT(*) FROM orders;                   -- посчитать колличество строк в таблице
SELECT COUNT(*) FROM orders WHERE price > 20;  -- с фильтрацией, считает число строк где цена больше 20

-- Можно использовать просто литералы в агрегатных функциях
SELECT failure_reason, SUM(1) AS cnt FROM failures GROUP BY failure_reason; -- добавим колонку с числом ошибок

-- Можно применять агрегатную функцию к выражениям
SELECT name, SUM(count * (handedness = 'Right-handed')::INT) AS "Right-handed" FROM customer GROUP BY name; -- TRUE::INT = 1, FALSE::INT = 0. В итоге получаем всегда 0 если значения не 'Right-handed'



--                                           Виды агрегатных функций

-- COUNT(имя_столбца) - агрегатная функция возвращает колличество сгруппированных строк в подгруппе, если взять по конкретному полю, то посчитает только те строки в которых значение в этом поле не NULL
SELECT home_type, COUNT(*) AS amount FROM Rooms GROUP BY home_type;  -- считает колич различных значений в home_type


-- SUM(имя_столбца) - агрегатная функция суммирует значения заданного столбца в подгруппе
SELECT SUM(OrderTotal) FROM Orders WHERE OrderTime > '2013-01-01';  -- сумма тех значений столбца OrderTotal в которых в столбце OrderTime значение больше указанного


-- MIN/MAX(имя_столбца) - возвращают наименьшее или наибольшее значение для подгруппы указанного столбца, работает не только на числа, но и на символы и даты.
SELECT MIN(OrderTime) AS min, MAX(OrderTime) AS max FROM Orders;               -- строка с самой маленькой и самой большой датой
SELECT YEAR(Otime) AS y, MAX(Total) AS m FROM Orders GROUP BY YEAR(Otime);     -- максимальные значения колонки Total по годам
SELECT room_id, MAX(end_date) AS last_date FROM Reservations GROUP BY room_id; -- самые позние даты выезда сгруппированные по номерам комнат


-- AVG/STDEV(имя_столбца) - считает среднее значение/стандартное отклонение столбца
SELECT YEAR(Otime) AS year, AVG(Total) AS ADTime FROM Orders GROUP BY YEAR(Otime); -- среднее значение Total за каждый год
SELECT plane, AVG(fly_time) AS m_time FROM Trip GROUP BY plane;                    -- среднее время полета по моделям самолетов


-- PERCENTILE_DISC(v)/PERCENTILE_CONT(v) - [ ?? PostgreSQL] медианное значение столбца
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY score) AS median FROM result;  -- больше подходит для целых чисел
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY some) AS median FROM result;   -- больше подходит для непрерывных значений ??


-- ARRAY_AGG(column, order) [PostgreSQL ??] создание массива из сгруппированных значений столбца, с возможностью сортировки элементов этого массива
SELECT name, ARRAY_AGG(rating) AS rentals FROM customer GROUP BY name;               -- массив всех рэйтингов к каждому имени
SELECT ARRAY_AGG(name ORDER BY id DESC) AS names FROM students GROUP BY subject;     -- группируем имена в массив, в котором они будут отсортированы по столбцу id в порядке убывания
SELECT m_id, ARRAY_AGG(name || '-' || id ORDER BY id) AS en FROM emps GROUP BY m_id; -- группируем результаты операции


-- STRING_AGG(column, разделитель порядок) [PostgreSQL ??] тоесть все значения группы записываются в одну строку, через указанный разделитель
SELECT somr, STRING_AGG(str, ', ' ORDER BY course_name) FROM tab GROUP BY some;
SELECT somr, STRING_AGG(course_name || '-' || score, ', ' ORDER BY course_name) FROM tab GROUP BY some;


-- BOOL_AND(price > 200) [PostgreSQL ??] - принимает логическое выражение и возвращает TRUE если для каждой строки в группе условие истинно иначе FALSE
SELECT name, BOOL_AND(price > 200) AS rich FROM customer GROUP BY name;

-- BOOL_OR(price > 200) [PostgreSQL ??] - принимает логическое выражение и возвращает TRUE если для хотябы одной строки в группе условие истинно иначе FALSE
SELECT name, BOOL_OR(price > 200) AS has_rich FROM customer GROUP BY name;


-- EVERY( boolean ) => boolean. [PostgreSQL] - если все значения в группе соответствуют условию возвращает TRUE иначе FALSE
SELECT customer_id, EVERY(delivery_date IS NULL) FROM orders GROUP BY customer_id;



--                                      Агрегатная функция с DISTINCT

-- DISTINCT можно добавлять в условие группировки, тогда агрегатная функция будет применена только к уникальным значениям
SELECT COUNT(DISTINCT country) FROM orders;                            -- считаем число уникальных значений в столбце country
SELECT date, COUNT(DISTINCT customer_id) FROM customers GROUP BY date; -- считаем число уникальных значений в каждой группе

-- Так же можно применять DISTINCT к нескольким столбцам, чтобы считать уникальные комбинации
SELECT product_id, COUNT(DISTINCT(color_id, size_id)) AS uniq FROM products GROUP BY product_id; -- считаем только уникальные комбинации по полям color_id и size_id



--                                      Условный оператор и группировка

-- Сначала условный оператор создает значения, а потом агрегатная функция их считает при группировке
SELECT id, COUNT(CASE stock WHEN true THEN 1 ELSE NULL END) AS variants FROM product_variants GROUP BY id;

-- Группировка в условном операторе, сперва производится группировка, а потом в результат группы пишется значение условного оператора
SELECT name, CASE WHEN COUNT(sub) = 0 THEN 'quit studying' ELSE 'failed' END AS reason FROM s GROUP BY name;



--                                  FILTER. Фильтрация в агрегатных функциях

-- FILTER - задает ограничение(условие) для значений, которые будут обрабатываться агрегатной функцией. Тоесть агрегатная функция обработает не все значения в группе, а только соответсвующие условию.
-- А иначе с обычным условием WHERE после FROM пришлось бы делать 2 отдельных запроса
SELECT
  rating,
  COUNT(*),                            -- посчтитает общее число фиьмов
  COUNT(*) FILTER(WHERE length > 100), -- посчитаем колличество фильмов определенной продолжительности
  COUNT(*) FILTER(WHERE length > 120)
FROM films GROUP BY rating;



--                                                  HAVING

-- HAVING - фильтрует результат группировки по условию. Похоже на WHERE, но фильтрует после группировки и агрегирования. Тоесть накладывает условия на результаты агрегатных функций
-- Прописывается после GROUP BY но до ORDER BY
-- Работает после GROUP BY

SELECT o_id, COUNT(*) FROM Orders GROUP BY o_id HAVING COUNT(*) > 5;       -- отфильтрует только клиентов с более чем 5 заказами
SELECT home, AVG(price) AS avp FROM Rooms GROUP BY home HAVING avp > 50;   -- только те сгруппированные данные где avp больше 50
SELECT type, MIN(price) AS min FROM Rooms WHERE price > 30 GROUP BY type HAVING COUNT(*) >= 5 OR COUNT(*) < 3; -- выводит только типы с ценой больше 30, которых есть >= 5 или < 2

-- Можно применять HAVING с агрегацией по колонке которую не выводим в блоке SELECT
SELECT name, SUM(price) FROM customer GROUP BY name HAVING 'NC-17' != ALL(ARRAY_AGG(rating));
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL);

-- HAVING с агрегацией и условным оператором
SELECT f_id FROM film LEFT JOIN inventory USING(f_id) LEFT JOIN rental USING(i_id)
GROUP BY f_id HAVING SUM(CASE WHEN r_id IS NULL THEN 1 ELSE 0 END) < 7;















--
