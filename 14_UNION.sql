--                                              UNION

-- UNION (Объединение запросов) - объединяет запросы в одну результирующую таблицу.
-- По умолчанию убирает повторения в результирующей таблице.
-- Не путайте операции объединения запросов с операциями объединения таблиц. Для этого служит оператор JOIN.
-- Чтобы UNION корректно сработал нужно чтобы результирующие таблицы каждого из SQL запросов имели одинаковое число столбцов, с одним и тем же типом данных и в той же самой последовательности.

SELECT good_name AS name FROM Goods
UNION 
SELECT member_name AS name FROM Family;
-- в один столбец name попадут и имена членов семьи и названия товаров

SELECT first_name, middle_name, last_name FROM Student
UNION
SELECT first_name, middle_name, last_name FROM Teacher;
-- объединяем по столбцам ФИО строки данных учеников и учителей


-- UNION ALL не убирает дубликаты


-- INTERSECT Комбинирует два запроса SELECT, но возвращает записи только первого SELECT, которые имеют совпадения во втором элементе SELECT.(работает как UNION ??)


-- EXCEPT Комбинирует два запроса SELECT, но возвращает записи только первого SELECT, которые не имеют совпадения во втором элементе SELECT.(работает как UNION ??)










--
