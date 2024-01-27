--                                         WHERE. Условные и логические операторы

-- WHERE (где) - условный оператор, выбирает только те строки которые соответсвуют условию (в сравнении можно использовать = > < >= <= != <>)(<> это тоже знак "не равно")
SELECT * FROM Cars WHERE price > 1000;                   -- выбрать строки, где значение в столбце "price" больше 1000
SELECT * FROM Orders WHERE DeliveryTime < '2013-06-20';  -- выбрать строки, где дата в столбце "DeliveryTime" меньше 20.06.2013
SELECT * FROM students WHERE tuition_received = false;   -- c Boolean значениями false в столбце tuition_received
SELECT * FROM Student WHERE first_name = "Grigorij";     -- выбираем где значение столбца first_name это "Grigorij"
SELECT * FROM Student WHERE YEAR(birthday) > 2000;       -- выбираем где год из столбца birthday больше 2000



--                                                     LIKE

-- LIKE (поиск) - условный оператор позволяет нам искать текст, соответствующий части строки поиска.
-- % соответствует любому количеству(>=0) любых символов ('begin%end' 'text%' '%text')
-- _ соответствует одному неизвестному символу ('s_me' '_ext')
SELECT * FROM cus WHERE name LIKE 'A%'              -- Выберем те строки где, значение столбца "name" начинается с буквы A.
SELECT name FROM Users WHERE email LIKE '%@gmail.%' -- выбираем где значение колонки почта содержит '@gmail.'
SELECT * FROM Some WHERE fild LIKE '_ext'           -- выбираем где в колонке fild стоит 'ext' с любой первой буквой

-- ESCAPE-символ (экранирование): используется назначаемый символ для экранирования специальных символов (% и \).
SELECT job_id FROM Jobs WHERE progress LIKE '3!%' ESCAPE '!'; --> 3%'(три процента). Экранируем '%' назначая для этого символ '!' и ставя его перед экранируемым символом

-- [ ?? Postgres] SIMILAR TO как LIKE только выбирает любую букву из. Тоесть начинается с любой буквы из данных
SELECT city_name FROM stations WHERE city_name SIMILAR TO '(A|E|I|O|U)%';



--                                                  OR|AND|XOR

-- OR|AND|XOR (или|и|исключающее или): логические операторы позволяют объединять несколько условий. XOR(XOR похоже нет в постгресс) - только одно из сравниваемых значений должно быть истинно, а другое должно быть ложно
SELECT * FROM dogs WHERE name LIKE 'A%' OR Id < 10        -- выбираем где значение столбца name начинается с  A или "Id" меньше 10
SELECT * FROM Orders WHERE Total > 90 AND OrTime > '2012-10-12'   -- где значение одного столбца больше 100 и другого больше даты
SELECT * FROM Orders WHERE Total > 30 OR (Total > 20 AND OrTime > '2012-11-15') --> сложное условие, приоритет обозначаем скобками
SELECT * FROM travelers WHERE country <> 'Canada' AND country <> 'Mexico' AND country <> 'USA'  --> пример с text/varchar



--                                                    BETWEEN

-- BETWEEN (BETWEEN min AND max) - логический оператор позволяет узнать расположено ли проверяемое значение столбца в интервале между min и max, включая сами значения min и max
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200;              -- выбрать строки где OrderTotal между 100 и 200
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200 AND id > 10;  -- тоже но с доп условием
SELECT * FROM some WHERE sTime BETWEEN '2023-09-01' AND '2023-09-30'    -- с датами



--                                                      NOT

-- NOT (не является): логический оператор отрицания, так же меняет значение логических операторов и операторов сравнения на противоположный
SELECT * FROM students WHERE NOT tuition_received;    -- в с толбце tuition_received должно быть false(тут именно false а не null)
SELECT * FROM Trip WHERE plane = 'Boeing' AND NOT town_from = 'London';   -- самолет боинг а город отправления не Лондон.



--                                                 IS [NOT] NULL

-- IS NULL (является значением null) - равно ли проверяемое значение NULL, тк some = NULL - не работает.
SELECT * FROM Teacher WHERE middle_name IS NULL;        -- выводит все где значением столбца middle_name является null
SELECT id FROM orders WHERE date IS NOT NULL;           -- не является null



--                                                    [NOT] IN

-- IN (входит): логический оператор позволяет узнать входит ли проверяемое значение столбца в список определённых значений
SELECT * FROM FamilyMembers WHERE status IN ('father', 'mother');  -- значение столбца status соответсует 'father' или 'mother'
SELECT * FROM travelers WHERE country NOT IN ('Canada', 'Mexico', 'USA')  -- country не включено в 'Canada', 'Mexico', 'USA'



--                                         Полнотекстовый поиск [Postgres]

-- https://supabase.com/docs/guides/database/full-text-search

TO_TSVECTOR() -- Преобразует строку данных в доступные для поиска «токены» ('green eggs and ham' => 'egg':2 'green':1 'ham':4)
TO_TSQUERY()  -- Преобразует проверочную строку в «токены». Этот шаг важен, потому что мы хотим получить нечеткое соответствие
@@            -- символ совпадения, он возвращает любые совпадения между результатом TO_TSVECTOR и результатом TO_TSQUERY

SELECT * FROM books -- далее любое условие из ниже описанных:
WHERE title = 'Harry'                                            -- Строгое равенство
WHERE TO_TSVECTOR(title) @@ TO_TSQUERY('Harry')                  -- все что содержит подстроку 'Harry' в столбце title
WHERE TO_TSVECTOR(name || ' ' || title) @@ TO_TSQUERY('little')  -- поиск сразу в нескольких столбцах
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('little & big')            -- поиск сразу 2х слов(объединяем при помощи символа &)
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('little | big')            -- поиск одного из слов(объединяем при помощи символа |)
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('big <-> dreams')          -- поиск 2х слов идущих одно за другим
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('year <2> school')         -- поиск 2х слов идущих в пределах 2х слов между ними
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('big & !little')           -- отрицание - одно слово содержится а другое нет
WHERE TO_TSVECTOR('english', books.name) @@ TO_TSQUERY('english', 'awesome') -- поиск сразу по 2м колонкам













--
