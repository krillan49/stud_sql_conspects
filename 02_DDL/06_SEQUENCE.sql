--                                   [ PostgreSQL ]  SEQUENCE / Последовательности

-- Последовательность - это объект в БД

-- Последовательности можно как генерировать, например для автоинкремента, при помощи псевдотипа данных SERIAL или синтаксиса GENERATED [ALWAYS / BY DEFAULT] AS IDENTITY, так и работать с ними явным образом, тоесть создавать, изменять и удалять отдельно



--                                          Создание последовательности

-- Создаем последовательность
CREATE SEQUENCE seq;               -- seq - название последовательности
CREATE SEQUENCE IF NOT EXISTS seq; -- тк последовательность это объект то лучше использовать IF NOT EXISTS

-- Создание последовательности с указанием ее параметров при помощи дополнительных опций, без этих опций их значения будут заданы по умолчанию:
CREATE SEQUENCE IF NOT EXISTS seq3
INCREMENT 16 -- значение на которое будет увеличиваться последовательность при генерации следующего значения. По умолчанию равно 1
MINVALUE 0   -- минимальное значение последовательности, например если последовательность убывает.
MAXVALUE 128 -- максимальное значение. Eсли будет превышено выдаст ошибку
START WITH 0 -- начальное значение последовательности, с которого начнется генерация. По умолчанию равно 1
OWNED BY book.book_id; -- назначить последовательность на поле какой-то таблицы, если нужно



--                                     Функкции для работы с последовательностями

-- nextval - функция генерирует следующее значение в последовательности, принимает аргументом название последовательности в виде строки, для которой и сгенерирует значение
SELECT nextval('seq');

-- currval - функция возвращает текущее значение, принимает имя последовательности
SELECT currval('seq');

-- lastval - функция возвращает последнее значение, сгенерированное последней среди всех последовательностей в текущей сессии, не принимает аргументы
SELECT lastval();

-- setval - функция устанавливающая текущее или следующее сгенерированное значение, принимает имя последовательности, значение которое хотим установить и true(значение по умолчанию, можно не писать, установит текущее значение) или false(установит значение 2го аргумента в следующее сгенерированное значение)
SELECT setval('seq', 10, true);



--                                           Изменение последовательностей

-- ALTER SEQUENCE - оператор для изменения последовательности, к нему применяются дополнительные ключевые слова, задающие как именно меняем последовательность:

-- 1. RENAME TO - переименовать последовательность
ALTER SEQUENCE seq3 RENAME TO seq4; -- переименует последовательность seq3 в seq4

-- 2. RESTART WITH - сбросить/откатить последовательность до указанного значения
ALTER SEQUENCE seq4 RESTART WITH 16 -- сбросит последовательность до значения 16
SELECT nextval('seq4');



--                                           Удаление последовательностей

-- DROP SEQUENCE - оператор для удаления последовательности
DROP SEQUENCE seq4;



--                             GENERATED AS IDENTITY. Последовательности для автоинкремента

-- GENERATED [ALWAYS / BY DEFAULT] AS IDENTITY - продвинутый/актуальный способ создания поля с автоинкрементом. Базируется на SEQUENCE. С 10й версии PostgreSQL рекомендуется использовать этот синтаксис.

-- Избегает множества ошибок, возникающих при использовании синтаксиса с псевдотипом SERIAL.
-- В отличие от SERIAL, при использовании ALTER TABLE нам не нужно знать имя последовательности, например чтобы сбросить последовательность, можем обращаться просто к имени колонки
-- Так же есть преимущества при работе с доступом

-- Дополнительные параметры:
-- ALWAYS     - запрещает по умолчанию явную вставку значения в поле с автоинкрементом, оставляя возможность этой вставки только при использовании при вставке дополнительного параметра OVERRIDING SYSTEM VALUE в операторе INSERT INTO
-- BY DEFAULT - разрешает по умолчанию явную вставку значения в поле с автоинкрементом


-- Поле с автоинкрементом создается с обычным INT типом данных и синтаксисом GENERATED [ALWAYS / BY DEFAULT] AS IDENTITY
CREATE TABLE public.book(
  book_id INT GENERATED ALWAYS AS IDENTITY NOT NULL, -- ALWAYS - запретим вставлять значения явно, по умолчанию
  title TEXT NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);
-- Теперь можем вставлять значения и в поле book_id и автоинкремент будет работать
INSERT INTO book (title) VALUES ('title'), ('title2'), ('title3');

-- Если кто-то захочет вставить значение поля с автоинкрементом явно, то СУБД выдаст ошибку:
INSERT INTO book VALUES (4, 'title4'); -- тут возникнет ошибка
-- Но можно разрешить вставку значений, только прописав дополнительный синтаксис OVERRIDING SYSTEM VALUE
INSERT INTO book OVERRIDING SYSTEM VALUE VALUES (4, 'title4');


-- При использовании GENERATED AS IDENTITY можно добавлять дополнительные опции для SEQUENCE прямо в строке создания поля:
CREATE TABLE public.book(
  book_id INT GENERATED ALWAYS AS IDENTITY (START WITH 10 INCREMENT BY 16) NOT NULL,
  title TEXT NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);



--                                     SERIAL. Последовательности для автоинкремента

-- (! SERIAL - этот псевдотип данных устарел, им стоит пользоваться только на версиях PostgreSQL ниже 10й)

-- В PostgreSQL для автономной инкрементации первичного ключа используются типы данных SERIAL или BIGSERIAL. Они автоматически создают числовую последовательность (SEQUENCE), которую будут инкрементировать

-- Тип данных INT по умолчанию не обладает свойствами автоинкремента, поэтому можно использовать вместо него псевдотип SERIAL, который использует под капотом SEQUENCE
CREATE TABLE public.book(
  book_id SERIAL NOT NULL,   -- указываем SERIAL вместо типа данных
  title TEXT NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);
-- Теперь значения book_id будут автоматически увеличиваться при вставке новых строк



--                                      Явное исполнение подкапотного кода SERIAL

-- Создаем таблицу с обычным INT полем для первичного ключа
CREATE TABLE public.book(
  book_id INT NOT NULL,
  title TEXT NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);

-- Создаем последовательность и назначаем ее при помощи OWNED BY к необходимому полю в нашу таблицу
CREATE SEQUENCE IF NOT EXISTS book_book_id_seq
START WITH 1
OWNED BY book.book_id;

-- Далее нужно значением по умолчанию в необходимую колонку присвоить функцию последовательности nextval от созданной выше последовательности, чтобы она генерировала следующее значение в каждой строке при вставке
ALTER TABLE book
ALTER COLUMN book_id SET DEFAULT nextval('book_book_id_seq');

-- Теперь при вставке новых строк в поле book_id будут генерироваться значения при помощи nextval
INSERT INTO book (title) VALUES ('title'), ('title2'), ('title3');



--                                           Проблемы и ошибки с SERIAL

-- Ошибка с ручным заполнением PRIMARY KEY/UNIQUE поля:
-- При использовании SERIAL остается возможность заполнить поле под ним вручную:
INSERT INTO book VALUES (4, 'title4');
-- При этом значение 4 просто вставится без использования функции nextval, соответственно значение последовательности не изменится и при следующей вставке уже так
INSERT INTO book VALUES ('title5'); -- возникнет ошибка, тк nextval выдает 4, а оно уже есть и у этой колонки есть ограничение на уникальность значений
















--
