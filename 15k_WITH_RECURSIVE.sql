--                                         WITH RECURSIVE [PostgreSQL]

-- WITH RECURSIVE - который присутствует в PostgreSQL (и в других серьёзных базах), это скорее вычисление чего-то итерациями до того, как будет выполнено некоторое условие, чем классическая рекурсия

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

-- FROM r не выполняет весь запрос снова, в первой итерации берет то, что в стартовой части рекурсии (anchor), а в следующие итерации берет результат каждой итерации из рекурсивной части.

-- Алгоритм:
-- 1. Берем стартовые данные
-- 2. Подставляем в «рекурсивную» часть запроса.
-- 3. В зависимости от результата рекурсивной части:
-- если результат рекурсивной части не пустой, то добавляем его в результирующую выборку, а также используем этот результат как данные для следующего вызова рекурсивной части;
-- если результат рекурсивной части пуст, то завершаем обработку


-- Возьмем выборку из дерева.
CREATE TABLE geo ( id int not null primary key, parent_id int references geo(id), name varchar(1000));
INSERT INTO geo (id, parent_id, name)
VALUES
(1, NULL, 'Планета Земля'),
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


-- Пример с сотрудниками и менеджерами, где сотрудник может быть менеджером другому сотруднику
WITH RECURSIVE employee_levels AS (
  SELECT 1 AS level, id, name, manager_id FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT r.level + 1 AS level, e.id, e.name, e.manager_id
  FROM employees e JOIN employee_levels r ON e.manager_id = r.id
)
SELECT * FROM employee_levels ORDER BY level;

-- Тот же пример с сотрудниками и менеджерами, где сотрудник может быть менеджером другому сотруднику, но только вся цепочка менеджеров пишется в виде строки а не просто айди прямого менеджера
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



-- ?? Нельзя использовать агрегатные функции в рекурсивной части запроса ??
WITH RECURSIVE r AS (
  SELECT
    manager_id,
    COUNT(id) AS total_subordinates,
    SUM(experience) / COUNT(id) AS average_experience,
    ARRAY_AGG(name ORDER BY id DESC) AS employee_names
  FROM employees e WHERE manager_id = 1
  GROUP BY manager_id

  UNION ALL
-- ERROR:  aggregate functions are not allowed in a recursive query's recursive term
  SELECT
    e.manager_id,
    COUNT(e.id) AS total_subordinates,
    SUM(e.experience) / COUNT(e.id) AS average_experience,
    ARRAY_AGG(e.name ORDER BY e.id DESC) AS employee_names
  FROM employees e JOIN r ON e.manager_id = r.manager_id + 1
  GROUP BY e.manager_id
)
SELECT * FROM r;















--
