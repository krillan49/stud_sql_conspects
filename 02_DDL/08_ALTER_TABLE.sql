--                                        ALTER TABLE. Изменение таблиц

-- https://www.postgresql.org/docs/current/sql-altertable.html

-- Изменение таблиц - это добавление/изменение/удаление колонок, изменение названия таблицы или столбца, добавление/удаление ограничений


-- [ PostgreSQL ] Основная команда изменения таблиц:
ALTER TABLE table_name [action];
ALTER TABLE IF EXISTS table_name [action];
-- action - действие/подкоманда с таблицей, записываются после ALTER TABLE



--                                                RENAME TO

-- RENAME TO - подкоманда/action для того чтобы переиментовать таблицу или отдельную колонку

-- RENAME TO new_table_name - изменить название таблицы
ALTER TABLE cathedra RENAME TO chair;              -- переименуем таблицу cathedra в chair

-- RENAME old_column_name TO new_column_name - изменить название столбца на новое
ALTER TABLE chair RENAME cathedra_id TO chair_id;  -- переименуем колонку cathedra_id в chair_id



--                                                ADD COLUMN

-- ADD COLUMN - подкоманда/action для того чтобы добавить колонку

-- ADD COLUMN column_name column_type constraints - добавить новую колонку с именем и типом данных, так же можно сразу с ограничениями:
ALTER TABLE student ADD COLUMN rating FLOAT;   -- добавим колонку rating FLOAT в таблицу student
ALTER TABLE student ADD COLUMN price DECIMAL CONSTRAINT CHK_book_price CHECK (price > 0); -- добавим колонку сразу с констрэйтом

-- (? Хз можно ли так сокращенно в Постгрэ) Сокращенный вариант добавить столбец без COLUMN
ALTER TABLE people ADD name VARCHAR(32); -- добавляем в таблицу people новый столбец name

-- Если добавляем колонку с ограничением NOT NULL, нужно добавить и DEFAULT, чтобы колонка могла быть создана, иначе будет ошибка
ALTER TABLE tab1 ADD COLUMN some_col INT DEFAULT(0) NOT NULL;



--                                               ADD CONSTRAINT

-- ADD CONSTRAINT - подкоманда/action для того чтобы добавить ограничение

-- ADD CONSTRAINT constraint_name PRIMARY KEY(field_name) - добавить первичный ключ на столбец (ключевое слово CONSTRAINT и его имя писать не обязательно)
ALTER TABLE exam ADD PRIMARY KEY(exam_id);    -- добавим первичный ключ в колонку exam_id таблицы exam

-- ADD CONSTRAINT constraint_name FOREIGN KEY(field) REFERENCES table_name(table_field) - добавим внешний ключ
ALTER TABLE book ADD CONSTRAINT fk_book_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id); -- добавим вторичный ключ в таблицу book в поле publisher_id ссылающийся на поле publisher_id в таблице publisher



--                                          DROP [COLUMN | CONSTRAINT]

-- DROP [COLUMN | CONSTRAINT] - подкоманды/action для того чтобы удалить колонку или ограничение

-- DROP COLUMN column_name         - удалить столбец
ALTER TABLE people DROP COLUMN name;                                   -- из таблицы people удаляем столбец name
ALTER TABLE table_name DROP COLUMN col_name1, DROP COLUMN col_name2;   -- удаляем несколько столбцов

-- DROP CONSTRAINT constraint_name - удалить ограничение по его имени



--                                               ALTER COLUMN

-- ALTER COLUMN - подкоманда/action для того чтобы изменить колонку, в том числе добавить или удалить значение по умолчанию

-- ALTER COLUMN column_name SET DATA TYPE data_type  - изменить тип данных столбца
ALTER TABLE student ALTER COLUMN name SET DATA TYPE VARCHAR(64);  -- сменим тип данных в колонке student на VARCHAR(64)

-- ALTER COLUMN status SET DEFAULT default_value;  - добавить значение по умолчанию
-- ALTER COLUMN status DROP DEFAULT;               - убрать значение по умолчанию(снова будет NULL)



--                                                 CHANGE

-- CHANGE - изменить название, тип данных и доп условие столбца(? Хз можно ли так сокращенно в Постгрэ)
ALTER TABLE people CHANGE name other_name TEXT NOT NULL;   -- изменяем имя и тип данных столбца name















--
