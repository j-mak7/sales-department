DROP TRIGGER IF EXISTS trg_account_role ON account;
DROP TRIGGER IF EXISTS trg_vpp_role ON vpp;
DROP TRIGGER IF EXISTS trg_product_role ON product;
DROP TRIGGER IF EXISTS trg_invoice_role ON invoice;
DROP TRIGGER IF EXISTS trg_receipt_document_role ON receipt_document;
DROP TRIGGER IF EXISTS trg_doc_write_off_role ON doc_write_off;
DROP TRIGGER IF EXISTS trg_invoice ON invoice;

--1
CREATE OR REPLACE FUNCTION check_empoloyees()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
	v_login VARCHAR(50);
	name_role VARCHAR(50);
	opp_roles TEXT[];
BEGIN
	IF TG_TABLE_NAME = 'account' THEN
		v_login := NEW.info_accountant;
		opp_roles := '{Бухгалтер, Заведующий}';
	ELSIF TG_TABLE_NAME = 'vpp' THEN
		v_login := NEW.login;
		opp_roles := '{Бухгалтер, Заведующий}';
	ELSIF TG_TABLE_NAME = 'product' THEN
		v_login := NEW.merchandiser;
		opp_roles := '{Товаровед, Заведующий}';
	ELSIF TG_TABLE_NAME = 'invoice' THEN
		v_login := NEW.login;
		opp_roles := '{Менеджер, Заведующий}';
	ELSIF TG_TABLE_NAME = 'receipt_document' THEN
		v_login := NEW.merchandiser;
		opp_roles := '{Товаровед, Заведующий}';
	ELSIF TG_TABLE_NAME = 'doc_write_off' THEN
		v_login := NEW.merchandiser;
		opp_roles := '{Товаровед, Заведующий}';
	ELSE
		RETURN NEW;
	END IF;
	SELECT p.name_post INTO name_role
	FROM employee e
	JOIN post p ON e.code_post = p.code_post
	WHERE e.login = v_login;
	IF NOT (name_role = ANY(opp_roles)) THEN 
		RAISE EXCEPTION 'Операция запрещена для роли "%". Допустимы: %', name_role, opp_roles;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER trg_account_role
    BEFORE INSERT OR UPDATE ON account
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

CREATE TRIGGER trg_vpp_role
    BEFORE INSERT OR UPDATE ON vpp
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

CREATE TRIGGER trg_product_role
    BEFORE INSERT OR UPDATE ON product
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

CREATE TRIGGER trg_invoice_role
    BEFORE INSERT OR UPDATE ON invoice
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

CREATE TRIGGER trg_receipt_document_role
    BEFORE INSERT OR UPDATE ON receipt_document
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

CREATE TRIGGER trg_doc_write_off_role
    BEFORE INSERT OR UPDATE ON doc_write_off
    FOR EACH ROW EXECUTE FUNCTION check_empoloyees();

--2
CREATE OR REPLACE FUNCTION invoice_operation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE count_product RECORD;
BEGIN
	IF OLD.release_stamp = TRUE THEN
		RAISE EXCEPTION 'Нельзя изменить эту накладную. Она уже проведена';
	END IF;
	IF NEW.release_stamp = TRUE AND OLD.release_stamp = FALSE THEN
		FOR count_product IN
			SELECT p.name_product, p.stock_quantity, p.article_number, ip.quantity
			FROM invoice_pos ip
			JOIN product p ON p.article_number = ip.article_number
			WHERE ip.id_invoice = NEW.id_invoice
			LOOP
				IF count_product.stock_quantity < count_product.quantity THEN
					RAISE EXCEPTION 'Недостаточное количество продукта: "%". Не хватает % единиц', 
					count_product.name_product, count_product.quantity - count_product.stock_quantity;
				ELSE
					UPDATE product
					SET stock_quantity = stock_quantity - count_product.quantity
					WHERE article_number = count_product.article_number;
				END IF;
			END LOOP;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER trg_invoice
BEFORE UPDATE ON invoice
FOR EACH ROW EXECUTE FUNCTION invoice_operation();

