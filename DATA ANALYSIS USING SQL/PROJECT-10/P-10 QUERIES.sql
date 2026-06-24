--BUSINESS PROBLEMS AND SOLUTIONS

-- 1. Find the number of stores in each country.
	Select country, Count(*) as number_of_stores
	From stores
	Group By 1
	Order By 2 Desc;
	
-- 2. Calculate the total number of units sold by each store.

	Select s.store_id,
		   st.store_name,
		   sum(s.quantity) as Total_Unit_Sold
	From sales s
	Join stores st
	ON s.store_id = st.store_id
	Group By 1, 2
	Order By 3 Desc;
	
-- 3. Identify how many sales occurred in December 2023.

	Select count(sale_id) as Total_sales
	From sales
	Where To_char(sale_date, 'MM-YYYY') = '12-2023'

-- 4. Determine how many stores have never had a warranty claim filed.

SELECT COUNT(*) FROM STORES 
WHERE STORE_ID NOT IN (
SELECT DISTINCT STORE_ID 


FROM SALES AS SA
RIGHT JOIN 
WARRANTY AS W
ON SA.SALE_ID= W.SALE_ID
)


-- 5. Calculate the percentage of warranty claims marked as "Rejected".
select 
round(count(repair_status)/(select count(*) from warranty)::numeric * 100,2)as rejected_percentage
from warranty where repair_status='Rejected'

-- 6. Identify which store had the highest total units sold in the last year.
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

-- 7. Count the number of unique products sold in the last year.

select count( distinct product_id) as number_of_products_sold
from sales
where sale_date>=(current_date-interval '3 year')

-- 8. Find the average price of products in each category.

select category_id ,avg(price) from products 
group by 1
order by 2 desc

-- 9. How many warranty claims were filed in 2024?

select count(claim_id) as warranty_claims

from warranty where extract(year from claim_date)='2024'

-- 10. For each store, identify the best-selling day based on highest quantity sold.

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

-- 11. Identify the least selling product in each country for each year based on total units sold.

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


-- 12. Calculate how many warranty claims were filed within 180 days of a product sale.
	
select p.product_id,p.product_name,s.sale_date,w.claim_date,
(w.claim_date-s.sale_date) as days 
from sales as s
join 
warranty as w
on s.sale_id=w.sale_id
join products as p
on s.product_id=p.product_id
where w.claim_date-s.sale_date<=180

select * 
from sales as s
join 
warranty as w
on s.sale_id=w.sale_id
join products as p
on s.product_id=p.product_id
where w.claim_date-s.sale_date<=180


-- 13. Determine how many warranty claims were filed for products launched in the last two years.


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


-- 14. List the months in the last three years where sales exceeded 5,000 units in the USA.


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

-- 15. Identify the product category with the most warranty claims filed in the last two years.

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



-- 16. Determine the percentage chance of receiving warranty claims after each purchase for each country.

 
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

-- 17. Analyze the year-by-year growth ratio for each store.
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

-- 18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

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


-- 19. Identify the store with the highest percentage of "Rejected" claims relative to total claims filed.

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


-- 20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.

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


-- 21. Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
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




