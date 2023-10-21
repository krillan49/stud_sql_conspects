--                                              JOIN

-- таблица.столбец (прим Customers.Id): позволяет при работе с несколькими таблицами выбирать столбцы из определенных
SELECT Customers.Id FROM Customers WHERE Customers.id < 5

-- Перечисление таблиц через запятую - все данные одной таблицы для каждого элемента другой и наоборот, те будет огромная таблица хз чего
SELECT * FROM people, toys


-- JOIN - многотабличные запрсы(позволяет делать выборку из нескольких таблиц объединяя их в запрсе - позволяют нам «соединять» строки нескольких таблиц вместе). Соединение бывает:
--   внутренним INNER (по умолчанию)
--   внешним OUTER, при этом внешнее соединение делится на левое LEFT, правое RIGHT и полное FULL

-- ON - оператор после кторого пишется условие о том как именно записи из разных таблиц должны находить друг друга(как они соответствуют друг другу)

-- INNER JOIN (внутреннее соединение): INNER писать не обязательно тк это значение по умолчанию
-- Внутреннее соединение —  находятся пары записей из двух таблиц, удовлетворяющие условию соединения, тем самым образуя новую таблицу, содержащую поля из первой и второй исходных таблиц.
-- Если нашем условии указано равенство полей A.good_id и B.id, то при внутреннем соединении в итоговой выборке окажутся только записи, где в обоих таблицах есть одинаковое значения в good_id и id.
SELECT * FROM Customers INNER JOIN Orders ON Orders.NameId = Customers.Id                       --#=> выбираем все строки 2х таблиц в которых  Orders.NameId = Customers.Id, таблиц Customers и Orders
SELECT products.*, companies.name AS name FROM products JOIN companies ON products.company_id = companies.id     -- #=> выбираем из 1й таблицы все, а из 2й одну колонку
SELECT family_member, member_name, amount * unit_price AS price FROM Payments INNER JOIN FamilyMembers ON Payments.family_member = FamilyMembers.member_id
--#=> тут колонки family_member, amount, unit_price - из таблицы Payments; а колонка member_name - из таблицы FamilyMembers (1)
SELECT Class.name, Stud_in_class.student, Student.first_name FROM Class JOIN Stud_in_class ON Class.id = Stud_in_class.class JOIN Student ON Stud_in_class.student = Student.id   --#=> объединение 3х таблиц

-- (АЛЬТЕРНАТИВА)Перечисление таблиц через запятую вместо INNER JOIN и WHERE вместо ON
SELECT family_member, member_name FROM Payments, FamilyMembers WHERE Payments.family_member = FamilyMembers.member_id  -- #=> тот же запрос что и выше (1)
SELECT people.*, toys.toy_count FROM people, toys WHERE people.id = toys.people_id

-- INNER JOIN + WHERE
SELECT * FROM Customers C INNER JOIN Orders O ON O.CustomerId = C.Id WHERE O.OrderTotal > 200   --#=> INNER JOIN + псевдонимы + WHERE
SELECT good_name FROM Goods JOIN Payments ON Payments.good = Goods.good_id JOIN FamilyMembers ON Payments.family_member = FamilyMembers.member_id WHERE status = 'son'
--#=> условие WHERE пишется после всего многотабличного запроса. Если выводится колонка только 1й таблицы указывать через точку не обязательно.

-- INNER JOIN + USING (вместо ON и сравнения) + AND (дополнительная выборка в присоединяемой таблице, удобно для многотабличных джойнов)
SELECT film_id, title, popularity FROM film
JOIN film_category USING (film_id)
JOIN category ON film_category.category_id = category.category_id AND name = 'Children'
JOIN inventory USING (film_id)

-- INNER JOIN + GROUP BY
SELECT people.*, COUNT(*) AS toy_count FROM toys JOIN people ON people.id = toys.people_id GROUP BY people.id            --#=> с использованием функции для таблицы toys
SELECT Reservations.room_id, AVG(Reviews.rating) AS avg_score FROM Reservations JOIN Reviews ON Reservations.id = Reviews.reservation_id GROUP BY Reservations.room_id
--#=> выбираем Reservations.room_id и средние значения Reviews.rating для каждого Reservations.room_id при помощи группировки по Reservations.room_id из объединенных таблиц Reservations и Reviews


OUTER JOIN (внешнее соединение): может быть трёх типов: левое LEFT, правое RIGHT и полное FULL. По умолчанию оно является полным.
-- Оно обязательно возвращает все строки одной таблицы (LEFT, RIGHT) или двух таблиц (FULL)

-- LEFT OUTER JOIN (внешнее левое соединение): возвращает все значения из левой таблицы, соединённые с соответствующими значениями из правой таблицы, если они удовлетворяют условию соединения
-- ( или заменяет их на NULL те что не удовлетворяют )
SELECT Timepair.id 'timepair.id', start_pair, end_pair,                                       --#=> Timepair.id 'timepair.id' вариант псевдономи(только для MySQL ???)
  Schedule.id 'schedule.id', date, class, number_pair, teacher, subject, classroom
FROM Timepair LEFT JOIN Schedule ON Schedule.number_pair = Timepair.id;
--#=> В выборку попали все строки из левой таблицы, дополненные данными из правой там где есть Schedule.number_pair = Timepair.id, где нет в колонки правой таблицы проставлены NULL

SELECT first_name, last_name, COUNT(Schedule.id) AS amount_classes FROM Teacher LEFT JOIN Schedule ON Teacher.id = Schedule.teacher GROUP BY Teacher.id      --#=> с функцией

-- Получение данных, относящихся только к левой таблице(которые из правой дополнены значениями NULL):
SELECT поля_таблиц FROM левая_таблица LEFT JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ WHERE правая_таблица.ключ IS NULL


-- RIGHT OUTER JOIN (внешнее правое соединение): тоже что и левое только все значения возвращаются из правой а из левой только соотв условию или иначе NULL

-- FULL OUTER JOIN (внешнее полное соединение): Соединение, которое выполняет внутреннее соединение записей и дополняет их левым внешним соединением и правым внешним соединением
--   1. Формируется таблица на основе внутреннего соединения (INNER JOIN)
--   2. В таблицу добавляются значения не вошедшие в результат формирования из левой таблицы (LEFT OUTER JOIN)
--   3. В таблицу добавляются значения не вошедшие в результат формирования из правой таблицы (RIGHT OUTER JOIN)
-- Соединение FULL JOIN реализовано не во всех СУБД. Например, в MySQL оно отсутствует
SELECT поля_таблиц FROM левая_таблица FULL OUTER JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ


-- Получение данных, не относящихся к левой и правой таблицам одновременно (обратное INNER JOIN):
SELECT поля_таблиц FROM левая_таблица FULL OUTER JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ WHERE левая_таблица.ключ IS NULL OR правая_таблица.ключ IS NULL


-- CROSS JOIN LATERAL - вывод новых строк из одной строки
SELECT s.results FROM strings
CROSS JOIN LATERAL unnest(string_to_array(string, ' ')) AS s(results)  --#=> тут results название столбца на выходе а s - хз что (мб s(results) просто имя те скобки не функциональны ??)














-- 
