--                                 Методы анализа запросов и планировщика запросов

-- Если у нас есть проблема с производительностью, в принципе нужно понять в чем она.
-- Перед тем как построить новый индекс нужно понять какой именно это будет индекс, или какие есть проблемы с уже существующими индексами, чтобы перестроить их или запросы.



--                                          EXPLAIN. Планировщик запросов.

-- EXPLAIN - команда и аналитический инструмент, выводится план выполнения запроса(оценку планировщика) без выполнения самого запроса где будет написано каким образом он выполняется, виды сканирования по которым он производится. Так же выдаст инфу про то какие cost/цены предположительно возникают. Сам запрос реально выполняться не будет, так что не стоит волноваться о запросах выполняющихся долго. Оценка планировщика не всегда может достаточно точно отражать реальность, а гдето и совсем не точно
EXPLAIN query; -- query - например SELECT-запрос, тоесть просто ставим команду перед необходимым запросом и запускаем.
EXPLAIN table_name; -- так же можно применить ко всей таблице

-- Пример:
EXPLAIN
SELECT * FROM film;
-- => Seq Scan on film (cost=0.00..64.00 rows=1000 width=384)
-- Seq Scan          - значит просто чтение всех строк
-- cost=0.00..64.00  - cost/цена
-- rows=1000         - число строк в результате запроса
-- width=384         - объем ??использованной?? памяти

-- cost/цена - это некая мера, в которой планировщик запросов считает эффективность всех возможных планов выполнения запроса и выбирает план с наименьшей ценой/стоимостью, тоесть тот что будет выполнен быстрее. Это догадка планировщика о том как долго будет исполняться некий стэйтмент/утверждение в запросе, по сумме затрат по работе с диском или процессором
-- На цену влияет например скорость чтения с диска и если мы используем HDD(механический жеский диск с вращающимися элементами и головкой) то 1 чтение с диска заниманьт относительно большое время, а если SSD то чтение с диска занимет меньше времени. В настройках PostgreSQL можно выставить стоимость для одного чтения с диска и соответсвенно если у нас HDD то ставим ее побольше, а если SSD то поменьше и планировщик будет учитовать это(стоимость одной операции чтения) при построении плана запроса.



--                                                ANALYZE

-- ANALYZE - исполняет запрос и выводит информацию об этом
ANALYZE query;

-- После запуска ANALYZE запросы могут работать быстрее (изза кэширования)

ANALYZE [table_name [(column1, column2...)]] -- тоесть можно дополнительно задавть отдельные таблицы и их колонки
-- собирает статистику по данным таблицы, помещает результаты в pg_statistic таблицу
-- планировщик смотрит на статистику при построении плана

-- Стоит запускать как минимум раз в день, чем больше обновлений данных, тем чаще надо запускать
-- Autovacuum (если включен) в том числе запускает и ANALYZE



--                                              EXPLAIN ANALYZE

-- EXPLAIN ANALYZE - команда и проводит анализ и прогоняет сам запрос и показывает результат и плана и реального примера для более точной и полной инфы
EXPLAIN ANALYZE query;

-- Пример:
EXPLAIN ANALYZE
SELECT * FROM film WHERE length > 120;
-- => Seq Scan on film (cost=0.00..66.50 rows=456 width=384) (actual time=0.020..0.662 rows=457 loops=1)
-- =>   Filter (length > 120)
-- =>   Rows Removed by Filter: 543
-- => Planning Time: 0.148 ms
-- => Execution Time: 0.738 ms
-- actual time=0.020..0.662 - реальное время выполнение шага
-- loops=1                  - число проходов по таблице
-- Planning Time            - запланированное время выполнение запроса
-- Execution Time           - реальное время выполнения данного запроса, может немного отличаться даже при одном и том же запросе














--
