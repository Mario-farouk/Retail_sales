SELECT  
FROM public.retail_sales;SELECT sales_month
,sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
;


SELECT date_part('year',sales_month) as sales_year 
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
GROUP BY 1
order by 1 desc 


SELECT date_part('year',sales_month) as sales_year
,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Book stores'
 ,'Sporting goods stores','Hobby, toy, and game stores')
GROUP BY 1,2


SELECT date_part('year',sales_month) as sales_year,
sum(case when kind_of_business = 'Book stores' then sales end) as book_sales,
sum(case when kind_of_business = 'Sporting goods stores' then sales end) as sports_sales
from retail_sales
where kind_of_business in ('Book stores','Sporting goods stores')
group by sales_year



SELECT sales_month
,kind_of_business
,sales
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')

SELECT date_part('year',sales_month) as sales_year
,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
GROUP BY 1,2


with cte as (
select date_part('year' , sales_month) as sales_year,
rank() over(partition by kind_of_business order by sum(sales) desc) as r,
sum(sales) as sum_sales,
kind_of_business
from retail_sales
group by sales_year , kind_of_business
)
select * 
from cte 
where r = 1


select (men_sales - women_sales) as men_diff
,(women_sales - men_sales) as women_diff
,sales_year
from 
(
	select date_part('year' , sales_month) as sales_year
	,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) men_sales
	,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) women_sales
	from retail_sales
	where kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
	and sales_month <= '2019-12-01'
	group by sales_year	
) a
order by sales_year 

--- the gab between women and men (who much women more than men)
select date_part('year' , sales_month) as sales_year
	,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) -  
	sum(case when kind_of_business = 'Men''s clothing stores' then sales end) as women_minus_men 
	from retail_sales
	where kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
	and sales_month <= '2019-12-01'
	group by sales_year
	order by sales_year



---who much women times men
select sales_year,
(women_sales / men_sales) as women_times_men
from 
(
	select date_part('year' , sales_month) as sales_year
	,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) men_sales
	,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) women_sales
	from retail_sales
	where kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
	and sales_month <= '2019-12-01'
	group by sales_year	
) a
order by sales_year


select sales_year,
(women_sales / men_sales -1)*100  as women_times_men
from 
(
	select date_part('year' , sales_month) as sales_year
	,sum(case when kind_of_business = 'Men''s clothing stores' then sales end) men_sales
	,sum(case when kind_of_business = 'Women''s clothing stores' then sales end) women_sales
	from retail_sales
	where kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
	and sales_month <= '2019-12-01'
	group by sales_year	
) a
order by sales_year




SELECT sales_month
,kind_of_business
,sales * 100 / total_sales as pct_total_sales
FROM
(
 SELECT a.sales_month, a.kind_of_business, a.sales
 ,sum(b.sales) as total_sales
 FROM retail_sales a
 JOIN retail_sales b on a.sales_month = b.sales_month
 and b.kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 WHERE a.kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 GROUP BY 1,2,3
) aa
;

with cte as (
select sales_month
,kind_of_business
,sales
,sum(sales) over(partition by sales_month) as total_sales
from retail_sales
where kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 group by 1,2,3
)
select * ,round((sales / total_sales),2) * 100 as pct_of_sales
from cte


SELECT sales_month
,kind_of_business
,sales * 100 / yearly_sales as pct_yearly
FROM
(
 SELECT a.sales_month, a.kind_of_business, a.sales
 ,sum(b.sales) as yearly_sales
 FROM retail_sales a
 JOIN retail_sales b on 
 date_part('year',a.sales_month) = date_part('year',b.sales_month)
 and a.kind_of_business = b.kind_of_business
 and b.kind_of_business in ('Men''s clothing stores','Women''s clothing stores')
 WHERE a.kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 GROUP BY 1,2,3
) aa


with cte as (
select a.sales_month , a.kind_of_business ,a.sales ,sum(b.sales) as total_sales
from retail_sales a join retail_sales b
on a.kind_of_business = b.kind_of_business
and date_part('year',a.sales_month) = date_part('year',b.sales_month)
WHERE a.kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
and b.kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 group by 1,2,3
 )
 
 select * ,round((sales/total_sales),2) * 100 as pct_of_sales 
 from cte 
 
 
 SELECT sales_month, kind_of_business, sales
,sum(sales) over (partition by date_part('year',sales_month)
 ,kind_of_business
 ) as yearly_sales
,sales * 100 / 
 sum(sales) over (partition by date_part('year',sales_month)
 ,kind_of_business
 ) as pct_yearly
FROM retail_sales 
WHERE kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')


select year
,total_sales
,first_value(total_sales) over(order by year) as sales_index
,(total_sales / first_value(total_sales) over (order by year) - 1) * 100 as pct_of_change
from (
	select date_part('year' , sales_month) as year 
	,sum(sales) as total_sales
	from retail_sales 
	where kind_of_business = 'Women''s clothing stores'
	group by year
	order by year asc
	) a


SELECT sales_year, kind_of_business, sales
,(sales / first_value(sales) over (partition by kind_of_business 
 order by sales_year)
 - 1) * 100 as pct_from_index
FROM
(
 SELECT date_part('year',sales_month) as sales_year
 ,kind_of_business
 ,sum(sales) as sales
 FROM retail_sales
 WHERE kind_of_business in ('Men''s clothing stores'
 ,'Women''s clothing stores')
 and sales_month <= '2019-12-31'
 GROUP BY 1,2
order by sales_year asc
) a

SELECT a.sales_month
,a.sales
,b.sales_month as rolling_sales_month
,b.sales as rolling_sales
FROM retail_sales a
JOIN retail_sales b on a.kind_of_business = b.kind_of_business 
 and b.sales_month between a.sales_month - interval '11 months' 
 and a.sales_month
 and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
and a.sales_month = '2019-12-01'
;




select a.sales_month 
, a.sales 
,b.sales_month AS ROLLING_DATE
,b.sales AS Sales_rolling
from retail_sales a 
join retail_sales b on a.kind_of_business = b.kind_of_business
and b.sales_month between a.sales_month - interval '11 months'
and a.sales_month
and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
and a.sales_month = '2019-12-01'
;




SELECT a.sales_month
,a.sales
,avg(b.sales) as moving_avg
,count(b.sales) as records_count
FROM retail_sales a
JOIN retail_sales b on a.kind_of_business = b.kind_of_business 
 and b.sales_month between a.sales_month - interval '11 months' 
 and a.sales_month
 and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
and a.sales_month >= '1993-01-01'
GROUP BY 1,2
order by a.sales_month asc



select avg(sales) over(partition by kind_of_business order by  date_part('year' , sales_month))
,sales
,sales_month
from retail_sales
where kind_of_business =  'Women''s clothing stores'




SELECT sales_month
,avg(sales) over (order by sales_month rows between 11 preceding and current row) as moving_avg
,count(sales) over (order by sales_month 
 rows between 11 preceding and current row
 ) as records_count
FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores'





