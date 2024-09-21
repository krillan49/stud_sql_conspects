--                                            DROP TABLE Удаление таблиц

-- [PostgreSQL, MySQL]
DROP TABLE имя_таблицы;                   -- удалить таблицу "имя_таблицы" из текущей БД
DROP TABLE IF EXISTS имя_таблицы;         -- удаление только если она существует



--                                 ALTER TABLE добавление/изменение/удаление колонок

-- https://www.postgresql.org/docs/current/sql-altertable.html


-- [ PostgreSQL ] Основная команда изменения таблиц:
ALTER TABLE table_name action
ALTER TABLE IF EXISTS table_name action
-- где action - действие/подкоманда с таблицей


-- Подкоманды(action) записываются после ALTER TABLE:
RENAME TO new_table_name                          -- изменить название таблицы
RENAME old_column_name TO new_column_name         -- изменить название столбца на другое
ADD COLUMN column_name column_type constraints    -- добавить новую колонку с именем и типом данных и ограничениями
ADD COLUMN price decimal CONSTRAINT CHK_book_price CHECK (price > 0); -- добавим колонку сразу с констрэйтом
ALTER COLUMN column_name SET DATA TYPE data_type  -- изменить тип данных столбца
DROP COLUMN column_name                           -- удалить столбец
ADD CONSTRAINT constraint_name PRIMARY KEY(chair_id);  -- добавить ограничение на столбец (CONSTRAINT и его имя писать не обязательно)
ADD CONSTRAINT fk_books_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id);  -- добавим внешний ключ
DROP CONSTRAINT constraint_name                   -- удалить ограничение просто по его имени
ALTER COLUMN status SET DEFAULT 'r';              -- добавить значение по умолчанию
ALTER COLUMN status DROP DEFAULT;                 -- убрать значение по умолчанию


-- Примеры:
ALTER TABLE student ADD COLUMN rating FLOAT;                           -- добавим колонку rating FLOAT в таблицу student
ALTER TABLE people ADD name VARCHAR(32);                               -- добавляем в таблицу people новый столбец name(? Хз можно ли так сокращенно в Постгрэ)
ALTER TABLE people DROP COLUMN name;                                   -- из таблицы people удаляем столбец name
ALTER TABLE table_name DROP COLUMN col_name1, DROP COLUMN col_name2;   -- удаляем несколько столбцов
ALTER TABLE cathedra RENAME TO chair;                                  -- переименуем таблицу cathedra в chair
ALTER TABLE chair RENAME cathedra_id TO chair_id;                      -- переименуем колонку cathedra_id в chair_id
ALTER TABLE student ALTER COLUMN first_name SET DATA TYPE varchar(64); -- сменим тип данных в колонке student
ALTER TABLE exam ADD PRIMARY KEY(exam_id);                             -- добавим первичный ключ в колонку exam_id таблицы exam
ALTER TABLE book ADD CONSTRAINT fk_book_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id); -- добавим вторичный ключ в таблицу book в поле publisher_id ссылающийся на поле publisher_id в таблице publisher

-- CHANGE - изменить название, тип данных и доп условие столбца(? Хз можно ли так сокращенно в Постгрэ)
ALTER TABLE people CHANGE name other_name TEXT NOT NULL;               -- изменяем имя и тип данных столбца name

-- Если добавляем колонку с NOT NULL, то нужно добавить и DEFAULT, чтобы колонка могла быть создана, иначе будет ошибка
ALTER TABLE tab1
ADD COLUMN some_col INT DEFAULT(0) NOT NULL;















--
