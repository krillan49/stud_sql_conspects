--                                                 JSON

-- https://www.postgresql.org/docs/current/functions-json.html
-- https://www.sql-ex.ru/blogs/?/Vvedenie_v_rabotu_s_dannymi_JSON_v_PostgreSQL.html

-- Для поддержки типов данных JSON - PostgreSQL реализует модель данных SQL/JSON. Эта модель состоит из последовательностей элементов. Каждый элемент может содержать скалярные значения SQL с дополнительным значением SQL/JSON null и составные структуры данных, которые используют массивы и объекты JSON.

-- SQL/JSON позволяет обрабатывать данные JSON с поддержкой транзакций, включая:
-- 1. Загрузка данных JSON в базу данных и сохранение их в обычных столбцах SQL в виде символьных или двоичных строк.
-- 2. Генерация объектов и массивов JSON из реляционных данных.
-- 3. Запрос данных JSON с использованием функций запросов SQL/JSON и выражений языка путей SQL/JSON.



--                                        Встроенные функции JSON

-- jsonb_array_length - функция возвращает длинну массива jsonb
SELECT jsonb_array_length(product) AS arr_len FROM sales; -- вернет длинну массива json product



--                                          Извлечение данных

-- Операторы извлечения поля/элемента/пути не приводят к ошибке, если входные данные JSON не имеют правильной структуры (например, если такого ключа или элемента массива не существует), а возвращают NULL;

-- Получить данные из столбцов JSON можно по индексу или по имени ключа. Они применимы как к столбцам json, так и к jsonb:


-- 1. Извлечение по имени ключа (если на этом уровне таблица):
-- ->    - оператор, извлекает значение как JSON (json, если поле имеет тип json, и jsonb, если поле имеет тип jsonb)
-- ->>   - оператор получает значение в виде текста
SELECT product -> 'color' AS color FROM sales;
-- product  - имя колонки
-- 'color'  - имя ключа-JSON, значение которого мы хотим извлечь в колонке запроса color
SELECT product ->> 'color' AS color FROM sales;
-- Если ключ существует не для всех записей, строки с отсутствующим ключом имеют значение NULL


-- 2. Извлеченик по индексу. (если на этом уровне массив). Поле массива можно извлечь в виде jsonb, используя оператор ->, или как текст с помощью оператора ->>:
SELECT nums -> 0 AS n FROM sales;
-- nums - имя колонки с JSON-массивом
-- 0    - индекс элемента массива, который хотим извлечь
SELECT nums ->> 0 AS n FROM sales;


-- 3. Комплексное извлечение. Eсть поле массива в поле JSON, которое называется size. Оно содержит от 0 до 2 значений.
SELECT
	product,                                          -- вернет весь JSON
	product -> 'size' AS size_json,                   -- извлечет элемент(тут массив) по ключу в виде jsonb
	product ->> 'size' AS size_txt,                   -- извлечет элемент(тут массив) по ключу в виде текста
	jsonb_array_length(product -> 'size') AS arr_len, -- вернет длинну массива json
	(product -> 'size') ->> 0 AS first_el,            -- вернет элемент с индесом 0 вложенного массива из JSON под ключем 'size'
	((product -> 'size') ->> 1) :: FLOAT AS second_el -- вернет элемент вложнного массива с последуюзим перемодом во float
FROM sales

-- Пример с использованием в CASE
SELECT
  data ->> 'first_name' AS first_name,
  data ->> 'last_name' AS last_name,
  SPLIT_PART(AGE(CURRENT_TIMESTAMP, (data ->> 'date_of_birth')::TIMESTAMP)::TEXT, ' ', 1)::INT AS age,
  CASE
    WHEN (data ->> 'private')::BOOL = TRUE THEN 'Hidden'
    WHEN ((data -> 'email_addresses') ->> 0) IS NULL THEN 'None'
    ELSE (data -> 'email_addresses') ->> 0
  END AS email_address
FROM users
ORDER BY first_name, last_name;















--
