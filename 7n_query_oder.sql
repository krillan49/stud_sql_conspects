--                                    Порядок выполнения частей запроса

-- https://www.postgresql.org/docs/current/sql-select.html

-- 1. WITH - Общее табличное выражение отрабатывает в 1ю очередь
-- 2. FROM - выполняется соединение таблиц в результирующий набор
-- 3. WHERE - фильтрация, так что если в предыдущем пункте соединяем огромные таблици, то лучше отфильтровать их до того в отдельном общем табличном выражении
-- 4. GROUP BY - группируем результат
-- 5. HAVING - фильтрация сгруппированных строк
-- 6. SELECT - расчитываем все поля кроме оконных функций
-- 7. SELECT DISTINCT - оставляем только уникальные расчитанные строки
-- 8. ORDER BY - сортируем полученный результат
-- 9. LIMIT и OFFSET - ограничиваем число строк в выводе

-- 1. Общее табличное выражение отрабатывает в 1ю очередь
WITH film_amount AS (
  SELECT
    i.film_id,
    SUM(amount) AS total_amount
  FROM
    inventory i
    JOIN rental r USING (inventory_id)
    JOIN payment p USING (rental_id)
  GROUP BY
    i.film_id
)
-- 6. Расчитываем все поля кроме оконных функций в блоке SELECT
-- 7. Оставляем только уникальные расчитанные строки в SELECT DISTINCT
SELECT DISTINCT
  SUBSTRING(f.title, 1, 3) AS short_title,
  f.rental_duration,
  COUNT(*) OVER(PARTITION BY f.rental_duration) AS rent_dur_film_cnt,
  SUM(fa.total_amount) AS total_amount
-- 2. Выполняется соединение таблиц в результирующий набор блоке FROM
FROM
  film f
  JOIN film_amount fa USING (film_id)
-- 3. Производим фильтрацию в блоке WHERE
WHERE
  f.rating = 'G'
-- 4. Группируем результат в блоке GROUP BY
GROUP BY
  SUBSTRING(f.title, 1, 3),
  f.rental_duration
-- 5. Фильтрация сгруппированных строк в блоке HAVING
HAVING
  COUNT(*) = 1
-- 8. Сортируем полученный результат в блоке ORDER BY
ORDER BY
  total_amount
-- 9. Ограничиваем число строк в выводе при помощи LIMIT и OFFSET
LIMIT 10
OFFSET 5;













--
