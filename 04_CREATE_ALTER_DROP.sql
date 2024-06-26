--                           Создание, удаление БД и таблиц. Добавление новых колонок.


DESCRIBE TableName;   -- (?? в скюлайт не работает ??)посмотреть типы данных столбцов таблицы
SHOW DATABASES;       -- (?? в скюлайт не работает ??)выведет все БД и таблицы(?) а так же служебные(information_schema, mysql, performance_schema, sys)


-- Операторы определения данных (Data Definition Language, DDL):
-- CREATE создаёт объект базы данных (саму базу, таблицу, представление, пользователя и так далее)
-- ALTER изменяет объект,
-- DROP удаляет объект;



--                                         CREATE DATABASE Создание БД

-- для имени БД можно использовать буквы, цифры, а также символы "_" и "$". Имя может начинаться с цифр, но не может состоять только из них. Максимальная длина имени составляет 64 знака.

CREATE DATABASE имя_базы_данных;                -- создание БД (В PostgreSQL так же)
CREATE DATABASE IF NOT EXIST имя_базы_данных;   -- создание БД только если ее не существует(! Проверить EXIST ошибка или правильно для МайСКЛ)
CREATE DATABASE IF NOT EXISTS имя_базы_данных;   -- [PostgreSQL]создание БД только если ее не существует

-- PostgreSQL
CREATE DATABASE db_name
  WITH  -- Параметры создания БД. По умолчанию, такие параметры будут заданы автоматически, если все это не писать
  OWNER = postgres         -- пользователь/владелец
  ENCODING = 'UTF8'        -- кодировка в которой будут символы нашей БД
  LOCALE_PROVIDER = 'libc' -- локаль определяет для разных регионов например формат Флоат(точка или запятая), дат итд
  CONNECTION LIMIT = -1;   -- ограничение на колич подключений к БД (-1 значит что ограничений нет)
  IS_TEMPLATE = False;



--                                        DROP DATABASE Удаление БД

-- [PostgreSQL] У той БД которую хотим удалить не должен существовать сеанс подключения иначе возникнет ошибка
-- чтобы удалить все подключения к некой БД:
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'имя_бд' AND pid <> pg_backend_pid()


DROP DATABASE имя_базы_данных;                   -- удаление БД  (В PostgreSQL так же)
DROP DATABASE IF EXISTS имя_базы_данных;         -- удаление БД только если она существует (В PostgreSQL так же)
DROP DATABASE IF EXIST имя_базы_данных;         -- (! Проверить EXIST ошибка или правильно для МайСКЛ)



--                                               Создание таблиц

USE имя_базы_данных;   -- выбрать(ели не выбрана другим образом) базу данных, в которую таблица будет записана.


-- Основные свойства(опции) колонок:
PRIMARY KEY    -- указывает колонку/колоноки как первичный ключ(он всегда уникальный, этим гарантирует уникальность всей строки)
AUTO_INCREMENT -- значение будет автоматически увеличиваться при добавление новых записей. Максимум одна такая колонка. Можно применять только к int и float.
UNIQUE         -- значения в данной колонке для всех записей должны быть отличными друг от друга.
NOT NULL       -- значения в данной колонке должны быть отличными от NULL, тоесть обязательны к заполнению, если будет не заполнено выдаст ошибку
DEFAULT        -- значение в колонке по умолчанию (данный параметр не применяется к типам BLOB, TEXT, GEOMETRY и JSON).


-- Варианты создания таблиц:
CREATE TABLE "Some" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" TEXT, "Price" INTEGER); -- кавычки не обязательны
CREATE TABLE Users (id INT, name VARCHAR(255), age INT, PRIMARY KEY (id)); -- PRIMARY KEY можно присваивать и так
CREATE TABLE IF NOT EXISTS "Some" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" TEXT, "Price" INTEGER); -- создания новой таблицы, если такой еще не существует (избавляет от ошибки если существует)
CREATE TABLE Users (id INT PRIMARY KEY, name VARCHAR(255) NOT NULL, age INT NOT NULL DEFAULT 18) -- age - поле числового типа со значением по умолчанию равным 18

-- [PostgreSQL] тоже самое
CREATE TABLE publisher
(
  publisher_id INTEGER PRIMARY KEY,
  org_name VARCHAR(128) NOT NULL,
  address TEXT NOT NULL
);

-- [PostgreSQL]
CREATE TABLE public.publisher -- тоесть таблица publisher создастся в схеме public
(
  publisher_id integer NOT NULL,
  org_name character varying(128) NOT NULL,
  address text NOT NULL,
  CONSTRAINT pk_publisher_id PRIMARY KEY (publisher_id) -- альтернативный синтаксис для задания ограницения(тут PRIMARY KEY) для столбца publisher_id
  -- CONSTRAINT  - создает имя (тут pk_publisher_id - по соглашениям называется как имя столбца с префиксом pk_ для праймари кей) для ограничения (PRIMARY KEY в том числе - это ограничение)
);


-- FOREIGN KEY (имя_столбца) REFERENCES Имя_таблицы_с_первичным_ключем (id) - создания таблицы с внешним ключом. REFERENCES - значит ссылка:
-- FOREIGN KEY задав соответсвующие айди позволяетсвязать 2 таблицы и удобно делать запросы объединяющие данные из них
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id));
-- внешний ключ company ссылается на первичный ключ id таблицы Companies
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id), FOREIGN KEY (name) REFERENCES People (id)); -- несколько внешних ключей


-- Доп опции (?? для полей с FOREIGN KEY) задаваемые при создании таблиц:
ON DELETE RESTRICT -- база данных не даст удалить компанию, у которой в таблице Users есть данные(Cannot delete or update a parent row: a foreign key constraint fails)
ON DELETE CASCADE  -- при удалении компании будут удалены все пользователи, ссылающиеся на эту компанию.
ON DELETE SET NULL -- база данных запишет NULL в качестве значения поля company для всех пользователей, работавших в удалённой компании.
ON UPDATE CASCADE  -- если компания изменит свой идентификатор, то все пользователи (Users) получат новый идентификатор в поле company.

CREATE TABLE Users (id INT, name VARCHAR(255) NOT NULL, age INT NOT NULL DEFAULT 18, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id) ON DELETE RESTRICT ON UPDATE CASCADE);

-- [PostgreSQL] создадим таблицу с внешним ключем fk_publisher_id ссылающимся на publisher_id таблицы publisher (один ко многим)
CREATE TABLE book
(
	book_id integer PRIMARY KEY,
	title text NOT NULL,
	isbn varchar(32) NOT NULL,
	fk_publisher_id integer REFERENCES publisher(publisher_id) NOT NULL -- В PostgreSQL тут при создании таблтцы не обязвтельно писать FOREIGN KEY, достаточно REFERENCES
);

-- [PostgreSQL] создадим таблицу person и с уникальным(отношение 1 к 1) внешним ключем passport
CREATE TABLE person
(
	person_id int PRIMARY KEY,
	first_name varchar(64) NOT NULL,
	last_name varchar(64) NOT NULL
);
CREATE TABLE passport
(
	passport_id int PRIMARY KEY,
	serial_number int NOT NULL,
	fk_passport_person int UNIQUE REFERENCES person(person_id) -- внешний ключ уникален тк отношение 1 к 1
);

-- [PostgreSQL] многие ко многим
CREATE TABLE book
(
	book_id integer PRIMARY KEY,
	title text NOT NULL,
	isbn varchar(32) NOT NULL,
);
CREATE TABLE author
(
	author_id integer PRIMARY KEY,
	full_name text NOT NULL,
	rating real
);
CREATE TABLE book_author
(
	book_id integer REFERENCES book(book_id),
	author_id integer REFERENCES author(author_id),

  CONSTRAINT book_author_pkey PRIMARY KEY (book_id, author_id) -- создаем так называемый "composite key" первичный ключ по 2м(или более) колонкам, тк только пара ключей уникальна, а каждый в отдельности может повторяться
);
-- Далее добавляем значения для каждой из таблиц



--                                              Удаление таблиц

DROP TABLE имя_таблицы;   -- удалить таблицу "Tablename" из данной БД (В PostgreSQL так же)

DROP TABLE IF EXISTS имя_таблицы;         -- удаление только если она существует (PostgreSQL)
DROP TABLE IF EXIST имя_таблицы;         -- (! Проверить EXIST ошибка или правильно для МайСКЛ)



--                                          Индексы. Создание и удаление.

-- При создании индекса и добавления его к полю, вы получаете более быстрый поиск данных по полю(чемто похожи на PRIMARY KEY или FOREIGN KEY, тк они тоже индесы но с уникальными свойствами)
-- Не нужно прописывать индексы для каждого из полей, так как это негативно скажется на оптимизации БД
-- Индексы никак визуально не отображаются в таблице ??

-- CREATE INDEX имя_индекса ON имя_таблицы(имя_колонки);  - создание индекса для столбца
CREATE INDEX Someidex ON people(name);  -- создаем инлекс Someidex для столбца name таблицы people, теперь поиск по этому полю будет быстрее для таблиц с большим колличеством строк

-- DROP INDEX имя_индекса ON имя_таблицы(имя_колонки);  - удаление индекса столбца
DROP INDEX Someidex ON people;          -- удаляем инлекс Someidex из таблицы people



--                                  Добавление/изменение/удаление колонок(столбцов)

-- ADD - добавить новое поле(столбец) в таблицу
ALTER TABLE people ADD name VARCHAR(32);                    -- добавляем в таблицу people новый столбец name

-- [ PostgreSQL ] добавим столбец fk_publisher_id
ALTER TABLE book
ADD COLUMN fk_publisher_id INTEGER;
-- Сделаем этот столбкц внешним ключем к колонке publisher_id таблицы publisher
ALTER TABLE book
ADD CONSTRAINT fk_book_publisher  -- тоесть добавляем ограничение по имени fk_book_publisher ...
FOREIGN KEY(fk_publisher_id) REFERENCES publisher(publisher_id); -- ... которое будет внешним ключем(имя) ссылающимся на колонку publisher_id в таблице publisher


-- CHANGE - изменить название, тип данных и доп условие столбца
ALTER TABLE people CHANGE name other_name TEXT NOT NULL;    -- изменяем имя и тип данных столбца name


-- DROP COLUMN - удалить столбец из таблицы
ALTER TABLE people DROP COLUMN name;                        -- из таблицы people удаляем столбец name

ALTER TABLE table_name DROP COLUMN column_name1, DROP COLUMN column_name2; -- несколько столбцов
















--
