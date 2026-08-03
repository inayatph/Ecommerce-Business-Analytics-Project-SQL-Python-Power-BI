create database urbannest;
use urbannest;

-- fact orders : grain - 1 product line within 1 order - meaning 1 row is 1 product and not 1 order. 
-- fact inventory (grain = 1 product, 1 warehouse, 1 month)
-- fact marketing (grain = 1 channel, 1 region, 1 month)


alter table fact_inventory
add column inventory_id  int not null auto_increment key first;

alter table fact_inventory
drop column inventory_turnover;

alter table fact_inventory
add constraint fk_inventory
foreign key (product_id)
references dim_product(product_id);

------------------------------------------------

alter table fact_marketing 
add column marketing_id int not null auto_increment primary key first;

------------------------------------------------------------
alter table dim_customer
modify customer_id varchar(50) not null;

alter table dim_customer
add primary key (customer_id);

-----------------------------------------------------------

alter table dim_date 
add primary key (date_id);

-----------------------------------------------------------

alter table dim_product
modify product_id varchar(50) not null;

alter table dim_product
add primary key(product_id);

---------------------------------------------------------------

alter table dim_people
modify region varchar(50) not null;

alter table dim_people
add primary key(region);

------------------------------------------------------------------

select * from fact_orders;
describe fact_orders;

alter table fact_orders
modify customer_id varchar(50) not null;
alter table fact_orders
modify product_id varchar(50) not null;

alter table fact_orders
add constraint fk_customer
foreign key (customer_id)
references dim_customer(customer_id);

alter table fact_orders
add constraint fk_product
foreign key (product_id)
references dim_product(product_id);

alter table fact_orders
add constraint fk_date
foreign key (order_date)
references dim_date(date_id);


alter table fact_orders
add primary key (row_id); 

-----------------------------------------------------------------
select * from dim_customer;
select * from dim_date;
select * from dim_people;
select * from dim_product;
select * from fact_inventory;
select * from fact_marketing;
select * from fact_orders;


#  LETS DO SOME BUSINESS QUESTIONS 

-- 1. 10 highest revenue order?

select order_id, customer_id, sales, quantity, profit, (sales * quantity) as revenue
from fact_orders
order by revenue desc limit 10;

-- 2. which orders were shipped same day with a discount above 20%

select order_id, ship_mode, discount, sales 
from fact_orders 
where ship_mode ='Same Day' and discount> 0.20
order by discount desc;

-- 3. whats the total revenue and profit by category?

select category, sum(sales * quantity) as total_sales, sum(profit) as total_profit, 
round(sum(profit)/sum(sales) *100, 2) as profit_marginpct
from fact_orders o
join dim_product p 
on o.product_id = p.product_id
group by category
order by profit_marginpct desc;

-- 4. which sub categories have negative average profit - candidates for discontinuation?

select sub_category, avg(profit) as avg_profit, count(distinct order_id) as order_count
from fact_orders o
inner join dim_product p
on o.product_id = p.product_id
group by sub_category
having avg_profit<0;


-- 5. Bucket customers into order-value tiers for quick segmentation view

select customer_id, sum(sales* quantity) as total_spent,
case
	when sum(sales* quantity) > 5000 then 'High value'
    when sum(sales* quantity) > 2000 then 'Mid value'
    else 'Low value'    
end as customer_tier
from fact_orders
group by customer_id; 

-- 6. Flag orders as delayed is shipping took more than 5 days. 

select order_id, datediff(ship_date, order_date) as days_to_ship, 
case 
	when datediff(ship_date, order_date) > 5 then 'Delayed'
    else 'Not delayed'
end  as shipping_status
from fact_orders;


-- 7. Whats our monthly revenue trend 

select 
substring(order_date, 1,7) as order_month, sum(sales*quantity) as revenue
from fact_orders 
group by order_month
order by order_month;

-- 8. clean up inconsistent customer name casing/ spacing for reporting 

select customer_id, trim(upper(customer_name)) as clean_name, length(customer_name) as name_length 
from dim_customer;

-- 9. Round shipping cost as a percentage of sales, for cost-efficiancy review?

select order_id, sales, shipping_cost, round((shipping_cost/ nullif(sales,0))*100, 2) as shipping_pct_sales
from fact_orders;
 
 
-- 10. List every order along with customer region and product category 

select order_id, order_date, region, category, sales, profit
from dim_product p 
inner join fact_orders o
on p.product_id = o.product_id
inner join dim_customer c
on o.customer_id = c.customer_id;


-- 11. which region have a manager assigned vs not   

select c.region, person as regional_manager
from dim_customer c
left join dim_people p
on c.region = p.region ;

-- 12. Which customers spent more than the overall average order value?

select customer_id, sum(sales* quantity) as total_spent
from fact_orders 
group by customer_id 
having total_spent > (select avg(sales*quantity) as avg_order_value from fact_orders);

-- 13. For each customer, find their single highest-value order 

select f.order_id, f.customer_id, f.sales
from fact_orders f
where f.sales = (
    select MAX(f2.sales) 
    from fact_orders f2 
    where f2.customer_id = f.customer_id
);


-- 14. Get monthly revenue, then calculate month over month growth 

with tt as 
(select date_format(order_date, '%Y-%m-01') as month_start, sum(sales) as total_sales 
from fact_orders 
group by month_start) 
select month_start, total_Sales, lag(total_sales) over(order by month_start) as previous_month_sales, 
round((total_sales - (lag(total_sales) over(order by month_start)))/ (lag(total_sales) over(order by month_start)) * 100, 2) as month_growth_pct
from tt 
order by month_start;

-- 15. Rank products by profit within each category 

select p.category, p.product_name, SUM(f.profit) as total_profit,
    rank() over(partition by p.category order by SUM(f.profit) desc) as profit_rank
from fact_orders f
join dim_product p on f.product_id = p.product_id
group by p.category, p.product_name;

-- 16. Compute a running (cumulative) revenue total by month.

select substring(order_date, 1,7) as order_month, sum(sales) as monthly_sales, 
	sum(sum(sales)) over (order by substring(order_date, 1,7 )) AS running_total
FROM fact_orders
GROUP BY substring(order_date, 1,7)
ORDER BY order_month;

-- 17. Marketing wants an on-demand report of top N products by revenue for any date range, without writing SQL each time.

DELIMITER //

create procedure GetTopProductsByRevenue(
    in start_date date, 
    in end_date date, 
    in top_n int
)
begin 
    select 
        p.product_name,
        SUM(f.sales) as total_sales
    from fact_orders f
    join dim_product p on f.product_id = p.product_id
    where f.order_date between start_date and end_date
    group by p.product_name
    order  by total_sales desc 
    limit top_n;
end //

DELIMITER //

-- Usage:
call GetTopProductsByRevenue('2023-01-01', '2023-12-31', 10);


-- 18. Finance wants a always-up-to-date, pre-joined profitability view without touching raw tables.

create view vw_order_profitability as 
select 
    f.order_id,
    f.order_date,
    c.region,
    p.category,
    p.sub_category,
    f.sales,
    f.profit,
    f.shipping_cost,
    ROUND(f.profit / NULLIF(f.sales, 0) * 100, 2) as margin_pct
from fact_orders f
join dim_customer c on  f.customer_id = c.customer_id
join dim_product p on f.product_id = p.product_id;

-- Usage:
select * from vw_order_profitability where region = 'South' and margin_pct < 0;


-- 19. Dashboards querying fact_orders by customer_id and order_date are running slowly — how do we speed them up?

create index idx_orders_customer ON fact_orders(customer_id);
create index idx_orders_date ON fact_orders(order_date);
create index idx_orders_product ON fact_orders(product_id);

-- Diagnose a slow query:
explain 
select * from fact_orders where customer_id = 'CU-12345' and order_date > '2023-06-01';

-- 20. Build an intermediate RFM base table to reuse across three separate downstream queries in the same session.

create temporary table tmp_customer_rfm as 
select 
    customer_id,
    DATEDIFF(CURDATE(), MAX(order_date)) as recency_days,
    COUNT(distinct order_id) as frequency,
    SUM(sales) as monetary
from fact_orders
group by customer_id;

select * from tmp_customer_rfm where frequency > 5;

