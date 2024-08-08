--                                           Функции pl/pgSQL

-- pl/pgSQL - язык расширений, он позволяет:
-- Создавать переменные в теле функции
-- Использовать циклы и условную логику
-- Выбрасывать исключения
-- итд еще многие возможности процедурного программирования

-- Синтаксис функции pl/pgSQL. Синтаксис похож, но логика функции должна дополнительно обрамляться в BEGIN END, что обозначает тело метода (не относятся к аналогичному синтаксису для транзакций):
CREATE [ OR REPLACE ] FUNCTION func_name([arg1, arg2, ...]) RETURNS data_type AS $$
BEGIN
  -- тело функции с какой-то логикой
END; -- точка с запятой не обязательно
$$ LANGUAGE plpgsql;



--                                           Возврат и присвоение

-- RETURN в plpgsql: Возврат значения через RETURN вместо SELECT или RETURN QUERY в дополнение к SELECT для возврата множественных значений


-- Пример скалярной функции, которая возвращает число:
CREATE OR REPLACE FUNCTION get_total_number_of_goods() RETURNS bigint AS $$
BEGIN
  -- RETURN возвращает к оператору скалярное значение от запроса:
	RETURN sum(units_in_stock) FROM products WHERE discontinued = 1; -- нужна точка с запятой в конце
END;
$$ LANGUAGE plpgsql;
-- Оператор такой же
SELECT get_total_number_of_goods();


-- Пример функции с OUT-параметрами и присвоение значений в переменные:
CREATE OR REPLACE FUNCTION get_price_boundaries(OUT max_price real, OUT min_price real) AS $$
BEGIN
  -- Вариант 1: присвоим значения в переменные(OUT-параметры) по отдельности, при помощи ':=' или просто '=' (алиасы). Так на каждое присвоение будет выполнен отдельный запрос к БД
	max_price := MAX(unit_price) FROM products;
	min_price = MIN(unit_price) FROM products;
  -- Вариант 2(более предпочтительный): присвоим значения переменным одним запросом при помощи INTO
	SELECT MAX(unit_price), MIN(unit_price)
	INTO max_price, min_price
	FROM products;
END;
$$ LANGUAGE plpgsql;
-- Оператор работает стандартно
SELECT * FROM get_price_boundaries();


-- Пример с математической операцией над входящими переменными
CREATE OR REPLACE FUNCTION get_sum(x int, y int, OUT result int) AS $$
BEGIN
	result = x + y; -- тоесть выходящая переменная будет принимать значение суммы входящих
	RETURN; -- тут нужен просто чтобы досрочно выйти из функции
  -- еще какаято логика, которая уже не будет исполнена
END;
$$ LANGUAGE plpgsql;
-- Оператор работает стандартно
SELECT * FROM get_sum(2, 3);


-- RETURN QUERY. Вернем колонку записей при помощи RETURNS SETOF
CREATE FUNCTION get_customers_by_country(customer_country varchar) RETURNS SETOF customers AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM customers WHERE country = customer_country;
END;
$$ LANGUAGE plpgsql;
-- Оператор работает стандартно
SELECT * FROM get_customers_by_country('USA');



--                                      Декларация/объявление переменных

-- Если хотим создать новые переменные не передававшиеся через параметры, то нужен другой синтаксис, с добавлением секции DECLARE перед секцией BEGIN и определить переменные и их типы данных там

-- Синтаксис декларации переменных
CREATE OR REPLACE FUNCTION func_name([ag1, arg2...]) RETURNS data_type AS $$
DECLARE
	variable var_type;
  variable2 var2_type;
BEGIN
  -- логика;
END;
$$ LANGUAGE plpgsql;


-- Пример функции с декларацией переменных, тут напримр геометрическая задача вообще не связанная с таблицами
CREATE OR REPLACE FUNCTION get_square(ab real, bc real, ac real) RETURNS real AS $$
DECLARE
	perimeter real;
BEGIN
	perimeter:=(ab+bc+ac)/2;
	RETURN sqrt(perimeter * (perimeter - ab) * (perimeter - bc) * (perimeter - ac)); -- тут считаем с применением встроенной функции
END;
$$ LANGUAGE plpgsql;
-- Оператор работает стандартно
select get_square(6, 6, 6)


-- Пример с вычислением средней цены по продуктам из таблицы и от нее расчета вехней и нижней границы цен
CREATE OR REPLACE FUNCTION middle_priced() RETURNS SETOF products AS $$
	DECLARE
		average_price real;
		bottom_price real;
		top_price real;
	BEGIN
		SELECT AVG(unit_price) INTO average_price FROM products; -- присваиваем значение запроса в average_price
		bottom_price := average_price * .75; -- используем новые переменные, присваимваем в них значения границ це
		top_price := average_price * 1.25;
		RETURN QUERY SELECT * FROM products WHERE unit_price BETWEEN bottom_price AND top_price; -- возвращаем строки соотв границам цен из переменных
	END;
$$ LANGUAGE plpgsql;
SELECT * FROM middle_priced();



--                                              Логика с IF ELSE

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


-- Функция с IF-THEN-ELSE переводящая цельсии в фарингейты или наоборот
CREATE OR REPLACE FUNCTION convert_temp_to(temperature real, to_celsius bool DEFAULT true) returns real AS $$
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
CREATE OR REPLACE FUNCTION get_season(month_number int) returns text AS $$
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

















--
