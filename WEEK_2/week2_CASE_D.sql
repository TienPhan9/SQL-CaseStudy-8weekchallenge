use Danny_Pizza

						/*D. Pricing and Ratings*/

/*If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and 
there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?*/
with cte as (
select  iif(pizza_id = 1, 12, 10) as costs
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where cancellation is null)
select sum(costs) from cte

/*What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/
with cte as (
(select c.order_id, count(c.order_id) as count_value, pizza_id 
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
cross apply string_split(extras, ',')
where extras is not null and cancellation is null
group by c.order_id, pizza_id))
select (select sum(iif(pizza_id = 1, 12 + count_value, 10 + count_value)) from cte)
+(select sum(iif(pizza_id=1, 12, 10))
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
where extras is null and cancellation is null)

/*The Pizza Runner team now wants to add an additional ratings system that 
allows customers to rate their runner, how would you design an additional table 
for this new dataset - generate a schema for this new table and insert your own data 
for ratings for each successful customer order between 1 to 5.*/
/*Using your newly generated table - can you join all of the information together to form a table 
which has the following information for successful deliveries?*/
create table ratings_runner
(
	customer_id int,
	rating int
)
insert into ratings_runner(customer_id, rating)
values(101,4),
		(102,3),
		(103,2),
		(104,5),
		(105,5)
--Time between order and pickup
select *,
cast(cast(pickup_time as datetime) - order_time as time) as diff_order_pickup
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
						inner join ratings_runner ra on c.customer_id = ra.customer_id
where cancellation is null

--Average speed
select
avg(cast(left(distance, 
case when patindex('%[a-z]%', distance) = 0 then len(distance) 
else patindex('%[a-z]%', distance)-1 end) as float) /
cast(substring(duration, 1, 
case when patindex('%[^0-9]%', duration) = 0 then len(duration) 
else patindex('%[^0-9]%', duration)-1 end) as int))
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
						inner join ratings_runner ra on c.customer_id = ra.customer_id
where cancellation is null

--Total number of pizzas
select count(pizza_id)
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
						inner join ratings_runner ra on c.customer_id = ra.customer_id
where cancellation is null

/*If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over 
after these deliveries?*/
select *, (cast(substring(distance, 1, iif(patindex('%[a-z]%', distance)=0, len(distance), patindex('%[a-z]%', distance)-1)) as float) * 0.3)
+ iif(pizza_id = 1, 12, 10)
from customer_orders c inner join runner_orders r on c.order_id = r.order_id
						inner join ratings_runner ra on c.customer_id = ra.customer_id
where cancellation is null


