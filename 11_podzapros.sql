--                                           Подзапросы


-- Подзапрос — это запрос, использующийся в другом SQL запросе. Подзапрос всегда заключён в круглые скобки и обычно выполняется перед основным запросом.

	-- 1. Подзапрос возвращающий 1 строку одного столбца(скалярный подзапрос)
	-- (может использоваться в различных частях основного SQL запроса, но чаще всего он используется в условиях ограничений выборки с помощью операторов сравнения =, <>, >, <)
SELECT (SELECT name FROM company LIMIT 1) AS company_name                                                       --#=> вывод единственного значения (названия компании)
SELECT * FROM FamilyMembers WHERE birthday = (SELECT MAX(birthday) FROM FamilyMembers)                          --#=> вывод самых молодых
SELECT * FROM Reservations WHERE Reservations.room_id = (SELECT id FROM Rooms ORDER BY price DESC LIMIT 1)      --#=> список всех бронирований самой дорогой комнаты
SELECT Users.* FROM Users JOIN Rooms ON Rooms.owner_id = Users.id WHERE price = (SELECT MAX(price) FROM Rooms)  --#=> в многотабличном запросе

	-- 2. Подзапросы с несколькими строками и одним столбцом(его нельзя просто использовать с операторами сравнения тк возвращает много строк)
	-- ALL - можем сравнивать отдельное значение с каждым значением в наборе, полученным подзапросом. Вернёт TRUE, только если все сравнения отдельного значения со значениями в наборе вернут TRUE.
SELECT 200 > ALL(SELECT price FROM Rooms)                                                                    --#=> все ли комнаты дешевле чем 200
SELECT DISTINCT name FROM Users JOIN Rooms ON Users.id = Rooms.owner_id WHERE Users.id <> ALL (SELECT DISTINCT user_id FROM Reservations)
	-- IN - проверяет входит ли конкретное значение в набор значений. В качестве такого набора как раз может использовать подзапрос, возвращающий несколько строк с одним столбцом.
SELECT id, name FROM departments WHERE id IN (SELECT department_id FROM sales WHERE price > 98)              --#=> так как используется IN то в подзапросе должен быть 1 стобец
SELECT good_name FROM Goods WHERE good_id NOT IN (SELECT good FROM Payments)                                 --#=> NOT IN
	-- ANY - имеет схожие поведение c IN но возвращает TRUE(те работает через операторы сравнения), если хотя бы одно сравнение отдельного значения со значением в наборе вернёт TRUE.
SELECT * FROM Users WHERE id = ANY (SELECT DISTINCT owner_id FROM Rooms WHERE price >= 150)                  --#=> найдёт пользователей, которые владеют хотя бы 1 жилым помещением стоимостью более 150

	-- 3. Многостолбцовые подзапросы - возвращающими несколько столбцов и несколько строк (производные таблицы)
SELECT * FROM Reservations WHERE (room_id, price) IN (SELECT id, price FROM Rooms)                           --#=> попарно сравнивает значения в основном запросе со значениями в подзапросе
SELECT * FROM Rooms WHERE (has_tv, has_internet) IN (SELECT has_tv, has_internet FROM Rooms WHERE id=11)     --#=> по одной конкретной строке

	-- 4. Коррелированные подзапросы - ссылаются на один или несколько столбцов основного запроса(зависимые, все прошлые 3 варианта были независимы от остального запроса)
	-- (он выполняется не один раз перед выполнением запроса, в который он вложен, а для каждой строки, которая может быть включена в окончательный результат)
	-- (использование коррелированных подзапросов может вызвать проблемы с производительностью, особенно если содержащий запрос возвращает много строк)
SELECT
   FamilyMembers.member_name,
   (SELECT MAX(Payments.unit_price) FROM Payments WHERE Payments.family_member = FamilyMembers.member_id) AS max_price
FROM FamilyMembers
--#=> Выводим для каждой строки максимум значения колонки из строки другой таблицы по соотв этих строк в значениях Payments.family_member и FamilyMembers.member_id

-- Можно использовать другой запрос после FROM вместо имени таблицы
select user_id, video_id from (select user_id, video_id, count(distinct video_id) over (partition by user_id) as cnt from user_playlist) t

-- Подзапрос таблицы к самой себе. Имитирует GROUP BY по полю supplier_id
SELECT DISTINCT ON(supplier_id)
supplier_id,
(SELECT COUNT(id) FROM products AS o WHERE o.supplier_id = p.supplier_id) AS total_products
FROM products AS p
ORDER BY supplier_id DESC

	-- EXISTS используется в сочетании с подзапросом и считается выполненным, если подзапрос возвращает хотя бы одну строку
	-- (Операторы SQL, использующие условие EXISTS, очень неэффективны, поскольку подзапрос повторно запускается для КАЖДОЙ строки в таблице внешнего запроса)
SELECT * FROM customers WHERE EXISTS (SELECT * FROM orders WHERE customers.customer_id = orders.customer_id)

	-- Двойное условие для подзапроса(не только для EXISTS а для любого оператора)
SELECT * FROM dep WHERE EXISTS (SELECT dep_id FROM sales WHERE sales.dep_id = dep.id AND price > 98)          --#=> 2е условие для позапроса через AND

	-- EXCEPT  - не соответсвие подзапросу
SELECT id FROM orders EXCEPT SELECT id FROM orders WHERE date IS NOT NULL
















--
