--                                          DELETE и TRUNCATE

-- DELETE и TRUNCATE  -  операторы удаления записей из таблицы. Наиболее универсальным и безопасным является DELETE

DELETE FROM имя_таблицы WHERE условие_отбора_записей;
-- Если условие отбора записей WHERE отсутствует, то будут удалены все записи указанной таблицы. Записи удаляются по одной.
-- Оптимизатор запросов СУБД MySQL автоматически использует оператор TRUNCATE, если оператор DELETE не содержит условия WHERE или конструкции LIMIT.
DELETE FROM test WHERE id > 10                     -- удаляем все строки где значение id больше 10


TRUNCATE TABLE имя_таблицы;  -- [PostgreSQL, MySQL]
-- выполнит удаление таблицы и пересоздаст её заново - этот вариант работает гораздо быстрее, чем удаление всех записей одна за другой как в случае с DELETE.
-- Не срабатывают триггеры, в частности, триггер удаления
-- Удаляет все строки в таблице, не записывая при этом удаление отдельных строк данных в журнал транзакций(логи)
-- Сбрасывает счётчик идентификаторов до начального значения
-- Чтобы использовать, необходимы права на изменение таблицы
-- не может удалить данные на которые есть ссылки из других таблиц

-- [PostgreSQL] по умолчанию не сбрасывает айдишники(автоинкремент), тоесть при добавлении новых данных будут начинаться не с 1
TRUNCATE TABLE faculty RESTART IDENTITY; -- а так сбрасывает
TRUNCATE TABLE faculty CONTINUE IDENTITY; -- по умолчанию стоит эта команда(ее прописывать не нужно)



--                               Удаление записей при многотабличных запросах

-- Если в DELETE запросе используется JOIN, то необходимо указать из каких(ой) именно таблиц(ы) требуется удалять записи
DELETE имя_таблицы_1 [, имя_таблицы_2]
FROM имя_таблицы_1 JOIN имя_таблицы_2 ON имя_таблицы_1.поле = имя_таблицы_2.поле [WHERE условие_отбора_записей];

-- Между операторами DELETE и FROM пишем таблицы из которых хотим удалить записи соответсвующие условию
DELETE Res FROM Res JOIN Rooms ON Res.room_id = Rooms.id WHERE Rooms.has_kitchen = false;	        -- удаляем только из таблицы Res
DELETE Res, Rooms FROM Res JOIN Rooms ON Res.room_id = Rooms.id WHERE Rooms.has_kitchen = false;  -- удаляем из 2х таблиц















--
