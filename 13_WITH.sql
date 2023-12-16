--                                               WITH

-- WITH (Обобщённое табличное выражение или CTE - Common Table Expressions) - это временный набор данных, к которому можно обращаться в последующих запросах.
-- Выражение с WITH считается «временным», потому что результат не сохраняется где-либо на постоянной основе - в схеме базы данных
-- Оно доступно только во время выполнения операторов SELECT, INSERT, UPDATE, DELETE или MERGE. Оно действительно только в том запросе, которому он принадлежит
-- Главная задача – улучшение читабельности, простоты написания запросов и их дальнейшей поддержки.

WITH Aeroflot_trips AS
  (SELECT Trip.* FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot")
SELECT plane, COUNT(plane) AS amount FROM Aeroflot_trips GROUP BY plane; -- теперь мы можем использовать временную таблицу Aeroflot_trips созданную в WITH для запроса

-- С переименованием колонок
WITH Aeroflot_trips (aeroflot_plane, town_from, town_to) AS
  (SELECT plane, town_from, town_to FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot")
SELECT * FROM Aeroflot_trips;

-- Несколько табличных выражений записывается через запятую
WITH Aeroflot_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"),
  Don_avia_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Don_avia")
SELECT * FROM Don_avia_trips UNION SELECT * FROM  Aeroflot_trips;

-- 3е выражение использует для запроса 1е и 2е выражения
WITH Aeroflot_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"),
  Don_avia_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Don_avia"),
  Aeroflot_Don
  (SELECT * FROM Don_avia_trips UNION SELECT * FROM  Aeroflot_trips)
SELECT * FROM Aeroflot_Don WHERE id > 10




--  ?? Почемуто нельзя использовать как подзапрос(в постгрэ или везе ??) вот так
WITH p3 AS
  (SELECT DISTINCT customer_id FROM orders WHERE product_name = 'Product 3')
SELECT * FROM orders WHERE orders.customer_id NOT IN p3;













--
