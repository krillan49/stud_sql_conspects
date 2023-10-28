--                                  Оператор выбора SELECT и сопутсвующие операторы

-- SELECT  -  выбирает данные, удовлетворяющие заданным условиям

SELECT "Hello world"                                              --#=> "Hello world"  можно выводить данные не только из таблиц базы данных, но и произвольные литералы
SELECT (5 * 2 - 6) / 2 AS Result;                                 --#=> 2 можно выводить результаты арифметических действий, тут в столбец Result
-- (PostgreSQL чтобы название столбца сохраняло регистр он должен быть в "")

SELECT * FROM Cars                                                --#=> выбрать строки всех(*) столбцов из таблицы "Cars"
SELECT Id, FirstName FROM Customers                               --#=> выбрать строки столбцов "Id" и "FirstName" из таблицы "Customers"  (можно выбирать столбцы в любом порядке)

SELECT *, 'US' AS location FROM ussales                           --#=> если нужно добавить новый столбец в запросе


-- AS псевдонимы(алиасы)(могут содержать до 255 знаков) таблиц и столбцов: позволяет использовать псевдонимом таблицы или столбца, чтоб не писать длинное название
SELECT "Строка" AS String                                         --#=> литерал "Строка" в столбце с псевдонимом String
SELECT member_id, member_name AS Name FROM FamilyMembers          --#=> выводим 2 поля, при этом 2е с другим названием при помощи псевдонима
SELECT member_id, member_name Name FROM FamilyMembers             --#=> тоже самое только без AS тк писать его не обязательно, можно просто через пробел
SELECT * FROM Customers C WHERE C.Id < 5                          --#=> определяем и потом используем псевдоним таблицы(C для Customers) при работе с WHERE
SELECT name AS 'Имя' FROM people                                  --#=> [MySQL ?] псевдоним колонки name русским шрифтом


-- Встроенная функция это реализованный в СУБД кусок кода, выполняет преобразования строковых, числовых итд данных в запросах. Может иметь 0 или несколько аргументов. Возвращает какой-то литерал.
SELECT UPPER("Hello world") AS upper_string;                      --#=> "HELLO WORLD". Функция UPPER возвращает строку в верхнем регистре
SELECT LOWER('SQL Academy') AS lower_string;                      --#=> "sql academy"  Функция LOWER возвращает строку в нижнем регистре
SELECT YEAR("2022-06-16") AS year;                                --#=> 2022           Функция YEAR/MONTH/DAY/HOUR/MINUTE возвращает год/месяц/... для указанной даты
SELECT EXTRACT(MONTH FROM payment_date) AS month FROM payment     --#=> [postgresql]  Для timestamp without time zone
SELECT INSTR('sql-academy', 'academy') AS idx;                    --#=> 5              Функция INSTR поиск подстроки в строке, возвращая позицию её первого символа(отсчёт начинается с единицы)
SELECT LENGTH('sql-academy') AS str_length;                       --#=> 11             Функция LENGTH возвращает длину указанной строки
SELECT LEFT('sql-academy', 3);                                    --#=> "sql"          Функция LEFT возвращает заданное количество крайних левых символов строки
SELECT RIGHT('XYZ', - 1)                                          --#=> 'YZ'           Обрезка с отрицательным индексом соотв тут оставляем все символы справа кроме первого

-- Функции можно применять не только над литералами, но и над значениями, взятыми из таблицы(обязательны псевдонимы). При этом функция выполняет преобразования для каждой строки отдельно.
SELECT LENGTH(name) AS fullname_length FROM FamilyMembers;                         --#=> выведет столбец с длинами соотв имен из столбца name, тут псевдоним обязателен
SELECT CONCAT(prefix, '-', first, '+', last, 'вася', suffix) AS title FROM names   --#=> объединение строковых значений столбцов в один столбец с добавлением доп строчных элементов
SELECT CONCAT_WS(' ', prefix, first, last, suffix) AS title FROM names             --#=> тоже самое что и выше, но если между значениями нужен одинаковый элемент(тут пробел)
SELECT first_name || ' ' || last_name AS full_name FROM rentals                    --#=> [postgresql ??] тоже что и 2 выше
SELECT REPEAT(name, 3) AS name FROM monsters                                       --#=> REPEAT(стобец, число повторений) - повторяет строковое значение.
SELECT REVERSE(chars) AS chars FROM monsters                                       --#=> реверсирует строку
SELECT SPLIT_PART(chars, ',', 1) AS char FROM monsters                             --#=> разбивает строку chars по ','(тут) и выбирает 1й(тут) из разбитых кусков(только для PostgreSQL ??)
SELECT INITCAP(name) AS shortlist FROM elves                                       --#=> capitalize name
SELECT CAST(id AS TEXT) AS textid FROM monsters;                                   --#=> преобразование типов данных(тут INTEGER в TEXT)
SELECT hits::FLOAT / at_bats AS batting_average FROM yankees                       --#=> [postgresql] преобразование типов данных(тут INTEGER в FLOAT)
SELECT (hits::FLOAT/at_bats)::TEXT AS batting_average FROM yankees                 --#=> [postgresql] преобразование типов данных
SELECT LEAST(compasses, gears, tablets) AS small FROM some                         --#=> [postgresql ??] выбирает наименьшее из значений
SELECT GREATEST(1, 2, 3)                                                           --#=> [postgresql ??] выбирает наибольшее из значений(тут 3)

-- Операции над результатом функции - тк каждая функция возвращает литерал, то её результат также можно использовать в дальнейших расчётах и преобразованиях при помощи функций.
SELECT UPPER(LEFT('sql-academy', 3)) AS str;                                       --#=> "SQL"          выполняем UPPER над результатом функции LEFT
SELECT CONCAT(UPPER(LEFT(name,1)), LOWER(RIGHT(name,LENGTH(name)-1))) FROM some    --#=> capitalize name

-- Обрезка дат в [postgresql]  DATE_TRUNC(field, source [, time_zone ])
-- (Значения для обрезки: microseconds milliseconds second minute hour day week month quarter year decade century millennium)
SELECT DATE_TRUNC('hour', timestamp '2020-06-30 17:29:31');                        --#=> 2020-06-30 17:00:00  - все дальше часа будет нулями
SELECT DATE_TRUNC('hour', timestamp with time zone '2020-06-30 17:29:31+00')       --#=> 2020-07-01 03:00:00+10
SELECT DATE_TRUNC('month', created_at)::DATE AS date FROM posts GROUP BY date      --#=> реальный пример с переводом в дату в конце и группировкой по дате(2022-10-01)

-- ROUND(22.29, 1) - 1й параметр флоат число, 2й число знаков до которых будет округление(без 2го параметра округляет до целого)
SELECT ROUND(22.29, 1);                                                                         --#=> 22.3
SELECT ROUND(22.29, -1)                                                                         --#=> 20
SELECT ROUND(j.salary)::FLOAT AS average_salary FROM job GROUP BY j.job_title                   --#=> [PostgreSQL] округление и преобразование во флоат(из такого 0.29e0)
SELECT ROUND(val::NUMERIC, 2)::FLOAT AS valround FROM float8                                   --#=> [PostgreSQL] округление до 2х знаков необходимо переводить в NUMERIC если есть параметр(2) и ошибка

-- TO_CHAR [PostgreSQL ??] - перевод в строку с определенным числом нулей после точки и еще всяким(тут символ %)
TO_CHAR(num, 'FM999990.0%')

-- Регулярные выражения:
SELECT city_name FROM stations WHERE city_name ~ '^[AEIOU]'  -- ищем соотв значения(тут с первой буквой из указанных)
-- SUBSTRING(имя_столбца FROM 'регулярное_выражение')   вырезать из строки по шаблону
SELECT SUBSTRING(greeting FROM '#\d+') AS user_id FROM greetings                   --#=> Bienvenido 45454545 tal #470815 BD. WA470815   ->  #470815
-- REGEXP_REPLACE(строка, регулярка, элемент замены, позиция(число, не обязательно))  -  заменить элементы строки
SELECT REGEXP_REPLACE('1, 4, и 10 числа', '\d', '@') FROM dual                     --#=> '@, @, и @@ числа' [ORACLE PL/SQL] меняем любую цифру на @ (само меняет все цифры)
SELECT REGEXP_REPLACE('1, 4, и 10 числа', '\d','@','g')  FROM dual                 --#=> '@, @, и @@ числа' [postgresql] меняем любую цифру на @ (само меняет только 1й, нужно добавить 'g')
SELECT REGEXP_REPLACE('John Doe', '(.*) (.*)', '\2, \1');                          --#=> 'Doe, John'

-- REGEXP_SPLIT_TO_TABLE(имя_столбца, регулярное_выражение) - сделать таблицу из подстрок разбитой по условию строки
SELECT REGEXP_SPLIT_TO_TABLE(str, '[aeiou]') AS results FROM random_string         --#=>  разбиваем строку по гласным(с их удалением) в столбец таблицы

-- DISTINCT (исключение дубликатов) - позволяет исключить одинаковые значения в выводе, если нам нужны только уникальные
SELECT DISTINCT class FROM Student_in_class;                      --#=> выбираем все варианты численности классов(class), тк нас интересуют именно варианты, а не конкретные классы, то дубликаты исключаем
SELECT DISTINCT first_name, last_name FROM User;                  --#=> применяя к нескольким столбцам исключаются только те строки в которых значения строк одинаковы во всех выбранных стобцах

-- DISTINCT ON (исключение дубликатов по столбцу) (возможно придется использовать в подзапросе, чтоб обработать рез потом)
SELECT DISTINCT ON(team) * FROM employees ORDER BY birth_date DESC  --#=> выбирает уникальные значения по столбцу, отсортированные по дате, тоесть выбраны эти уникальные с самой большой датой
SELECT DISTINCT ON(user_id, video_id) user_id, video_id FROM user_playlist  --#=> по нескольким столбцам

-- LIMIT - пишется в самом конце запроса, позволяет извлечь определённый диапазон записей из одной или нескольких таблиц.
-- (Оператор LIMIT реализован не во всех СУБД, например, в MSSQL для вывода записей с начала таблицы используется оператор TOP)
SELECT capital FROM countries WHERE continent IN ('Africa', 'Afrika') AND country LIKE 'E%' ORDER BY capital LIMIT 6   --#=> выводит токо 6 певых строк
SELECT * FROM Company LIMIT 2, 3;                                                                                      --#=> выводит строки с 3й по 5ю(1я цифра число пропущеных строк, 2я число строк)
SELECT * FROM Company LIMIT 3 OFFSET 2;                                                                                --#=> альтернативный синтаксис того что выше
SELECT * FROM Company OFFSET 2;                                                                                        --#=> выбираем все кроме 2х первых строк

-- ROW_NUMBER() OVER(ORDER BY SUM(имя_колонки) DESC) - вывести новую колонку порядковых номеров по убыванию относительно значений указанной колонки, которые заполняются автоматически
SELECT ROW_NUMBER() OVER(ORDER BY points DESC) AS rank FROM people;
SELECT ROW_NUMBER() OVER(ORDER BY SUM(points) DESC) AS rank FROM people GROUP BY some;

ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY count(*) DESC, category.name) AS category_rank
--#=> разбивка ранга по значениям столбца(когда новое значения ранг начинается снова с 1)  ???

-- DATEDIFF(interval, from, to): interval - дни/месяцы/годы. от даты from до даты to
SELECT DATEDIFF(DAY, OrderTime, DeliveryTime) AS AvDelTime FROM Orders           --#=> тут (day, OrderTime, DeliveryTime) расчет количества дней между OrderTime и DeliveryTime

-- TIMESTAMPDIFF(SECOND, time_out, time_in) - среднее время в секундах между time_out и time_in
SELECT plane, TIMESTAMPDIFF(SECOND, time_out, time_in) AS time FROM Trip         --#=> время полета


-- WHERE (где): условный оператор, выводит только те строки которые соответсвуют условию (в сравнении можно использовать = > < >= <= != <>)(посл это тоже знак "не равно")
SELECT * FROM Cars WHERE price > 1000                             --#=> выбрать из таблицы "Cars" те строки всех столбцов, где значение в столбце "price" больше 1000
SELECT * FROM Orders WHERE DeliveryTime < '2013-06-20'            --#=> выбрать из таблицы "Orders" те строки всех столбцов, где значение даты в столбце "DeliveryTime" меньше чем 20.06.2013
SELECT * FROM students WHERE tuition_received = false             --#=> c Boolean значениями false в столбце tuition_received
SELECT * FROM Student WHERE first_name = "Grigorij";              --#=> выбираем где значение столбца first_name это "Grigorij"
SELECT * FROM Student WHERE YEAR(birthday) > 2000;                --#=> выбираем где год из столбца birthday больше 2000

-- LIKE (поиск): условный оператор позволяет нам искать текст, соответствующий части строки поиска. Например, поиск по имени LIKE 'Jan%' будет соответствовать Jane и Janet, но не Jack.
-- Символ % соответствует любому количеству(>=0) любых символов. Пр 'begin%end' 'text%' '%text'
-- символ _ соответствует одному неизвестному символу. Пр 's_me' '_ext'
SELECT * FROM Customers WHERE LastName LIKE 'A%'                  --#=> Выберем те строки всех столбцов из "Customers", значение столбца "LastName" в которых начинается с буквы A.
SELECT name, email FROM Users WHERE email LIKE '%@hotmail.%'      --#=> выбираем где значение колонки почта содержит @hotmail.
SELECT * FROM Some WHERE fild LIKE '_ext'                          --#=> выбираем где в колонке fild стоит ext с любой первой буквой

-- ESCAPE-символ (экранирование): используется назначаемый символ для экранирования специальных символов (% и \). Чтобы они являлись обычными символами
SELECT job_id FROM Jobs WHERE progress LIKE '3!%' ESCAPE '!';     --#=> нужен прогресс задач в '3%'(три процента). Экранируем '%' назначая для этого символ '!' и ставя его перед

-- OR|AND|XOR (или|и|исключающее или): логические операторы позволяют объединять несколько условий. XOR - только одно из сравниваемых значений должно быть истинно, а другое должно быть ложно
SELECT * FROM Customers WHERE FirstName LIKE 'A%' OR Id < 10                          --#=> выбираем из таблицы строки, где значение столбца "FirstName" начинается с буквы A или "Id" меньше 10
SELECT * FROM Orders WHERE OrderTotal > 100 AND OrderTime > '2012-10-12'                           --#=> ... где значение одного столбца больше 100 и другого больше даты
SELECT * FROM Orders WHERE OrderTotal > 300 OR (OrderTotal > 200 AND OrderTime > '2012-11-15')     --#=> сложное условие, приоритет обозначаем скобками(как и везде)
SELECT * FROM travelers WHERE country <> 'Canada' AND country <> 'Mexico' AND country <> 'USA'     --#=> пример с text/varchar

-- IS NULL (является значением null): лпозволяет узнать равно ли проверяемое значение NULL, тк some = NULL - не работает.
SELECT * FROM Teacher WHERE middle_name IS NULL;                  --#=> выводит все где значением столбца middle_name является null
SELECT id FROM orders WHERE date IS NOT NULL                      --#=> не является null

-- BETWEEN (BETWEEN min AND max): логический оператор позволяет узнать расположено ли проверяемое значение столбца в интервале между min и max, включая сами значения min и max
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200              --#=> выбрать из таблицы "Orders" те строки всех столбцов, где значение в столбце "OrderTotal" между 100 и 200
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200 AND id > 10  --#=> тоже но с доп условием

-- IN (входит): логический оператор позволяет узнать входит ли проверяемое значение столбца в список определённых значений
SELECT * FROM FamilyMembers WHERE status IN ('father', 'mother');      --#=> выбрать все где значение столбца status соответсует 'father' или 'mother'

-- NOT (не является): логический оператор отрицания, так же меняет значение логических операторов и операторов сравнения на противоположный
SELECT * FROM students WHERE NOT tuition_received                            --#=> c Boolean значениями в с толбце tuition_received должно быть false(отрицание true) тут именно false а не null
SELECT * FROM Trip WHERE plane = 'Boeing' AND NOT town_from = 'London';      --#=> выводит где самолет боинг а город отправления не лондон.
SELECT * FROM travelers WHERE country NOT IN ('Canada', 'Mexico', 'USA')     --#=> выбираем все, где в значениях столбца "country" не стоит чтото из 'Canada', 'Mexico', 'USA'


-- Полнотекстовый поиск [Postgres]   https://supabase.com/docs/guides/database/full-text-search
-- TO_TSVECTOR() - Преобразует ваши данные в доступные для поиска «токены».  select to_tsvector('green eggs and ham')  #=>  'egg':2 'green':1 'ham':4
-- TO_TSQUERY() - Преобразует строку запроса в «токены» для соответствия. Этот шаг преобразования важен, потому что мы хотим получить «нечеткое соответствие»
-- @@  - символ «совпадения» для полнотекстового поиска. Он возвращает любые совпадения между to_tsvector результатом и to_tsquery результатом
SELECT * FROM books WHERE title = 'Harry'                                                   --#=> Символ равенства очень «строгий» в отношении того, что ему соответствует
SELECT * FROM books WHERE TO_TSVECTOR(title) @@ TO_TSQUERY('Harry')                         --#=> найти все что содержит подстроку 'Harry' в столбце title
SELECT * FROM books WHERE TO_TSVECTOR(description || ' ' || title) @@ TO_TSQUERY('little')  --#=> поиск сразу в нескольких столбцах(предварительно объединяет столбцы, потому добавим пробел)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('little & big')            --#=> поиск сразу 2х(обоих) слов(объединяем при помощи символа &)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('little | big')            --#=> поиск одного из слов(объединяем при помощи символа |)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('big <-> dreams')          --#=> поиск 2х слов идущих один за другим
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('year <2> school')         --#=> поиск 2х слов идущих в пределах 2х слов между ними
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('big & !little')           --#=> отрицание - одно слово содержится а другое обязательно не содержится
SELECT * FROM product WHERE TO_TSVECTOR('english', product.name) @@ TO_TSQUERY('english', 'awesome')   #--=> указание языка или поиск сразу по 2м колонкам ?



-- ORDER BY (порядок/сортировка): позволяет вывести по определенному(по умолчанию от наименьшего) порядку(например значений некого столбца)
SELECT name FROM Company ORDER BY name;                                --#=> сортируем строки по значениям столбца name
SELECT * FROM Orders WHERE Time > '2013-01-15' ORDER BY Time           --#=> (ORDER BY пишется после WHERE)отображаем порядок строк по значениям столбца "OrderTime"
SELECT * FROM Orders ORDER BY DeliveryTime DESC                        --#=> добавляя в конце DESC получаем порядок по убыванию(ASC - по возрастанию, значение по умолчанию)
SELECT * FROM Orders ORDER BY OrderTime DESC, OrderTotal ASC           --#=> сортируем по 2м столбцам(через запятую) при равенстве значений в 1м, сортирует по 2му итд(Даже если оба DESK пишем оба раза)
SELECT * FROM companies ORDER BY 4                                     --#=> используем номер колонки вместо названия(сортируем по 4й колонке)

-- https://www.geeksforgeeks.org/how-to-custom-sort-in-sql-order-by-clause/  - сортировка с условным оператором case





SELECT city_name FROM stations
WHERE city_name LIKE 'A%' OR city_name LIKE 'E%' OR city_name LIKE 'I%' OR city_name LIKE 'O%' OR city_name LIKE 'U%';
-- Неопознанные варианты выборки все аналоши того что выше
select distinct city_name from stations where city_name similar to '(A|E|I|O|U)%'














--
