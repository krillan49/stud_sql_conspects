--                                               INSERT

-- INSERT - добавляет/вставляет в стаблицу новые данные/строки. Значения можно вставлять либо с помощью VALUES, перечислив их в круглых скобках через запятую, либо c помощью запроса SELECT например из другой таблицы:
-- INSERT INTO имя_таблицы (поле_таблицы, ...) VALUES (значение_поля_таблицы, ...)
-- INSERT INTO имя_таблицы (поле_таблицы, ...) SELECT поле_таблицы, ... FROM имя_таблицы ...

INSERT INTO Cars (Id, Name, Price) VALUES (1, 'BMW', 10000)   -- добавляем в столбцы(Id, Name, Price) новую строку со значениями(1, 'BMW', 10000)

-- Первичный ключ таблицы является уникальным значением и добавление уже существующего значения приведёт к ошибке.
INSERT INTO Goods SELECT COUNT(*) + 1, 'Table', 2 FROM Goods; -- вариант задания значения ключа способом SELECT

-- Во многих СУБД введён механизм его автоматической генерации первичного ключа. Для этого достаточно снабдить первичный ключ good_id атрибутом AUTO_INCREMENT.

-- Тогда при создании новой записи в качестве значения good_id достаточно передать NULL или 0(MySQL ??)
INSERT INTO Goods VALUES (NULL, 'Table', 2);

-- PostgreSQL есть схожий механизм. Он имеет типы SMALLSERIAL, SERIAL, BIGSERIAL. Столбец с одним из них будет являться целочисленным и автоматически увеличиваться при добавлении новой записи
CREATE TABLE Goods ( good_id SERIAL ... );
INSERT INTO Goods (good_name, type) VALUES ('Table', 2);


INSERT INTO Cars (Name, Price) VALUES ('Audi', 3000)                 -- если столбец(тут id) создан с параметром AUTOINCREMENT то его значения добавятся автоматически, соотв их писать не нужно
INSERT INTO Cars (Name) VALUES ('Audi')                              -- если добавить строку, содержащую не все столбцы, то в незаполненных столбцах будет значение NULL
INSERT INTO Cars VALUES ('Mersedes', 5000);                          -- можно опустить имена столбццов если заполняем их по порядку
INSERT INTO users (name, age) VALUES('Алексей', 38), ('Мартин', 12); -- добавление нескольких строк в одном запросе


-- sqlite3(??) Когда ставим значением столбца datetime() то в него помещается текущие дата и время(часовой пояс -3)
INSERT INTO Posts (content, created_date) VALUES ('Something', datetime());


-- Сложная вставка где одно из значений получается при помощи подзапроса возвращающего необходимое значение
INSERT INTO Goods
SELECT 'Table', (SELECT type FROM Goods JOIN Types ON Types.gt_id = Goods.type WHERE Types.gt_name = 'some' LIMIT 1)
FROM Goods;














--
