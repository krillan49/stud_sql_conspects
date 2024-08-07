--                                                Подзапросы

-- Запросы бывают логически сложными, потому может понадобиться разбить запросы на части

-- Подзапрос — это запрос, использующийся в другом SQL запросе.

-- Подзапрос всегда заключён в круглые скобки и обычно выполняется перед основным запросом.

-- Если можно переписать код с подзапросом на вариант при помощи соединения, то стоит выбрать по критериям от самого важного:
-- Протизводительность (необходимая для нашей задачи)
-- Читабельность

SELECT company_name FROM suppliers WHERE country IN (SELECT country FROM customers);  -- с подзапросом
SELECT DISTINCT suppliers.company_name FROM suppliers JOIN customers USING(country);  -- с соединением

-- Можно сперва написать с подзапросом если это проще, а потом если это необходимо переписать с джоином, оптимизировав его. Но замена подзапроса джоином возможна не всегда

-- Часто планировщик SQL сам автоматически преобразует запросы с подзапросами в запросы с соединениями перед их обработкой



--                                          1-а. Скалярный подзапрос

-- Скалярный подзапрос - это подзапрос возвращающий 1 строку одного столбца(литерал). Он может использоваться в различных частях основного SQL запроса, но чаще всего он используется в условиях ограничений выборки с помощью операторов сравнения =, <>, >, <

-- из той же самой таблицы, в зоне выбора столбцов
SELECT (SELECT name FROM company LIMIT 1) AS c_name FROM company;

-- в зоне WHERE с операциями сравнения
SELECT * FROM Family WHERE birthday = (SELECT MAX(birthday) FROM Family);               -- из той же таблицы
SELECT * FROM Res WHERE Res.room_id = (SELECT id FROM Rooms ORDER BY price LIMIT 1);    -- из другой таблицы без объединения таблиц
SELECT u.* FROM u JOIN r ON r.owner_id = u.id WHERE price = (SELECT MAX(price) FROM r); -- в многотабличном запросе
SELECT name, count FROM products WHERE count > (SELECT AVG(count) FROM products)        -- значения больше среднего

-- после LIMIT, подзапрос чтобы получить необходимое число для лимитирования
SELECT category_name, SUM(units_in_stock) AS sum FROM products JOIN categories USING(category_id)
GROUP BY category_name ORDER BY sum DESC
LIMIT (SELECT MIN(product_id) + 4 FROM products);



--                              1-б. Возвращающие несколько строк одного столбца

-- Подзапросы возвращающие несколько строк одного столбца нельзя просто использовать с операторами сравнения тк они возвращает много строк, поэтому нужно использовать операторы ALL, IN, ANY

-- ALL - сравнивает отдельное значение с каждым значением в наборе, полученным подзапросом. Вернёт TRUE, только если все сравнения отдельного значения со значениями в наборе вернут TRUE.
SELECT 200 > ALL (SELECT price FROM Rooms);                                          -- все ли комнаты дешевле чем 200
SELECT name FROM u JOIN r ON u.id = r.o_id WHERE u.id <> ALL (SELECT u_id FROM Res); -- в многотабличном запросе с таблицей не объединенной с ним

-- IN / NOT IN - проверяет входит ли конкретное значение в набор значений
SELECT id, name FROM departments WHERE id IN (SELECT department_id FROM sales WHERE price > 98);
SELECT good_name FROM Goods WHERE good_id NOT IN (SELECT good_id FROM Payments);                     -- NOT IN

-- ANY - имеет схожие поведение c IN но возвращает TRUE(те работает через любые операторы сравнения), если хотя бы одно сравнение отдельного значения со значением в наборе вернёт TRUE.
SELECT * FROM Users WHERE id = ANY (SELECT owner_id FROM Rooms WHERE price >= 150);  -- найдёт пользователей, которые владеют хотя бы 1 жилым помещением стоимостью более 150



--                                     1-в. Многостолбцовые подзапросы

-- Многостолбцовые подзапросы - возвращают несколько столбцов и несколько строк (подтаблицы)
SELECT * FROM Res WHERE (r_id, price) IN (SELECT id, price FROM Rooms);  -- попарно сравнивает значения в основном запросе со значениями в подзапросе
SELECT * FROM Rooms WHERE (tv, internet) IN (SELECT tv, internet FROM Rooms WHERE id = 11);  -- по одной конкретной строке



--                                  Подзапрос после FROM (запрос от подзапроса)

-- Можно использовать другой запрос после FROM вместо имени таблицы
SELECT class, COUNT(class)
FROM (SELECT user_id, MAX(class) AS class FROM users GROUP BY user_id) AS subquery -- должен иметь псевдоним
GROUP BY class



--                                      JOIN с результатом подзапроса

SELECT o.customer_id, SUM(o.freight) AS freight_sum
FROM orders AS o
INNER JOIN (SELECT customer_id, AVG(freight) AS freight_avg FROM orders GROUP BY customer_id) AS oa
  ON oa.customer_id = o.customer_id
WHERE o.freight > oa.freight_avg AND o.shipped_date BETWEEN '1996-07-16' AND '1996-07-31'
GROUP BY o.customer_id ORDER BY freight_sum;



--                                       2. Коррелированные подзапросы

-- Коррелированные подзапросы - ссылаются на один или несколько столбцов основного запроса
-- Коррелированные подзапросы зависимые(все прошлые 3 варианта были независимы от остального запроса) - он выполняется не один раз перед выполнением запроса, в который он вложен, а для каждой строки, которая может быть включена в окончательный результат. Потому использование коррелированных подзапросов может вызвать проблемы с производительностью, особенно если содержащий запрос возвращает много строк

-- По соотв со значением столбца в каждой новой строке, делаем каждый раз позапрос из другой таблице
SELECT Family.name, (SELECT MAX(Pay.price) FROM Pay WHERE Pay.member_id = Family.member_id) AS max_price FROM Family



--                                               EXISTS, EXCEPT

-- EXISTS используется в сочетании с подзапросом и считается выполненным, если подзапрос возвращает хотя бы одну строку (Операторы SQL, использующие условие EXISTS, очень неэффективны, поскольку подзапрос каррелирован и повторно запускается для КАЖДОЙ строки в таблице внешнего запроса)
-- EXISTS возвращает TRUE или FALSE, если поздзапрос возвращает 1 или более строк и соответсвенно, например WHERE фильтрует или нет эту запись
SELECT * FROM customers WHERE EXISTS (SELECT * FROM orders WHERE customers.customer_id = orders.customer_id);

-- EXCEPT  - не соответсвие подзапросу
SELECT id FROM orders WHERE EXCEPT (SELECT id FROM orders WHERE date IS NOT NULL);

















--
