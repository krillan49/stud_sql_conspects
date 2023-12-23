--                                  Оператор выбора SELECT и сопутсвующие операторы

-- SELECT  -  выбирает данные, удовлетворяющие заданным условиям

SELECT "Hello world"                -- "Hello world"  можно выводить данные не только из таблиц, но и произвольные литералы
SELECT (5 * 2 - 6) / 2 AS Result;   -- можно выводить результаты арифметических действий, тут в столбец Result
SELECT (5 * 2 - 6) / 2 AS "Result"; -- (PostgreSQL) чтобы название столбца сохраняло регистр он должен быть в ""

SELECT * FROM Cars                      -- выбрать строки всех(*) столбцов из таблицы "Cars"
SELECT Id, FirstName FROM Customers     -- выбрать строки столбцов "Id" и "FirstName" из таблицы "Customers"  (можно выбирать столбцы в любом порядке)

SELECT *, 'US' AS location FROM ussales  -- если нужно добавить новый столбец в запросе

-- (постгрэ ??) условие с = возвращает true или false
SELECT REVERSE(str) = str AS res FROM ispalindrome -- в столбце res будет true или false в зависимости соотв условию или нет



--                                                AS - псевдонимы

-- AS - позволяет использовать псевдонимом таблицы или столбца, чтоб не писать длинное название или просто выбрать новое название. Псевдонимы могут содержать до 255 знаков.
SELECT "Строка" AS String                      -- литерал "Строка" в столбце с псевдонимом String
SELECT member_name AS Name FROM FamilyMembers  -- выводим поле с другим названием при помощи псевдонима
SELECT member_name Name FROM FamilyMembers     -- AS писать не обязательно, можно просто через пробел
SELECT * FROM Customers C WHERE C.Id < 5       -- псевдоним таблицы, определение после FROM и использование с WHERE
SELECT name AS 'Имя' FROM people               -- [MySQL ?] псевдоним колонки name русским шрифтом
SELECT Tim.id 'tim.id' FROM Tim                -- [MySQL ?] вариант псевдонимов



--                                               Встроенные функции

-- Встроенная функция - это реализованный в СУБД кусок кода, выполняет преобразования данных в запросах. Может иметь 0 или несколько аргументов. Возвращает какой-то литерал.

-- Функции можно применять как к просто литералам, так и к значениям, взятым из таблицы(обязательны псевдонимы для столбцов). При этом функция выполняет преобразования для каждой строки отдельно.

-- Операции над результатом функции - тк каждая функция возвращает литерал, то её результат также можно использовать в дальнейших расчётах и преобразованиях при помощи функций.
SELECT UPPER(LEFT('sql-academy', 3)) AS str;             --> "SQL" выполняем UPPER над результатом функции LEFT


-- Функции для строковых значений:
SELECT UPPER("Hello world") AS upstring;        --> "HELLO WORLD". Возвращает строку в верхнем регистре в колонке upstring
SELECT LOWER('SQL Academy') AS lowstring;       --> "sql academy"  Возвращает строку в нижнем регистре в колонке lowstring
SELECT INSTR('sql-academy', 'academy') AS idx;  --> 5  Возвращая позицию первого символа подстроки в строке (отсчёт начинается с единицы)
SELECT LENGTH('sql-academy') AS str_length;     --> 11 Возвращает длину указанной строки
SELECT LEFT('sql-academy', 3);                  --> "sql" Возвращает заданное количество крайних левых символов строки
SELECT RIGHT('XYZ', - 1)                        --> 'YZ'  Обрезка с отрицательным индексом соотв тут оставляем все символы справа кроме первого
SELECT INITCAP(name) AS shortlist FROM elves    -- capitalize name
SELECT REVERSE(chars) AS chars FROM monsters    -- реверсирует строку
SELECT REPEAT(name, 3) AS name FROM monsters    -- REPEAT(стобец, число повторений) - повторяет строковое значение.
SELECT CONCAT(first, '+', mid, 'k', last) AS title FROM names   -- объединение строковых значений столбцов в один столбец с добавлением доп строчных элементов
SELECT CONCAT_WS(' ', first, mid, last) AS title FROM names     -- тоже самое что и выше, но если между значениями нужен одинаковый элемент(тут пробел)
SELECT first_name || ' ' || last_name AS full_name FROM rentals -- [postgresql ??] тоже что и 2 выше
SELECT SPLIT_PART(chars, ',', 1) AS char FROM monsters          -- [postgresql ??] разбивает строку chars по ',' и выбирает 1й из разбитых кусков
REPLACE(x, 'a', 'b')                    -- замена одиночных символов на другие одиночные('a' to 'b')
FORMAT('Hello, %s how are you doing today?', some)  -- подставит some в позицию %s

TRANSLATE(some, '123456789', '000011111')    -- как tr в Руби

-- PostgreSQL индексация строк начинается с 1, а не с 0. Таким образом, первый символ строки находится в позиции 1

ASCII(char) -- PostgreSQL  получить код символа
CHR(num) -- PostgreSQL  получить символ из кода



-- Регулярные выражения:
SELECT city_name FROM stations WHERE city_name ~ '^[AEIOU]'  -- ищем соотв значения(тут с первой буквой из указанных) (в постгре регистр не учитывает ??)

-- SUBSTRING(имя_столбца FROM 'регулярное_выражение')   вырезать из строки по шаблону
SELECT SUBSTRING(greeting FROM '#\d+') AS user_id FROM greetings   -- Bienvenido tal #470815 BD.  ->  #470815

-- REGEXP_REPLACE(строка, регулярка, элемент замены, позиция(число, не обязательно))  -  заменить элементы строки
SELECT REGEXP_REPLACE('1, 4, и 10 числа', '\d', '@') FROM dual     --> '@, @, и @@ числа' [ORACLE PL/SQL] меняем любую цифру на @ (само меняет все цифры)
SELECT REGEXP_REPLACE('1, 4, и 10 числа', '\d','@','g')  FROM dual --> '@, @, и @@ числа' [postgresql] меняем любую цифру на @ (само меняет только 1й, нужно добавить 'g')
SELECT str, REGEXP_REPLACE(str, '[aeiou]', '', 'gi') AS res FROM disemvowel  -- 'gi' 2 параметра для регулярки
SELECT REGEXP_REPLACE('John Doe', '(.*) (.*)', '\2, \1');          --> 'Doe, John'

-- REGEXP_SPLIT_TO_TABLE(имя_столбца, регулярное_выражение) - сделать таблицу из подстрок разбитой по условию строки
SELECT REGEXP_SPLIT_TO_TABLE(str, '[aeiou]') AS results FROM random_string  -->  разбиваем строку по гласным(с их удалением) в столбец таблицы

-- REGEXP_COUNT() - regexp_count(строка, шаблон [, start [, flags]]) — системная функция, подсчитывает количество мест, где шаблон регулярного выражения POSIX соответствует строке. Он имеет синтаксис. start - считает начиная с этого индекса. flags — собственно флаги регулярок
REGEXP_COUNT('ABCABCAXYaxy', 'A.')         --> 3
REGEXP_COUNT('ABCABCAXYaxy', 'A.', 1, 'i') --> 4



-- Функции для значений даты и времени:
SELECT YEAR("2022-06-16") AS year;              --> 2022  YEAR/MONTH/DAY/HOUR/MINUTE возвращает год/месяц/... для указанной даты
SELECT EXTRACT(MONTH FROM payment_date) AS month FROM payment     -- [postgresql]  Для timestamp without time zone
EXTRACT(DOW FROM created_at)                                      -- dow - день недели 0 for Sunday, 1 for Monday, 6 for Saturday
to_char(rental_date, 'dy')                                        -- день недели: Sun, Mon, Sat

-- Обрезка дат в [postgresql]  DATE_TRUNC(field, source [, time_zone ]) (Значения для обрезки: microseconds milliseconds second minute hour day week month quarter year decade century millennium)
SELECT DATE_TRUNC('hour', timestamp '2020-06-30 17:29:31');                    --> 2020-06-30 17:00:00  - все дальше часа будет нулями
SELECT DATE_TRUNC('hour', timestamp with time zone '2020-06-30 17:29:31+00')   --> 2020-07-01 03:00:00+10
SELECT DATE_TRUNC('month', created_at)::DATE AS date FROM posts GROUP BY date  --> реальный пример с переводом в дату в конце и группировкой по дате(2022-10-01)

-- DATEDIFF(interval, from, to): interval - дни/месяцы/годы. от даты from до даты to
SELECT DATEDIFF(DAY, OrderTime, DeliveryTime) AS AvDelTime FROM Orders          --> тут (day, OrderTime, DeliveryTime) расчет количества дней между OrderTime и DeliveryTime

-- Аналог DATEDIFF для PostgreSQL
DATE_PART('year', last) - DATE_PART('year', first)                       -- Years   == DATEDIFF(yy, first, last)
years_diff * 12 + (DATE_PART('month', last) - DATE_PART('month', first)) -- Months  == DATEDIFF(mm, first, last)
DATE_PART('day', last - first)                                           -- Days    == DATEDIFF(dd, first, last)
TRUNC(DATE_PART('day', last - start)/7)                                  -- Weeks   == DATEDIFF(wk, first, last)
days_diff * 24 + DATE_PART('hour', last - first )                        -- Hours   == DATEDIFF(hh, first, last)
hours_diff * 60 + DATE_PART('minute', last - first )                     -- Minutes == DATEDIFF(mi, first, last)
minutes_diff * 60 + DATE_PART('minute', last - first )                   -- Seconds == DATEDIFF(ss, first, last)

-- TIMESTAMPDIFF(SECOND, time_out, time_in) - среднее время в секундах между time_out и time_in
SELECT TIMESTAMPDIFF(SECOND, time_out, time_in) AS time FROM Trip               --> время полета



-- Функции для преобразования типов данных
SELECT CAST(id AS TEXT) AS textid FROM monsters;                   -- преобразование типов данных(тут INTEGER в TEXT)
SELECT hits::FLOAT / at_bats AS batting_average FROM yankees       -- [postgresql] преобразование типов данных(тут INTEGER в FLOAT)
SELECT (hits::FLOAT/at_bats)::TEXT AS batting_average FROM yankees -- [postgresql] преобразование типов данных
TO_CHAR(num, 'FM999990.0%')                                        -- [PostgreSQL ??] перевод в строку с определенным числом нулей после точки и еще всяким(тут символ %)



-- Функции для числовых значений
SELECT LEAST(compasses, gears, tablets) AS small FROM some         -- [postgresql ??] выбирает наименьшее из значений
SELECT GREATEST(1, 2, 3)                                           -- [postgresql ??] выбирает наибольшее из значений(тут 3)
-- ROUND(22.29, 1) - 1й параметр флоат число, 2й число знаков до которых будет округление(без 2го параметра округляет до целого)
SELECT ROUND(22.29, 1);                                  --> 22.3
SELECT ROUND(22.29, -1)                                  --> 20
SELECT *, FLOOR(hours * 0.5) AS liters FROM cycling      --> округление вниз
SELECT *, CEIL(yr::FLOAT/100) AS century FROM years      --> округление вверх
SELECT ROUND(salary)::FLOAT AS av_salary FROM job        --> [PostgreSQL] округление и преобразование во флоат(из такого 0.29e0)
SELECT ROUND(val::NUMERIC, 2)::FLOAT AS num FROM float8  --> [PostgreSQL] округление до 2х знаков необходимо переводить в NUMERIC если есть параметр(2) и ошибка
MOD(number, 2)                                           -- остаток от деления number на 2
POWER(n, 3)::int                                         -- [PostgreSQL ??] возведение в степень
sqrt( number )                                           -- [PostgreSQL ??] корень квадратный



-- DISTINCT (исключение дубликатов) - позволяет исключить одинаковые значения в выводе, если нам нужны только уникальные
SELECT DISTINCT class FROM Student_in_class;     --> выбираем все уникальные значения столбца class, иключив все дубликаты
SELECT DISTINCT first_name, last_name FROM User; --> применяя к нескольким столбцам исключаются только те строки в которых значения строк одинаковы во всех выбранных стобцах

-- DISTINCT ON (исключение дубликатов по столбцу) (возможно придется использовать в подзапросе, чтоб обработать рез потом)
SELECT DISTINCT ON(team) * FROM employees ORDER BY birth_date DESC  --> выбирает уникальные значения по столбцу, отсортированные по дате, тоесть выбраны эти уникальные с самой большой датой(DISTINCT работает после сортировки)
SELECT DISTINCT ON(user_id, video_id) user_id, video_id FROM user_playlist  --> по нескольким столбцам



-- LIMIT - позволяет извлечь определённый диапазон записей из одной или нескольких таблиц(пишется в самом конце запроса).
-- (Оператор LIMIT реализован не во всех СУБД, например, в MSSQL для вывода записей с начала таблицы используется оператор TOP)
SELECT capital FROM countries WHERE country LIKE 'E%' ORDER BY capital LIMIT 6;   --> выводит токо 6 певых строк
SELECT * FROM Company LIMIT 2, 3;             --> выводит строки с 3й по 5ю(1я цифра число пропущеных строк, 2я число строк)
SELECT * FROM Company LIMIT 3 OFFSET 2;       --> альтернативный синтаксис того что выше
SELECT * FROM Company OFFSET 2;               --> выбираем все кроме 2х первых строк



-- ROW_NUMBER() OVER(ORDER BY SUM(имя_колонки) DESC) - вывести новую колонку порядковых номеров по убыванию относительно значений указанной колонки, которые заполняются автоматически
SELECT ROW_NUMBER() OVER(ORDER BY points DESC) AS rank FROM people;
SELECT ROW_NUMBER() OVER(ORDER BY SUM(points) DESC) AS rank FROM people GROUP BY some;

-- ROW_NUMBER() OVER(PARTITION BY
ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY count(*) DESC, category.name) AS category_rank  --> разбивка ранга по значениям столбца(когда новое значения ранг начинается снова с 1)  ???


-- RANK() OVER(ORDER BY SUM(имя_колонки) DESC) - работает так же как ROW_NUMBER() только при одинаковых значениях ставит одинаковый ранг. Дальнейший ранг учитывает все столбцы, например 1, 1, 3

-- DENSE_RANK() OVER(ORDER BY SUM(имя_колонки) DESC) - работает так же как ROW_NUMBER() только при одинаковых значениях ставит одинаковый ранг. Дальнейший ранг не учитывает все столбцы, например 1, 1, 2














--
