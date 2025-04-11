--                                                 JSON

-- https://www.postgresql.org/docs/current/functions-json.html
-- https://www.sql-ex.ru/blogs/?/Vvedenie_v_rabotu_s_dannymi_JSON_v_PostgreSQL.html

-- Для поддержки типов данных JSON - PostgreSQL реализует модель данных SQL/JSON. Эта модель состоит из последовательностей элементов. Каждый элемент может содержать скалярные значения SQL с дополнительным значением SQL/JSON null и составные структуры данных, которые используют массивы и объекты JSON.

-- SQL/JSON позволяет обрабатывать данные JSON с поддержкой транзакций, включая:
-- 1. Загрузка данных JSON в базу данных и сохранение их в обычных столбцах SQL в виде символьных или двоичных строк.
-- 2. Генерация объектов и массивов JSON из реляционных данных.
-- 3. Запрос данных JSON с использованием функций запросов SQL/JSON и выражений языка путей SQL/JSON.



--                                      Информационные функции JSON

-- jsonb_array_length - функция возвращает длинну массива jsonb
SELECT jsonb_array_length(product) AS arr_len FROM sales; -- вернет длинну массива json product


-- `?` (exists) - оператор проверяет наличие элемента в массиве `jsonb`. Это самый простой и быстрый способ.
SELECT jsonb_contains('["Lenita", "Mauricio", "Jene"]', '"Lenita"');        -- Возвращает true
SELECT jsonb_contains('["Lenita", "Mauricio", "Jene"]', '"Lenita"'::jsonb); -- Альтернативный вариант с явным указанием типа
SELECT '["Lenita", "Mauricio", "Jene"]'::jsonb ? 'Lenita';                  -- Возвращает true (более краткая запись)


-- В Postgresql для проверки наличия элемента в массиве `jsonb`, начинающегося с определенной подстроки, можно использовать комбинацию операторов и функций:
SELECT * FROM your_table
WHERE EXISTS (
  SELECT 1
  FROM jsonb_array_elements_text(your_jsonb_column) AS element
  WHERE element LIKE 'M%'
);
-- jsonb_array_elements_text(your_jsonb_column) - функция разворачивает массив `jsonb` в набор строк. Она преобразует каждый элемент массива в текстовую строку (так как `LIKE` работает со строками).
-- AS element - gрисваивает псевдоним `element` каждой строке (элементу массива).
-- WHERE element LIKE 'M%' - оператор `LIKE` для проверки, начинается ли строка `element` с буквы "M"
-- EXISTS (SELECT 1 ...) - gроверяет, существует ли хотя бы одна строка (элемент массива), которая удовлетворяет условию `LIKE 'M%'`. Если хотя бы один элемент подходит, `EXISTS` вернет `TRUE`, и строка из `your_table` будет включена в результаты.



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


-- 2. Извлечение по индексу. (если на этом уровне массив). Поле массива можно извлечь в виде jsonb, используя оператор ->, или как текст с помощью оператора ->>:
SELECT nums -> 0 AS n FROM sales;
-- nums - имя колонки с JSON-массивом
-- 0    - индекс элемента массива, который хотим извлечь
SELECT nums ->> 0 AS n FROM sales;


-- 3. Извлечение по цепочке. Eсть поле массива в поле JSON, которое называется size. Оно содержит от 0 до 2 значений.
SELECT
	product,                                           -- вернет весь JSON
	product -> 'size' AS size_json,                    -- извлечет элемент(тут массив) по ключу в виде jsonb
	product ->> 'size' AS size_txt,                    -- извлечет элемент(тут массив) по ключу в виде текста
	jsonb_array_length(product -> 'size') AS arr_len,  -- вернет длинну массива json
	(product -> 'size') ->> 0 AS first_el,             -- вернет элемент с индесом 0 вложенного массива из JSON под ключем 'size'
	((product -> 'size') ->> 1) :: FLOAT AS second_el, -- вернет элемент вложнного массива с последуюзим перемодом во float
	SPLIT_PART(AGE(CURRENT_TIMESTAMP, (data ->> 'date_of_birth')::TIMESTAMP)::TEXT, ' ', 1)::INT AS age,
  CASE -- Пример с использованием в CASE
    WHEN (data ->> 'private')::BOOL = TRUE THEN 'Hidden'
    WHEN ((data -> 'email_addresses') ->> 0) IS NULL THEN 'None'
    ELSE (data -> 'email_addresses') ->> 0
  END AS email_address
FROM sales


-- 4. Извлечсение множеств элементов в новый массив jsonb

-- jsonb_path_query_array(jsonb, jsonpath) - функция извлекает значения из JSON в соответствии с выражением JSONPath и возвращает массив `jsonb` этих значений
jsonb_path_query_array(`["Lenita", "Mauricio", "Jene"]`, '$[*]')  --> `["Lenita", "Mauricio", "Jene"]`
-- '$[*]'  -  JSON Path, который выбирает все элементы корневого массива
jsonb_path_query_array('[{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}]', '$[*].name') --> `["Lenita", "Mauricio", "Jene"]`
-- '$[*].name' - jsonpath извлекает все значения, связанные с ключом "name" во всех объектах массива.



--                                     Разворачивание json в строки таблицы

-- jsonb_array_elements(jsonb)  -  Разворачивает JSON-массив, содержащийся в `jsonb`, в набор JSON-значений. Каждое значение становится отдельной строкой в результирующем наборе.
jsonb_array_elements('[{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}]')
--=>
-- {"name": "Lenita", "type": "Dog"}
-- {"name": "Mauricio", "type": "Dog"}


-- jsonb_array_elements_text(jsonb) - Разворачивает массив `jsonb`, содержащий текстовые элементы, в набор текстовых значений.  Каждое значение становится отдельной строкой
jsonb_array_elements_text('["Lenita", "Mauricio"]')
--=>
-- "Lenita"
-- "Mauricio"



--                                      Преобразование JSON в обычный массив

-- Например json масиив pets содержащий объекты json [{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}] можно преобразовать в массив значений [ "Lenita",  "Mauricio"], извлекая только значение ключа "name", каждого объекта

-- 1. jsonb_array_elements разворачивает JSON-массив в набор JSON-объектов как строк таблицы, а затем `->>` извлекает значение из каждого объекта и агрегирует в новый массив
SELECT array_agg(element->>'name') AS names FROM jsonb_array_elements(pets) AS element;

-- 2. (Для Postgresql 12 и новее) `jsonb_path_query_array` извлекает всех значения "name" из JSON в соответствии с выражением JSONPath и возвращает массив `jsonb`, а `jsonb_array_elements_text`  преобразует этот массив в массив текстовых значений.
SELECT jsonb_array_elements_text(jsonb_path_query_array(pets, '$[*].name'));                        -- так
SELECT array_agg(x) FROM jsonb_array_elements_text(jsonb_path_query_array(pets, '$[*].name')) AS x; -- или так



--                                          Преобразование JSON в строку

-- 1. В PostgreSQL есть несколько способов объединить массив JSONB в строку:

-- а) (Работает в большинстве версий PostgreSQL) `jsonb_array_elements_text` развернет массив в набор строк и при помощи `string_agg` агрегируем строки в одну строку. Этот метод  и позволяет контролировать разделитель:
SELECT string_agg(elem, ', ')
FROM (
  SELECT jsonb_array_elements_text('[ "Lenita",  "Mauricio",  "Jene"]') AS elem
) AS subquery; --> Lenita, Mauricio, Jene

-- б) (Работает, начиная с Postgres 12) `jsonb_path_query_array`, использует JSONPath для получения элементов массива, что может быть более эффективным для больших JSONB-документов.
SELECT string_agg(elem, ', ')
FROM (
  SELECT jsonb_path_query_array('[ "Lenita",  "Mauricio",  "Jene"]', '$[*]')::TEXT AS elem
) AS subquery; --> Lenita, Mauricio, Jene
-- jsonb_path_query_array(jsonb, jsonpath) -  Извлекает JSONB массив из JSONB документа, используя JSONPath. В данном случае, `'$[*]'` выбирает все элементы массива.
-- ::text -  Преобразует каждый элемент JSONB в текстовую строку



-- 2. Объединить массив `jsonb` в строку в Postgresql, если он находится в колонке таблицы и нужно учитывать другие колонки. Например, есть таблица `users` с колонками: `id`(integer), `username`(text) и `names`(jsonb), например, `["Lenita", "Mauricio", "Jene"]`

-- а) `jsonb_array_elements_text` разворачивает массив `jsonb` в набор строк, `LATERAL` позволяет обращаться к этой "временной таблице" в основном запросе. string_agg агрегирует значения `name` в одну строку.
SELECT id, username, string_agg(name, ', ' ORDER BY name) AS full_name
FROM users CROSS JOIN LATERAL jsonb_array_elements_text(names) AS name
GROUP BY id, username;
-- GROUP BY id, username -  Обязателен, так как мы используем агрегатную функцию `string_agg`

-- Можно извлекать элементы прямо сразу в функциях
SELECT id, info->>'name' AS user_name, string_agg(pet->>'name', ', ') AS pet_names
FROM users, jsonb_array_elements(info->'pets') AS pet
WHERE pet->>'name' LIKE 'M%'
GROUP BY id, info->>'name';

-- б) (для сложных сложных JSON-структур) Этот подход более полезен, если нужно выбрать только определенные элементы из JSON-массива, используя JSON path.
SELECT id, username, string_agg(name, ', ' ORDER BY name) AS full_name
FROM users
CROSS JOIN LATERAL jsonb_path_query_array(names, '$[*]') AS name_array
CROSS JOIN LATERAL jsonb_array_elements_text(name_array) AS name
GROUP BY id, username;
-- jsonb_path_query_array(names, '$[*]')` -  Это извлекает все элементы массива `names` как новый `jsonb` массив.



--                                       Создание JSON из значений столбцов

-- json_build_array - функция создает массив JSON из вариативного списка аргументов. Каждый аргумент преобразуется согласно to_json или to_jsonb
json_build_array(1, 2, 'foo', 4, 5)             --→ [1, 2, "foo", 4, 5]

-- json_build_object - функция создает объект JSON из вариативного списка аргументов. По соглашению список аргументов состоит из чередующихся ключей и значений. Ключевые аргументы приводятся к тексту; аргументы значений преобразуются согласно to_json или to_jsonb
json_build_object('foo', 1, 2, row(3,'bar'))    --→ {"foo" : 1, "2" : {"f1":3,"f2":"bar"}}



--                                         Группировка строк в JSON массив

-- В PostgreSQL можно сгруппировать строки (например с JSON-объектами) в JSON-массив с помощью json_agg() или jsonb_agg() агрегантных функций:
-- json_agg() - агрегатная функция, которая собирает JSON-значения в JSON-массив
SELECT grouping_column, json_agg(json_column) AS json_array FROM your_table GROUP BY grouping_column;
-- jsonb_agg() - агрегатная функция (рекомендуется для JSONB)
SELECT grouping_column, jsonb_agg(jsonb_column) AS json_array FROM your_table GROUP BY grouping_column;


-- Дополнительные опции с `json_agg()`/`jsonb_agg()`:

-- 1. Можно отсортировать элементы внутри JSON-массива, добавив `ORDER BY`:
SELECT category, jsonb_agg(details ORDER BY details->>'name') AS product_details FROM products GROUP BY category;
-- сортирует продукты по имени (значению ключа `"name"` внутри JSON-объекта) внутри каждой категории.

-- 2. Можно добавить `FILTER (WHERE ...)` для фильтрации элементов, включаемых в JSON-массив:
SELECT category, jsonb_agg(details FILTER (WHERE details->>'price' > '50')) AS expensive_products FROM products GROUP BY category;
-- создает JSON-массив только для продуктов с ценой больше 50.














--
