-- Нормализация — это процесс удаления избыточности данных из базы данных. Сокращение дублированных данных означает меньшую вероятность несоответствий и большую гибкость.
-- Нормальные формы — это этапы, между которыми из таблицы удаляются различные формы избыточности данных. Для того чтобы высшая нормальная форма была удовлетворена, все низшие нормальные формы также должны быть удовлетворены.
-- Первая нормальная форма (1NF)
-- Для достижения первой нормальной формы (1NF) каждый столбец в таблице должен быть атомарным, т. е. он не может содержать набор значений.


-- PARTITION BY (??)  Запрос ниже аналог GROUP BY по полю supplier_id
SELECT DISTINCT supplier_id, COUNT(*) OVER (PARTITION BY supplier_id) total_products FROM products