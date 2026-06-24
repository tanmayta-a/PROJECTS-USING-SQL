-------------- Create All Table Schema -----------------------

Drop Table if Exists stores; 
Create Table stores (
	store_id Varchar(5) Primary Key,
	store_name Varchar(50),
	city Varchar(30),
	country Varchar(30)
);

Drop Table if Exists category;
Create Table category(
	category_id Varchar(6) Primary Key,
	category_name Varchar(50)
);

Drop Table if Exists products;
Create Table products(
	product_id Varchar(5) Primary Key,
	product_name Varchar(200),
	category_id Varchar(6),
	launch_date date,
	price float,
	CONSTRAINT fk_category Foreign key (category_id) References category(category_id)
);

Drop Table if Exists sales;
Create Table sales(
	sale_id Varchar(20) Primary Key,
	sale_date Date,
	store_id Varchar(5),
	product_id Varchar(5),
	quantity int,
	CONSTRAINT fk_store Foreign key (store_id) References stores(store_id),
	CONSTRAINT fk_product Foreign key (product_id) References products(product_id)
);

Drop Table if Exists warranty;
Create Table warranty(
	claim_id Varchar(20) Primary Key,
	claim_date Date,
	sale_id Varchar(20),
	repair_status Varchar(20),
	CONSTRAINT fk_sales Foreign key (sale_id) References sales(sale_id)
);
-- EDA :
-- Improving Query Performance

  Create Index sales_store_id On sales(store_id);
  Create Index sales_product_id On sales(product_id);
  Create Index sales_sale_date On sales(sale_date);  

-- et : 99 ms
-- et after creating index : 10 - 15 ms
   Explain Analyze
   Select * from sales
   Where store_id = 'ST-63';
   
-- et : 121 ms
-- et after creating index : 10 - 15 ms
   Explain Analyze
   Select * from sales
   Where product_id = 'P-38';

-- et : 56 ms
-- et after creating index : 1 ms
   Explain Analyze
   Select * from sales
   Where sale_date = '13-04-2022';





















