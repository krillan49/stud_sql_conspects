--                                            Условные и логические операторы

-- WHERE (где): условный оператор, выводит только те строки которые соответсвуют условию (в сравнении можно использовать = > < >= <= != <>)(<> это тоже знак "не равно")
SELECT * FROM Cars WHERE price > 1000;                   --> выбрать строки, где значение в столбце "price" больше 1000
SELECT * FROM Orders WHERE DeliveryTime < '2013-06-20';  --> выбрать строки, где дата в столбце "DeliveryTime" меньше 20.06.2013
SELECT * FROM students WHERE tuition_received = false;   --> c Boolean значениями false в столбце tuition_received
SELECT * FROM Student WHERE first_name = "Grigorij";     --> выбираем где значение столбца first_name это "Grigorij"
SELECT * FROM Student WHERE YEAR(birthday) > 2000;       --> выбираем где год из столбца birthday больше 2000


-- LIKE (поиск): условный оператор позволяет нам искать текст, соответствующий части строки поиска..
-- Символ % соответствует любому количеству(>=0) любых символов ('begin%end' 'text%' '%text')
-- символ _ соответствует одному неизвестному символу ('s_me' '_ext')
SELECT * FROM Customers WHERE LastName LIKE 'A%'             --> Выберем те строки всех столбцов из "Customers", значение столбца "LastName" в которых начинается с буквы A.
SELECT name, email FROM Users WHERE email LIKE '%@hotmail.%' --> выбираем где значение колонки почта содержит @hotmail.
SELECT * FROM Some WHERE fild LIKE '_ext'                    --> выбираем где в колонке fild стоит ext с любой первой буквой

-- ESCAPE-символ (экранирование): используется назначаемый символ для экранирования специальных символов (% и \). Чтобы они являлись обычными символами
SELECT job_id FROM Jobs WHERE progress LIKE '3!%' ESCAPE '!'; --> 3%'(три процента). Экранируем '%' назначая для этого символ '!' и ставя его перед экранируемым символом

-- [ ?? Postgres] SIMILAR TO как LIKE только выбирает любую букву из. Тоесть начинается с любой буквы из данных
SELECT city_name FROM stations WHERE city_name SIMILAR TO '(A|E|I|O|U)%';


-- OR|AND|XOR (или|и|исключающее или): логические операторы позволяют объединять несколько условий. XOR - только одно из сравниваемых значений должно быть истинно, а другое должно быть ложно
-- (XOR похоже нет в постгресс)
SELECT * FROM Customers WHERE FirstName LIKE 'A%' OR Id < 10                      --> выбираем из таблицы строки, где значение столбца "FirstName" начинается с буквы A или "Id" меньше 10
SELECT * FROM Orders WHERE Total > 100 AND OrTime > '2012-10-12'                  --> ... где значение одного столбца больше 100 и другого больше даты
SELECT * FROM Orders WHERE Total > 300 OR (Total > 200 AND OrTime > '2012-11-15') --> сложное условие, приоритет обозначаем скобками
SELECT * FROM travelers WHERE country <> 'Canada' AND country <> 'Mexico' AND country <> 'USA'  --> пример с text/varchar


-- IS NULL (является значением null): лпозволяет узнать равно ли проверяемое значение NULL, тк some = NULL - не работает.
SELECT * FROM Teacher WHERE middle_name IS NULL;        --> выводит все где значением столбца middle_name является null
SELECT id FROM orders WHERE date IS NOT NULL;           --> не является null


-- BETWEEN (BETWEEN min AND max): логический оператор позволяет узнать расположено ли проверяемое значение столбца в интервале между min и max, включая сами значения min и max
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200;              --> выбрать строки где OrderTotal между 100 и 200
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200 AND id > 10;  --> тоже но с доп условием
between '2023-09-01' and '2023-09-30'


-- IN (входит): логический оператор позволяет узнать входит ли проверяемое значение столбца в список определённых значений
SELECT * FROM FamilyMembers WHERE status IN ('father', 'mother');  --> значение столбца status соответсует 'father' или 'mother'


-- NOT (не является): логический оператор отрицания, так же меняет значение логических операторов и операторов сравнения на противоположный
SELECT * FROM students WHERE NOT tuition_received;                        --> в с толбце tuition_received должно быть false(тут именно false а не null)
SELECT * FROM Trip WHERE plane = 'Boeing' AND NOT town_from = 'London';   --> самолет боинг а город отправления не лондон.
SELECT * FROM travelers WHERE country NOT IN ('Canada', 'Mexico', 'USA')  --> country не включено в 'Canada', 'Mexico', 'USA'



--                                        Полнотекстовый поиск [Postgres]

-- https://supabase.com/docs/guides/database/full-text-search

TO_TSVECTOR() -- Преобразует строку данные в доступные для поиска «токены» ('green eggs and ham' => 'egg':2 'green':1 'ham':4)
TO_TSQUERY()  -- Преобразует строку запроса в «токены» для соответствия. Этот шаг преобразования важен, потому что мы хотим получить «нечеткое соответствие»
@@            -- символ «совпадения», он возвращает любые совпадения между TO_TSVECTOR результатом и TO_TSQUERY результатом

SELECT * FROM books WHERE title = 'Harry'                                --> Строгое равенство
SELECT * FROM books WHERE TO_TSVECTOR(title) @@ TO_TSQUERY('Harry')      --> все что содержит подстроку 'Harry' в столбце title
SELECT * FROM books WHERE TO_TSVECTOR(description || ' ' || title) @@ TO_TSQUERY('little')  --> поиск сразу в нескольких столбцах(предварительно объединяет столбцы, потому добавим пробел)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('little & big')            --> поиск сразу 2х слов(обоих) слов(объединяем при помощи символа &)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('little | big')            --> поиск одного из слов(объединяем при помощи символа |)
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('big <-> dreams')          --> поиск 2х слов идущих одно за другим
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('year <2> school')         --> поиск 2х слов идущих в пределах 2х слов между ними
SELECT * FROM books WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('big & !little')           --> отрицание - одно слово содержится а другое обязательно не содержится
SELECT * FROM books WHERE TO_TSVECTOR('english', books.name) @@ TO_TSQUERY('english', 'awesome')   --> поиск сразу по 2м колонкам



--                                            ORDER BY (порядок/сортировка)

-- ORDER BY позволяет вывести по определенному(по умолчанию от наименьшего) порядку(например значений некого столбца)
-- (ORDER BY пишется после WHERE и после GROUP_BY но перед LIMIT)
-- Можно сортировать по колонкам таблицы, которые не выводятся данным запросом

SELECT name FROM Company ORDER BY name;                       --> сортируем строки по значениям столбца name
SELECT * FROM Orders WHERE Time > '2013-01-15' ORDER BY Time  --> отображаем порядок строк по значениям столбца "OrderTime"
SELECT * FROM Orders ORDER BY DeliveryTime DESC               --> DESC порядок по убыванию, ASC - по возрастанию(значение по умолчанию)
SELECT * FROM Orders ORDER BY OrderTime DESC, OrderTotal ASC  --> сортируем по 2м столбцам - при равенстве значений в 1м, сортирует по 2му итд(если оба DESK пишем оба раза)
SELECT * FROM companies ORDER BY 4                            --> используем номер колонки вместо названия(сортируем по 4й колонке)

-- https://www.geeksforgeeks.org/how-to-custom-sort-in-sql-order-by-clause/  - сортировка с условным оператором case











--
