--                                             Группировка и агрегация

-- GROUP BY (группировка функций/значений) группирует строки выбранных колонок по их значениям(одинаковые значения группирует в одно - одну строку). Соттветсвенно число подгуп равно числу всех значений в колонке или колонках без повторов по которым проводим группировку, к значениям группируемых колонок нужно применить агрегатную функцию, чтобы объединить их тем или иным способом
-- На каждую группу в итоге будет выведена одна строка
-- Располагается между WHERE и ORDER BY
-- WHERE фильтрует строки до группировки

-- Группируем по 1й колонке
SELECT home_type FROM Rooms GROUP BY home_type                     -- все сгруппированные типы значений в home_type Это будет ранозначно SELECT DISTINCT home_type FROM Rooms
SELECT raiting FROM Rooms GROUP BY home_type                     -- все сгруппированные значения raiting по типам значений из home_type.
SELECT home_type FROM Rooms GROUP BY home_type ORDER BY home_type  -- сортировка идет после группировки
SELECT home_type FROM Rooms GROUP BY home_type WHERE sum > 10      -- WHERE фильтрует строки до группировки
SELECT home_type, AVG(price) AS ap FROM rooms GROUP BY home_type   -- группы значений home_type и среднее значение price для каждой из этих групп

-- Группировка по нескольким колонкам. для обобщения в одну группу одинаковыми дожны быть значения во всех группируемых колонках. Тоесть отдельная группа будет браться по каждой существующей паре значений
SELECT home_type, street, AVG(price) ap FROM Rooms GROUP BY home_type, street

-- Группируем по результату функции(по выражению) над колонкой
SELECT YEAR(OrderTime) yr, SUM(OrderTotal) st FROM Orders GROUP BY YEAR(OrderTime) -- группируем по годам из OrderTime, соотв сумма OrderTotal будет за каждый год, а не за каждую полную дату
SELECT SUBSTRING(name, 1, 1) AS a, SUM(OrderTotal) st FROM Orders GROUP BY SUBSTRING(name, 1, 1) -- группируем по первой букве имени
SELECT f_name || l_name AS name, SUM(OrderTotal) st FROM Orders GROUP BY f_name || l_name

-- При группировке можем ссылаться на псевдонимы
SELECT home_type h, street s, AVG(price) ap FROM Rooms GROUP BY h, s




--                                 [Postgres  ??]  ROLLUP и GROUPING SETS

-- ROLLUP(col1, col2, ... coln) - группировка по разному колличеству полей сразу - сначала по всем, потом по всем кроме последнего, потом по всем кроме последних 2х ..итд, потом по первому.
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY ROLLUP(name, month, day)
-- получаем сначала общую цену по товару за каждый день, потом за месяц, потом за все время


-- GROUPING SETS() - группировка по разному коллич полей сразу - по кастомным наборам
SELECT name, EXTRACT(MONTH FROM date) AS month, EXTRACT(DAY FROM date) AS day, SUM(price * count) AS total FROM products
GROUP BY GROUPING SETS ((name, month), (name, month, day), (name, day), (name))



--                                             Агрегатные функции

-- ?? Мб перечислить функции в одном отформатированном запросе ??

-- https://www.postgresql.org/docs/current/functions-aggregate.html

-- Агрегатная функция – это функция, которая выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Запрос с агрегатной функцией без GROUP BY обрабатывает всю таблицу как одну группу и возвращает одну строку
-- Агрегатные функции(за исключением COUNT) применяются только для значений, не равных NULL.


-- COUNT(имя_столбца) - агрегатная функция возвращает колличество сгруппированных строк в подгруппе, если взять по конкретному полю, то посчитает только те строки в которых значение в этом поле не NULL
SELECT COUNT(*) FROM orders;                      -- посчитать колличество строк в таблице
SELECT COUNT(*) FROM orders WHERE price > 20;     -- с фильтрацией, считает число строк где цена больше 20
SELECT home_type, COUNT(*) AS amount FROM Rooms GROUP BY home_type  -- считает колич различных значений в home_type

-- посчитать колличество уникальных значений
SELECT COUNT(DISTINCT country) FROM orders;  -- посчитать колличество уникальных значений в столбце country


-- SUM(имя_столбца) - агрегатная функция суммирует значения заданного столбца в подгруппе
SELECT SUM(OrderTotal) FROM Orders WHERE OrderTime > '2013-01-01'   -- выводим сумму тех значений столбца OrderTotal в которых в столбце OrderTime значение больше указанного


-- MIN/MAX(имя_столбца) - возвращают наименьшее или наибольшее значение для подгруппы указанного столбца, работает не только на числа но и на символы и на даты.
SELECT MIN(OrderTime) AS min, MAX(OrderTime) AS max FROM Orders                -- строка с самой маленькой и самой большой датой
SELECT YEAR(Otime) AS year, MAX(Total) AS max FROM Orders GROUP BY YEAR(Otime) -- максимальные значения колонки Total по годам
SELECT room_id, MAX(end_date) AS last_date FROM Reservations GROUP BY room_id  -- самые позние даты выезда сгруппированные по номерам комнат


-- AVG/STDEV(имя_столбца) - считает среднее значение/стандартное отклонение столбца
SELECT YEAR(Otime) AS year, AVG(Total) AS AvDelTime FROM Orders GROUP BY YEAR(Otime) -- среднее значение Total за каждый год
SELECT plane, AVG(fly_time) AS m_time FROM Trip GROUP BY plane                       -- среднее время полета по моделям самолетов


-- PERCENTILE_DISC(v)/PERCENTILE_CONT(v) - [ ?? PostgreSQL] медианное значение столбца
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY score) AS median FROM result  -- больше подходит для целых чисел
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY some) AS median FROM result   -- больше подходит для непрерывных значений ??


-- ARRAY_AGG(column, order) [PostgreSQL ??] создание массива из сгруппированных значений столбца, с возможностью сортировки массива
SELECT name, ARRAY_AGG(rating) AS rentals FROM customer GROUP BY name           -- создавая массив всех рэйтингов к каждому имени
SELECT ARRAY_AGG(name ORDER BY id DESC) AS names FROM students GROUP BY subject -- группируем имена в массив, в котором они будут отсортированы по столбцу id в порядке убывания
SELECT m_id, ARRAY_AGG(name || '-' || id ORDER BY id) AS en FROM emps GROUP BY m_id -- группируем результаты операции


-- STRING_AGG(column, раздклитель, order) [PostgreSQL ??] тоесть группирует все в одну строку
STRING_AGG(str, ', ' ORDER BY c.course_name)
STRING_AGG(c.course_name || '(' || c.score || ')', ', ' ORDER BY c.course_name)


-- BOOL_AND(price > 200) [PostgreSQL ??] - принимает логическое выражение и возвращает TRUE если для каждой строки в группе условие истинно иначе FALSE
SELECT name, BOOL_AND(price > 200) AS rich FROM customer GROUP BY name
-- BOOL_OR(price > 200) [PostgreSQL ??] - принимает логическое выражение и возвращает TRUE если для хотябы одной строки в группе условие истинно иначе FALSE
SELECT name, BOOL_OR(price > 200) AS has_rich FROM customer GROUP BY name


-- ?? Проверить работает ли так ??
-- EVERY( boolean ) => boolean. [PostgreSQL] - тоесть где все сгруппированные значения соответствуют условию (true)
SELECT customer_id, EVERY(delivery_date IS NULL) FROM orders GROUP BY customer_id;  -- Тоесть где все группируемые значения в группе соответвуют условию возвращает TRUE иначк FALSE


-- Можно использовать просто значения в агрегатных функциях
SELECT failure_reason, SUM(1) AS cnt FROM interview_failures GROUP BY failure_reason


-- Функция от вычислений
SELECT name, SUM(count * (handedness = 'Right-handed')::INT) AS "Right-handed" FROM customer GROUP BY name
-- Тоесть TRUE::INT это 1, соотв FALSE::INT это 0. В итоге получаем всегда 0 если значения не 'Right-handed'

-- Дистинкт до группировки, тоесть считаем только уникальные ?
SELECT date, COUNT(DISTINCT customer_id) FROM customers GROUP BY date
SELECT product_id, COUNT(DISTINCT(color_id, size_id)) AS total_unique_variants FROM product_variants GROUP BY product_id
-- тоесть считаем только уникальные комбинации по полям color_id и size_id



--                                      Условный оператор и группировка

-- Тоесть сначала условный оператор создает значения, а потом функция их считает при группировке ??
SELECT id, COUNT(CASE stock WHEN true THEN 1 ELSE NULL END) AS variants FROM product_variants GROUP BY id

-- COUNT в условном операторе
SELECT name, CASE WHEN COUNT(sub) = 0 THEN 'quit studying' ELSE 'failed' END AS reason FROM s GROUP BY name



--                                   Оконные функции с OVER при группировке

-- RANK() OVER() [PostgreSQL] Функция RANK() присваивает ранг каждой подгруппе в разделе результирующего набора(после группировки).
SELECT sale, RANK() OVER(ORDER BY sale DESC) AS srank FROM sales GROUP BY sale             -- создаем колонку рангов цен у наибольшей(DESC) лучший ранг(1й) у одинаковых одинаковый ранг.
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales GROUP BY sale  -- ранг по 2м полям, 2е не используется в основном запросе(как тогда по нему считет ??)


-- COUNT(*) OVER  и PARTITION BY   -  Разбиение группировки по значениям столбца(получается тоже что и группировка ??)
SELECT COUNT(*) OVER (PARTITION BY supplier_id) total_products FROM products


-- ?? Суммирует все строки до по условиям группировки OVER(ORDER BY date, id) включая данную
SELECT *, SUM(CASE WHEN op = 'add' THEN amount ELSE -amount END) OVER(ORDER BY date, id) AS fl_sum FROM actions ORDER BY date, id;


-- Оконная фунуция sum() over() Выводит суммы в каждой строке: сумму во всех строках(выводит в каждой строке), сумму для каждого customer_id(в каждой строке с эти customer_id) итд
SELECT sales_id, customer_id, cnt,
SUM(cnt) OVER () as total,
SUM(cnt) OVER (ORDER BY customer_id) AS running_total,
SUM(cnt) OVER (ORDER BY customer_id, sales_id) AS running_total_unique
FROM sales
ORDER BY customer_id, sales_id;



--                                  FILTER. Фильтрация в агрегатных функциях

-- FILTER - задает ограничение для значений, которые будут обрабатываться агрегатной функцией

SELECT
  rating,
  COUNT(*),                            -- так посчтитает общее число фиьмов
  COUNT(*) FILTER(WHERE length > 100), -- а так в том же запросе посчитаем колличество фильмов определенной продолжительности. А иначе с обычным условием WHERE после FROM пришлось бы делать 2 отдельных запроса
  COUNT(*) FILTER(WHERE length > 120)
FROM films GROUP BY rating;

-- ?? OVER + FILTER
SELECT order_id, MAX(order_id) FILTER(WHERE status_code = 4) OVER(ORDER BY order_id) AS sbn FROM order_status
-- Тоесть берем части таблицы между строками со значениями 4 в столбце status_code и заполняем их значениями MAX(order_id)



--                                                  HAVING

-- HAVING (наличие): фильтрует группы по условию. Чемто похоже на WHERE, но нужен для того чтоб фильтровать после группировки и  агрегирования(суммы, подсчет итд) с GROUP BY. Тоесть накладывает условия на результаты агрегатных функций
-- Прописывается после GROUP BY но до ORDER BY
-- Работает после GROUP BY

SELECT o_id, COUNT(*) FROM Orders GROUP BY o_id HAVING COUNT(*) > 5;       -- отфильтрует только клиентов с более чем 5 заказами
SELECT home, AVG(price) AS avp FROM Rooms GROUP BY home HAVING avp > 50;   -- только те сгруппированные данные где avp больше 50
SELECT type, MIN(price) AS min FROM Rooms WHERE price > 30 GROUP BY type HAVING COUNT(*) >= 5 OR COUNT(*) < 3; -- выводит только типы с ценой больше 30, которых есть >= 5 или < 2

-- используем HAVING с агрегацией по колонке которую не выводим
SELECT name, SUM(price) FROM customer GROUP BY name HAVING 'NC-17' != ALL(ARRAY_AGG(rating));
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL);

-- HAVING с агрегацией и условным оператором
SELECT f_id FROM film LEFT JOIN inventory USING(f_id) LEFT JOIN rental USING(i_id)
GROUP BY f_id HAVING SUM(CASE WHEN r_id IS NULL THEN 1 ELSE 0 END) < 7;















--
