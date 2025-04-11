--                                         Window Functions. OVER()

-- Window Functions / Оконная функция - это функция после которой идет OVER(). Оконными функциями могут быть любые агрегатные функции(применяемые при группировке)

-- OVER() - берет все строки, как при группировке, и высчитывает значение из них при помощи агрегатной функции, которая прописана перед OVER(), только в отличие от простой группировки запрос вернет все изначальные строки, а результат оконной функции будет добавлен значением новой колонки в каждой из них
SELECT rating, length, MIN(langth) OVER() AS min_length FROM films; -- тут в каждой строке выведет в новой колонке min_length минимальное значение колонки langth по всем строкам

-- Любые виды оконных функций можно использовать в одном запросе одновременно, тк они просто добавят новые колонки
SELECT rating, length,
  COUNT(*) OVER() AS count,         -- COUNT точно так же может принимать не только столбец или выражение, но и *
  MIN(langth) OVER() AS min_length,
  MAX(langth) OVER() AS max_length,
  AVG(langth) OVER() AS avg_length
FROM films;



--                                        Описание окна. PARTITION BY

-- Внутри круглых скобок OVER() чаще всего идет описание окна:

-- PARTITION BY - описывает окно, похоже на GROUP BY, но для оконных функций. Параметром может быть колонка, несколько колонок или выражение, указывающее на какие группы нужно разбить все строки, для применения к каждой из этих групп отдельно оконной функции. При указании какой-то колонки - в группу добавятся все строки из таблицы у которых значение в этой колонке соответсвует значению в данной строке.
SELECT rating, length, MIN(langth) OVER(PARTITION BY rating) AS min_rating_length FROM films; -- тоесть для каждой строки берем все строки с таким же рейтингом и высчимтываем минимальную длинну среди них и добавляем к каждой строке соответсвующее ее группе значение в колонку min_rating_length



--                                Родственные строки. Задание рамок окна. ORDER BY

-- Родственные строки в контексте оконных функций - это строки имеющие одинаковое значение в поле или полях к которому применено описание окна "ORDER BY", тоесть строки имеющие одинаковые значение в поле или полях по котором была сделана сортировка для выбора порядка для конной функции. Тоесть родственные строки могут существовать, только если сортировка сделана недостаточно точно и результат ее неоднозначен и при повторении тогоже запроса результат этой сортировки может быть другим


-- Чтобы для оконной функции выбрать не все строки из таблицы или группы, а только отпределенное число строк выше и/или ниже - можно задавать рамки для окна выборки, при помощи значений:
-- CURRENT ROW           - текущая строка
-- UNBOUNDED PRECEDING   - все строки перед текущей
-- UNBOUNDED FOLlOWING   - все строки после текущей
-- 2 PRECEDING           - количество строк перед текущей (тут 2), для 1й строки возьмет только 1 строку, тк выше ничего нет
-- 3 FOLlOWING           - количество строк после текущей (тут 3), для последней строки возьмет только 1 строку, для предпоследней только 2, тк выше ничего нет


-- 1. ROWS BETWEEN - задает значения рамок окна, не учтывает родственные строки вне этих рамок (тоесть при одном и том же запросе родственные строки могут стоять в разном порядке относительно друг друга, соответсвенно могут быть разные результаты оконных функций при повторном запросе)
SELECT rent_day, amount,
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS tree_days_before_amount, -- берет 2 строки перед текущей и саму текущую строку
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) AS week_amount,
  SUM(amount) OVER(ORDER BY rent_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_amount_row  -- в каждой строке будет сумма всех продаж с начала и по текущий день
FROM rent_day;


-- 2. RANGE BETWEEN - задает значения рамок окна, но учитывает значения родственных строк. ROWS BETWEEN берет например все строки до, текущую и все строки после если они заданны, а RANGE возьмет все тоже, но еще и все родственные уже взятым строкам.
SELECT rent_day, amount,
  SUM(amount) OVER(ORDER BY rent_day RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_amount_row  -- так в каждой строке будет сумма всех продаж с начала и по текущий день (+ все родственные строки, что позволит учесть все прдажи текущего дня, даже если они ниже в порядке)
FROM rent_day;


-- ORDER BY [DESC] - описание окна, задает порядок по которому будут отсортированны строки (без PARTITION BY всей таблице). По умолчанию(без ORDER BY) строки будут взяты в случайном порядке

-- Если мы указываем ORDER BY в агрегатных оконных функциях, то автоматически будут применены рамки окна с параметрами RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, тоесть от начала и до данной строки + родственные строки
SELECT rating, length,
  SUM(langth) OVER(PARTITION BY rating) AS sum_length,    -- тоесть тут в каждой группе будет сумма всей группы, по умолчанию все строки родственные тк не задано поле для сортировки
  SUM(langth) OVER(PARTITION BY rating ORDER BY langth) AS sum_length2, -- а тут в кажой группе будет сумма в рамках окна с параметрами RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, те от начала до текущей строки + родственные по условию сортировки
  SUM(langth) OVER(PARTITION BY rating ORDER BY langth, film_id) AS sum_length4 -- чтобы исключить родственные просто сделаем строки уникальными добавив новые колонки в сортировку
FROM films;



--                                   FILTER. Фильтрация в оконных функциях

-- FILTER - задает ограничение(условие) для значений, которые будут обрабатываться оконной функцией. Тоесть оконная функция обработает не все значения в группе, а только соответсвующие дополнительному условию.
SELECT
  rating,
  COUNT(*) OVER(PARTITION BY rating),                            -- посчтитает общее число фиьмов с каждым рейтингом
  COUNT(*) FILTER(WHERE length > 100) OVER(PARTITION BY rating), -- посчитаем колличество фильмов определенной продолжительности
  COUNT(*) FILTER(WHERE length > 120) OVER(PARTITION BY rating)
FROM films;



--                                                WINDOW

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
  AVG(points) OVER s AS diff_avg,                -- применяем 1е описание окна
  RANK() OVER w AS rating,                       -- применяем 2е составное описание окна
  LAG(points, 1, points) OVER w AS next_behind,
  MAX(points) OVER q AS total_behind,            -- применяем обычное описание окна, аналог составного
FROM results
WINDOW s AS(PARTITION BY competition_id),
       w AS(s ORDER BY points DESC),                          -- создаем еще одно описание окна и используем в нем предыдущее
       q AS(PARTITION BY competition_id ORDER BY points DESC) -- описание полностью аналогично описанию w
ORDER BY 1, 4



--                                  Оконные функции получения конкретной строки

-- FIRST_VALUE() - оконная функция вернет значение 1й строки в таблице или группе
-- LAST_VALUE() - оконная функция вернет значение последней строки в таблице или группе

-- Работают как агрегатные, тоесть на них распространяется стандартные правила рамок окнка с RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW по умолчанию при использовании ORDER BY ??

SELECT rating, length,
  FIRST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth) AS first_length, -- получим значение длинны 1й строки(тоесть минимальной) для этой группы (с таким же рейтингом как в данной строке)
  LAST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth) AS first_length,  -- так не получим значение длинны последней строки, тк по умолчанию у нас стоят рамки окна RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, тоесть строки до текущей, а последнее значение будет равно текущий с этими условиями
  LAST_VALUE(langth) OVER(PARTITION BY rating ORDER BY langth RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLlOWING) AS first_length, -- так изменив рамки окна на все строки уже получим значение длинны последней строки(тоесть максимальной) для этой группы (с таким же рейтингом как в данной строке)
FROM films;



--                                          Ранжирующие оконные функции.

-- Ранжирующие оконные функции - уже не существуют отдельно как агрегатные и нужны только как оконные функции, для того чтобы назначать номера для каждой строки.

-- Так как это не агрегатные функции то значения рамок окна при использовании ORDER BY будут интуитивными, тоесть включать все строки, а не до текущей


-- 1. ROW_NUMBER() - выведет порядковый номер для каждой строки, всегда выдает строкам разные номера. ?? Не принимает собственных параметров

-- PARTITION BY - разбивает на группы и выдает порядковые номера для каждой из груп отдельно, те для каждой из групп начинается снова с 1.
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating) AS rn FROM films;

-- ORDER BY [DESC] - описание окна, задает порядок по которому будут назначены номера (без PARTITION BY всей таблице), в соответсвии с условием сортировки. По умолчанию(без ORDER BY) строки будут взяты в случайном порядке
SELECT title, rating, length, ROW_NUMBER() OVER(ORDER BY length) AS rn FROM films;  -- нумерация по значениб в колонке length
SELECT sale, ROW_NUMBER() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales;  -- по 2м полям, если 1е равно использует 2е

-- PARTITION BY + ORDER BY - разбивает на группы по условию группировки и дает отдельную нумерацию кадой группе по условию сортировки
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 2. RANK() - при одинаковых значениях сортируемого значения(тоесть при одинаковом порядке сортировки) ставит одинаковый ранг. Дальнейший ранг учитывает все предыдущие строки до, например 1, 1, 3. Использует теже варианты описания окна как и ROW_NUMBER()
SELECT title, rating, length, RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 3. DENSE_RANK() - Работает точно так же как RANK(), но дальнейший ранг не учитывает все предыдущие сттроки до, например 1, 1, 2
SELECT title, rating, length, DENSE_RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 4. NTILE(n) - разобьет на n подкатегорий (на примерно равное число строк в каждой) всю таблицу или каждую группу полученную при помощи PARTITION BY и выдает номер каждой такой подкатегории. ORDER BY используетя для задания порядка по которому таблица или группа делится на подкатегории
-- если количество подкатегорий больше строк в группе или тоблице, то каждая строка попадет в отдельную подкатегорию;
-- если зададим только 1 подкатегорию то в нее попадет вся таблица или группа;
-- если число строк в группе или таблице не делится нацело на n, то подкатегории с большим числом строк(на 1) будут в начале.
SELECT title, rating, length, NTILE(8) OVER(PARTITION BY rating ORDER BY length) AS group_id FROM films;


-- Всякие примеры:
SELECT *, (ROW_NUMBER() OVER(ORDER BY birth_date DESC)) * 2 - 1 AS rang FROM employees; -- Делаем ранг нечетным (1, 3, 5 ...). Соотв четным без "- 1"



--                         Оконные функции получения значений предыдущих и следующих строк

-- 1. LAG(col_name, n, default) - оконная функция позволяет получить значение предыдущей строки, где:
--    col_name - имя стобца(?или выражение?)
--    n        - целочисленный параметр, указывающий на сколько строк выше мы берем значение
--    default  - значение по умолчанию, которое попадет в результат для тех строк, у которых нет предыдущих на расстоянии n в таблице или в рамках группы. Если не указать значение по умолчанию, то оно будет NULL
-- OVER может использовать описания окна и PARTITION BY (будем брать значение на n строк выше только в рамках одной группы) и ORDER BY (задает порядок того какие строки будут выше, а какие ниже).
SELECT title, rating, length, LAG(length, 1) OVER(PARTITION BY rating ORDER BY length) AS prev_length FROM films; -- получим значение длинны предыдущего фильма(на одну строку выше) в группах с таким же рейтингом, отсортированных по длинне
SELECT price, trade_date, LAG(price, 1, price - 1) OVER (ORDER BY trade_date) AS drop; -- получим значение цены предыдущей строки, в таблице отсортированной по trade_date. В качестве значения по умолчанию применим price текущей строки - 1


-- 2. LEAD(col_name, n, default) - аналогична LAG, но возвращает значение строки следующей после
SELECT title, rating, length, LEAD(length, 5) OVER(PARTITION BY rating ORDER BY length) AS next_five_length FROM films;



--                                          Оконные функции + группировка

-- Тк оконные функции начинают обсчитываться уже после группировки и HAVING, то мы можем использовать их поверх группировки и соответсвенно обычных агрегатных функций
-- Наоборот внутри агрегатных функций для обычных группировок использовать оконные функции уже нельзя

SELECT
  rental_date::DATE,
  COUNT(*) AS cnt,
  LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS prev_cnt,      -- тоесть вернет значение предыдущей строки, которая до того уже будет сгруппирована из нескольких строк, тоесть ее значение будет колличеством значений каждого rental_date::DATE
  COUNT(*) - LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS dif -- можем и разницу посчитать между текущем и предыдущим сгруппированным значением
FROM rental
GROUP BY rental_date::DATE;



--                                              Разные примеры

-- С условным оператором в условии оконной функции
SELECT
  *,
  SUM(CASE WHEN op = 'add' THEN amount ELSE -amount END) OVER(ORDER BY date, id) AS fl_sum
FROM actions ORDER BY date, id;


-- Оконная фунуция выводит: сумму во всех строках, сумму для каждого customer_id итд
SELECT sales_id, customer_id, cnt,
  SUM(cnt) OVER () AS total,
  SUM(cnt) OVER (ORDER BY customer_id) AS running_total,
  SUM(cnt) OVER (ORDER BY customer_id, sales_id) AS running_total_unique
FROM sales ORDER BY customer_id, sales_id;

















--
