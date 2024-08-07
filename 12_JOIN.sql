--                                         Многотабличные запрсы. JOIN

-- имя_таблицы.имя_столбца: позволяет при работе с несколькими таблицами выбирать столбцы из определенных таблиц, удобно при одинаковых названиях в разных таблицах
SELECT Customers.Id FROM Customers WHERE Customers.id < 5

-- JOIN - оператор многотабличного запроса - позволяет делать выборку из нескольких таблиц, соединяя данные(строки) из них в одном запросе, те позволяют нам «соединять» строки нескольких таблиц вместе по соответсвующим значениям столбцов в них, используя например внешний ключ одной таблицы и первичный другой

-- Соединение бывает:
-- INNER - внутреннее соединение (по умолчанию)
-- OUTER - внешнее соединение. Оно делится на левое LEFT, правое RIGHT и полное FULL
-- СROSS - как декартово произведение(операция над множествами)
-- SELF  - соединение(рекурсивное) на саму себя

-- ON - оператор после кторого пишется условие о том как именно записи из разных таблиц должны находить друг друга(как они соответствуют друг другу)



--                                         INNER JOIN (внутреннее соединение)

-- INNER в запросе писать не обязательно тк это значение по умолчанию

-- Внутреннее соединение - находятся пары записей из двух таблиц, удовлетворяющие условию соединения, тем самым образуя записи новой таблицы, содержащую поля из первой и второй исходных таблиц. Например если в нашем условии указано равенство значений в полях A.good_id и B.id, то при внутреннем соединении в итоговой выборке окажутся только те записи, где эти значения равны

SELECT * FROM Cus INNER JOIN Ord ON Ord.Nid = Cus.id       -- выбираем и соединяем те строки(тут все столбцы) таблиц Cus и Ord в которых Ord.Nid = Cus.id
SELECT prod.*, comp.name AS name FROM prod JOIN comp ON prod.comp_id = comp.id  -- соединяем из 1й таблицы все, а из 2й одну колонку

-- Можно не писать имена таблиц для тех имен колонок в запросе, которых не существует в других объединяемых таблицах
SELECT member, name FROM Pay JOIN Family ON Pay.id = Family.m_id -- member из таблицы Pay, а name из таблицы Family

-- INNER JOIN + псевдонимы + WHERE(осуществляется после объединения)
SELECT * FROM Customers C JOIN Orders O ON O.CustId = C.Id WHERE O.Total > 200

-- объединение 3х таблиц
SELECT Class.name, S_in_c.student, Student.name
FROM Class
JOIN S_in_c ON Class.id = S_in_c.class
JOIN Student ON S_in_c.student = Student.id

-- INNER JOIN + GROUP BY. Группировка осуществляется после объединения
SELECT people.*, COUNT(*) FROM toys JOIN people ON people.id = toys.people_id GROUP BY people.id  -- с функцией для toys
SELECT Res.room_id, AVG(Rev.rating) AS score FROM Res JOIN Rev ON Res.id = Rev.res_id GROUP BY Res.room_id
-- выбираем Res.room_id и средние значения Rev.rating для каждого Res.room_id при помощи группировки по Res.room_id из объединенных таблиц Res и Rev



--                                       Объединение не по равенству значений

-- Помимо равенства значений можем объединять и по другим отношениям, напроимер != или < или >

-- объединение по нервыенству значений в колонке, тоесть соединяются значения тех строк таблиц, значения выбранной колонке в которых не равны
SELECT s1.state AS s_a, s2.state AS s_b, s1.total - s2.total AS dif FROM s1 JOIN s2 ON s1.state != s2.state

-- объединение по <, тоесть соединяются значения тех строк таблиц, значения выбранной колонке одной тавлицы меньше чем в другой
SELECT s1.state AS s_a, s2.state AS s_b, s2.total - s1.total AS dif FROM s1 JOIN s2 ON s1.state < s2.state



--                                        Несколько условий соединения

-- В условии соединения могут использоваться несколько соответсвий и логические операторы: AND, OR, NOT.

-- Запись в rank идентифицируется составным суррогатным ключом (store_id, rank_id). Т.е. чтобы найти информацию о должности сотрудника, нужно из таблицы rank взять строку с таким же идентификатором магазина и идентификатором должности в магазине.
SELECT e.first_name, e.last_name, r.rank_id, r.store_id, r.name
FROM e JOIN rank r ON r.rank_id = e.rank_id AND r.store_id = e.store_id



--                                                    USING

-- USING вместо ON и сравнения - используется для любых видов соединений, если столбец, по равенству значений которого объединяем, в обеих таблицах называется одинаково
SELECT film_id, title, popularity FROM film
JOIN film_category USING(film_id)
JOIN inventory USING(film_id)
JOIN category ON film_category.category_id = category.category_id AND name = 'Children'
-- AND name = 'Children'  - дополнительная выборка в присоединяемой таблице, удобно для многотабличных джойнов

-- C 2мя полями в USING
SELECT COALESCE(ts.product_id, tr.product_id) AS product_id, sale_qty, return_qty, COALESCE(ts.date, tr.date) AS date
FROM ts FULL JOIN tr USING(product_id, date)



--                                                 NATURAL JOIN

--  Работает как INNER JOIN, а соединение происходит автоматически по всем столбцам что имеют одинаковые имена, тоесть еще короче чем с USING.
-- Не рекомендуется тк: код не очень читабелен, тк не видно столбец по которому соединяем, так же может быть непрактичным, если введут еще столбцы с одинаковыми именами позже
SELECT order_id, customer_id, name, title FROM orders NATURAL JOIN employees;



--                            Таблицы через запятую вместо INNER JOIN и WHERE вместо ON

-- Если после FROM перечислить названия нескольких таблиц через запятую, то выберет все данные одной таблицы для каждого элемента другой и наоборот, те будет огромная таблица хз чего
SELECT * FROM people, toys

-- (АЛЬТЕРНАТИВА INNER JOIN ON) Перечисление таблиц через запятую вместо INNER JOIN и WHERE вместо ON
SELECT member, name FROM Pay, Family WHERE Pay.member = Family.member_id
SELECT people.*, toys.toy_count FROM people, toys WHERE people.id = toys.people_id

-- объединение не по равенству значений
SELECT s1.state AS s_a, s2.state AS s_b, s1.total - s2.total AS dif FROM s1, s2
WHERE s1.state != s2.state AND s1.total - s2.total < 1000



--                                      OUTER JOIN (внешнее соединение)

-- OUTER JOIN - Внешнее соединение, оно может быть трёх типов: левое LEFT, правое RIGHT и полное FULL. По умолчанию оно является полным. Оно обязательно возвращает все строки одной из таблиц (LEFT, RIGHT) или двух таблиц (FULL)


-- LEFT OUTER JOIN (внешнее левое соединение): возвращает все значения из левой таблицы, соединённые с соответствующими значениями из правой таблицы, там где они удовлетворяют условию соединения, а там где не удовлетворяют, будут значения из левой таблицы соединенные с значениями NULL
SELECT Tim.id, start, Sched.id, class FROM Tim LEFT JOIN Sched ON Sched.num = Tim.id;  -- В выборку попали все строки из левой таблицы Tim, дополненные данными из правой Sched там где Sched.num = Tim.id, а где нет этого соответсвия к данным левой таблицы в колонки соответсвующие правой таблице подставлены NULL

-- с функцией и GROUP BY
SELECT name, COUNT(Sched.id) AS amount FROM Teacher LEFT JOIN Sched ON Teacher.id = Sched.teacher GROUP BY Teacher.id

-- Получение данных, относящихся только к левой таблице(которые из правой дополнены значениями NULL):
SELECT * FROM left_tab LEFT JOIN right_tab USING(key) WHERE right_tab.key IS NULL


-- RIGHT OUTER JOIN (внешнее правое соединение): тоже что и левое только все значения возвращаются из правой, а из левой только соотв условию либо NULL


-- FULL OUTER JOIN (внешнее полное соединение):
-- 1. Формируется таблица на основе внутреннего соединения (INNER JOIN)
-- 2. В таблицу добавляются значения не вошедшие в результат формирования из левой таблицы (LEFT OUTER JOIN)
-- 3. В таблицу добавляются значения не вошедшие в результат формирования из правой таблицы (RIGHT OUTER JOIN)
-- Соединение FULL JOIN реализовано не во всех СУБД.(Есть: PostgreSQL; Нет: MySQL)
SELECT поля_таблиц FROM левая_таблица FULL JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ;
SELECT employee_name, department_name FROM employees e FULL OUTER JOIN departments d ON d.department_id = e.department_id;

-- Получение данных, не относящихся к левой и правой таблицам одновременно (обратное INNER JOIN):
SELECT поля_таблиц FROM левая_таблица FULL OUTER JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ
WHERE левая_таблица.ключ IS NULL OR правая_таблица.ключ IS NULL;



--                                                CROSS JOIN

-- СROSS - как декартово произведение(операция над множествами)
-- С каждой записью слева сопоставляем все записи справа

SELECT product_name, suppliers.company_name, units_in_stock FROM products CROSS JOIN suppliers; -- Услоаия соединения с ON не нужны, тк каждая строка одной таблицы объединяется с каждой из другой



--                                      SELF JOIN (Рекурсивное соединение)

-- SELF JOIN синтаксически пишется как любой вид джойна(INNER, OUTER). Используется тогода, когда нужно построить иерархию в запросе и соединить данные таблицы с другими данными той же самой таблицы

-- Например если у таблицы внешний ключ ссылается на первичный ключ в этой же таблице(но не обязательно ключи должны быть), то предполагается использование SELF JOIN.
-- У каждого работника может быть менеджер, но сам менеджер тоже работник и соотв тоже может иметь менеджера
CREATE TABLE employee (
	employee_id int PRIMARY KEY, name varchar(256) NOT NULL, manager_id int,
	FOREIGN KEY (manager_id) REFERENCES employee(employee_id); -- внешний ключ ссылается на первичный ключ в этой же таблице
);
INSERT INTO employee (employee_id, name, manager_id)
VALUES (1, 'Hays', NULL), (2, 'Lester', 1), (3, 'Conner', 1), (4, 'Reeves', 2), (5, 'Norman', 2), (6, 'Kels', 3), (7, 'Goff', 3);

SELECT e.name AS employee, m.name AS manager
FROM employee e LEFT JOIN employee m ON m.employee_id = e.manager_id;


-- Объединение с одной и тойже таблицей 2 раза, для того чтоб объединить ее по разным полям
SELECT u.unit_name || COALESCE('/' || u2.unit_name, '') AS dose_units FROM dose_records r
NATURAL JOIN drugs d
JOIN units u ON r.drug_unit_id = u.unit_id
LEFT JOIN units u2 ON r.check_unit_id = u2.unit_id



--                                                 Изучить

-- https://www.postgresql.org/docs/current/queries-table-expressions.html

-- Подзапросы с джойнами
FROM (SELECT * FROM table1) AS alias_name


-- LATERAL Подзапросы   -   CROSS JOIN LATERAL - вывод новых строк из одной строки
SELECT s.results FROM strings
CROSS JOIN LATERAL unnest(string_to_array(string, ' ')) AS s(results)  -- тут results название столбца на выходе а s - хз что (мб s(results) просто имя те скобки не функциональны ??)












--
