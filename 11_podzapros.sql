--                                              Подзапросы

-- Подзапрос — это запрос, использующийся в другом SQL запросе. Подзапрос всегда заключён в круглые скобки и обычно выполняется перед основным запросом.



--                                          1-а. Скалярный подзапрос

-- Скалярный подзапрос - это подзапрос возвращающий 1 строку одного столбца(литерал). Он может использоваться в различных частях основного SQL запроса, но чаще всего он используется в условиях ограничений выборки с помощью операторов сравнения =, <>, >, <

SELECT (SELECT name FROM company LIMIT 1) AS company_name                 -- из той же таблицы, в зоне выбора столбцов
SELECT * FROM Family WHERE birthday = (SELECT MAX(birthday) FROM Family)  -- из той же таблицы, в зоне WHERE
SELECT * FROM Res WHERE Res.room_id = (SELECT id FROM Rooms ORDER BY price DESC LIMIT 1) -- подзапрос из другой таблицы без объединения таблиц
SELECT Users.* FROM Users JOIN Rooms ON Rooms.owner_id = Users.id WHERE price = (SELECT MAX(price) FROM Rooms)  -- в многотабличном запросе



--                            1-б. Подзапросы возвращающие несколько строк одного столбца

-- Подзапросы возвращающие несколько строк одного столбца нельзя просто использовать с операторами сравнения тк они возвращает много строк, поэтому нужно использовать операторы ALL, IN, ANY

-- ALL - сравнивает отдельное значение с каждым значением в наборе, полученным подзапросом. Вернёт TRUE, только если все сравнения отдельного значения со значениями в наборе вернут TRUE.
SELECT 200 > ALL(SELECT price FROM Rooms)                         -- все ли комнаты дешевле чем 200
SELECT name FROM Users JOIN Rooms ON Users.id = Rooms.owner_id WHERE Users.id <> ALL (SELECT user_id FROM Res) -- в многотабличном запросе с таблицей не объединенной с ним

-- IN - проверяет входит ли конкретное значение в набор значений (тут подзвпроса возвращающего набор строк одного столбца).
SELECT id, name FROM departments WHERE id IN (SELECT department_id FROM sales WHERE price > 98)  -- так как используется IN то в подзапросе должен быть 1 стобец
SELECT good_name FROM Goods WHERE good_id NOT IN (SELECT good FROM Payments)                     -- NOT IN

-- ANY - имеет схожие поведение c IN но возвращает TRUE(те работает через операторы сравнения), если хотя бы одно сравнение отдельного значения со значением в наборе вернёт TRUE.
SELECT * FROM Users WHERE id = ANY (SELECT DISTINCT owner_id FROM Rooms WHERE price >= 150)  -- найдёт пользователей, которые владеют хотя бы 1 жилым помещением стоимостью более 150



--                                     1-в. Многостолбцовые подзапросы

-- Многостолбцовые подзапросы - возвращают несколько столбцов и несколько строк (производные таблицы)
SELECT * FROM Reservations WHERE (room_id, price) IN (SELECT id, price FROM Rooms)     -- попарно сравнивает значения в основном запросе со значениями в подзапросе
SELECT * FROM Rooms WHERE (has_tv, has_internet) IN (SELECT has_tv, has_internet FROM Rooms WHERE id=11)  -- по одной конкретной строке



--                                       2. Коррелированные подзапросы

-- Коррелированные подзапросы - ссылаются на один или несколько столбцов основного запроса
-- Коррелированные подзапросы зависимые(все прошлые 3 варианта были независимы от остального запроса) - он выполняется не один раз перед выполнением запроса, в который он вложен, а для каждой строки, которая может быть включена в окончательный результат. Потому использование коррелированных подзапросов может вызвать проблемы с производительностью, особенно если содержащий запрос возвращает много строк

SELECT
  Family.name,
  (SELECT MAX(Payments.price) FROM Payments WHERE Payments.member = Family.member_id) AS max_price
FROM Family
-- По Family.member_id находим значения в другой таблице соответсвующие данной строке в базовом запросе

-- Можно использовать другой запрос после FROM вместо имени таблицы
SELECT user_id, video_id
FROM (SELECT user_id, video_id, COUNT(distinct video_id) OVER (PARTITION BY user_id) AS cnt FROM user_playlist) t

-- Подзапрос таблицы к самой себе. Имитирует GROUP BY по полю supplier_id
SELECT DISTINCT ON(supplier_id)
supplier_id,
(SELECT COUNT(id) FROM products AS o WHERE o.supplier_id = p.supplier_id) AS total_products
FROM products AS p


-- EXISTS используется в сочетании с подзапросом и считается выполненным, если подзапрос возвращает хотя бы одну строку (Операторы SQL, использующие условие EXISTS, очень неэффективны, поскольку подзапрос повторно запускается для КАЖДОЙ строки в таблице внешнего запроса)
SELECT * FROM customers WHERE EXISTS (SELECT * FROM orders WHERE customers.customer_id = orders.customer_id)


-- EXCEPT  - не соответсвие подзапросу
SELECT id FROM orders EXCEPT SELECT id FROM orders WHERE date IS NOT NULL
















--
