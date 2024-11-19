--                                                 Типы данных

-- В SQL каждый столбец в таблице должен иметь определённый тип данных, указывающий на то, какие значения могут храниться в этом столбце.



--                                             Строковый тип данных

-- Благодаря строковому типу данных в базе данных хранятся как текстовые, так и различные двоичные данные (например, картинки).

-- [ PostgreSQL +, MySQL + ]

CHARACTER(x) -- Содержит текстовые строки. Длина фиксируемая по выбору(0 до 255), указывается в скобках при объявлении, не может быть больше этого значения. Если длина строки меньше указанной, она дополняется правыми(вконце) пробелами до указанной длины. В Постгрэ может хранить любые символы юникода
CHAR(x)	     -- алиас к CHARACTER(x)

CHARACTER VARYING(x) -- Содержит текстовые строки. Длина строк динамическая. Длина может быть любой в диапазоне от 0 до 65,535, не может быть больше этого значения. Если указываем строку меньшей длинны, то он такой и будет, никаких пробелов поставлено не будет. В Постгрэ может хранить любые символы юникода(8байт). В других СУБД(MSSQL) есть тип NVARCHAR(8байт), там просто VARCHAR только 4байта(только латинские символы). Часто используется.
VARCHAR(x)           -- алиас к CHARACTER VARYING(x)

TEXT       -- предназначен для хранения больших данных текстового содержания. Максимальная длина 65,535 (сортировки и сравнения сохранённых данных не чувствительны к регистру в полях TEXT). В Постгресс ограничение до 1 гигабайта.


-- [ PostgreSQL ?, MySQL + ]

TINYTEXT   -- Максимальная длина 255
MEDIUMTEXT -- Максимальная длина 16,777,215
LONGTEXT   -- Максимальная длина 4,294,967,295


BINARY(X)    -- Содержит двоичные строки. Длина фиксируемая(0 до 255), её вы указываете при объявлении.
VARBINARY(X) -- Содержит двоичные строки. Длина строк динамическая. Длина может быть любой в диапазоне от 0 до 65,535

BLOB       -- Используется для хранения больших бинарных данных(двоичные строки), таких как картинки. Максимальная длина 65,535 (сортировки и сравнения сохранённых данных у BLOB чувствительны к регистру)
TINYBLOB   -- Максимальная длина 255
MEDIUMBLOB -- Максимальная длина 16,777,215
LONGBLOB   -- Максимальная длина 4,294,967,295



--                                            Числовой тип данных

-- Числовые данные разделяются на точные и приближенные, на целые и вещественные. В отдельную категорию можно отнести битовые значения.


-- 1. Точные целые числа

-- [ PostgreSQL +, MySQL + ]
SMALLINT              -- 2 байта                от -32768 до 32767 (от -2**15 до 2**15-1)
INTEGER               -- 4 байта	              от -2**31 до 2**31-1
INT                   -- синоним к INTEGER
BIGINT                -- 8 байт	                от -2**63 до 2**63-1

-- [ PostgreSQL +, MySQL - ] В PostgreSQL нет UNSIGNED, вместо этого есть типы:
SMALLSERIAL           -- 2 байта                от 0 до 32767
SERIAL                -- 4 байта	              от 0 до 2**32-1
BIGSERIAL             -- 8 байт                 от 0 до 2**64-1

-- [ PostgreSQL -, MySQL + ]
UNSIGNED -- предотвращает хранение в отмеченном столбце отрицательных величин
TINYINT	              -- 1 байт(Объем памяти)   от -128 до 127 (от -2**7 до 2**7-1)
TINYINT UNSIGNED      -- 1 байт                 от 0 до 255 (от 0 до 2**8-1)
SMALLINT UNSIGNED     -- 2 байта                от 0 до 65535 (от 0 до 2**16-1)
MEDIUMINT             -- 3 байта                от -2**23 до 2**23-1
MEDIUMINT UNSIGNED    -- 3 байта                от 0 до 2**24-1
INT UNSIGNED          -- 4 байта	              от 0 до 2**32-1
BIGINT UNSIGNED       -- 8 байт                 от 0 до 2**64-1


-- 2. Точные вещественные числа - хранят точные вещественные значения. Используется, когда точность является критически важной. Например, при хранении финансовых данных.

-- [ PostgreSQL +, MySQL + ]
DECIMAL(m, n) -- Дают высокую точность нецелых расчетов, например для финансовых операций
-- m - точность, определяет число всех значащих знаков как до так и после точки
-- n - масштаб, определяет число значащих знаков после точки

-- [ PostgreSQL +, MySQL ? ]
NUMERIC(m, n) -- алиас к DECIMAL

-- [ PostgreSQL ?, MySQL + ]
DEC(M,D)      -- синоним DECIMAL(M,D)
-- Синтаксис DECIMAL эквивалентен DECIMAL(M) и DECIMAL(M,0). По умолчанию, параметр M равен 10.
CREATE TABLE Users (salary DECIMAL(5,2));   -- объявляется, что в колонке salary будут хранится числа, имеющие максимум 5 цифр, причём 2 из которых отведены под десятичную часть(от -999.99 до 999.99)
-- Целая часть и часть после точки хранятся как 2 отдельных целых числа. У DECIMAL(5,2) целая часть содержит 3 цифры и занимает 2 байта, часть после точки 2 цифры - достаточно 1 байта. Итого 3 байта


-- 3. Приближенные числа. Не обеспечивают высокую точность, но работает REAL значительно быстрее NUMERIC Тк например при делении 4 на 2 FLOAT может выдать 2.00000000000000001 и 1.99999999999999999 то для использования расчетов требующих точность лучше его не юзать а применить NUMERIC.

-- [ PostgreSQL +, MySQL ? ]
REAL              -- 4 байта     поддерживает 6 знаков после запятой
FLOAT             -- алиас для REAL и FLOAT4
FLOAT4            -- алиас для REAL и FLOAT

DOUBLE PRECISION  -- 8 байтов    поддерживает 15 знаков после запятой
FLOAT8            -- тоже что и DOUBLE PRECISION

-- [ PostgreSQL ?, MySQL + ]
UNSIGNED -- предотвращает хранение в отмеченном столбце отрицательных величин, но, в отличие от целочисленных типов, максимальный интервал для величин столбца остаётся прежним.
FLOAT(M, D)     -- 4 байта     От ±1.17·10**-39    До  ±3.4·10**38
REAL(M, D)      -- 8 байтов    От ±2.22·10**-308   До  ±1.79·10**308
DOUBLE(M, D)    -- синоним для REAL(M, D)


-- 4. Битовые числа

-- [ PostgreSQL +, MySQL + ]
BOOLEAN -- 1 бит  те 0 или 1.
BOOL    -- синоним к BOOLEAN
-- В PostgreSQL BOOLEAN/BOOL содеожат TRUE или FALSE, так же конвертирует в них "0 или 1" и "y или n" "yes или no"

-- [ PostgreSQL ?, MySQL + ]
BIT(M) -- От 1 до 64 битов, в зависимости от значения M. Хранит последовательность битов заданной длины. По умолчанию, длина составляет 8 бит.
-- Если назначаемое значение в колонке с данным типом использует меньше M бит, то происходит дополнение нулями слева. Например b'101' в BIT(6) храниться в итоге будет b'000101'



--                                                 Дата и время

-- [ PostgreSQL ]
DATE        -- значения даты               в формате ГГГГ-ММ-ДД             от 4713 (до нашей эры) до 294276 года   4 байта
TIME        -- значения времени            в формате ЧЧ:ММ:СС               от 00:00:00 до 24:00:00                 8 байта
TIMESTAMP   -- значение даты и времени     в формате ГГГГ-MM-ДД ЧЧ:ММ:СС.   от 4713 (до нашей эры) до 294276 года   8 байт
TIMESTAMPTZ -- TIMESTAMP с часовым поясом                                   от 4713 (до нашей эры) до 294276 года   8 байт
INTERVAL    -- Разница между 2мя TIMESTAMP, милисек, сек, часах итд.        от -178000000 до 178000000              16 байт
-- Интервал можно вычитать или прибавлять к другим типам даты и времени


-- [ MySQL ]
DATE      -- значения даты           в формате ГГГГ-ММ-ДД            от 1000-01-01 до 9999-12-31                     3 байта
TIME      -- значения времени        в формате ЧЧ:ММ:СС/ЧЧЧ:ММ:СС    от -838:59:59 до 838:59:59                      3 байта
DATETIME  -- значение даты и времени в формате ГГГГ-MM-ДД ЧЧ:ММ:СС.  от 1000-01-01 00:00:00 до 9999-12-31 23:59:59   8 байтов (не зависит от временной зоны - изменении часового пояса, отображение времени не изменится)
TIMESTAMP -- значение даты и времени в формате ГГГГ-MM-ДД ЧЧ:ММ:СС.  от 1970-01-01 00:00:01 до 2038-01-19 03:14:07   4 байта
-- При выборках отображается с учётом текущего часового пояса, его можно задать в настройках операционной системы, где работает MySQL, в глобальных настройках MySQL или в конкретной сессии
-- В базе данных при создании записи с типом TIMESTAMP значение сохраняется по нулевому часовому поясу

-- Значения DATETIME, DATE и TIMESTAMP могут быть заданы одним из следующих способов:
-- Как строка в формате YYYY-MM-DD HH:MM:SS или в формате YY-MM-DD HH:MM:SS для указания даты и времени
-- Как строка в формате YYYY-MM-DD или в формате YY-MM-DD для указания только даты
-- При указании даты можно использовать любой знак пунктуации в качестве разделительного между частями разделов даты или времени. Также возможно задавать дату вообще без разделительного знака, слитно:
INSERT INTO date_table VALUES("2022-06-16 16:37:23");  --> 2022-06-16 16:37:23
INSERT INTO date_table VALUES("22.05.31 8+15+04");     --> 2022-05-31 08:15:04
INSERT INTO date_table VALUES("2014/02/22 16*37*22");  --> 2014-02-22 16:37:22
INSERT INTO date_table VALUES("20220616163723");       --> 2022-06-16 16:37:23
INSERT INTO date_table VALUES("2021-02-12");           --> 2021-02-12 00:00:00

-- Пример с DATETIME
CREATE TABLE datetime_table (datetime_field DATETIME);
SET @@session.time_zone="+00:00";                            -- сбрасываем часовой пояс в MYSQL
INSERT INTO datetime_table VALUES("2022-06-16 16:37:23");
SET @@session.time_zone="+03:00";                            -- меняем часовой пояс в MYSQL
SELECT * FROM datetime_table;  --> 2022-06-16 16:37:23

-- Пример с TIMESTAMP
CREATE TABLE timestamp_table (timestamp_field TIMESTAMP);
SET @@session.time_zone="+00:00";                            -- сбрасываем часовой пояс в MYSQL
INSERT INTO timestamp_table VALUES("2022-06-16 16:37:23");
SET @@session.time_zone="+03:00";                            -- меняем часовой пояс в MYSQL
SELECT * FROM timestamp_table; --> 2022-06-16 19:37:23



--                                           Специальные значения

NULL -- Специальное значение отсутствия данных



--                                            Разное [PostgreSQL]

-- PostgreSQL - поддерживает массовы, JSON, XML, специальные геометрические типы. PostgreSQL так же позволяет создавать свои кастомные типы

-- MONEY  - формат денег в Пострэ
1281.7::MONEY     -->    '$1,281.70'

::INET  -- [PostgreSQL] преобразование IP-адреса в число, где последний член это единицы, предпоследний *256, 2й *256*256, 1й *256*256*256



--                                            Узнать тип данных

-- [ PostgreSQL ]

-- PG_TYPEOF(col_name) - функция возвращает тип данных
WITH cte AS (SELECT 1 AS n UNION ALL SELECT 1.5 AS n)
SELECT PG_TYPEOF(n) AS type_field FROM cte;           -- в данном случае в колонку выведет NUMERIC



--                                      Явное преобразования типов данных

-- [ PostgreSQL +, MySQL + ]

-- CAST(col_name AS TYPE_NAME) - функция для преобразования типов, из общего стандарта SQL
SELECT CAST(rental_rate AS VARCHAR(10)) FROM some;

-- CAST может преобразовать строку к дате и времени если строка отформатирована как дата и время, тоесть формат даты и времени поддерживается СУБД
SELECT CAST('2024-10-01' AS DATE) FROM some;
SELECT CAST('01/10/2024 10:21' AS TIMESTAMP) FROM some;


-- TO_DATE(str, format) - если формат не поддерживается то используем эти функции с указанием формата по которому переводим
SELECT TO_DATE('24/10/01', 'yy/MM/dd') FROM some;
SELECT TO_TIMESTAMP('24/10/01 10:21', 'yy/MM/dd HH24:mi') FROM some;


-- [ PostgreSQL +, MySQL - ]

-- :: - альтернативный способ преобразования типов в PostgreSQL
SELECT rental_rate::VARCHAR(10) FROM some;


-- [ PostgreSQL +, MySQL ? ]

-- TO_CHAR([date|num], format) - функция для преобразования и форматирования, числел, дат и времени к строке
-- https://www.postgresql.org/docs/current/functions-formatting.html

SELECT TO_CHAR(NOW(), 'yyyy-MM-dd HH:mi:ss');   -- тут 4 цифры(но можно и 2мя) отведены на год(yyyy), 2 на месяц(MM) например 01, 2 на день месяца(dd), 2 на часы(HH - 12 часовой, HH24 - 24 часовой формат), 2 на минуты(mi) и 2 на секунды(ss)
SELECT TO_CHAR(NOW(), 'dd/MM/yyyy HH:mi ВАСЯ'); -- помимо кодовых букв может добавлять любые символы, которые надо и указывать элементы даты и времени в любом порядке
SELECT TO_CHAR(NOW(), 'dd/MON/yyyy HH:mi');     -- MON - выведет название месяцев из его первых трех заглавных букв, можно написать и Mon чтобы заглавной была только 1я, либо например Month - выведет полное название месяца

TO_CHAR(NOW(), 'FMmonth, YYYY FMDD HH12:MI:SS')            --> 	february, 2023 19 12:00:00
TO_CHAR(NOW(), 'FMMonth, YYYY FMDD HH12:MI:SS')            --> 	February, 2023 19 12:00:00
TO_CHAR('2023-05-08 13:00:00 +0000', 'HH12AM:MI')          -->  01PM:00
TO_CHAR('2023-05-08 13:00:00 +0000', 'HH12:MI AM')         -->  01:00 PM

-- Левый текст(содержащий кодовые стмволы ??) в форматировании вставляем в 2йных кавычках
'FMDD "days and" FMHH24 "hours ago"'

TO_CHAR(num, '99.99')               -- форматирование числел, тут до 2х знаков с обеих сторон (зачемто добавляет пробел вначале)
-- 9 - будет обрезан 0 в начале
-- 0 - не будет обрезан 0 в начале
TO_CHAR(num, 'FM999990.0%')         -- перевод в строку с определенным числом нулей после точки и еще всяким(тут символ %)



--                                       Неявное преобразования типов данных

-- [ PostgreSQL +, MySQL ? ]

-- Неявное преобразование типов - автоматически преобразует типы данных при объединениях строк в одноименных колонках которых разные типы данных, либо когда мы вставляем новые значения в таблицу при помощи INSERT INTO

SELECT 1 AS n UNION ALL SELECT 1.5 AS n;    -- при объединении запросов общая колонка будет типом с плавающей точкой и целое значение из 1го запроса будет преобразовано во флоат(numeric)
SELECT 1 AS n UNION ALL SELECT '1' AS n;    -- при объединении числа со строкой в которой число, неявно преобразует в числоыой тип
SELECT 1 AS n UNION ALL SELECT 'asds' AS n; -- при объединении числа со строкой в которой не числовые символы, преобразования не будет и СУБД выдаст ошибку
SELECT 1 AS n UNION ALL SELECT FALSE AS n;  -- выдаст ошибку
-- Так же неявно может преобразовать строку отформатированную как дата к типу даты






















--
