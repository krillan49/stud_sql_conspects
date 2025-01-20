--                                           Встроенные функции для строк

-- [PostgreSQL, MySQL] индексация строк начинается с 1, а не с 0.



--                                               Преобразование строк
SELECT
  UPPER('Hello world') AS upstring,  --> 'HELLO WORLD'  Возвращает строку в верхнем регистре
  LOWER('SQL Academy'),              --> 'sql academy'  Возвращает строку в нижнем регистре
  INITCAP(name),                     -- Capitalize name
  REVERSE(chars)                     -- реверсирует строку
FROM some;

-- Преобразование частей строк
SELECT
  REPLACE('aca', 'a', 'b'),                  -- 'bcb' замена одиночных символов на другие одиночные('a' to 'b')
  TRANSLATE(some, '123456789', '000011111')  -- как tr в Руби
FROM some;

-- Убрать крайние пробелы, удалить подстроку
SELECT
  TRIM(str),            -- [postgresql ?] убирает пробелы с краев
  TRIM(leading str),    -- [postgresql ?] убирает пробелы слева
  TRIM(trailing str),   -- [postgresql ?] убирает пробелы справа
  TRIM('er' from str),  -- [postgresql ?] убирает заданную подстроку
  RTRIM(str)            -- [postgresql ?] убирает пробелы справа
FROM some;

-- Форматирование/Интерполяция значения в строку(шаблон)
SELECT FORMAT('Hello, %s how are you doing today?', name) FROM some; -- подставит name в позицию %s



--                                Информация о строках(индекс подстроки, длинна строки)

SELECT
  LENGTH('sql-academy') AS size,           --> 11 Возвращает длину указанной строки
  CHAR_LENGTH(s1 || ' ' || s2) AS str,     --> 11 [PostgreSQL] Возвращает длину указанной строки
  INSTR('sql-academy', 'academy') AS idx,  --> 5  Возвращает позицию первого символа подстроки в строке
  STRPOS('sql-academy', 'academy'),        --> 5  [PostgreSQL ?] Возвращает позицию первого символа подстроки в строке
  POSITION('om' in 'Thomas') AS idx,       --> 3  [PostgreSQL] Возвращает позицию первого символа подстроки в строке
  STRPOS(email, '@')                       -- возвращает позицию заданного элмента в строке
FROM some;



--                                              Срезы и подстроки

LEFT('sql-academy', 3)       --> "sql" Возвращает заданное количество крайних левых символов строки
RIGHT('XYZ', - 1)            --> 'YZ'  оставляем все символы справа кроме первого

-- [PostgreSQL] SUBSTRING - возвращает часть строки:
SUBSTRING('PostgreSQL', 1, 5),               --> 'Postg' 1й аргумент стартовая позиция, 2й число элементов
SUBSTRING('PostgreSQL', 8),                  --> 'SQL'  с 1м аргументом берет все символы начиная с 8го
SUBSTRING('PostgreSQL' FROM 1 FOR 8),        -- полный синтаксис
SUBSTRING('PostgreSQL' FROM 8),              -- полный синтаксис
SUBSTRING(email, 1, STRPOS(email, '@') - 1),
SUBSTRING('The house number is 9001', '([0-9]{1,4})') AS house_no, --> '9001'  с регуляркой
SUBSTRING('PostgreSQL' FROM '%#"S_L#"%' FOR '#')                   --> 'SQL' скюэлевской регуляркой по типу LIKE



--                                       Дублирование и конкатинация строк

-- REPEAT(стобец, число повторений) - повторяет строковое значение.
REPEAT(name, 3) AS name

-- CONCAT / CONCAT_WS - конкатинация строковых значений столбцов в один столбец с добавлением дополнительных строчных элементов
CONCAT(first, '+', mid, 'k', last) AS title
CONCAT_WS(' ', first, mid, last) AS title    -- тоже самое что и выше, но если между значениями нужен одинаковый элемент(тут пробел)

-- [PostgreSQL] тоже что и 2 выше, оператор || конкатенации
first_name || ' ' || last_name AS full_name



--                                                Разбитие строк

-- [PostgreSQL] SPLIT_PART - разбивает строку и вохзвращает одну из ее частей, 2й аргумент символ по которому разбиваем, 3й агумент индекс части которую вернет
SPLIT_PART(chars, ',', 1) AS c1   -- разбивает строку chars по ',' и возвращает 1й из разбитых кусков
SPLIT_PART(chars, ',', -1) AS c2  -- вовращает последний элемент (работает только в новых версиях)



--                                                  Кодировка

-- [PostgreSQL] функции кодировки ASCII:
ASCII('A')  --> 65       получить код символа
CHR(65)     --> 'A'      получить символ из кода



















--
