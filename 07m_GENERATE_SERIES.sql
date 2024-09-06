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
SELECT n, factorial(n) AS res FROM generate_series(1, 5) AS t(n)  -- тут t(n) t - псевдоним таблицы/запроса что будет создан, n - имя колонки в запроса, куда будут генерироваться значения

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
