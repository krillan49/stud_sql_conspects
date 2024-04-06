--                                             Массивы и генераторы

-- https://www.postgresql.org/docs/current/functions-array.html
-- https://postgrespro.ru/docs/postgrespro/9.6/arrays
-- https://postgrespro.ru/docs/postgrespro/9.6/functions-array

TEXT[], INT[] -- массивы ??

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



--                                         Создание массива из столбца

SELECT *, ARRAY(SELECT id FROM some) AS res FROM aaa


--                             Создание массива из литералов или значений столбцов строки

SELECT ARRAY[completion, final_review, second_review, first_review, initial_assignment] AS arr FROM some



--                                         Преобразомание массива в строки

UNNEST -- создает новые строки из массива (была одна строка с массивом, слало много строк по числу элементов массива и так каждый массив, если строк с массивами несколько, повторы не убираются)
SELECT UNNEST(special_features) AS feature FROM film



--                                        Преобразомание массива в текст

-- ARRAY_TO_STRING() - встроенная функция PostgreSQL, которая преобразует заданный массив в строки(TEXT) и объединяет строки с помощью разделителя, она принимает три аргумента: массив, разделитель и текст для замены нулевых значений.
SELECT ARRAY_TO_STRING(arr, ':' , '-') FROM st_information;
-- arr - колонка с массивом
-- ':' - элемент который будет делить элементы массива в строке
-- '-' - элемент который заменит значения NULL из массива



--                                       Преобразомание строки(литерала) в массив

-- PostgreSQL функция STRING_TO_ARRAY разбивает строку по указанным разделителям в массив
SELECT STRING_TO_ARRAY('a,b,c', ',') FROM user_tags            --> {a, b, c}
-- PostgreSQL функция regexp_split_to_array разбивает строку по указанным regexp-разделителям в массив
REGEXP_SPLIT_TO_ARRAY('hello world', '\s+')                    --> {hello, world}


--                                    Получение значений и частей из массивов

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


--                                         Удаление элементов из массива

SELECT ARRAY_REMOVE(arr, NULL) AS ar FROM some    -- тут удаляем значения NULL



--                                        Генерация столбцов в запросах

SELECT GENERATE_SERIES(2, 100) AS nums                                  -- Создает столбец чисел от 2х до 100
SELECT GENERATE_SERIES(2, 10, 2)                                        -- 2, 4, 6, 8, 10
SELECT GENERATE_SERIES('2005-05-24', '2005-06-02', INTERVAL '1 day')    -- с датами и заданным интервалом
GENERATE_SERIES('2023-05-08 10:00:00', '2023-05-08 22:00:00', INTERVAL '30 minute')

-- 2 колонки с интервалами по часу
SELECT
GENERATE_SERIES('2023-07-16 08:00:00', '2023-07-16 17:00:00', INTERVAL '1 hour') AS time_from,
GENERATE_SERIES('2023-07-16 09:00:00', '2023-07-16 18:00:00', INTERVAL '1 hour') AS time_to
-- колонка всех начал недель
SELECT
GENERATE_SERIES('2024-01-01', '2024-12-31', INTERVAL '1 week') AS time_some

-- используем для размножения строк в зависимости от цифры в quantity_in_stock
SELECT product_id, product_name, quantity_in_stock, GENERATE_SERIES(1, quantity_in_stock) AS n FROM products
-- тоже самое без создания доп колонки
SELECT product_id, product_name, quantity_in_stock FROM products CROSS JOIN GENERATE_SERIES(1, quantity_in_stock);

-- можно использовать как изначальные данные, тут чтоб создать таблицу с одинаковыми значениями в 2х столбцах из 10 строк
SELECT 0, '-' FROM GENERATE_SERIES(1, 10)

-- Функция применяется к каждому сгенереному члену
power((generate_series(1,n)),3)

-- Генерация и преобразование в массив
SELECT ARRAY(SELECT * FROM GENERATE_SERIES(2, 10, 2))



-- Сортировка массивов есть в разделе груп бай



-- Добавлят в начало массива(array_agg ...) элемент, тут строку (format('*** %s ***', developer_title))
array_prepend(format('*** %s ***', developer_title), array_agg(attribute order by attribute))

-- Создает строку по шаблону
format('*** %s ***', developer_title)











--













--
