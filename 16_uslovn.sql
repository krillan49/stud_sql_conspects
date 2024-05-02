--                                   CASE (условный оператор/условная логика)

-- CASE - результат обычно представляет собой значение какогото нового выводимого столбца

SELECT
  name,
  CASE             --  несколько условий(если первое не срабатывает переходим ко второму итд)
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (10, 11) THEN "Старшая школа"
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (5, 6, 7, 8, 9) THEN "Средняя школа"
    ELSE "Начальная школа"
  END AS stage     --  возвращаем в новую колонку stage со значением в зависимости от условия
FROM Class

-- Запись сравниваемого значения после CASE, подходит если сравнивает только с 1м значением в условии
SELECT
  name,
  CASE SUBSTRING(name, 1, INSTR(name, ' '))
    WHEN 11 THEN "Старшая школа"
    WHEN 9 THEN "Средняя школа"
    ELSE "Начальная школа"
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



--                                          IFNULL (условная функция)

-- IFNULL(значение, альтернативное_значение) - возвращает значение, переданное первым аргументом, если оно не равно NULL, иначе возвращает альтернативное_значение
SELECT IFNULL("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;     --> "SQL Academy"
SELECT IFNULL(some, "Альтернатива SQL Academy") AS sql_trainer;



--                                                  COALESCE

-- COALESCE - это специальное выражение, которое вычисляет по порядку каждый из своих аргументов и на выходе возвращает значение первого по порядку аргумента, который был не NULL.
SELECT COALESCE(NULL, NULL, 1, 2, NULL, 3) FROM some;                      --> 1
SELECT name, COALESCE(bonus1, bonus2, 1000000) AS bonus FROM table_name    -- если bonus1 == NULL выбирает значение bonus2 если и оно == NULL, тогда выбирает 1000000

SELECT COALESCE(NULLIF(name, ''), '[product name not found]') AS name FROM eusales  -- при помощи NULLIF меняем пустые строки на NULL чтобы применить COALESCE



--                                          NULLIF (условная функция) (работает в PostgreSQL)

-- NULLIF(значение_1, значение_2) - возвращает NULL, если значение_1 равно значению_2, в противном случае возвращает значение_1(тоесть колонку для проверки ставим в 1)
SELECT NULLIF("SQL Academy", "SQL Academy") AS sql_trainer;                 --> <NULL>
SELECT NULLIF("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;    --> "SQL Academy"



--                                      [PostgreSQL] BOOL_OR

-- [постгресс] BOOL_OR(column = value)  Если значение равно значению столбца вернет true иначе false
SELECT username, BOOL_OR(role = 'internal') AS internal, BOOL_OR(role = 'admin') AS admin FROM user_roles



--                                     [PostgreSQL ??] Условие без оператора

-- Условие возврвщающее тру или фолс можно писать без оператора
SELECT id, n % x = 0 AND n % y = 0 AS res FROM kata



--                                     IF (условная функция/условная логика) (нет в PostgreSQL, есть в MySQL)

-- IF (условное_выражение, значение_1, значение_2). Если условное выражение в первом аргументе в функции IF, истинно, функция вернёт значение второго аргумента значение_1, иначе возвращается значение третьего аргумента значение_2.

SELECT IF(10 > 20, "TRUE", "FALSE");                                          --> "FALSE"
SELECT price, IF(price >= 150, "Комфорт", "Эконом") AS category FROM Rooms    -- ставим значеня в зависимости от price
SELECT price, IF(price >= 200, "Бизнес", IF(price >= 150, "Комфорт", "Эконом")) AS category FROM Rooms   -- вложение одного IF в другой(эмуляция CASE)








-- CASE внутри CASE
SELECT items.id,
       mi.is_by_storage_balance,
       pbp.portions_by_plan,
       greatest(floor(min(pbs.portions_possible))::integer, 0),
       case
           when ig.meta_item_id IS NULL
               then 0
           else
               case
                   when mi.is_by_storage_balance = true
                       then greatest(floor(min(pbs.portions_possible))::integer, 0)
                   else
                       pbp.portions_by_plan
                   end
           end main_portions,
       items.meta_item_id
FROM "items"







--
