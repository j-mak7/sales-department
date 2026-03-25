--3
WITH prod_stat AS(
	SELECT 	ip.article_number,
			COUNT(DISTINCT ip.id_invoice) AS invoice_quantity,
			SUM(ip.quantity) AS total_quantity, 
			SUM(CASE WHEN i.payment_stamp = TRUE AND i.cancell_stamp = FALSE THEN i.total_quantity ELSE 0 END) AS q_payment,
			SUM(CASE WHEN i.payment_stamp = FALSE AND i.cancell_stamp = TRUE THEN i.total_quantity ELSE 0 END) AS q_not_payment
	FROM invoice_pos as ip
	JOIN invoice i ON ip.id_invoice = i.id_invoice
	GROUP BY ip.article_number
)
SELECT	p.article_number,
		p.name_product,
		p.name_manufacture,
		p.stock_quantity,
		ps.invoice_quantity AS invoice_quantity,
		COALESCE(ps.total_quantity, 0) AS total_quantity,
		COALESCE(ps.q_payment, 0) AS q_payment,
		COALESCE(ps.q_not_payment, 0) AS q_not_payment
FROM product p
LEFT JOIN prod_stat ps ON p.article_number = ps.article_number
WHERE ps.total_quantity IS NOT NULL
ORDER BY ps.total_quantity DESC;

--4 запрос
WITH course AS (
	SELECT DISTINCT ON (id_unit) id_unit, rate_value
	FROM course_money_unit
	ORDER BY id_unit, date_course DESC
),
change_price AS (
	SELECT i.id_invoice, ip.article_number, i.date_register,
	ip.quantity,
	ip.price,
	ip.price - COALESCE(LAG(ip.price, 1) OVER 
	(PARTITION BY ip.article_number ORDER BY i.date_register, i.id_invoice), ip.price) AS diff,
	i.payment_stamp,
	i.cancell_stamp, 
	i.id_unit
	FROM invoice i
	JOIN invoice_pos ip ON i.id_invoice = ip.id_invoice
	WHERE i.date_register >= CURRENT_DATE - INTERVAL '1 month'
),
const_price AS (
	SELECT article_number,
	id_unit,
	MAX(price) AS current_price,
	COUNT(DISTINCT id_invoice) AS quantity_invoice,
	SUM(quantity) AS sum_quantity,
	SUM(CASE WHEN payment_stamp = TRUE AND cancell_stamp = FALSE THEN quantity ELSE 0 END) AS q_payment,
	SUM(CASE WHEN payment_stamp = FALSE OR cancell_stamp = TRUE THEN quantity ELSE 0 END) AS q_not_payment
	FROM change_price
	GROUP BY article_number, id_unit
	HAVING SUM(diff) = 0
)
SELECT	p.article_number, p.name_product, p.name_manufacture, p.stock_quantity, mu.name_unit, 
		cp.current_price,
		(cp.current_price * COALESCE(c.rate_value, 1)) AS price_rub,
		cp.quantity_invoice,
    	cp.sum_quantity,
    	cp.q_payment,
    	cp.q_not_payment
FROM product p
JOIN const_price cp ON p.article_number = cp.article_number
-- JOIN invoice_pos ip ON ip.article_number = p.article_number
-- JOIN invoice i ON i.id_invoice = ip.id_invoice
JOIN money_unit mu ON cp.id_unit = mu.id_unit
LEFT JOIN course c ON mu.id_unit = c.id_unit
-- WHERE i.date_register >= CURRENT_DATE - INTERVAL '1 month'
-- GROUP BY p.article_number, p.name_product, p.name_manufacture, p.stock_quantity, mu.name_unit, c.rate_value
-- HAVING cp.change_price = 0;
ORDER BY p.article_number;


-- 5
WITH table_months AS (
    SELECT m AS id_month 
    FROM generate_series(1, 12) AS m
),
prod_per_month AS (
	SELECT 	p.name_product, p.article_number, EXTRACT (MONTH FROM i.date_payment) AS month_payment,
			SUM (ip.quantity) AS total_quantity,
			SUM(ip.price * ip.quantity) AS sum_sales,
			ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM i.date_payment) ORDER BY SUM (ip.quantity) DESC
        ) AS popularity_rank,
			ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM i.date_payment) ORDER BY SUM(ip.price * ip.quantity) DESC
        ) AS income_rank
	FROM product p
	JOIN invoice_pos ip ON ip.article_number = p.article_number
	JOIN invoice i ON ip.id_invoice = i.id_invoice
	WHERE EXTRACT(YEAR FROM i.date_payment) = 2025
      AND i.payment_stamp = TRUE
	GROUP BY p.name_product, p.article_number, month_payment
),
sum_per_month AS (
	SELECT month_payment,
		MAX(CASE WHEN ppm.popularity_rank = 1 THEN ppm.name_product END) AS name_popular_product,
		MAX(CASE WHEN ppm.popularity_rank = 1 THEN ppm.total_quantity END) AS q_popular_product,
		MAX(CASE WHEN ppm.popularity_rank = 1 THEN ppm.sum_sales END) AS sum_popular_product,
		MAX(CASE WHEN ppm.income_rank = 1 THEN ppm.name_product END) AS name_income_product,
		MAX(CASE WHEN ppm.income_rank = 1 THEN ppm.total_quantity END) AS q_income_product,
		MAX(CASE WHEN ppm.income_rank = 1 THEN ppm.sum_sales END) AS sum_income_product,
        SUM(ppm.sum_sales) AS month_sales,
		SUM(ppm.total_quantity) AS total_quantity,
		COUNT(DISTINCT ppm.article_number) AS q_diff_prod
	FROM prod_per_month ppm
    GROUP BY month_payment
)
SELECT tm.id_month,
	TO_CHAR(TO_DATE(tm.id_month::text, 'MM'), 'Month') AS month_name,
	spm.name_popular_product,
	spm.q_popular_product,
	spm.sum_popular_product,
	spm.name_income_product,
	spm.q_income_product,
	spm.sum_income_product,
	CASE 
        WHEN spm.month_payment IS NULL THEN 0 
        ELSE SUM(spm.month_sales) OVER (
            ORDER BY tm.id_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) 
    END AS sales_year_start,
	spm.total_quantity,
	spm.q_diff_prod
FROM table_months tm
LEFT JOIN sum_per_month spm ON tm.id_month = spm.month_payment
--GROUP BY ppm.month_payment, spm.total_quantity, spm.month_sales, spm.q_diff_prod
ORDER BY tm.id_month;
--1
WITH invoice_stat AS (
	SELECT i.id_invoice, i.id_buyer,
	SUM (ip.quantity * ip.price * COALESCE(c.rate_value, 1)) AS summa,
	SUM (ip.quantity) AS quantity
	FROM invoice i
	--JOIN buyer b ON i.id_buyer = b.id_buyer
	JOIN invoice_pos ip ON i.id_invoice = ip.id_invoice
	LEFT JOIN course_money_unit c ON i.id_unit = c.id_unit AND i.date_register = c.date_course
	--JOIN payment_invoice pi ON i.id_invoice = pi.id_invoice
	--JOIN vpp ON vpp.num_vpp = pi.num_vpp
	GROUP BY i.id_invoice, i.id_buyer
),
sum_per_invoice AS (
SELECT pi.id_invoice, 
		SUM (vpp.summa) AS real_sum
		FROM payment_invoice pi
		JOIN vpp ON pi.num_vpp = vpp.num_vpp
		GROUP BY pi.id_invoice
)
SELECT b.id_buyer, b.name_comp, 
	COUNT (DISTINCT a.id_account) AS q_account,
	COUNT (DISTINCT i.id_invoice) AS q_invoice,
	SUM (ist.quantity) AS q_product,
	SUM (ist.summa) AS sum_product,
	COUNT(DISTINCT pi.id_invoice) AS q_paid_invoice,
    COUNT(DISTINCT i.id_invoice) FILTER (WHERE pi.id_invoice IS NULL AND i.cancell_stamp = FALSE) AS q_unpaid_invoice,
    COUNT(DISTINCT i.id_invoice) FILTER (WHERE i.cancell_stamp = TRUE) AS q_cancell_invoice,
	COALESCE(SUM(ist.quantity) FILTER (WHERE i.payment_stamp = FALSE), 0) AS q_prod_not_payment,
	COALESCE(SUM(ist.summa) FILTER (WHERE i.payment_stamp = FALSE), 0) AS sum_prod_not_payment,
	COALESCE(SUM(spi.real_sum), 0) AS fact_sum
FROM buyer b
LEFT JOIN account a ON b.id_buyer = a.id_buyer
LEFT JOIN invoice i ON b.id_buyer = i.id_buyer
JOIN invoice_stat ist ON i.id_invoice = ist.id_invoice
LEFT JOIN sum_per_invoice spi ON i.id_invoice = spi.id_invoice
LEFT JOIN payment_invoice pi ON i.id_invoice = pi.id_invoice
GROUP BY b.id_buyer, b.name_comp;

--2
WITH count_invoice AS (
SELECT b.id_buyer, b.name_comp,
	COUNT (DISTINCT i.id_invoice) AS q_invoice,
	COUNT(DISTINCT i.id_invoice) FILTER (WHERE i.payment_stamp = TRUE) AS q_paid_invoice,
    COUNT(DISTINCT i.id_invoice) FILTER (WHERE i.cancell_stamp = TRUE) AS q_cancell_invoice
	FROM buyer b
	LEFT JOIN invoice i ON b.id_buyer = i.id_buyer
	LEFT JOIN payment_invoice pi ON i.id_invoice = pi.id_invoice
	GROUP BY b.id_buyer, b.name_comp
),
count_percent AS (
	SELECT *,
	(q_invoice / AVG(q_invoice) OVER() * 100) AS percent_excess
	FROM count_invoice
)
SELECT *
FROM count_percent
WHERE percent_excess > 100;







