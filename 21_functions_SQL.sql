-- Непонятно:
-- RETURNING <- Оператор функции. VOID. RETURNING



--                                 Синтаксис создания функции на языке SQL

-- CREATE FUNCTION            - Создает новую функцию
-- CREATE OR REPLACE FUNCTION - Создает новую функцию или модифицирует уже существующую функцию с этим названием, тоесть заменяет функционал(тело) на новый
CREATE [OR REPLACE] FUNCTION func_name([arg1, arg2, ...]) RETURNS data_type AS $$
  -- тело функции с какой-то логикой
$$ LANGUAGE lang;
-- arg1, arg2, ...    - Аргументы функции(не обязательны) - переменные с типами данных
-- RETURNS data_type  - указываем тип данных, которые будут возвращены
-- $$                 - знак открытия и закрытия тела функции (есть еще способ с кавычками он он хуже, тк придется экранировать кавычки в логике функции, использовались до 8й версии )
-- LANGUAGE lang      - указываем язык(либо SQL, либо PL\pgSQL)



--                                 DROP FUNCTION. Синтаксис удаления функции

-- OR REPLACE при создании функции не всегда может помочь, потому может пригодиться синтакс удаления функции
DROP FUNCTION func_name;
DROP FUNCTION IF EXISTS func_name;



--                                      Оператор функции. VOID. RETURNING

-- Функция без аргументов, в которой будем заменять в таблице tmp_customers значения NULL на 'unknown'
CREATE OR REPLACE FUNCTION fix_customer_region() RETURNS void AS $$
	-- RETURNS void   - тк функция будет только изменять значения и ничего не будет возвращать(NULL)
	UPDATE tmp_customers
  SET region = 'unknown'
  WHERE region IS NULL
$$ LANGUAGE sql;
-- Чтобы запустить функцию, нужно вызвать ее оператор, если функция ничего не возвращает как тут, то вернет NULL. Вызывается, через SELECT-запрс к ее оператору:
SELECT fix_customer_region();


-- ???
-- Если функция не объявлена ​​возвращающей void, последний оператор должен быть SELECT или INSERT, UPDATE или DELETE с предложением RETURNING.
CREATE OR REPLACE FUNCTION fix_customer_region() RETURNS TABLE(...какието столбцы соотв возвращенному...) void AS $$
	UPDATE tmp_customers
  SET region = 'unknown'
  WHERE region IS NULL
	RETURNING *; -- возврвщаем измененную таблицу
$$ LANGUAGE sql;
SELECT * FROM fix_customer_region();



--                                           DO. Анонимная функция

-- DO - выполняет анонимный блок кода/временную анонимную функцию.
-- Блок кода обрабатывается так, как будто это тело функции без параметров, возвращающей void. Он анализируется и выполняется только один раз.

DO $$
BEGIN
	SELECT SUM(units_in_stock) FROM products
END$$;



--                                          Скалярные функции

-- Скалярные функции - это функции возврвщающие одно единственное значение. Внутри такой функции нельзя писать SQL-запрос, который возвращает более 1 значения, тк будет вызвана ошибка

-- Скалярная функция, которая вернет максимальную цену, тоесть число
CREATE OR REPLACE FUNCTION get_max_price_from_discontinued() RETURNS real AS $$
	SELECT MAX(unit_price) FROM products WHERE discontinued = 1
$$ LANGUAGE sql;
SELECT get_max_price_from_discontinued() AS max_price;
-- AS - именовать вывод нужно тут у оператора, тк в самой функции AS будет проигнорирован



--                             Аргументы SQL-функций: IN, OUT, INOUT, VARIADIC, DEFAULT

-- IN       - неявно(по умолчанию) помечает входящие аргуметы, которые мы объявляем. Можно указывать и явно
-- OUT      - помечает исходящие аргументы, для вывода от оператора функции, объявляются так же внутри круглых скобок в строке создания функции, а не после RETURNS, тоесть можем опустить RETURNS, когда используем OUT-аргументы
-- INOUT    - помечает аргумент, который используется и как входящий и как исходящий
-- VARIADIC - помечает массив входящих параметров, тоесть оперетор может передавать любое колличество значений через запятую
-- DEFAULT  - присваивает аргументу значение по умолчанию (на случай если аргумент не передан), прописываем после имени аргумента и типа данных

-- Типы данных должны быть как в таблице (или совместимые с ними ??)


-- IN.  Функция, вернет цену продукта по его имени
CREATE OR REPLACE FUNCTION get_product_price_by_name(prod_name varchar) RETURNS real AS $$
	-- prod_name varchar - задаем входящий(IN задан неявно) аргумент переменной с произвольным именем и типом данных
	SELECT unit_price FROM products
	WHERE product_name = prod_name  -- тоесть выбираем строку по соответсвию значения из аргумента
	-- тут на самом деле нет гарантии что название уникально и может вернуться таблица, (? тоесть будет ошибка), соотв надо продумать это заране
$$ LANGUAGE sql;
-- Оператор/клиентский код при вызове функции передает значение в аргумент, предполагаемого типа данных
SELECT get_product_price_by_name('Chocolade') AS price;


-- OUT.  Функция с OUT-аргументами для вывода максимальной и минимальной цены. Тут можем опустить RETURNS
CREATE OR REPLACE FUNCTION get_price_boundaries(OUT max_price real, OUT min_price real) AS $$
	SELECT MAX(unit_price), MIN(unit_price) -- последовательность вывода нужно сопоставить с последовательностью аргументов, когда мы пишем функции на языке sql
	FROM products
$$ LANGUAGE sql;
-- При таком вызове мы получим так называемый record все будет в одной колонке
SELECT get_price_boundaries();
-- А если нужно получить каждое значение в отдельной колонке то нужно вызывать
SELECT * FROM get_price_boundaries();


-- Функция и с IN(не обязательно прописывать) и с OUT параметрами
CREATE OR REPLACE FUNCTION get_freight_boundaries(IN start_date date, end_date date, OUT max_price real, OUT min_price real) AS $$
	SELECT MAX(freight), MIN(freight) FROM orders WHERE shipped_date BETWEEN start_date AND end_date
$$ LANGUAGE sql;
-- Вызываем и передаем значения для IN-аргументов
SELECT get_freight_boundaries('1997-06-01', '1997-06-12');
SELECT * FROM get_freight_boundaries('1997-06-01', '1997-06-12');


-- DEFAULT.  Функция с DEFAULT значением для IN-аргумента
CREATE OR REPLACE FUNCTION get_price_boundaries_by_discont(
		is_discontinued int DEFAULT 1, OUT max_price real, out min_price real
	) AS $$
	SELECT MAX(unit_price), MIN(unit_price) FROM products WHERE discontinued = is_discontinued
$$ LANGUAGE sql;
-- Теперь при вызове можем как передавать параметр, так и не передавать
SELECT * FROM get_price_boundaries_by_discont(1);
SELECT * FROM get_price_boundaries_by_discont();



--                                    Возврат наборов данных(множества строк)

--see also (todo):
-- https://dba.stackexchange.com/questions/96109/return-type-of-joining-stored-procedure-postgresql


-- RETURNS SETOF data_type  - возврат набора скалярных значений (одна колонка) типа data_type
-- RETURNS SETOF table_name - если нужно вернуть все столбцы из таблицы или значения какого-то пользовательского типа
-- RETURNS SETOF record     - только когда типы колонок в результирующем наборе неизвестны
-- RETURNS TABLE (column_name data_type, ...) - тоже что и SETOF table_name, но имеем возможность явно указывать возвращаемые столбцы, тоесть вернуть только необходимые нам столбцы, а не все

-- Возврат через out-параметры, как делали выше для скалярных функций, когда опущена запись RETURNS SETOF record, но это будет возврат не множества строк а одной строки с несколькими значениями.
-- RETURNS SETOF record без out-параметров позволяет работать по другому


-- RETURNS SETOF data_type. Функция возвращает набор значений примитивного типа. Тут средние цены разбитые по категориям
CREATE OR REPLACE FUNCTION get_average_prices_by_categories() RETURNS SETOF double precision AS $$
	SELECT AVG(unit_price) FROM products GROUP BY category_id
$$ LANGUAGE sql;
-- оператор вернет колонку значений
SELECT * FROM get_average_prices_by_categories() AS average_prices;


-- RETURNS SETOF record и OUT-parameters. Функция возвращающая набор(колонки) значений. Например берет суммы и средние цены по категорям продуктов
CREATE OR REPLACE FUNCTION get_prices_by_prod_cats(OUT sum_price real, OUT avg_price float8)
RETURNS SETOF record AS $$ -- пропишем RETURNS SETOF явно, так мы сможем вернуть столбцы, иначе вернет только 1 строку, первую что встретится видимо
	SELECT SUM(unit_price), AVG(unit_price) FROM products GROUP BY category_id;
$$ LANGUAGE sql;
-- Можем вызывать операторы по тем колонкам, которым хотим
SELECT sum_price FROM get_prices_by_prod_cats();
SELECT sum_price, avg_price FROM get_prices_by_prod_cats();
-- Вызов не сработает если дадим левые имена колонкам
SELECT sum_of, in_avg FROM get_prices_by_prod_cats();
-- Чтобы так сделать нужно создать алиасы
SELECT sum_price AS sum_of, avg_price AS in_avg FROM get_prices_by_prod_cats();


-- RETURNS SETOF record без OUT-parameters. Функция возвращающая набор(колонки) значений. Это используется когда мы не знаем какие колонки нужно вернуть. Но лучше так не писать
CREATE OR REPLACE FUNCTION get_average_prices_by_product_categories() RETURNS SETOF record AS $$
	SELECT SUM(unit_price), AVG(unit_price) FROM products GROUP BY category_id;
$$ LANGUAGE sql;
-- Так не сработает и выдаст ошибку, тк у функций имеющих запись должен быть список с определением столбцов
SELECT sum_price, avg_price FROM get_average_prices_by_product_categories();
SELECT * FROM get_average_prices_by_product_categories();
-- Чтобы вывод сработал, нужно указать аргументы и типы тут
SELECT * FROM get_average_prices_by_product_categories() AS (sum_price real, avg_price float8);


-- RETURNS TABLE. Напишем функцию, что вернет клиентов по стране, которая будет входным аргументом
CREATE OR REPLACE FUNCTION get_customers_by_country(customer_country varchar)
RETURNS TABLE(char_code char, company_name varchar) AS $$
	SELECT customer_id, company_name FROM customers WHERE country = customer_country
$$ LANGUAGE sql;
-- правила селекта вызова функции те же, что и при RETURNS SETOF
SELECT * FROM get_customers_by_country('USA');
SELECT company_name FROM get_customers_by_country('USA');
SELECT char_code, company_name FROM get_customers_by_country('USA');


-- RETURNS SETOF table
CREATE OR REPLACE FUNCTION get_customers_by_country(customer_country varchar) RETURNS SETOF customers AS $$
	-- SELECT company_name, contact_name  - такая выборка не будет работать, тк мы обязаны вернуть все столбцы
	SELECT * FROM customers WHERE country = customer_country
$$ LANGUAGE sql;
-- Можем делать и выборки по столбцам и вызывать все
SELECT * FROM get_customers_by_country('USA');
SELECT contact_name, city FROM get_customers_by_country('USA');

-- Сложный пример
CREATE OR REPLACE FUNCTION sold_more_than(min_sold_boundary int) RETURNS SETOF products AS $$
	SELECT * FROM products WHERE product_id IN (
		SELECT product_id FROM (
			SELECT SUM(quantity), product_id FROM order_details GROUP BY product_id HAVING SUM(quantity) > min_sold_boundary
	  ) AS filtered_out
	)
$$ LANGUAGE sql;
SELECT sold_more_than(100);


















--
