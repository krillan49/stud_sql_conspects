--                                        SELECT - оператор выбора

-- SELECT  -  выбирает заданные данные: столбцы таблицы, операции над столбцами или литералы и операции над ними

-- 1. Можно выводить произвольные литералы или операции между ними
SELECT 'Hello world', 3+2, 3=4;      --> 'Hello world'   5   FALSE

-- 2. * - оператор выбирает все столбцы из таблицы.
-- Не стоит использовать этот оператор в проде, тк запрос останется, а к таблице могут добавить столбцы, что может сказаться на скорости запроса при большом числе строк
SELECT * FROM сars;        -- выбрать все строки всех столбцов из таблицы "Cars"
SELECT * FROM public.сars; -- более общая форма записи названия таблицы с добавлением префикса схемы к которой она относится

-- 3. Можно выбирать конкретные столбцы, указывая их имена через запятую, в любом порядке. Можно дублировать вывод одних и тех же колонок сколько угодно раз.
SELECT name, id FROM res;                 -- выбрать строки колонок "id" и "name" из таблицы "res"
SELECT name, id, name, id, *, * FROM res; -- колонки "id" и "name" по два раза потом все колонки 2 раза

-- 4. Можно добавлять новые столбцы с одинаковыми литералами
SELECT *, 'US' AS location FROM ussales;

-- 5. Можно выводить в результирующий набор операции над столбцами или результаты применения встроенных или оконных функций
SELECT REVERSE(str) = str AS res FROM ispalindrome; -- в столбце res будет true или false в зависимости соотв условию или нет
SELECT s ~ 'R' AND s ~ '(W|Y)' AND s ~ '[wens].*[wens].*[wens].*[RYW]' AS res FROM score;  -- много условий через AND
















--