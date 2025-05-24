--                                           MERGE (PostgreSQL 15+)

-- https://www.postgresql.org/docs/current/sql-merge.html

-- MERGE - команда, которая объединяет INSERT, UPDATE и DELETE в один запрос. Она позволяет вставлять новые записи или обновлять существующие, в зависимости от условий. Например вставить строку, если она не существует, или обновить её, если уже есть, это похоже на upsert, но сильнее и гибче

-- Преимущества:
-- Всё в одном запросе
-- Читаемо и удобно
-- Нет гонки между SELECT и INSERT

-- Таблица-источник (в USING) - это может быть VALUES, SELECT или другая таблица

-- Обновить цену товара, если он уже есть, или добавить, если его нет:
MERGE INTO products AS p                              -- работаем с таблицей products
USING (VALUES (1, 'Хлеб', 30)) AS v(id, name, price)  -- данные, с которыми сравниваем
ON p.id = v.id                                        -- В ON нужно указать, как сопоставлять строки (тут по ID)
WHEN MATCHED THEN                                     -- если запись найдена то UPDATE
  UPDATE SET price = v.price
WHEN NOT MATCHED THEN                                 -- если запись не найдена то INSERT
  INSERT (id, name, price)
  VALUES (v.id, v.name, v.price);

-- Удаление, если товар устарел:
MERGE INTO products AS p
USING outdated_products AS o -- Если products.id есть в outdated_products, запись удалится
ON p.id = o.id
WHEN MATCHED THEN
  DELETE;



--                                Пример MERGE с одновременными INSERT, UPDATE, DELETE

-- Есть таблица inventory с текущими остатками товаров на складе:
CREATE TABLE inventory (
  product_id     BIGINT PRIMARY KEY,
  warehouse_id   BIGINT,
  stock_quantity INTEGER,
  last_updated   TIMESTAMP
);

-- Мы получаем новые данные об остатках из внешней системы и помещаем их во временную таблицу:
CREATE TEMP TABLE tmp_inventory (
  product_id     BIGINT,
  warehouse_id   BIGINT,
  stock_quantity INTEGER,
  last_updated   TIMESTAMP
);

INSERT INTO tmp_inventory VALUES
  (1, 100, 50, now()),    -- новый товар
  (2, 100, 120, now()),   -- обновление
  (3, 100, 70, now());    -- существующий (оставим как есть)

-- Запрос с MERGE, выполняющий вставку, обновление и удаление:
MERGE INTO inventory AS inv                    -- Целевая таблица
USING tmp_inventory AS tmp                     -- Новые данные - временная таблица
ON inv.product_id = tmp.product_id             -- ON  Определяет, что считается совпадением товара на складе
  AND inv.warehouse_id = tmp.warehouse_id
WHEN MATCHED THEN                              -- Обновляет уже существующий товар
  UPDATE SET
    stock_quantity = tmp.stock_quantity,
    last_updated   = tmp.last_updated
WHEN NOT MATCHED THEN                          -- Вставляет новый товар, если он не существует
  INSERT (product_id, warehouse_id, stock_quantity, last_updated)
  VALUES (tmp.product_id, tmp.warehouse_id, tmp.stock_quantity, tmp.last_updated)
WHEN NOT MATCHED BY SOURCE THEN                -- удаляет строки из inventory, которые не представлены в tmp_inventory
  DELETE;

-- Удаление может быть опасно, если не нужно удалять записи по умолчанию