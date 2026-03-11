DROP TABLE IF EXISTS bonus_manager CASCADE;
DROP TABLE IF EXISTS payment_invoice CASCADE;
DROP TABLE IF EXISTS vpp CASCADE;
DROP TABLE IF EXISTS invoice_pos CASCADE;
DROP TABLE IF EXISTS invoice CASCADE;
DROP TABLE IF EXISTS receipt_document_line CASCADE;
DROP TABLE IF EXISTS receipt_document CASCADE;
DROP TABLE IF EXISTS wr_off_doc_line CASCADE;
DROP TABLE IF EXISTS doc_write_off CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS post CASCADE;
DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS course_money_unit CASCADE;
DROP TABLE IF EXISTS money_unit CASCADE;
DROP TABLE IF EXISTS buyer CASCADE;
DROP TABLE IF EXISTS bank CASCADE;

DROP TYPE IF EXISTS buyer_category CASCADE;
DROP TYPE IF EXISTS account_category CASCADE;

CREATE TABLE bank (
	id_bank bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name_bank VARCHAR(50) NOT NULL UNIQUE,
	addr VARCHAR(200) NOT NULL,
	country VARCHAR(50) NOT NULL,
	num_lic VARCHAR(20) NOT NULL
);

CREATE TYPE buyer_category AS ENUM ('store', 'wholesaler', 'service company', 'manufacturing company', 'IT company');

CREATE TABLE buyer(
	id_buyer bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name_comp VARCHAR(50) NOT NULL UNIQUE,
	country VARCHAR(50) NOT NULL,
	legal_addr VARCHAR(200) NOT NULL,
	num_lic VARCHAR(20) NOT NULL,
	category buyer_category NOT NULL
);

CREATE TYPE account_category AS ENUM ('savings', 'settlement', 
'correspondent', 'deposit', 'credit', 'accumulative', 'nominal');

CREATE TABLE money_unit (
	id_unit bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name_unit CHAR(3) NOT NULL CHECK (name_unit ~ '^[A-Z]{3}$'),
	country_unit VARCHAR(20) NOT NULL,
	information text
);

CREATE TABLE course_money_unit (
	id_course bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_unit bigint NOT NULL,
	date_course date NOT NULL CHECK (date_course <= CURRENT_DATE),
	rate_value DECIMAL(15, 8) NOT NULL CHECK (rate_value > 0),
	CONSTRAINT fk_id_unit
 		FOREIGN KEY (id_unit)
 		REFERENCES money_unit(id_unit)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE,
	CONSTRAINT unique_currency_date UNIQUE (id_unit, date_course)
);

CREATE TABLE account (
	id_account bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_bank bigint NOT NULL,
	id_buyer bigint NOT NULL,
	id_unit bigint NOT NULL,
	category account_category NOT NULL,
	info_accountant VARCHAR(50),

	CONSTRAINT fk_account_bank
 		FOREIGN KEY (id_bank)
 		REFERENCES bank(id_bank)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE,
	CONSTRAINT fk_account_buyer
 		FOREIGN KEY (id_buyer)
 		REFERENCES buyer(id_buyer)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE,
	CONSTRAINT fk_account_moneyunit
 		FOREIGN KEY (id_unit)
 		REFERENCES money_unit(id_unit)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE
);

CREATE TABLE product (
	article_number int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name_product varchar(50) NOT NULL UNIQUE,
	q_certificate_number varchar(50) NOT NULL,
	package bool,
	name_manufacture varchar(50) NOT NULL,
	stock_quantity int NOT NULL CHECK (stock_quantity >= 0),
	merchandiser varchar(50) NOT NULL,
	price decimal(12, 4) NOT NULL CHECK (price > 0)
);

CREATE TABLE doc_write_off(
	id_doc_off bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	date_doc date NOT NULL CHECK (date_doc <= CURRENT_DATE),
	cause varchar(20) NOT NULL,
	merchandiser varchar(50) NOT NULL
);

CREATE TABLE wr_off_doc_line (
	id_doc_off bigint NOT NULL,
	article_number int NOT NULL,
	quantity  int NOT NULL CHECK (quantity  > 0),
	CONSTRAINT pk_doc_off_line PRIMARY KEY (id_doc_off, article_number),
	CONSTRAINT fk_line_doc_off FOREIGN KEY (id_doc_off) REFERENCES doc_write_off(id_doc_off)
	ON DELETE CASCADE
 	ON UPDATE CASCADE,
 	CONSTRAINT fk_line_article_number1 FOREIGN KEY (article_number) REFERENCES product(article_number)
	ON DELETE CASCADE
 	ON UPDATE CASCADE
);

CREATE TABLE receipt_document(
	id_receipt_document bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	date_doc date NOT NULL CHECK (date_doc <= CURRENT_DATE),
	merchandiser varchar(50) NOT NULL
);

CREATE TABLE receipt_document_line (
	id_receipt_document bigint NOT NULL,
	article_number int NOT NULL,
	quantity  int NOT NULL CHECK (quantity  > 0),
	CONSTRAINT pk_receipt_doc_line PRIMARY KEY (id_receipt_document, article_number),
	CONSTRAINT fk_line_receipt_doc FOREIGN KEY (id_receipt_document) REFERENCES receipt_document(id_receipt_document)
	ON DELETE CASCADE
 	ON UPDATE CASCADE,
 	CONSTRAINT fk_line_article_number2 FOREIGN KEY (article_number) REFERENCES product(article_number)
	ON DELETE CASCADE
 	ON UPDATE CASCADE
);

CREATE TABLE post (
	code_post int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name_post varchar(50) NOT NULL UNIQUE
);

CREATE TABLE employee (
	login varchar(50) PRIMARY KEY,
	code_post int NOT NULL,
	inn varchar(12) NOT NULL UNIQUE CHECK (inn ~ '^[0-9]{10,12}$'),
	fio varchar (100) NOT NULL,
	num_pas char(10) NOT NULL UNIQUE CHECK (num_pas ~ '^[0-9]{10}$'),
	born_date date NOT NULL CHECK (born_date < CURRENT_DATE AND born_date > '1900-01-01'),
	gender bool NOT NULL,
	phone_num varchar(20) NOT NULL,
	parole varchar(50) NOT NULL CHECK (LENGTH(parole) >= 6),
	CONSTRAINT fk_employee_post FOREIGN KEY (code_post)
 		REFERENCES post(code_post)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE
);

CREATE TABLE invoice(
	id_invoice bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_buyer bigint NOT NULL,
	id_unit bigint NOT NULL,
	login varchar(50) NOT NULL,
	date_register date NOT NULL CHECK (date_register <= CURRENT_DATE),
	date_payment date NOT NULL CHECK (date_payment >= date_register),
	payment_stamp bool NOT NULL,
	cancell_stamp bool NOT NULL,
	release_stamp bool NOT NULL,
	total_quantity int NOT NULL CHECK (total_quantity > 0),
	CONSTRAINT fk_invoice_employee
 		FOREIGN KEY (login)
 		REFERENCES employee(login)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE,
	CONSTRAINT fk_invoice_buyer
 		FOREIGN KEY (id_buyer)
 		REFERENCES buyer(id_buyer)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE,
	CONSTRAINT fk_invoice_moneyunit
 		FOREIGN KEY (id_unit)
 		REFERENCES money_unit(id_unit)
		ON DELETE RESTRICT
 		ON UPDATE CASCADE
);

CREATE TABLE invoice_pos (
	id_invoice bigint NOT NULL,
	article_number int NOT NULL,
	quantity int NOT NULL CHECK (quantity  > 0),
	CONSTRAINT pk_invoice_pos PRIMARY KEY (id_invoice, article_number),
	CONSTRAINT fk_invoice_pos_invoice FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice)
	ON DELETE CASCADE
 	ON UPDATE CASCADE,
 	CONSTRAINT fk_invoice_pos_product FOREIGN KEY (article_number) REFERENCES product(article_number)
	ON DELETE CASCADE
 	ON UPDATE CASCADE
);

CREATE TABLE vpp (
	num_vpp char(20) PRIMARY KEY,
	id_account bigint NOT NULL,
	id_unit bigint NOT NULL,
	login varchar(50) NOT NULL,
	num_s_depart int NOT NULL,
	num_bank int NOT NULL,
	date_create date NOT NULL CHECK (date_create <= CURRENT_DATE),
	summa decimal(30, 2) NOT NULL CHECK (summa > 0),
	CONSTRAINT fk_vpp_account FOREIGN KEY (id_account) REFERENCES account(id_account)
		ON DELETE CASCADE
 		ON UPDATE CASCADE,
 	CONSTRAINT fk_vpp_unit FOREIGN KEY (id_unit) REFERENCES money_unit(id_unit)
		ON DELETE CASCADE
 		ON UPDATE CASCADE,
	CONSTRAINT fk_vpp_employee FOREIGN KEY (login) REFERENCES employee(login)
		ON DELETE CASCADE
 		ON UPDATE CASCADE
);

CREATE TABLE payment_invoice (
	id_invoice bigint NOT NULL,
	num_vpp char(20) NOT NULL,
	CONSTRAINT pk_payment_invoice PRIMARY KEY (id_invoice, num_vpp),
	CONSTRAINT fk_payment_invoice_invoice FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice)
	ON DELETE CASCADE
 	ON UPDATE CASCADE,
 	CONSTRAINT fk_payment_invoice_vpp FOREIGN KEY (num_vpp) REFERENCES vpp(num_vpp)
	ON DELETE CASCADE
 	ON UPDATE CASCADE
);

CREATE TABLE bonus_manager(
	id_bonus bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	login varchar(50) NOT NULL,
	summa decimal(30, 2) NOT NULL CHECK (summa >= 0),
	payment_date date NOT NULL CHECK (payment_date <= CURRENT_DATE),
 	information text NOT NULL,
 	id_invoice bigint NOT NULL,
	article_number int NOT NULL,
 	CONSTRAINT fk_bonus_invoice_pos FOREIGN KEY (id_invoice, article_number) 
        REFERENCES invoice_pos(id_invoice, article_number)
        ON DELETE CASCADE,
    	UNIQUE(id_invoice, article_number)
 );