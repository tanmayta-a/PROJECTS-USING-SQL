--ONLINE_BOOK_STORE PROJECT-4

--CREATING TABLES
create table orders
(
order_id integer,
customer_id integer,
book_id integer,
order_date date,
quantity integer,
total_amount float
);

--IMPORTING DATA THROUGH CSV FILES 

select * from orders;

create table customers
(
customer_id integer,
name varchar(100),
email varchar(100),
phone integer,
city varchar (100),
country varchar(100)
);
select * from customers;

create table books
(
boook_id integer,
title varchar(400),
author varchar(400),
genre varchar(100),
published_year integer,
price float,
stock integer
);

select * from books;

--BASIC SQL TASKS --

--TASK-1: Retrieve all books in the "Fiction" genre:
         select * from books;
		 select * from books where genre='Fiction';


--TASK-2: Find books published after the year 1950:
          select  title,author,genre ,published_year from books where published_year>1950 order by published_year desc;
  select  * from books where published_year>1950 order by published_year asc;



--TASK-3: List all customers from the Canada:

select * from customers where country='Canada'


--TASK-4:  Show orders placed in November 2023:
select * from orders where order_date between '2023-11-01' and '2023-11-30';


--TASK-5: Retrieve the total stock of books available:
select sum(stock) as total_stock_available from books;


--TASK-6: Find the details of the most expensive book:
select * from books order by price desc limit 1;


--TASK-7: Show all customers who ordered more than 1 quantity of a book:
select * from orders where quantity>1;

--ANOTHER WAY BY USING JOINS 
select cust.name,
 o.quantity
from orders as o
join 
books as bk
on bk.boook_id=o.book_id
 join 
customers as cust
 on cust.customer_id=o.customer_id
  where o.quantity>1
 group by cust.name,o.quantity;


--TASK-8: Retrieve all orders where the total amount exceeds $20:

SELECT * FROM ORDERS WHERE total_amount>20;

--TASK-9: List all genres available in the Books table:

select distinct genre from books;


--TASK-10: Find the book with the lowest stock:

select * from books order by stock asc limit 1;


--TASK-11: Calculate the total revenue generated from all orders:

SELECT SUM(total_amount) As Revenue 
FROM Orders;


-- Advance SQL TASKS  

--TASK-1: Retrieve the total number of books sold for each genre:
select bk.genre,
       sum(o.quantity) as total_number_of_books_sold
from orders as o
join 
books as bk
on bk.boook_id=o.book_id
group by bk.genre;


--TASK-2: Find the average price of books in the "Fantasy" genre:
select* from books;
select avg(price),title as average_price from books where genre='Fiction' group by title;


--TASK-3: List customers who have placed at least 2 orders:

select 
cust.name,
o.customer_id,
count(o.order_id) as order_count
from customers as cust
join orders as o
on o.customer_id=cust.customer_id
group by o.customer_id,cust.name
having count(o.order_id)>=2;


--TASK-4: Find the most frequently ordered book:
select bk.title,o.book_id,
count(o.order_id) as order_count
from orders as o
join 
books as bk
on o.book_id=bk.boook_id
group by o.book_id,bk.title
order by order_count desc limit 1;


--TASK-5: Show the top 3 most expensive books of 'Fantasy' Genre :

select max(price)as expensive_price,title,stock from books where genre='Fantasy' group by title,stock order by max(price) desc limit 3 ;


--OR WE CAN REFER TO THIS ALSO

SELECT * FROM books
WHERE genre ='Fantasy'
ORDER BY price DESC LIMIT 3;


--TASK-6: Retrieve the total quantity of books sold by each author:

select bk.author,sum(quantity) as total_quantity
from books as bk
join 
orders as o
on o.book_id=bk.boook_id
group by bk.author;



--TASK-7: List the cities where customers who spent over $30 are located:

select distinct  cust.city,
                 o.total_amount,
                 cust.name
from
orders as o
join 
customers as cust
on cust.customer_id=o.customer_id
where  o.total_amount >30;


--TASK-8: Find the customer who spent the most on orders:
select 
cust.name,
cust.customer_id,
sum(o.total_amount) as total_spent

from customers as cust
join 
orders as o
on o.customer_id=cust.customer_id
group by 1,2
order by total_spent desc limit 1 ;


--TASK-9: Calculate the stock remaining after fulfilling all orders:
SELECT bk.boook_id,
       bk.title, 
	   bk.stock,
	   COALESCE(SUM(o.quantity),0) AS Order_quantity,  
	   bk.stock- COALESCE(SUM(o.quantity),0) AS Remaining_Quantity
FROM books bk
left JOIN orders o
ON bk.boook_id=o.book_id
GROUP BY 1,2,3
ORDER BY bk.boook_id;





