--                                            Функции pl/pgSQL

-- pl/pgSQL - язык процедурных расширений, для написания императивного кода, например может:
-- Создавать переменные в теле функции
-- Использовать циклы и условную логику
-- Выбрасывать исключения
-- итд еще многие возможности процедурного программирования

-- Функции могут быть вызваны внутри других функций

-- Синтаксис функции pl/pgSQL - логика функции должна дополнительно обрамляться в BEGIN END, что обозначает тело метода (не относятся к аналогичному синтаксису для транзакций):
CREATE [ OR REPLACE ] FUNCTION func_name([arg1, arg2, ...]) RETURNS data_type AS $$
BEGIN
  -- тело функции с какой-то логикой
END; -- точка с запятой не обязательны
$$ LANGUAGE plpgsql;



--                                           Возврат и присвоение

-- Возврат скалярного значения производиттся из тела функции через RETURN вместо SELECT.
-- RETURN не обязателен если используем OUT-параметры
-- Возврат множественных значений (RETURNS SETOF итд) поизводится через RETURN QUERY в дополнение к SELECT


-- Скалярная функцияи на plpgsql, которая возвращает число:
CREATE OR REPLACE FUNCTION get_total_number_of_goods() RETURNS bigint AS $$
BEGIN
  -- RETURN возвращает к оператору скалярное значение от запроса:
	RETURN SUM(units_in_stock) FROM products WHERE discontinued = 1; -- нужна точка с запятой в конце
END;
$$ LANGUAGE plpgsql;
-- Оператор работает стандартно
SELECT get_total_number_of_goods();


-- Функция с OUT-параметрами и присвоением значений в их переменные:
CREATE OR REPLACE FUNCTION get_price_boundaries(OUT max_price real, OUT min_price real) AS $$
BEGIN
  -- Вариант 1: присвоим значения в переменные(OUT-параметры) по отдельности, при помощи ':=' или просто '=' (алиасы). Так на каждое присвоение будет выполнен отдельный запрос к БД
	max_price := MAX(unit_price) FROM products;
	min_price = MIN(unit_price) FROM products;
  -- Вариант 2(более предпочтительный): присвоим значения переменным одним запросом при помощи INTO
	SELECT MAX(unit_price), MIN(unit_price)
	INTO max_price, min_price
	FROM products;
	-- RETURN не обязателен если используем OUT-параметры
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_price_boundaries();


-- Функция с математической операцией над входящими переменными, чисто математическая задача вообще не связанная с таблицами
CREATE OR REPLACE FUNCTION get_sum(x int, y int, OUT result int) AS $$
BEGIN
	result = x + y; -- тоесть выходящая переменная будет принимать значение суммы входящих
	RETURN; -- тут просто чтобы досрочно выйти из функции
  -- еще какаято логика, которая уже не будет исполнена
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_sum(2, 3);


-- RETURN QUERY. Вернем колонку записей при помощи RETURNS SETOF
CREATE FUNCTION get_customers_by_country(customer_country varchar) RETURNS SETOF customers AS $$
BEGIN
	RETURN QUERY SELECT * FROM customers WHERE country = customer_country;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_customers_by_country('USA');



--                                  DECLARE. Объявление локальных переменных в функции

-- Если хотим создать новые переменные не передававшиеся в функцию через параметры, то нужен другой синтаксис, с добавлением секции DECLARE перед секцией BEGIN и определить переменные и их типы данных там

-- Функция с декларацией переменной
CREATE OR REPLACE FUNCTION get_square(ab real, bc real, ac real) RETURNS real AS $$
DECLARE
	perimeter real;       -- обявление пустой переменной
	del INT := 2;         -- при объявлении сразу можем присвоить начальное значение в новую переменную
BEGIN
	perimeter:=(ab+bc+ac)/del; -- результат расчета с использованием одной переменной присваиваем в другую
	RETURN SQRT(perimeter * (perimeter - ab) * (perimeter - bc) * (perimeter - ac)); -- считаем с применением встроенной функции
END;
$$ LANGUAGE plpgsql;
SELECT get_square(6, 6, 6);


-- Функция с применением новых переменных для выборки из таблицы
CREATE OR REPLACE FUNCTION middle_priced() RETURNS SETOF products AS $$
	DECLARE
		average_price real;
		bottom_price real;
		top_price real;
	BEGIN
		SELECT AVG(unit_price) INTO average_price FROM products; -- присваиваем значение запроса в новую переменную average_price
		bottom_price := average_price * .75;                     -- присваимваем в новые переменные значения границ цен
		top_price := average_price * 1.25;
		RETURN QUERY SELECT * FROM products WHERE unit_price BETWEEN bottom_price AND top_price; -- возвращаем строки таблицы соответсвующие границам цен из переменных
	END;
$$ LANGUAGE plpgsql;
SELECT * FROM middle_priced();



--                                            Условный оператор IF ELSE

-- Синтаксис условной логики IF ELSE:
IF expression THEN
  -- логика;
ELSIF expression THEN
  -- логика;
ELSIF expression THEN
  -- логика;
ELSE
  -- логика;
END IF;


-- Скаляреная функция с IF-THEN-ELSE переводящая цельсии в фаренгейты или наоборот
CREATE OR REPLACE FUNCTION convert_temp_to(temperature real, to_celsius bool DEFAULT true) RETURNS real AS $$
DECLARE
	result_temp real;
BEGIN
	IF to_celsius THEN -- тут оцениваем true или false тк оно будет во входящем параметре
		result_temp = (5.0/9.0)*(temperature-32);
	ELSE
		result_temp:=(9*temperature+(32*5))/5.0;
	END IF;
	RETURN result_temp; -- возвращаем значнение
END;
$$ LANGUAGE plpgsql;
-- Операторы для обоих случаев перевода
SELECT convert_temp_to(80);
SELECT convert_temp_to(26.7, false);


-- Функция с множественным ветвлением IF-ELSIF-ELSE возвращает сезон в зависимости от номера месяца
CREATE OR REPLACE FUNCTION get_season(month_number int) RETURNS text AS $$
DECLARE
	season text;
BEGIN
	IF month_number BETWEEN 3 AND 5 THEN
		season = 'Spring';
	ELSIF month_number BETWEEN 6 AND 8 THEN
		season = 'Summer';
	ELSIF month_number BETWEEN 9 AND 11 THEN
		season = 'Autumn';
	ELSE
		season = 'Winter';
	END IF;
	RETURN season;
END;
$$ LANGUAGE plpgsql;
SELECT get_season(12);



--                                            Циклы в plpgsql. Синтаксис

-- WHILE цикл. После ключевого слова WHILE с условием идет блок кода, обернутый в LOOP...END LOOP, который повторяется необходимое число раз, пока expression является TRUE:
WHILE expression
LOOP
	-- логика
END LOOP;

-- Бесконечный цикл, выход из которого осуществляется, EXIT WHEN:
LOOP
	EXIT WHEN expression
	-- логика
END LOOP;

-- FOR цикл. Вместо a и b можно подставить числовые литералы
-- BY      - задает числовой литерал n для шага, который по умолчанию равен 1
-- REVERSE - реверсирует цикл в обратном порядке, нужно чтобы a было больше b, а значение n по умолчанию станет отрицательным
FOR counter IN [REVERSE] a..b [BY n]
LOOP
	-- логика
END LOOP;

-- ?? FOREACH

-- CONTINUE - прерывает исполнение локиги и переходит к следующей итерации
CONTINUE [WHEN expression]

-- EXIT - аналог break в яп, выходит из цикла, осуществляется, когда expression в EXIT WHEN является TRUE
EXIT [WHEN expression]



--                                             Примеры циклов

-- WHILE.  Функция вычисления энного числа Фибоначи
CREATE OR REPLACE FUNCTION fibonacci(n INTEGER) RETURNS INTEGER AS $$
DECLARE
  counter INTEGER := 0;
  i INTEGER := 0;
  j INTEGER := 1;
BEGIN
  IF (n < 1) THEN
    RETURN 0;
  END IF;
  WHILE counter <= n
  LOOP
    counter := counter + 1;
    SELECT j, i + j INTO i, j; -- переназначаем значения переменных для следующих чисел Фибоначи
  END LOOP;
  RETURN i;
END;
SELECT fibonacci(3);

-- Считаем число будней между датами включительно
CREATE OR REPLACE FUNCTION weekdays(d1 DATE, d2 DATE) RETURNS INTEGER AS $$
DECLARE
  res INTEGER = 0;
BEGIN
  IF d1 > d2 THEN
    SELECT d1, d2 INTO d2, d1;
	END IF;
  WHILE d1 <= d2
  LOOP
    IF EXTRACT(DOW FROM d1) BETWEEN 1 AND 5 THEN
      res = res + 1;
    END IF;
    d1 = d1 + INTERVAL '1 day';
  END LOOP;
  RETURN res;
END;
$$ LANGUAGE plpgsql;


-- LOOP c EXIT WHEN.  Функция вычисления энного числа Фибоначи
CREATE OR REPLACE FUNCTION fibonacci (n INTEGER) RETURNS INTEGER AS $$
DECLARE
  counter INTEGER := 0;
  i INTEGER := 0;
  j INTEGER := 1;
BEGIN
  IF (n < 1) THEN
    RETURN 0;
  END IF;
  LOOP
    EXIT WHEN counter > n;
    counter := counter + 1;
    SELECT j, i + j INTO i, j;
  END LOOP;
  RETURN i;
END;
$$ LANGUAGE plpgsql;
SELECT fibonacci(3);


-- FOR IN.  Для анонимноых блоков кода
DO $$
BEGIN
  FOR counter IN 1..5 LOOP
  	RAISE NOTICE 'Counter: %', counter; -- выведем сообщение "Counter: n" в месенджер
  END LOOP;
END; $$
-- FOR IN с REVERSE
DO $$
BEGIN
  FOR counter IN REVERSE 5..1 LOOP
    RAISE NOTICE 'Counter: %', counter;
  END LOOP;
END; $$
-- FOR IN с BY
DO $$
BEGIN
  FOR counter IN 1..6 BY 2 LOOP
    RAISE NOTICE 'Counter: %', counter;
  END LOOP;
END; $$


-- FOR IN. Для итерации запроса
CREATE OR REPLACE FUNCTION iter_over_query(n INTEGER DEFAULT 5) RETURNS VOID AS $$
DECLARE
  rec RECORD;  -- RECORD - тоесть тип данных запрос ??
BEGIN
  FOR rec IN
		SELECT * FROM products ORDER BY unit_price LIMIT n
  LOOP
 		RAISE NOTICE '%', rec.product_name; --don't forget to look at messages
  END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM iter_over_query();



--                                    RETURN NEXT (Неэффективен по быстродействию)

-- Иногда нам нужно делать построчный процессинг, тоесть накапливать записи в результирующем наборе, тоесть обрабатывать каждую строку и помещать(возвращать) ее в результирующий набор. Как правило это все делается в цикле

RETURN NEXT expression; -- возвращает/накапливает записи в результирующий набор. Это выражение можно вызывать несколько раз и результатом каждого вызова будет новая строка в выходном наборе данных.

-- Циклы проходящие по большому числу данных, например через SELECT-запросы, это как правило не очень хорошо, тк потенциально имеет плохую производительность.
-- В 99% случаев все что написано с RETURN NEXT можно переписать при помощи обычного декларативного SQL, который работает с кортежами и работать это будет быстрее и будет более читабельно, даже если это будет несколько селектов с UNION. Чем больше будет данных, тем медленне будет цикл относительно обычного запроса.
-- Тоесть желательно решать при помощи RETURN NEXT только те задачи, что не получается решить в декларативном SQL


-- Простейший пример функции с RETURN NEXT:
CREATE OR REPLACE FUNCTION return_setof_int() RETURNS SETOF int AS $$
BEGIN
	-- вернем набор из 3х целых чисел при помощи RETURN NEXT
  RETURN NEXT 1; -- значение 1 отправляется в результирующий набор
  RETURN NEXT 2; -- значение 2 отправляется в результирующий набор
  RETURN NEXT 3;
  RETURN;        -- необязательно
END
$$ LANGUAGE plpgsql;
SELECT * FROM return_setof_int() -- выведет столбец со значениями 1, 2, 3


-- Пример функции, что проходит по таблице продуктов и меняет их цену в зависимости от категории. Но так лучше не писать в реальности, тк даже если заменить это на 3 селекта с UNION, то будет скорее всего работать быстрее
CREATE OR REPLACE FUNCTION after_christmas_sale() RETURNS SETOF products AS $$
DECLARE
	product record; -- тип record, это некая запись ?? нужен чтобы хранить набор данных ??
BEGIN
	FOR product IN
		SELECT * FROM products -- тоесть на каждой итерации в переменную product попадает текущая запись/строка из результирующего набора данного SELECT-запроса
	LOOP
		IF product.category_id IN (1,4,8) THEN
			product.unit_price = product.unit_price * .80; -- модифицируем значение unit_price, у текущей записи из переменной product
		ELSIF product.category_id IN (2,3,7) THEN
			product.unit_price = product.unit_price * .75;
		ELSE
			product.unit_price = product.unit_price * 1.10;
		END IF;
		RETURN NEXT product; -- помещаем/накапливаем модифицированную запись в результирующий набор
	END LOOP;
	RETURN; -- не обязателен
END;
$$ LANGUAGE plpgsql;
SELECT * FROM after_christmas_sale(); -- выведет запрос аналогичный изначальной таблице но с модифицированными ценами



--                                              Итерация массива

-- FOR для итерациеи массива
CREATE OR REPLACE FUNCTION filter_even(variadic numbers int[]) RETURNS SETOF int AS $$
BEGIN
  FOR counter IN 1..array_upper(numbers, 1) LOOP
		CONTINUE WHEN counter % 2 != 0;
		RETURN NEXT counter;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM filter_even(1, 2, 3, 4, 5, 6);


-- ?? FOREACH для итерации массива
CREATE OR REPLACE FUNCTION filter_even(variadic numbers int[]) RETURNS SETOF int AS $$
DECLARE
	counter int;
BEGIN
  FOREACH counter IN ARRAY numbers LOOP
   	CONTINUE WHEN counter % 2 != 0;
   	RETURN NEXT counter;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM filter_even(1, 2, 3, 4, 5, 6);


















--
