--                                             Группировка и агрегация


-- GROUP BY (группировка функций/значений): возврат значений или функций для нескольких подмножеств данных(например вывод средней суммы по годам из столбца дат)
-- 		(Мы какбы группируем колонки по подтипам, группируя все одинаковые значения в подтип(в одну строку), соттв число подкгуп равно числу всех значений без повторов)
SELECT home_type FROM Rooms GROUP BY home_type                                     --#=> выдаст все типы значений в home_type сгруппированные(объединенные/нет одинаковых) по значениям home_type
SELECT home_type, AVG(price) as avg_price FROM Rooms GROUP BY home_type            --#=> выводим группы значений home_type и фунуцию среднего(AVG) всех значений для каждой из этих групп
SELECT YEAR(OrderTime) yr, SUM(OrderTotal) st FROM Orders GROUP BY YEAR(OrderTime) --#=> При помощи GROUP BY группируем по годам из OrderTime(1й солбец), соотв сумма будет тоже за каждый из годов(2й столбец).
SELECT * FROM Ord GROUP BY YEAR(OrdTime), MONTH(OrdTime) ORDER BY YEAR(OrderTime)  --#=> Группировка по нескольким колонкам, для обобщения в одну группу одинаковыми дожны быть значения во всех этих колонках

	-- ROLLUP(col1, col2, coln) [Postgres  ??]  - группировка по разному коллич полей сразу(сначала по всем, потом по всем кроме последнего, потом по всем кроме последних 2х ..итд, по первому)
SELECT name, EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products GROUP BY ROLLUP(product_name, year, month, day)

	-- GROUPING SETS() [Postgres  ??]  - группировка по разному коллич полей сразу по кастомным наборам
SELECT name, EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY GROUPING SETS ((product_name, year), (product_name, year, month), (product_name, year, month, day), (product_name))


-- Агрегатная функция – это функция, которая выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Агрегатные функции применяются для значений, не равных NULL. Исключением является функция COUNT(*)

	-- COUNT(имя_столбца) - агрегатная функция позволяет считать элементы
SELECT COUNT(*) FROM Orders                                                              --#=> считает все строки в таблице "Orders"
SELECT home_type, COUNT(*) AS amount FROM Rooms GROUP BY home_type ORDER BY amount DESC  --#=> выводим колич жилья каждого типа в порядке по убыванию от этого количества

	-- SUM(имя_столбца) - агрегатная функция суммирует значения заданного столбца
SELECT SUM(OrderTotal) FROM Orders WHERE OrderTime > '2013-01-01'                        --#=> выводим сумму тех значений столбца OrderTotal в которых в столбце OrderTime значение больше указанного

	-- MIN/MAX(имя_столбца) (минимум/максимум): возвращают наименьшее или наибольшее значение для указанного столбца.
SELECT MIN(OrderTime) AS minDate, MAX(OrderTime) AS maxDate FROM Orders                            --#=> выводит в 2х однострочных колонках под новыми именами самую маленькую и самую большую даты
SELECT YEAR(OrderTime) AS OYear, MAX(OrderTotal) AS maxOT FROM Orders GROUP BY YEAR(OrderTime)     --#=> выводит максимальные значения колонки OrderTotal по годам(сгруппированные по годам)
SELECT room_id, MAX(end_date) AS last_end_date FROM Reservations GROUP BY room_id                  --#=> самые позние даты выезда сгруппированные по номерам комнат

	-- AVG/STDEV(имя_столбца) (среднее значение/стандартное отклонение): считает среднее значение столбца
SELECT YEAR(OrderTime) AS OYear, AVG(OrderTotal) AS AvDelTime FROM Orders GROUP BY YEAR(OrderTime) --#=> среднее значение столбца OrderTotal за каждый год(группируем по годам)
SELECT plane, AVG(TIMESTAMPDIFF(SECOND, time_out, time_in)) AS time FROM Trip GROUP BY plane       --#=> среднее время полета по моделям самолетов

	-- RANK() [PostgreSQL] Функция RANK()присваивает ранг каждой строке в разделе результирующего набора.
SELECT sale, RANK() OVER(ORDER BY sale DESC) AS sale_rank FROM sales GROUP BY sale                   --#=> создаем колонку рангов цен у наибольшей(DESC) лучший ранг(1й) у одинаковых одинаковый ранг.
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS sale_rank FROM sales GROUP BY sale        --#=> ранг по 2м полям, если 1е равно использует 2е

	-- Медианное значение столбца(постгре??)
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY score) AS median FROM result                      --# больше подходит для целых чисел
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY some) AS median FROM result                       --# больше подходит для непрерывных значений ??

	-- ARRAY_AGG(column) [PostgreSQL ??] создание массива из сгруппированных значений столбца
SELECT name, ARRAY_AGG(rating) AS total_rentals FROM customer GROUP BY name                          --#=> группируем по имени, создавая массив всех рэйтингов к нем относящихся
	-- ARRAY_AGG(column ORDER BY column2) [PostgreSQL ??] создание массива из сгруппированных значений столбца с сортировкой внутри массива в том числе по другому столбцу
SELECT ARRAY_AGG(name ORDER BY id DESC) AS names FROM students GROUP BY subject                      --#=> группируем имена в массив, где ини будут порядке по id

	-- HAVING (наличие): фильтрует группы по условию, чемто похоже на WHERE, нужен для того чтоб фильтровать после агрегирования(суммы, подсчет итд) для GROUP BY
	-- (раполагается после GROUP BY но до ORDER BY)
SELECT CustomerId, COUNT(*) AS Count FROM Orders GROUP BY CustomerId HAVING COUNT(*) > 5       --#=> считает количество заказов, размещенных каждым клиентом, а затем отфильтрует только клиентов с более чем 5
SELECT home_type, AVG(price) AS avg_price FROM Rooms GROUP BY home_type HAVING avg_price > 50  --#=> средняя цена сгруппированная по тем типам домов где эта средняя цена больше 50
SELECT home_type, MIN(price) AS min_price FROM Rooms WHERE has_tv = True GROUP BY home_type HAVING COUNT(*) >= 5; --#=> выводит только для тех типов домов с телевизором, которых есть >= 5
SELECT name AS total_rentals FROM customer GROUP BY name HAVING 'NC-17' != ALL(ARRAY_AGG(f.rating))               --#=> используем HAVING с колонкой которую не выводим

	-- HAVING EVERY   -  аналог ALL ???.  тоесть где все сгруппированные значения соотв условию
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL) ORDER BY 1 DESC















-- 
