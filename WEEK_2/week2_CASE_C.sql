use Danny_Pizza
/*What are the standard ingredients for each pizza?*/
select pizza_id, topping_name from (select *  from pizza_recipes
cross apply string_split(cast(toppings as varchar), ',')) as a
inner join pizza_toppings
on a.value = pizza_toppings.topping_id

/*What was the most commonly added extra?*/
select top 1 value, count(value), cast(pizza_toppings.topping_name as varchar(max)) from (
select * from customer_orders
cross apply string_split(extras, ',')
where exclusions is not null) as a
inner join pizza_toppings on a.value = pizza_toppings.topping_id
group by value,cast(pizza_toppings.topping_name as varchar(max))
order by count(value) desc

/*What was the most common exclusion?*/
select top 1 value, count(value), cast(pizza_toppings.topping_name as varchar(max)) from (
select * from customer_orders
cross apply string_split(exclusions, ',')
where exclusions is not null) as a
inner join pizza_toppings on a.value = pizza_toppings.topping_id
group by value,cast(pizza_toppings.topping_name as varchar(max))
order by count(value) desc

/*Generate an order item for each record in the customers_orders table 
in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

with cte_extras(orderId, pizza_id, added_extras) as (
select order_id, pizza_id, 
string_agg(cast(topping_name as varchar(max)), ',')
within group (order by cast(topping_name as varchar(max))) 
from (select order_id, pizza_id, value from customer_orders
cross apply string_split(extras, ',')
group by order_id, pizza_id, value
) as p
inner join pizza_toppings on p.value = pizza_toppings.topping_id
group by order_id, pizza_id),
cte_exclusions (orderId, pizza_id, added_exclusions) as (
select order_id,  pizza_id, 
string_agg(cast(topping_name as varchar(max)), ',') within group (order by cast(topping_name as varchar(max))) 
from (select order_id, pizza_id, value from customer_orders
cross apply string_split(exclusions, ',')
group by order_id, pizza_id, value) as p
inner join pizza_toppings on p.value = pizza_toppings.topping_id
group by order_id,pizza_id)

select order_id, c.pizza_id, concat(cast(e.pizza_name as varchar(max)),
iif(added_extras is null, ' ', ' Extra '+added_extras), 
iif(added_exclusions is null, ' ', ' Exclude '+added_exclusions))
from customer_orders c
inner join pizza_names e on c.pizza_id = e.pizza_id
left join cte_extras a on c.order_id = a.orderId
left join cte_exclusions n on c.order_id = n.orderId
where added_extras is not null or added_exclusions is not null
group by order_id, c.pizza_id, cast(e.pizza_name as varchar(max)), added_extras, added_exclusions

/*Generate an alphabetically ordered comma separated ingredient list 
for each pizza order from the customer_orders table 
and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" chưa làm xong, hồi giải quyết*/ 
select * from pizza_recipes


select order_id, string_agg(cast(topping_name as varchar(max)), ',') 
within group (order by cast(topping_name as varchar(max))) 
from (
select order_id, c.pizza_id, toppings, value from customer_orders c
inner join pizza_recipes s
on c.pizza_id = s.pizza_id
cross apply string_split(cast(toppings as varchar), ',')) as f
inner join pizza_toppings z
on z.topping_id = f.value 
group by pizza_id, order_id

select * from customer_orders
inner join pizza_toppings on customer_orders.pizza_id = pizza_toppings.
select * from pizza_toppings
select * from pizza_names

/*What is the total quantity of each ingredient used in all delivered pizzas 
sorted by most frequent first?*/
select value, count(value), cast(pizza_toppings.topping_name as varchar(max)) from (
select customer_orders.order_id, customer_orders.pizza_id, toppings, value from customer_orders
inner join pizza_recipes on customer_orders.pizza_id = pizza_recipes.pizza_id
cross apply string_split(cast(toppings as varchar), ',')
inner join runner_orders
on customer_orders.order_id = runner_orders.order_id
where cancellation is null) as f
inner join pizza_toppings on pizza_toppings.topping_id = f.value
group by value, cast(pizza_toppings.topping_name as varchar(max))
order by count(value) desc 






