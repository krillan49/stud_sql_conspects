--                                        Встроенные функции - разное [PostgreSQL]

-- https://www.postgresql.org/docs/current/functions-net.html   - функции и операторы для айпи адресов

RANDOM()        --  генерит флоат от 0 до 1
RANDOM()::TEXT  -- сгенерит рандомный текст

MD5('Kroker')        -- функция для шифрования в MD5 возвращает строку шифра
MD5(RANDOM()::TEXT)  -- сгенерить MD5 рандоиного текста
















--
