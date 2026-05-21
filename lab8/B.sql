-- non-repeatable read
BEGIN;
UPDATE invoice_pos SET price = 100 WHERE id_invoice = 2 AND article_number = 2;
COMMIT;

-- phantom read
BEGIN;
INSERT INTO invoice_pos (id_invoice, article_number, quantity, price) VALUES (112, 100, 500, 50000.00);
COMMIT;

SELECT * FROM invoice_pos WHERE id_invoice = 112;

-- write skew
BEGIN;
SELECT * FROM product WHERE article_number = 100;
UPDATE product SET stock_quantity = stock_quantity - 19 WHERE article_number = 100;
COMMIT;



UPDATE product SET stock_quantity = 10 WHERE name_product = 'Принтер Canon PIXMA';
SELECT * FROM product WHERE article_number = 100;




-- write skew
BEGIN;
CALL release_invoice(105);
COMMIT;

-- BEGIN;
-- SELECT SUM(stock_quantity) FROM product WHERE merchandiser = 'ivanov_m';
-- UPDATE product SET stock_quantity = stock_quantity - 10 WHERE name_product = 'Мышь Logitech';
-- COMMIT;