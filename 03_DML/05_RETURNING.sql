--                                              RETURNING

-- RETURNING - позволяет вернуть данные по модифицированной строке в результате UPDATE или DELETE или INSERT, в его параметры можно прописать все тоже что и между полями SELECT и FROM селект запроса ?

-- Таблица использующаяся в примерах ниже:
CREATE TABLE book(
	book_id SERIAL,
	title TEXT NOT NULL,
	isbn VARCHAR(32) NOT NULL,
	publisher_id INT NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);

-- INSERT. Вернет всю строку вместе со сгенерированным book_id как будто это результат селект-запроса
INSERT INTO book(title, isbn, publisher_id)
VALUES ('title', 'isbn', 3)
RETURNING *;

-- UPDATE. Вернем айди измененной строки
UPDATE author
SET full_name = 'Walter', rating = 5
WHERE author_id = 1
RETURNING author_id;

-- DELETE. Особенно актуально посмотреть при удалении что именно удалилось
DELETE FROM author
WHERE rating = 5
RETURNING *;

















--
