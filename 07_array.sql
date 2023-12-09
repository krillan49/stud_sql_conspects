--                                                Массивы

-- https://www.postgresql.org/docs/current/functions-array.html
-- https://postgrespro.ru/docs/postgrespro/9.6/arrays
-- https://postgrespro.ru/docs/postgrespro/9.6/functions-array

TEXT[], INT[] -- массивы ??



--                                       Проверка на вхождение в массив

-- @> работает если оба параметра массивы
ARRAY[1,4,3] @> ARRAY[3,1,3]                        -- Содержит ли первый массив второй(каждый элемент второго массива равен какому-то элементу первого массива)
ARRAY[2,2,7] <@ ARRAY[1,7,4,2,6]                    -- Содержитcя ли первый массив во втором
( (ARRAY_1 @> ARRAY_2) AND (ARRAY_1 <@ ARRAY_2) )   -- Быстрый способ сравнить два массива(но не учитывает разные количесва одинаковых элементов)

-- Пример в запросе
SELECT * FROM film WHERE ARRAY['Trailers', 'Deleted Scenes'] <@ special_features  -- содержится ли 1й массив во втором
SELECT * FROM film WHERE 'Trailers' = ANY(special_features) AND 'Deleted Scenes' != ALL(special_features) -- тоже что и выше при помощи ANY. Проверяем содержится ли в массиве в данной строке столбца special_features данные значения

-- LIKE-соответсвие любому элементу в массиве
SELECT city_name FROM stations WHERE city_name LIKE ANY(ARRAY['A%','E%','I%','O%','U%'])



--                                         Преобразомание массива в строки

UNNEST -- создает новые строки из массива(была одна строка массив, слало много строк по числу элементов массива и так каждый массив, повторы не убираются)
SELECT UNNEST(special_features) AS feature FROM film



--                                        Преобразомание массива в текст

-- PostgreSQL предлагает встроенную функцию массива с именем ARRAY_TO_STRING() , которая принимает три аргумента: массив, разделитель/разделитель и текст для замены нулевых значений. Функция ARRAY_TO_STRING() преобразует заданный массив в строки и объединяет строки с помощью разделителя/разделителя. Тип возвращаемого значения функции ARRAY_TO_STRING() — ТЕКСТ
SELECT ARRAY_TO_STRING(arr, ':' , '-' ) FROM st_information;
-- arr - колонка с массивом
-- ':' - элемент который будет делить элементы массива в строке
-- '-' - элемент который заменит значения NULL из массива




--                                         Генерация массивов в запросах

SELECT GENERATE_SERIES(2, 100) AS nums                                  -- Создает массив чисел от 2х до 100
SELECT GENERATE_SERIES('2005-05-24', '2005-06-02', interval  '1 day')   -- с датами и заданным интервалом

-- используем для размножения строк в зависимости от цифры в quantity_in_stock
SELECT product_id, product_name, quantity_in_stock, GENERATE_SERIES(1, quantity_in_stock) AS n FROM products
-- тоже самое без создания доп колонки
SELECT product_id, product_name, quantity_in_stock
FROM products
CROSS JOIN GENERATE_SERIES(1, quantity_in_stock)
ORDER BY product_id DESC;

-- можно использовать как изначальные данные, тут чтоб создать таблицу с одинаковыми значениями в 2х столбцах из 10 строк
SELECT 0, '-' FROM GENERATE_SERIES(1, 10)



-- Сортировка массивов есть в разделе груп бай













--













--
