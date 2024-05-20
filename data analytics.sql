select * from df_orders

--find top 10 highest revenue generating products
  select top 10 [Product Id],sum(sale_price) as sales
  from df_orders
  group by [Product Id]
  Order by sales desc

  -- find top 5 highest selling products in each region
  with cte as (
  select region,[Product Id],sum(sale_price) as sales
  from df_orders
  group by region,[Product Id])
  select * from (
  select *
  , row_number() over(partition by region order by sales desc) as rn
  from cte) A
  where rn<=5


  --find month over month growth comparision for 2022 and 2023 sales eg:jan 2022 vs jan 2023
  with cte as(
  select year([Order Date]) as order_year, month([Order Date]) as order_month,
  sum(sale_price) as sales
  from df_orders
  group by year([Order Date]),month([Order Date])
  )
  select order_month,order_year
  , case when order_year=2022 then sales else 0 end as sales_2022
  , case when order_year=2023 then sales else 0 end as sales_2023
  from cte
  order by order_month


  -- for each category which month had highest sales
  with cte as (
  select category,format([Order Date],'yyyyMM') as order_year_month
  ,sum(sale_price) as sales
  from df_orders
  group by category,format([Order Date],'yyyyMM')
  )
  select * from (
  select *,
  row_number() over(partition by category order by sales desc ) as rn
  from cte
  ) a
  where rn=1


  --which sub category had highest growth by profit in 2023 compare to 2022
  with cte as (
  select [Sub Category],year([Order Date]) as order_year,
  sum(sale_price) as sales
  from df_orders
  group by [Sub Category],year([Order Date])
  )
  , cte2 as (
  select [Sub Category]
  ,sum(case when order_year=2022 then sales else 0 end) as sales_2022
  ,sum(case when order_year=2023 then sales else 0 end) as sales_2023
  from cte
  group by [Sub Category]
  )
  select *
  ,(sales_2023-sales_2022)*100/sales_2022
  from cte2
  order by(sales_2023-sales_2022)*100/sales_2022 desc
 
