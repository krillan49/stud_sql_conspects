--                                                 Массивы

-- https://www.postgresql.org/docs/current/functions-array.html
-- https://postgrespro.ru/docs/postgrespro/9.6/arrays
-- https://postgrespro.ru/docs/postgrespro/9.6/functions-array
-- https://postgrespro.ru/docs/postgresql/15/arrays

TEXT[], INT[] -- типы массивов в PostgreSQL



--                                     Создание массива и преоразование в массив

-- 1. Создание массива из литералов или значений столбцов строки:
SELECT ARRAY[completion, final_review, second_review, 'some', first_review] AS arr FROM some;


-- 2. Создание массива из столбца в подзапросе:
SELECT *, ARRAY(SELECT id FROM some) AS res FROM aaa;


-- 3. Преобразомание строки(литерала) в массив:

-- STRING_TO_ARRAY - [PostgreSQL] функция разбивает строку по указанным разделителям в массив
SELECT STRING_TO_ARRAY('a,b,c', ',') FROM user_tags;            --> {a, b, c}

-- REGEXP_SPLIT_TO_ARRAY() - [PostgreSQL] функция разбивает строку по указанным regexp-разделителям в массив
SELECT REGEXP_SPLIT_TO_ARRAY('hello world', '\s+');             --> {hello, world}



--                                    Преобразование типов данных в массивах

SELECT customer_id, arr::INT[] AS arr FROM customer;    -- преобразунм значение всех элементов массива в INT



--                                               Длинна массива

SELECT CARDINALITY(arr) FROM example;              -- длинна массива (работает корректно только с одномерными массивами, в многомерных считает все элементы последнего уровня как с применением flatten)

SELECT ARRAY_LENGTH(arr, 1) FROM example;          -- длинна массива, 2й параметр это вложенность те 1 самый внешний массив, 2 - подмассив 1го уровня итд



--                                        Проверка на вхождение в массив

-- 1. @> работает если оба параметра массивы
ARRAY[1,4,3] @> ARRAY[3,1,3]                        -- Содержит ли первый массив второй (каждый элемент второго массива равен какому-то элементу первого массива)
ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]                    -- Содержитcя ли первый массив во втором
( (ARRAY_1 @> ARRAY_2) AND (ARRAY_1 <@ ARRAY_2) )   -- Равны ли два массива(не учитывает разные количесва одинаковых элементов)

-- Пример в запросе
SELECT * FROM film WHERE ARRAY['Trailers', 'Deleted Scenes'] <@ special_features;  -- содержится ли 1й массив во втором


-- 2. ALL, ANY (? мб еще что-то) - работают с массивом так же как с подзапросом
SELECT * FROM film WHERE 'Trailers' = ANY(special_features) AND 'Deleted Scenes' != ALL(special_features); --  Проверяем содержится ли в массиве в данной строке столбца special_features одно значение и не содержится другое

-- LIKE-соответсвие любому выражению в массиве
SELECT city_name FROM stations WHERE city_name LIKE ANY(ARRAY['A%','E%','I%','O%','U%']);



--                                 Получение значений и срезов из массива по индексам

-- По умолчанию в PostgreSQL действует соглашение о нумерации элементов массива с 1
-- Индексы элементов массива записываются в квадратных скобках.
SELECT
  arr[3],                                    -- 3й элемет массива pay_by_quarter
  arr[:3],                                   -- элементы с 1го по 3й включительно
  arr[3:],                                   -- элементы с 3го по последний включительно
  arr[2:3],                                  -- элементы с 2го по 3й включительно
  arr[2:3][1:3]                              -- элементы с 1го по 3й включительно из подмассивов со 2го по 3й
  arr[ARRAY_UPPER(arr, 1)],                  -- последний элемент массива arr
  arr[CARDINALITY(arr)-1],                   -- предпоследний элемент при помощи длинны массива
  (ARRAY_AGG(class ORDER BY class DESC))[1]  -- при генерации при группировке надо взять в скобки
FROM sal_emp;



--                                            Добавить в массив

-- ARRAY_PREPEND - функция PostgreSQL добавляет указанный элемент в начало массива(arr) и возвращает измененный массив. Первый параметр - элемент, второй - массив.
ARRAY_PREPEND('some', arr)      --> arr

-- ARRAY_APPEND - функция PostgreSQL добавляет указанный элемент в конец указанного массива и возвращает измененный массив. Первый параметр - массив, второй - элемент.
ARRAY_APPEND(arr, element)      --> arr



--                                         Удаление элементов из массива

-- ARRAY_REMOVE - функция удаляет указанные элементы из массива
SELECT ARRAY_REMOVE(arr, NULL) AS ar FROM some    -- тут удаляем значения NULL


-- PostgreSQL удаление дубликатов из массива при помощи ARRAY_AGG(DISTINCT):
SELECT ARRAY_AGG(DISTINCT element ORDER BY element) FROM UNNEST(ARRAY[1, 2, 2, 3, 4, 4, 5]) AS element; --> {1,2,3,4,5}
SELECT other_column, ARRAY(SELECT DISTINCT val FROM UNNEST(my_array) AS val) AS arr FROM my_table; -- если есть другие колонки



--                                      Преобразомание массива в строки таблицы

-- UNNEST - создает новые строки из массива (была одна строка с массивом, слало много строк по числу элементов массива и так каждый массив, если строк с массивами несколько, повторы не убираются)
SELECT UNNEST(special_features) AS feature FROM film

-- Если в запросе выводятся другие колонки, то их значения продублируются для каждой новой строки из соответсвующего массива
SELECT name, UNNEST(special_features) AS feature FROM film   -- значения из name продублируется для каждой новой строки соотв массива

-- Два UNNEST-а не дублируют друг друга ? а если разной длинны ??
SELECT UNNEST(ARRAY[1, 2, 3, 4, 5]) AS n, UNNEST(ARRAY[1, 2, 6, 24, 120]) AS result



--                                             Сортировка массива

-- [PostgreSQL] для сортировки массива можно использовать функцию `unnest()` совместно с оператором `ORDER BY`
-- unnest(ARRAY[...])            - разбивает массив на строки.
-- ORDER BY 1                    - сортирует эти строки.
-- ARRAY(...)                    - собирает отсортированные строки обратно в массив.

SELECT ARRAY(SELECT unnest(ARRAY[5, 2, 8, 1, 4]) ORDER BY 1) AS sorted_array;
SELECT ARRAY(SELECT unnest(ARRAY['banana', 'apple', 'cherry', 'date']) ORDER BY 1) AS sorted_array;
SELECT id, ARRAY(SELECT unnest(fruit_names) ORDER BY 1) AS sorted_fruit_names FROM fruits;



--                                        Преобразование массива в текст

-- ARRAY_TO_STRING() - встроенная функция PostgreSQL, которая преобразует заданный массив в строки(TEXT)
SELECT ARRAY_TO_STRING(arr, ':' , '-') FROM st_information;
-- arr - колонка с массивом
-- ':' - элемент который будет делить элементы массива в строке
-- '-' - элемент который заменит значения NULL из массива
















--
