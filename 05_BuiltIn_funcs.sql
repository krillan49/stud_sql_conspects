--                                             Встроенные функции

-- https://sql-academy.org/ru/handbook/LENGTH  справочник по функциям MySQL

-- Встроенная функция - это реализованный в СУБД кусок кода, выполняет преобразования данных в запросах. Может иметь 0 или несколько аргументов. Возвращает какой-то литерал. Их можно применять как к просто литералам, так и к значениям, взятым из таблицы.

-- Встроенная функция выполняет преобразования для каждой строки отдельно.

-- Операции над результатом функции - тк каждая функция возвращает литерал, то её результат также можно использовать в дальнейших расчётах и преобразованиях при помощи функций.
SELECT UPPER(LEFT('sql-academy', 3)) AS str;       --> "SQL" выполняем UPPER над результатом функции LEFT



--                                 Встроенные функции для преобразования типов данных

SELECT CAST(id AS TEXT) AS textid FROM monsters;           -- преобразование типов данных(тут INTEGER в TEXT)
SELECT hits::FLOAT / at_bats AS average FROM yankees;      -- [postgresql] преобразование типов данных(тут INTEGER в FLOAT)



--                                        Встроенные функции - разное [PostgreSQL]

RANDOM()        --  генерит флоат от 0 до 1
RANDOM()::TEXT  -- сгенерит рандомный текст

MD5('Kroker')        -- функция для шифрования в MD5 возвращает строку шифра
MD5(RANDOM()::TEXT)  -- сгенерить MD5 рандоиного текста



--                                 Математические/числовые встроенные функции и операторы

-- Можем использовать математические операторы к значениям из таблицы и дополнительным литералам
SELECT a + b - 5, a * c / 2, a ^ 2 % 3 FROM some; -- ^ только в [PostgreSQL ??]
SELECT 10000!;                                    -- Факториал [PostgreSQL ??]

-- [PostgreSQL ??] Наименьшее и наибольшее из набора значений:
SELECT LEAST(compasses, gears, tablets) AS small FROM some;   -- выбирает наименьшее из значений
SELECT GREATEST(1, 2, 3);                                     -- выбирает наибольшее из значений(тут 3)

-- Встроенные функции для округления. -- [ROUND, FLOOR, CEIL](22.29, 1) - 1й параметр флоат число, 2й число знаков до которых будет округление(без 2го параметра округляет до целого)
SELECT
  ROUND(22.29, 1),               --> 22.3
  ROUND(22.29, 0),               --> 22
  ROUND(22.29, -1),              --> 20
  ROUND(salary)::FLOAT,          -- [PostgreSQL] округление и преобразование во флоат(из NUMERIC 0.29e0)
  ROUND(val::NUMERIC, 2)::FLOAT, -- [PostgreSQL] если есть параметр числа знаков, то необходимо переводить в NUMERIC
  FLOOR(hours * 0.5),            -- округление вниз
  CEIL(yr::FLOAT / 100)          -- округление вверх
FROM some;

-- Разные встроенные математические функции:
SELECT
  DIV(n, 2),         -- [PostgreSQL ??] целочисленное деление даже для изначально дробных чисел
  ABS(-5),           --> 5     модуль числа
  MOD(num, 2),       -- остаток от деления num на 2 (альтернатива %)
  POWER(n, 3)::INT,  -- [PostgreSQL ??] возведение в степень
  SQRT(num),         -- [PostgreSQL ??] корень квадратный
  GCD(1071, 462),    --> 21    Наибольший общий множитель
  FACTORIAL(5)       --> 120   [PostgreSQL] считает факториал
FROM some;



--                                             Встроенные функции для строк

-- [PostgreSQL, MySQL] индексация строк начинается с 1, а не с 0.

-- Преобразование строки
SELECT
  UPPER('Hello world') AS upstring,  --> 'HELLO WORLD'  Возвращает строку в верхнем регистре
  LOWER('SQL Academy'),              --> 'sql academy'  Возвращает строку в нижнем регистре
  INITCAP(name),                     -- Capitalize name
  REVERSE(chars)                     -- реверсирует строку
FROM some;

-- Информация о параметрах строки(индекс подстроки, длинна строки):
SELECT
  LENGTH('sql-academy') AS size,           --> 11 Возвращает длину указанной строки
  CHAR_LENGTH(s1 || ' ' || s2) AS str,     --> 11 [PostgreSQL] Возвращает длину указанной строки
  INSTR('sql-academy', 'academy') AS idx,  --> 5  Возвращает позицию первого символа подстроки в строке
  STRPOS('sql-academy', 'academy'),        --> 5  [PostgreSQL ?] Возвращает позицию первого символа подстроки в строке
  POSITION('om' in 'Thomas') AS idx        --> 3  [PostgreSQL] Возвращает позицию первого символа подстроки в строке
FROM some;

-- Срезы и подстроки:
SELECT
  LEFT('sql-academy', 3),      --> "sql" Возвращает заданное количество крайних левых символов строки
  RIGHT('XYZ', - 1),           --> 'YZ'  оставляем все символы справа кроме первого
  -- [PostgreSQL] SUBSTRING - возвращает часть строки:
  SUBSTRING('PostgreSQL', 1, 5),               --> 'Postg' 1й аргумент стартовая позиция, 2й число элементов
  SUBSTRING('PostgreSQL', 8),                  --> 'SQL'  с 1м аргументом берет все символы начиная с 8го
  SUBSTRING('PostgreSQL' FROM 1 FOR 8),        -- полный синтаксис
  SUBSTRING('PostgreSQL' FROM 8),              -- полный синтаксис
  SUBSTRING(email, 1, STRPOS(email, '@') - 1),
  SUBSTRING('The house number is 9001', '([0-9]{1,4})') AS house_no, --> '9001'  с регуляркой
  SUBSTRING('PostgreSQL' FROM '%#"S_L#"%' FOR '#')                   --> 'SQL' скюэлевской регуляркой по типу LIKE
FROM some;

-- Повторение и конкатинация строк
SELECT
  REPEAT(name, 3) AS name,                     -- REPEAT(стобец, число повторений) - повторяет строковое значение.
  CONCAT(first, '+', mid, 'k', last) AS title, -- конкатинация строковых значений столбцов в один столбец с добавлением дополнительных строчных элементов
  CONCAT_WS(' ', first, mid, last) AS title,   -- тоже самое что и выше, но если между значениями нужен одинаковый элемент(тут пробел)
  first_name || ' ' || last_name AS full_name -- [PostgreSQL] тоже что и 2 выше, оператор конкатенации
FROM some;

-- Разбитие строк:
SELECT
  SPLIT_PART(chars, ',', 1) AS c1,  -- [PostgreSQL] разбивает строку chars по ',' и выбирает 1й из разбитых кусков
  SPLIT_PART(chars, ',', -1) AS c2  -- [PostgreSQL] последний элемент (работает только в новых версиях)
FROM some;

-- Преобразование частей строк
SELECT
  REPLACE('aca', 'a', 'b'),                  -- 'bcb' замена одиночных символов на другие одиночные('a' to 'b')
  TRANSLATE(some, '123456789', '000011111')  -- как tr в Руби
FROM some;

-- Убрать крайние пробелы, удалить подстроку
SELECT
  TRIM(str),            -- [postgresql ?] убирает пробелы с краев
  TRIM(leading str),    -- [postgresql ?] убирает пробелы слева
  TRIM(trailing str),   -- [postgresql ?] убирает пробелы справа
  TRIM('er' from str),  -- [postgresql ?] убирает заданную подстроку
  RTRIM(str)            -- [postgresql ?] убирает пробелы справа
FROM some;

-- Форматирование/Интерполяция значения в строку(шаблон)
SELECT FORMAT('Hello, %s how are you doing today?', name) FROM some; -- подставит name в позицию %s

-- [PostgreSQL] функции кодировки ASCII
SELECT
  ASCII('A'), --> 65       получить код символа
  CHR(65)     --> 'A'      получить символ из кода
FROM some;



--                                   Встроенные функции для регулярных выражений

-- string ~ regex  -  определяет строки соответсующие регулярке (в постгре регистр не учитывает ??)
SELECT city_name, city_name ~ '^[AEIOU]' AS a FROM stations;   -- ищет совпадения с первой буквой из указанных

-- [PostgreSQL] REGEXP_COUNT(строка, шаблон [, start [, flags]]) — системная функция, подсчитывает количество мест, где шаблон регулярного выражения POSIX соответствует строке. start - считает начиная с этого индекса
-- Работает только с 15й версии Постгрэ
SELECT
  REGEXP_COUNT('ABCABCAXYaxy', 'A.')         --> 3
  REGEXP_COUNT('ABCABCAXYaxy', 'A.', 1, 'i') --> 4
FROM some;

-- SUBSTRING(string FROM regex)   - вырезать из строки по шаблону регулярки
SELECT SUBSTRING(greeting FROM '#\d+') AS user_id FROM greetings;   --   Bienvenido tal #470815 BD. -> #470815

-- REGEXP_REPLACE(строка, регулярка, элемент замены, позиция(число, не обязательно))  -  заменить элементы строки по шаблону регулярки
SELECT
  REGEXP_REPLACE('1, 4, и 10 числа', '\d','@','g'),      --> '@, @, и @@ числа' меняем любую цифру на @ ([PostgreSQL] - само меняет только 1й раз, нужно добавить 'g'; [ORACLE, PL/SQL] - само меняет все цифры те флаг 'g' не нужен)
  REGEXP_REPLACE(str, '[aeiou]', '', 'gi') AS res,       -- 2 флага для регулярки
  REGEXP_REPLACE('John Doe', '(.*) (.*)', '\2, \1'),     --> 'Doe, John'
  REGEXP_REPLACE(str, ('^' || n || '[aeiou]'), '', 'gi') -- с объединением в регулярку значения столбца
FROM some;

-- REGEXP_SPLIT_TO_TABLE(имя_столбца, регулярное_выражение) - сделать новые строки из подстрок строки разбитой по regex
SELECT REGEXP_SPLIT_TO_TABLE(str, '[aeiou]') AS results FROM random_string  -->  разбиваем строку по гласным(с их удалением) в столбец таблицы



--                                       Встроенные функции для даты и времени

-- Название столбца лучше не делать datetime, тк оно часто зарезервировано. Лучше использовать datestamp/date_stamp/DateStamp

-- Cпецификация SQL определяет эти функции(работают с SELECT):
SELECT
  CURRENT_TIME,       -- Время на момент оценки(-3 часа от московского)
  CURRENT_DATE,       -- Дата на момент оценки
  CURRENT_TIMESTAMP   -- Дата и время на момент оценки
FROM some;

-- [PostgreSQL] NOW() - функция фозвращает текущее значение даты и времени, можно использовать в любых запросах, в том числе и в ограничения DEFAULT при заполнении таблицы
SELECT NOW();

-- [sqlite3 ?] когда ставим это значением столбца то в него помещается текущие дата и время(часовой пояс -3)
SELECT DATETIME();

-- Вернуть YEAR/MONTH/DAY/HOUR/MINUTE для указанной даты
SELECT
  EXTRACT(MONTH FROM payment_date) AS month,  -- [PostgreSQL]  Для timestamp without time zone
  EXTRACT(DOW FROM created_at),               -- dow - день недели 0 for Sunday, 1 for Monday, 6 for Saturday
  TO_CHAR(rental_date, 'dy'),                 -- день недели: sun, mon, sat
  YEAR("2022-06-16") AS year                  --> 2022 [MySQL ?]
  -- AGE - возвращает число лет до текущей даты в виде интервала:
  AGE(birthdate),                             --> '60 years'   те число лет от даты до сейчас
  AGE(birthdate) >= '60 years',               --> true         можно сравнивать c другим интервалом
  -- DATE_PART - извлекает часть даты:
  DATE_PART('year', last_date),               -- извлекает год из даты в колонке last_date в виде целого числа
  DATE_PART('day', AGE(age))                  -- возвращает число полных дней от даты до сейчас в виде целого числа
FROM some;

-- [MySQL] DATEDIFF(interval, from, to): interval - дни/месяцы/годы. от даты from до даты to
SELECT DATEDIFF(DAY, OrderTime, DeliveryTime) AS AvDelTime FROM Orders;  --> расчет количества дней между OrderTime и DeliveryTime
-- [MySQL] TIMESTAMPDIFF(SECOND, time_out, time_in) - среднее время в секундах между time_out и time_in
SELECT TIMESTAMPDIFF(SECOND, time_out, time_in) AS time FROM Trip        --> время полета

-- Аналог DATEDIFF для [PostgreSQL]
-- даты без времени отнимаются по умолчанию в днях без DATEDIFF/DATE_PART
SELECT
  DATE_PART('year', last) - DATE_PART('year', first),                       -- Years   == DATEDIFF(yy, first, last)
  years_diff * 12 + (DATE_PART('month', last) - DATE_PART('month', first)), -- Months  == DATEDIFF(mm, first, last)
  DATE_PART('day', last - first),                                           -- Days(день месяца)    == DATEDIFF(dd, first, last)
  TRUNC(DATE_PART('day', last - start)/7),                                  -- Weeks   == DATEDIFF(wk, first, last)
  days_diff * 24 + DATE_PART('hour', last - first),                         -- Hours   == DATEDIFF(hh, first, last)
  hours_diff * 60 + DATE_PART('minute', last - first),                      -- Minutes == DATEDIFF(mi, first, last)
  minutes_diff * 60 + DATE_PART('minute', last - first)                     -- Seconds == DATEDIFF(ss, first, last)
FROM some;

-- [PostgreSQL] Вычитание, сложение, сравнение дат и дат, дат и интервалов
SELECT
  -- Вычитание дат вернет тип данных INTERVAL, по умолчанию вернет разницу в днях(число дней интеджер) для дат и в днях и времени для дат со временем:
  cert_finish - CURRENT_DATE,                        --> '49 days'  тип данных INTERVAL
  CURRENT_TIMESTAMP - '2024-02-29 22:11:46 +0000',   --> '49 days 14:20:38.369185'  тип данных INTERVAL
  CURRENT_DATE - '2024-02-29 22:11:46 +0000',        --> '8 days 01:48:14'  CURRENT_DATE - отнимает от начала дня
  -- Сложение/вычитание даты и интервала вернет дату:
  '2001-09-28' + INTERVAL '1 hour',                  --> 2001-09-28 01:00:00
  CURRENT_DATE - INTERVAL '60 years',
  CURRENT_TIMESTAMP - '1 hour'::INTERVAL,
  -- Можно сравнивать даты или интервалы:
  order_time > CURRENT_TIMESTAMP,                    --> true / false
  CURRENT_DATE - occurred_at < '90 days'             --> true / false
FROM some;

-- DATE_TRUNC(field, source [, time_zone ])  - Обрезка дат в [postgresql]
-- Значения для обрезки: microseconds, milliseconds, second, minute, hour, day, week, month, quarter, year, decade, century, millennium
SELECT
  DATE_TRUNC('hour', timestamp '2020-06-30 17:29:31'),                   --> 2020-06-30 17:00:00 - все дальше часа будет нулями
  DATE_TRUNC('hour', timestamp with time zone '2020-06-30 17:29:31+00'), --> 2020-07-01 03:00:00+10
  DATE_TRUNC('month', created_at)::DATE AS d,                            -- пример с переводом в дату в конце
  DATE_TRUNC('week', CURRENT_DATE - INTERVAL '1 week')                   -- предыдущая законченная неделя перед этой
FROM some;













--
