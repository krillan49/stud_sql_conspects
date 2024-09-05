--                                           Window Functions

-- Window Functions / Оконная функция - если после функции идет OVER(), значит она оконная.

-- OVER() - берет все строки как при группировке и высчитывает значение из них при помощи функции, которая шла до, только в отличие от группировке остаются все строки и результат функции будет в каждой
SELECT rating, length, MIN(langth) OVER() AS min_length FROM films;

-- Оконными функциями могут быть все агрегатные функции(применяемые при группировке)
SELECT rating, length,
  COUNT(*) OVER() AS count, -- COUNT точно так же может принимать не только столбец или выражение но и *
  MIN(langth) OVER() AS min_length,
  MAX(langth) OVER() AS max_length,
  AVG(langth) OVER() AS avg_length
FROM films;

-- Внутри круглых скобок OVER() чаще всего идет описание окна:

-- PARTITION BY  - описывает окно, аналог GROUP BY для оконных функций, после нее мы указываем на какие группы нужно разбить все строки и какую группу из них взять. При указании какой-то колонке это будет значить, что в группу нужно взять все строки из таблицы у которых значение в этой колонке соответсвует его значению в данной строке.
SELECT rating, length, MIN(langth) OVER(PARTITION BY rating) AS min_rating_length FROM films; -- тоесть для каждой строки берем все строки с таким же рейтингом и высчимтываем минимальную длинну среди них. Тоесть выясняем минимальную продолжительность для фильмов с каждым рейтингом и добавляем к каждой строке фильма соответсвующее значение



--                                               WINDOW

-- Если у всех оконных функций в запросе одно и тоже описание окна, то мы можем описать его в разделе WINDOW, а в OVER просто передать его название

-- WINDOW пишется до ORDER BY

SELECT rating, length, COUNT(*) OVER w AS count, MIN(langth) OVER w AS min_length, MAX(langth) OVER w AS max_length
FROM films
WINDOW w AS (PARTITION BY rating);
-- w - название для окна



--                                          Ранжирующие оконные функции

-- Ранжирующие оконные функции - уже не существуют как агрегатные и нужны для того чтобы назначать номера для каждой строки. Все виды ранжирующих функций можно использовать в одном запросе одновременно, тк они простодобавят новые колонки


-- 1. ROW_NUMBER() - выведет порядковые номера для каждой строки, всегда выдает строкам разные номера

-- OVER(PARTITION BY ...) - разбивает на группы по столбцу и выражению и выдает порядковые номера для каждой из груп отдельные, те для каждой из групп начинается снова с 1. Но внутри групп они будут взяты в случайном порядке
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating) AS rn FROM films;

-- OVER(ORDER BY ... [DESC]) - выдает номера всей таблице(без разбиения на группы) в соответсвии с описанием сортировки
SELECT title, rating, length, ROW_NUMBER() OVER(ORDER BY length) AS rn FROM films;

-- OVER(PARTITION BY ... ORDER BY ... [DESC]) - разбивает на группы по колонке, колонкам или выражею и дает номера кадой группе отсортированные по строке строкам или выражению в ORDER BY ... [DESC]
SELECT title, rating, length, ROW_NUMBER() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;

-- Другие примеры
SELECT ROW_NUMBER() OVER(ORDER BY SUM(points) DESC) AS rank FROM people GROUP BY some;       -- с группировкой
ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY count(*) DESC, category.name DESC) AS category_rank  -- разбивка ранга по значениям столбца store_id (когда новое значения ранг начинается снова с 1 при каждом новом значении store_id)

-- Делаем ранк нечетным (1, 3, 5 ...). Соотв четным без "- 1"
SELECT *, (ROW_NUMBER() OVER(ORDER BY birth_date DESC)) * 2 - 1 AS rank FROM employees


-- 2. RANK() - использует теже варианты описания окна как и ROW_NUMBER() но при одинаковых значениях сортируемого значения(тоесть при одинаковом порядке сортировки) ставит одинаковый ранг. Дальнейший ранг учитывает все предыдущие строки до, например 1, 1, 3
SELECT title, rating, length, RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;

-- Другие примеры
SELECT sale, RANK() OVER(ORDER BY sale DESC, some DESC) AS srank FROM sales  -- ранг по 2м полям, если 1е равно использует 2е


-- 3. DENSE_RANK() - использует теже варианты описания окна как и ROW_NUMBER() и RANK() но при одинаковых значениях сортируемого значения(тоесть при одинаковом порядке сортировки)  ставит одинаковый ранг. Дальнейший ранг не учитывает все предыдущие сттроки до, например 1, 1, 2
SELECT title, rating, length, DENSE_RANK() OVER(PARTITION BY rating ORDER BY length) AS rn FROM films;


-- 4. NTILE(n) - оконная функция при помощи которой СУБД само(автоматически) разобьет на n категорий всю таблицу или в рамках каких-то групп и выдает номер каждой такой подкатегории. Если колличество подкатегорий больше строк в группе или тоблице, то каждая строка попадет в отдельную подкатегорию; если зададим только 1 подкатегорию то в нее попадет вся таблица или группа; если число строк в группе или таблице не делится нацело на n, то подкатегории с большим числом строк(на 1) будут в начале. OVER может использовать описания окна и PARTITION BY и ORDER BY(для задания порядка по которому собственно делятся категории)
SELECT title, rating, length, NTILE(8) OVER(PARTITION BY rating ORDER BY length) AS group_id FROM films;



--                         Оконные функции получения значений предыдущей и следующей строки

-- 1. LAG(col_name, n) - оконная функция позволяет получить значение предыдущей строки, сама функция принимает имя стобца и целочисленное значение, указывающее насколько строк выше мы берем значение. OVER может использовать описания окна и PARTITION BY(тоесть юудем брать значение на n строк выше только в рамках одной группы) и ORDER BY(собственно задает порядок какие строки будут выше, а какие ниже). Для тех строк у которых нет предыдущих на расстоянии n в таблице или в рамках группы добавит значение NULL в эту колонку
SELECT title, rating, length, LAG(length, 1) OVER(PARTITION BY rating ORDER BY length) AS prev_length FROM films; -- Получим значение длинны предыдущего фильма(на одну строку выше) с таким же рейтингом те узнаем насколько текущий фильм длинне предыдущего

-- Другие примеры
LAG(price, 1, price - 1) OVER (ORDER BY trade_date) AS drop


-- 2. LEAD(col_name, n) - все точно так же как и у LAG, только возвращает значения следующих строк
SELECT title, rating, length, LEAD(length, 5) OVER(PARTITION BY rating ORDER BY length) AS next_five_length FROM films;



--                                          Оконные функции + группировка

-- Тк оконные функции начинают обсчитываться уже после группировки и HAVING, то мы можем использовать их поверх группировки и обычных агрегатных функций
-- Наоборот внутри агрегатных функций для обычных группировок использовать оконные функции уже нельзя

SELECT rental_date::DATE, COUNT(*) AS cnt,
  LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS prev_cnt, -- тоесть вернет значение предыдущей уже до того сгруппированной из нескольких строк строки
  COUNT(*) - LAG(COUNT(*), 1) OVER(ORDER BY rental_date::DATE) AS dif -- можем и разницу посчитать между текущем и предыдущим сгруппированным значением
FROM rental
GROUP BY rental_date::DATE



--                                            Задание рамок окна

-- Можно задать значения рамок окна и взять только некоторые строки а не все из таблицы или группы, чтобы обсчитать их в оконной функции

-- ROWS BETWEEN - задает рамки окна

-- Получим число продаж на каждый день
WITH rent_day AS (
  SELECT rental_date::DATE AS rent_day, COUNT(*) AS cnt FROM rental GROUP BY rental_date::DATE
)
-- Проссуммируем продажи за каждые 3 дня, для 1й строки возьмет только 1 день, для 2й только 2, далее по 3
SELECT rent_day, cnt,
  SUM(cnt) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS tree_days_cnt,
  SUM(cnt) OVER(ORDER BY rent_day ROWS BETWEEN 2 PRECEDING AND 3 FOLlOWING) AS week_cnt
FROM rent_day;
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW - тоесть берет 2 строки между включительно 2мя(начало диапазона) до и текущей(конец диапазона) == 3
-- CURRENT ROW  - текущая строка
-- 2 PRECEDING  - количество строк(тут 2) до текущей
-- UNBOUNDED PRECEDING - все строки до текущей
-- 3 FOLlOWING  - количество строк(тут 3) после текущей
-- UNBOUNDED FOLlOWING - все строки после текущей

















--
