--                                          Relations / Отношения

-- Отношение один ко многим. В одной из таблиц (многие) есть/добавляется колонка содержащая внешние ключи для каждой записи ссылающиеся на первичный ключ к таблице (один)

-- Отношение один к одному отличается от один ко многим, только тем что для каждой записи в одной таблице есть только одна запись в другой

-- Отношение многие ко многим - всегда моделируется при помщи введения 3й таблицы содержащей не уникальные(тк могут повторяться) ключи для обеих таблиц, но каждая пара(строка) этих ключей уникальна, тоесть первичный ключ состоит из обоих этих ключей. Обычно доп таблица называется именами обоих таблиц через подчеркивание.