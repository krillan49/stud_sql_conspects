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
  CONNECTION LIMIT = -1    -- ограничение на колич подключений к БД (-1 значит что ограничений нет)
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



--                                    CREATE TABLE Создание таблиц и ограничения

USE имя_базы_данных;   -- выбрать(ели не выбрана другим образом) базу данных, в которую таблица будет записана.


-- Основные свойства/опции/ограничения для колонок/полей. Записываются после имени столбца и типа данных:
PRIMARY KEY    -- указывает колонку или несколько колонок одновременно как первичный ключ. Он всегда уникальный, этим гарантирует уникальность всей строки. Тоесть накладывает ограничение уникальности UNIQUE. Так же не позволяет всталять в колонку NULL значение, тоесть включает в себя и ограничение NOT NULL. Может быть только 1 первичный ключ во всей таблице, но он может быть наложен на несколько полей одновременно(композитный), для Постргэ это единственная разница между ним и просто колонкой UNIQUE NOT NULL, тк в ней нет кластеризованных ключей.
-- Сурогатный первычный ключ - это первичный ключ который мы сами назначем, например при помощи serial(пользователь не заполняет значение сам)
-- Натуральный первичный ключ - это первичный ключ который который записывает сам пользователь, например поле login или email может являться первичным ключем тк они обычно задаются уникальными

AUTO_INCREMENT -- (? хз насчет Постгрэ, тк там есть тип данных сериал) значение будет автоматически увеличиваться при добавление новых записей. Максимум одна такая колонка. Можно применять только к int и float.
UNIQUE         -- ограничение - значения в данной колонке для всех записей должны быть отличными друг от друга.
NOT NULL       -- ограничение - значения в данной колонке должны быть отличными от NULL, тоесть обязательны к заполнению, если будет не заполнено выдаст ошибку
DEFAULT        -- значение в колонке по умолчанию, тоесть если при добавлении данных не будет заполнена колонка то добавится значение по умолчанию вместо NULL (данный параметр не применяется к типам BLOB, TEXT, GEOMETRY и JSON).

-- [PostgreSQL]
CHECK(LENGTH(login) > 6)  -- ограничивает значение поля логическим выражением, тут дллинна значения для поля login должна быть больше 6
CHECK(LENGTH(login) > 6 AND login <> name) -- более сложное условие, чтобы логин и имя не совпадали

-- [PostgreSQL] если ограничение пишем отдельно от колонки, то:
CHECK(LENGTH(login) > 6 AND login <> name AND LENGTH(org_name) > 3) -- можем объединить все условия CHECK на разные столбцы в одно ограничение
UNIQUE(first_name, last_name) -- если хотим чтобы уникальными были значения не по 1му полю, а только по 2м сразу, тоесть можно одинаковое имя если разные фамилии, просто допавим в параметры одного UNIQUE
PRIMARY KEY(login, email) -- если хотим назначить составной первичный ключ по уникальности комбинации полей. Таким полям отдельно стоит задать NOT NULL

-- [PostgreSQL] - можно задавать название для ограничения, чтобы если оно нарушалось, то при вызове исключения писалось это название и мы понимали точно в чем проблема, особенно удобно для кастомных ограничений CHECK
CONSTRAINT length_more_then_six CHECK(LENGTH(login) > 6) -- Те CONSTRAINT потом название, потом ограничение
CONSTRAINT unique_name UNIQUE(first_name, last_name)
CONSTRAINT pk_publisher_id PRIMARY KEY (publisher_id)



-- Варианты создания таблиц:
CREATE TABLE "Some" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" TEXT, "Price" INTEGER); -- кавычки не обязательны
CREATE TABLE Users (id INT, name VARCHAR(255), age INT, PRIMARY KEY (id)); -- PRIMARY KEY можно присваивать и так
CREATE TABLE IF NOT EXISTS "Some" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" TEXT, "Price" INTEGER); -- создания новой таблицы, если такой еще не существует (избавляет от ошибки если существует)
CREATE TABLE Users (id INT PRIMARY KEY, name VARCHAR(255) NOT NULL, age INT NOT NULL DEFAULT 18) -- age - поле числового типа со значением по умолчанию равным 18

-- [PostgreSQL] тоже самое
CREATE TABLE publisher
(
  -- Задаем все поля, их типыданных и ограничения которые будут в таблице publisher
  email VARCHAR(20) PRIMARY KEY, -- натуральный первичный ключ на основе имэйла
  org_name VARCHAR(128) NOT NULL, -- По умолчанию ограничение NULL, значит возможны значения NULL
  login VARCHAR(20) NOT NULL UNIQUE,
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  address TEXT NOT NULL CHECK(LENGTH(address) > 6 AND address <> address2), -- с кастомным ограничением
  address2 TEXT NOT NULL CONSTRAINT length_more_then_six CHECK(LENGTH(address2) > 6), -- с названием
  raiting FLOAT DEFAULT(0) NOT NULL, -- с указанием значения по умолчанию
  registrated TIMESTAMP DEFAULT(NOW()) NOT NULL,
  deleted BOOL DEFAULT(FALSE) NOT NULL,
  CHECK(LENGTH(org_name) > 3), -- алтернативный способ задать ограничения для любого столбца, просто через запятую после столбцов, можно например сюда переносить все нестандартные или длинные или вообще все ограничения
  CHECK(LENGTH(address) > 6 AND address <> address2 AND LENGTH(address2) > 6 AND LENGTH(org_name) > 3), -- если ограничение пишем отдельно от колонки, то можем объединить все условия на разные столбцы в одно ограничение
  CONSTRAINT unique_name UNIQUE(first_name, last_name),
  PRIMARY KEY(login, email) -- ыариант задания составного первичного ключа по уникальности комбинации полей. Таким полям отдельно стоит задать NOT NULL
);

-- [PostgreSQL]
CREATE TABLE public.publisher -- тоесть таблица publisher создастся в схеме public
(
  publisher_id integer NOT NULL,
  org_name character varying(128) NOT NULL,
  address text NOT NULL,
  CONSTRAINT pk_publisher_id PRIMARY KEY (publisher_id) -- альтернативный синтаксис для задания ограницения(тут PRIMARY KEY) для столбца publisher_id
  -- CONSTRAINT  - создает имя(при обычном способе создания имя дается автоматически) (тут pk_publisher_id - по соглашениям называется как имя столбца с префиксом pk_ для праймари кей) для ограничения (PRIMARY KEY в том числе - это ограничение)
);

-- [PostgreSQL] посмотреть название ограничения для конкретной колоки таблицы из схемы
select constraint_name
from information_schema.key_column_usage
where table_name = 'chair'
  and table_schema = 'public'
  and column_name = 'cathedra_id';


-- [PostgreSQL] SERIAL - данные для колонки с этим типом можно не прописывать при INSERT, они будут генерироваться автоматически(те будет Сурогатный первычный ключ)
CREATE TABLE chair
(
	cathedra_id serial PRIMARY KEY,
	chair_name varchar,
	dean varchar
);



-- FOREIGN KEY (имя_столбца) REFERENCES Имя_таблицы_с_первичным_ключем (id) - создания таблицы с внешним ключом. REFERENCES - значит ссылка. Внешний или вторичный ключ так же является видом ограничений, позволяющие ссылаться(добавлять) только на существующие значения таблицы с PRIMARY KEY к которому он относится и в поле FOREIGN KEY должны быть те же значения того же типа

-- FOREIGN KEY задав соответсвующие айди позволяетсвязать 2 таблицы и удобно делать запросы объединяющие данные из них
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id));
-- внешний ключ company ссылается на первичный ключ id таблицы Companies
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id), FOREIGN KEY (name) REFERENCES People (id)); -- несколько внешних ключей


-- Есть разные правила как обрабатывать удаление и редактирование при использовании внешних ключей
-- Доп опции (?? хз насчет Постгрэ) (?? для полей с FOREIGN KEY) задаваемые при создании таблиц:
ON DELETE RESTRICT -- база данных не даст удалить компанию, у которой в таблице Users есть данные(Cannot delete or update a parent row: a foreign key constraint fails)
ON DELETE CASCADE  -- каскадное удаление, те при удалении компании будут удалены все пользователи, ссылающиеся на эту компанию.
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
  -- publisher(publisher_id) - publisher имя таблицы, publisher_id имя поля в таблице на которое мы ссылаемся
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


-- Через запятую можно добавить несколько ограничений
CREATE TABLE public.book
(
  book_id integer NOT NULL,
  title text NOT NULL,
  isbn character varying(32) NOT NULL,
  publisher_id integer NOT NULL,

	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id),
	CONSTRAINT FK_book_publisher FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);



-- CHECK - логическое ограничение, накладывает условие для значений таблицы
CREATE TABLE public.book
(
  book_id integer NOT NULL,
  title text NOT NULL,
  price decimal NOT NULL,

	CONSTRAINT CHK_book_price CHECK (price > 0) -- тоесть колонку price можно заполнить только значениями больше 0, можно задать любые логические условия, в том числе составные
);


-- Создаем новую таблицу от запроса
CREATE TABLE new_some AS SELECT * FROM some;

CREATE TABLE dishes AS
SELECT id AS restaurant_id, UNNEST(string_to_array(menu, ',')) AS dish FROM restaurants;



--                                            DROP TABLE Удаление таблиц

-- [PostgreSQL, MySQL]
DROP TABLE имя_таблицы;   -- удалить таблицу "Tablename" из данной БД

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



--                                  ALTER TABLE Добавление/изменение/удаление колонок(столбцов)

-- [ PostgreSQL ] Основная команда изменения таблиц:
ALTER TABLE table_name
-- Подкоманды после ALTER TABLE:
ADD COLUMN column_name column_type ograns         -- добавить новую колонку с именем и типом данных и ограничениями
RENAME TO new_table_name                          -- изменить название таблицы
RENAME old_column_name TO new_column_name         -- изменить название столбца на другое
ALTER COLUMN column_name SET DATA TYPE data_type  -- изменить тип данных столбца
DROP COLUMN column_name                           -- удалить столбец
ADD CONSTRAINT constraint_name PRIMARY KEY(chair_id);   -- добавить ограничение на столбец (? CONSTRAINT и его имя  писать не обязательно)
ADD CONSTRAINT fk_books_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id);  -- добавим внешний ключ
DROP CONSTRAINT constraint_name                   -- удалить ограничение просто по его имени
ADD COLUMN price decimal CONSTRAINT CHK_book_price CHECK (price > 0);   -- добавим колонку сразу с констрэйтом
ALTER COLUMN status SET DEFAULT 'r';           -- добавить значение по умолчанию
ALTER COLUMN status DROP DEFAULT;              -- убрать значение по умолчанию

ALTER TABLE tab1 ADD COLUMN col1 INT DEFAULT(0) NOT NULL -- если добавляем колонку с NOT NULL, то нужно добавить и DEFAULT, чтобы колонка могла быть создана, иначе будет ошибка

-- Добавим первичный ключ в колонку exam_id таблицы exam
ALTER TABLE exam
ADD PRIMARY KEY(exam_id);


ALTER TABLE student ADD COLUMN rating float;
ALTER TABLE cathedra RENAME TO chair;
ALTER TABLE chair RENAME cathedra_id TO chair_id;
ALTER TABLE student ALTER COLUMN first_name SET DATA TYPE varchar(64);
ALTER TABLE book ADD CONSTRAINT fk_books_publisher FOREIGN KEY(publisher_id) REFERENCES publisher(publisher_id);

-- [ PostgreSQL ] добавим столбец fk_publisher_id
ALTER TABLE book
ADD COLUMN fk_publisher_id INTEGER;
-- Сделаем этот столбкц внешним ключем к колонке publisher_id таблицы publisher
ALTER TABLE book
ADD CONSTRAINT fk_book_publisher  -- тоесть добавляем ограничение по имени fk_book_publisher ...
FOREIGN KEY(fk_publisher_id) REFERENCES publisher(publisher_id); -- ... которое будет внешним ключем(имя) ссылающимся на колонку publisher_id в таблице publisher

-- DROP COLUMN - удалить столбец из таблицы
ALTER TABLE people DROP COLUMN name;                                       -- из таблицы people удаляем столбец name
ALTER TABLE table_name DROP COLUMN column_name1, DROP COLUMN column_name2; -- несколько столбцов



-- ADD - добавить новое поле(столбец) в таблицу. (? Хз можно ли так сокращенно в Постгрэ)
ALTER TABLE people ADD name VARCHAR(32);                    -- добавляем в таблицу people новый столбец name

-- CHANGE - изменить название, тип данных и доп условие столбца (? Хз можно ли так сокращенно в Постгрэ)
ALTER TABLE people CHANGE name other_name TEXT NOT NULL;    -- изменяем имя и тип данных столбца name
















--
