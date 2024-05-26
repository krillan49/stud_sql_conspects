--                                    PREPARE [PostgreSQL]. Параметризация запросов

-- https://www.postgresql.org/docs/current/sql-prepare.html      PREPARE
-- https://www.postgresql.org/docs/current/sql-execute.html      EXECUTE


-- Подготовленный оператор — это объект на стороне сервера, который можно использовать для оптимизации производительности. Позволяет избежать повторяющейся работы по синтаксическому анализу и написанию SQL операторов
-- Подготовленные операторы выгодны в производительности, когда один сеанс используется для выполнения большого количества похожих операторов, особенно если операторы сложны для написания, например, если запрос включает в себя соединение многих таблиц. Если оператор прост в написании, но дорог в исполнении, буст производительности будет менее заметным.

-- PREPARE - создает подготовленный оператор. Когда PREPARE оператор выполняется, исполняемый оператор парсится, анализируется и перезаписывается
-- EXECUTE - команда для выполнения подготовленного оператора.

-- Подготовленные операторы могут принимать параметры, они подставляются в оператор при его выполнении. При создании подготовленного оператора обращайтесь к параметрам по их позиции $1, $2 итд. Можно указать список типов данных параметров. Если тип данных параметра не указан или объявлен как unknown, тип выводится из контекста, в котором параметр впервые упоминается (если это возможно). При выполнении оператора нужно указать в операторе значения этих параметров. Если PREPARE в операторе, создавшем оператор, указаны некоторые параметры, в оператор должен быть передан совместимый набор параметров EXECUTE, иначе возникнет ошибка.

-- имя подготовленного оператора должно быть уникальным в пределах сеанса базы данных

-- Подготовленные операторы действуют только в течение текущего сеанса базы данных. Когда сеанс завершается, подготовленный оператор забывается

-- Подготовленные операторы можно очистить вручную с помощью DEALLOCATE команды.



-- Создаем подготовленный оператор для INSERT оператора:
PREPARE fooplan (INT, TEXT, BOOL, NUMERIC) AS -- fooplan - имя подготовленного оператора, можно любое. Типы данных соотв параметрам
  INSERT INTO foo VALUES($1, $2, $3, $4);  -- оператор в который подставим данные и будем выполнять при вызове подготовленного
EXECUTE fooplan(1, 'Hunter Valley', 't', 200.00); -- выполняем подготовленный оператор, параметры будут переданы в $1, $2, $3, $4 в соотвествии с порядком написания


-- Создаем подготовленный оператор для SELECT оператора:
PREPARE usrrptplan (INT) AS  -- тк тут тип данных 2го параметра не указан, то он возьмется из контекста, в котором используется $2
  SELECT * FROM users u, logs l WHERE u.usrid = $1 AND u.usrid = l.usrid AND l.date = $2;
EXECUTE usrrptplan(1, current_date); -- выполняем подготовленный оператор













--
