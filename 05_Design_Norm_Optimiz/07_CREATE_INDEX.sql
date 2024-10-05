--                                Примеры построения индексов: Подготовка таблицы

-- Создадим таблицу:
CREATE TABLE perf_test
(
  id INTEGER,
  reason TEXT COLLATE "C", -- COLLATE "C" - говорим не использовать таблице колэйшен, тоесть правила сортировки и сравнения, если они по умолчанию привязаны например к кирилице, а будет использоваться просто побайтовое сравнение символов в строке, тк будем использовать латиницу для этих строк
  annotation TEXT COLLATE "C"
);

-- Заполним таблицу случайными данными:
INSERT INTO perf_test(id, reason, annotation)
SELECT s.id, MD5(RANDOM()::TEXT), NULL FROM GENERATE_SERIES(1, 10000000) AS s(id) ORDER BY RANDOM();
-- Отдельно заполним колонку annotation, на всякий, чтоб не генерило одинаковый текст
UPDATE perf_test
SET annotation = UPPER(MD5(RANDOM()::TEXT))

-- Получим таблицу из 10 миллионов строк хэшей MD5 обычных и в верхнем регистре



--                                 Создание индекса B-tree. EXPLAIN, ANALYZE

-- Данный запрос будет испольняться примерно 2 секунды, что достаточно долго:
SELECT * FROM perf_test WHERE id = 3700000;

-- Проверим при помощи EXPLAIN(или EXPLAIN ANALYZE) почему он исполнялся так долго:
EXPLAIN SELECT * FROM perf_test WHERE id = 3700000;  --> среди прочей инфы видим 'Paralel Seq Scan', тоесть чтение выполняется при помощи самого долгого последовательного сканирования

-- Создадим B-tree индекс для поиска по id в этой таблице. Построение индекса также занимает время если строк много (тут примерно 11 секунд):
CREATE INDEX idx_perf_test_idx ON perf_test(id);
-- idx_perf_test_idx - имя для индекса

-- Проверим еще раз при помощи EXPLAIN:
EXPLAIN SELECT * FROM perf_test WHERE id = 3700000;  --> среди прочей инфы видим 'Bitmap Index Scan', тоесть теперь производится побитовое индексное сканирование

-- Теперь тот же запрос будет испольняться примерно 60 милисекун, илиза 0.06 секунды:
SELECT * FROM perf_test WHERE id = 3700000;



--                                  Поиск по шаблону LIKE, индекс по выражению

-- Сделаем селект по шаблону LIKE сразу по 2м колонкам, он отрабатывает примерно за 2.5 секунды
SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE 'AB%';

-- Проверим почему так медленно:
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE 'AB%'; --> среди прочей инфы видим 'Paralel Seq Scan'

-- Чтобы ускорить такие типы запросов, построим индекс сразу по 2м колонкам (построение заняло почти 30 секунд)
CREATE INDEX idx_perf_test_reason_annotation ON perf_test(reason, annotation);

-- Проверим еще раз:
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE 'AB%'; --> среди прочей инфы видим 'Index Scan'

-- Теперь тот же запрос занимает 200 милисекунд
SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE 'AB%';


-- Построение индекса по 2м колонкам дает так же нам возможность индексного поиска по первой из них отдельно, но не дает отдельного поиска по второй, потому если мы хотим такой, то придется сделать отдельный индекс
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%';     --> 'Bitmap Index Scan' и 300 милисекунд на запрос
EXPLAIN SELECT * FROM perf_test WHERE annotation LIKE 'AB%'; --> 'Paralel Seq Scan'  и 1.2 секунды на запрос

-- Попробуем решить проблему простым построением индекса:
CREATE INDEX idx_perf_test_annotation ON perf_test(annotation);
-- Проверим:
EXPLAIN SELECT * FROM perf_test WHERE annotation LIKE 'AB%'; --> 'Bitmap Index Scan'  и 370 милисекунд на запрос


-- Но если поиск будет идти с использованием функций преобразования строк, то не будет поиска по индексу созданному для колонки
SELECT * FROM perf_test WHERE LOWER(annotation) LIKE 'ab%'         --> почти 2 секунды
EXPLAIN SELECT * FROM perf_test WHERE LOWER(annotation) LIKE 'ab%' --> 'Paralel Seq Scan'

-- Чтобы заработало нужно создать отдельный индекс конкретно для использования с этой функции (индекс по выражению)
CREATE INDEX idx_perf_test_annotation_lower ON perf_test(LOWER(annotation));
-- Проверим
SELECT * FROM perf_test WHERE LOWER(annotation) LIKE 'ab%'         --> почти 300 милисекунд
EXPLAIN SELECT * FROM perf_test WHERE LOWER(annotation) LIKE 'ab%' --> 'Bitmap Index Scan'


-- Пример создания индексов для ускорения запроса с большим числом строк
CREATE INDEX some_idx1 ON customers(lower(first_name || ' ' || last_name), lower(first_name || ',' || last_name));
CREATE INDEX some_idx2 ON prospects(lower(full_name));
SELECT a.first_name, a.last_name, a.credit_limit AS old_limit, max(b.credit_limit) AS new_limit
FROM customers a JOIN prospects b
  ON lower(full_name) IN (lower(a.first_name || ' ' || a.last_name), lower(a.last_name || ', ' || a.first_name))
GROUP BY a.id HAVING MAX(b.credit_limit) > a.credit_limit;



--                                          Создание индекса GIN

-- Если мы хотим усложнить регулярное выражение используемое в LIKE и осуществлять индексный поиск по нему, то придется использовать специализированный индекс

-- По простому выражению работает ранее созданный индекс:
SELECT * FROM perf_test WHERE reason LIKE 'bc%';          --> 300 милисекунд
-- Но вот по более сложному:
SELECT * FROM perf_test WHERE reason LIKE '%bc%';         --> 3.3 секунды, тоесть параллельное последовательное сканирование
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE '%bc%'; --> 'Paralel Seq Scan'

-- Чтобы ускорить текстматчинг, тоесть поиск по шаблонам/рег выражением нужно построить индекс GIN или GiST

-- Для этого сперва нужно запустить/подключить расширение модуля pg_trgm
CREATE EXTENSION pg_trgm;

-- Далее можем создать и сам индекс. Заняло 2 минуты
CREATE INDEX trgm_idx_perf_test_reason ON perf_test USING GIN (reason gin_trgm_ops);

-- Проверим
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE '%bc%'; --> 'Seq Scan' тоесть все равно последовательное сканирование и 2.7 секунд на запрос, все потому что нет гарантий, что будет использоваться индексный поиск, в данном случае он не был использован тк запрос выводит более миллиона строк

-- Но если сократим число строк в выводе задав более редкую подстроку для выборки, тогда появляется причина переходить на индексный поиск
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE '%fаbc%'; --> 'Bitmap Index Scan' и 500 милисекунд на запрос














--
