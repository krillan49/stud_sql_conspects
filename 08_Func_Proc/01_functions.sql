--                                             Функции SQL

-- Функция - это объект, сохраняющийся в БД, принимающий аргументы и возвращающий результат

-- Преимущества SQL-функций:
-- Функции (а так же хранимые процедуры) компилируемы и хранятся в БД. Поэтому их вызов стоит дешево.
-- Они дают разграничение работы Frontend-девелопера(используют функции) и Server-side-девелопера(пишут функции)
-- Хранить код, который работает с данными(кортежами), логичнее ближе к этим данным (согласуется с SRP - принципом распределения обязанностей)
-- Переиспользуемость функции разными клиентскими приложениями, тоесть не нужно их создавать множество раз на языке каждого приложения, что подключено к БД
-- Управление безопасностью через регулирование доступа к функциям
-- Уменьшение трафика на сеть
-- Поощряют модульное программирование. Например если нужна генерация какого-то ряда числел в нескольких SQL-запросах

-- Функции неявно упакованы в транзакции



--                                             Функции PostgreSQL

-- Состоят из набора утверждений, возвращают результат последнего

-- Могут содержать запросы: SELECT, INCERT, UPDATE, DELETE (тоесть CRUD-операции)
-- Не могут содержать запросы: COMMIT, SAVEPOINT (TLC), VACUUM (utility), они не нужны, тк функции транзакционны автоматически и секции BEGIN END работают как сэйвпоинты, тоесть все что произошло с ошибкой внутри функции будет автоматически полностью откачено

-- Функции в PostgreSQL делятся на:
-- SQL-функци
-- Процедурные(PL\pgSQL - основной диалект)
-- Серверные функции, написанные на Си
-- Собственные Си-функции












--