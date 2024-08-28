--                                     ORDER BY [ASC | DESC] (порядок/сортировка)

-- Если не задавать сортировку явно, то мы не можем быть на 100% уверенны, что записи будут выданы отсортированными по айди

-- ORDER BY позволяет вывести строки по определенному(по умолчанию от наименьшего) порядку(например значений некого столбца)
-- ORDER BY пишется после WHERE и после GROUP_BY но перед LIMIT
-- Можно сортировать по колонкам таблицы, которые не выводятся данным запросом

-- DESC - порядок сортировки по убыванию
-- ASC - порядок сортировки по возрастанию(значение по умолчанию)

SELECT * FROM Orders WHERE sum > 50 ORDER BY timeA; -- отображаем порядок строк по значениям столбца "timeA"
SELECT * FROM Orders ORDER BY DeliveryTime DESC;    -- с указанием порядка по убыванию

-- сортируем по 2м столбцам - при равенстве значений в 1м, сортирует по 2му итд
SELECT * FROM Orders ORDER BY sum DESC, timeA ASC;

-- Можем сортировать по псевдонимам
SELECT name f, second_name s FROM actors ORDER BY f, s DESC;

-- используем номер колонки в таблице вместо названия(сортируем по 4й колонке)
SELECT * FROM companies ORDER BY 1, 4 DESC;

-- можно комбинировать все виды способов сортировки
SELECT name f, second_name s FROM actors ORDER BY name, s DESC, 3 ASC;



--                                             Сортировка и NULL

-- NULL значения считаются самыми большими и при сортировке по возрастанию попадают в самый конец, а по убыванию в начало

-- Если хотим изменить расположение NULL, то дописваем до опцию к колонке:
SELECT * FROM actors ORDER BY name NULLS FIRST;  -- сортирует по возрастанию, но NULL будет в начале
SELECT * FROM actors ORDER BY name DESC NULLS LAST;  -- сортирует по убыванию, но NULL будет в конце



--                                           Сортировка по выражению

-- Невозможно сортировать по выражениям от псевдонимов, ORDER BY f || s, или номеров колонок ORDER BY 1 || 2, Постгрэ выдаст ошибку

SELECT * FROM actors ORDER BY name || second_name; -- сортируем по имени и фамилии при помощи объединения их в одну строку, что будет аналогом для сортировки ORDER BY name, second_name
SELECT * FROM actors ORDER BY mod(actor_id, 10); -- сортируем по последней цифре айди при помощи деления с остатком на 10
SELECT * FROM actors ORDER BY name || second_name DESC, mod(actor_id, 10); -- по нескольким выражениям

-- Сортировка по рандомному полю?
SELECT id, fg, yu
FROM s
ORDER BY RANDOM();



--                                        Сортировка по ROW_NUMBER()

-- Сортировка по ROW_NUMBER() чтобы не создавать предварительно саму колонку ROW_NUMBER(), если она не нужна
SELECT id, is_return FROM orders ORDER BY ROW_NUMBER() OVER (PARTITION BY is_return ORDER BY id DESC)


-- Сортировка по меньшему значению из 2х ROW_NUMBER()
SELECT * FROM employees WHERE team = 'backend'
ORDER BY LEAST(2 * ROW_NUMBER() OVER (ORDER BY birth_date DESC) - 1, 2 * ROW_NUMBER() OVER (ORDER BY birth_date))



--                                          Сортировка по условию CASE

-- Сортировка с условным операторам CASE позволяет заменить для сортировки значения столбцов на более удобные для сортировки в необходимом порядке значения
SELECT * FROM students ORDER BY CASE WHEN sex = 'Male' THEN 1 WHEN sex = 'Female' THEN 2 ELSE 3 END
-- тут если сортировать 'Male', 'Female' и 'Trans', то ASC нам даст 'Female', 'Male', 'Trans', DESC соотв наоборот, но нам нужен другой определенный порядок

















--
