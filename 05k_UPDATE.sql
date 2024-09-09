--                                              UPDATE

-- UPDATE - редактирование/изменение существующих значений колонок каких-то строк
UPDATE имя_таблицы SET колонка_1 = новое_значение_колонки_1, колонкаN = новое_значение_колонки_N WHERE условие_выборки

-- Если пропустить оператор WHERE, то будут изменены все записи в столбце/таблице.

UPDATE Family SET name = "Anthony" WHERE name = "Quincey";       -- если в столбце name есть значение "Quincey" заменим его на "Anthony"
UPDATE users SET name = 'Иван' WHERE id = 5 AND age = 44;        -- с 2мя условиями выборки
UPDATE users SET name = 'Иван', password ='qwerty' WHERE id = 5; -- меняем значение сразу 2х колонок у строки с айди 5
UPDATE Payments SET price = price * 2;                           -- меняем все значения столбца price на их удвоенные значения
UPDATE Payments SET price = price * 3 WHERE id > 6;              -- меняем те значения столбца price, где айди больше 6 на их утроенные значения
