--test 1 trigger
--попробуем добавить счет и указать в качестве бухгалтера того, кто является товароведом
INSERT INTO account (id_bank, id_buyer, id_unit, category, info_accountant) VALUES
	(7, 1, 1, 'settlement', 'kozlov_d'),
	(8, 1, 1, 'settlement', 'ivanov_i');
--смотрим, какие должности занимают работники
SELECT em.login, p.name_post
FROM employee em
JOIN post p ON em.code_post = p.code_post
WHERE em.login = 'kozlov_d' OR em.login = 'ivanov_i'
--пробуем добавить счет с работником, который может выполнить эту работу
INSERT INTO account (id_bank, id_buyer, id_unit, category, info_accountant) VALUES
	(9, 1, 1, 'settlement', 'kozlov_d');
--смотрим, что добавилось
SELECT * FROM account;
--пробуем добавить накладную, которую оформил товаровед => получаем ошибку
INSERT INTO invoice (id_buyer, id_unit, login, date_register, date_payment, 
                     payment_stamp, cancell_stamp, release_stamp, total_quantity) VALUES
    (1, 2, 'sidorov_p', CURRENT_DATE, CURRENT_DATE, true, false, false, 3452);
--ничего нет, потому что этот человек не занимает должность менджера или заведующего
SELECT * FROM invoice
WHERE login = 'sidorov_p'
--проверяем какую должность занимает выбранный работник
SELECT em.login, p.name_post
FROM employee em
JOIN post p ON em.code_post = p.code_post
WHERE em.login = 'sidorov_p'
--пробуем обновить уже существующую запись с изменением ответственного работника
--получаем ошибку из-за несоотвествия его должности
UPDATE invoice
SET login = 'sokolov_i'
WHERE id_invoice = 27;
--смотрим, что ничего не изменилось и выводим информацию об ответственном работнике
SELECT i.*, em.code_post, p.name_post 
FROM invoice i
JOIN employee em ON i.login = em.login
JOIN post p ON em.code_post = p.code_post
WHERE id_invoice = 27;

--test 2 trigger
--негативный сценарий того, что не хватает количества товара 
UPDATE invoice
SET release_stamp = TRUE
WHERE id_invoice = 56;
SELECT * FROM invoice WHERE id_invoice = 56;
--позитивный сценарий проведения накладной, количество товара уменьшилось
UPDATE invoice
SET release_stamp = TRUE
WHERE id_invoice = 21;
--смотрим, что изменилось значение release_stamp
SELECT * FROM invoice WHERE id_invoice = 21;
--смотрим, что изменилось количество товара на складе
SELECT p.*, ip.quantity FROM product p
JOIN invoice_pos ip ON p.article_number = ip.article_number
JOIN invoice i ON ip.id_invoice = i.id_invoice
WHERE i.id_invoice = 21

--test 1 procedure
--здесь происходит обновление курса для валюты с id = 4
--потому что на текущую дату у нее есть курс, добавление курса для валюты с id = 2, 
--для остальных валют копируется самый близкий к текущей дате курс
--для валюты с id = 8 нет курса, поэтому будет выведена ошибка и таблица не будет обновлена
CALL add_course(ARRAY[(4, 98.00000000)::currency_rate,(2, 95.20000000)::currency_rate]);
SELECT * FROM course_money_unit;

--test 2 procedure
--нельзя провести накладную, потому что не хватает товара
CALL release_invoice(56);
--товара с id = 93 на складе всего 5, а требуется 7
SELECT p.*, ip.quantity FROM product p
JOIN invoice_pos ip ON p.article_number = ip.article_number
JOIN invoice i ON ip.id_invoice = i.id_invoice
WHERE i.id_invoice = 56

CALL release_invoice(32);
--смотрим, что изменилось значение release_stamp
SELECT * FROM invoice WHERE id_invoice = 32;
--смотрим, что изменилось количество товара на складе
SELECT p.*, ip.quantity FROM product p
JOIN invoice_pos ip ON p.article_number = ip.article_number
JOIN invoice i ON ip.id_invoice = i.id_invoice
WHERE i.id_invoice = 32

