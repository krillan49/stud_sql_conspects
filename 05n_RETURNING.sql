--                                                 RETURNING

-- RETURNING - позволяет вернуть данные по модифицированной строке в результате UPDATE или DELETE или INSERT

CREATE TABLE book(
	book_id serial,
	title text NOT NULL,
	isbn varchar(32) NOT NULL,
	publisher_id int NOT NULL,
	CONSTRAINT PK_book_book_id PRIMARY KEY(book_id)
);

-- вернет Всю строку вместе со сгенерированным book_id как результат селект запроса
INSERT INTO book(title, isbn, publisher_id)
VALUES ('title', 'isbn', 3)
RETURNING *;

-- При апдэйте вернем айди измененной строки
UPDATE author
SET full_name = 'Walter', rating = 5
WHERE author_id = 1
RETURNING author_id;

-- При удалении особенно актуально посмотреть что удалилось
DELETE FROM author
WHERE rating = 5
RETURNING *;











--
