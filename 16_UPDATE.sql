--                                             UPDATE

-- UPDATE - редактирования существующих записей в таблицах

-- UPDATE имя_таблицы SET поле_таблицы1 = значение_поля_таблицы1, поле_таблицыN = значение_поля_таблицыN [WHERE условие_выборки]

-- (!!! Будьте внимательны, когда обновляете данные. Если вы пропустите оператор WHERE, то будут обновлены все записи в столбце/таблице. !!!)

UPDATE Family SET name = "Andie Anthony" WHERE name = "Andie Quincey";     --#=> если в столбце name есть значение "Andie Quincey" то заменим его на "Andie Anthony"
UPDATE users SET name = 'Иван' WHERE id = 5 AND age = 44;                  --#=> с 2мя условиями выборки
UPDATE users SET name = 'Иван', password ='qwerty' WHERE id = 5;           --#=> меняем значение сразу 2х колонок у строки с айди 5
UPDATE Payments SET unit_price = unit_price * 2                            --#=> меняем все значения столбца unit_price на их удвоенные значения
UPDATE Payments SET unit_price = unit_price * 3 WHERE id > 6               --#=> меняем те значения столбца unit_price на их утроенные значения, если их айди больше 6
