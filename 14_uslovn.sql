--                                   CASE (условный оператор/условная логика)

-- CASE - результат обычно представляет собой значение какогото нового выводимого столбца

SELECT
  name,
  CASE             --  несколько условий(если первое не срабатывает переходим ко второму итд)
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (10, 11) THEN "Старшая школа"
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (5, 6, 7, 8, 9) THEN "Средняя школа"
    ELSE "Начальная школа"
  END AS stage     --  возвращаем в новую колонку stage значения в зависимости от условия
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

-- Несколько условных операторов в запросе записываются через запятую
SELECT
  CASE
    WHEN SUM(number1)%2=0 THEN MAX(number1)
    ELSE MIN(number1)
  END AS number1,
  CASE
    WHEN SUM(number2)%2=0 THEN MAX(number2)
    ELSE MIN(number2)
  END AS number2
FROM numbers

-- В одну строку с надфункцией(какойто странный пример ??)
SELECT p.name,
  COUNT(CASE WHEN d.detail LIKE '%oo%' THEN 1 ELSE 0 END) AS good,
  COUNT(CASE WHEN d.detail = 'ok'  THEN 1 ELSE 0 END) AS ok,
  COUNT(CASE WHEN d.detail = 'bad' THEN 1 ELSE 0 END) AS bad
FROM products p JOIN details d ON p.id = d.product_id



--                                     IF (условная функция/условная логика) (нет postgre)

-- IF (условное_выражение, значение_1, значение_2). Если условное выражение в первом аргументе в функции IF, истинно, функция вернёт значение второго аргумента значение_1, иначе возвращается значение третьего аргумента значение_2.

SELECT IF(10 > 20, "TRUE", "FALSE");                                          --> "FALSE"
SELECT price, IF(price >= 150, "Комфорт", "Эконом") AS category FROM Rooms    -- ставим значеня в зависимости от price
SELECT price, IF(price >= 200, "Бизнес", IF(price >= 150, "Комфорт", "Эконом")) AS category FROM Rooms   -- вложение одного IF в другой(эмуляция CASE)



--                                          IFNULL (условная функция)

-- IFNULL(значение, альтернативное_значение) - возвращает значение, переданное первым аргументом, если оно не равно NULL, иначе возвращает альтернативное_значение
SELECT IFNULL("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;     --> "SQL Academy"
SELECT IFNULL(some, "Альтернатива SQL Academy") AS sql_trainer;



--                                          NULLIF (условная функция) (работает в постгрэ)

-- NULLIF(значение_1, значение_2) - возвращает NULL, если значение_1 равно значению_2, в противном случае возвращает значение_1(тоесть колонку для проверки ставим в 1)
SELECT NULLIF("SQL Academy", "SQL Academy") AS sql_trainer;                 --> <NULL>
SELECT NULLIF("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;    --> "SQL Academy"



--                                                  COALESCE

-- COALESCE - это специальное выражение, которое вычисляет по порядку каждый из своих аргументов и на выходе возвращает значение первого аргумента, который был не NULL.
SELECT COALESCE(NULL, NULL, 1, 2, NULL, 3)                                 --> 1
SELECT name, COALESCE(bonus1, bonus2, 1000000) AS bonus FROM table_name    -- если bonus1 == NULL выбирает значение bonus2 если и оно == NULL, тогда выбирает 1000000

SELECT COALESCE(NULLIF(name, ''), '[product name not found]') AS name FROM eusales  -- при помощи NULLIF меняем пустые строки на NULL чтобы применить COALESCE



--                                      [постгресс] BOOL_OR

-- [постгресс] BOOL_OR(column = value)  Если значение равно значению столбца вернет true иначе false
SELECT username, BOOL_OR(role = 'internal') AS internal, BOOL_OR(role = 'admin') AS admin FROM user_roles



--                                     [постгресс ??] Условие без оператора

-- Условие возврвщающее тру или фолс можно писать без оператора
SELECT id, n % x = 0 AND n % y = 0 AS res FROM kata













--
