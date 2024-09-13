--                                         WITH RECURSIVE [PostgreSQL]

-- WITH RECURSIVE - который присутствует в PostgreSQL (и в других серьёзных базах), это скорее вычисление чего-то итерациями до того, как будет выполнено некоторое условие, чем классическая рекурсия
-- RECURSIVE тут это специальная возможность CTE(общих табличных выражений)

-- В PostgreSQL в рекурсивной части CTE обязательно должна быть стартовая часть и рекурсивная часть, разделенные словом UNION.
WITH RECURSIVE result AS (
  SELECT 1 AS i, 1 AS factorial                                        -- стартовая часть рекурсии (anchor)
  UNION
  SELECT i+1 AS i, factorial * (i+1) AS factorial FROM result WHERE i < 5   -- рекурсивная часть, выполняется циклично пока не будет возвращен пустой результат. В ней мы запрашиваем данные из result, но такой таблицы не существует
)
SELECT * FROM result; -->
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



-- Примеры с сотрудниками и менеджерами, где сотрудник может быть менеджером другому сотруднику, сотрудник у которого нет менеджера имеет в значении manager_id значение NULL, у каждого менеджера в подчинении могут быть как нескольео, так и ни одного сотрудкика, каждый из которых сам может быть менеджером сколькихто других сотрудников или не иметь подчиненных(тоесть одна из конечных веток этого дерева)

-- Или например можем выбрать только часть дерева, начиная с обределенного сотрудника по его id, и далее все дерево его подчиненных
WITH RECURSIVE subordinates AS (
  -- 1. Стартовый запрос выполняется только 1 раз. При его выполнении будет получена только одна строка сотрудника с айди 2
  -- а. этот результат будкт добавлен к общему результату всего CTE
  -- б. зта строка так же была помещена в subordinates, тоесть subordinates стала как бы таблицей с 1й этой строкой
  SELECT id, name FROM employees WHERE id = 2
  UNION
  -- 2. После того как был выполнен стартовый запрос начинает многократно выполняться рекурсивный запрос, до тех пор пока он не вернет пустой результат. Например при первом исполнении есть только один сотрудник с айди 2, мы берем эти данные и присоединяем строки всех сотрудников с менеджер айди равных 2, тоесть непосредственных подчиненных этого менеджера. Результат этого запроса будет набор строк сотрудников manager_id = 2
  -- а. этот результат(набор строк) будкт добавлен к общему результату всего CTE
  -- б. этот результат(набор строк) будкт добавлен в subordinates, но при этом из subordinates будет удалено все что там было до этого, тоесть subordinates стала как бы таблицей с набором строк где manager_id = 2
  -- 3. При следующем запуске рекурсивного запроса уже находим всех сотрудников, чей manager_id равен айдишникам сотрудников из набора из пункта 2, тоесть их подчиненных итд
  -- 4. Когда при очередном запросе ни для одного из следующего набора менеджеров не будет больше сотрудников с соответсвующими manager_id и соответсвенно рекурсивный запрос вернет 0 строк и выполнение всего CTE остановится
  SELECT id, name FROM subordinates r JOIN employees e ON r.id = e.manager_id
)
SELECT * FROM subordinates;

-- Тоже но нужно получить сотрудников этого менеджера не всех уровней подчинения а только до определенных уровней (4)
WITH RECURSIVE subordinates AS (
  SELECT 1 AS level, id, name FROM employees WHERE id = 2
  UNION
  SELECT r.level + 1 AS level, id, name FROM subordinates r JOIN employees e ON r.id = e.manager_id
  WHERE r.level + 1 < 4
)
SELECT * FROM subordinates;

-- Тут выбираем от менеджеров с NULL в manager_id, так же вернем с колонкой уровня менеджерства
WITH RECURSIVE employee_levels AS (
  SELECT 1 AS level, id, name, manager_id FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT r.level + 1 AS level, e.id, e.name, e.manager_id
  FROM employees e JOIN employee_levels r ON e.manager_id = r.id
)
SELECT * FROM employee_levels ORDER BY level;

-- обратный вариант от сотрудника(точки дерева) вверх вернем всю цепочку его начальников до самого главного босса
WITH RECURSIVE managers AS (
  -- Получим строку начального сотрудника чью цепочку вышестоящих менеджеров хотим искать
  SELECT id, name, manager_id FROM employees WHERE id = 18
  UNION ALL
  -- Берем того сотрудника, что получили на предыдущем шаге и присоединяем изначальную таблицу и берем всех сотрудников(тут это будет 1 менеджер каждый раз) с тем айди колторое соответсвует manager_id данных полученных от предыдущей итерации
  SELECT id, name, manager_id FROM managers m JOIN employees e ON e.id = m.manager_id
)
SELECT * FROM managers;


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
