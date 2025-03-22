--                                                Подзапросы

-- Запросы бывают логически сложными, потому может понадобиться разбить запросы на части

-- Подзапрос — это запрос, использующийся внутри другого SQL запроса.

-- Подзапрос всегда заключён в круглые скобки и обычно выполняется перед основным запросом.

-- Подзапросы мугут быть:
-- коррелирующие/связанные - обращаются к полям основного запроса. Не эффективны по быстродействию, тк выполняются для каждой строки основного запроса заново)
-- не коррелирующие/не связанные - не обращяются к полям основного запроса. Эффективны по быстродействию, тк выполняются 1 раз, тк нет смысла для каждой строки выполнять одинаковый позапрос

-- Так же могут делиться на:
-- скалярные(возвращают 1 значение)
-- возвращающие 1 столбец значений
-- возвращающие несколько столбцов значений(как подтаблицы)



--                                       Выбор между подзапросом и JOIN

-- Если можно переписать код с подзапросом на вариант с JOIN, то стоит выбрать по критериям от самого важного:
-- 1. Протизводительность (необходимая для нашей задачи)
-- 2. Читабельность

SELECT company_name FROM suppliers WHERE country IN (SELECT country FROM customers);  -- аналог с подзапросом
SELECT DISTINCT suppliers.company_name FROM suppliers JOIN customers USING(country);  -- аналог с соединением

-- Можно сперва написать с подзапросом если это проще, а потом если это необходимо переписать с JOIN, оптимизировав его. Но замена подзапроса джоином возможна не всегда

-- Часто планировщик SQL сам автоматически преобразует запросы с подзапросами в запросы с соединениями JOIN



--                                           Скалярный подзапрос

-- Скалярный подзапрос - это подзапрос возвращающий 1 строку одного столбца, те литерал, содержимое конкретной ячейки. Он может использоваться в различных частях основного SQL запроса, но чаще всего он используется для условиях ограничений выборки с помощью операторов сравнения =, <>, >, <.

-- Тк скалярный запрос возвращает 1 значение, то возможно и удобно применять его в блоке SELECT
SELECT (SELECT name FROM company LIMIT 1) AS c_name FROM company; -- подзапрос из той же самой таблицы

-- в зоне WHERE с операциями сравнения
SELECT * FROM Family WHERE birthday = (SELECT MAX(birthday) FROM Family);               -- из той же таблицы
SELECT name, count FROM products WHERE count > (SELECT AVG(count) FROM products)        -- значения больше среднего
SELECT * FROM Res WHERE Res.room_id = (SELECT id FROM Rooms ORDER BY price LIMIT 1);    -- из другой таблицы без необходимости объединения этих таблиц
SELECT u.* FROM u JOIN r ON r.owner_id = u.id WHERE price = (SELECT MAX(price) FROM r); -- в многотабличном запросе

-- В посе LIMIT, подзапрос чтобы получить необходимое число для лимитирования
SELECT category_name, units_in_stock FROM products LIMIT (SELECT MIN(product_id) + 4 FROM products);



--                                     Возвращающие 1 столбец значений

-- Подзапросы возвращающие несколько строк одного столбца нельзя просто использовать с операторами сравнения тк они возвращает много строк, поэтому нужно использовать операторы ALL, IN, ANY

-- ALL - сравнивает отдельное значение с каждым значением в наборе, полученным подзапросом. Вернёт TRUE, только если все сравнения отдельного значения со значениями в наборе вернут TRUE.
SELECT 200 > ALL (SELECT price FROM Rooms);                    -- все ли комнаты дешевле чем 200
SELECT name FROM u WHERE id <> ALL (SELECT u_id FROM res);     -- с другой таблицей

-- IN / NOT IN - эта функция так же может принимать подзапросы, проверяет входит ли конкретное значение в набор значений. Возвращает 1 колонку. Возвращает TRUE, FALSE или NULL(только в случаях: если среди значений нет искомого и среди них присутствет хотя бы 1 значение NULL; или если мы ищем NULL в независимости от того есть оно в столбце или нет) это стандартное поведение в SQL, так что оно такое же в большинстве СУБД
SELECT id, name FROM departments WHERE id IN (SELECT department_id FROM sales WHERE price > 98);
SELECT good_name FROM Goods WHERE good_id NOT IN (SELECT good_id FROM Payments);

-- ANY / SOME(алиас) - имеет схожие поведение c IN но возвращает TRUE или FALSE при помощи операторов сравнения, если хотя бы одно сравнение(любые операторы сравнения) отдельного значения со любым значением в наборе вернёт TRUE, то в итоге вернется TRUE.
SELECT * FROM Users WHERE id = ANY (SELECT owner_id FROM Rooms WHERE price >= 150);  -- найдёт пользователей, которые владеют хотя бы 1 жилым помещением стоимостью более 150



--                                       Многостолбцовые подзапросы

-- Многостолбцовые подзапросы - возвращают несколько столбцов и несколько строк (подтаблицы)
SELECT * FROM Res WHERE (r_id, price) IN (SELECT id, price FROM Rooms);  -- попарно сравнивает значения в основном запросе со значениями в подзапросе
SELECT * FROM Rooms WHERE (tv, internet) IN (SELECT tv, internet FROM Rooms WHERE id = 11);  -- по одной конкретной строке



--                                  Подзапрос после FROM (запрос от подзапроса)

-- Можно использовать другой запрос(обычно многостолбцовый) в поле FROM вместо имени таблицы
SELECT class, COUNT(class)
FROM (SELECT user_id, MAX(class) AS class FROM users GROUP BY user_id) AS subquery -- должен иметь псевдоним
GROUP BY class



--                                         JOIN с результатом подзапроса

-- Более подробно описано в JOIN.sql -> LATERAL Подзапросы

SELECT o.customer_id, SUM(o.freight) AS freight_sum
FROM orders AS o
INNER JOIN (SELECT customer_id, AVG(freight) AS freight_avg FROM orders GROUP BY customer_id) AS oa
  ON oa.customer_id = o.customer_id
WHERE o.freight > oa.freight_avg AND o.shipped_date BETWEEN '1996-07-16' AND '1996-07-31'
GROUP BY o.customer_id ORDER BY freight_sum;



--                                       Коррелирующие/связанные подзапросы

-- Коррелированные подзапросы - ссылаются(изпользуют внутри себя) на одно или несколько полей внешнего запроса

-- Коррелированные подзапросы зависимые - они выполняются не один раз перед выполнением запроса, в который он вложен, а для каждой строки, которая может быть включена в окончательный результат. Потому использование коррелированных подзапросов может вызвать проблемы с производительностью, особенно если содержащий запрос возвращает много строк

-- По соответсвию со значением столбца в каждой новой строке, делаем каждый раз позапрос из другой таблицы. Тут скалярный коррелированный подзапрос
SELECT Family.name, (SELECT MAX(Pay.price) FROM Pay WHERE Pay.member_id = Family.member_id) AS max_price FROM Family



--                                              [NOT] EXISTS, EXCEPT

-- EXISTS, EXCEPT - функции, которые принимают в себя подзапрос. ? Для использования коррелированных подзапросов в блоке WHERE ?

-- Операторы SQL, использующие условие EXISTS, очень неэффективны, поскольку подзапрос каррелирован(ссылается на поля из внешнего запроса), он заново запускается для проверки КАЖДОЙ строки в таблице внешнего запроса

-- EXISTS используется в сочетании с подзапросом и считается выполненным(возвращает TRUE), если подзапрос возвращает хотя бы одну строку или FALSE, если не возвращает строк, например WHERE фильтрует или нет эту запись
SELECT * FROM customers WHERE EXISTS (SELECT * FROM orders WHERE customers.customer_id = orders.customer_id);

-- EXCEPT  - не соответсвие подзапросу
SELECT id FROM orders WHERE EXCEPT (SELECT id FROM orders WHERE date IS NOT NULL);

















--
