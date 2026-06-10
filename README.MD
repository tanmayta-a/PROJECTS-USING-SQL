# PIZZA SALES ANALYSIS SQL Project-3

## Project Overview

**Project Title**: PIZZA Sales Analysis
**Level**: Intermediate  
**Database**: PIZZAHUT-PROJECT3

This project demonstrates the implementation of a PIZZA SALES  using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![PIZZA SALES](images/pizza-3010062_640.jpg)

## Objectives

1. **Set up the PIZZA SALES Database**: Create and populate the database with tables for order_details, orders, pizza_types, pizzas.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named 'PIZZAHUT-PROJECT3'.
- **Table Creation**: Created tables for order_details, orders, pizza_types, pizzas . Each table includes relevant columns and relationships.

```sql
--create table "order_details"
DROP TABLE IF EXISTS order_details;
create table order_details
(
            order_details_id integer,
            order_id integer,
            pizza_id varchar(50),
            quantity integer
);



-- Create table "orders"
DROP TABLE IF EXISTS orders;
CREATE TABLE orders
(
           order_id integer,
           order_date Date,
           order_time Time
);


-- Create table "pizza_types"
DROP TABLE IF EXISTS pizza_types ;
CREATE TABLE pizza_types
(    
          pizza_type varchar(1000),
          name varchar(50),
          category varchar(50),
          ingredients varchar(1000)    

);



-- Create table "pizzas"
DROP TABLE IF EXISTS pizzas;
CREATE TABLE pizzas
(
         pizza_id varchar(50),
         pizza_type varchar(50),
         size varchar(50),
         price varchar(1000)
);



### 2.BASIC SQL TASKS 


-**Task 1. Retrieve the total number of orders placed.**

```
 ```sql
  select 
 count(order_id) as total_orders from orders;
```

**Task 2:  Calculate the total revenue generated from pizza sales.


```sql
create table total_revenue 
		  as 
		  select 
		  round(sum(od.quantity * cast(pz.price as numeric) ),2) as total_revenue
		  from order_details as od
		  join 
		  pizzas as pz
		  on pz.pizza_id=od.pizza_id;
		  
		  select * from total_revenue ;
      
```

**Task 3: Identify the highest-priced pizza.

```sql
select pzt.name,
               pz.price
         from pizza_types as pzt
               join 
         pizzas as pz
                 on pzt.pizza_type=pz.pizza_type
          order by pz.price desc limit 1;
          
```

**Task 4: Identify the most common pizza size ordered.

```sql
select count(od.order_details_id) as order_count, 
               pz.size
	   from pizzas as pz
            join 
        order_details as od
             on od.pizza_id =pz.pizza_id
        group by pz.size
        order by order_count desc;

```


**Task 5: List the top 5 most ordered pizza types along with their quantities.

```sql
select pzt.name,
              sum (od.quantity) as quantity 
       from pizza_types as pzt
            join 
       pizzas as pz
           on pz.pizza_type=pzt.pizza_type  
             join 
       order_details as od
            on od.pizza_id=pz.pizza_id
          group by pzt.name 
	      order by quantity desc limit 5;

```

### 3.INTERMEDIATE SQL TASKS 

- **Task 6: Join the necessary tables to find the total quantity of each pizza category ordered.


```sql
 select 
       pzt.category,
             sum(od.quantity)as total_quantity
       from pizza_types as pzt
            join 
       pizzas as pz
           on pz.pizza_type=pzt.pizza_type  
             join 
       order_details as od
            on od.pizza_id=pz.pizza_id
         group by  pzt.category 
		 order by total_quantity desc ;

```

- **Task 7.  Determine the distribution of orders by hour of the day.

```sql
select extract (hour from order_time) as hour_time,
		           count(order_id) as distributed_orders
	       from orders
           group by hour_time  order by  distributed_orders asc ;

```

8. **Task 8: Join relevant tables to find the category-wise distribution of pizzas.


```sql
 select category,count(name) as categorized_names
		  from pizza_types
		  group by category;

```

9. ** Task 9: Group the orders by date and calculate the average number of pizzas ordered per day**:
```sql
select round(avg(quantites),0) as avg_pizza_ordered_per_day from 
          (select o.order_date,
           sum(od.quantity) as quantites
           from orders as o 
              join 
           order_details as od
             on o.order_id=od.order_id
                 group by o.order_date) as order_quantity ;

```

10. **Determine the top 3 most ordered pizza types based on revenue**:

```sql
select pzt.name,
           sum(od.quantity * cast(pz.price as numeric) ) as total_revenue
           from pizza_types as pzt
                 join 
           pizzas as pz
              on pzt.pizza_type=pz.pizza_type
                 join 
           order_details as od
              on od.pizza_id=pz.pizza_id
           group by pzt.name
           order by total_revenue desc limit 3;

```

### 3.ADVANCED SQL TASKS 


Task 11. **Calculate the percentage contribution of each pizza type to total revenue.**:
```sql
select pzt.category,
        (sum(od.quantity * cast(pz.price as numeric) ) / (select * from total_revenue ))*100 as revenue
         from pizza_types as pzt
               join 
         pizzas as pz
           on pzt.pizza_type=pz.pizza_type
               join 
         order_details as od
           on od.pizza_id=pz.pizza_id
          group by pzt.category
          order by revenue desc;
```

**Task 12: **Analyze the cumulative revenue generated over time**:

```sql
select order_date,
         sum(revenue)  over (order by order_date ) as cum_revenue 
         from
         (select o.order_date ,
          sum(od.quantity * cast(pz.price as numeric )) as revenue
          from order_details as od
               join 
          pizzas as pz
             on od.pizza_id=pz.pizza_id
               join 
         orders as o
             on o.order_id=od.order_id
         group by o.order_date) as sales;

```


**Task 13:Determine the top 3 most ordered pizza types based on revenue for each pizza category**:


```sql
SELECT
		 name,
		 revenue
		FROM
		 
         (SELECT category,name,revenue,
         RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn 
       FROM
		 
       (SELECT pzt.category,
       pzt.name,
       SUM(od.quantity * CAST(pz.price AS numeric)) as revenue
	           from pizza_types AS pzt
	               JOIN
	           pizzas AS pz
	                 ON pz.pizza_type=pzt.pizza_type
	               JOIN 
	          order_details AS od
	                  ON od.pizza_id=pz.pizza_id
					  
	 GROUP BY 1,2)AS a ) AS b 
	   
	WHERE rn<=3; 

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into ORDER_DETAILS, ORDER, REVENUE GENERATED ,PERCENATGE DISTRIBUTION.
- **Summary Reports**: Aggregated data on high-demand ORDERS and CATEGORY WISE DISTRIBUTION.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing PIZZA HUT SALES. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


Thank you for your interest in this project!
