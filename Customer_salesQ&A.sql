CREATE DATABASE IF NOT EXISTS sales_db1;
use sales_db1;

create table customers (
customer_id INT PRIMARY KEY,
customer_name varchar(50) not null,
email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50),
    state VARCHAR(50),
    registration_date DATE
);

Select * from customers;

Insert into customers (customer_id, customer_name, email, phone, city, state, registration_date)
VALUES
(101, 'Ravi Kumar', 'ravi@gmail.com', '9876543210', 'Hyderabad', 'Telangana', '2024-01-15'),
(102, 'Priya Sharma', 'priya@gmail.com', '9876543211', 'Bangalore', 'Karnataka', '2024-02-10'),
(103, 'Arun Reddy', 'arun@gmail.com', '9876543212', 'Hyderabad', 'Telangana', '2024-03-05'),
(104, 'Sneha Rao', 'sneha@gmail.com', '9876543213', 'Chennai', 'Tamil Nadu', '2024-03-20'),
(105, 'Kiran Patel', 'kiran@gmail.com', '9876543214', 'Mumbai', 'Maharashtra', '2024-04-12'),
(106, 'Anjali Singh', 'anjali@gmail.com', '9876543215', 'Delhi', 'Delhi', '2024-05-18'),
(107, 'Vijay Kumar', 'vijay@gmail.com', '9876543216', 'Pune', 'Maharashtra', '2024-06-25'),
(108, 'Neha Gupta', 'neha@gmail.com', '9876543217', 'Kolkata', 'West Bengal', '2024-07-10'),
(109, 'Rahul Verma', 'rahul@gmail.com', '9876543218', 'Hyderabad', 'Telangana', '2024-08-15'),
(110, 'Pooja Mehta', 'pooja@gmail.com', '9876543219', 'Ahmedabad', 'Gujarat', '2024-09-01');


-- ====================== Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    order_status VARCHAR(30),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

INSERT INTO orders
(order_id, customer_id, order_date, product_name, category,
 quantity, unit_price, discount, order_status)
VALUES
(1001, 101, '2024-01-20', 'Laptop', 'Electronics', 1, 65000, 5, 'Delivered'),
(1002, 102, '2024-02-15', 'Mobile Phone', 'Electronics', 2, 25000, 10, 'Delivered'),
(1003, 101, '2024-02-20', 'Headphones', 'Electronics', 2, 3000, 5, 'Delivered'),
(1004, 103, '2024-03-10', 'Office Chair', 'Furniture', 1, 12000, 0, 'Delivered'),
(1005, 104, '2024-03-25', 'Table', 'Furniture', 1, 18000, 5, 'Shipped'),
(1006, 105, '2024-04-15', 'Refrigerator', 'Appliances', 1, 45000, 8, 'Delivered'),
(1007, 106, '2024-05-20', 'Washing Machine', 'Appliances', 1, 35000, 10, 'Cancelled'),
(1008, 107, '2024-06-30', 'Television', 'Electronics', 1, 55000, 7, 'Delivered'),
(1009, 101, '2024-07-05', 'Keyboard', 'Electronics', 3, 1500, 5, 'Delivered'),
(1010, 108, '2024-07-15', 'Sofa', 'Furniture', 1, 40000, 10, 'Shipped'),
(1011, 109, '2024-08-20', 'Mobile Phone', 'Electronics', 1, 30000, 5, 'Delivered'),
(1012, 103, '2024-08-25', 'Laptop', 'Electronics', 2, 70000, 8, 'Delivered'),
(1013, 110, '2024-09-05', 'Microwave Oven', 'Appliances', 2, 12000, 5, 'Pending'),
(1014, 105, '2024-09-10', 'Air Conditioner', 'Appliances', 1, 50000, 10, 'Delivered'),
(1015, 102, '2024-09-15', 'Mouse', 'Electronics', 2, 1000, 0, 'Delivered');

Select * from orders;

Select * from customers c INNER JOIN orders o 
ON c.customer_id = o.customer_id;

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.product_name,
    o.quantity,
    o.unit_price
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;

-- Calculate Order Amount
       SELECT
    o.order_id,
    c.customer_name,
    o.product_name,
    o.quantity,
    o.unit_price,
    o.discount,
    (o.quantity * o.unit_price) AS gross_amount,
  
   ROUND ((o.quantity * o.unit_price) -
       ((o.quantity * o.unit_price) * o.discount / 100), 2) AS net_amount
       
    FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id;
  
    
    SELECT
       c.customer_name,
    c.customer_id,
    
  sum(
  (o.quantity * o.unit_price) -
       ((o.quantity * o.unit_price) * o.discount / 100)
       ) AS Sum_sales
       FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
    Group by  c.customer_id;
    
    -- Total Sales by Customer
    
    SELECT
    c.customer_id,
    c.customer_name,
    SUM(
        (o.quantity * o.unit_price) -
        ((o.quantity * o.unit_price) * o.discount / 100)
    ) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;
   
   
   -- Customers Who Have Not Placed Any Order
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

 -- Customers With More Than 2 Orders
  SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(o.order_id) > 2;

 -- Highest Order Amount
 
 SELECT
    o.order_id,
    c.customer_name,
    o.product_name,
    o.quantity * o.unit_price AS order_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY order_amount DESC
LIMIT 1;

-- Find the number of orders placed by each customer , Find customers who placed more than 1 orders.
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
Having count(o.order_id) >1;

-- Find total sales for each customer.
SELECT
    c.customer_name,
    ROUND(
        SUM(
            (o.quantity * o.unit_price)
            - ((o.quantity * o.unit_price) * o.discount / 100)
        ), 2
    ) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;

-- Find total sales by product category.
SELECT
    category,
    ROUND(
        SUM(
            (quantity * unit_price)
            - ((quantity * unit_price) * discount / 100)
        ), 2
    ) AS total_sales
FROM orders
GROUP BY category;

-- =================Real-Time Interview Questions===========================

-- 19 Find the customer who has spent the most money

select c.customer_name, c.customer_id,
sum(o.unit_price * o.quantity) as spent
from customers c join orders o 
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
Order by spent DESC
LIMIT 1
;

-- After discount 
select c.customer_name, c.customer_id,
ROUND(
	sum(
		(o.unit_price * o.quantity) -
        (o.unit_price * o.quantity)*discount/100), 2) as spent
from customers c join orders o 
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
Order by spent DESC
-- LIMIT 1
;

-- 20. Find the second-highest spending customer.
select c.customer_name, c.customer_id,
ROUND(
	sum(
		(o.unit_price * o.quantity) -
        (o.unit_price * o.quantity)*discount/100), 2) as spent
from customers c join orders o 
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
Order by spent DESC
LIMIT 1,1
;

-- Find the customer with the highest number of orders.

select c.customer_id, c.customer_name, count(o.order_id) total_orders
from customers c join orders o 
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
Order by total_orders DESC
LIMIT 1
;

select c.customer_id, c.customer_name, count(o.order_id) total_orders,
rank() over(order by count(o.order_id) DESC) as Rnk
from customers c join orders o 
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name

;

WITH ranked_customers AS (
    SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders,
           DENSE_RANK() OVER (ORDER BY COUNT(o.order_id) DESC) as rnk
    FROM customers c 
    JOIN orders o ON c.customer_id = o.customer_id 
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_orders
FROM ranked_customers
WHERE rnk = 1;


select c.customer_name, o.order_id, o.product_name, 
ROUND(
		(o.unit_price * o.quantity) -
        (o.unit_price * o.quantity)*discount/100, 2) as order_amount
from customers c join orders o 
ON c.customer_id = o.customer_id
Order by o.order_id
;

-- Find total revenue from only Delivered orders. & Find total revenue by order status.
Select * from orders;

select o.order_status,
ROUND(sum((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) as revenue       
from customers c join orders o 
ON c.customer_id = o.customer_id
group by o.order_status
-- having o.order_status = 'delivered'
;



-- Find the average order value by order_status AVG()

select o.order_status, count(o.order_id) as Number_of_orders,
ROUND(avg((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) avg_order_value
       from customers c join orders o 
ON c.customer_id = o.customer_id
group by o.order_status
-- having o.order_status = 'delivered'
;


-- Find the average order value by order_status (SUM() / COUNT())

select o.order_status, count(o.order_id) as Number_of_orders,
ROUND(sum((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) as total_sales,

 ROUND(sum((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100) / count(o.order_id), 3) as avg_order_value
       from customers c join orders o 
ON c.customer_id = o.customer_id
group by o.order_status
;


-- Find the average order value 

select count(o.order_id) as Number_of_orders,
ROUND(sum((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) sum_order_value,
ROUND(avg((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) avg_order_value
       from customers c join orders o 
ON c.customer_id = o.customer_id
;

-- Find customers whose total spending is greater than ₹50,000.
select * from orders;

select c.customer_id,
c.customer_name, 
ROUND(sum((o.unit_price * o.quantity) -
(o.unit_price * o.quantity) * discount/100), 2) total_spending

from customers c 
JOIN orders o
ON c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
 having total_spending > 50000
;

SELECT 
    c.customer_id,
    c.customer_name, 
    ROUND(SUM((o.unit_price * o.quantity) * (1 - o.discount / 100)), 2) AS total_spending
FROM 
    customers c 
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, 
    c.customer_name
HAVING 
    SUM((o.unit_price * o.quantity) * (1 - o.discount / 100)) > 50000;




