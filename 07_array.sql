--                                                Массивы

-- https://www.postgresql.org/docs/current/functions-array.html
-- https://postgrespro.ru/docs/postgrespro/9.6/arrays
-- https://postgrespro.ru/docs/postgrespro/9.6/functions-array

TEXT[], INT[] --...  - массивы


SELECT * FROM film WHERE ARRAY['Trailers', 'Deleted Scenes'] <@ special_features
SELECT * FROM film WHERE 'Deleted Scenes' = ANY(special_features) AND 'Behind the Scenes' != ALL(special_features)     --#=> вроде такой синтаксис лучше

UNNEST -- создает новые строки из массива(была одна строка массив, слало много строк по числу элементов массива и так каждый массив, повторы не убираются)
SELECT UNNEST(special_features) AS feature FROM film

SELECT GENERATE_SERIES(2, 100) AS nums                           --#=> Создает массив чисел от 2х до 100?
SELECT GENERATE_SERIES('2005-05-24', '2005-06-02', interval  '1 day')   --#=> с датами и заданным интервалом

select 0, '-' from generate_series(1,10)                         -- можно использовать как изначальные данные, тут чтоб создать таблицу с одинаковыми значениями в 2х столбцах из 10 строк

ARRAY[1,4,3] @> ARRAY[3,1,3]                        --#=> t   Содержит ли первый массив второй(каждый элемент второго массива равен какому-то элементу первого массива)
ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]                    --#=> t   Содержитcя ли первый массив во втором
( (ARRAY_1 @> ARRAY_2) AND (ARRAY_1 <@ ARRAY_2) )   --#=> Быстрый способ сравнить два массива(но не учитывает разные количесва одинаковых элементов)

SELECT city_name FROM stations WHERE city_name LIKE ANY(ARRAY['A%','E%','I%','O%','U%'])   -- соответсвие любому в массиве














--













--
