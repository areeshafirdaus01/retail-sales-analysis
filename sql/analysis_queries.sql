--Profitability Distrubution
---By Category Profit VS Revenue based on returned or cancelled order stats
with category_stats as 
    (select 
      productCategory, count(*) as total_orders, 
      count(*) filter(where status in ('Returned', 'Cancelled')) as lost_orders, 
      avg(profit/totalAmount) as avg_profit_margin 
      from sales 
      group by productCategory) 
  select productCategory, 
    total_orders, 
    lost_orders, 
    round((lost_orders *100/total_orders)::numeric,2) as return_rate, 
    round((avg_profit_margin * total_orders)::numeric,2) expected_pi, 
    round((avg_profit_margin* (total_orders-lost_orders))::numeric,2) as adjusted_pi 
  from category_stats 
  order by adjusted_pi desc;
---Margin Distribution
select productCategory, 
  round(min(profit/totalAmount)::numeric,2) as min_margin, 
  round(max(profit/totalAmount)::numeric,2) as max_margin, 
  round(avg(profit/totalAmount)::numeric,2) as avg_margin 
from sales group by productCategory;
-------------------------------------------------------------------------------------------------------
--Channel Economics 
---Analysis of profit margin, order value and profit by sales channel
select salesChannel, 
  min(totalAmount) as min_revenue, 
  max(totalAmount) as max_revenue, 
  round(min(profit/totalAmount)::numeric,2) as min_profit_margin, 
  round(max(profit/totalAmount)::numeric,2) as max_profit_margin, 
  round(avg(profit/totalAmount)::numeric,2) as avg_profit_margin, 
  round(avg(totalAmount)::numeric,2) as avg_order_value, 
  round(min(profit)::numeric,2) as min_profit, 
  round(max(profit)::numeric,2) as profit_max, 
  round(avg(profit)::numeric,2) as avg_profit 
from sales group by salesChannel;
---revenue by channel
select salesChannel, 
  round(sum(profit)::numeric,2) as total_profit, 
  round(sum(totalAmount)::numeric,2) as total_revenue 
from sales group by salesChannel;
------------------------------------------------------------------------------------------------------------
--Pareto Principle
select * from
  (select customerID, revenue, rank() over(order by revenue desc) as customer_revenue, 
  round(sum(revenue) over(order by revenue desc)/sum(revenue) over()::numeric, 3) as cumulative_revenue 
  from 
    ( select customerID, round(sum(totalAmount)::numeric,3) as revenue 
  from sales group by customerID) 
  t) x 
  where cumulative_revenue <=0.08;
-------------------------------------------------------------------------------------------------------------
--Time Trend Analysis
select date_trunc('month', saleDate) as month, 
  round(sum(totalAmount)::numeric,2) as monthly_revenue, 
  round(sum(profit)::numeric,2) as monthly_profit, 
  round(sum(quantity)::numeric,2) as monthly_order_quantity 
from sales group by month order by month;
