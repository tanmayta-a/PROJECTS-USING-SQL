--AMAZON PROJECT-7 

--CREATING SCHEMAS
--CREATE CATEGORY TABLE

CREATE TABLE CATEGORY(
category_id INT PRIMARY KEY,
category_name VARCHAR(20)
);

--CREATE TABLE CUSTOMER

CREATE TABLE CUSTOMER(
Customer_ID INT primary key,
first_name VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20),
address varchar(5) default ('xxx')
);


--CREATE TABLE SELLER

CREATE TABLE SELLER(
 seller_id int primary key,
 seller_name varchar(20),
 origin varchar(10)
);

--CREATE TABLE PRODUCTS

CREATE TABLE PRODUCTS(
product_id int primary key, 
product_name varchar(50),
price float,
cogs float,
category_id int,
constraint product_fk_category foreign key (category_id)
references category(category_id)
);

--CREATE TABLE ORDER

CREATE TABLE ORDERS(
order_id int  PRIMARY KEY,
order_date date,
customer_id int,--fk
seller_id int,--fk
order_status varchar(20),
CONSTRAINT ORDER_FK_CUSTOMER FOREIGN key (Customer_id) 
references Customer (Customer_id),
constraint order_FK_seller foreign key (seller_id) 
references seller (seller_id)
);
DROP TABLE IF EXISTS ORDERS;

--CREATE TABLE ORDER_ITEMS

CREATE TABLE ORDER_ITEMS(
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
price_per_unit FLOAT,
CONSTRAINT order_items_fk_orders foreign key (order_id)
references orders(order_id),
constraint order_items_fk_products foreign key (product_id) 
references products(product_id)
);
drop table if exists order_items;

--CREATE TABLE PAYMENT 

CREATE TABLE PAYMENT (
payment_id INT,
order_id INT,
payment_date DATE,
payment_status VARCHAR(50),
CONSTRAINT PAYMENT_FK_ORDERS FOREIGN KEY(order_id)
references orders(order_id)
);

--CREATE TABLE SHIPPING

CREATE TABLE SHIPPING(
shipping_id	INT PRIMARY KEY,
order_id INT,
shipping_date DATE,
return_date DATE,
shipping_providers VARCHAR(20),
delivery_status VARCHAR(20),
CONSTRAINT SHIPPING_FK_ORDERS FOREIGN KEY(order_id)
references orders(order_id)
);

--CREATE TABLE INVENTORY

CREATE TABLE INVENTORY(
inventory_id INT PRIMARY KEY,
product_id INT,
stock INT,
warehouse_id INT,
last_stock_date DATE,
constraint INVENTORY_fk_products foreign key (product_id) 
references products(product_id)
);

--END OF SCHEMAS




















