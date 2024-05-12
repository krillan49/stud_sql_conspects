--                                     ORDER BY [ASC | DESC] (порядок/сортировка)

-- ORDER BY позволяет вывести строки по определенному(по умолчанию от наименьшего) порядку(например значений некого столбца)
-- ORDER BY пишется после WHERE и после GROUP_BY но перед LIMIT
-- Можно сортировать по колонкам таблицы, которые не выводятся данным запросом

-- DESC - порядок сортировки по убыванию
-- ASC - порядок сортировки по возрастанию(значение по умолчанию)

SELECT * FROM Orders WHERE sum > 50 ORDER BY timeA; -- отображаем порядок строк по значениям столбца "timeA"
SELECT * FROM Orders ORDER BY DeliveryTime DESC;    -- с указанием порядка по убыванию
SELECT * FROM Orders ORDER BY sum DESC, timeA ASC;  -- сортируем по 2м столбцам - при равенстве значений в 1м, сортирует по 2му итд
SELECT * FROM companies ORDER BY 4;                 -- используем номер колонки вместо названия(сортируем по 4й колонке)



--                                          Сортировка по условию CASE

-- Сортировка с условным операторам CASE позволяет заменить для сортировки значения столбцов на более удобные для сортировки в необходимом порядке значения
SELECT * FROM students ORDER BY CASE WHEN sex = 'Male' THEN 1 WHEN sex = 'Female' THEN 2 ELSE 3 END
-- тут если сортировать 'Male', 'Female' и 'Trans', то ASC нам даст 'Female', 'Male', 'Trans', DESC соотв наоборот, но нам нужен другой определенный порядок



--                                        Сортировка по ROW_NUMBER()

-- Сортировка по ROW_NUMBER() чтобы не создавать предварительно саму колонку ROW_NUMBER(), если она не нужна
SELECT id, is_return FROM orders ORDER BY ROW_NUMBER() OVER (PARTITION BY is_return ORDER BY id DESC)


-- Сортировка по меньшему значению из 2х ROW_NUMBER()
SELECT * FROM employees WHERE team = 'backend'
ORDER BY LEAST(2 * ROW_NUMBER() OVER (ORDER BY birth_date DESC) - 1, 2 * ROW_NUMBER() OVER (ORDER BY birth_date))



















--
