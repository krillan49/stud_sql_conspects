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



--                                         WITH RECURSIVE [PostgreSQL]

-- WITH RECURSIVE - который присутствует в PostgreSQL (и в других серьёзных базах)  это скорее вычисление чего-то итерациями до того, как будет выполнено некоторое условие, чем классическая рекурсия

-- В PostgreSQL в рекурсивной части CTE обязательно должна быть стартовая часть и рекурсивная часть, разделенные словом UNION.
WITH RECURSIVE r AS (
  SELECT 1 AS i, 1 AS factorial                                        -- стартовая часть рекурсии (anchor)
  UNION
  SELECT i+1 AS i, factorial * (i+1) AS factorial FROM r WHERE i < 5   -- рекурсивная часть
)
SELECT * FROM r; -->
--  i  | factorial
-- ----+-----------
--   1 |         1
--   2 |         2
--   3 |         6
--   4 |        24
--   5 |       120

-- FROM r не выполняет весь запрос снова, а в первый раз берет то, что в стартовой части рекурсии (anchor), а в следующие итерации берет результаты предыдущей итерации.

-- Алгоритм:
-- 1. Берем стартовые данные
-- 2. подставляем в «рекурсивную» часть запроса.
-- 3. смотрим что получилось:
-- если результат рекурсивной части не пустой, то добавляем его в результирующую выборку, а также используем этот результат как данные для следующего вызова рекурсивной части;
-- если результат рекурсивной части пуст, то завершаем обработку


-- Возьмем выборку из дерева.
CREATE TABLE geo ( id int not null primary key, parent_id int references geo(id), name varchar(1000));
INSERT INTO geo (id, parent_id, name)
VALUES
(1, null, 'Планета Земля'),
(2, 1, 'Континент Евразия'),
(3, 1, 'Континент Северная Америка'),
(4, 2, 'Европа'),
(5, 4, 'Россия'),
(6, 4, 'Германия'),
(7, 5, 'Москва'),
(8, 5, 'Санкт-Петербург'),
(9, 6, 'Берлин');

-- Существует ограничение - рекурсия не должна использоваться в подзапросах.
-- Выбираем всё, что относится к Европе:
WITH RECURSIVE r AS (
  SELECT id, parent_id, name FROM geo WHERE parent_id = 4
  UNION
  SELECT id, parent_id, name FROM geo WHERE parent_id IN ( SELECT id FROM r )
)
SELECT * FROM r; --> ERROR:  recursive reference to query "r" must not appear within a subquery

-- перепишем на join:
WITH RECURSIVE r AS (
  SELECT id, parent_id, name FROM geo WHERE parent_id = 4
  UNION
  SELECT geo.id, geo.parent_id, geo.name FROM geo JOIN r ON geo.parent_id = r.id
)
SELECT * FROM r; -->
--  id | parent_id |      name
-- ----+-----------+-----------------
--   5 |         4 | Россия
--   6 |         4 | Германия
--   7 |         5 | Москва
--   8 |         5 | Санкт-Петербург
--   9 |         6 | Берлин

-- Еще пример. Можно, например выдать всё, что относится к Европе вместе с самой Европой, и еще посчитать уровень вложенности
WITH RECURSIVE r AS (
  SELECT id, parent_id, name, 1 AS level FROM geo WHERE id = 4
  UNION ALL
  SELECT geo.id, geo.parent_id, geo.name, r.level + 1 AS level FROM geo JOIN r ON geo.parent_id = r.id
)
SELECT * FROM r; -->
--  id | parent_id |      name       | level
-- ----+-----------+-----------------+-------
--   4 |         2 | Европа          |     1
--   5 |         4 | Россия          |     2
--   6 |         4 | Германия        |     2
--   7 |         5 | Москва          |     3
--   8 |         5 | Санкт-Петербург |     3
--   9 |         6 | Берлин          |     3


-- Пример с сотрудниками и менеджерами, где сотркдник может быть менеджером другому сотруднику
WITH RECURSIVE employee_levels AS (
  SELECT 1 AS level, id, first_name, last_name, manager_id FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT r.level + 1 AS level, e.id, e.first_name, e.last_name, e.manager_id
  FROM employees e JOIN employee_levels r ON e.manager_id = r.id
)
SELECT * FROM employee_levels ORDER BY level;

-- Тот же пример с сотрудниками и менеджерами, где сотркдник может быть менеджером другому сотруднику, но только вся цепочка менеджеров пишется в виде строки а не просто айди прямого менеджера
WITH RECURSIVE employee_levels AS (
  SELECT id, name, manager_id, '' AS management_chain FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.id, e.name, e.manager_id,
    CASE
      WHEN r.management_chain = '' THEN r.name || ' (' || r.id || ')'
      ELSE r.management_chain || ' -> ' || r.name || ' (' || r.id || ')'
    END AS management_chain
  FROM employees e JOIN employee_levels r ON e.manager_id = r.id
)
SELECT id, name, management_chain FROM employee_levels ORDER BY id;















--
