DROP PROCEDURE IF EXISTS add_course(currency_rate[]);
DROP PROCEDURE IF EXISTS release_invoice(invoice_id BIGINT);
DROP TYPE IF EXISTS currency_rate CASCADE;

--1 procedure
CREATE TYPE currency_rate AS (
    id_unit BIGINT,
    rate DECIMAL(15,8)
);

CREATE PROCEDURE add_course(rates currency_rate[])
LANGUAGE plpgsql
AS $$
DECLARE
	process_units BIGINT[] := '{}';
	rate currency_rate;
	unit RECORD;
	last_course RECORD;
BEGIN
	FOREACH rate in ARRAY rates LOOP
		IF EXISTS (SELECT 1 FROM course_money_unit WHERE id_unit = rate.id_unit 
			AND date_course = CURRENT_DATE) THEN
			UPDATE course_money_unit
			SET rate_value = rate.rate
			WHERE id_unit = rate.id_unit AND date_course = CURRENT_DATE;
		ELSE 
			INSERT INTO course_money_unit (id_unit, date_course, rate_value) VALUES
				(rate.id_unit, CURRENT_DATE, rate.rate);
		END IF;
		process_units := array_append(process_units, rate.id_unit);
	END LOOP;
	FOR unit IN SELECT id_unit, name_unit FROM money_unit WHERE id_unit <> ALL(process_units)
	LOOP
		SELECT rate_value, date_course INTO last_course FROM course_money_unit
		WHERE id_unit = unit.id_unit
		ORDER BY date_course DESC
		LIMIT 1;
		IF FOUND THEN
			IF last_course.date_course != CURRENT_DATE THEN
				INSERT INTO course_money_unit (id_unit, date_course, rate_value) VALUES 
				(unit.id_unit, CURRENT_DATE, last_course.rate_value);
			END IF;
		ELSE
			RAISE EXCEPTION 'нет курса для конвертации из % в RUB', unit.name_unit;
		END IF;
	END LOOP;
END;
$$;	

--2 procedure
CREATE PROCEDURE release_invoice(invoice_id BIGINT)
LANGUAGE plpgsql
AS $$ 
DECLARE
	one_invoice RECORD;
	str_product RECORD;
BEGIN
	SELECT * INTO one_invoice
	FROM invoice i
	WHERE i.id_invoice = invoice_id;
	IF one_invoice.release_stamp = TRUE THEN
		RAISE EXCEPTION 'Накладная уже проведена';
	END IF;
	FOR str_product IN
		SELECT p.name_product, p.stock_quantity, ip.article_number, ip.quantity
		FROM invoice_pos ip
		JOIN product p ON p.article_number = ip.article_number
		WHERE ip.id_invoice = invoice_id
	LOOP
		IF str_product.stock_quantity < str_product.quantity THEN
			RAISE EXCEPTION 'Нехватка товара: "%". Требуется: %, В наличии: %, Не хватает: %', 
                str_product.name_product, 
                str_product.quantity, 
                str_product.stock_quantity, 
                (str_product.quantity - str_product.stock_quantity);
		END IF;
	END LOOP;

	UPDATE invoice i
	SET release_stamp = TRUE
	WHERE i.id_invoice = invoice_id;
END;
$$;