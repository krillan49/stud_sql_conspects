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



--                                        CREATE TABLE Создание таблиц

USE имя_базы_данных;   -- выбрать(ели не выбрана другим образом) базу данных, в которую таблица будет записана.


-- Основные свойства(опции) колонок:
PRIMARY KEY    -- указывает колонку/колоноки как первичный ключ. Он всегда уникальный, этим гарантирует уникальность всей строки. Тоесть накладывает ограничение уникальности UNIQUE. Так же не позволяет всталять в колонку NULL значение, тоесть включает в себя и ограничение NOT NULL. Может быть только 1 такая колонка во всей таблице, для Постргэ это единственная разница между ним и просто колонкой UNIQUE NOT NULL, тк в ней нет кластеризованных ключей
AUTO_INCREMENT -- (? хз насчет Постгрэ, тк там есть тип данных сериал) значение будет автоматически увеличиваться при добавление новых записей. Максимум одна такая колонка. Можно применять только к int и float.
UNIQUE         -- ограничение - значения в данной колонке для всех записей должны быть отличными друг от друга.
NOT NULL       -- ограничение - значения в данной колонке должны быть отличными от NULL, тоесть обязательны к заполнению, если будет не заполнено выдаст ошибку
DEFAULT        -- значение в колонке по умолчанию, тоесть если при добавлении данных не будет заполнена колонка то добавится значение по умолчанию вместо NULL (данный параметр не применяется к типам BLOB, TEXT, GEOMETRY и JSON).


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
  -- CONSTRAINT  - создает имя(при обычном способе создания имя дается автоматически) (тут pk_publisher_id - по соглашениям называется как имя столбца с префиксом pk_ для праймари кей) для ограничения (PRIMARY KEY в том числе - это ограничение)
);

-- [PostgreSQL] посмотреть название ограничения для конкретной колоки таблицы из схемы
select constraint_name
from information_schema.key_column_usage
where table_name = 'chair'
  and table_schema = 'public'
  and column_name = 'cathedra_id';


-- [PostgreSQL] SERIAL - данные для колонки с этим типом можно не прописывать при INSERT, они будут генерироваться автоматически
CREATE TABLE chair
(
	cathedra_id serial PRIMARY KEY,
	chair_name varchar,
	dean varchar
);



-- FOREIGN KEY (имя_столбца) REFERENCES Имя_таблицы_с_первичным_ключем (id) - создания таблицы с внешним ключом. REFERENCES - значит ссылка. Внешний ключ так же является видом ограничений, позволяющие ссылаться(добавлять) только на существующие значения таблицы с PRIMARY KEY к которому он относится
-- FOREIGN KEY задав соответсвующие айди позволяетсвязать 2 таблицы и удобно делать запросы объединяющие данные из них
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id));
-- внешний ключ company ссылается на первичный ключ id таблицы Companies
CREATE TABLE Users (id INT, name TEXT, age INT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id), FOREIGN KEY (name) REFERENCES People (id)); -- несколько внешних ключей


-- Доп опции (?? хз насчет Постгрэ) (?? для полей с FOREIGN KEY) задаваемые при создании таблиц:
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
ADD COLUMN column_name data_type                  -- добавить новую колонку с именем и типом данных
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
