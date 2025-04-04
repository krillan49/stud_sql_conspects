--                                                  DISTINCT

-- DISTINCT - позволяет исключить одинаковые значения(дубликаты) в выводе, тоесть оставить только уникальные

-- DISTINCT исполняется после всех остальных действий, те дубликаты исключаются из результата запроса, соответственно можно провести сортировку (тоесть после сортировки ??), чтобы исключить дубликаты в том порядке в котором необходимо

-- 1. Удаляем дубликаты по полям запроса:
SELECT DISTINCT class FROM Students;             -- выбираем все уникальные значения столбца class, иключив все дубликаты
SELECT DISTINCT first_name, last_name FROM User; -- если в запросе несколько столбцов, исключаются только те строки, в которых значения строк одинаковы в каждом из выбранных стобцов

-- 2. Можно выбирать уникальные значения не только по полям, но и по выражениям
SELECT DISTINCT SUBSTRING(name, 1, 3) FROM acters; -- строки уникальные по 1м 3м буквам имени



--                                           DISTINCT ON [PostgreSQL]

-- DISTINCT ON - исключает дубликаты строк только по выбранным столбцам, а не по всем что описаны в поле SELECT
SELECT DISTINCT ON(team) * FROM employees;          -- выбирает строки по уникальности значения в столбце team

-- Применяя к нескольким столбцам, исключаются только те строки, в которых значения строк одинаковы в каждом из выбранных стобцов
SELECT DISTINCT ON(user_id, video_id) user_id, video_id, some FROM user_playlist;

-- Чтобы получить не случайные уникальные значения(по умолчанию выбирается первое встреченное), а определенные, можно выполнить сортировку, тк DISTINCT работает после сортировки. Обязательно нужно указывать поле по которому ищем уникальные значения первым в блоке сортировки, а потом уже идут поля по которым сортируем
SELECT DISTINCT ON(team) * FROM employees ORDER BY team, birth_date DESC;        -- выбирает уникальные значения по столбцу, из отсортированных по дате, тоесть выбраны уникальные team с самой большой датой из birth_date














--
