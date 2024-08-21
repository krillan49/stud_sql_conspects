--                                             Массивы и генераторы

-- https://www.postgresql.org/docs/current/functions-array.html
-- https://postgrespro.ru/docs/postgrespro/9.6/arrays
-- https://postgrespro.ru/docs/postgrespro/9.6/functions-array

TEXT[], INT[] -- типы массивов

-- Сортировка массивов есть в разделе груп бай



--                                    Преобразование типов данных в массивах

SELECT customer_id, arr::INT[] AS arr FROM customer    -- преобразунм значение всех элементов массива в INT



--                                               Длинна массива

SELECT CARDINALITY(arr) FROM example;              -- длинна массива (работает корректно только с одномерными массивами, в многомерных считает все элементы последнего уровня как с применение flatten)

SELECT ARRAY_LENGTH(arr, 1) FROM example;          -- длинна массива, 2й параметр это вложенность те 1 самый внешний массив, 2 - подмассив 1го уровня итд



--                                       Проверка на вхождение в массив

-- @> работает если оба параметра массивы
ARRAY[1,4,3] @> ARRAY[3,1,3]                        -- Содержит ли первый массив второй (каждый элемент второго массива равен какому-то элементу первого массива)
ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]                    -- Содержитcя ли первый массив во втором
( (ARRAY_1 @> ARRAY_2) AND (ARRAY_1 <@ ARRAY_2) )   -- Быстрый способ сравнить два массива(но не учитывает разные количесва одинаковых элементов)

-- Пример в запросе
SELECT * FROM film WHERE ARRAY['Trailers', 'Deleted Scenes'] <@ special_features  -- содержится ли 1й массив во втором

-- С массивом работают ALL ANY мб еще что
SELECT * FROM film WHERE 'Trailers' = ANY(special_features) AND 'Deleted Scenes' != ALL(special_features) -- альтернатива при помощи ANY. Проверяем содержится ли в массиве в данной строке столбца special_features одно значение и не содержится другое

-- LIKE-соответсвие любому выражению в массиве
SELECT city_name FROM stations WHERE city_name LIKE ANY(ARRAY['A%','E%','I%','O%','U%'])



--                                     Создание массива из столбца в подзапросе

SELECT *, ARRAY(SELECT id FROM some) AS res FROM aaa



--                             Создание массива из литералов или значений столбцов строки

SELECT ARRAY[completion, final_review, second_review, first_review, initial_assignment] AS arr FROM some



--                                    Преобразомание строки(литерала) в массив

-- PostgreSQL функция STRING_TO_ARRAY разбивает строку по указанным разделителям в массив
SELECT STRING_TO_ARRAY('a,b,c', ',') FROM user_tags            --> {a, b, c}

-- REGEXP_SPLIT_TO_ARRAY() - PostgreSQL функция разбивает строку по указанным regexp-разделителям в массив
REGEXP_SPLIT_TO_ARRAY('hello world', '\s+')                    --> {hello, world}



--                                    Получение значений и срезов из массива

-- https://postgrespro.ru/docs/postgresql/15/arrays

-- По умолчанию в PostgreSQL действует соглашение о нумерации элементов массива с 1
-- Индексы элементов массива записываются в квадратных скобках.
SELECT pay_by_quarter[3] FROM sal_emp;                   -- 3й элемет массива pay_by_quarter
(ARRAY_AGG(class ORDER BY class DESC))[1]                -- при генерации при группировке надо взять в скобки
SELECT pay_by_quarter[:3] FROM sal_emp;                  -- элементы с 1го по 3й включительно
SELECT pay_by_quarter[3:] FROM sal_emp;                  -- элементы с 3го по последний включительно
SELECT pay_by_quarter[2:3] FROM sal_emp;                 -- элементы с 2го по 3й включительно
SELECT pay_by_quarter[2:3][1:3] FROM sal_emp;            -- элементы с 1го по 3й включительно из подмассивов со 2го по 3й
SELECT arr[ARRAY_UPPER(arr, 1)];                         -- последний элемент массива arr
SELECT arr[CARDINALITY(arr)-1];                          -- предпоследний элемент при помощи длинны массива



--                                           Добавить в начало массива

-- Добавлят в начало массива(arr) элемент, тут строку
ARRAY_PREPEND('some', arr)



--                                         Удаление элементов из массива

SELECT ARRAY_REMOVE(arr, NULL) AS ar FROM some    -- тут удаляем значения NULL



--                                      Преобразомание массива в строки таблицы

-- UNNEST - создает новые строки из массива (была одна строка с массивом, слало много строк по числу элементов массива и так каждый массив, если строк с массивами несколько, повторы не убираются)
SELECT UNNEST(special_features) AS feature FROM film
SELECT name, UNNEST(special_features) AS feature FROM film   -- строка name продублируется для каждой новой строки соотв массива

-- 2 UNNESTа не дублируют друг друга ?
SELECT UNNEST(ARRAY[1, 2, 3, 4, 5]) AS n, UNNEST(ARRAY[1, 2, 6, 24, 120]) AS result



--                                        Преобразомание массива в текст

-- ARRAY_TO_STRING() - встроенная функция PostgreSQL, которая преобразует заданный массив в строки(TEXT)
SELECT ARRAY_TO_STRING(arr, ':' , '-') FROM st_information;
-- arr - колонка с массивом
-- ':' - элемент который будет делить элементы массива в строке
-- '-' - элемент который заменит значения NULL из массива



--                                        Генерация столбцов в запросах

SELECT GENERATE_SERIES(2, 100) AS nums                                  -- Создает столбец чисел от 2х до 100
SELECT GENERATE_SERIES(2, 10, 2) AS nums                                -- 2, 4, 6, 8, 10. 3й аргумент - шаг
SELECT GENERATE_SERIES(9, 7, -1) AS nums                                -- 9, 8, 7. Отрицательный шаг для обратного порядка
SELECT GENERATE_SERIES('2005-05-24', '2005-06-02', INTERVAL '1 day')    -- с датами и шагов в виде интервала
GENERATE_SERIES('2023-05-08 10:00:00', '2023-05-08 22:00:00', INTERVAL '30 minute')

-- Генерация и преобразование в массив
SELECT ARRAY(SELECT * FROM GENERATE_SERIES(2, 10, 2))

-- удобно использовать как изначальные данные, тут чтоб создать таблицу с одинаковыми значениями в 2х столбцах из 10 строк
SELECT 0, '-' FROM GENERATE_SERIES(1, 10)
SELECT REPEAT('*', 20-n) AS star_pattern FROM GENERATE_SERIES(1, 10) AS n
SELECT n, factorial(n) AS res FROM generate_series(1, 5) AS t(n)

-- Функция применяется к каждому сгенереному члену
SELECT POWER((GENERATE_SERIES(1, n)), 3) AS m FROM some

-- 2 колонки с интервалами по часу
SELECT
GENERATE_SERIES('2023-07-16 08:00:00', '2023-07-16 17:00:00', INTERVAL '1 hour') AS time_from,
GENERATE_SERIES('2023-07-16 09:00:00', '2023-07-16 18:00:00', INTERVAL '1 hour') AS time_to

-- колонка всех начал недель
SELECT GENERATE_SERIES('2024-01-01', '2024-12-31', INTERVAL '1 week') AS time_some

-- используем для размножения строк в зависимости от цифры в quantity_in_stock
SELECT product_id, product_name, quantity_in_stock, GENERATE_SERIES(1, quantity_in_stock) AS n FROM products

-- Использование для джойна (тоже самое, что и выше)
SELECT product_id, product_name, quantity_in_stock FROM products CROSS JOIN GENERATE_SERIES(1, quantity_in_stock);


-- Вывод из серии еще и совмещенной с таблицей ??
select year,
  count(*) filter (where extract(year from joined_date) = year) as joined_quantity,
  count(*) filter (where extract(year from left_date) = year) as left_quantity
from generate_series(2014, 2023) AS year, employees















--
