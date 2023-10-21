--                                           Условная логика

-- CASE (условный оператор/условная логика) - результат обычно представляет собой значение какогото нового выводимого столбца
SELECT
name,
CASE
 WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (10, 11) THEN "Старшая школа"
 WHEN SUBSTRING(name, 1, INSTR(name, ' ')) IN (5, 6, 7, 8, 9) THEN "Средняя школа"
 ELSE "Начальная школа"
END AS stage     --#=>   возвращаем в новую колонку stage значения в зависимости от условия
FROM Class        --#=>   несколько условий(если первое не срабатывает переходим ко второму итд)

SELECT
CASE
  WHEN SUM(number1)%2=0 THEN MAX(number1)
  ELSE MIN(number1)
END AS number1,
CASE
  WHEN SUM(number2)%2=0 THEN MAX(number2)
  ELSE MIN(number2)
END AS number2
FROM numbers      --#=>    несколько условных операторов через запятую

SELECT name,
CASE SUBSTRING(name, 1, INSTR(name, ' '))
  WHEN 11 THEN "Старшая школа"
  WHEN 9 THEN "Средняя школа"
  ELSE "Начальная школа"
END AS stage
FROM Class        --#=>   просто стравниваем значения CASE со значениями в WHEN по одному(придется писать много условий для каждого класса)

SELECT p.name,
COUNT(CASE WHEN d.detail LIKE '%oo%' THEN 1 ELSE 0 END) AS good,
COUNT(CASE WHEN d.detail = 'ok'  THEN 1 ELSE 0 END) AS ok,
COUNT(CASE WHEN d.detail = 'bad' THEN 1 ELSE 0 END) AS bad
FROM products p
INNER JOIN details d ON p.id = d.product_id  --#=> в одну строку с надфункцией



-- IF (условная функция/условная логика) - IF (условное_выражение, значение_1, значение_2);
-- (Если условное выражение в первом аргументе в функции IF, истинно, функция вернёт значение второго аргумента значение_1, иначе возвращается значение третьего аргумента значение_2)
SELECT IF(10 > 20, "TRUE", "FALSE");                                                          --#=> "FALSE"
SELECT id, price, IF(price >= 150, "Комфорт-класс", "Эконом-класс") AS category FROM Rooms    --#=> ставим значеня в колонке category в зависимости от значения колонки price
SELECT id, price, IF(price >= 200, "Бизнес-класс", IF(price >= 150, "Комфорт-класс", "Эконом-класс")) AS category FROM Rooms   --#=> вложение одного IF в другой(эмуляция CASE)

-- IFNULL (условная функция) - IFNULL(значение, альтернативное_значение); возвращает значение, переданное первым аргументом, если оно не равно NULL, иначе возвращает альтернативное_значение
SELECT IFNULL("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;

-- NULLIF (условная функция) - NULLIF(значение_1, значение_2); возвращает NULL, если значение_1 равно значению_2, в противном случае возвращает значение_1(тоесть колонку для проверки ставим в 1)
SELECT NULLIF("SQL Academy", "SQL Academy") AS sql_trainer;                                   --#=> <NULL>
SELECT NULLIF("SQL Academy", "Альтернатива SQL Academy") AS sql_trainer;                      --#=> "SQL Academy"

-- COALESCE - это специальное выражение, которое вычисляет по порядку каждый из своих аргументов и на выходе возвращает значение первого аргумента, который был не NULL.
SELECT COALESCE(NULL, NULL, 1, 2, NULL, 3)                                                    --#=> 1
SELECT name, COALESCE(bonus1, bonus2, 1000000) AS bonus FROM table_name                       --#=> если bonus1==NULL выбирает значение bonus2 если и оно ==NULL, тогда выбирает 1000000

SELECT COALESCE(NULLIF(name,''), '[product name not found]') AS name FROM eusales             --#=> при помощи NULLIF меняем пустые строки на NULL чтобы применить COALESCE














-- 
