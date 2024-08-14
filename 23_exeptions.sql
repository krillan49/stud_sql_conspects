--                                        Ошибки их обработка в PostgreSQL

-- Exceptions - исключения, они доступны только в PL/pgSQL-функциях

-- Например в функцию пришел некорректный параметр, можно вернуть NULL, а можно сгенерировать исключение, чтобы, прервать выполнение функции и соотв транзакции и привлечь внимание к ошибке.

-- Лучше во избежание деградации производительности не слищком плодить исключения, а применять их только тогда, когда ошибка явно критическая, например когда передают 12-значный номер счета, а нужен 11-значный



--                                         Синтаксис вызова ошибок
RAISE [level] 'message (%)', arg_name;
-- RAISE  - ключевое слово, при помощи которого выбрасывается сообщения/ошибки или исключения
-- level  - уровень серьезности ошибки, далее уровни по возрастанию:
DEBUG -- отладка
LOG -- лог
INFO -- информация
NOTICE -- замечание
WARNING -- потенциальная опасность
EXCEPTION -- исключение/ошибка. Абортирует/откачивает(роллбек) текущую транзакцию (и функцию естественно)
-- 'message (%)'  - сообщение с описанием ошибки, где % это точка интерполяции для следующей далее переменной
-- arg_name - значение например проверяемого аргумента функции

log_min_messages -- параметр конфигурации сервера, регулирует уровень сообщений, которые будут писаться в логе сервера (WARNING и EXCEPTION - по умолчанию)
client_min_messages -- регулирует уровень сообщений, которые будут передаваться вызывающей стороне (NOTICE - по умолчанию)

USING -- ключевое слово присоединяющее параметры, например:
RAISE 'invalid binding number=%', number USING HINT='Check out the binding number' ERRCODE='12881'

-- наиболее важные параметры, которые можно присоединить:
HINT -- сообщение с подсказкой
ERRCODE -- номер ошибки, по нему удобно отлавливать эту конкретную ошибку для ее обработки



--                                      Синтаксис отлова исключений

-- EXCEPTION WHEN - блок для поимки и обработки исключений
EXCEPTION WHEN condition [others] THEN handling_logic
-- condition  - условие (пишем например номер ERRCODE), если вычисляется в true, то блок кода обработки после THEN будет выполнен

-- Код в блоке EXCEPTION теряет в производительности, потому без серьезных причин лучше не плодить исключения



--                                             Пример вызова ошибки

-- Есть функция принимает номер месяца и возвращает сезон. И если из оператора ей передать несуществующий месяц больше 12 или меньше 1, то все равно вернет зиму, тк она в ELSE, а если исправим на ELSIF, то вернет NULL, тк переменная так и не определит значение
CREATE OR REPLACE FUNCTION get_season(month_number int) RETURNS text AS $$
DECLARE
	season text;
BEGIN
  -- Чтобы предотвратить неправильный ввод, сделаем проверку вводимого значения и вызовем исключение
	IF month_number NOT BETWEEN 1 and 12 THEN
		RAISE EXCEPTION 'Invalid month. You passed:(%)', month_number USING HINT='Allowed from 1 up to 12', ERRCODE=12882;
	END IF;
  -- Основной код функции:
	IF month_number BETWEEN 3 and 5 THEN
		season = 'Spring';
	ELSIF month_number BETWEEN 6 and 8 THEN
		season = 'Summer';
	ELSIF month_number BETWEEN 9 and 11 THEN
		season = 'Autumn';
	ELSE
		season = 'Winter';
	END IF;
	RETURN season;
END;
$$ LANGUAGE plpgsql;
-- Оператор с несуществующим номером месяца
SELECT get_season(15);



--                                             Пример обработки ошибки

-- Например есть функция, котороя вызывает нашу функцию выше get_season (с вызовом ошибки).
CREATE OR REPLACE FUNCTION get_season_caller1(month_number int) RETURNS text AS $$
DECLARE
  -- переменные для значений из спец переменных GET STACKED DIAGNOSTICS
	err_ctx text;
	err_msg text;
	err_details text;
	err_code text;
BEGIN
  -- все что делам в блоке BEGIN это возвращаем результат что вернет функция get_season, со значением, которое выбросит исключение
  RETURN get_season(month_number);
EXCEPTION WHEN SQLSTATE '12882' THEN  -- начинаем блок перехвата исключения по коду ошибки
  -- переходим в блок если исключение отловлен:

  -- GET STACKED DIAGNOSTICS - может получить дополнительные данные о пойманной ошибке при помощи специальных переменных присвоенных в наши переменные
  GET STACKED DIAGNOSTICS
    err_ctx = PG_EXCEPTION_CONTEXT,
    err_msg = MESSAGE_TEXT,
    err_details = PG_EXCEPTION_DETAIL,
    err_code = RETURNED_SQLSTATE;

  -- Вызовем просто сообщения(тут со значениями из спец переменных) и потом вернем NULL
	RAISE INFO 'My custom handler:';
  RAISE INFO 'Error msg:%', err_msg;
  RAISE INFO 'Error details:%', err_details;
	RAISE INFO 'Error code:%', err_code;
	RAISE INFO 'Error context:%', err_ctx;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
-- Теперь оператор на вернет NULL и покажет все заданные сообщения
SELECT get_season_caller1(15);


-- Пример с несколькими блоками отлова
CREATE OR REPLACE FUNCTION get_season_caller2(month_number int) RETURNS text AS $$
BEGIN
  RETURN get_season(month_number);
EXCEPTION
WHEN SQLSTATE '12882' THEN
	RAISE INFO 'My custom handler:';
  RAISE INFO 'Error Name:%', SQLERRM;  -- можно использовать спецпеременные сразу
  RAISE INFO 'Error State:%', SQLSTATE;
	RETURN NULL;
-- Если мы знаем что может быть несколько ошибок то можем прописать несколько блоков WHEN:
WHEN OTHERS THEN -- тут при помощи OTHERS ловим все остальные ошибки
  RAISE INFO 'My custom handler others:';
  RAISE INFO 'Error Name:%', SQLERRM;
  RAISE INFO 'Error State:%', SQLSTATE;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
SELECT get_season_caller2(15);

















--
