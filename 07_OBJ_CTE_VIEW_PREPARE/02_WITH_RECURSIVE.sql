--                                        rCTE. WITH RECURSIVE [PostgreSQL]

-- RECURSIVE - это специальная возможность CTE(общих табличных выражений)

-- WITH RECURSIVE - который присутствует в PostgreSQL (и в других серьёзных базах), это скорее вычисление чего-то итерациями до того, как будет выполнено некоторое условие, чем классическая рекурсия

-- В PostgreSQL в рекурсивном CTE есть 2 компонента, разделенные ключевым словом UNION:
-- а. Стартовая часть / anchor  - создает подзапрос с начальными данными который именуется именем CTE
-- б. Рекурсивная часть         - создает подзапрос, который сначала использует anchor, а затем свою предыдущую итерацию. Выполняется циклично пока не будет возвращен пустой результат. Столбцы рекурсивной части должны соответсвовать столбцам стартовой части и иметь ту же последовательность написания
WITH RECURSIVE result AS (
  SELECT 1 AS i, 1 AS factorial                                            -- стартовая часть рекурсии (anchor)
  UNION
  SELECT i+1 AS i, factorial * (i+1) AS factorial FROM result WHERE i < 5  -- рекурсивная часть
  -- FROM result не выполняет весь запрос снова, в первой итерации берет то, что в стартовой части рекурсии (anchor), а в следующие итерации берет результат последней предыдущией итерации из рекурсивной части.
)
SELECT * FROM result; -->
--  i  | factorial
-- ----+-----------
--   1 |         1
--   2 |         2
--   3 |         6
--   4 |        24
--   5 |       120



--                             Алгоритм рекурсивного CTE. JOIN для рекурсивной части

-- 1. Берем стартовые данные (anchor)
-- 2. Подставляем в рекурсивную» часть запроса.
-- 3. В зависимости от результата рекурсивной части:
--    а. если результат рекурсивной части не пустой, то добавляем его в результирующую выборку, а также используем результат этой итерации как данные для следующего вызова рекурсивной части
--    б. если результат рекурсивной части пуст, то завершаем обработку


-- Подробный алгоритм на примере с сотрудниками и менеджерами. Таблица связанная рекурсивно сама с собой, как дерево:

-- Сотрудник может быть менеджером другому сотруднику, сотрудник у которого нет менеджера имеет в значении manager_id значение NULL, у каждого менеджера в подчинении могут быть как нескольео, так и ни одного сотрудкика, каждый из которых сам может быть менеджером сколькихто других сотрудников или не иметь подчиненных(тоесть одна из конечных веток этого дерева)

-- Можно выбрать только часть дерева, начиная с одного определенного сотрудника в стартовой части по его id, и далее все дерево его подчиненных
WITH RECURSIVE subordinates AS (
  -- 1. Стартовый запрос выполняется только 1 раз. При его выполнении будет получена только одна строка сотрудника с id 2
  -- а. этот результат будкт добавлен к общему результату всего CTE
  -- б. зта строка так же была помещена в subordinates, тоесть subordinates стала как бы таблицей с 1й этой строкой
  SELECT id, name FROM employees WHERE id = 2
  UNION
  -- 2. После того как был выполнен стартовый запрос начинает многократно выполняться рекурсивный запрос, до тех пор пока он не вернет пустой результат. Например при первом исполнении есть только один сотрудник - с id 2, мы берем эти данные и присоединяем строки всех сотрудников с manager_id равных 2, тоесть непосредственных подчиненных этого менеджера. Результат этого запроса будет набор строк сотрудников у которых manager_id = 2
  -- а. этот результат(набор строк) будет добавлен к общему результату всего CTE
  -- б. этот результат(набор строк) будет добавлен в subordinates, но перед этим из subordinates будет удалено все что там было до этого, тоесть subordinates стала как бы таблицей с набором строк где manager_id = 2
  -- 3. При следующем запуске рекурсивного запроса уже находим всех сотрудников, чей manager_id равен любому из id сотрудников из набора из пункта 2, тоесть их подчиненных итд
  -- 4. Когда при очередном запросе ни для одного из следующего набора менеджеров не будет больше сотрудников с соответсвующими manager_id и соответсвенно рекурсивный запрос вернет 0 строк - то выполнение всего CTE остановится
  SELECT id, name FROM subordinates r JOIN employees e ON r.id = e.manager_id
)
SELECT * FROM subordinates;



--                                     Ограничения для рекурсивной части

-- 1. В рекурсивной части не должны использоваться подзапросы
WITH RECURSIVE r AS (
  SELECT id, parent_id, name FROM geo WHERE parent_id = 4
  UNION
  SELECT id, parent_id, name FROM geo WHERE parent_id IN ( SELECT id FROM r )
)
SELECT * FROM r; --> ERROR:  recursive reference to query "r" must not appear within a subquery
-- Вместо этого принято использовать JOIN:
WITH RECURSIVE r AS (
  SELECT id, parent_id, name FROM geo WHERE parent_id = 4
  UNION
  SELECT geo.id, geo.parent_id, geo.name FROM geo JOIN r ON geo.parent_id = r.id
)
SELECT * FROM r;


-- 2. (?? Нельзя использовать агрегатные функции и группировку в рекурсивной части запроса ??)
WITH RECURSIVE r AS (
  SELECT manager_id, ARRAY_AGG(name ORDER BY id DESC) AS names
  FROM employees e WHERE manager_id = 1
  GROUP BY manager_id
  UNION ALL
  SELECT e.manager_id, ARRAY_AGG(e.name ORDER BY e.id DESC) AS names
  FROM employees e JOIN r ON e.manager_id = r.manager_id + 1
  GROUP BY e.manager_id
)
SELECT * FROM r; --> ERROR:  aggregate functions are not allowed in a recursive query's recursive term



--                                             WITH + WITH RECURSIVE

-- Если нужно для одного запроса получить как обычные, таки рекурсивные CTE, то ключевое слово WITH прописывается один раз, также нужно добавить к нему ключевое слово RECURSIVE вверху тоже один раз, тк WITH RECURSIVE может содержать как рекурсивные, так и обычные CTE. Можно чередовать рекурсивные и обычные CTE в любом порядке
WITH RECURSIVE
  cte1 AS (...),                              -- non-recursive
  cte2 AS (SELECT ... UNION ALL SELECT ...),  -- recursive
  cte3 AS (...)                               -- non-recursive
SELECT ... FROM cte3 WHERE ...
-- Другим эффектом RECURSIVE является то, что WITH запросы не обязательно должны быть упорядочены: запрос может ссылаться на другой запрос, который находится позже в списке. (Однако циклические ссылки или взаимная рекурсия не реализованы) Без RECURSIVE запросы WITH могут ссылаться только на WITH запросы того же уровня, которые находятся раньше в WITH списке.


-- Пример где 1й подзапрос не рекурсивный, с агрегацией - используется во 2м рекурсивном подзапросе:
WITH RECURSIVE
t AS
  (SELECT c.id AS category_id, parent, COUNT(i.id) AS items
  FROM categories c LEFT JOIN items i ON c.id = i.category_id
  GROUP BY c.id, parent ORDER BY category_id),
r AS (
  -- Для стартовом подзапроса берем результат подзапроса t (выше) и выводим строки всех категорий с их items(количество итемов)
  SELECT category_id AS id, category_id, parent, items FROM t -- дублируем category_id
  UNION ALL
  -- Добавляем родителей всех строк из набора предыдущей итерации, но оставляем id от предыдущей итерации(тоесть в итоге из самой первой), а все остальные колонки от родителя, тоесть получаем строку родителя с указателем на id строки в стартовом наборе
  SELECT id, t.category_id, t.parent, t.items FROM r JOIN t ON r.category_id = t.parent
)
-- В итоге получам кучу строк - всех родителей по цепочке для каждой строки изначальной таблицы(1й подзапрос) и суммируем все items, чтобы получить их суммы для каждой строки и каждого ее родителя по цепочке вверх
SELECT id, SUM(items) AS total FROM r GROUP BY id ORDER BY id;



--                                   Еще примеры с сотрудниками и менеджерами

-- Получить сотрудников этого менеджера не всех уровней подчинения, а только до определенных уровней (4)
WITH RECURSIVE subordinates AS (
  SELECT 1 AS level, id, name FROM employees WHERE id = 2
  UNION
  SELECT r.level + 1 AS level, id, name FROM subordinates r JOIN employees e ON r.id = e.manager_id
  WHERE r.level + 1 < 4  -- просто добавим условия проверяющее уровень
)
SELECT * FROM subordinates;


-- Выбираем от набора строк главных менеджеров(с NULL в manager_id), так же вернем с колонкой уровня менеджерства
WITH RECURSIVE employee_levels AS (
  SELECT 1 AS level, id, name, manager_id FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT r.level + 1 AS level, e.id, e.name, e.manager_id
  FROM employees e JOIN employee_levels r ON e.manager_id = r.id
)
SELECT * FROM employee_levels ORDER BY level;


-- Вся цепочка менеджеров пишется в виде строки а не просто id прямого менеджера
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


-- Обратный вариант от сотрудника(точки дерева) вверх вернем всю цепочку его начальников до самого главного босса
WITH RECURSIVE managers AS (
  -- Получим строку начального сотрудника(можно взять больше 1го, если хотим искать цепочки многих сотрудников) чью цепочку вышестоящих менеджеров хотим искать
  SELECT id, name, manager_id FROM employees WHERE id = 18
  UNION ALL
  -- Берем того сотрудника, что получили на предыдущем шаге и присоединяем изначальную таблицу и берем всех сотрудников(тут это будет 1 менеджер каждый раз) с тем id колторое соответсвует manager_id данных полученных от предыдущей итерации
  SELECT id, name, manager_id FROM managers m JOIN employees e ON e.id = m.manager_id
)
SELECT * FROM managers;


-- Пример с циклической связью(тоесть сотрудник может быть менеджером сам себе прямо или через цепочку менеджеров). Задача найти всех таких сотрудников и вывести их id и массив с цепочкой id цикла, где их id будет первым и последним
WITH RECURSIVE r AS (
  SELECT id AS r_id, id, manager_id, ARRAY[id] AS arr, 0 AS cycle FROM employees
  -- cycle переменная для того чтобы узнать есть уже цикл или нет и остановить рекурсию
  UNION ALL
  SELECT r_id, e.id, e.manager_id,
    ARRAY_APPEND(arr, e.id) AS arr,                   -- добавляем в массив id менеджера
    CASE WHEN e.id = r_id THEN 1 ELSE 0 END AS cycle  -- смотрим если айди этого сотрудника(менеджера к записи из предыдущей итерации) такое же как r_id тоесть как изначальное id одного из проверяемых сотрудников из стартового набора, то меняем значение cycle на 1, что значит цикл найден
  FROM employees e JOIN r ON e.manager_id = r.id
  WHERE r.cycle = 0 -- проверяем только те новые строки где cycle не равен 1, тоесть цикла еще нет
)
SELECT r_id AS id, arr AS cycle FROM r WHERE cycle = 1; -- отбираем только записи где цикл есть















--
