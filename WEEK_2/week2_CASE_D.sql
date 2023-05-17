use Danny_Pizza

						/*D. Pricing and Ratings*/

/*If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and 
there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?*/
select sum(iif(customer_orders.pizza_id = 1, 12, 10)) as totalMoney from customer_orders
inner join pizza_names on customer_orders.pizza_id = pizza_names.pizza_id
inner join runner_orders on customer_orders.order_id = runner_orders.order_id
where cancellation is null

/*What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/
select iif(value is null, 0, value) from (
select order_id, value from customer_orders
cross apply string_split(extras, ',')) as split