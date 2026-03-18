import psycopg2
from faker import Faker
import logging
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os

class DatabaseFiller:
    def __init__(self, db_config):
        self.fake = Faker('ru_RU')
        self.db_config = db_config
        self.conn = None 
        self.bank_ids = []
        self.buyer_ids = []
        self.unit_ids = []
        self.product_article = []
        self.invoice_ids = []
        self.merchandiser_logins = []
        self.manager_logins = []
        self.accountant_logins = []
        self.account_ids = []
        self.vpp_numbers = []
        self.receipt_document_ids = []
        self.doc_write_off_ids = []
        self.invoice_pos = [] 
        
    def connect(self):
        self.conn = psycopg2.connect(**self.db_config)
            

    def fill_bank_table(self, count=10):
        cursor = self.conn.cursor()
        for _ in range(count):
            bank_data = (self.fake.company() + " Банк", self.fake.address()[:200], 'Russia', self.fake.numerify('##########'))
            cursor.execute("""
                INSERT INTO bank (name_bank, addr, country, num_lic)
                VALUES (%s, %s, %s, %s) RETURNING id_bank""", bank_data)
            self.bank_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()

    def fill_buyers_table(self, count=15):
        cursor = self.conn.cursor()
        categories = ['store', 'wholesaler', 'service company', 'manufacturing company', 'IT company']
        for _ in range(count):
            buyer_data = (self.fake.company(), 'RU', self.fake.address()[:200], self.fake.numerify('#########'), random.choice(categories))
            cursor.execute("""
                INSERT INTO buyer (name_comp, country, legal_addr, num_lic, category)
                VALUES (%s, %s, %s, %s, %s) RETURNING id_buyer""", buyer_data)
            self.buyer_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()
    
    def fill_money_unit_table(self, count=10):
        cursor = self.conn.cursor()
        cursor.execute("SELECT id_unit FROM money_unit")
        self.unit_ids = [row[0] for row in cursor.fetchall()]
        # currencies = [('RUB', 'Россия', 'Рубль'), ('USD', 'США', 'Доллар'), ('EUR', 'ЕС', 'Евро')]
        # for _ in range(count):
        #     curr = random.choice(currencies)
        #     cursor.execute("""
        #         INSERT INTO money_unit (name_unit, country_unit, information)
        #         VALUES (%s, %s, %s) RETURNING id_unit""", curr)
        #     self.unit_ids.append(cursor.fetchone()[0])
        # self.conn.commit()
        cursor.close()

    def fill_post_table(self):
        cursor = self.conn.cursor()
        posts = ['Товаровед', 'Менеджер', 'Бухгалтер', 'Заведующий']
        for post in posts:            
            cursor.execute("INSERT INTO post (name_post) VALUES (%s)", (post,))
        self.conn.commit()
        cursor.close()

    def fill_employee_table(self, count=20):
        cursor = self.conn.cursor()
        for _ in range(count):
            code_post = random.randint(1, 4)
            login = self.fake.user_name() + str(random.randint(1, 999))
            
            is_male = random.choice([True, False])
            
            if is_male:
                last_name = self.fake.last_name_male()
                first_name = self.fake.first_name_male()
                middle_name = self.fake.middle_name_male()
            else:
                last_name = self.fake.last_name_female()
                first_name = self.fake.first_name_female()
                middle_name = self.fake.middle_name_female()
            
            fio = f"{last_name} {first_name} {middle_name}"

            employee_data = (
                login, 
                code_post, 
                self.fake.individuals_inn(), 
                fio, 
                self.fake.numerify('##########'), 
                self.fake.date_of_birth(minimum_age=20, maximum_age=65),
                is_male, 
                self.fake.phone_number()[:20], 
                self.fake.password(length=8)
            )
            
            cursor.execute("""
                INSERT INTO employee (login, code_post, inn, fio, num_pas, born_date, gender, phone_num, parole)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)""", employee_data)
            
            if code_post == 1: self.merchandiser_logins.append(login)
            if code_post == 2: self.manager_logins.append(login)
            if code_post == 3: self.accountant_logins.append(login)
            
        self.conn.commit()
        cursor.close()
    
    def fill_product_table(self, count=50):
        cursor = self.conn.cursor()
        product_types = [
            ('Ноутбук', 45000, 180000),
            ('Смартфон', 15000, 120000),
            ('Монитор', 12000, 70000),
            ('Клавиатура', 1500, 15000),
            ('Мышь', 800, 10000),
            ('Принтер', 10000, 50000),
            ('SSD накопитель', 3000, 30000),
            ('Видеокарта', 30000, 250000),
            ('Оперативная память', 4000, 20000),
            ('Материнская плата', 8000, 45000),
            ('Блок питания', 5000, 15000),
            ('Наушники', 2000, 40000)
        ]
        
        manufacturers = [
            'HP', 'Dell', 'Lenovo', 'Asus', 'Acer', 'Samsung', 
            'LG', 'MSI', 'Gigabyte', 'Logitech', 'Sony', 'Apple', 'Xiaomi'
        ]
        
        for i in range(count):
            p_type, min_p, max_p = random.choice(product_types)
            brand = random.choice(manufacturers)
            
            product_name = f"{p_type} {brand} {self.fake.word().upper()}-{random.randint(100, 999)}"
            
            product_data = (
                product_name,
                self.fake.numerify('CERT-####-####'),
                random.choice([True, False]),
                brand,
                random.randint(0, 1000),
                random.choice(self.merchandiser_logins),
                round(random.uniform(min_p, max_p), 2)
            )
            
            try:
                cursor.execute("""
                    INSERT INTO product (name_product, q_certificate_number, package, name_manufacture, stock_quantity, merchandiser, price)
                    VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING article_number
                """, product_data)
                self.product_article.append(cursor.fetchone()[0])
            except Exception as e:
                self.conn.rollback()
                continue
                
        self.conn.commit()
        cursor.close()

    def fill_account_table(self, count=20):
        cursor = self.conn.cursor()
        categories = ['savings', 'settlement', 'correspondent', 'deposit', 'credit', 'accumulative', 'nominal']
        for _ in range(count):
            account_data = (
                random.choice(self.bank_ids), random.choice(self.buyer_ids),
                random.choice(self.unit_ids), random.choice(categories),
                random.choice(self.accountant_logins if self.accountant_logins else self.manager_logins) 
            )
            cursor.execute("""
                INSERT INTO account (id_bank, id_buyer, id_unit, category, info_accountant)
                VALUES (%s, %s, %s, %s, %s) RETURNING id_account""", account_data)
            self.account_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()

    def fill_invoice_table(self, count=50):
        cursor = self.conn.cursor()
        today = datetime.now().date()
        for _ in range(count):
            date_reg = today - timedelta(days=random.randint(1, 60))
            invoice_data = (
                random.choice(self.buyer_ids), random.choice(self.unit_ids),
                random.choice(self.manager_logins), date_reg,
                date_reg + timedelta(days=random.randint(1, 10)),
                random.choice([True, False]), False, False, random.randint(1, 1000)
            )
            cursor.execute("""
                INSERT INTO invoice (id_buyer, id_unit, login, date_register, date_payment, payment_stamp, cancell_stamp, release_stamp, total_quantity)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id_invoice""", invoice_data)
            self.invoice_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()
    
    def fill_vpp_table(self, count=50):
        cursor = self.conn.cursor()
        for _ in range(count):
            vpp_num = self.fake.numerify('####################')
            vpp_data = (
                vpp_num, random.choice(self.account_ids), random.choice(self.unit_ids),
                random.choice(self.accountant_logins if self.accountant_logins else self.manager_logins),
                random.randint(1, 1000), random.randint(1, 1000),
                datetime.now().date(), random.uniform(100, 100000)
            )
            cursor.execute("""
                INSERT INTO vpp (num_vpp, id_account, id_unit, login, num_s_depart, num_bank, date_create, summa)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""", vpp_data)
            self.vpp_numbers.append(vpp_num)
        self.conn.commit()
        cursor.close()

    def fill_invoice_pos_table(self, count=100):
        cursor = self.conn.cursor()
        self.invoice_pos = [] 
        
        for _ in range(count):
            inv_id = random.choice(self.invoice_ids)
            art_id = random.choice(self.product_article)
            quantity = random.randint(1, 10)
            
            try:
                cursor.execute("""
                    INSERT INTO invoice_pos (id_invoice, article_number, quantity) 
                    VALUES (%s, %s, %s)
                """, (inv_id, art_id, quantity))
                self.invoice_pos.append((inv_id, art_id))
                
            except psycopg2.Error:
                self.conn.rollback()
                continue
        
        self.conn.commit()
        cursor.close()

    def fill_receipt_document_table(self, count=30):
        cursor = self.conn.cursor()
        for _ in range(count):
            receipt_data = (datetime.now().date(), random.choice(self.merchandiser_logins))
            
            cursor.execute("INSERT INTO receipt_document (date_doc, merchandiser) VALUES (%s, %s) RETURNING id_receipt_document", receipt_data)
            self.receipt_document_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()

    def fill_receipt_document_line_table(self, count=50):
        cursor = self.conn.cursor()
        for _ in range(count):
            pos_data = (random.choice(self.receipt_document_ids), random.choice(self.product_article), random.randint(1, 100))
            try:
                cursor.execute("INSERT INTO receipt_document_line (id_receipt_document, article_number, quantity) VALUES (%s, %s, %s)", pos_data)
            except psycopg2.Error:
                self.conn.rollback()
                continue
        self.conn.commit()
        cursor.close()

    def fill_doc_write_off_table(self, count=30):
        cursor = self.conn.cursor()
        causes = ['Брак', 'Повреждение', 'Утеря']
        for _ in range(count):
            off_data = (datetime.now().date(), random.choice(causes), random.choice(self.merchandiser_logins))
            cursor.execute("INSERT INTO doc_write_off (date_doc, cause, merchandiser) VALUES (%s, %s, %s) RETURNING id_doc_off", off_data)
            self.doc_write_off_ids.append(cursor.fetchone()[0])
        self.conn.commit()
        cursor.close()

    def fill_bonus_manager_table(self, count=20):
        cursor = self.conn.cursor()
        if not self.invoice_pos:
            logging.warning("invoice_pos empty")
            return
        sample_size = min(count, len(self.invoice_pos))
        target_pairs = random.sample(self.invoice_pos, sample_size)

        for inv_id, art_num in target_pairs:
            pos_data = (
                random.choice(self.manager_logins),
                round(random.uniform(500, 5000), 2),
                datetime.now().date(),
                "Бонус за продажу",
                inv_id,
                art_num
            )
            
            try:
                cursor.execute("""
                    INSERT INTO bonus_manager (login, summa, payment_date, information, id_invoice, article_number)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, pos_data)
            except Exception as e:
                self.conn.rollback()
                continue
        
        self.conn.commit()
        cursor.close()

# db_config = {'host': 'localhost', 'database': 'sales_department', 'user': 'postgres', 'password': 'juliamaria'}
load_dotenv()
db_config = {
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}


filler = DatabaseFiller(db_config)
filler.connect()
# filler.fill_post_table()
filler.fill_money_unit_table(5)
filler.fill_bank_table(10)
filler.fill_buyers_table(15)
filler.fill_employee_table(20)
filler.fill_product_table(100) 
filler.fill_account_table(20)
filler.fill_invoice_table(50)
filler.fill_invoice_pos_table(150)
filler.fill_vpp_table(40)
filler.fill_bonus_manager_table(30)
filler.fill_receipt_document_table(20)
filler.fill_receipt_document_line_table(60)
filler.fill_doc_write_off_table(15)

print("Yes")