--                                   Нормальные формы и нормализация БД

-- Нормальная форма (НФ) - свойство отношения/таблицы, характеризующее его с точки зрения избыточности данных

-- Нормализация / приведение к нормальной форме - процесс минимизации избыточности данных отношения/таблицы. Нормализация помогает устранить дублирующиеся данные в таблице, данные в таблицах начинают описывать более логически конкретные данные, а не кашу из разношерстных. Сокращение дублированных данных означает меньшую вероятность несоответствий и большую гибкость.

-- Нормальные формы — это этапы, между которыми из таблицы удаляются различные формы избыточности данных. Для того чтобы высшая нормальная форма была удовлетворена, нужно чтобы все низшие нормальные формы также были удовлетворены.

-- Нормальные формы именуются как: 1НФ(1NF), 2NF, 3NF, 4NF, 5NF, 6NF

-- 3NF - общепринятая и наиболее распространенная форма нормализации в индустрии, дальше нее в подаляющем большинстве случаев нормализацию не проводят, тк тратить слищком много времени на нормализацию БД нерационально, за это время бизнес уже может что-то изменить и придется много раз все переделывать

-- Основным способом удовлетворения требований нормальных форм является декомпозиция, тоесть рабитие одной большой таблицы на несколько маленьких и более однозначных таблиц



--                                        Денормализация данных

-- Денормализация данных - процесс обратный нормализации. Приведение структуры БД в состояние не соответсвующее, критериям нормализации.

-- Помогает избегать лишних Джоинов, тоесть Селекты могут проходить быстрее, но будет требоваться больше места для избыточных данных

-- Необходимость денормализации уже можно понять только в процессе использования БД, а сначала лучше данные нормализовать до 3NF



--                                     1NF - первая нормальная форма

-- Строки не упорядочены, тк нет первичного ключа, может быть условная нумерация строк, но данные можно удалять, менять итд, давая эти номера произвольно, соответсвенно от этих номеров ничего не зависит или вовсе можно не иметь нумерации
-- Столбцы не упорядочены, тоесть не важно какой столбец в таблице в каком порядке относительно других столбцов, соответсвено можно их менять местами как угодно и данные будут зависить только от названия колонки, но не от ее номера

-- Приведение к первой нормальной форме (1NF):
-- 1. В таблице не должно быть записей(строк)-дубликатов, тоесть нескольких строк с одинаковыми значениями во всех колонках
-- 2. Все значения должны быть скалярными(одно значение), те каждый столбец в таблице должен быть атомарным, те он не может содержать набор значений. Соответсвенно все атрибуты должны быть простых типов данных
-- 3. Все столбцы являются обычными - тоесть содержит только значение которое надо получить, чтобы какие-то одельные ячейки не содержали например функции, хранимые процедуры, ссылки итл. Тоесть данные в каждой колонке должны быть 1го типа не только по собствеено типу, но и по способу их использования

-- Например таблица, авторов и книг, в ней хоть и нет строк дубликатов, но в колонке books не простой тип данных а массив, и значения не скалярные, тк массив содержит разные книги во 2й строке:

-- author_name     |     book_title
--------------------------------------
-- Толстой         |     Анна Каренина
-- Достоевский     |     Игрок, Идиот

-- Разобьем данные на отдельные записи не только по авторам, но и по книгам:

-- author_name     |     book_title
---------------------------------------
-- Толстой         |     Анна Каренина
-- Достоевский     |     Игрок
-- Достоевский     |     Идиот

-- Теперь в таблице нет дубликатов и все типы данных простые и значения скалярные, тоесть мы привели таблицу к 1НФ



--                                     2NF - вторая нормальная форма

-- Приведение ко второй нормальной форме (2NF):
-- 1. Таблица удовлетворяет 1НФ
-- 2. Должен быть первичный ключ, тоесть строки должны быть упорядочены однозначно
-- 3. Если имеем составной первичный ключ, то все атрибуты/поля дожны неприводимо от него зависеть, тоесть все поля должны описывать первичный ключ целиком, а не какую-то одельную составляющую его часть. Например если есть натуральный составной ключ из нескольких полей имя, фамилия, отчество, день рождения - то не должно быть в этой же таблице данных зависящих только от года рождения или только от фамилии.

-- В таблице выше мы не можем определить первичный ключ ни по колонке author_name, ни по book_title, тк значения в них могут повторяться
-- Кодда ни одна колонка не может стать первичным ключем, то мы можем завести композитный/составной ключ по 2м колонкам(2 ключа), тоесть в совокупности эти 2 ключа будут представлять строки уникальными

-- author_name     |     book_title     |   author_id     |     book_id
-----------------------------------------------------------------------
-- Толстой         |     Анна Каренина  |   1             |     1
-- Достоевский     |     Игрок          |   2             |     2
-- Достоевский     |     Идиот          |   2             |     3

-- Но это не удовоетворяет 3му пункту, тк поле author_name описывает только часть ключа, а именно author_id, а поле book_title описывает лишь часть ключа, а именно book_id

-- Таблица для примера по лучше:

-- author_id    |      book_id  |  author_name     |     book_title     |    publisher_title  |  publisher_contact
--------------------------------------------------------------------------------------------------------------
-- 1            |      1        |  Толстой         |     Анна Каренина  |    Альпина          |  87987787
-- 2            |      2        |  Достоевский     |     Игрок          |    Альпина          |  87987787
-- 2            |      3        |  Достоевский     |     Идиот          |    Питер            |  90909090

-- Для удовлетворения 3го требования 2НФ мы можем разбить эту таблицу на 3 таблицы связанные через внешний ключ. Вынесем информацию об авторах в одну таюлицу, о книгах в другую таблицу и составной ключ в отдельную 3ю таблицу, тоесть реализуем отношение многие ко многим:

-- author_id  | author_name
---------------------------
-- 1          | Толстой
-- 2          | Достоевский

-- book_id  |  book_title      |   publisher_title  |  publisher_contact
-----------------------------------------------------------------------
-- 1        |  Анна Каренина   |   Альпина          |  87987787
-- 2        |  Игрок           |   Альпина          |  87987787
-- 3        |  Идиот           |   Питер            |  90909090

-- author_id     |     book_id
-------------------------------
-- 1             |     1
-- 2             |     2
-- 2             |     3

-- Теперь все атрибуты таблиц авторов и книг описывают свой первичный ключ целиком



--                                     3NF - третья нормальная форма

-- Общепринятая и наиболее распространенная форма нормализации в индустрии

-- Приведение к третей нормальной форме (3NF):
-- 1. Таблица удовлетворяет 2НФ
-- 2. Не должно быть зависимостей одних неключевых атрибутов от других (все атрибуты зависят только от первичного ключа). Те ни одна колонка не должна иметь возможность быть выведенной(полученной) при помощи данных другой колонки. Те в таблице должны быть только данные, что зависят только от ключа и не от чего кроме него.

-- В таблице книг колонка publisher_contact зависит от publisher_title и может быть выведена от него

-- book_id  |  book_title      |   publisher_title  |  publisher_contact
----------------------------------------------------------------------
-- 1        |  Анна Каренина   |   Альпина          |  87987787
-- 2        |  Игрок           |   Альпина          |  87987787
-- 3        |  Идиот           |   Питер            |  90909090

-- Удовлетворим 2е требование при помощи декомпозиции создав еще одну таблицу, а в 1ю добавим вторичный ключ к ней. Тоесть реализуем 1 ко многим(либо 1 к одному для каких-то других примеров):

-- book_id  |  book_title      |   publisher_id
----------------------------------------------
-- 1        |  Анна Каренина   |   1
-- 2        |  Игрок           |   1
-- 3        |  Идиот           |   2

-- publisher_id     |    publisher_title  |  publisher_contact
--------------------------------------------------------------
-- 1                |    Альпина          |  87987787
-- 2                |    Питер            |  90909090

-- Теперь в обеих таблицах неключевые атрибуты зависят только от первичного ключа



--                                                    BCNF

-- BCNF (Boyce-Codd Normal Form) - более строгий(усиленный) вариант 3NF. Если есть 2 потенциальных ключа, то не должно быть зависимостей между частями этих ключей














--
