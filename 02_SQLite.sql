--                                              SQLite

-- SQLite — это библиотека на языке C, которая реализует небольшой, автономный, полнофункциональный механизм базы данных SQL.

-- Скачивание и установка:
-- https://sqlite.org/index.html  ->  Download  ->  Precompiled Binaries for Windows  ->  https://www.youtube.com/watch?v=ZSOyqH3loss  https://lumpics.ru/how-install-sqlite-on-windows-10/


-- > sqlite3 --version   -  проверить версию
-- > sqlite3             -  войти в программу (в оболочку/shell программы) (выход Ctrl+C или прописать .exit)


-- gem install sqlite3   -  библиотека для Руби


-- в sqlite VARCHAR==TEXT потому лучше использовать TEXT



-- 	                                      Работа с SQLite через терминал

-- > sqlite3 db_name.расширение (например testDB.sqlite)   - войти в рабочую текстовую консольную оболочку SQLite конкретной БД, находясь в директории с этой БД
-- > sqlite3 ./DB/leprosorium.db  - войти с указанием доп пути из другой директории

-- Команды внутри консоли sqlite3:
-- > .tables                                  - вывести список таблиц которые существуют вданной базе данных
-- > .mode column                             - изменяет визуальный стиль вывода таблицы на такой чтоб колонки были ровными
-- > .headers on                              - Включить заголовки(похоже включена автоматически и так в .mode column)
-- > .exit                                    - выйти из базы данных

-- > pragma table_info(articles);   -  Посмотреть, какие стобцы и их типы и прочее существуют в таблице articles (ток хз это скуэль запрос или командп консоли скюлайт)

-- Чтобы в командной строке sqlite3 каждый раз не прописывать команды, создайте в домашней директории файл .sqliterc с содержимым:
-- .headers on
-- .mode column

-- Запрсы внутри консоли sqlite3:
CREATE TABLE "Some" ("Id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" VARCHAR, "Price" INTEGER);  -- запрс создания новой таблицы в данной базе данных (среда позволяет писать запросы в несколько строк, соотв в конце запроса(именно запроса не команды) точка с запятой, иначе на другую строку переходит ввод запроса, можно поставить и на новой строке)
SELECT * FROM Cars;                                  -- пример запроса SELECT, получаем вывод таблицы или ее элементов в консоли
INSERT INTO Cars (Name, Price) VALUES ('Foo', 6743); -- пример запроса INSERT, добавим новую строку в таблицу



-- 	                                               sqlitebrowser

-- https://sqlitebrowser.org/dl/  инструмент-браузер для SQLite

-- Создание БД и таблиц в sqlitebrowser:
-- новая база данных -> выбираем директорию имя фаила и расширение -> фаил базы данной создан -> в появившемся окне создаем таблицу, добавляя имя таблицы и столбцы с параметрами -> внизу создание отобразится в синтаксисе кодом нашей таблицы
CREATE TABLE "Cars" ("Id" INTEGER PRIMARY KEY AUTOINCREMENT, "Name" VARCHAR, "Price" INTEGER) -- запрос к базе данных на создание таблицы
-- теперь таблица создана в этой базе данных и появится в основном окне в списке таблиц
-- во вкладки SQL основного окна можно делать запросы (наполнять или выводить чтото из таблицы)
-- таблицу можно посмотреть во вкладке "Данные"













--
