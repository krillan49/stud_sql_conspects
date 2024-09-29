--                             WHERE(ограничения выборки). Условные и логические операторы

-- WHERE  - условный оператор, выбирает/фильтрует только те строки которые соответсвуют условию/ограничению тоесть возвращают TRUE
-- Условие может вернуть значение TRUE, FALSE или NULL
-- Можно использовать операторы сравнения: =, >, <, >=, <=, !=, <> (<> это тоже знак "не равно")
-- При сравнении дат со строками отформатированными как даты, они должны быть прописаны в том формате что задан в локали
-- Если сравниваем значения разных типов нужно привести их к одному типу

SELECT * FROM cars WHERE price > 1000;              -- выбрать строки, где значение в столбце "price" больше 1000
SELECT * FROM orders WHERE d_time < '2013-06-20';   -- выбрать строки, где дата в столбце "d_time" меньше 20.06.2013.
SELECT * FROM students WHERE received = false;      -- c Boolean значениями false в столбце received
SELECT * FROM students WHERE name = "Grigorij";     -- выбираем где значение столбца first_name это "Grigorij"

-- Так же можеи использовать математические операторы или функции в условии
SELECT * FROM cars WHERE price * 5 > some + 1000;
SELECT * FROM students WHERE YEAR(birthday) > 2000; -- выбираем где год из столбца birthday больше 2000



--                                               OR | AND | XOR

-- OR|AND|XOR (или|и|исключающее или) - логические операторы позволяют объединять несколько условий.
-- XOR(?? XOR похоже нет в PostgreSQL) - только одно из сравниваемых значений должно быть истинно, а другое должно быть ложно
SELECT * FROM travelers WHERE val <> 'US' AND val <> 'RU';       -- выбираем строки где в столбце не данные конкретные значения
SELECT * FROM dogs WHERE name LIKE 'A%' OR id < 10;              -- выбираем те строки где значение столбца name начинается с A или id меньше 10
SELECT * FROM Orders WHERE Total > 90 AND OrTime > '2012-10-12'; -- выбираем те строки где значение одного столбца больше 100 и другого больше даты заданной строкой

-- В сложном составном условии, приоритет обозначаем скобками:
SELECT * FROM orders WHERE total > 30 OR (total > 20 AND or_time > '2012-11-15');



--                                                      NOT

-- NOT (не является) - логический оператор отрицания. Меняет значение логических операторов и операторов сравнения на противоположный
SELECT * FROM students WHERE NOT tuition_received;  -- в с толбце tuition_received должно быть false(именно false а не null)
SELECT * FROM Trip WHERE plane = 'Boeing' AND NOT town_from = 'London'; -- самолет боинг а город отправления не Лондон.



--                                                 IS [NOT] NULL

-- IS NULL - равно ли проверяемое значение NULL, тк some = NULL - не работает.
SELECT * FROM Teacher WHERE middle_name IS NULL;        -- выводит все где значением столбца middle_name является null
SELECT id FROM orders WHERE date IS NOT NULL;           -- не является null



--                                                  [NOT] IN

-- IN (входит) - логический оператор позволяет узнать входит ли проверяемое значение столбца в список определённых значений
SELECT * FROM FamilyMembers WHERE status IN ('father', 'mother');         -- значение столбца status 'father' или 'mother'
SELECT * FROM travelers WHERE country NOT IN ('Canada', 'Mexico', 'USA'); -- country не включено в 'Canada', 'Mexico', 'USA'



--                                                  BETWEEN

-- BETWEEN (BETWEEN min AND max) - логический оператор позволяет узнать расположено ли проверяемое значение столбца в интервале между min и max, включая сами значения min и max
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200;              -- выбрать строки где OrderTotal между 100 и 200
SELECT * FROM Orders WHERE OrderTotal BETWEEN 100 AND 200 AND id > 10;  -- тоже но с доп условием
SELECT * FROM some WHERE sTime BETWEEN '2023-09-01' AND '2023-09-30';   -- с датами



--                                                 [NOT] LIKE

-- LIKE - условный оператор позволяет нам искать строки, соответствующие шаблону(паттерн матчинг).
-- "%" соответствует любому количеству(>=0) любых символов ('begin%end' 'text%' '%text')
-- "_" соответствует одному любому символу ('s_me' '_ext')
SELECT * FROM cus WHERE name LIKE 'A%';                    -- выберет строки, где значение столбца name начинается с буквы A.
SELECT * FROM Some WHERE fild LIKE '_ext';                 -- в колонке fild стоит 'ext' с любой первой буквой

-- NOT LIKE
SELECT name FROM Users WHERE email NOT LIKE '%@gmail.%';   -- значение колонки почта не содержит '@gmail.'
SELECT name FROM Users WHERE NOT (email LIKE '%@gmail.%'); -- значение колонки почта не содержит '@gmail.'

-- Создание строки для LIKE
SELECT str, name FROM some WHERE str LIKE '%,' || code_name || ',%';

-- ESCAPE (экранирование) - назначает символ для экранирования специальных символов (%, _ итд).
SELECT job_id FROM Jobs WHERE progress LIKE '3!%' ESCAPE '!'; -- тут '3%' это три процента. Экранируем '%' назначая для этого символ '!' и ставя его перед экранируемым символом



--                                           SIMILAR TO [?? Postgres]

-- SIMILAR TO - похоже LIKE только может выбирать выбирает любую букву из заданных в скобках через пайпы.
SELECT city_name FROM stations WHERE city_name SIMILAR TO '(A|E|I|O|U)%'; -- city_name начинается с любой буквы из данных



--                                         Полнотекстовый поиск [Postgres]

-- https://supabase.com/docs/guides/database/full-text-search

-- TO_TSVECTOR() - преобразует строку данных в доступные для поиска «токены» ('green eggs and ham' => 'egg':2 'green':1 'ham':4)
-- TO_TSQUERY()  - преобразует проверочную строку в «токены». Этот шаг важен, потому что мы хотим получить нечеткое соответствие
-- @@            - символ совпадения, он возвращает любые совпадения между результатом TO_TSVECTOR и результатом TO_TSQUERY

SELECT * FROM books -- далее любое условие из ниже описанных:
WHERE title = 'Harry'                                            -- Строгое равенство
WHERE TO_TSVECTOR(title) @@ TO_TSQUERY('Harry')                  -- все что содержит подстроку 'Harry' в столбце title
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('little & big')            -- поиск сразу 2х слов(объединяем при помощи символа &)
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('big & !little')           -- одно слово содержится а другое нет
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('little | big')            -- поиск одного из слов(объединяем при помощи символа |)
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('big <-> dreams')          -- поиск 2х слов идущих одно за другим
WHERE TO_TSVECTOR(name) @@ TO_TSQUERY('year <2> school')         -- поиск 2х слов идущих в пределах 2х слов между ними

-- Можно производить поиск в любом из нескольких столбцав одного значения
SELECT * FROM books WHERE WHERE TO_TSVECTOR(name || ' ' || title) @@ TO_TSQUERY('little');

-- Можно производить поиск сразу по нескольким колонкам, записам их в одном операторе, в том же порядке с проверяемыми значениями
SELECT * FROM books WHERE TO_TSVECTOR(lang, name) @@ TO_TSQUERY('english', 'Some');



--                                           Регулярные выражения

-- string ~ regex  -  определяет строки соответсующие регулярке (в Postgres регистр не учитывает ??)
SELECT city_name FROM stations WHERE city_name ~ '^[AEIOU]';  -- ищет совпадения с первой буквой из указанных

-- (?? Хз зачем звездочка)
where description ~* 'confetti|glitter|golden toilet|massage chair|video game|karaoke'














--
