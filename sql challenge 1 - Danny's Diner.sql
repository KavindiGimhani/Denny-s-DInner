CREATE SCHEMA dannys_diner;

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- Q1: What is the total amount each customer spent at the restaurant?

Select s.customer_id, sum(m.price) As total_spent
from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;

-- How many days has each customer visited the restaurant?

Select customer_id, count(distinct(order_date)) as no_of_days
from sales
group by customer_id;

-- What was the first item from the menu purchased by each customer?

Select customer_id, product_name From(
	SELECT s.*,
	dense_rank() over(partition by customer_id order by order_date) as den_rnk
	FROM dannys_diner.sales s) rnk
join menu m
on m.product_id = rnk.product_id
where rnk.den_rnk<2;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

Select m.product_name, count(s.product_id) as purchased_times 
From sales s
join menu m
on s.product_id = m.product_id
group by product_name
order by purchased_times desc
limit 1;

-- Which item was the most popular for each customer?

Select customer_id, product_name, order_count
From (
SELECT s.customer_id,m.product_id,m.product_name, count(m.product_id) As order_count,
dense_rank() over(partition by customer_id order by count(m.product_id) desc) As dense_rnk
FROM sales s
Join menu m 
on s.product_id = m.product_id
group by s.customer_id, m.product_name, m.product_id) most_purchase
Where dense_rnk = 1;

-- Which item was purchased first by the customer after they became a member

Select first_as_member.customer_id, first_as_member.product_id, m.product_name
From(
SELECT mb.customer_id, s.product_id , dense_rank() Over(partition by mb.customer_id order by s.order_date) As den_rnk
FROM dannys_diner.members mb
join sales s
on mb.customer_id=s.customer_id
where s.order_date >= mb.join_date) as first_as_member
join menu m
on first_as_member.product_id = m.product_id
where den_rnk = 1
order by customer_id asc
;

-- Which item was purchased just before the customer became a member?

Select just_before_member.customer_id, just_before_member.product_id, m.product_name
From(
SELECT mb.customer_id, s.product_id, dense_rank() Over(partition by mb.customer_id order by s.order_date desc) As den_rnk
FROM dannys_diner.members mb
join sales s
on mb.customer_id=s.customer_id
where s.order_date < mb.join_date) as just_before_member
join menu m
on just_before_member.product_id = m.product_id
where den_rnk = 1
order by just_before_member.customer_id asc ;


-- What is the total items and amount spent for each member before they became a member?


SELECT s.customer_id, count(m.product_name) as order_count, sum(m.price) as total_sales
FROM dannys_diner.members mb
join sales s
on mb.customer_id=s.customer_id
join menu m
on m.product_id=s.product_id
where s.order_date < mb.join_date
group by s.customer_id;



-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, sum(if(product_name = "sushi",price*20, price*10)) as total_points
FROM sales s
join menu m
on m.product_id=s.product_id
group by customer_id
order by customer_id
;


-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?





