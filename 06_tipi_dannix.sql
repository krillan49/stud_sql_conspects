--                                            Типы данных(по MySQL)

-- В SQL каждый столбец в таблице должен иметь определённый тип данных, указывающий на то, какая информация может храниться в этом столбце.



--                                            1. Строковый тип данных.

-- Благодаря строковому типу данных в базе данных хранятся как текстовые, так и различные двоичные данные (например, картинки).

CHAR(X)	   -- Содержит текстовые строки. Длина фиксируемая(0 до 255), указывается в скобках при объявлении. Если длина строки меньше указанной, она дополняется правыми пробелами до указанной длины.
VARCHAR(X) -- Содержит текстовые строки. Длина строк динамическая. Длина может быть любой в диапазоне от 0 до 65,535

TEXT -- предназначен для хранения больших данных текстового содержания. Максимальная длина 65,535 (сортировки и сравнения сохранённых данных не чувствительны к регистру в полях TEXT)
TINYTEXT -- Максимальная длина 255
MEDIUMTEXT -- Максимальная длина 16,777,215
LONGTEXT -- Максимальная длина 4,294,967,295


BINARY(X)    -- Содержит двоичные строки. Длина фиксируемая(0 до 255), её вы указываете при объявлении.
VARBINARY(X) -- Содержит двоичные строки. Длина строк динамическая. Длина может быть любой в диапазоне от 0 до 65,535

BLOB -- используется для хранения больших бинарных данных(двоичные строки), таких как картинки. Максимальная длина 65,535 (сортировки и сравнения сохранённых данных у BLOB чувствительны к регистру)
TINYBLOB -- Максимальная длина 255
MEDIUMBLOB -- Максимальная длина 16,777,215
LONGBLOB -- Максимальная длина 4,294,967,295



--                                            2. Числовой тип данных

-- Числовые данные разделяются на точные и приближенные, на целые и вещественные. В отдельную категорию можно отнести битовые значения.

UNSIGNED -- предотвращает хранение в отмеченном столбце отрицательных величин


-- а. Точные целые числа
TINYINT	              -- 1 байт(Объем памяти)   от -128 до 127 (от -2**7 до 2**7-1)
TINYINT UNSIGNED      -- 1 байт                 от 0 до 255 (от 0 до 2**8-1)
SMALLINT              -- 2 байта                от -32768 до 32767 (от -2**15 до 2**15-1)
SMALLINT UNSIGNED     -- 2 байта                от 0 до 65535 (от 0 до 2**16-1)
MEDIUMINT             -- 3 байта                от -2**23 до 2**23-1
MEDIUMINT UNSIGNED    -- 3 байта                от 0 до 2**24-1
INTEGER               -- 4 байта	              от -2**31 до 2**31-1
INT                   -- синоним к INTEGER
INT UNSIGNED          -- 4 байта	              от 0 до 2**32-1
BIGINT                -- 8 байт	                от -2**63 до 2**63-1
BIGINT UNSIGNED       -- 8 байт                 от 0 до 2**64-1


-- б. Точные вещественные числа - DECIMAL хранит точное вещественное значение данных. Используется, когда точность является критически важной. Например, при хранении финансовых данных.
-- Синтаксис DECIMAL эквивалентен DECIMAL(M) и DECIMAL(M,0). По умолчанию, параметр M равен 10.
DECIMAL(M,D)  -- Зависит от параметров M и D
DEC(M,D)      -- синоним DECIMAL(M,D)
CREATE TABLE Users (salary DECIMAL(5,2));   -- объявляется, что в колонке salary будут хранится числа, имеющие максимум 5 цифр, причём 2 из которых отведены под десятичную часть(от -999.99 до 999.99)
-- Целая часть и часть после точки хранятся как 2 отдельных целых числа. У DECIMAL(5,2) целая часть содержит 3 цифры и занимает 2 байта, часть после точки 2 цифры - достаточно 1 байта. Итого 3 байта


-- в. Битовые числа
BIT(M) -- От 1 до 64 битов, в зависимости от значения M. Хранит последовательность битов заданной длины. По умолчанию, длина составляет 8 бит.
-- Если назначаемое значение в колонке с данным типом использует меньше M бит, то происходит дополнение нулями слева. Например b'101' в BIT(6) храниться в итоге будет b'000101'
BOOLEAN -- 1 бит  те 0 или 1.
BOOL    -- синоним к BOOLEAN


-- г. Приближенные числа
UNSIGNED -- предотвращает хранение в отмеченном столбце отрицательных величин, но, в отличие от целочисленных типов, максимальный интервал для величин столбца остаётся прежним.
FLOAT(M, D)     -- 4 байта     От ±1.17·10**-39    До  ±3.4·10**38
REAL(M, D)      -- 8 байтов    От ±2.22·10**-308   До  ±1.79·10**308
DOUBLE(M, D)    -- синоним для REAL(M, D)


-- ??   Дают высокую точность нецелых расчетов (Постгрэ??)
::NUMERIC



--                                                3. Дата и время

DATE      -- Хранит значения даты в виде ГГГГ-ММ-ДД    от 1000-01-01 до 9999-12-31   3 байта.
TIME      -- Хранит значения времени в формате ЧЧ:ММ:СС/ЧЧЧ:ММ:СС   от -838:59:59 до 838:59:59   3 байта
DATETIME  -- Хранит значение даты и времени в виде ГГГГ-MM-ДД ЧЧ:ММ:СС.  от 1000-01-01 00:00:00 до 9999-12-31 23:59:59   8 байтов (не зависит от временной зоны - изменении часового пояса, отображение времени не изменится)
TIMESTAMP -- Хранит значение даты и времени в виде ГГГГ-MM-ДД ЧЧ:ММ:СС.  от 1970-01-01 00:00:01 до 2038-01-19 03:14:07   4 байта
-- При выборках отображается с учётом текущего часового пояса, его можно задать в настройках операционной системы, где работает MySQL, в глобальных настройках MySQL или в конкретной сессии
-- В базе данных при создании записи с типом TIMESTAMP значение сохраняется по нулевому часовому поясу

-- Пример с DATETIME
CREATE TABLE datetime_table (datetime_field DATETIME);
SET @@session.time_zone="+00:00"; -- сбрасываем часовой пояс в MYSQL
INSERT INTO datetime_table VALUES("2022-06-16 16:37:23");
SET @@session.time_zone="+03:00"; -- меняем часовой пояс в MYSQL
SELECT * FROM datetime_table;  --> 2022-06-16 16:37:23

-- Пример с TIMESTAMP
CREATE TABLE timestamp_table (timestamp_field TIMESTAMP);
SET @@session.time_zone="+00:00"; -- сбрасываем часовой пояс в MYSQL
INSERT INTO timestamp_table VALUES("2022-06-16 16:37:23");
SET @@session.time_zone="+03:00"; -- меняем часовой пояс в MYSQL
SELECT * FROM timestamp_table; --> 2022-06-16 19:37:23

-- Значения DATETIME, DATE и TIMESTAMP могут быть заданы одним из следующих способов:
-- Как строка в формате YYYY-MM-DD HH:MM:SS или в формате YY-MM-DD HH:MM:SS для указания даты и времени
-- Как строка в формате YYYY-MM-DD или в формате YY-MM-DD для указания только даты
-- При указании даты можно использовать любой знак пунктуации в качестве разделительного между частями разделов даты или времени. Также возможно задавать дату вообще без разделительного знака, слитно:
INSERT INTO date_table VALUES("2022-06-16 16:37:23");  --> 2022-06-16 16:37:23
INSERT INTO date_table VALUES("22.05.31 8+15+04");     --> 2022-05-31 08:15:04
INSERT INTO date_table VALUES("2014/02/22 16*37*22");  --> 2014-02-22 16:37:22
INSERT INTO date_table VALUES("20220616163723");       --> 2022-06-16 16:37:23
INSERT INTO date_table VALUES("2021-02-12");           --> 2021-02-12 00:00:00


-- спецификация SQL 92, октябрь 97, стр. 171, раздел 6.16 определяет эти функции(работают с SELECT):
CURRENT_TIME       -- Время на момент оценки(-3 часа от московского)
CURRENT_DATE       -- Дата на момент оценки
CURRENT_TIMESTAMP  -- Дата и время на момент оценки


datetime() -- Фишка sqlite3(??) когда ставим это значением столбца то в него помещается текущие дата и время(часовой пояс -3)



--                                                4. Разное

-- ::money  - формат денег в Пострэ
1281.7::MONEY     -->    '$1,281.70'
















--
