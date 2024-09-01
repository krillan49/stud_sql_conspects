--                                   CASE (условный оператор/условная логика)

-- Условный оператор CASE можно использовать: в полях SELECT, при вычислении условий в WHERE или HAVING, при вычислении условий при соединении таблиц, при сортировке,


-- 1. CASE в полях SELECT - результат чаще всего представляет собой значение какогото нового выводимого столбца
SELECT
  name,
  CASE             --  несколько условий(если первое не срабатывает переходим ко второму итд)
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (10, 11) THEN 'Старшая школа'
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (5, 6, 7, 8, 9) THEN 'Средняя школа'
    ELSE 'Начальная школа'  -- если не указать ELSE и все условия окажутся не верны то вернет NULL
  END AS stage     --  возвращаем в новую колонку stage со значением в зависимости от условия
FROM Class

-- Запись сравниваемого значения после CASE, подходит если сравнивает только с 1м значением в условии. Этот синтаксис уже не является стандартным в базовом SQL, но применяется в PostgreSQL и некоторых других СУБД
SELECT
  name,
  CASE SUBSTRING(name, 1, INSTR(name, ' '))
    WHEN 11 THEN 'Старшая школа'
    WHEN 9 THEN 'Средняя школа'
    ELSE 'Начальная школа'
  END AS stage
FROM Class

-- Несколько условных операторов (с функцией в условии) в запросе записываются через запятую
SELECT
  CASE WHEN SUM(number1) % 2 = 0 THEN MAX(number1) ELSE MIN(number1) END AS number1,
  CASE WHEN SUM(number2) % 2 = 0 THEN MAX(number2) ELSE MIN(number2) END AS number2
FROM numbers

-- С функцией поверх условия(тут без группировки тк считаем все выводимые столбцы)
SELECT p.name,
  COUNT(CASE WHEN d.detail LIKE '%oo%' THEN 1 ELSE 0 END) AS good,
  COUNT(CASE WHEN d.detail = 'ok'  THEN 1 ELSE 0 END) AS some,
  COUNT(CASE WHEN d.detail = 'bad' THEN 1 ELSE 0 END) AS bad
FROM products p JOIN details d ON p.id = d.product_id

-- CASE внутри CASE
SELECT id, balance, portions_by_plan, portions_possible,
  CASE
    WHEN meta_item_id IS NULL THEN 0
    ELSE
      CASE
        WHEN balance = TRUE THEN portions_possible
        ELSE portions_by_plan
      END
  END AS main_portions
FROM items


-- 2. CASE - для выбора столбца для сортировки в зоне ORDER BY
SELECT contact_name, city, country
FROM customers
ORDER BY contact_name, (CASE WHEN city IS NULL THEN country ELSE city END); -- тоесть в зависимости от условий сортировать будем либо по country, либо по city, хз обязательны ли скобки.


-- 3. CASE при вычислении условий в WHERE
SELECT * FROM class
WHERE SUBSTRING(CASE WHEN n = 1 THEN f_name WHEN n = 2 THEN m_name ELSE l_name END, 1, 2) = 'Kr';

SELECT * FROM film WHERE length > CASE WHEN rating = 'G' THEN 90 ELSE 120 END;


-- 4. CASE при вычислении условий при JOIN
SELECT * FROM class JOIN class2 ON CASE WHEN class.grade = 'A' THEN 1 ELSE class.subject_id END = class2.subject_id -- тоесть соединяем строку 2й таблице в которой subject_id будет соответсвовать обределенному тестовому значению из class.grade если 1е условие срабатывает, остальное будем соединять по соответсвию айди


-- 5. CASE при группировке
SELECT neme, SUM(num)
  CASE
    WHEN SUM(num) >= 150 THEN 'Top'
    WHEN SUM(num) >= 100 THEN 'Mid'
    ELSE 'Low'
  END AS rating
FROM numbers GROUP BY name




--                                                  COALESCE

-- COALESCE - это функция, которая вычисляет по порядку каждый из своих аргументов и возвращает значение первого по порядку аргумента, который был не NULL. Вернет NULL, если все аргументы это NULL.
SELECT COALESCE(NULL, NULL, 1, 2, NULL, 3) FROM some;                      --> 1
SELECT name, COALESCE(bonus1, bonus2, 1000000) AS bonus FROM table_name    -- если bonus1 == NULL выбирает значение bonus2 если и оно == NULL, тогда выбирает 1000000

-- COALESCE - предполагает принятие во все аргументы данные одного и того же типа(или NULL), тк помещает их в одну колонку, поэтому может потребоваться применить преобразование типов
SELECT COALESCE(order_id::text, 'no orders') FROM customers;

-- Замена других значений в комбинации с NULLIF
SELECT COALESCE(NULLIF(name, ''), '[product name not found]') AS name FROM eusales  -- при помощи NULLIF, проверяем пустая ли строка и меняем пустые строки на NULL, чтобы применить COALESCE



--                                          NULLIF (условная функция)

-- NULLIF(значение_1, значение_2) - возвращает NULL, если значение_1 равно значению_2, если они не равны то возвращает значение_1(тоесть колонку для проверки ставим в 1).
SELECT NULLIF("SQL Academy", "SQL Academy") AS sql_trainer;                 --> <NULL>
SELECT NULLIF("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;    --> "SQL Academy"



--                                      [PostgreSQL] BOOL_OR

-- [постгресс] BOOL_OR(column = value)  Если значение равно значению столбца вернет true иначе false
SELECT username, BOOL_OR(role = 'internal') AS internal, BOOL_OR(role = 'admin') AS admin FROM user_roles



--                                     [PostgreSQL ??] Условие без оператора

-- Условие возврвщающее тру или фолс можно писать без оператора
SELECT id, n % x = 0 AND n % y = 0 AS res FROM kata



--                                      [MySQL ??] IFNULL (условная функция)

-- IFNULL(значение, альтернативное_значение) - возвращает значение, переданное первым аргументом, если оно не равно NULL, иначе возвращает альтернативное_значение
SELECT IFNULL("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;     --> "SQL Academy"
SELECT IFNULL(some, "Альтернатива SQL Academy") AS sql_trainer;



--                                    [MySQL] IF (условная функция/условная логика)

-- IF (условное_выражение, значение_1, значение_2). Если условное выражение в первом аргументе в функции IF, истинно, функция вернёт значение второго аргумента значение_1, иначе возвращается значение третьего аргумента значение_2.

SELECT IF(10 > 20, "TRUE", "FALSE");                                          --> "FALSE"
SELECT price, IF(price >= 150, "Комфорт", "Эконом") AS category FROM Rooms    -- ставим значеня в зависимости от price
SELECT price, IF(price >= 200, "Бизнес", IF(price >= 150, "Комфорт", "Эконом")) AS category FROM Rooms   -- вложение одного IF в другой(эмуляция CASE)














--
