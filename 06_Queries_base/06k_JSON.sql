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



--                                   Разворачивание в строки и сложные извлечения

-- Как масиив jsonb [{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}] преобразовать в массив [ "Lenita",  "Mauricio"], извлекая значение ключа "name".

-- 1. Используя `jsonb_array_elements` и `->>`. Этот метод разворачивает JSON-массив в набор JSON-объектов, а затем извлекает текстовое значение из каждого объекта.
SELECT array_agg(element->>'name') AS names
FROM jsonb_array_elements('[{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}]') AS element;
-- jsonb_array_elements(jsonb)  -  Разворачивает JSON-массив, содержащийся в `jsonb`, в набор JSON-значений.  Каждое значение становится отдельной строкой в результирующем наборе.
-- element->>'name' - Извлекает текстовое значение, связанное с ключом `name` из каждого JSON-объекта `element`. Оператор `->>` преобразует извлеченное значение в текст.
-- array_agg(text) - Собирает набор текстовых значений в массив.

-- 2. Используя `jsonb_path_query_array` и `jsonb_array_elements_text` (Для Postgresql 12 и новее). Этот метод использует JSONPath для извлечения всех значений "name" как массив `jsonb`, а затем преобразует этот массив в массив текстовых значений.
SELECT jsonb_array_elements_text(jsonb_path_query_array('[{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}]', '$[*].name'));
-- или
SELECT array_agg(x)
FROM jsonb_array_elements_text(jsonb_path_query_array('[{"name": "Lenita", "type": "Dog"}, {"name": "Mauricio", "type": "Dog"}]', '$[*].name')) as x;
-- jsonb_path_query_array(jsonb, jsonpath) - Извлекает значения из JSON `jsonb` в соответствии с выражением JSONPath `jsonpath` и возвращает массив `jsonb`.
-- '$[*].name' - jsonpath извлекает все значения, связанные с ключом "name" во всех объектах массива.
-- jsonb_array_elements_text(jsonb) - Разворачивает массив `jsonb`, содержащий текстовые элементы, в набор текстовых значений.  Каждое значение становится отдельной строкой
-- array_agg(text) - Собирает набор текстовых значений в массив.



--                                          Информационные методы

-- `?` (exists) - оператор проверяет наличие элемента в массиве `jsonb`.  Это самый простой и обычно самый быстрый способ для проверки наличия конкретного элемента.
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



--                                            Преобразование JSON

-- В PostgreSQL есть несколько способов объединить массив JSONB в строку:

-- 1. Используя `jsonb_array_elements_text` и `string_agg` (Наиболее универсальный способ) Этот метод работает в большинстве версий PostgreSQL и позволяет контролировать разделитель:
SELECT string_agg(elem, ', ')  -- Замените ', ' на нужный разделитель
FROM (
  SELECT jsonb_array_elements_text('[ "Lenita",  "Mauricio",  "Jene"]') AS elem
) AS subquery; --> Lenita, Mauricio, Jene
-- jsonb_array_elements_text(jsonb) - Разворачивает массив JSONB в набор строк, где каждый элемент массива представлен как строка.
-- string_agg(text, text) - Агрегирует набор строк в одну строку, используя заданный разделитель.

-- 2. Используя `jsonb_path_query_array` и `string_agg` (Более современный способ, начиная с Postgres 12), использует JSONPath для получения элементов массива, что может быть более эффективным для больших JSONB-документов.
SELECT string_agg(elem, ', ')
FROM (
  SELECT jsonb_path_query_array('[ "Lenita",  "Mauricio",  "Jene"]', '$[*]')::text AS elem
) AS subquery; --> Lenita, Mauricio, Jene
-- jsonb_path_query_array(jsonb, jsonpath) -  Извлекает JSONB массив из JSONB документа, используя JSONPath. В данном случае, `'$[*]'` выбирает все элементы массива.
-- ::text -  Преобразует каждый элемент JSONB в текстовую строку.
-- string_agg(text, text) -  Агрегирует набор строк в одну строку, используя заданный разделитель.


-- Объединить массив `jsonb` в строку в Postgresql, если этот массив находится в колонке таблицы и вам нужно учитывать другие колонки
-- Предположим, есть таблица `users` со следующими колонками:
-- *   `id` (integer):    Уникальный идентификатор пользователя
-- *   `username` (text): Имя пользователя
-- *   `names` (jsonb):   Массив имен (например, `["Lenita", "Mauricio", "Jene"]`)

-- Решение 1: Используя `jsonb_array_elements_text` и `string_agg`
SELECT
  id,
  username,
  string_agg(name, ', ' ORDER BY name) AS full_name
FROM users
CROSS JOIN LATERAL jsonb_array_elements_text(names) AS name
GROUP BY id, username;
-- jsonb_array_elements_text(names) - Эта функция разворачивает массив `jsonb` в набор строк.  `LATERAL` позволяет обращаться к этой "временной таблице" в основном запросе.
-- string_agg(name, ', ' ORDER BY name) -  Эта функция агрегирует (объединяет) значения `name` (которые стали строками из массива) в одну строку, разделяя их запятой и пробелом.  `ORDER BY name` опционально сортирует имена перед объединением.
-- GROUP BY id, username -  Обязателен, так как мы используем агрегатную функцию `string_agg`

-- Решение 2: Используя `jsonb_path_query_array` и `string_agg` (для более сложных случаев) Этот подход более полезен, если вам нужно выбрать только *определенные* элементы из JSON-массива, используя JSON path.  Он также может быть полезен для сложных JSON-структур.
SELECT
  id,
  username,
  string_agg(name, ', ' ORDER BY name) AS full_name
FROM users
CROSS JOIN LATERAL jsonb_path_query_array(names, '$[*]') AS name_array
CROSS JOIN LATERAL jsonb_array_elements_text(name_array) AS name
GROUP BY id, username;
-- jsonb_path_query_array(names, '$[*]')` -  Это извлекает все элементы массива `names` как новый `jsonb` массив. `'$[*]'` - это JSON Path, который выбирает все элементы корневого массива.  (Эквивалентно `names` в первом примере).
-- Остальное аналогично первому решению.














--
