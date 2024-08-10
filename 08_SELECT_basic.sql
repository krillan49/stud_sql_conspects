--                                  Оператор выбора SELECT и сопутсвующие операторы

-- SELECT  -  выбирает данные, удовлетворяющие заданным условиям

SELECT 'Hello world';                -- можно выводить произвольные литералы
SELECT (5 * 2 - 6) / 2 AS Result;    -- можно выводить результаты арифметических действий, тут в столбец Result
SELECT (5 * 2 - 6) / 2 AS "Result";  -- (PostgreSQL) чтобы название столбца сохраняло регистр он должен быть в ""

-- * - оператор выбрать строки всех столбцов из таблицы. Не стоит использовать этот оператор в проде, тк запрос останется, а к таблице могут добавить столбцы, что может сказаться на скорости запроса при большом числе строк
SELECT * FROM Cars -- выбрать строки всех столбцов из таблицы "Cars"

-- Можно выбирать конкретные столбцы, указывая их имена через запятую, в любом порядке
SELECT name, Id FROM res     -- выбрать строки колонок "Id" и "name" из таблицы "res"

SELECT *, 'US' AS location FROM ussales  -- добавить новый столбец, тут с одинаковым литералом в запросе

-- (PostgreSQL ??) условие с = возвращает true или false
SELECT REVERSE(str) = str AS res FROM ispalindrome -- в столбце res будет true или false в зависимости соотв условию или нет
SELECT s ~ 'R' AND s ~ '(W|Y)' AND s ~ '[wens].*[wens].*[wens].*[RYW]' AS res FROM score  -- много условий через AND



--                                                AS - псевдонимы

-- AS - позволяет использовать псевдонимом таблицы или столбца, чтоб не писать длинное название или просто выбрать новое название. Псевдонимы могут содержать до 255 знаков.
SELECT 'Строка' AS String                      -- литерал "Строка" в столбце с псевдонимом String
SELECT member_name AS name FROM FamilyMembers  -- выводим поле с другим названием при помощи псевдонима
SELECT member_name name FROM FamilyMembers     -- AS писать не обязательно, можно просто через пробел

-- Псевдонимами столбцов не получится пользоваться в WHERE, тк когда оно отрабатывет псевдоним еще не назначен, тк SELECT работает после FROM и WHERE, но можно использовать в GROUP BY(только в случае псевдонимов не сгруппированных столбцов) и ORDER BY тк они работают после SELECT
SELECT category_id, SUM(units) AS units FROM products GROUP BY category_id ORDER BY units_in_stock;
-- Соответсвенно не можем использовать в HAVING псевдонимы, которые назначены после группировки
SELECT category_id, SUM(price * units) AS total_price FROM products
GROUP BY category_id HAVING SUM(price * units) > 5000
ORDER BY total_price DESC;

-- Псевдонимы таблиц
SELECT * FROM Customers C WHERE C.Id < 5       -- псевдоним таблицы, определение после FROM и использование с WHERE

SELECT name AS 'Имя' FROM people               -- [MySQL ?] псевдоним колонки name русским шрифтом
SELECT Tim.id 'tim.id' FROM Tim                -- [MySQL ?] вариант псевдонимов



--                                                  DISTINCT

-- DISTINCT (исключение дубликатов) - позволяет исключить одинаковые значения в выводе
-- Дубликаты исключаются из результата запроса, те DISTINCT исполняется после всех остальных действий, соотв можно провести сортировку, чтоб исключить в том порядке в котором надо

SELECT DISTINCT class FROM Student_in_class;       -- выбираем все уникальные значения столбца class, иключив все дубликаты
SELECT DISTINCT first_name, last_name FROM User;   -- применяя к нескольким столбцам исключаются только те строки в которых значения строк одинаковы во всех выбранных стобцах

-- DISTINCT ON (исключение дубликатов по столбцу) (возможно придется использовать в подзапросе, чтоб обработать рез потом)
SELECT DISTINCT ON(team) * FROM employees ORDER BY birth_date DESC          -- выбирает уникальные значения по столбцу, отсортированные по дате, тоесть выбраны уникальные team с самой большой датой (DISTINCT работает после сортировки)
SELECT DISTINCT ON(user_id, video_id) user_id, video_id FROM user_playlist  -- по нескольким столбцам


--                                                     LIMIT

-- LIMIT - позволяет извлечь определённый диапазон записей из одной или нескольких таблиц(пишется в самом конце запроса).
-- LIMIT реализован не во всех СУБД, например, в MSSQL для вывода записей с начала таблицы используется оператор TOP
SELECT capital FROM countries WHERE country LIKE 'E%' ORDER BY capital LIMIT 6;   -- выводит только 6 певых строк
SELECT * FROM Company LIMIT 2, 3;             -- выводит строки с 3й по 5ю(1я цифра число пропущеных строк, 2я число строк)
SELECT * FROM Company LIMIT 3 OFFSET 2;       -- альтернативный синтаксис того что выше
SELECT * FROM Company OFFSET 2;               -- выбираем все кроме 2х первых строк



--                                               Встроенные функции

-- Встроенная функция - это реализованный в СУБД кусок кода, выполняет преобразования данных в запросах. Может иметь 0 или несколько аргументов. Возвращает какой-то литерал.

-- Функции можно применять как к просто литералам, так и к значениям, взятым из таблицы. При этом функция выполняет преобразования для каждой строки отдельно.

-- Операции над результатом функции - тк каждая функция возвращает литерал, то её результат также можно использовать в дальнейших расчётах и преобразованиях при помощи функций.
SELECT UPPER(LEFT('sql-academy', 3)) AS str;             --> "SQL" выполняем UPPER над результатом функции LEFT



--                                      Функции для преобразования типов данных

SELECT CAST(id AS TEXT) AS textid FROM monsters;           -- преобразование типов данных(тут INTEGER в TEXT)
SELECT hits::FLOAT / at_bats AS average FROM yankees       -- [postgresql] преобразование типов данных(тут INTEGER в FLOAT)
SELECT (hits::FLOAT/at_bats)::TEXT AS average FROM yankees -- [postgresql] преобразование типов данных
::INET                                                     -- [PostgreSQL] преобразование айпиадреса в число, где последний член это единицы, предпоследний *256, 2й *256*256, 1й *256*256*256


--                                               Функции для строк

-- PostgreSQL, MySQL индексация строк начинается с 1, а не с 0. Таким образом, первый символ строки находится в позиции 1

SELECT UPPER("Hello world") AS upstring;        --> "HELLO WORLD". Возвращает строку в верхнем регистре в колонке upstring
SELECT LOWER('SQL Academy') AS lowstring;       --> "sql academy"  Возвращает строку в нижнем регистре в колонке lowstring
SELECT INSTR('sql-academy', 'academy') AS idx;  --> 5  Возвращает позицию первого символа подстроки в строке
SELECT POSITION('om' in 'Thomas') AS idx;       --> [PostgreSQL] 3 Возвращает позицию первого символа подстроки в строке
SELECT LENGTH('sql-academy') AS str_length;     --> 11 Возвращает длину указанной строки
SELECT LEFT('sql-academy', 3);                  --> "sql" Возвращает заданное количество крайних левых символов строки
SELECT RIGHT('XYZ', - 1)                        --> 'YZ'  оставляем все символы справа кроме первого
SELECT INITCAP(name) AS shortlist FROM elves    -- Capitalize name
SELECT REVERSE(chars) AS chars FROM monsters    -- реверсирует строку
SELECT REPEAT(name, 3) AS name FROM monsters    -- REPEAT(стобец, число повторений) - повторяет строковое значение.
SELECT CONCAT(first, '+', mid, 'k', last) AS title FROM names   -- объединение строковых значений столбцов в один столбец с добавлением доп строчных элементов
SELECT CONCAT_WS(' ', first, mid, last) AS title FROM names     -- тоже самое что и выше, но если между значениями нужен одинаковый элемент(тут пробел)
SELECT first_name || ' ' || last_name AS full_name FROM rentals -- [postgresql] тоже что и 2 выше
SELECT SPLIT_PART(chars, ',', 1) AS char FROM monsters          -- [postgresql] разбивает строку chars по ',' и выбирает 1й из разбитых кусков
SELECT SPLIT_PART(chars, ',', -1) AS char FROM monsters         -- [postgresql] последний элемент (работает только в новых версиях)
REPLACE('aca', 'a', 'b')                                        -- 'bcb' замена одиночных символов на другие одиночные('a' to 'b')
FORMAT('Hello, %s how are you doing today?', some)              -- подставит some в позицию %s (Создает строку по шаблону)
TRANSLATE(some, '123456789', '000011111')                       -- как tr в Руби

ASCII(char) -- PostgreSQL  получить код символа
CHR(num) -- PostgreSQL  получить символ из кода

-- PostgreSQL
SELECT SUBSTRING('PostgreSQL', 1, 5);   --> 'Postg' 1й аргумент стартовая позиция, 2й число элементов
SELECT SUBSTRING('PostgreSQL', 8);      --> 'SQL'  с 1м аргументом удаляет символы сначала
SELECT SUBSTRING('PostgreSQL' FROM 1 FOR 8), SUBSTRING('PostgreSQL' FROM 8)  -- полный синтаксис
SELECT SUBSTRING('The house number is 9001', '([0-9]{1,4})') AS house_no --> '9001'  с регуляркой
SELECT SUBSTRING('PostgreSQL' FROM '%#"S_L#"%' FOR '#'); --> 'SQL' скюэлевской регуляркой по типу LIKE


--                                               Регулярные выражения

-- string ~ regex  -  определяет строки соответсующие регулярке (в постгре регистр не учитывает ??)
SELECT city_name FROM stations WHERE city_name ~ '^[AEIOU]'        -- ищет совпадения с первой буквой из указанных

-- SUBSTRING(string FROM regex)   вырезать из строки по шаблону
SELECT SUBSTRING(greeting FROM '#\d+') AS user_id FROM greetings   -- Bienvenido tal #470815 BD.  ->  #470815

-- REGEXP_REPLACE(строка, регулярка, элемент замены, позиция(число, не обязательно))  -  заменить элементы строки
SELECT REGEXP_REPLACE('1, 4, и 10 числа', '\d','@','g') FROM dual       --> '@, @, и @@ числа' меняем любую цифру на @ ([postgresql] само меняет только 1й, нужно добавить 'g'; [ORACLE PL/SQL] - само меняет все цифры те флаг 'g' не нужен)
SELECT REGEXP_REPLACE(str, '[aeiou]', '', 'gi') AS res FROM disemvowel  -- 2 флага для регулярки
SELECT REGEXP_REPLACE('John Doe', '(.*) (.*)', '\2, \1');               --> 'Doe, John'
REGEXP_REPLACE(str, ('^' || n || '[aeiou]'), '', 'gi')                  -- с объединением в регулярку значения столбца

-- REGEXP_SPLIT_TO_TABLE(имя_столбца, регулярное_выражение) - сделать новые строки из подстрок строки разбитой по regex
SELECT REGEXP_SPLIT_TO_TABLE(str, '[aeiou]') AS results FROM random_string  -->  разбиваем строку по гласным(с их удалением) в столбец таблицы

-- REGEXP_COUNT(строка, шаблон [, start [, flags]]) — системная функция, подсчитывает количество мест, где шаблон регулярного выражения POSIX соответствует строке. start - считает начиная с этого индекса
REGEXP_COUNT('ABCABCAXYaxy', 'A.')         --> 3
REGEXP_COUNT('ABCABCAXYaxy', 'A.', 1, 'i') --> 4


--                                           Функции для даты и времени

-- YEAR/MONTH/DAY/HOUR/MINUTE возвращает год/месяц/... для указанной даты
SELECT YEAR("2022-06-16") AS year;                                --> 2022
SELECT EXTRACT(MONTH FROM payment_date) AS month FROM payment     -- [postgresql]  Для timestamp without time zone
EXTRACT(DOW FROM created_at)                                      -- dow - день недели 0 for Sunday, 1 for Monday, 6 for Saturday
TO_CHAR(rental_date, 'dy')                                        -- день недели: sun, mon, sat

CURRENT_TIMESTAMP - '2024-02-29 22:11:46 +0000'        --> (postgre) '49 days 14:20:38.369185' тип данных INTERVAL
CURRENT_DATE - '2024-02-29 22:11:46 +0000'             --> '8 days 01:48:14'  CURRENT_DATE - отнимает от начала дня
CURRENT_DATE - occurred_at                             --> вернет число дней интеджер
CURRENT_DATE - occurred_at < '90 days'                 --> true / false

cert_finish - CURRENT_DATE                                        -- вычитание дат по умолчанию вернет разницу в днях например 20
'2001-09-28' + INTERVAL '1 hour'                                  --> 2001-09-28 01:00:00
CURRENT_DATE - INTERVAL '60 years'                                --

order_time > CURRENT_TIMESTAMP - '1 hour' :: INTERVAL

AGE(birthdate)                                                    --> '60 years'   те число лет от даты до сейчас
AGE(birthdate) >= '60 years'                                      --> true    можно сравнивать

-- DATE_TRUNC(field, source [, time_zone ])  - Обрезка дат в [postgresql]
-- Значения для обрезки: microseconds milliseconds second minute hour day week month quarter year decade century millennium
SELECT DATE_TRUNC('hour', timestamp '2020-06-30 17:29:31');                  --> 2020-06-30 17:00:00 - все дальше часа будет нулями
SELECT DATE_TRUNC('hour', timestamp with time zone '2020-06-30 17:29:31+00') --> 2020-07-01 03:00:00+10
SELECT DATE_TRUNC('month', created_at)::DATE AS date FROM posts              -- пример с переводом в дату в конце
DATE_TRUNC('week', CURRENT_DATE - INTERVAL '1 week')                         -- предыдущая законченная неделя перед этой

-- DATEDIFF(interval, from, to): interval - дни/месяцы/годы. от даты from до даты to
SELECT DATEDIFF(DAY, OrderTime, DeliveryTime) AS AvDelTime FROM Orders         --> тут (day, OrderTime, DeliveryTime) расчет количества дней между OrderTime и DeliveryTime

DATE_PART('year', last)   -- извлекает год из даты в колонке last в виде числа

-- Аналог DATEDIFF для PostgreSQL
-- даты без времени отнимаются по умолчанию в днях без DATEDIFF/DATE_PART
DATE_PART('year', last) - DATE_PART('year', first)                       -- Years   == DATEDIFF(yy, first, last)
years_diff * 12 + (DATE_PART('month', last) - DATE_PART('month', first)) -- Months  == DATEDIFF(mm, first, last)
DATE_PART('day', last - first)                                           -- Days(день месяца)    == DATEDIFF(dd, first, last)
TRUNC(DATE_PART('day', last - start)/7)                                  -- Weeks   == DATEDIFF(wk, first, last)
days_diff * 24 + DATE_PART('hour', last - first )                        -- Hours   == DATEDIFF(hh, first, last)
hours_diff * 60 + DATE_PART('minute', last - first )                     -- Minutes == DATEDIFF(mi, first, last)
minutes_diff * 60 + DATE_PART('minute', last - first )                   -- Seconds == DATEDIFF(ss, first, last)

-- TIMESTAMPDIFF(SECOND, time_out, time_in) - среднее время в секундах между time_out и time_in
SELECT TIMESTAMPDIFF(SECOND, time_out, time_in) AS time FROM Trip               --> время полета

-- https://www.postgresql.org/docs/current/functions-formatting.html  Форматирование даты [postgresql]
TO_CHAR(timestamp, 'FMmonth, YYYY FMDD HH12:MI:SS')            --> 	february, 2023 19 12:00:00
TO_CHAR(timestamp, 'FMMonth, YYYY FMDD HH12:MI:SS')            --> 	February, 2023 19 12:00:00
TO_CHAR('2023-05-08 13:00:00 +0000', 'HH12AM:MI')              -->  01PM:00
TO_CHAR('2023-05-08 13:00:00 +0000', 'HH12:MI AM')             -->  01:00 PM
'FMDD "days and" FMHH24 "hours ago"'                           --  левый текст в форматировании вставляем в 2йных кавычках



--                                            Функции для чисел

SELECT LEAST(compasses, gears, tablets) AS small FROM some   -- [postgresql ??] выбирает наименьшее из значений
SELECT GREATEST(1, 2, 3)                                     -- [postgresql ??] выбирает наибольшее из значений(тут 3)

-- ROUND(22.29, 1) - 1й параметр флоат число, 2й число знаков до которых будет округление(без 2го параметра округляет до целого)
SELECT ROUND(22.29, 1);                                  --> 22.3
SELECT ROUND(22.29, -1)                                  --> 20
SELECT ROUND(salary)::FLOAT FROM job                     -- [PostgreSQL] округление и преобразование во флоат(из NUMERIC 0.29e0)
SELECT ROUND(val::NUMERIC, 2)::FLOAT FROM float8         -- [PostgreSQL] округление до 2х знаков необходимо переводить в NUMERIC если есть параметр(2)
SELECT FLOOR(hours * 0.5) FROM cycling                   -- округление вниз
SELECT CEIL(yr::FLOAT / 100) FROM years                  -- округление вверх

ABS(-5)                                                  -- 5
MOD(num, 2)                                              -- остаток от деления num на 2 (альтернатива % ??)
POWER(n, 3)::INT                                         -- [PostgreSQL ??] возведение в степень
SQRT(num)                                                -- [PostgreSQL ??] корень квадратный
GCD(1071, 462)                                           -- 21  Наибольший общий множитель

random() -- [PostgreSQL ??] генерит флоат от 0 до 1

factorial(n)                                             -- [PostgreSQL] считае факториал от n

-- https://www.postgresql.org/docs/16/functions-formatting.html
TO_CHAR(num, '99.99')                -- форматирование числел, тут до 2х знаков с обеих сторон (зачемто добавляет пробел вначале)
-- 9 - будет обрезан 0 в начале
-- 0 - не будет обрезан 0 в начале
TO_CHAR(num, 'FM999990.0%')         -- перевод в строку с определенным числом нулей после точки и еще всяким(тут символ %)



--                       Window Functions - для вывода новых колонок нумерации по определенному порядку

-- ROW_NUMBER() OVER(ORDER BY ...) - вывести новую колонку порядковых номеров по убыванию относительно значений указанной колонки
SELECT ROW_NUMBER() OVER(ORDER BY points DESC) AS rank FROM people;
SELECT ROW_NUMBER() OVER(ORDER BY SUM(points) DESC) AS rank FROM people GROUP BY some;   -- с группировкой

-- ROW_NUMBER() OVER(PARTITION BY ...)
ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY count(*) DESC, category.name DESC) AS category_rank  -- разбивка ранга по значениям столбца store_id (когда новое значения ранг начинается снова с 1 при каждом новом значении store_id)


-- RANK() OVER(ORDER BY ...) - работает так же как ROW_NUMBER() но при одинаковых значениях ставит одинаковый ранг. Дальнейший ранг учитывает все столбцы до, например 1, 1, 3
SELECT sale, RANK() OVER(ORDER BY sale DESC) AS srank FROM sales             -- создаем колонку рангов цен
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales  -- ранг по 2м полям, если 1е равно использует 2е
SELECT depname, empno, salary, RANK() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;
-- Разбивает ранк на подразделы по depname, те лоя каждого значения depname будет свой ранк(те с каждым новым значением depname, ранк заново считается с единицы)


-- DENSE_RANK() OVER(ORDER BY SUM(имя_колонки) DESC) - работает так же как ROW_NUMBER() только при одинаковых значениях ставит одинаковый ранг. Дальнейший ранг не учитывает все столбцы до, например 1, 1, 2


-- Делаем ранк нечетным (1, 3, 5 ...). Соотв четным без "- 1"
SELECT *, (ROW_NUMBER() OVER(ORDER BY birth_date DESC)) * 2 - 1 AS rank FROM employees













--
