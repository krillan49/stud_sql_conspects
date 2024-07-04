-- Операции над множествами


--                                              UNION

-- UNION (Объединение запросов) - объединяет запросы в одну результирующую таблицу.
-- По умолчанию убирает повторения в результирующей таблице.
-- Не путайте операции объединения запросов с операциями объединения таблиц. Для этого служит оператор JOIN.
-- Чтобы UNION корректно сработал нужно чтобы результирующие таблицы каждого из SQL запросов имели одинаковое число столбцов, с одним и тем же типом данных и в той же самой последовательности.

SELECT good_name AS name FROM Goods
UNION
SELECT member_name AS name FROM Family;
-- в один столбец name попадут и имена членов семьи и названия товаров

-- UNION ALL не убирает дубликаты(не уберет дубликаты даже если добавить дистинкт в каждый запрос)
SELECT first_name, middle_name, last_name FROM Student
UNION ALL
SELECT first_name, middle_name, last_name FROM Teacher;
-- объединяем по столбцам ФИО строки данных учеников и учителей


-- INTERSECT (Пересечение запросов) Комбинирует два запроса SELECT, но возвращает только совпадающие записи первого и второго SELECT

SELECT country FROM customers
INTERSECT
SELECT country FROM suppliers


-- EXCEPT (Исключение/разница запросов) Комбинирует два запроса SELECT, но возвращает только те записи первого SELECT, которые не имеют совпадения во втором элементе SELECT. Тоесть есть разница какой запрос ставить 1м. По умолчанию накладывает дистинкт на 1й запрос

SELECT country
FROM customers
EXCEPT
SELECT country
FROM suppliers

-- EXCEPT ALL  - дистинкт не наложен ни на 1 запрос потому возвращает только те записи которых нет в том запросе, в котором есть меньше дубликатов этой записи. Тоесть большее число дубликатов минус меньшее
SELECT country
FROM customers
EXCEPT ALL
SELECT country
FROM suppliers



-- Этими операциями над множествами можно объединять более 2х запросов
SELECT country FROM customers
INTERSECT
SELECT country FROM suppliers
EXCEPT
SELECT country FROM employees










--
