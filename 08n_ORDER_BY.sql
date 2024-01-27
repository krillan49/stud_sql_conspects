--                                     ORDER BY [ASC | DESC] (порядок/сортировка)

-- ORDER BY позволяет вывести строки по определенному(по умолчанию от наименьшего) порядку(например значений некого столбца)
-- ORDER BY пишется после WHERE и после GROUP_BY но перед LIMIT
-- Можно сортировать по колонкам таблицы, которые не выводятся данным запросом

-- DESC - порядок сортировки по убыванию
-- ASC - порядок сортировки по возрастанию(значение по умолчанию)

SELECT name FROM Company ORDER BY name;             -- сортируем строки по значениям столбца name
SELECT * FROM Orders WHERE sum > 50 ORDER BY timeA; -- отображаем порядок строк по значениям столбца "timeA"
SELECT * FROM Orders ORDER BY DeliveryTime DESC;    -- с указанием порядка по убыванию
SELECT * FROM Orders ORDER BY sum DESC, timeA ASC;  -- сортируем по 2м столбцам - при равенстве значений в 1м, сортирует по 2му итд
SELECT * FROM companies ORDER BY 4;                 -- используем номер колонки вместо названия(сортируем по 4й колонке)



-- https://www.geeksforgeeks.org/how-to-custom-sort-in-sql-order-by-clause/  - сортировка с условным операторам CASE
ORDER BY CASE WHEN sex = 'Male' THEN 1 WHEN sex = 'Female' THEN 2 ELSE 3 END


-- Сорьтровка по условию
select * from employees where team = 'backend' order by least(
  2 * row_number() over (order by birth_date desc) - 1,
  2 * row_number() over (order by birth_date)
)
















-- 
