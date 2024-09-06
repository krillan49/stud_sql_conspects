--                                                  CTE. WITH

-- CTE(Common Table Expressions/Общее табличное выражение) - это временный набор данных, к которому можно обращаться в последующих запросах. Главная задача – улучшение читабельности запрса, простоты написания запросов и их дальнейшей поддержки, тк можем разбить большой запрос на отдельные позапросы

-- WITH - оператор для CTE
-- Выражение с WITH считается «временным», потому что результат не сохраняется где-либо на постоянной основе
-- Оно доступно только во время выполнения операторов SELECT, INSERT, UPDATE, DELETE или MERGE.
-- Выражение с WITH действительно только в том запросе, которому он принадлежит
-- Если позапросу дать название как у какой либо из таблиц(но лучше так не делать), то при обращении из запроса к этому имени использован будет подзапрос, а не таблица. Нельзя 2м подзапросам дать одно и тоже имя.

-- После WITH пишем название для позапроса AS и в скобках сам подзпрос
WITH aeroflot_trips AS (
  SELECT Trip.* FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"
)
-- теперь мы можем использовать временную таблицу aeroflot_trips созданную в WITH, вместо того чтоб писать подзапрос прямо тут
SELECT plane, COUNT(plane) AS amount FROM Aeroflot_trips GROUP BY plane;

-- Синтаксис с переименованием колонок в поле WITH
WITH Aeroflot_trips (aeroflot_plane, town_from, town_to) AS
  (SELECT plane, town_from, town_to FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot")
SELECT * FROM Aeroflot_trips;

-- Несколько табличных выражений записывается через запятую
WITH Aeroflot_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"),
  Don_avia_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Don_avia")
SELECT * FROM Don_avia_trips UNION SELECT * FROM  Aeroflot_trips;

-- 3е выражение использует для запроса 1е и 2е выражения. Тоесть одни подвыражения могут использовать предыдущие
WITH Aeroflot_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"),
  Don_avia_trips AS
  (SELECT Trip.* FROM Company INNER JOIN Trip ON Trip.company = Company.id WHERE name = "Don_avia"),
  Aeroflot_Don
  (SELECT * FROM Don_avia_trips UNION SELECT * FROM  Aeroflot_trips)
SELECT * FROM Aeroflot_Don WHERE id > 10;



--                                     Форматы исполнения подзапросов в PostgreSQL

-- Раньше в Постгресс на каждое табличное выражение создавалась временная таблица, затем выполнялся этот запрос CTE и его результат сохранялся в эту временную таблицу и так для каждого подзапроса после WITH, тоесть было бы созданно столько временных таблиц сколько подзапросов. И затем в основном запроса данные брались из этих временных таблиц и после завершения запроса все временные таблицы удалялись. Плюс тут в том что получаем данные из готовой таблицы и не нужно рпсчитывать подзапросы при исполнении основного запроса, тратя оперативную память. Но минус в том что таблицу нужно создать, наполнить данными и потом удалить

-- В более поздних версиях Постгрэ мы сами можем решать, создавать временную таблицу или расчитывать подзапросы находу, тоесть подставлять как обычные подзапросы:

-- 1. MATERIALIZED - если хотим создавать временные таблицы
WITH aeroflot_trips AS MATERIALIZED (
  SELECT Trip.* FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"
)

-- 2. NOT MATERIALIZED - если хотим подставлять CTE как обычные подзапросы
WITH aeroflot_trips AS NOT MATERIALIZED (
  SELECT Trip.* FROM Company JOIN Trip ON Trip.company = Company.id WHERE name = "Aeroflot"
)

-- Если мы явно не указываем [NOT] MATERIALIZED, то по умолчанию в Постресс - если CTE используется только 1 раз то он не материализуется, а если больше то материализуется















--
