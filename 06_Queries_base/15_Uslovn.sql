--                                    Условные операторы/условная логика в SQL

-- Условие возврвщающее TRUE или FALSE (можно писать без оператора)
SELECT id, n % x = 0 AND n % y = 0 AS res FROM kata;



--                                                     CASE

-- Синтаксис стандартный:
CASE
  WHEN условие_1      -- условие пишется после ключевого слова WHEN
    THEN результат_1  -- значение что вернет условный оператор CASE, если условие_1 вернет TRUE
  -- Может быть несколько условий, если первое вернет FALSE то переходит ко второму условию, тотом к третьему итд
  WHEN условие_2 THEN результат_2
  -- ELSE - вернет данный результат, если все условия выше вернули FALSE. Если не указать ELSE и все условия окажутся не верны то условный оператор CASE вернет NULL
  ELSE 'Начальная школа'
END

-- [PostgreSQL и некоторые другие СУБД] Синтаксис с записью сравниваемого значения после CASE, подходит если сравнивает только с 1м значением в условии. Этот синтаксис уже не является стандартным в базовом SQL, но применяется в некоторых СУБД
CASE num
  WHEN 11 THEN 'Старшая школа'  -- если num == 11
  WHEN 9 THEN 'Средняя школа'   -- если num == 9
  ELSE 'Начальная школа'        -- если num != 11 && num != 9
END

-- Можно использовать один условный оператор CASE внутри другого для более сложных ветвлений условий
CASE
  WHEN meta_item_id IS NULL THEN 0
  ELSE
    CASE
      WHEN balance = TRUE THEN portions_possible
      ELSE portions_by_plan
    END
END


-- Условный оператор CASE можно использовать в блоках:
-- SELECT   - при вычислении значений для столбцов
-- WHERE    - при вычислении условий
-- HAVING   - при вычислении условий
-- JOIN ON  - при вычислении условий при соединении таблиц
-- ORDER BY - для выбора сортируемой колонки или выражения


-- 1. SELECT - результат CASE в полях SELECT чаще всего представляет собой значение какого-то нового выводимого столбца
SELECT first_name, second_name, -- другие выводимые запросом колонки
  CASE
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (10, 11) THEN 'Старшая школа'
    WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (5, 6, 7, 8, 9) THEN 'Средняя школа'
    ELSE 'Начальная школа'
  END AS stage, -- добавляет колонку stage со значениями, которые в каждой строке выбираются в зависимости от этого условия
  -- Можно использовать несколько условных операторов для вывода нескольких колонок:
  CASE WHEN some == 5 THEN 'five' ELSE 'not five' END AS five
FROM Class

-- Запись сравниваемого значения после CASE, подходит если сравнивает только с 1м значением в условии. Этот синтаксис уже не является стандартным в базовом SQL, но применяется в PostgreSQL и некоторых других СУБД
SELECT
  CASE SUBSTRING(name, 1, INSTR(name, ' '))
    WHEN 11 THEN 'Старшая школа'
    WHEN 9 THEN 'Средняя школа'
    ELSE 'Начальная школа'
  END AS stage
FROM Class

-- С агрегациией и группировкой:
SELECT neme, SUM(num)
  -- Можно производить агрегацию внутри условия:
  CASE
    WHEN SUM(num) >= 150 THEN 'Top' -- используем агрегацию, чтобы вернуть просто значение в результат группировки этой колонки
    WHEN SUM(num) + 5 > 100 THEN 'Mid'
    ELSE SUM(num)                   -- вернем результат агрегации
  END AS rating,
  -- Можно производить агрегацию над результатом условия
  COUNT(CASE WHEN d.detail LIKE '%oo%' THEN 1 ELSE 0 END) AS good,
  COUNT(CASE WHEN d.detail = 'bad' THEN 1 ELSE 0 END) AS bad
FROM products p JOIN details d ON p.id = d.product_id
GROUP BY name


-- 2. ORDER BY - результат CASE в зоне ORDER BY для выбора столбца для сортировки
SELECT contact_name, city, country FROM customers
ORDER BY contact_name, (CASE WHEN city IS NULL THEN country ELSE city END); -- тоесть в зависимости от условий сортировать будем либо по country, либо по city, хз обязательны ли скобки.


-- 3. WHERE - результат CASE в зоне WHERE для фильтрации в зависимости от условий
SELECT * FROM class WHERE SUBSTRING(CASE WHEN n = 1 THEN f_name WHEN n = 2 THEN m_name ELSE l_name END, 1, 2) = 'Kr';
SELECT * FROM film WHERE length > CASE WHEN rating = 'G' THEN 90 ELSE 120 END;


-- 4. JOIN ON - результат CASE в зоне JOIN ON для вычисления условий соединения
SELECT * FROM class JOIN class2 ON CASE WHEN class.grade = 'A' THEN 1 ELSE class.subject_id = class2.subject_id END; -- ??? тоесть соединяем строку 2й таблицы, в которой subject_id будет соответсвовать определенному текстовому значению из class.grade если 1е условие срабатывает, остальное будем соединять по соответсвию айди ???



--                                                  COALESCE

-- COALESCE - это функция, которая вычисляет по порядку каждый из своих аргументов и возвращает значение первого по порядку аргумента, который был не NULL. Вернет NULL, если все аргументы это NULL.
SELECT COALESCE(NULL, NULL, 1, 2, NULL, 3) FROM some;                      --> 1
SELECT name, COALESCE(bonus1, bonus2, 1000000) AS bonus FROM table_name;   -- если bonus1 == NULL выбирает значение bonus2 если и оно == NULL, тогда выбирает 1000000

-- COALESCE предполагает, что все аргументы это данные одного и того же типа или NULL, тк помещает их в одну колонку, поэтому может потребоваться применить преобразование типов
SELECT COALESCE(order_id::TEXT, 'no orders') FROM customers;

-- Замена других значений в комбинации с NULLIF
SELECT COALESCE(NULLIF(name, ''), '[product name not found]') AS name FROM eusales  -- при помощи NULLIF, проверяем пустая ли строка и меняем пустые строки на NULL, чтобы применить COALESCE



--                                                   NULLIF

-- NULLIF(значение_1, значение_2) - возвращает NULL, если значение_1 равно значению_2, если они не равны то возвращает значение_1(тоесть колонку для проверки ставим в 1).
SELECT NULLIF("SQL Academy", "SQL Academy") AS sql_trainer;                 --> <NULL>
SELECT NULLIF("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;    --> "SQL Academy"



--                                            [PostgreSQL] BOOL_OR

-- [постгресс] BOOL_OR(column = value)  Если значение равно значению столбца вернет true иначе false
SELECT username,
  BOOL_OR(role = 'internal') AS internal,
  BOOL_OR(role = 'admin') AS admin
FROM user_roles;



--                                              [MySQL ??] IFNULL

-- IFNULL(значение, альтернативное_значение) - возвращает значение, переданное первым аргументом, если оно не равно NULL, иначе возвращает альтернативное_значение
SELECT IFNULL("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;     --> "SQL Academy"
SELECT IFNULL(some, "Альтернатива SQL Academy") AS sql_trainer;



--                                                  [MySQL] IF

-- IF (условное_выражение, значение_1, значение_2). Если условное выражение в первом аргументе в функции IF, истинно, функция вернёт значение второго аргумента значение_1, иначе возвращается значение третьего аргумента значение_2.

SELECT IF(10 > 20, "TRUE", "FALSE"); --> "FALSE"
SELECT price, IF(price >= 150, "Комфорт", "Эконом") AS category FROM Rooms; -- ставим значеня в зависимости от price
SELECT price, IF(price >= 200, "Бизнес", IF(price >= 150, "Комфорт", "Эконом")) AS category FROM Rooms; -- вложение одного IF в другой(эмуляция CASE)














--
