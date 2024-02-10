--                                         Многотабличные запрсы. JOIN

-- имя_таблицы.имя_столбца: позволяет при работе с несколькими таблицами выбирать столбцы из определенных таблиц, удобно при одинаковых названиях в разных таблицах
SELECT Customers.Id FROM Customers WHERE Customers.id < 5

-- JOIN - оператор многотабличного запроса - позволяет делать выборку из нескольких таблиц, объединяя данные из них в одном запросе, те позволяют нам «соединять» строки нескольких таблиц вместе.

-- Соединение бывает:
-- INNER - внутреннее соединение (по умолчанию)
-- OUTER - внешнее соединение. Оно делится на левое LEFT, правое RIGHT и полное FULL

-- ON - оператор после кторого пишется условие о том как именно записи из разных таблиц должны находить друг друга(как они соответствуют друг другу)



--                                         INNER JOIN (внутреннее соединение)

-- INNER в запросе писать не обязательно тк это значение по умолчанию

-- Внутреннее соединение - находятся пары записей из двух таблиц, удовлетворяющие условию соединения, тем самым образуя новую таблицу, содержащую поля из первой и второй исходных таблиц. Например если нашем условии указано равенство значений в полях A.good_id и B.id, то при внутреннем соединении в итоговой выборке окажутся только записи, где в обоих таблицах есть одинаковое значения в good_id и id.

SELECT * FROM Cus INNER JOIN Ord ON Ord.Nid = Cus.id       -- выбираем те строки таблиц Cus и Ord в которых Ord.Nid = Cus.id
SELECT prod.*, comp.name AS name FROM prod JOIN comp ON prod.comp_id = comp.id  -- выбираем из 1й таблицы все, а из 2й одну колонку

-- Можно не писать имена таблиц тк колонки называются по разному (1)
SELECT member, name FROM Pay JOIN Family ON Pay.id = Family.m_id -- колонка member из таблицы Pay, а колонка name из таблицы Family

-- INNER JOIN + псевдонимы + WHERE
SELECT * FROM Customers C JOIN Orders O ON O.CustId = C.Id WHERE O.Total > 200

-- объединение 3х таблиц
SELECT Class.name, S_in_c.student, Student.name
FROM Class JOIN S_in_c ON Class.id = S_in_c.class JOIN Student ON S_in_c.student = Student.id

-- INNER JOIN + GROUP BY
SELECT people.*, COUNT(*) AS count FROM toys JOIN people ON people.id = toys.people_id GROUP BY people.id  -- с функцией для toys
SELECT Res.room_id, AVG(Rev.rating) AS score FROM Res JOIN Rev ON Res.id = Rev.res_id GROUP BY Res.room_id
-- выбираем Res.room_id и средние значения Rev.rating для каждого Res.room_id при помощи группировки по Res.room_id из объединенных таблиц Res и Rev

-- Использование псевдонимов чтобы группировать одну таблицу саму с собой
SELECT managers.id, managers.name FROM employees managers JOIN employees subordinates



--                                        Несколько условий соединения

-- В условии соединения могут использоваться несколько соответсвий и логические операторы: AND, OR, NOT.

-- Запись в rank идентифицируется составным суррогатным ключом (store_id, rank_id). Т.е. чтобы найти информацию о должности сотрудника, нужно из таблицы rank взять строку с таким же идентификатором магазина и идентификатором должности в магазине.
SELECT e.first_name, e.last_name, r.rank_id, r.store_id, r.name
FROM e JOIN rank r ON r.rank_id = e.rank_id AND r.store_id = e.store_id



--                                                    USING

-- USING вместо ON и сравнения - если столбец по значениям которого объединяем в обоих таблицах называется одинаково ??
SELECT film_id, title, popularity FROM film
JOIN film_category USING (film_id)
JOIN category ON film_category.category_id = category.category_id AND name = 'Children'
JOIN inventory USING (film_id)
-- AND name = 'Children'  - дополнительная выборка в присоединяемой таблице, удобно для многотабличных джойнов



--                            Таблицы через запятую вместо INNER JOIN и WHERE вместо ON

-- Если после FROM перечислить названия нескольких таблиц через запятую, то выберет все данные одной таблицы для каждого элемента другой и наоборот, те будет огромная таблица хз чего
SELECT * FROM people, toys

-- (АЛЬТЕРНАТИВА INNER JOIN ON) Перечисление таблиц через запятую вместо INNER JOIN и WHERE вместо ON
SELECT member, name FROM Pay, Family WHERE Pay.member = Family.member_id           --  тот же запрос что и выше (1)
SELECT people.*, toys.toy_count FROM people, toys WHERE people.id = toys.people_id



--                                      OUTER JOIN (внешнее соединение)

-- OUTER JOIN - Внешнее соединение, оно может быть трёх типов: левое LEFT, правое RIGHT и полное FULL. По умолчанию оно является полным. Оно обязательно возвращает все строки одной из таблиц (LEFT, RIGHT) или двух таблиц (FULL)


-- LEFT OUTER JOIN (внешнее левое соединение): возвращает все значения из левой таблицы, соединённые с соответствующими значениями из правой таблицы, там где они удовлетворяют условию соединения, а там где не удовлетворяют, будут значения из левой таблицы соединенные с значениями NULL
SELECT Tim.id, start, Sched.id, class FROM Tim LEFT JOIN Sched ON Sched.num = Tim.id;  -- В выборку попали все строки из левой таблицы Tim, дополненные данными из правой Sched там где Sched.num = Tim.id, где нет в колонки правой таблицы проставлены NULL

-- с функцией и GROUP BY
SELECT name, COUNT(Sched.id) AS amount FROM Teacher LEFT JOIN Sched ON Teacher.id = Sched.teacher GROUP BY Teacher.id

-- Получение данных, относящихся только к левой таблице(которые из правой дополнены значениями NULL):
SELECT * FROM left_tab LEFT JOIN right_tab ON left_tab.ключ = right_tab.ключ WHERE right_tab.ключ IS NULL


-- RIGHT OUTER JOIN (внешнее правое соединение): тоже что и левое только все значения возвращаются из правой, а из левой только соотв условию либо NULL


-- FULL OUTER JOIN (внешнее полное соединение):
-- 1. Формируется таблица на основе внутреннего соединения (INNER JOIN)
-- 2. В таблицу добавляются значения не вошедшие в результат формирования из левой таблицы (LEFT OUTER JOIN)
-- 3. В таблицу добавляются значения не вошедшие в результат формирования из правой таблицы (RIGHT OUTER JOIN)
-- Соединение FULL JOIN реализовано не во всех СУБД. Например, в MySQL оно отсутствует

SELECT поля_таблиц FROM левая_таблица FULL OUTER JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ

-- Получение данных, не относящихся к левой и правой таблицам одновременно (обратное INNER JOIN):
SELECT поля_таблиц FROM левая_таблица FULL OUTER JOIN правая_таблица ON правая_таблица.ключ = левая_таблица.ключ WHERE левая_таблица.ключ IS NULL OR правая_таблица.ключ IS NULL



--                                                 Изучить

-- https://www.postgresql.org/docs/current/queries-table-expressions.html

-- Подзапросы с джойнами
FROM (SELECT * FROM table1) AS alias_name

-- LATERALПодзапросы   -   CROSS JOIN LATERAL - вывод новых строк из одной строки
SELECT s.results FROM strings
CROSS JOIN LATERAL unnest(string_to_array(string, ' ')) AS s(results)  -- тут results название столбца на выходе а s - хз что (мб s(results) просто имя те скобки не функциональны ??)



-- NATURAL JOIN
-- Объединение с одной и тойже таблицей 2 раза, для того чтоб объединить ее по разным полям
SELECT u.unit_name || COALESCE('/' || u2.unit_name, '') AS dose_units FROM dose_records r
NATURAL JOIN drugs d -- natural join втф что это??
JOIN units u ON r.drug_unit_id = u.unit_id
LEFT JOIN units u2 ON r.check_unit_id = u2.unit_id











--
