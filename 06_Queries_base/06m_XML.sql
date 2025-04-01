--                                                    XML

-- https://www.postgresql.org/docs/13/functions-xml.html



--                                           Cоздание XML-элементов

-- xmlcomment(text) - функция создает комментарий XML с указанным текстом в качестве содержимого. Текст не может содержать « --» или заканчиваться на « -»
SELECT xmlcomment('привет');                   --> <!--привет-->


-- xmlconcat - функция объединяет список отдельных значений XML для создания одного значения. Значения Null опускаются.
SELECT xmlconcat('<abc/>', '<bar>foo</bar>');  --> <abc/><bar>foo</bar>
SELECT xmlconcat('<?xml version="1.1"?><foo/>', '<?xml version="1.1" standalone="no"?><bar/>'); --> <?xml версия="1.1"?><foo/><bar/>   XML-декларации: Если все имеют одинаковое версии XML, эта версия используется в результате, в противном случае версия не используется.


-- xmlelement - создает элемент XML с заданным именем, атрибутами и содержимым.
SELECT xmlelement(name foo);                                                     --> <foo/>
SELECT xmlelement(name foo, xmlattributes('xyz' as bar));                        --> <foo bar="xyz"/>
SELECT xmlelement(name foo, xmlattributes(current_date as bar), 'cont', 'ent');  --> <foo bar="2007-01-26">content</foo>

-- Имена элементов и атрибутов, которые не являются допустимыми в XML, экранируются путем замены ошибочных символов последовательностью "_xHHHH_", где "HHHH" код символа в шестнадцатеричной записи
SELECT xmlelement(name "foo$bar", xmlattributes('xyz' as "a&b"));                --> <foo_x0024_bar a_x0026_b="xyz"/>

-- Явное имя атрибута не нужно указывать, если значение атрибута является ссылкой на столбец, в этом случае имя столбца будет использоваться как имя атрибута по умолчанию. В других случаях атрибуту должно быть дано явное имя. Поэтому этот пример является допустимым:
CREATE TABLE test (a xml, b xml);
SELECT xmlelement(name test, xmlattributes(a, b)) FROM test;
-- а этот нет:
SELECT xmlelement(name test, xmlattributes('constant'), a, b) FROM test;
SELECT xmlelement(name test, xmlattributes(func(a, b))) FROM test;

-- Содержимое элемента, если указано, будет отформатировано в соответствии с его типом данных. Если содержимое само по себе имеет тип xml, могут быть созданы сложные XML-документы. Например:
SELECT xmlelement(name foo, xmlattributes('xyz' as bar),
                            xmlelement(name abc),
                            xmlcomment('test'),
                            xmlelement(name xyz));
--> <foo bar="xyz"><abc/><!--test--><xyz/></foo>


-- xmlforest - создает XML-лес (последовательность) элементов, используя заданные имена и содержимое. Что касается xmlelement, каждый name должен быть простым идентификатором, в то время как content выражения могут иметь любой тип данных. Леса XML не являются допустимыми документами XML, если они состоят из более чем одного элемента, поэтому может быть полезно заключать xmlforest выражения в xmlelement.
SELECT xmlforest('abc' AS foo, 123 AS bar); --> <foo>abc</foo><bar>123</bar>

-- имя элемента может быть опущено, если значением содержимого является ссылка на столбец, в этом случае имя столбца используется по умолчанию. В противном случае имя должно быть указано
SELECT xmlforest(table_name, column_name) FROM information_schema.columns WHERE table_schema = 'pg_catalog';
-->
-- <table_name>pg_authid</table_name>​<column_name>rolname</column_name>
-- <table_name>pg_authid</table_name>​<column_name>rolsuper</column_name> ...


-- xmlpi - создает инструкцию обработки XML. Что касается xmlelement, то name должен быть простым идентификатором, тогда как content выражение может иметь любой тип данных. content не должен содержать последовательность символов ?>.
SELECT xmlpi(name php, 'echo "hello world";');      --> <?php echo "hello world";?>


-- xmlroot - изменяет свойства корневого узла значения XML. Если указана версия, оно заменяет значение в объявлении версии корневого узла; если указана отдельная настройка, оно заменяет значение в отдельном объявлении корневого узла.
SELECT xmlroot(xmlparse(document '<?xml version="1.1"?><content>abc</content>'), version '1.0', standalone yes);
--> <?xml version="1.0" standalone="yes"?><content>abc</content>


-- xmlagg - является агрегатной функцией. Она объединяет входные значения в вызов агрегатной функции, как и xmlconcat делает, за исключением того, что объединение происходит по строкам, а не по выражениям в одной строке.
CREATE TABLE test (y int, x xml);
INSERT INTO test VALUES (1, '<foo>abc</foo>');
INSERT INTO test VALUES (2, '<bar/>');
SELECT xmlagg(x) FROM test;                                         --> <foo>abc</foo><bar/>
-- Чтобы определить порядок конкатенации, ORDER BY можно добавить предложение к совокупному вызову
SELECT xmlagg(x ORDER BY y DESC) FROM test;                         --> <bar/><foo>abc</foo>
SELECT xmlagg(x) FROM (SELECT * FROM test ORDER BY y DESC) AS tab;  --> <bar/><foo>abc</foo>



--                                                XML-предикаты

-- Выражения, описанные в этом разделе, проверяют свойства xml значений.


-- xml IS DOCUMENT - возвращает true, если значение аргумента XML является надлежащим XML-документом, false, если это не так или null, если аргумент является null.

-- xml IS NOT DOCUMENT - возвращает false, если XML-значение аргумента является надлежащим XML-документом, true, если это не так или null, если аргумент равен null.


-- xmlexists - оценивает выражение XPath 1.0 (первый аргумент) с переданным значением XML в качестве элемента контекста. Функция возвращает false, если результат оценки дает пустой набор узлов, true, если он дает любое другое значение. Функция возвращает null, если любой аргумент имеет значение null.
SELECT xmlexists('//town[text() = ''Toronto'']' PASSING BY VALUE '<towns><town>Toronto</town><town>Ottawa</town></towns>'); --> t


-- xml_is_well_formed_document(text) - проверяет правильность формата документа, возвращая true или false
SELECT xml_is_well_formed_document('<pg:foo xmlns:pg="http://postgresql.org/stuff">bar</pg:foo>');  --> t
SELECT xml_is_well_formed_document('<pg:foo xmlns:pg="http://postgresql.org/stuff">bar</my:foo>');  --> f

-- xml_is_well_formed_content(text) - проверяет правильность формата содержимого, возвращая true или false

-- xml_is_well_formed(text) - проверяет правильность формата документа, если параметр конфигурации xmloption установлен в значение DOCUMENT, или проверяет правильность формата содержимого, если он установлен в значение CONTENT, возвращая true или false
SET xmloption TO DOCUMENT;
SELECT xml_is_well_formed('<>');     --> f
SELECT xml_is_well_formed('<abc/>'); --> t
SET xmloption TO CONTENT;
SELECT xml_is_well_formed('abc');    --> t



--                                            Обработка (парсинг) XML

-- Для обработки значений типа данных xml PostgreSQL предлагает функции xpath и xpath_exists, которые оценивают выражения XPath 1.0, а также XMLTABLE табличную функцию


-- xpath - возвращает массив значений XML, соответствующих набору узлов, созданному выражением XPath(заданное как текст). Если выражение XPath возвращает скалярное значение, а не набор узлов, возвращается одноэлементный массив.
-- Второй аргумент должен быть правильно сформированным XML-документом. В частности, он должен иметь один элемент root node.
-- Необязательный третий аргумент — массив отображений пространств имен. Этот массив должен быть двумерным text массивом каждый из которых состоит ровно из 2 элементов. Первый элемент каждой записи массива — имя пространства имен (псевдоним), второй — URI пространства имен
SELECT xpath('/my:a/text()', '<my:a xmlns:my="http://example.com">test</my:a>', ARRAY[ARRAY['my', 'http://example.com']]);
--> {test}       -- (1 row)

-- Чтобы работать с пространствами имен по умолчанию (анонимными), сделайте что-то вроде этого:
SELECT xpath('//mydefns:b/text()', '<a xmlns="http://example.com"><b>test</b></a>', ARRAY[ARRAY['mydefns', 'http://example.com']]);    --> {test}        -- (1 row)


-- xpath_exists - является специализированной формой функции xpath. Вместо возврата отдельных значений XML, которые удовлетворяют выражению XPath 1.0, эта функция возвращает логическое значение, указывающее, был ли удовлетворен запрос или нет (в частности, было ли создано какое-либо значение, отличное от пустого набора узлов)
SELECT xpath_exists('/my:a/text()', '<my:a xmlns:my="http://example.com">test</my:a>', ARRAY[ARRAY['my', 'http://example.com']]);
--> t                  -- (1 row)



-- xmltable - создает таблицу на основе значения XML, фильтра XPath для извлечения строк и набора определений столбцов. Хотя синтаксически оно напоминает функцию, оно может отображаться только как таблица в FROM предложении запроса:

-- XMLTABLE (
--     [ XMLNAMESPACES ( namespace_uri AS namespace_name [, ...] ), ]
--     row_expression PASSING [BY {REF|VALUE}] document_expression [BY {REF|VALUE}]
--     COLUMNS name { type [PATH column_expression] [DEFAULT default_expression] [NOT NULL | NULL]
--                   | FOR ORDINALITY }
--             [, ...]
-- ) → setof record

-- XMLNAMESPACES (Необязательно) предложение дает разделенный запятыми список определений пространств имен, где каждое namespace_uri является text выражением, а каждое namespace_name — простым идентификатором. Оно указывает пространства имен XML, используемые в документе, и их псевдонимы.

-- row_expression (Требуемый) аргумент — это выражение XPath 1.0 (задано как text), которое оценивается, передавая значение XML document_expression в качестве своего элемента контекста, чтобы получить набор узлов XML. Эти узлы преобразуются xmltable в выходные строки. Строки не будут созданы, если document_expression равно null или если row_expression создает пустой набор узлов или любое значение, отличное от набора узлов.

-- document_expression - предоставляет элемент контекста для row_expression. Это должен быть правильно сформированный XML-документ; фрагменты/леса не принимаются. Предложения BY REF и BY VALUE принимаются, но игнорируются.

-- COLUMNS (Обязательный) - определяет столбец(ы), которые будут созданы в выходной таблице. Имя требуется для каждого столбца, как и тип данных (если не FOR ORDINALITY указано иное, в этом случае тип integer подразумевается). Пункты path, default и nullability являются необязательными.

-- FOR ORDINALITY  - столбец будет заполнен номерами строк, начиная с 1, в порядке узлов, извлеченных из row_expression результирующего набора узлов. Только один столбец может быть FOR ORDINALITY.

-- for a column — это column_expression выражение XPath 1.0, которое вычисляется для каждой строки с текущим узлом из row_expression результата в качестве элемента контекста, чтобы найти значение столбца. Если column_expression не указано, то имя столбца используется как неявный путь.

-- Строковое значение элемента XML представляет собой объединение в порядке документа всех текстовых узлов, содержащихся в этом элементе и его потомках. Строковое значение элемента без текстовых узлов-потомков представляет собой пустую строку (не NULL). Любые xsi:nil атрибуты игнорируются. Обратите внимание, что text() узел, состоящий только из пробелов, между двумя нетекстовыми элементами сохраняется, а начальный пробел в text() узле не сглаживается.

-- Если выражение пути возвращает пустой набор узлов (обычно, когда он не совпадает) для заданной строки, столбцу будет присвоено значение NULL, если default_expression не указано a; в этом случае используется значение, полученное в результате вычисления этого выражения.

CREATE TABLE xmldata AS SELECT
xml $$
<ROWS>
  <ROW id="1">
    <COUNTRY_ID>AU</COUNTRY_ID>
    <COUNTRY_NAME>Australia</COUNTRY_NAME>
  </ROW>
  <ROW id="5">
    <COUNTRY_ID>JP</COUNTRY_ID>
    <COUNTRY_NAME>Japan</COUNTRY_NAME>
    <PREMIER_NAME>Shinzo Abe</PREMIER_NAME>
    <SIZE unit="sq_mi">145935</SIZE>
  </ROW>
  <ROW id="6">
    <COUNTRY_ID>SG</COUNTRY_ID>
    <COUNTRY_NAME>Singapore</COUNTRY_NAME>
    <SIZE unit="sq_km">697</SIZE>
  </ROW>
</ROWS>
$$ AS data;

SELECT xmltable.*
  FROM xmldata,
       XMLTABLE('//ROWS/ROW'
                PASSING data
                COLUMNS id int PATH '@id',
                        ordinality FOR ORDINALITY,
                        "COUNTRY_NAME" text,
                        country_id text PATH 'COUNTRY_ID',
                        size_sq_km float PATH 'SIZE[@unit = "sq_km"]',
                        size_other text PATH
                             'concat(SIZE[@unit!="sq_km"], " ", SIZE[@unit!="sq_km"]/@unit)',
                        premier_name text PATH 'PREMIER_NAME' DEFAULT 'not specified');
-->
--  id | ordinality | COUNTRY_NAME | country_id | size_sq_km |  size_other  | premier_name
-- ----+------------+--------------+------------+------------+--------------+---------------
--   1 |          1 | Australia    | AU         |            |              | not specified
--   5 |          2 | Japan        | JP         |            | 145935 sq_mi | Shinzo Abe
--   6 |          3 | Singapore    | SG         |        697 |              | not specified






-- 1. Использование `xmltable` (наиболее рекомендуемый и гибкий подход)
-- xmltable - это табличная функция, которая позволяет извлечь данные из XML-документа и представить их в виде таблицы. Это наиболее мощный и гибкий способ.

SELECT *
FROM xmltable(
    '/root/items/item'              -- XPath для выборки элементов
    PASSING XMLPARSE(CONTENT '<root><items><item id="1" name="product1" price="10"/><item id="2" name="product2" price="20"/></items></root>')                 -- XML документ
    COLUMNS
        id INTEGER PATH '@id',       -- Извлекаем атрибут 'id'
        name TEXT PATH '@name',      -- Извлекаем атрибут 'name'
        price NUMERIC PATH '@price'  -- Извлекаем атрибут 'price'
);

SELECT *
FROM xmltable(
    '/root/book'
    PASSING XMLPARSE(CONTENT '<root><book id="123"><title>My Book</title><author>John Doe</author></book></root>')
    COLUMNS
        book_id INTEGER PATH '@id',
        title TEXT PATH 'title',
        author TEXT PATH 'author'
);

-- '/root/items/item' - XPath выражение, которое указывает, какие узлы XML нужно обработать. В данном случае, это все узлы `<item>` внутри `<items>` внутри `<root>`
-- PASSING XMLPARSE(CONTENT '...') - это сам XML документ, который нужно распарсить. Функция `XMLPARSE` преобразует строку в XML-объект.  Можно использовать `XMLDOCUMENT` вместо `XMLPARSE(CONTENT ...)` если XML берется из файла или другой переменной XML-типа.
-- COLUMNS - блок определяет, какие столбцы будут в результирующей таблице и как они будут извлекаться из XML
-- PATH '@attribute' - указывает, что нужно извлечь значение атрибута
-- PATH 'element' - указывает, что нужно извлечь значение текстового содержимого элемента.



-- 2. Использование функций `xpath` и `unnest` если XML-структура простая и не требует сложных XPath выражений
SELECT
  unnest(xpath('//item/@id', xml_data))::TEXT AS id,
  unnest(xpath('//item/@name', xml_data))::TEXT AS name,
  unnest(xpath('//item/@price', xml_data))::TEXT AS price
FROM (SELECT XMLPARSE(CONTENT '<root><items><item id="1" name="product1" price="10"/><item id="2" name="product2" price="product2" price="20"/></items></root>') AS xml_data) AS subquery;
-- xpath('//item/@id', xml_data)  - выполняет XPath запрос `//item/@id` к XML-данным, которые хранятся в столбце `xml_data`.  XPath `//item/@id` выбирает все атрибуты `id` элементов `item` в XML-документе. Результат `xpath` - массив XML-узлов.
-- unnest(...) - функция "разворачивает" массив, полученный от `xpath`, в отдельные строки.
-- ::TEXT  - т.к. `xpath` возвращает XML-узлы, которые нужно преобразовать в текст.




-- Как распарсить XML из столбца таблицы в PostgreSQL

-- Предполагается, что у есть таблица следующего вида:
CREATE TABLE my_table ( id SERIAL PRIMARY KEY, xml_data XML ); -- где xml_data содержит:
-- <root>
--   <item id="1">
--     <name>Product A</name>
--     <price>10.99</price>
--     <category>Electronics</category>
--   </item>
--   <item id="2">
--     <name>Product B</name>
--     <price>25.50</price>
--     <category>Books</category>
--   </item>
-- </root>


-- 1. Использование XPath и `xpath()` функции:  Это наиболее гибкий способ, позволяющий извлекать данные из XML практически любой структуры.
SELECT
    (xpath('/root/item/@id', xml_data))[1]::TEXT AS item_id,
    (xpath('/root/item/name/text()', xml_data))[1]::TEXT AS item_name,
    (xpath('/root/item/price/text()', xml_data))[1]::NUMERIC AS item_price,
    (xpath('/root/item/category/text()', xml_data))[1]::TEXT AS item_category
FROM my_table;
-- xpath('/root/item/@id', xml_data) -  XPath-выражение, которое выбирает атрибут `id` узла `item`.
-- xpath('/root/item/name/text()', xml_data) -  XPath-выражение, которое выбирает текст внутри узла `name`.
-- [1] - Функция `xpath()` возвращает массив XML-элементов.  `[1]` выбирает первый (и в данном случае единственный) элемент в массиве.
-- ::TEXT, ::NUMERIC - Приведение типа к TEXT или NUMERIC. Важно приводить типы, чтобы PostgreSQL правильно интерпретировал данные.

SELECT
  unnest(xpath('/user/first_name/text()', data2))::text as first_name,
  unnest(xpath('/user/last_name/text()', data2))::text as last_name,
  DATE_PART('year', AGE(TO_DATE(unnest(xpath('//date_of_birth/text()', data2))::text, 'yyyy-mm-dd')))::int as age,
  CASE
    WHEN xpath('/user/private/text()', data2)::text LIKE '%true%' THEN 'Hidden'
    WHEN array_length(xpath('/user/email_addresses/*[1]/text()', data2), 1) is null THEN 'None'
    else unnest(xpath('/user/email_addresses/*[1]/text()', data2))::text
  END email_address
FROM
  (select unnest(xpath('/data/user', data)) as data2 from users) t
ORDER BY first_name, last_name


-- 2. Использование XMLTABLE: Это более специализированный подход, но может быть удобным для структурированных XML-документов с предсказуемым форматом. Функция `XMLTABLE` упрощает разбор XML в табличное представление, особенно если XML имеет структуру, которая хорошо подходит для преобразования в таблицу.
SELECT
  x.*
FROM my_table,
XMLTABLE(
  '/root/item'
  PASSING xml_data
  COLUMNS
    item_id TEXT PATH '@id',
    item_name TEXT PATH 'name',
    item_price NUMERIC PATH 'price',
    item_category TEXT PATH 'category'
) AS x;
-- XMLTABLE('/root/item' ...) - Указывает корневой элемент, который нужно итерировать (`/root/item`).
-- PASSING xml_data           - Передает XML-данные из столбца таблицы `xml_data`.
-- COLUMNS                    - Определяет столбцы результирующей таблицы и соответствующие XPath-выражения для каждого столбца.
-- item_id TEXT PATH '@id'    - Создает столбец `item_id` типа TEXT и заполняет его значением атрибута `id`.
-- item_name TEXT PATH 'name' - Создает столбец `item_name` типа TEXT и заполняет его значением элемента `name`.




-- Иногда выражение пути ссылается на элемент, имеющий несколько значений.

-- Выражения пути в предложении COLUMNS не должны выдавать более одного элемента на строку.

-- 0. у сотрудника Мэри Джонс два номера телефона. Если нужно запросить эти данные и вернуть реляционную таблицу с именем и номером телефона каждого сотрудника, запрос может выглядеть следующим образом:
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH 'name/first',
                      lastname  VARCHAR(25)  PATH 'name/last',
                      phone     VARCHAR(12)  PATH 'phone') AS X
-- При запуске с образцами документов этот запрос не выполняется, поскольку для phone есть два значения. Необходимо другое решение.

-- 1. Вернуть только первое значение. Если нужна сводная информация по каждому сотруднику, может быть достаточно иметь только один номер телефона. Это можно осуществить с помощью позиционного предиката в выражении XPath для столбца телефон.

-- Квадратные скобки в XPath используются для указания предикатов. Чтобы получить первый элемент телефона для сотрудника, используйте позиционный предикат, записанный как[1] или [fn:position()=1]. Первая запись [1] является сокращенной версией второго
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH 'name/first',
                      lastname  VARCHAR(25)  PATH 'name/last',
                      phone     VARCHAR(12)  PATH 'phone[1]') AS X

-- еще пример, где в теге email_addresse, есть много тегов address
SELECT
  x.*
FROM users,
XMLTABLE(
  '/data/user'
  PASSING data
  COLUMNS
    first_name TEXT PATH 'first_name',
    last_name TEXT PATH 'last_name',
    age DATE PATH 'date_of_birth',
    private TEXT PATH 'private',
    email_address TEXT PATH 'email_addresses/address[1]'
) AS x;

-- тк вся работа с XML идет в поле FROM то в поле SELECT можно споойно делать все нужные последующие преобразования
SELECT
  first_name,
  last_name,
  DATE_PART('year', AGE(date_of_birth))::integer as age,
  CASE WHEN private = true THEN 'Hidden' WHEN email IS NULL THEN 'None' ELSE email END as email_address
FROM users x,
  XMLTABLE('/data/user'
    PASSING x.data
    COLUMNS
      first_name     VARCHAR(50)   PATH 'first_name',
      last_name      VARCHAR(50)   PATH 'last_name',
      date_of_birth  DATE          PATH 'date_of_birth',
      private        BOOLEAN       PATH 'private',
      email          TEXT          PATH 'email_addresses/address[1]'
  ) xt
ORDER BY first_name, last_name;


-- 2. Возврат нескольких значений в виде XML

-- Другой вариант возврата нескольких телефонных номеров для одного сотрудника — возврат XML-последовательности телефонных элементов. Для этого сгенерированный столбец телефон должен иметь тип XML, что позволяет возвращать значение XML как результат выражения XPath.
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH 'name/first',
                      lastname  VARCHAR(25)  PATH 'name/last',
                      phone     XML          PATH 'phone') AS X
-->
-- FIRSTNAME    LASTNAME   PHONE
--  ----------- ---------- ------------------
-- John         Doe        -
-- Peter        Pan        <phone>905-416-5004</phone>
-- Mary         Jones      <phone>905-403-6112</phone><phone>647-504-4546</phone>

-- Значение XML, возвращаемое в столбце телефонов для Мэри Джонс, не является правильно сформированным документом XML, поскольку нет единого корневого элемента.

-- 3. Возврат нескольких столбцов — возвращать каждый номер телефона как отдельное значение VARCHAR, создавая фиксированное количество столбцов результата телефона. В этом примере используются позиционные предикаты для возврата номеров телефонов в двух столбцах.
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH 'name/first',
                      lastname  VARCHAR(25)  PATH 'name/last',
                      phone     VARCHAR(12)  PATH 'phone[1]',
                      phone2    VARCHAR(12)  PATH 'phone[2]') AS X
-- недостаток - переменное количество элементов сопоставляется с фиксированным количеством столбцов. У одного сотрудника может быть больше телефонных номеров, чем предполагалось.

-- 4. Возвращает одну строку для каждого значения. использовать XMLTABLE, чтобы вернуть значения в отдельных строках. В этом случае вам нужно вернуть одну строку для каждого номера телефона вместо одной строки для каждого сотрудника. Это может привести к повторению информации в столбцах для имени и фамилии.
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee/phone' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH '../name/first',
                      lastname  VARCHAR(25)  PATH '../name/last',
                      phone     VARCHAR(12)  PATH '.') AS X
-->
-- FIRSTNAME    LASTNAME   PHONE
--  ----------- ---------- ------------------
-- Peter        Pan        905-416-5004
-- Mary         Jones      905-403-6112
-- Mary         Jones      647-504-4546
-- В этом результате строка для Джона Доу отсутствует, поскольку у него нет номера телефона.


-- Обработка несуществующих значений пути. Предыдущий пример не вернул строку для сотрудника Джона Доу, потому что выражение row-xquery перебирает все элементы phone, а для сотрудника Джона Доу нет элемента phone. В результате элемент employee для Джона Доу никогда не обрабатывается.

-- Чтобы решить эту проблему, необходимо использовать SQL UNION из двух функций XMLTABLE.
SELECT X.*
  FROM emp,
       XMLTABLE ('$d/dept/employee/phone' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH '../name/first',
                      lastname  VARCHAR(25)  PATH '../name/last',
                      phone     VARCHAR(12)  PATH '.') AS X
UNION
SELECT Y.*, CAST(NULL AS VARCHAR(12))
  FROM emp,
       XMLTABLE ('$d/dept/employee[fn:not(phone)]' PASSING doc AS "d"
                 COLUMNS
                      firstname VARCHAR(20)  PATH 'name/first',
                      lastname  VARCHAR(25)  PATH 'name/last') AS Y
-- The$d/отдел/сотрудник[fn:не(телефон)]Выражение строки во второй XMLTABLE возвращает всех сотрудников без номеров телефонов, добавляя строки сотрудников, которые были пропущены в первой XMLTABLE.













--
