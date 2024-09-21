--                                     Создание, удаление, изменение таблиц.

-- [ PostgreSQL ] Нэйминг названий колонок и таблиц - снэйк кейс

USE имя_базы_данных;   -- выбрать(ели не выбрана другим образом) базу данных, в которую таблица будет записана.
DESCRIBE TableName;    -- (?? в скюлайт не работает ??)посмотреть типы данных столбцов таблицы



--                                       Ограничения для колонок и таблиц

-- Основные свойства/опции/ограничения для колонок/полей. Записываются после имени столбца и типа данных:


-- 1. PRIMARY KEY / первичный ключ  – это поле, значение которого однозначно определяет запись в таблице. С помощью данного правила СУБД не позволит нам создать новую запись, где id будет неуникальным. Может быть только 1 первичный ключ во всей таблице, но он может быть наложен на несколько полей одновременно(композитный).

-- Сурогатный первычный ключ - это первичный ключ который мы сами назначем, например при помощи serial(пользователь не заполняет значение сам)
-- Натуральный первичный ключ - это первичный ключ который который записывает сам пользователь, например поле login или email может являться первичным ключем тк они обычно задаются уникальными

PRIMARY KEY    -- указывает колонку или несколько колонок одновременно, как первичный ключ. Он всегда уникальный(накладывает ограничение уникальности UNIQUE), этим гарантирует уникальность всей строки. Так же не позволяет всталять в колонку NULL значение, тоесть включает в себя и ограничение NOT NULL.

-- [ PostgreSQL ] Единственная разница между PRIMARY KEY и просто колонкой UNIQUE NOT NULL, в том что в просто колонке нет кластеризованных ключей.


-- 2. FOREIGN KEY (имя_столбца) REFERENCES имя_таблицы_с_первичным_ключем (id) - создания таблицы с внешним ключом.
-- Внешний или вторичный ключ (необязателен, может быть несколько) - то поле в одной таблице, которое ссылается на первичный ключ в другой таблице, позволяет ссылаться(добавлять) только на существующие значения таблицы с PRIMARY KEY к которому он относится и в поле FOREIGN KEY должны быть те же значения того же типа. Позволяет связать 2 таблицы и удобно делать запросы объединяющие данные из них
-- REFERENCES - значит ссылка.
-- Таблица с внешним ключом называется дочерней, а таблица с первичным ключом называется ссылочной или родительской (одна таблица может быть и той и другой одновременно).

-- [ PostgreSQL ??, MySQL + ] Есть разные правила (?? для полей с FOREIGN KEY) как обрабатывать удаление и редактирование при использовании внешних ключей:
ON DELETE RESTRICT -- база данных не даст удалить компанию, у которой в таблице Users есть данные
ON DELETE CASCADE  -- каскадное удаление, те при удалении компании будут удалены все пользователи, ссылающиеся на эту компанию.
ON DELETE SET NULL -- база данных запишет NULL в качестве значения поля company для юзеров, работавших в удалённой компании.
ON UPDATE CASCADE  -- если компания изменит свой идентификатор, то все пользователи (Users) получат новый идентификатор в поле company.


-- 3. Разные ограничения для колонок:
UNIQUE    -- значения в данной колонке для всех записей должны быть отличными друг от друга.
NOT NULL  -- значения в данной колонке должны быть отличными от NULL, тоесть обязательны к заполнению, если будет не заполнено выдаст ошибку. По умолчанию стоит ограничение NULL, тоесть возможность колонке иметь пустые значения
DEFAULT   -- установит значение в колонке по умолчанию, тоесть если при добавлении данных не будет заполнена колонка то добавится значение по умолчанию вместо NULL (данный параметр не применяется к типам BLOB, TEXT, GEOMETRY и JSON).


-- 4. CHECK(expr) [PostgreSQL] - ограничивает значение поля логическим выражением, которое принимет как параметр
CHECK(LENGTH(login) > 6)                   -- дллинна значения для поля login должна быть больше 6
CHECK(LENGTH(login) > 6 AND login <> name) -- составное условие, чтобы логин и имя не совпадали


-- [PostgreSQL] если ограничение пишем в отдельной строке, а не задаем в строке колонки, то:
PRIMARY KEY(login, email)                         -- можно назначить составной первичный ключ по уникальности комбинации полей. Таким полям отдельно стоит задать NOT NULL
CHECK(LENGTH(login) > 6 AND LENGTH(org_name) > 3) -- можем объединить все условия CHECK на разные столбцы в одно ограничение
UNIQUE(first_name, last_name)                     -- можем ограничить на уникальность не по 1му полю, а по 2нескольким сразу, тоесть можно одинаковое имя, если разные фамилии, но нельзя одинаковые и имя и фамилию


-- CONSTRAINT [PostgreSQL] - можно задавать название для ограничения(При обычном способе создания имя дается автоматически), чтобы если оно нарушалось, то при вызове исключения писалось это название и мы понимали точно в чем проблема, особенно удобно для кастомных ограничений CHECK.
CONSTRAINT length_more_then_six CHECK(LENGTH(login) > 6)   -- nе CONSTRAINT потом название, потом ограничение
CONSTRAINT unique_name UNIQUE(first_name, last_name)
CONSTRAINT pk_publisher_id PRIMARY KEY (publisher_id)

-- Посмотреть название ограничения для конкретной колонки таблицы из схемы
SELECT constraint_name
FROM information_schema.key_column_usage
WHERE table_name = 'chair'
  AND table_schema = 'public'
  AND column_name = 'cathedra_id';


-- [ SQLite, MySQL ]
AUTO_INCREMENT -- значение будет автоматически увеличиваться при добавление новых записей. Максимум одна такая колонка. Можно применять только к int и float.



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

CREATE TABLE new_some AS SELECT * FROM some;

CREATE TABLE dishes AS
SELECT id AS restaurant_id, UNNEST(string_to_array(menu, ',')) AS dish FROM restaurants;
















--
