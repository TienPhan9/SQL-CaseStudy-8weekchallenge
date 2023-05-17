--B.Runner and Customer Experience
/*How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Is there any relationship between the number of pizzas and how long the order takes to prepare?
What was the average distance travelled for each customer?
What was the difference between the longest and shortest delivery times for all orders?
What was the average speed for each runner for each delivery and do you notice any trend for these values?
What is the successful delivery percentage for each runner?*/

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
set datefirst 1
select count(runner_id) as amount_runners, datepart(week, registration_date) as week
from runners
group by datepart(week, registration_date)

/*What was the average time in minutes it took for each runner to arrive 
at the Pizza Runner HQ to pickup the order?*/
select avg(datediff(MINUTE, order_time, cast(pickup_time as datetime)))
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where pickup_time is not null
/*Is there any relationship between the number of pizzas 
and how long the order takes to prepare?*/
select count(pizza_id) as amountPizza, c.order_id, order_time, pickup_time,
datediff(minute, order_time, cast(pickup_time as datetime)) as takeMinutes
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where pickup_time is not null
group by c.order_id, order_time, pickup_time
order by amountPizza desc
--it also depends on time that customers orders

/*What was the average distance travelled for each customer?*/
select order_id, runner_id, pickup_time,
isnull(null, iif(patindex('%[^a-zA-Z]%', reverse(distance))=1, distance, reverse(substring(reverse(distance),patindex('%[^a-zA-Z]%', reverse(distance)), 100)))) as distance,
isnull(null, iif(patindex('%[^a-zA-Z]%', reverse(duration))=1, duration, reverse(substring(reverse(duration),patindex('%[^a-zA-Z]%', reverse(duration)), 100)))) as duration
,cancellation 
into runnerOrdersTemp
from runner_orders

select avg(cast(distance as float)) from runnerOrdersTemp
where distance is not null
/*What was the difference between the longest and shortest delivery times for all orders?*/
--c1: more detail
declare @amountOrdersDiff int, @distanceDiff int 
select @amountOrdersDiff = 
(select count(c.order_id)
from customer_orders c inner join runnerOrdersTemp r on c.order_id = r.order_id
where duration = 
(select max(cast(duration as float)) 
from customer_orders c inner join runnerOrdersTemp r on c.order_id = r.order_id))
-
(select count(c.order_id)
from customer_orders c inner join runnerOrdersTemp r on c.order_id = r.order_id
where duration = 
(select min(cast(duration as float)) 
from customer_orders c inner join runnerOrdersTemp r on c.order_id = r.order_id))

select @distanceDiff = 
max(cast(distance as float)) - min(cast(distance as float)) from runnerOrdersTemp
print 'difference in amount orders: ' + cast(@amountOrdersDiff as varchar)
print 'difference in distance: '+ cast(@distanceDiff as varchar)

--c2: just focus on that
select max(cast(duration as int)) - min(cast(duration as int)) from runnerOrdersTemp

/*What was the average speed for each runner for each delivery 
and do you notice any trend for these values?*/
alter table runnerOrdersTemp
add durationHour float
update runnerOrdersTemp
set durationHour = round(cast(duration as float) / 60, 2)

select runner_id, round(avg(cast(distance as float) / durationHour),2) as speedAverage from runnerOrdersTemp
group by runner_id

--What is the successful delivery percentage for each runner?*/
select runner_id, count(order_id) as totalOrders into total
from runnerOrdersTemp group by runner_id

select runner_id, count(order_id) as successOrders into success
from runnerOrdersTemp 
where cancellation is null
group by runner_id

select 
total.runner_id, 
totalOrders, 
successOrders, 
cast((cast(successOrders as float) / cast(totalOrders as float))*100 as varchar) + '%'
as percentageSuccess
from total inner join success on total.runner_id = success.runner_id