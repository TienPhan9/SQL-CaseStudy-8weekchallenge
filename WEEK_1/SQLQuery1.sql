/*
case study 1
*/

create database Danny
use Danny

create table members
(
	customer_id nvarchar(1),
	join_date date
)

create table menu
(
	product_id integer,
	product_name varchar(5),
	price integer
)
create table sales
(
	customer_id nvarchar(1),
	order_date date,
	product_id integer
)

insert into sales(customer_id, order_date, product_id)
values
('A', '2021-01-01',1),
('A', '2021-01-01',2),
('A', '2021-01-07',2),
('A', '2021-01-10',3),
('A', '2021-01-11',3),
('A', '2021-01-11',3),
('B', '2021-01-01',2),
('B', '2021-01-02',2),
('B', '2021-01-04',1),
('B', '2021-01-11',1),
('B', '2021-01-16',3),
('B', '2021-02-01',3),
('C', '2021-01-01',3),
('C', '2021-01-01',3),
('C', '2021-01-07',3)

insert into sales (customer_id, order_date, product_id)
values ('B', '2020-12-01',3)
insert into menu(product_id, product_name, price)
values
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12)

insert into members(customer_id, join_date)
values
('A', '2021-01-07'),
('B', '2021-01-09')

--What is the total amount each customer spent at the restaurant?
select sales.customer_id, spent=sum(price)
from menu
inner join sales
on menu.product_id = sales.product_id
group by sales.customer_id

--How many days has each customer visited the restaurant?
select distinct customer_id, count(distinct order_date) from sales
group by customer_id
--What was the first item from the menu purchased by each customer?
select distinct customer_id, product_name  from sales
inner join menu
on sales.product_id = menu.product_id
where order_date in (select min(order_date) from sales group by customer_id, order_date)
order by customer_id
select customer_id, min(order_date), product_name from sales
inner join menu
on sales.product_id = menu.product_id
group by customer_id, product_name
--What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 count(product_id) as amount_product, product_id from sales
group by product_id
order by count(product_id) desc

--Which item was the most popular for each customer?
select top 3 count(product_id) as sum_each, product_id, customer_id from sales
where customer_id in (select distinct customer_id from sales group by customer_id)
group by customer_id, product_id
order by product_id desc

--Which item was purchased first by the customer after they became a member?
--lay min cua nhung ngay sau ngay became a member
--lack of information of customer C
select top 2 sales.product_id, sales.customer_id, sales.order_date from sales
where order_date in 
(select order_date from sales inner join members on sales.customer_id = members.customer_id
where order_date > join_date)
and sales.customer_id in 
(select distinct customer_id from sales)
group by product_id, customer_id, order_date 
having order_date = min(order_date)

/*
7/Which item was purchased just before the customer became a member?

8/What is the total items and amount spent for each member before they became a member?
9/If each $1 spent equates to 10 points and sushi has a 2x points 
multiplier - how many points would each customer have?
10/In the first week after a customer joins the program (including their join date) they earn 2x points
on all items, not just sushi- how many points do customer A and B have at the end of January?

*/
--7/Which item was purchased just before the customer became a member?
select sales.customer_id,  sales.product_id, sales.order_date from sales
where sales.order_date in 
(select order_date from sales inner join members on sales.customer_id = members.customer_id
where order_date < join_date)
and sales.customer_id in 
(select distinct customer_id from sales)
group by customer_id, product_id, order_date

--8/What is the total items and amount spent for each member before they became a member?
select count(sales.product_id) as amount_items, sales.customer_id, order_date, sales.product_id
into new 
from sales
inner join members
on sales.customer_id=members.customer_id
where sales.order_date < join_date
group by sales.customer_id, order_date, sales.product_id

select customer_id, sum(price) as spent from new
inner join menu
on menu.product_id= new.product_id
group by customer_id 

/*

9/If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
how many points would each customer have?
10/In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - how many points do customer A and B 
have at the end of January?
*/

select customer_id,
sum((case when
product_name = 'sushi' then price * 20 else price * 10 
end))as point
from menu 
inner join sales
on menu.product_id = sales.product_id
group by customer_id

--10/In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi - how many points do customer A and B 
--have at the end of January?
--select * from sales inner join members on sales.customer_id=members.customer_id
select sales.customer_id, join_date, order_date,
product_name, price,
point = price * (case when product_name = 'sushi' then 20 else 10 end)
into cus
from sales inner join menu
on sales.product_id = menu.product_id
inner join members
on sales.customer_id = members.customer_id

select customer_id, iif((datepart(day, order_date) >= datepart(day, join_date) 
and datediff(day, join_date, order_date)<=7), price * 20, point) as point_2 into Spending  from cus

select customer_id, sum(point_2) from Spending
group by customer_id

/* bonus:
Join All The Things
*/
select sales.customer_id, order_date,  product_name, price,
member = iif(order_date < join_date, 'N', 'Y') into bonus
from sales inner join members on sales.customer_id = members.customer_id
inner join menu on sales.product_id = menu.product_id

select *, order_date, ranking = case when order_date < join_date then null
						when order_date = join_date then 1
						when order_date > join_date then 2
						when (order_date > join_date and order_date >= max(order_date)) then 3 end from bonus 	
inner join members
on bonus.customer_id = members.customer_id

select * from bonus
select dense_rank() over (order by order_date desc) pro_rank
from bonus





select sales.customer_id , sum(case when product_name = 'Sushi' then price * 20
						else price*10 end)  from sales 
inner join members
on sales.customer_id = members.customer_id
inner join menu
on sales.product_id = menu.product_id
where price= 
(
	case 
		when (datepart(day, order_date) > datepart(day, join_date) 
		and datepart(month, order_date) = datepart(month, join_date)
		and datepart(year, order_date) = datepart(year, join_date)
		and datediff(day, join_date, order_date)<=7) then 20
	end
)
group by sales.customer_id














