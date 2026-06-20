--BUSINESS ANALYSIS 

/*TASK-1:What are the top 5 most frequently ordered dishes by the customer "Arjun Mehta" in the last year?*/

WITH
	RANKED_ORDERS AS (
		SELECT
			C.CUSTOMER_NAME,
			O.ORDER_ITEM AS DISHES,
			COUNT(*) AS TOTAL_ORDERS,
			DENSE_RANK() OVER (
				ORDER BY
					COUNT(*) DESC
			) AS RANK
		FROM
			ORDERS AS O
			JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
		WHERE
			C.CUSTOMER_NAME = 'Arjun Mehta'
			AND O.ORDER_DATE >= CURRENT_DATE - INTERVAL '4 year'
		GROUP BY
			1,
			2
	)
SELECT
	CUSTOMER_NAME,
	DISHES,
	TOTAL_ORDERS
FROM
	RANKED_ORDERS
WHERE
	RANK <= 5
ORDER BY
	TOTAL_ORDERS DESC;

/*TASK-2:What are the most popular time slots (in 2-hour intervals) for placing orders?*/
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;

/*TASK-3: What is the average order value (AOV) for customers who have placed more than 750 orders?*/
SELECT C.CUSTOMER_NAME,
AVG(O.TOTAL_AMOUNT) AS AOV
FROM
			ORDERS AS O
			JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
GROUP BY 1
HAVING COUNT(ORDER_ID)>750


/*TASK-4:Which customers have spent more than 100,000 in total?*/


SELECT C.CUSTOMER_NAME,SUM(O.TOTAL_AMOUNT) AS TOTAL_SPENT
FROM
			ORDERS AS O
			JOIN CUSTOMERS AS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
GROUP BY 1
HAVING SUM(O.TOTAL_AMOUNT)>100000;

/*TASK-5: Which orders were placed but never delivered, and at which restaurants?*/

SELECT R.RESTAURANT_NAME,
       R.CITY,
	   COUNT(O.ORDER_ID)AS CNT_NOT_DELIVERED_ORDERS
FROM ORDERS AS O
LEFT JOIN 
RESTAURANTS AS R
ON R.RESTAURANT_ID=O.RESTAURANT_ID
LEFT JOIN 
DELIVERIES AS D
ON D.ORDER_ID=O.ORDER_ID
WHERE D.DELIVERY_ID IS NULL
GROUP BY 1,2
ORDER BY 3 DESC;

/*TASK-6:How do restaurants rank by total revenue within their respective cities over the last year?*/


WITH RANKING_TABLE AS(
SELECT R.CITY,R.RESTAURANT_NAME,
SUM(O.TOTAL_AMOUNT) AS TOTAL_REVENUE,
DENSE_RANK() OVER( PARTITION BY R.CITY ORDER BY SUM(O.TOTAL_AMOUNT)DESC ) AS RANK
FROM
RESTAURANTS AS R
JOIN 
ORDERS AS O
ON R.RESTAURANT_ID=O.RESTAURANT_ID
WHERE O.ORDER_DATE>=CURRENT_DATE-INTERVAL '4 YEAR'
GROUP BY 1,2)
SELECT * FROM RANKING_TABLE WHERE RANK=1;

/*TASK-7:What is the most ordered dish in each city?*/

SELECT * FROM (SELECT R.CITY,O.ORDER_ITEM AS DISHES,
COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
RANK() OVER(PARTITION BY R.CITY ORDER BY COUNT(O.ORDER_ID) DESC) AS RANK       
FROM
RESTAURANTS AS R
JOIN 
ORDERS AS O
ON R.RESTAURANT_ID=O.RESTAURANT_ID
GROUP BY 1,2
ORDER BY 3 DESC)AS T1
WHERE RANK=1;

/*TASK-8: Which customers placed orders in 2023 but have not placed any in 2024?*/


SELECT DISTINCT customer_id from orders where 
extract(year from order_date)=2023 and customer_id not in (SELECT DISTINCT customer_id from orders where 
extract(year from order_date)=2024 );

/*TASK-9:  How does the order cancellation rate for each restaurant in the current year compare to the previous year?*/

WITH
CANCEL_RATIO_23 AS (
	SELECT
		O.RESTAURANT_ID,
		COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
		COUNT(
			CASE
				WHEN D.DELIVERY_ID IS NULL THEN 1
			END
		) AS NOT_DELIVERED
	FROM
		ORDERS AS O
		LEFT JOIN DELIVERIES AS D 
		ON D.ORDER_ID = O.ORDER_ID
	WHERE
		EXTRACT(
			YEAR
			FROM
				O.ORDER_DATE
		) = 2023
	GROUP BY
		1
),
CANCEL_RATIO_24 AS (
	SELECT
		O.RESTAURANT_ID,
		COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
		COUNT(
			CASE
				WHEN D.DELIVERY_ID IS NULL THEN 1
			END
		) AS NOT_DELIVERED
	FROM
		ORDERS AS O
		LEFT JOIN DELIVERIES AS D 
		ON D.ORDER_ID = O.ORDER_ID
	WHERE
		EXTRACT(
			YEAR
			FROM
				O.ORDER_DATE
		) = 2024
	GROUP BY
		1
),
LAST_YEAR_DATA AS (
	SELECT
		RESTAURANT_ID,
		TOTAL_ORDERS,
		NOT_DELIVERED,
		ROUND((NOT_DELIVERED::NUMERIC / TOTAL_ORDERS::NUMERIC) * 100,
			2) AS CANCEL_RATIO
	FROM
		CANCEL_RATIO_23
),

CURRENT_YEAR_DATA AS  (
	SELECT
		RESTAURANT_ID,
		TOTAL_ORDERS,
		NOT_DELIVERED,
		
			ROUND((NOT_DELIVERED::NUMERIC / TOTAL_ORDERS::NUMERIC) * 100,
			2) AS CANCEL_RATIO
	FROM
		CANCEL_RATIO_24
)
SELECT
C.RESTAURANT_ID AS RESTAURANT_ID,
C.CANCEL_RATIO AS CURRENT_YEAR_CANCEL_RATIO,
L.CANCEL_RATIO AS LAST_YEAR_CANCEL_RATIO
FROM
CURRENT_YEAR_DATA AS C
JOIN LAST_YEAR_DATA AS L ON C.RESTAURANT_ID = L.RESTAURANT_ID;

/*TASK-10:What is the average time it takes for each rider to deliver an order?*/

SELECT  o.order_id,
        o.order_time,
		d.delivery_time,
        D.RIDER_ID,
		d.delivery_time- o.order_time as time_difference,
       AVG(EXTRACT(EPOCH FROM (D.DELIVERY_TIME-O.ORDER_TIME+
	   CASE WHEN D.DELIVERY_TIME < O.ORDER_TIME THEN INTERVAL '1 DAY' ELSE INTERVAL '0 DAY' END)))/ 60 AS AVG_DELIVERY_TIME
FROM ORDERS AS O
JOIN 
DELIVERIES AS D
ON O.ORDER_ID=D.ORDER_ID 
WHERE D.DELIVERY_STATUS='Delivered'
group by 1,2,3,4

/*TASK-11:  What is the month-over-month growth rate in delivered orders for each restaurant?*/

WITH GROWTH_RATIO AS(
SELECT O.RESTAURANT_ID,
        TO_CHAR(O.ORDER_DATE,'MM-YY')AS MONTH,
		COUNT(O.ORDER_ID) AS CURRENT_MONTH_SALES,
		LAG(COUNT(O.ORDER_ID),1)OVER(PARTITION BY O.RESTAURANT_ID ORDER BY  TO_CHAR(O.ORDER_DATE,'MM-YY')) AS PREV_MONTH_ORDERS

FROM ORDERS AS O
JOIN 
DELIVERIES AS D
ON O.ORDER_ID=D.ORDER_ID 
WHERE D.DELIVERY_STATUS='Delivered'
GROUP BY 1,2
ORDER BY 1,2
)
SELECT RESTAURANT_ID,MONTH,CURRENT_MONTH_SALES,PREV_MONTH_ORDERS,
ROUND((CURRENT_MONTH_SALES::NUMERIC-PREV_MONTH_ORDERS::NUMERIC )/PREV_MONTH_ORDERS::NUMERIC *100,2)
AS GROWTH_RATIOS
FROM GROWTH_RATIO

/*TASK-12:Segment customers into 'Gold' or 'Silver' based on whether their total spending is above or below the platform-wide average order value (AOV). What is the total revenue from each segment?*/

select cx_category,
sum(total_spent) as total_revenue,
sum(total_orders) as total_orders

from
(SELECT CUSTOMER_ID,
SUM(TOTAL_AMOUNT) AS TOTAL_SPENT,
COUNT(ORDER_ID) AS TOTAL_ORDERS,
CASE
     WHEN SUM(TOTAL_AMOUNT)>(SELECT AVG(TOTAL_AMOUNT)FROM ORDERS )THEN 'Gold'
     else 'Silver'
	 end as cx_category
	 from orders
group by 1
)as t1
group by 1

/*TASK-13:  Calculate each rider's total monthly earnings, assuming they earn an 8% commission on the order amount.*/
SELECT
	d.rider_id,
	TO_CHAR(o.order_date, 'MM-YY') as month,
	SUM(o.total_amount) as total_revenue_generated,
	SUM(o.total_amount) * 0.08 as riders_earning
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1, 2
ORDER BY 1, 2;

/*TASK-14:How many 5-star, 4-star, and 3-star ratings does each rider have, based on delivery speed?*/


WITH delivery_times AS (
    SELECT
        d.rider_id,
        EXTRACT(EPOCH FROM (d.delivery_time - o.order_time +
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE INTERVAL '0 day' END
        ))/60 as delivery_took_time
    FROM orders as o
    JOIN deliveries as d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
)
SELECT
	rider_id,
	COUNT(CASE WHEN delivery_took_time < 15 THEN 1 END) as five_star_ratings,
	COUNT(CASE WHEN delivery_took_time BETWEEN 15 AND 20 THEN 1 END) as four_star_ratings,
	COUNT(CASE WHEN delivery_took_time > 20 THEN 1 END) as three_star_ratings
FROM delivery_times
GROUP BY 1
ORDER BY 1;

/*TASK-15 What is the busiest day of the week for each restaurant?*/

WITH daily_orders AS (
	SELECT
		r.restaurant_name,
		TO_CHAR(o.order_date, 'Day') as day_of_week,
		COUNT(o.order_id) as total_orders,
		RANK() OVER(  PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as rank
	FROM orders as o
	JOIN
	restaurants as r
	ON o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
)
SELECT
    restaurant_name,
    day_of_week,
    total_orders
FROM daily_orders
WHERE rank = 1;


/*TASK-16: What is the total revenue generated by each customer over their entire history with the platform?*/

SELECT
	c.customer_name,
	SUM(o.total_amount) as customer_lifetime_value
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC;

/*TASK-17:How do total sales for each month compare to the previous month?*/

SELECT EXTRACT (YEAR FROM ORDER_DATE) AS YEAR,
       EXTRACT (MONTH FROM ORDER_DATE) AS MONTH,
SUM(TOTAL_AMOUNT) AS TOTAL_SALE,
LAG(SUM(TOTAL_AMOUNT),1) OVER (ORDER BY EXTRACT(YEAR FROM ORDER_DATE),
       EXTRACT(MONTH FROM ORDER_DATE)) AS PREV_MONTH_SALE
 FROM ORDERS 
 GROUP BY 1,2
 ORDER BY 1,2

 /*TASK-18: Who are the fastest and slowest riders on average?*/

WITH riders_avg_time AS (
	SELECT
		d.rider_id,
		AVG(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time +
		CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE
		INTERVAL '0 day' END))/60) as avg_time_minutes
	FROM orders as o
	JOIN deliveries as d
	ON o.order_id = d.order_id
	WHERE d.delivery_status = 'Delivered'
    GROUP BY 1
)
SELECT
	MIN(avg_time_minutes) as fastest_avg_delivery_time,
	MAX(avg_time_minutes) as slowest_avg_delivery_time
FROM riders_avg_time;

/*TASK-19:How does the popularity of different food items change with the seasons?*/
WITH seasonal_orders AS (
    SELECT
		order_item,
		CASE
			WHEN EXTRACT(MONTH FROM order_date) IN (3, 4, 5) THEN 'Spring'
			WHEN EXTRACT(MONTH FROM order_date) IN (6, 7, 8) THEN 'Summer'
			WHEN EXTRACT(MONTH FROM order_date) IN (9, 10, 11) THEN 'Autumn'
			ELSE 'Winter'
		END as season
	FROM orders
)
SELECT
	order_item,
	season,
	COUNT(*) as total_orders
FROM seasonal_orders
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

/*TASK-20:Rank cities based on the total revenue generated in 2023.*/
SELECT
	r.city,
	SUM(o.total_amount) as total_revenue,
	RANK() OVER(ORDER BY SUM(o.total_amount) DESC) as city_rank
FROM orders as o
JOIN
restaurants as r
ON o.restaurant_id = r.restaurant_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023
GROUP BY 1;
	