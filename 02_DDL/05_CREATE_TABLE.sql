--                                         CREATE TABLE Создание таблиц

-- https://www.postgresql.org/docs/current/sql-createtable.html


-- Варианты создания таблиц для любых СУБД:
CREATE TABLE "Some" ("id" INTEGER PRIMARY KEY, "Name" TEXT, "Price" INTEGER);                    -- кавычки не обязательны
CREATE TABLE IF NOT EXISTS "Some" ("id" INTEGER PRIMARY KEY , "Name" TEXT, "Price" INTEGER);     -- создания новой таблицы, если такой еще не существует (избавляет от ошибки если существует)
CREATE TABLE users (id INT, name VARCHAR(255), age INT, PRIMARY KEY (id));                       -- PRIMARY KEY отдельно в конце
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(255) NOT NULL, age INT NOT NULL DEFAULT 18) -- age - поле числового типа со значением по умолчанию равным 18


-- [ SQLite, MySQL ] Создание таблицы с AUTOINCREMENT. Кавычки не обязательны
CREATE TABLE "Some" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" TEXT, "Price" INTEGER);


-- [ MySQL ] FOREIGN KEY
CREATE TABLE Users (id INT, name TEXT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id)); -- внешний ключ company ссылается на первичный ключ id таблицы Companies
CREATE TABLE Users (id INT, name TEXT, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id), FOREIGN KEY (name) REFERENCES People (id)); -- несколько внешних ключей
CREATE TABLE Users (id INT, name VARCHAR(255) NOT NULL, age INT NOT NULL DEFAULT 18, company INT, PRIMARY KEY (id), FOREIGN KEY (company) REFERENCES Companies (id) ON DELETE RESTRICT ON UPDATE CASCADE);


-- [PostgreSQL] Пример создания таблицы с набором ограничений
CREATE TABLE publisher
(
  -- Задаем все поля, их типы данных и ограничения которые будут в таблице publisher
  email VARCHAR(20) PRIMARY KEY,                   -- натуральный первичный ключ на основе имэйла
  deleted BOOL DEFAULT(FALSE) NOT NULL,            -- с указанием значения по умолчанию
  registrated TIMESTAMP DEFAULT(NOW()) NOT NULL,
  login VARCHAR(20) NOT NULL UNIQUE,               -- с ограничением на уникальность
  address TEXT NOT NULL CHECK(LENGTH(address) > 6 AND address <> address2),           -- с кастомным ограничением
  address2 TEXT NOT NULL CONSTRAINT length_more_then_six CHECK(LENGTH(address2) > 6), -- ограничение с названием
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  -- Альтернативный способ задать ограничения для любого столбца, просто через запятую после столбцов, можно например сюда переносить все нестандартные или длинные или вообще все ограничения. Так можно удобно объединить все условия на разные столбцы в одно ограничение:
  CHECK(LENGTH(address) > 6 AND address <> address2 AND LENGTH(address2) > 6 AND LENGTH(org_name) > 3),
  CONSTRAINT unique_name UNIQUE(first_name, last_name),
  PRIMARY KEY(login, email) -- первичный ключ по уникальности комбинации полей. Таким полям отдельно стоит задать NOT NULL
);


-- [PostgreSQL] Создание таблицы в конкретной схеме
CREATE TABLE public.publisher -- тоесть таблица publisher создастся в схеме public
(
  publisher_id integer NOT NULL,
  org_name character varying(128) NOT NULL,
  address text NOT NULL,
  CONSTRAINT pk_publisher_id PRIMARY KEY (publisher_id) -- создадим имя для первичного ключа (тут pk_publisher_id - по соглашениям называется как имя столбца с префиксом pk_ для праймари кей)
);


-- [PostgreSQL] FOREIGN KEY Добавим внешний ключ
CREATE TABLE public.book
(
  book_id integer NOT NULL,
  title text NOT NULL,
  publisher_id integer NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id),
	CONSTRAINT FK_book_publisher FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

-- [PostgreSQL] FOREIGN KEY (отношение 1 ко многим) Cоздадим таблицу с внешним ключем fk_publisher_id ссылающимся на publisher_id таблицы publisher
CREATE TABLE book (
	book_id integer PRIMARY KEY,
	title text NOT NULL,
	isbn varchar(32) NOT NULL,
	fk_publisher_id INTEGER REFERENCES publisher(publisher_id) NOT NULL -- В PostgreSQL тут при создании таблтцы не обязвтельно писать FOREIGN KEY, достаточно REFERENCES
  -- publisher(publisher_id) - publisher имя таблицы, publisher_id имя поля в таблице на которое мы ссылаемся
);

-- [PostgreSQL] FOREIGN KEY (отношение 1 к 1) создадим таблицу person и с уникальным внешним ключем passport
CREATE TABLE person ( person_id int PRIMARY KEY, first_name varchar(64) NOT NULL, last_name varchar(64) NOT NULL );
CREATE TABLE passport (
	passport_id int PRIMARY KEY,
	serial_number int NOT NULL,
	fk_passport_person int UNIQUE REFERENCES person(person_id) -- внешний ключ уникален тк отношение 1 к 1
);

-- [PostgreSQL] (отношение многие ко многим)
CREATE TABLE book ( book_id integer PRIMARY KEY, title text NOT NULL, isbn varchar(32) NOT NULL, );
CREATE TABLE author ( author_id integer PRIMARY KEY, full_name text NOT NULL, rating real );
CREATE TABLE book_author (
  -- Создадим вторичные ключи для к 2м таблицам:
	book_id integer REFERENCES book(book_id),
	author_id integer REFERENCES author(author_id),
  -- Cоздаем "composite key" - композитный первичный ключ по 2м(или более) колонкам, тк только пара ключей уникальна, а каждый в отдельности может повторяться:
  CONSTRAINT book_author_pkey PRIMARY KEY (book_id, author_id)
);
-- Далее добавляем значения для каждой из таблиц



--                                     Создание новой таблицы от SELECT-запроса

CREATE TABLE new_some AS
SELECT * FROM some;

CREATE TABLE dishes AS
SELECT id AS restaurant_id, UNNEST(string_to_array(menu, ',')) AS dish FROM restaurants;
















--
