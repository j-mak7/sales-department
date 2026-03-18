SET client_encoding = 'UTF8';
TRUNCATE TABLE 
    bonus_manager,
    payment_invoice,
    invoice_pos,
    invoice,
    vpp,
    account,
    course_money_unit,
    money_unit,
    receipt_document_line,
    receipt_document,
    wr_off_doc_line,
    doc_write_off,
    product,
    employee,
    post,
    buyer,
    bank
RESTART IDENTITY CASCADE;

INSERT INTO bank (name_bank, addr, country, num_lic) VALUES
    ('Сбербанк', 'ул. Вавилова, 19, Москва', 'RU', '1481'),
    ('ВТБ', 'ул. Покровка, 11, Москва', 'RU', '1000'),
    ('Альфа-Банк', 'пр. Вернадского, 9, Москва', 'RU', '1326'),
    ('Тинькофф', 'ул. Хуторская 2-я, 38А, Москва', 'RU', '2673'),
    ('Газпромбанк', 'ул. Наметкина, 16, Москва', 'RU', '3540');

INSERT INTO buyer (name_comp, country, legal_addr, num_lic, category) VALUES
    ('ООО Ромашка', 'RU', 'г. Москва, ул. Ленина 10', '1234567890', 'store'),
    ('АО ТехноСнаб', 'RU', 'г. Санкт-Петербург, пр. Мира 15', '0987654321', 'wholesaler'),
    ('ИП Петров', 'RU', 'г. Казань, ул. Центральная 5', '5554443332', 'service company'),
    ('ООО АйТи Решения', 'RU', 'г. Новосибирск, пр. Коптюга 4', '7778889990', 'IT company'),
    ('ЗАО ПромСтрой', 'RU', 'г. Екатеринбург, ул. Малышева 8', '1112223334', 'manufacturing company'),
    ('ООО Продукты Плюс', 'RU', 'г. Краснодар, ул. Красная 20', '4445556667', 'store');

INSERT INTO money_unit (name_unit, country_unit, information) VALUES
    ('RUB', 'RU', 'Российский рубль'),
    ('USD', 'US', 'Доллар США'),
    ('EUR', 'EU', 'Евро'),
    ('CNY', 'CN', 'Китайский юань'),
    ('GBP', 'GB', 'Фунт стерлингов'),
    ('JPY', 'JP', 'Японская иена'),
    ('CHF', 'CH', 'Швейцарский франк');

INSERT INTO course_money_unit (id_unit, date_course, rate_value) VALUES
    (1, CURRENT_DATE, 1.00000000),
    (2, CURRENT_DATE, 92.50000000),
    (3, CURRENT_DATE, 99.80000000),
    (4, CURRENT_DATE, 12.75000000), 
    (5, CURRENT_DATE, 116.30000000),
    (6, CURRENT_DATE, 0.62000000),
    (7, CURRENT_DATE, 105.20000000);

INSERT INTO course_money_unit (id_unit, date_course, rate_value) VALUES
    (2, CURRENT_DATE - INTERVAL '7 days', 91.80000000),
    (2, CURRENT_DATE - INTERVAL '30 days', 90.50000000),
    (3, CURRENT_DATE - INTERVAL '7 days', 98.90000000),
    (3, CURRENT_DATE - INTERVAL '30 days', 97.20000000);

INSERT INTO account (id_bank, id_buyer, id_unit, category, info_accountant) VALUES
    (1, 1, 1, 'settlement', 'Основной счет ООО Ромашка'),
    (1, 2, 1, 'settlement', 'Основной счет АО ТехноСнаб'),
    (2, 3, 1, 'settlement', 'Счет ИП Петров'),
    (3, 4, 2, 'settlement', 'Валютный счет ООО АйТи Решения'),
    (1, 5, 1, 'settlement', 'Счет ЗАО ПромСтрой'),
    (2, 6, 1, 'settlement', 'Счет ООО Продукты Плюс'),
    (4, 1, 1, 'savings', 'Депозитный счет ООО Ромашка');

INSERT INTO post (name_post) VALUES
    ('Товаровед'),
    ('Менеджер'),
    ('Бухгалтер'),
    ('Заведующий');

INSERT INTO employee (login, code_post, inn, fio, num_pas, born_date, gender, phone_num, parole) VALUES
    ('ivanov_i', 1, '770112345678', 'Иванов Иван Иванович', '4510123456', '1985-03-15', true, 79161234567, 'pass123'),
    ('petrova_a', 2, '770176543210', 'Петрова Анна Сергеевна', '4510654321', '1990-07-22', false, 79167654321, 'pass456'),
    ('sidorov_p', 1, '770198765432', 'Сидоров Петр Васильевич', '4510987654', '1978-11-10', true, 79169876543, 'admin789'),
    ('smirnova_e', 3, '770111122233', 'Смирнова Елена Викторовна', '4510112233', '1988-12-05', false, 79161112233, 'elena2024'),
    ('kozlov_d', 4, '770144455566', 'Козлов Дмитрий Алексеевич', '4510445566', '1992-09-18', true, 79164445566, 'dima1992'),
    ('morozov_a', 2, '770177788899', 'Морозов Андрей Сергеевич', '4510778899', '1982-04-25', true, 79167778899, 'andrey82'),
    ('volkova_n', 1, '770199988877', 'Волкова Наталья Павловна', '4510998877', '1995-06-30', false, 79169998877, 'natali95'),
    ('sokolov_i', 3, '770155566677', 'Соколов Игорь Владимирович', '4510556677', '1980-01-12', true, 79165556677, 'igor123');

INSERT INTO product (name_product, q_certificate_number, package, 
                     name_manufacture, stock_quantity, merchandiser, price) VALUES
    ('Ноутбук HP Pavilion', 'CERT-2023-001', true, 'HP Inc.', 45, 'ivanov_i', 85000.0000),
    ('Ноутбук Lenovo IdeaPad', 'CERT-2023-002', true, 'Lenovo', 30, 'ivanov_i', 72000.0000),
    ('Мышь Logitech MX Master', 'CERT-2023-042', true, 'Logitech', 150, 'ivanov_i', 6500.0000),
    ('Мышь Logitech M185', 'CERT-2023-043', true, 'Logitech', 200, 'ivanov_i', 1200.0000),
    ('Клавиатура Logitech K120', 'CERT-2023-087', true, 'Logitech', 120, 'sidorov_p', 1800.0000),
    ('Клавиатура Logitech MX Keys', 'CERT-2023-088', true, 'Logitech', 40, 'sidorov_p', 12000.0000),
    ('Монитор Samsung 24"', 'CERT-2023-156', true, 'Samsung', 25, 'volkova_n', 18000.0000),
    ('Монитор Samsung 27"', 'CERT-2023-157', true, 'Samsung', 20, 'volkova_n', 25000.0000),
    ('Принтер HP LaserJet', 'CERT-2023-201', true, 'HP Inc.', 12, 'ivanov_i', 35000.0000),
    ('Принтер Canon PIXMA', 'CERT-2023-202', true, 'Canon', 8, 'ivanov_i', 12000.0000),
    ('SSD Samsung 1TB', 'CERT-2024-001', true, 'Samsung', 100, 'volkova_n', 8000.0000),
    ('SSD WD Blue 500GB', 'CERT-2024-002', true, 'Western Digital', 150, 'volkova_n', 5000.0000),
    ('Оперативная память Kingston 16GB', 'CERT-2024-015', true, 'Kingston', 80, 'volkova_n', 5500.0000),
    ('Видеокарта NVIDIA RTX 4060', 'CERT-2024-032', true, 'NVIDIA', 10, 'ivanov_i', 45000.0000),
    ('Видеокарта NVIDIA RTX 4090', 'CERT-2024-033', true, 'NVIDIA', 3, 'ivanov_i', 150000.0000);

INSERT INTO invoice (id_buyer, id_unit, login, date_register, date_payment, 
                     payment_stamp, cancell_stamp, release_stamp, total_quantity) VALUES
    (1, 1, 'ivanov_i', '2025-02-01', '2025-02-10', true, false, true, 245500),
    (2, 1, 'petrova_a', '2025-02-03', '2025-02-15', true, false, true, 189000),
    (3, 1, 'sidorov_p', '2025-02-05', '2025-02-18', true, false, false, 187500),
    (1, 1, 'ivanov_i', '2025-02-10', '2025-02-20', false, false, false, 324000),
    (4, 2, 'sokolov_i', '2025-02-12', '2025-02-25', true, false, true, 450000),
    (5, 1, 'morozov_a', '2025-02-15', '2025-02-28', false, false, false, 78000),
    (6, 1, 'volkova_n', '2025-02-18', '2025-03-05', false, false, false, 45600),
    (2, 1, 'petrova_a', '2025-02-20', '2025-03-10', false, false, false, 210000);

INSERT INTO invoice_pos (id_invoice, article_number, quantity) VALUES
    (1, 1, 2),
    (1, 3, 3),
    (1, 5, 5),
    (1, 7, 1),
    
    (2, 2, 2),
    (2, 4, 10),
    (2, 9, 1),
    
    (3, 1, 1),
    (3, 8, 1),
    (3, 11, 2),
    (3, 13, 2),
    
    (4, 1, 3),
    (4, 3, 5),
    (4, 6, 2),
    
    (5, 14, 2),
    (5, 15, 1),
    (5, 11, 10),
    
    (6, 4, 30),
    (6, 5, 20),
    
    (7, 4, 20),
    (7, 5, 15),
    
    (8, 1, 2),
    (8, 11, 10),
    (8, 13, 10); 

INSERT INTO vpp (num_vpp, id_account, id_unit, login, num_s_depart, 
                 num_bank, date_create, summa) VALUES
    ('VPP20250201001', 1, 1, 'smirnova_e', 101, 1001, '2025-02-10', 245500.00),
    ('VPP20250203001', 2, 1, 'sokolov_i', 102, 1001, '2025-02-15', 189000.00),
    ('VPP20250205001', 3, 1, 'sokolov_i', 103, 1002, '2025-02-18', 187500.00),
    ('VPP20250212001', 4, 2, 'smirnova_e', 104, 1003, '2025-02-25', 450000.00),
    ('VPP20250201002', 1, 1, 'smirnova_e', 101, 1001, '2025-02-20', 324000.00);

INSERT INTO payment_invoice (id_invoice, num_vpp) VALUES
    (1, 'VPP20250201001'),
    (2, 'VPP20250203001'),
    (3, 'VPP20250205001'),
    (5, 'VPP20250212001'),
    (4, 'VPP20250201002');

INSERT INTO bonus_manager (login, summa, payment_date, information, 
                          id_invoice, article_number) VALUES
    ('morozov_a', 4980.00, '2025-02-28', 'Бонус за продажу ноутбуков и аксессуаров (накл. 1)', 1, 1),
    ('morozov_a', 930.00, '2025-02-28', 'Бонус за продажу мышей MX Master (накл. 1)', 1, 3),
    ('morozov_a', 425.00, '2025-02-28', 'Бонус за продажу клавиатур (накл. 1)', 1, 5),
    ('morozov_a', 175.00, '2025-02-28', 'Бонус за продажу монитора (накл. 1)', 1, 7),
    ('petrova_a', 4260.00, '2025-03-01', 'Бонус за продажу ноутбуков Lenovo (накл. 2)', 2, 2),
    ('petrova_a', 330.00, '2025-03-01', 'Бонус за продажу мышей M185 (накл. 2)', 2, 4),
    ('petrova_a', 1020.00, '2025-03-01', 'Бонус за продажу принтера (накл. 2)', 2, 9),
    ('morozov_a', 2460.00, '2025-03-02', 'Бонус за продажу ноутбука (накл. 3)', 3, 1),
    ('morozov_a', 720.00, '2025-03-02', 'Бонус за продажу монитора (накл. 3)', 3, 8),
    ('morozov_a', 468.00, '2025-03-02', 'Бонус за продажу SSD и памяти (накл. 3)', 3, 11),
    ('morozov_a', 7380.00, '2025-03-03', 'Бонус за продажу ноутбуков (накл. 4)', 4, 1),
    ('petrova_a', 2640.00, '2025-03-05', 'Бонус за продажу видеокарт (накл. 5)', 5, 14),
    ('petrova_a', 4440.00, '2025-03-05', 'Бонус за продажу RTX 4090 (накл. 5)', 5, 15),
    ('petrova_a', 2250.00, '2025-03-05', 'Бонус за продажу SSD (накл. 5)', 5, 11);

INSERT INTO receipt_document (date_doc, merchandiser) VALUES
    ('2025-01-15', 'ivanov_i'),
    ('2025-01-20', 'ivanov_i'),
    ('2025-02-01', 'sidorov_p'),
    ('2025-02-10', 'sidorov_p'),
    ('2025-02-15', 'ivanov_i');

INSERT INTO receipt_document_line (id_receipt_document, article_number, quantity) VALUES
    (1, 1, 20), (1, 2, 15), (1, 3, 30), (1, 4, 50),
    (2, 5, 40), (2, 6, 20), (2, 7, 15), (2, 8, 10),
    (3, 9, 8), (3, 10, 5), (3, 11, 40), (3, 12, 50),
    (4, 13, 30), (4, 14, 8), (4, 15, 2),
    (5, 1, 15), (5, 3, 20), (5, 4, 50);

INSERT INTO doc_write_off (date_doc, cause, merchandiser) VALUES
    ('2025-02-05', 'Брак', 'sidorov_p'),
    ('2025-02-18', 'Истек срок годности', 'sidorov_p'),
    ('2025-02-25', 'Повреждение упаковки', 'ivanov_i'),
    ('2025-03-01', 'Демо-образцы', 'ivanov_i');

INSERT INTO wr_off_doc_line (id_doc_off, article_number, quantity) VALUES
    (1, 4, 2),
    (1, 5, 1),
    (2, 11, 3),
    (3, 3, 1),
    (3, 6, 1),
    (4, 14, 1),
    (4, 15, 1);