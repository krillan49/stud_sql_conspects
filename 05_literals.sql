--                                               Литералы

-- Литерал — это указанное явным образом фиксированное значение, например, число 12 или строка "kjyglygly". Бывает строковый, числовой, логический, NULL, литерал даты и времени итд



--                                               Строка

-- Строка — это последовательность символов, заключённых в одинарные (') или двойные (") кавычки, включает спец символы при помощи "\" например "\n"

-- [postgresql] - строковые литералы только в одинарных кавычках('') тк двойные воспринимаются как столбец

-- [postgresql] - экранирование кавычек
-- 1. Необходимо удваивать кавычки:
SELECT ' for=''213'' ';
-- 2. escape string (требует явного указания на возможное содержание escape последовательностей)
SELECT E' for=\'213\' ';
-- 3. использовать синтаксис строковых литералов Dollar-quoted String (там же в мануале)
SELECT $$ for='213' $$;
SELECT $anystring$ for='213' $anystring$;
-- Если же данные приходят от пользователя через приложение - то используйте prepared statements (или его эмуляцию вашей библиотекой доступа) и тогда вас экранирование не беспокоит вовсе



--                                           Числовые литералы

-- Числовые литералы - любые числа: 1, 2.9, 0.01, .2(можно без нуля), +1(для положительного можно писать плюс если надо), -10, -2.2, 1e3(это 1000) 1e-3(это 0.001)

-- 	Арифметические операторы для числовых литералов: % или MOD(Деление по модулю), *(Умножение), +, -, /(Деление 1 / 2 = 0.5), DIV(Целочисленное деление)

-- 		[postgresql] 1/2 == 0.  Нужно переводить во FLOAT например так 1.0*4/5



--                                          Литералы даты и времени

-- Литералы даты и времени - могут быть представлены в формате строки("1970-12-30", "19701230") или числа(19701230).

-- 	можем указывать время отдельно или вместе:
-- '2020-01-01'  - интерпритируется как дата со временем равным нулю, например 1 января 2020, 00:00:00
--  hh:mm:ss, hh:mm, hh, ss  -  варианты времени без даты или без отдельных элементов времени
-- 	YYYY-MM-DD hh:mm:ss, YYYYMMDDhhmmss  -  дата и время - '20200101183030' = 1 января 2020, 18:30:30



--                                           Логические литералы

-- Логические литералы - TRUE и FALSE, истинность и ошибочность утверждения.

-- MySQL, при интерпретации запроса преобразует их в числа: TRUE и FALSE становятся 1 и 0 соответственно.



--                                                    NULL

-- NULL - означает "нет данных", "нет значения". Оно нужно, чтобы отличать визуально пустые значения, такие как строка нулевой длины или пробел, от того, когда значения вообще нет














--
