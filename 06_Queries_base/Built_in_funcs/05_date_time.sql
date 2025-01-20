--                                              Текущие дата и время

-- Cпецификация SQL определяет эти функции:
SELECT
  CURRENT_TIME,       -- Время на данный момент(-3 часа от московского)
  CURRENT_DATE,       -- Дата на данный момент
  CURRENT_TIMESTAMP   -- Дата и время на данный момент
FROM some;

-- [PostgreSQL] NOW() - функция возвращает текущее значение даты и времени, можно использовать в любых запросах, в том числе и в ограничениях DEFAULT при заполнении таблицы
SELECT NOW();

-- [sqlite3 ?] DATETIME() -  текущие дата и время(часовой пояс -3)
SELECT DATETIME();



--                                                   Части дат

-- Части дат например YEAR/MONTH/DAY/HOUR/MINUTE для указанной даты

-- [PostgreSQL] EXTRACT - возвращшает элемент даты для для timestamp without time zone
EXTRACT(MONTH FROM payment_date) AS month   -- вернуть месяц
EXTRACT(DOW FROM created_at)                -- день недели (0 - Sunday, 1 - Monday, 6 - Saturday)
EXTRACT(year FROM AGE(NOW(), date_of_birth) -- число лет между датами
EXTRACT(YEAR FROM AGE(date_of_birth))       -- тоже что и выше

-- TO_CHAR - возвращает часть даты в виде строки:
TO_CHAR(rental_date, 'dy')                 -- день недели (sun, mon, sat)

-- DATE_PART - извлекает часть даты:
DATE_PART('year', last_date)               -- извлекает год из даты в колонке last_date в виде целого числа
DATE_PART('day', AGE(age))                 -- возвращает число полных дней от даты до сейчас в виде целого числа

-- [MySQL ?]
YEAR("2022-06-16") AS year                 --> 2022



--                                                  Обрезка дат

rental_date::TIME -- урезать дату-время до просто времени, отбросив дату

-- [postgresql] DATE_TRUNC(field, source [, time_zone ])  - функция для обрезки дат. Варианты значений для обрезки: microseconds, milliseconds, second, minute, hour, day, week, month, quarter, year, decade, century, millennium
DATE_TRUNC('hour', timestamp '2020-06-30 17:29:31')                   --> 2020-06-30 17:00:00 (все дальше часов будет нулями)
DATE_TRUNC('hour', timestamp with time zone '2020-06-30 17:29:31+00') --> 2020-07-01 03:00:00+10 (тоже с таймзоной)
DATE_TRUNC('month', created_at)::DATE AS d                            -- пример с переводом в дату в конце
DATE_TRUNC('week', CURRENT_DATE - INTERVAL '1 week')                  -- предыдущая законченная неделя перед этой



--                                                  Разница дат

-- [MySQL] DATEDIFF(interval, from, to): interval - дни/месяцы/годы. от даты from до даты to
SELECT DATEDIFF(DAY, OrderTime, DeliveryTime) AS AvDelTime FROM Orders;  --> расчет количества дней между OrderTime и DeliveryTime
-- [MySQL] TIMESTAMPDIFF(SECOND, time_out, time_in) - среднее время в секундах между time_out и time_in
SELECT TIMESTAMPDIFF(SECOND, time_out, time_in) AS time FROM Trip        --> время полета


-- [PostgreSQL] AGE - возвращает количество лет, месяцев и дней между двумя датами до текущей даты в виде интервала:
AGE(birthdate)                              --> '60 years'   с 1м аргументом число лет от даты до сейчас
AGE(a::TIMESTAMP, b::TIMESTAMP)             --> 27 years 5 days
AGE(birthdate) >= '60 years'                --> true         резульат можно сравнивать c другим интервалом

-- Аналог DATEDIFF для [PostgreSQL] (даты без времени отнимаются по умолчанию в днях без DATEDIFF/DATE_PART)
SELECT
  DATE_PART('year', last) - DATE_PART('year', first),                       -- Years   == DATEDIFF(yy, first, last)
  years_diff * 12 + (DATE_PART('month', last) - DATE_PART('month', first)), -- Months  == DATEDIFF(mm, first, last)
  DATE_PART('day', last - first),                                           -- Days(день месяца)    == DATEDIFF(dd, first, last)
  TRUNC(DATE_PART('day', last - start)/7),                                  -- Weeks   == DATEDIFF(wk, first, last)
  days_diff * 24 + DATE_PART('hour', last - first),                         -- Hours   == DATEDIFF(hh, first, last)
  hours_diff * 60 + DATE_PART('minute', last - first),                      -- Minutes == DATEDIFF(mi, first, last)
  minutes_diff * 60 + DATE_PART('minute', last - first)                     -- Seconds == DATEDIFF(ss, first, last)
FROM some;



--                                 Операции над датами(Вычитание, сложение, сравнение)

-- [PostgreSQL] Вычитание дат вернет тип данных INTERVAL, по умолчанию вернет разницу в днях(число дней интеджер) для дат, либо в днях и времени для дат со временем:
cert_finish - CURRENT_DATE                        --> '49 days'  (тип данных INTERVAL)
CURRENT_TIMESTAMP - '2024-02-29 22:11:46 +0000'   --> '49 days 14:20:38.369185'  (тип данных INTERVAL)
CURRENT_DATE - '2024-02-29 22:11:46 +0000'        --> '8 days 01:48:14'  (CURRENT_DATE - отнимает от начала дня)

-- Сложение/вычитание даты и интервала вернет дату:
'2001-09-28' + INTERVAL '1 hour'                  --> 2001-09-28 01:00:00
CURRENT_DATE - INTERVAL '60 years'
CURRENT_TIMESTAMP - '1 hour'::INTERVAL

-- Можно сравнивать даты или интервалы:
order_time > CURRENT_TIMESTAMP                    --> true / false
CURRENT_DATE - occurred_at < '90 days'            --> true / false














--
