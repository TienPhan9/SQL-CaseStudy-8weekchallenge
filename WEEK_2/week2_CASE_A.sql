--case A
--How many pizzas were ordered?
/*
How many unique customer orders were made?
How many successful orders were delivered by each runner?
How many of each type of pizza was delivered?
How many Vegetarian and Meatlovers were ordered by each customer?
*/
update runner_orders
set cancellation = null where cancellation = '' or cancellation ='NaN' or cancellation = 'null'
update runner_orders
set pickup_time =null where pickup_time = 'null'
update runner_orders
set distance =null where distance = 'null'
update runner_orders
set duration = null where duration = 'null'
--How many unique customer orders were made?
use Danny_Pizza
select count(pizza_id) from customer_orders
--How many successful orders were delivered by each runner?
select runner_id, count(pizza_id) as amount_orders
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation is null
group by runner_id
--How many of each type of pizza was delivered?
select pizza_id ,count(pizza_id) as each_type_amount 
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation is null
group by pizza_id
--How many Vegetarian and Meatlovers were ordered by each customer?
select 
customer_id, count(customer_orders.pizza_id), iif(customer_orders.pizza_id=1, 'Meat Lover', 'Vegetarian')
from customer_orders inner join pizza_names on customer_orders.pizza_id = pizza_names.pizza_id
group by customer_id, customer_orders.pizza_id

/*
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/
--What was the maximum number of pizzas delivered in a single order?
select top 1 count(customer_orders.order_id) as maxOrdersAmount
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation is null
group by customer_orders.order_id
order by count(customer_orders.order_id) desc
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select count(*)
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where (cancellation is null) and (exclusions is not null or extras is not null) 
union
select count(*)
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where (cancellation is null) and (exclusions is null) 

--How many pizzas were delivered that had both exclusions and extras?
select count(*)
from customer_orders inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation is null and (exclusions is not null and extras is not null)

--What was the total volume of pizzas ordered for each hour of the day?
select 
order_id, pizza_id,
cast(substring(convert(varchar(100), order_time, 121),1, 11) as date) as day, 
left(convert(varchar(50), order_time, 114),2) as hour
into dt from customer_orders

select count(pizza_id), day, hour
from dt
group by day, hour
order by day

--What was the volume of orders for each day of the week?
select order_id,
cast(substring(convert(varchar(50), order_time, 121),1,11) as date) as days, 
datepart(week, order_time) as week
into dt_1 from customer_orders

select days, week, count(*) as amount_orders
from dt_1
group by days, week