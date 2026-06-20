---

# **Amazon USA Sales Analysis Project**


### **Difficulty Level: Advanced**

---

## **Project Overview**
This project focuses on analyzing an Amazon-style e-commerce database using PostgreSQL. The objective is to transform raw transactional data into meaningful business insights by performing data exploration, sales analysis, customer behavior analysis, inventory monitoring, and operational performance tracking.

The database consists of multiple interconnected entities such as customers, products, categories, orders, sellers, payments, shipping records, and inventory. Advanced SQL techniques including joins, Common Table Expressions (CTEs), aggregate functions, window functions, ranking functions, and subqueries were used to solve real-world business problems and generate actionable insights.

## **Business Objectives**
The project aims to answer critical business questions such as:

- Which products generate the highest revenue?
- How much revenue does each product category contribute?
- What is the average spending behavior of customers?
- How are monthly sales trending over time?
- Which customers have never made a purchase?
- Which product categories perform poorly in different states?
- Who are the most valuable customers based on lifetime spending?
- Which products require inventory replenishment?
- How efficiently are orders being shipped and delivered?

---

### **Entity Relationship Diagram (ERD)**

An ERD is included to visually represent the database schema and table relationships.


![ERD Scratch](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-7/ERD)

---
## **Database Setup & Design**

### **Schema Structure**

```sql
--CREATE TABLE CATEGORY

CREATE TABLE CATEGORY(
category_id INT PRIMARY KEY,
category_name VARCHAR(20)
);

-- CREATE TABLE CUSTOMER

CREATE TABLE CUSTOMER(
Customer_ID INT primary key,
first_name VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20),
address varchar(5) default ('xxx')
);

-- CREATE TABLE SELLER

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

-- CREATE TABLE ORDERS

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
```

---
## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---

## **Tools & Technologies**
- PostgreSQL
- SQL
- Relational Database Management System (RDBMS)
- Data Analytics
- Business Intelligence Concepts

## **Solving Business Problems**

### Solutions Implemented:

TASK-1: Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.
```sql
--STEP-1:ADDING COLUMN IN ORDER_ITEMS
alter table order_items
add column total_sales float;

-- STEP-2:UPDATING ORDER_ITEMS
update order_items 
set total_sales=quantity*price_per_unit;

--STEP-3: Preview the order_items table 
select * from order_items order by quantity desc;

-- Step 4: Get top 10 best-selling products by total sales
SELECT
	P.PRODUCT_NAME,
	OI.PRODUCT_ID,
	SUM(OI.TOTAL_SALES) AS TOTAL_SALE,
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS
FROM
	ORDERS AS O
	JOIN ORDER_ITEMS AS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS AS P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	1,
	2
ORDER BY
	3 DESC
LIMIT
	10;
```
TASK-2: Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.

```sql
SELECT
	P.CATEGORY_ID,
	CT.CATEGORY_NAME,
	SUM(OI.TOTAL_SALES) AS TOTAL_SALE,
	SUM(OI.TOTAL_SALES) / (
		SELECT
			SUM(TOTAL_SALES)
		FROM
			ORDER_ITEMS
	) * 100 AS CONTRIBUTION
FROM
	ORDER_ITEMS AS OI
	JOIN PRODUCTS AS P ON OI.PRODUCT_ID = P.PRODUCT_ID
	LEFT JOIN CATEGORY AS CT ON P.CATEGORY_ID = CT.CATEGORY_ID
GROUP BY
	1,
	2
ORDER BY
	3 DESC;
```

--TASK-3:Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.

```sql
-- average order value =  total amount they spent on complete order / how many orders they have done
-- eg- rahul has done 2 orders and in these 2 orders he purchase 5 items and
--  total he give 1000 of these 2 orders. But we do not have to focus on itmes in these 2 orders 
-- so avg rahul spent = 1000 / 2  


SELECT
	C.CUSTOMER_ID,
	CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS FULL_NAME,
	SUM(TOTAL_SALES) / COUNT(O.ORDER_ID) AS AOV,
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS
FROM
	ORDERS AS O
	JOIN CUSTOMER AS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
	JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
GROUP BY
	1,
	2
HAVING
	COUNT(O.ORDER_ID) > 5;

```
TASK-4: Monthly Sales Trend
Query monthly total sales over the last 2  year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!
```sql
--last 2 year sale
--each month -their sales and their prev month sale
--window function lag

WITH
	CTE AS (
		SELECT
			EXTRACT(
				MONTH
				FROM
					O.ORDER_DATE
			) AS MONTH,
			EXTRACT(
				YEAR
				FROM
					O.ORDER_DATE
			) AS YEAR,
			ROUND(SUM(OI.TOTAL_SALES::NUMERIC), 2) AS TOTAL_SALE
		FROM
			ORDERS AS O
			JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
		WHERE
			ORDER_DATE >= CURRENT_DATE - INTERVAL '3 year'
		GROUP BY
			1,
			2
		ORDER BY
			YEAR,
			MONTH
	)
SELECT
	YEAR,
	MONTH,
	TOTAL_SALE AS CURRENT_MONTH_SALE,
	LAG(TOTAL_SALE, 1) OVER (
		ORDER BY
			YEAR,
			MONTH
	) AS LAST_MONTH_SALES
FROM
	CTE;

```

TASK-5: Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.
 ```sql

SELECT * FROM CUSTOMER where customer_id not in (

SELECT  distinct customer_id FROM ORDERS);

SELECT
	*
FROM
	CUSTOMER AS C
	LEFT JOIN ORDERS AS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE
	O.CUSTOMER_ID IS NULL;
```

TASK-6: Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.

```sql
WITH
	RANKING_TABLE AS (
		SELECT
			C.STATE,
			CT.CATEGORY_NAME,
			SUM(OI.TOTAL_SALES) AS TOTAL_SALE,
			RANK() OVER (
				PARTITION BY
					C.STATE
				ORDER BY
					SUM(OI.TOTAL_SALES) ASC
			) AS RANK
		FROM
			ORDERS AS O
			JOIN CUSTOMER AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
			JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
			JOIN PRODUCTS AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
			JOIN CATEGORY AS CT ON CT.CATEGORY_ID = P.CATEGORY_ID
		GROUP BY
			1,
			2
	)
SELECT
	*
FROM
	RANKING_TABLE
WHERE
	RANK = 1;
```

TASK-7: Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.
```sql

SELECT
	C.CUSTOMER_ID,
	CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS FULL_NAME,
	SUM(OI.TOTAL_SALES) AS CLTV,
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
	DENSE_RANK() OVER (
		ORDER BY
			SUM(OI.TOTAL_SALES) DESC
	) AS CX_RANKING
FROM
	ORDERS AS O
	JOIN CUSTOMER AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
	JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
GROUP BY
	1,
	2;
```
TASK-8: Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.
```sql

SELECT
	I.INVENTORY_ID,
	P.PRODUCT_NAME,
	I.STOCK AS CURRENT_STOCK,
	I.LAST_STOCK_DATE,
	I.WAREHOUSE_ID
FROM
	INVENTORY AS I
	JOIN PRODUCTS AS P ON P.PRODUCT_ID = I.PRODUCT_ID
WHERE
	STOCK < 10;
```

TASK-9: Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
```sql
SELECT
	C.*,
	O.*,
	S.SHIPPING_PROVIDERS,
	S.SHIPPING_DATE - O.ORDER_DATE AS DAYS_TOOK_TO_SHIP
FROM
	ORDERS AS O
	JOIN CUSTOMER AS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
	JOIN SHIPPING AS S ON S.ORDER_ID = O.ORDER_ID
WHERE
	S.SHIPPING_DATE - O.ORDER_DATE > 3
```

TASK-10: Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).

```sql
SELECT
	P.PAYMENT_STATUS,
	COUNT(*) AS TOTAL_COUNT,
	ROUND(
		COUNT(*) / (
			SELECT
				COUNT(*)
			FROM
				PAYMENT
		)::NUMERIC * 100,
		2
	)
FROM
	PAYMENT AS P
	JOIN ORDERS AS O ON O.ORDER_ID = P.ORDER_ID
GROUP BY
	1
```

TASK-11: Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.
```sql
	WITH
	TOP_SELLERS AS (
		SELECT
			S.SELLER_ID,
			S.SELLER_NAME,
			SUM(OI.TOTAL_SALES) AS TOTAL_SALE
		FROM
			ORDERS AS O
			JOIN SELLER AS S ON S.SELLER_ID = O.SELLER_ID
			JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
		GROUP BY
			1,
			2
		ORDER BY
			3 DESC
		LIMIT
			5
	),
	SELLER_REPORTS AS (
		SELECT
			O.ORDER_STATUS,
			O.SELLER_ID,
			TS.SELLER_NAME,
			COUNT(*) AS TOTAL_ORDERS
		FROM
			ORDERS AS O
			JOIN TOP_SELLERS AS TS ON TS.SELLER_ID = O.SELLER_ID
		WHERE
			O.ORDER_STATUS NOT IN ('Inprogress', 'Returned')
		GROUP BY
			1,
			2,
			3
	)
SELECT
	SELLER_ID,
	SELLER_NAME,
	SUM(
		CASE
			WHEN ORDER_STATUS = 'Completed' THEN TOTAL_ORDERS
			ELSE 0
		END
	) AS COMPLETED_ORDERS,
	SUM(
		CASE
			WHEN ORDER_STATUS = 'Cancelled' THEN TOTAL_ORDERS
			ELSE 0
		END
	) AS CANCELLED_ORDERS,
	SUM(TOTAL_ORDERS) AS TOTAL_ORDERS,
	SUM(
		CASE
			WHEN ORDER_STATUS = 'Completed' THEN TOTAL_ORDERS
			ELSE 0
		END
	)::NUMERIC / SUM(TOTAL_ORDERS)::NUMERIC * 100 AS SUCCESSFUL_ORDERS
FROM
	SELLER_REPORTS
GROUP BY
	1,
	2;
```

TASK-12: Product Profit Margin
Calculate the profit margin for each product (profit = difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
```sql
--PROFIT=TOTAL_SALES -COGS*QUANTITY
--PROFIT_MARGIN=PROFIT/TOTAL_SALES *100


SELECT product_id,product_name,profit_margin,
DENSE_RANK() OVER(ORDER BY PROFIT_MARGIN DESC) AS RANK
from
(SELECT P.PRODUCT_ID,P.PRODUCT_NAME ,
SUM(OI.TOTAL_SALES-P.COGS*OI.QUANTITY) AS PROFIT,
(SUM(OI.TOTAL_SALES-P.COGS*OI.QUANTITY) /SUM(OI.TOTAL_SALES))*100 AS PROFIT_MARGIN
FROM 
PRODUCTS AS P
JOIN 
ORDER_ITEMS AS OI
ON OI.PRODUCT_ID=P.PRODUCT_ID
GROUP BY 1,2)AS T1;
```

TASK-13: Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.
```sql

-- total units sold =  total no of orders 
--  number of returns = no of times every products returns
--  return_percentage = no of returns / total orders

	SELECT
	P.PRODUCT_NAME,
	P.PRODUCT_ID,
	COUNT(*) AS TOTAL_NO_OF_ORDERS_SOLD ,
	SUM(
		CASE
			WHEN O.ORDER_STATUS = 'Returned' THEN 1
			ELSE 0
		END
	) AS TOTAL_RETURNED,
	SUM(
		CASE
			WHEN O.ORDER_STATUS = 'Returned' THEN 1
			ELSE 0
		END
	)::NUMERIC / COUNT(*)::NUMERIC * 100 AS RETURN_PERCENTAGE
	FROM
	ORDER_ITEMS AS OI
	JOIN PRODUCTS AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
	JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
	GROUP BY
	1,
	2
	ORDER BY
	5 DESC;
```

TASK-14: Orders Pending Shipment
Find orders that have been paid but are still pending shipment.
Challenge: Include order details, payment date, and customer information.
```sql
SELECT
	CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS FULL_NAME,
	P.PAYMENT_DATE,
	P.PAYMENT_STATUS,
	O.ORDER_ID,
	O.ORDER_STATUS
FROM
	ORDERS AS O
	JOIN PAYMENT AS P ON O.ORDER_ID = P.ORDER_ID
	JOIN CUSTOMER AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE
	P.PAYMENT_STATUS = 'Payment Successed'
	AND O.ORDER_STATUS = 'Inprogress';
```

TASK-15: Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.
```sql
WITH
	CTE1 AS (
		SELECT
			*
		FROM
			SELLER
		WHERE
			SELLER_ID NOT IN (
				SELECT
					SELLER_ID
				FROM
					ORDERS
				WHERE
					ORDER_DATE >= CURRENT_DATE - INTERVAL '6month'
			)
	)
SELECT
	O.SELLER_ID,
	MAX(O.ORDER_DATE) AS LAST_SALE_DATE,
	MAX(OI.TOTAL_SALES) AS LAST_SALE_AMOUNT
FROM
	ORDERS AS O
	JOIN CTE1 ON CTE1.SELLER_ID = O.SELLER_ID
	JOIN ORDER_ITEMS AS OI ON O.ORDER_ID = OI.ORDER_ID
GROUP BY
	1;

SELECT DISTINCT
	ORDER_STATUS
FROM
	ORDERS;
```

TASK-16: IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns
```sql
SELECT
	CUSTOMER_ID,
	FULL_NAME,
	TOTAL_ORDERS,
	TOTAL_RETURNS,
	(
		CASE
			WHEN TOTAL_RETURNS > 5 THEN 'returning'
			ELSE 'new'
		END
	) AS IDENTITY_CUSTOMERS
FROM
	(
		SELECT
			C.CUSTOMER_ID,
			CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS FULL_NAME,
			COUNT(ORDER_ID) AS TOTAL_ORDERS,
			SUM(
				CASE
					WHEN O.ORDER_STATUS = 'Returned' THEN 1
					ELSE 0
				END
			) AS TOTAL_RETURNS
		FROM
			CUSTOMER AS C
			JOIN ORDERS AS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
		GROUP BY
			1,
			2
	) AS T1;
```

TASK-17: Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.
```sql
SELECT
	*
FROM
	(
		SELECT
			C.STATE,
			CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS FULL_NAME,
			COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
			SUM(OI.TOTAL_SALES) AS TOTAL_SALES,
			DENSE_RANK() OVER (
				PARTITION BY
					C.STATE
				ORDER BY
					COUNT(O.ORDER_ID) DESC
			) AS RANK
		FROM
			CUSTOMER AS C
			JOIN ORDERS AS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
		GROUP BY
			1,
			2
	)
WHERE
	RANK <= 5;
```

TASK-18: Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and 
the average delivery time for each provider.
```sql
-- delivery time = return date - shipping date
SELECT
	S.SHIPPING_PROVIDERS,
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
	ROUND(SUM(OI.TOTAL_SALES)::NUMERIC, 2) AS REVENUE,
	COALESCE(AVG(S.RETURN_DATE - S.SHIPPING_DATE), 0) AS AVG_DELIVERY_TIME
FROM
	SHIPPING AS S
	JOIN ORDERS AS O ON S.ORDER_ID = S.ORDER_ID
	JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
GROUP BY
	1;
```

TASK-19: Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio. At the end Round the result .
Note: Decrease ratio = cr-ls/ls* 100 (cr = current_year, ls=last_year)
```sql

WITH
	LAST_YEAR_SALE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			C.CATEGORY_NAME,
			SUM(OI.TOTAL_SALES) AS REVENUE
		FROM
			ORDERS AS O
			JOIN ORDER_ITEMS AS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
			JOIN CATEGORY AS C ON C.CATEGORY_ID = P.CATEGORY_ID
		WHERE
			EXTRACT(
				YEAR
				FROM
					O.ORDER_DATE
			) = 2022
		GROUP BY
			1,
			2,
			3
	),
	CURRENT_YEAR_SALE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			C.CATEGORY_NAME,
			SUM(OI.TOTAL_SALES) AS REVENUE
		FROM
			ORDERS AS O
			JOIN ORDER_ITEMS AS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
			JOIN CATEGORY AS C ON C.CATEGORY_ID = P.CATEGORY_ID
		WHERE
			EXTRACT(
				YEAR
				FROM
					O.ORDER_DATE
			) = 2023
		GROUP BY
			1,
			2,
			3
	)
SELECT
	CS.PRODUCT_ID,
	CS.PRODUCT_NAME,
	CS.CATEGORY_NAME,
	LS.REVENUE AS LAST_YEAR_REVENUE,
	CS.REVENUE AS CURRENT_YEAR_REVENUE,
	(LS.REVENUE - CS.REVENUE) AS REV_DIFF,
	ROUND(
		(
			(LS.REVENUE - CS.REVENUE)::NUMERIC / LS.REVENUE * 100
		)::NUMERIC,
		2
	) AS REVENUE_DEC_RATIO
FROM
	LAST_YEAR_SALE AS LS
	JOIN CURRENT_YEAR_SALE AS CS ON LS.PRODUCT_ID = CS.PRODUCT_ID
WHERE
	LS.REVENUE > CS.REVENUE
```

TASK-20: Final Task
-- Store Procedure
create a function as soon as the product is sold the same quantity should reduced from inventory table
after adding any sales records it should update the stock in the inventory table based on the product and qty purchased .
-- 
```sql

SELECT
	*
FROM
	PRODUCTS;

SELECT
	*
FROM
	INVENTORY
WHERE
	PRODUCT_ID = 1;

--PRODUCT_ID 1 --AIRPOD 3RD GEN --55 STOCK
-- PRODU ID 2 AIRPOD MAX--39 STOCK
CREATE OR REPLACE PROCEDURE ADD_SALES (
	IN P_ORDER_ID INT,
	P_CUSTOMER_ID INT,
	P_SELLER_ID INT,
	P_ORDER_ITEM_ID INT,
	P_PRODUCT_ID INT,
	P_QUANTITY INT
) LANGUAGE PLPGSQL AS $$

DECLARE 
V_COUNT INT;
V_PRICE FLOAT;
V_PRODUCT VARCHAR(100);

BEGIN 

--FETCHING PRODUCT NAME AND PRICE BASED ON PRODUCT_ID ENTERED

SELECT PRICE ,PRODUCT_NAME
INTO V_PRICE,V_PRODUCT 
FROM PRODUCTS 
WHERE PRODUCT_ID=P_PRODUCT_ID;


--CHECKING STOCK AND PRODUCT AVAILABILITY IN INVENTORY 

SELECT COUNT(*) INTO V_COUNT
FROM INVENTORY WHERE PRODUCT_ID=P_PRODUCT_ID 
AND STOCK>=P_QUANTITY;

IF V_COUNT>0 THEN 

--ADD INTO ORDERS AND ORDER_ITEMS TABLE
--UPDATE INVENTORY

        INSERT INTO ORDERS(ORDER_ID,ORDER_DATE,CUSTOMER_ID,SELLER_ID)
        VALUES
		(P_ORDER_ID,CURRENT_DATE,P_CUSTOMER_ID ,P_SELLER_ID );

        INSERT INTO ORDER_ITEMS(ORDER_ITEM_ID,ORDER_ID,PRODUCT_ID,QUANTITY,PRICE_PER_UNIT,TOTAL_SALES)
        VALUES
        (P_ORDER_ITEM_ID,P_ORDER_ID,P_PRODUCT_ID ,P_QUANTITY,V_PRICE,V_PRICE*P_QUANTITY);

--UPDATING INVENTORY
UPDATE INVENTORY 
SET STOCK=STOCK-P_QUANTITY
WHERE PRODUCT_ID=P_PRODUCT_ID;

RAISE NOTICE 'THANKU PRODUCT:% SALE HAS BEEN ADDED ALSO INVENTORY STOCK UPDATES',V_PRODUCT;

ELSE 
RAISE NOTICE 
'THANKU FOR YOUR INFO THE PRODUCT:% IS NOT AVAILABLE',V_PRODUCT;

END IF;
END;
$$
--CALLING PROCEDURE
CALL ADD_SALES (25002, 2, 5, 25004, 1, 14);

```

## **Project Outcomes**
Successfully designed and analyzed an end-to-end e-commerce database to generate actionable business insights across sales, customer behavior, inventory management, and operational performance using advanced SQL techniques. The project demonstrates strong proficiency in database design, data analysis, and business problem-solving using PostgreSQL.

---

## **Conclusion**

This advanced SQL project successfully demonstrates my ability to solve real-world e-commerce problems using structured queries. From improving customer retention to optimizing inventory and logistics, the project provides valuable insights into operational challenges and solutions.

By completing this project, I have gained a deeper understanding of how SQL can be used to tackle complex data problems and drive business decision-making.

---











