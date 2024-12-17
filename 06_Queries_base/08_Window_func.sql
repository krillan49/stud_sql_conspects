--                                           Window Functions

-- Window Functions / Оконная функция - это функция после которой идет OVER()

-- OVER() - берет все строки как при группировке и высчитывает значение из них при помощи функции, которая прописана перед OVER(), только в отличие от простой группировки в выводе остаются все изначальные строки, а результат оконной функции будет добавлен в каждой из них
SELECT rating, length, MIN(langth) OVER() AS min_length FROM films;

-- Оконными функциями могут быть любые агрегатные функции(применяемые при группировке)
-- Любые виды оконных функций можно использовать в одном запросе одновременно, тк они просто добавят новые колонки
SELECT rating, length,
  COUNT(*) OVER() AS count,         -- COUNT точно так же может принимать не только столбец или выражение но и *
  MIN(langth) OVER() AS min_length,
  MAX(langth) OVER() AS max_length,
  AVG(langth) OVER() AS avg_length
FROM films;



--                                      Описание окна. PARTITION BY

-- Внутри круглых скобок OVER() чаще всего идет описание окна:

-- PARTITION BY ...  - описывает окно, похожже на GROUP BY для оконных функций. Параметром может быть колонка, колонки или выражение, указывающее на какие группы нужно разбить все строки для применения к каждой из этих групп оконной функции. При указании какой-то колонки в группу добавятся все строки из таблицы у которых значение в этой колонке соответсвует значению в данной строке.
SELECT rating, length, MIN(langth) OVER(PARTITION BY rating) AS min_rating_length FROM films; -- тоесть для каждой строки берем все строки с таким же рейтингом и высчимтываем минимальную длинну среди них. Тоесть выясняем минимальную продолжительность для фильмов с каждым рейтингом и добавляем к каждой строке фильма соответсвующее ее группе значение



--                                  FILTER. Фильтрация в оконных функциях

-- FILTER - задает ограничение(условие) для значений, которые будут обрабатываться оконной функцией. Тоесть оконная функция обработает не все значения в группе, а только соответсвующие условию.
SELECT
  rating,
  COUNT(*) OVER(PARTITION BY rating),                            -- посчтитает общее число фиьмов
  COUNT(*) FILTER(WHERE length > 100) OVER(PARTITION BY rating), -- посчитаем колличество фильмов определенной продолжительности
  COUNT(*) FILTER(WHERE length > 120) OVER(PARTITION BY rating)
FROM films GROUP BY rating;



--                                               WINDOW

-- Если у всех оконных функций в запросе одно и тоже описание окна, то мы можем описать его в разделе WINDOW, а в OVER просто передать его название

SELECT rating, length,
  COUNT(*) OVER w AS count,         -- подставляем название окна вместо того чтобы прописывать его
  MIN(langth) OVER w AS min_length,
  MAX(langth) OVER w AS max_length
FROM films
WINDOW w AS (PARTITION BY rating);  -- WINDOW пишется до ORDER BY
ORDER BY count
-- w - название для окна

-- В разделе WINDOW можно создавать несколько описаний окна через запятую. Так же можно комбинировать уже созданные описания окна для новых описаний
SELECT
  AVG(points) s AS diff_avg,                   -- применяем 1е описание окна
  RANK() OVER w AS rating,                     -- применяем 2е составное описание окна
  LAG(points,1,points) OVER w AS next_behind,
  MAX(points) OVER q AS total_behind,          -- применяем обычное описание окна, аналог составного
FROM results
WINDOW s AS(PARTITION BY competition_id),
       w AS(s ORDER BY points DESC),                          -- создаем еще одно описание окна и используем в нем предыдущее
       q AS(PARTITION BY competition_id ORDER BY points DESC) -- описание выше полностью аналогично данному
ORDER BY 1, 4



--                                          Ранжирующие оконные функции

-- Ранжирующие оконные функции - уже не существуют как агрегатные и нужны для того чтобы назначать номера для каждой строки.


-- 1. ROW_NUMBER() - выведет порядковые номера для каждой строки, всегда выдает строкам разные номера. Не принимает собственных параметров??

-- PARTITION BY ... - разбивает на группы и выдает порядковые номера для каждой из груп отдельные, те для каждой из групп начинается снова с 1. Но по умолчанию без ORDER BY внутри групп они будут взяты в случайном порядке
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating) AS rn FROM films;

-- ORDER BY ... [DESC] - выдает номера по умолчанию(без PARTITION BY) всей таблице, в соответсвии с условием сортировки
SELECT title, rating, length, ROW_NUMBER() OVER(ORDER BY length) AS rn FROM films;
SELECT sale, ROW_NUMBER() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales;  -- по 2м полям, если 1е равно использует 2е

-- PARTITION BY ... ORDER BY ... [DESC] - разбивает на группы по условию группировки и дает отдельную номерацию кадой группе по условию сортировки
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 2. RANK() - использует теже варианты описания окна как и ROW_NUMBER() но при одинаковых значениях сортируемого значения(тоесть при одинаковом порядке сортировки) ставит одинаковый ранг. Дальнейший ранг учитывает все предыдущие строки до, например 1, 1, 3
SELECT title, rating, length, RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 3. DENSE_RANK() - Работает точно так же как RANK(), но дальнейший ранг не учитывает все предыдущие сттроки до, например 1, 1, 2
SELECT title, rating, length, DENSE_RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 4. NTILE(n) - разобьет на n подкатегорий (примерно раное число строк в каждой) всю таблицу или каждую группу полученную при помощи PARTITION BY и выдает номер каждой такой подкатегории. OVER может использовать описания окна PARTITION BY и ORDER BY(для задания порядка по которому собственно и делятся подкатегории)
-- если количество подкатегорий больше строк в группе или тоблице, то каждая строка попадет в отдельную подкатегорию;
-- если зададим только 1 подкатегорию то в нее попадет вся таблица или группа;
-- если число строк в группе или таблице не делится нацело на n, то подкатегории с большим числом строк(на 1) будут в начале.
SELECT title, rating, length, NTILE(8) OVER(PARTITION BY rating ORDER BY length) AS group_id FROM films;


-- Всякие примеры:
SELECT *, (ROW_NUMBER() OVER(ORDER BY birth_date DESC)) * 2 - 1 AS rang FROM employees; -- Делаем ранг нечетным (1, 3, 5 ...). Соотв четным без "- 1"



--                         Оконные функции получения значений предыдущих и следующих строк

-- 1. LAG(col_name, n, default) - оконная функция позволяет получить значение предыдущей строки, где:
--    col_name - имя стобца(?или выражение?)
--    n        - целочисленный параметр, указывающий насколько строк выше мы берем значение
--    default  - значение по умолчанию, для тех строк у которых нет предыдущих на расстоянии n в таблице или в рамках группы, если не указать значение по умолчанию, то добавит значение NULL в эту колонку
-- OVER может использовать описания окна и PARTITION BY(тоесть будем брать значение на n строк выше только в рамках одной группы) и ORDER BY(собственно задает порядок какие строки будут выше, а какие ниже).
SELECT title, rating, length, LAG(length, 1) OVER(PARTITION BY rating ORDER BY length) AS prev_length FROM films; -- Получим значение длинны предыдущего фильма(на одну строку выше) по длинне с таким же рейтингом

-- ?? Хз че делает 3й параметр ??
LAG(price, 1, price - 1) OVER (ORDER BY trade_date) AS drop


-- 2. LEAD(col_name, n) - аналогична LAG, но возвращает значения следующих строк
SELECT title, rating, length, LEAD(length, 5) OVER(PARTITION BY rating ORDER BY length) AS next_five_length FROM films;



--                                          Оконные функции + группировка

-- Тк оконные функции начинают обсчитываться уже после группировки и HAVING, то мы можем использовать их поверх группировки и соответсвенно обычных агрегатных функций
-- Наоборот внутри агрегатных функций для обычных группировок использовать оконные функции уже нельзя

SELECT rental_date::DATE, COUNT(*) AS cnt,
  LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS prev_cnt,      -- тоесть вернет значение предыдущей уже до того сгруппированной из нескольких строк строки
  COUNT(*) - LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS dif -- можем и разницу посчитать между текущем и предыдущим сгруппированным значением
FROM rental
GROUP BY rental_date::DATE;



--                                       Задание рамок окна. Родственные строки

-- 1. ROWS BETWEEN - задает значения рамок окна(включительно), чтобы взять только часть строк из таблицы или группы, заданные этими рамками, а не все, для применения их в оконной функции

-- Варианты значений рамок окна:
-- CURRENT ROW         - текущая строка
-- 2 PRECEDING         - количество строк(тут 2) до текущей
-- UNBOUNDED PRECEDING - все строки до текущей
-- 3 FOLlOWING         - количество строк(тут 3) после текущей
-- UNBOUNDED FOLlOWING - все строки после текущей

-- Просуммируем продажи за каждые 3 дня (для 1й строки возьмет только 1 день, для 2й только 2, тк выше ничего нет)
SELECT rent_day, amount,
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS tree_days_before_amount, -- тоесть берет 2 строки между включительно 2мя(начало диапазона) до текущей и самой текущей(конец диапазона)
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) AS week_amount,
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_amount_row  -- а так в каждой строке будет сумма всех продаж с начала и по текущий день
FROM rent_day;


-- 2. RANGE BETWEEN - задает значения рамок окна как и ROWS BETWEEN, но если значения по которым сортируем в каких-то строках равны(тоесть при одном и том же запроса они могут стоять в разном порядке относительно друг друга, тоесть при ROWS BETWEEN у них могут быть разные суммы при повторном запросе), то они являются родственными. ROWS BETWEEN берет например все строки до, текущую и все строки после если они заданны, а RANGE возьмет все тоже, но еще и все родственные уже взятым строки

SELECT rent_day, amount,
  SUM(amount) OVER(ORDER BY rent_day RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_amount_row  -- так в каждой строке будет сумма всех продаж с начала и по текущий день + все родственные строки
FROM rent_day;

-- Если мы указываем ORDER BY в агрегатных оконных функциях, то автоматически будут применены рамки окна с параметрами RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, тоесть от начала и до данной строки + родственные строки
SELECT rating, length,
  SUM(langth) OVER(PARTITION BY rating) AS sum_length,    -- тоесть тут в каждой группе будет сумма всей группы, по умолчанию все строки родственные тк не задано поле для сортировки
  SUM(langth) OVER(PARTITION BY rating ORDER BY langth) AS sum_length2, -- а тут в кажой группе будет сумма в рамках окна с параметрами RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, те от начала до текущей строки + родственные по условию сортировки
  SUM(langth) OVER(PARTITION BY rating ORDER BY langth RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_length3, -- тут будет тоже самое как и выше, тк это значение рамок по умолчанию
  SUM(langth) OVER(PARTITION BY rating ORDER BY langth, film_id) AS sum_length4 -- чтобы исключить родственные просто сделаем строки уникальными добавив новые колонки в сортировку
FROM films;



--                                  Оконные функции получения конкретной строки

-- FIRST_VALUE() - оконная функция вернет значение 1й строки в таблице или группе
-- LAST_VALUE() - оконная функция вернет значение последней строки в таблице или группе

SELECT rating, length,
  FIRST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth) AS first_length, -- получим значение длинны 1й строки(тоесть минимальной) для этой группы (с таким же рейтингом как в данной строке)
  LAST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth) AS first_length,  -- так не получим значение длинны последней строки, тк по умолчанию у нас стоят рамки окна RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, тоесть строки до текущей, а последнее значение будет равно текущий с этими условиями
  LAST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLlOWING) AS first_length, -- так изменив рамки окна на все строки уже получим значение длинны последней строки(тоесть максимальной) для этой группы (с таким же рейтингом как в данной строке)
FROM films;



--                                              Разные примеры

-- С условным оператором в условии оконной функции
SELECT *, SUM(CASE WHEN op = 'add' THEN amount ELSE -amount END) OVER(ORDER BY date, id) AS fl_sum
FROM actions ORDER BY date, id;


-- Оконная фунуция выводит: сумму во всех строках, сумму для каждого customer_id итд
SELECT sales_id, customer_id, cnt,
  SUM(cnt) OVER () AS total,
  SUM(cnt) OVER (ORDER BY customer_id) AS running_total,
  SUM(cnt) OVER (ORDER BY customer_id, sales_id) AS running_total_unique
FROM sales ORDER BY customer_id, sales_id;

















--
