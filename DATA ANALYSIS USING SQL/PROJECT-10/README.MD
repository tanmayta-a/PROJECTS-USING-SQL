#APPLE SALES ANALYSIS 
## Project Overview

This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally. 


## Entity Relationship Diagram (ERD)

![ERD](https://github.com/tanmayta-a/PROJECTS-USING-SQL/blob/main/DATA%20ANALYSIS%20USING%20SQL/PROJECT-10/ERD%20P-10)

---

### What’s Included:

- **20 Advanced SQL Queries**: Step-by-step solutions for complex queries, enhancing my  skills in performance tuning and optimization.
- **5 Detailed Tables**: Comprehensive datasets with over 1 million rows, including sales, stores, product categories, products, and warranties.
- **Hands-on Learning**: Practical experience with complex datasets and advanced business problem-solving.
- **Comprehensive Coverage**: Each table provides new opportunities to explore SQL concepts.


## Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

## Objectives

The project is split into three tiers of questions to test SQL skills of increasing complexity:

### Easy to Medium (10 Questions)

1. Find the number of stores in each country.
```sql
Select country, Count(*) as number_of_stores
	From stores
	Group By 1
	Order By 2 Desc;
```
2. Calculate the total number of units sold by each store.
```sql
Select s.store_id,
		   st.store_name,
		   sum(s.quantity) as Total_Unit_Sold
	From sales s
	Join stores st
	ON s.store_id = st.store_id
	Group By 1, 2
	Order By 3 Desc;
```
3. Identify how many sales occurred in December 2023.
```sql
Select count(sale_id) as Total_sales
	From sales
	Where To_char(sale_date, 'MM-YYYY') = '12-2023'


```
4. Determine how many stores have never had a warranty claim filed.
```sql
SELECT COUNT(*) FROM STORES 
WHERE STORE_ID NOT IN (
SELECT DISTINCT STORE_ID
FROM SALES AS SA
RIGHT JOIN 
WARRANTY AS W
ON SA.SALE_ID= W.SALE_ID
)


```
5. Calculate the percentage of warranty claims marked as "Rejected".
```sql
select 
round(count(repair_status)/(select count(*) from warranty)::numeric * 100,2)as rejected_percentage
from warranty where repair_status='Rejected'
```
6. Identify which store had the highest total units sold in the last year(2023).
```sql
select st.store_id,
       st.store_name,
       sum(sa.quantity) as total_units_sold,
       to_char(sa.sale_date,'yyyy') as year
from sales as sa
join 
stores as st
on sa.store_id=st.store_id 
where sa.sale_date>=(current_date-interval '3 year')
group by 1,2,4
order by 3 desc
```
7. Count the number of unique products sold in the last year(2023).
```sql
select count( distinct product_id) as number_of_products_sold
from sales
where sale_date>=(current_date-interval '3 year')
```
8. Find the average price of products in each category.
```sql
select category_id ,avg(price) from products 
group by 1
order by 2 desc

```
9. How many warranty claims were filed in 2020?
```sql
select count(claim_id) as warranty_claims
from warranty where extract(year from claim_date)='2024'

```
10. For each store, identify the best-selling day based on highest quantity sold.
```sql
with selling_day as (
select store_id,
        to_char(sale_date,'day') as day_name,
		sum(quantity) as total_units_sold,
		rank() over(partition by store_id order by 	sum(quantity) desc) as rank
from sales
group by 1,2
)

select store_id,day_name, total_units_sold
from selling_day where rank=1
order by 1;
```

### Medium to Hard (5 Questions)

11. Identify the least selling product in each country for each year based on total units sold.
```sql
with least_selling_product as (
select st.country,
        extract(year from sa.sale_date) as years,
	   p.product_name,
       p.product_id,
	   sum(sa.quantity) as total_no_of_units_sold,
       rank() over(partition by st.country,extract(year from sa.sale_date) order by sum(sa.quantity) asc) as min_sale_product   

from products as p
join 
sales as sa
on sa.product_id=p.product_id
join 
stores as st
on 
st.store_id=sa.store_id
group by 1,2,3,4
)

select country,years,product_name,product_id,total_no_of_units_sold
from least_selling_product where min_sale_product=1

```
12. Calculate how many warranty claims were filed within 180 days of a product sale.
```sql
select * 
from sales as s
join 
warranty as w
on s.sale_id=w.sale_id
join products as p
on s.product_id=p.product_id
where w.claim_date-s.sale_date<=180

```
13. Determine how many warranty claims were filed for products launched in the last two years.
```sql
select p.product_name,
       count(w.claim_id) as no_claim,
	   count(s.sale_id) as sales
	   from warranty as w
	    right join 
	   sales as s
	   on s.sale_id=w.sale_id
	   join products as p
	   on p.product_id=s.product_id 
	   where p.launch_date>=current_date -interval'2 years'
	    group by 1
```
14. List the months in the last three years where sales exceeded 5,000 units in the USA.
```sql
select st.country,
       extract(month from sa.sale_date) as month,
	   count(sa.quantity) as total_no_of_units_sold
from stores as st
join 
sales as sa
on st.store_id=sa.store_id
where st.country='United States'
and sa.sale_date>(current_date-interval '3 years')
group by 1,2
having count(sa.quantity)>5000
order by 3 desc
```
15. Identify the product category with the most warranty claims filed in the last two years.
```sql

select c.category_name,
       count(w.claim_id) as total_warranty_claims
from category as c
join 
products as p
on c.category_id = p.category_id
join sales as sa
ON p.product_id = sa.product_id
	Join warranty w
	ON sa.sale_id  = w.sale_id
where w.claim_date >= (current_date-interval '2 years')
group by 1
order by 2 desc;
```

### Complex (5 Questions)

16. Determine the percentage chance of receiving warranty claims after each purchase for each country.
```sql
select  country,
        total_units_sold,
		total_claim,
        coalesce(total_claim::numeric/total_units_sold::numeric *100,0) as risk 
from 
(select st.country,
        sum(sa.quantity) as total_units_sold,
		count(w.claim_id) as total_claim
from sales as sa
join 
stores as st
on st.store_id=sa.store_id
left join 
warranty as w
on w.sale_id=sa.sale_id
group by 1) t1
order by 4 desc
```
17. Analyze the year-by-year growth ratio for each store.
```sql
with yearly_sales as(
	select sa.store_id,
	       st.store_name ,
		   extract(year from sa.sale_date) as year,
		   sum(sa.quantity* p.price) as total_sale
	from sales as sa
	join 
	products as p
	on sa.product_id=p.product_id
	join stores as st
	on st.store_id=sa.store_id
	group by 1,2,3
	order by 2,3
	),
	growth_ratio as (
	select store_name,
	        year,
			lag(total_sale,1)over (partition by store_name order by  year asc )as last_year_sale,
			total_sale as current_year from yearly_sales)
	
select store_name,
	   year,
	   last_year_sale,
	   current_year,
	   round((current_year-last_year_sale)::numeric/last_year_sale::numeric *100,3) as growth_ratio
	       
	from growth_ratio
where last_year_sale is not null and  year<> extract(year from current_date)

```
18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
```sql
-- to check warranty claim for products of different price category 
-- (to check if lower price product category has more claim or higher price category has more)
select 
case  
when p.price<500 then 'less expense product'
when p.price between 500 and 1000 then 'mid range product'
else 'expensive product'
end as price_segment,
count(w.claim_id) as total_claim
from warranty as w
left join 
sales as sa
on w.sale_id=sa.sale_id
join products as p
on  sa.product_id=p.product_id
where w.claim_date >=(current_date-interval '5 years')
group by 1
```
19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
```sql
with rejected_count as
(
select sa.store_id,
        count(w.claim_id) as total_claim,
		count(case when w.repair_status='Rejected' then  1 end) as total_rejected
	from sales as sa
	right join 
	warranty as w
	on sa.sale_id=w.sale_id
	group by 1
)

     select 
	 r.store_id,
	 st.store_name,
	 st.city,
	 st.country,
	 r.total_claim,
	 r.total_rejected,
	 round(r.total_rejected::numeric/ r.total_claim ::numeric * 100,2)as rejection_percentage
	from rejected_count AS r
	join 
	stores as st
	on st.store_id=r.store_id
	order by 7 desc 
	limit 1
```
20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
```sql
with monthly_sales as(
select store_id,
        extract (year from sale_date) as year,
		extract(month from sale_date) as month,
		sum(p.price * sa.quantity) as total_revenue
		from sales as sa
		join 
		products as p
		on  sa.product_id=p.product_id
		group by 1,2,3
		order by 1,2,3)

select store_id,year,month, total_revenue,
sum(total_revenue) over ( partition by store_id order by year,month) as running_total
from monthly_sales
```

### Bonus Question

- Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
```sql
select p.product_name,
case 
when sa.sale_date between p.launch_date and p.launch_date + interval '6 month' then '0-6 month'
when sa.sale_date between p.launch_date + interval '6 month' and p.launch_date +interval '12 month' then '6-12 month'
when sa.sale_date between p.launch_date + interval '12 month' and p.launch_date + interval '18 month' then '12-18 month'
else '18+'
end as plc,
sum(sa.quantity) as total_qty_sale
from sales as sa
join products as p
on sa.product_id=p.product_id
group by 1,2
order by 1,3 desc

```

## Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.


## Dataset

- **Size**: 1 million+ rows of sales data.
- **Period Covered**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.

---
