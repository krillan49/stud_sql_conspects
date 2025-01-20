--                                              Соответсвие

-- string ~ regex  -  определяет строки соответсующие регулярке (в постгре регистр не учитывает ??)
SELECT city_name, city_name ~ '^[AEIOU]' AS a FROM stations;   -- ищет совпадения с первой буквой из указанных

-- [PostgreSQL] REGEXP_COUNT(строка, шаблон [, start [, flags]]) — системная функция, подсчитывает количество мест, где шаблон регулярного выражения POSIX соответствует строке. start - считает начиная с этого индекса
-- Работает только с 15й версии Постгрэ
REGEXP_COUNT('ABCABCAXYaxy', 'A.')         --> 3
REGEXP_COUNT('ABCABCAXYaxy', 'A.', 1, 'i') --> 4



--                                               Подстроки

-- SUBSTRING(string FROM regex)   - вырезать из строки по шаблону регулярки
SELECT SUBSTRING(greeting FROM '#\d+') AS user_id FROM greetings;   --   Bienvenido tal #470815 BD. -> #470815



--                                          Замена элементов строки

-- REGEXP_REPLACE(строка, регулярка, элемент замены, позиция(число, не обязательно))  -  заменить элементы строки по шаблону регулярки
REGEXP_REPLACE('1, 4, и 10 числа', '\d','@','g'),      --> '@, @, и @@ числа' меняем любую цифру на @ ([PostgreSQL] - само меняет только 1й раз, нужно добавить 'g'; [ORACLE, PL/SQL] - само меняет все цифры те флаг 'g' не нужен)
REGEXP_REPLACE(str, '[aeiou]', '', 'gi') AS res,       -- 2 флага для регулярки
REGEXP_REPLACE('John Doe', '(.*) (.*)', '\2, \1'),     --> 'Doe, John'
REGEXP_REPLACE(str, ('^' || n || '[aeiou]'), '', 'gi') -- с объединением в регулярку значения столбца



--                                        Разбитие стоки в строки таблицы

-- REGEXP_SPLIT_TO_TABLE(имя_столбца, регулярное_выражение) - сделать новые строки из подстрок строки разбитой по regex
SELECT REGEXP_SPLIT_TO_TABLE(str, '[aeiou]') AS results FROM random_string  -->  разбиваем строку по гласным(с их удалением) в столбец таблицы















--
