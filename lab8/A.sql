-- non-repeatable read
BEGIN;
SELECT price FROM invoice_pos WHERE id_invoice = 2 AND article_number = 2;
SELECT price FROM invoice_pos WHERE id_invoice = 2 AND article_number = 2;
COMMIT;

-- phantom read
BEGIN; 
SELECT count(*) FROM invoice_pos WHERE price > 10000;
SELECT count(*) FROM invoice_pos WHERE price > 10000;
COMMIT;

-- write skew
BEGIN;
SELECT * FROM product WHERE article_number = 100;
UPDATE product SET stock_quantity = stock_quantity - 25 WHERE article_number = 100;
COMMIT;

-- SELECT * FROM invoice_pos WHERE id_invoice = 105 AND article_number = 100;
-- SELECT * FROM invoice WHERE id_invoice = 105;
-- SELECT * FROM product WHERE article_number = 100;

-- UPDATE product SET stock_quantity = stock_quantity - 5 WHERE article_number = 100;
-- SELECT * FROM product WHERE article_number = 100;

-- savepoint
BEGIN;
INSERT INTO money_unit (name_unit, country_unit, information) 
VALUES ('AUD', 'AU', 'Австралийский доллар');
SAVEPOINT point1;
INSERT INTO money_unit (name_unit, country_unit, information) 
VALUES ('dkk', 'DK', 'Датская крона');
ROLLBACK TO point1;
INSERT INTO money_unit (name_unit, country_unit, information) 
VALUES ('ZAR', 'ZA', 'Южноафриканский ранд');
COMMIT;


SELECT * FROM money_unit;

SELECT * FROM invoice_pos WHERE id_invoice = 102; 

SELECT * FROM product WHERE article_number = 100


BEGIN;
SELECT * FROM product WHERE article_number = 100;
UPDATE product SET stock_quantity = stock_quantity - 25 WHERE article_number = 100;
COMMIT;





-- write skew
BEGIN;
CALL release_invoice(104);
COMMIT;


-- INSERT INTO product (name_product, q_certificate_number, package, name_manufacture, stock_quantity, merchandiser, price)
-- VALUES 
-- ('Ноутбук Dell', 'CERT-001', true, 'Dell', 10, 'ivanov_m', 1000.00),
-- ('Мышь Logitech', 'CERT-002', true, 'Logitech', 10, 'ivanov_m', 50.00);
-- write skew
BEGIN;
SELECT * FROM product WHERE merchandiser = 'ivanov_m';
UPDATE product SET stock_quntity = stock_quantity - 10 WHERE merchandiser = 'ivanov_m' AND name_product = 'Ноутбук Dell';
COMMIT;