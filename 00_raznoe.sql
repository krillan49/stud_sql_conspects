-- Нормализация — это процесс удаления избыточности данных из базы данных. Сокращение дублированных данных означает меньшую вероятность несоответствий и большую гибкость.
-- Нормальные формы — это этапы, между которыми из таблицы удаляются различные формы избыточности данных. Для того чтобы высшая нормальная форма была удовлетворена, все низшие нормальные формы также должны быть удовлетворены.
-- Первая нормальная форма (1NF)
-- Для достижения первой нормальной формы (1NF) каждый столбец в таблице должен быть атомарным, т. е. он не может содержать набор значений.


-- PARTITION BY (??)  Запрос ниже аналог GROUP BY по полю supplier_id
SELECT DISTINCT supplier_id, COUNT(*) OVER (PARTITION BY supplier_id) total_products FROM products


-- EVERY   -  аналог ALL ???.  тоесть где все сгруппированные значения соответствуют условию
SELECT customer_id FROM orders GROUP BY customer_id HAVING EVERY(delivery_date IS NULL) ORDER BY 1 DESC;


-- (постгрэ ??) условие с = возвращает true или false
SELECT REVERSE(str) = str AS res FROM ispalindrome -- в столбце res будет true или false в зависимости от того соотв условию или нет
