--SQL PROJECT 1

--Creating aisle table
CREATE TABLE aisle(
aisle_id INT PRIMARY KEY,
aisle VARCHAR(50) NOT NULL
);

--creating department table
CREATE TABLE department(
department_id INT PRIMARY KEY,
department VARCHAR(50)
);

--creating products table
CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(250),
aisle_id INT REFERENCES aisle(aisle_id),
department_id INT REFERENCES department(department_id),
unit_cost NUMERIC(10,2),
unit_price NUMERIC(10,2)
);
	
--creating orders table
CREATE TABLE orders(
order_id INT PRIMARY KEY,
user_id INT,
product_id INT REFERENCES products(product_id),
quantity INT,
order_date DATE,
order_dow INT,
order_hour_of_day INT,
days_since_prior_order INT,
order_status VARCHAR(50)
);

/*Q1 What are the top_selling products by revenue and
how much revenue have they generated?
*/
SELECT p.product_name,
	SUM(p.unit_price*o.quantity) AS Revenue,
	 '$' || SUM(p.unit_price*o.quantity) AS Total_Revenue
FROM products AS p
JOIN orders AS o USING(product_id)
GROUP BY p.product_name
ORDER BY Revenue DESC;

--Q2 On which day of the week are chocolate mostly sold?
SELECT o.order_dow,
	CASE
	WHEN(o.order_dow) = 0 THEN 'Sunday'
	WHEN(o.order_dow) = 1 THEN 'Monday'
	WHEN(o.order_dow) = 2 THEN 'Tuesday'
	WHEN(o.order_dow) = 3 THEN 'Wednesday'
	WHEN(o.order_dow) = 4 THEN 'Thursday'
	WHEN(o.order_dow) = 5 THEN 'Friday'
	ELSE 'Saturday'
	END AS Day_of_the_week,
	SUM(o.quantity) AS Total_quantity
FROM orders AS o
JOIN products AS p USING(product_id)
WHERE p.product_name ILIKE '%chocolate%'
GROUP BY o.order_dow
ORDER BY SUM(o.quantity) DESC
LIMIT 1
 --So Sunday is the day with the highest sales of chocolate.

SELECT order_date, TO_CHAR(order_date, 'Day')
FROM orders AS o
JOIN products AS p USING(product_id)
WHERE p.product_name ILIKE '%chocolate%'
GROUP BY o.order_date, TO_CHAR(order_date, 'Day')
ORDER BY SUM(o.quantity) DESC
LIMIT 1

/*Q3 Do we have any department where we have made over $15 
in revenue and what is the profit?
*/
SELECT d.department,
	'$'|| SUM(p.unit_price*o.quantity) AS Total_Revenue,
	'$'|| SUM((p.unit_price-p.unit_cost)*o.quantity) AS Total_Profit
FROM department AS d
JOIN products AS p USING(department_id)
JOIN orders AS o USING(product_id)
GROUP BY department
HAVING SUM(p.unit_price*o.quantity)>15000000
--7 departments made over $15M in revenue.

/*Q4 Is it true that customers buy more alcoholic products 
on Xmas day 2019?
*/
SELECT d.department,
	SUM(o.quantity) AS Total_Quantity
FROM department AS d
JOIN products AS p USING(department_id)
JOIN orders AS o USING(product_id)
WHERE order_date = '2019-12-25' 
GROUP BY department
ORDER BY department 
-- NO, customers didn't buy more alcoholic products on Xmas day 2019.

--Q5 Which year did Instacart generate the most profit?
SELECT
	EXTRACT(YEAR FROM order_date) AS YEARS,
	'$'|| SUM((p.unit_price-p.unit_cost)*o.quantity) AS Total_Profit
FROM orders AS o
JOIN products AS p USING(product_id)
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY SUM((p.unit_price-p.unit_cost)*o.quantity) DESC
LIMIT 1

--Q6 How long has it been since the last cheese order?
SELECT 
	CURRENT_DATE-MAX(order_date) AS Day_of_last_order
FROM aisle AS a
JOIN products AS p USING(aisle_id)
JOIN orders AS o USING(product_id)
WHERE aisle ILIKE '%cheese%'


--Q7 What time of the day do we sell alcohol the most?
SELECT o.order_hour_of_day,
	CASE
	WHEN(o.order_hour_of_day) = 0 THEN '12Midnight'
	WHEN(o.order_hour_of_day) = 1 THEN '1AM'
	WHEN(o.order_hour_of_day) = 2 THEN '2AM'
	WHEN(o.order_hour_of_day) = 3 THEN '3AM'
	WHEN(o.order_hour_of_day) = 4 THEN '4AM'
	WHEN(o.order_hour_of_day) = 5 THEN '5AM'
	WHEN(o.order_hour_of_day) = 6 THEN '6AM'
	WHEN(o.order_hour_of_day) = 7 THEN '7AM'
	WHEN(o.order_hour_of_day) = 8 THEN '8AM'
	WHEN(o.order_hour_of_day) = 9 THEN '9AM'
	WHEN(o.order_hour_of_day) = 10 THEN '10AM'
	WHEN(o.order_hour_of_day) = 11 THEN '11AM'
	WHEN(o.order_hour_of_day) = 12 THEN '12Noon'
	WHEN(o.order_hour_of_day) = 13 THEN '1PM'
	WHEN(o.order_hour_of_day) = 14 THEN '2PM'
	WHEN(o.order_hour_of_day) = 15 THEN '3PM'
	WHEN(o.order_hour_of_day) = 16 THEN '4PM'
	WHEN(o.order_hour_of_day) = 17 THEN '5PM'
	WHEN(o.order_hour_of_day) = 18 THEN '6PM'
	WHEN(o.order_hour_of_day) = 19 THEN '7PM'
	WHEN(o.order_hour_of_day) = 20 THEN '8PM'
	WHEN(o.order_hour_of_day) = 21 THEN '9PM'
	WHEN(o.order_hour_of_day) = 22 THEN '10PM'
	ELSE '11PM'
	END AS Time_of_the_day,
	SUM(o.quantity) AS Total_quantity_sold
FROM department AS d
JOIN products AS p USING(department_id)
JOIN orders AS o USING(product_id)
WHERE department = 'alcohol'
GROUP BY o.order_hour_of_day
ORDER BY SUM(o.quantity) DESC
LIMIT 1


/*Q8 What is the total revenue generated in Qtr 2 & 3 
of 2016 from breads?
*/
SELECT 
	'$'|| SUM(p.unit_price*o.quantity) AS Total_Revenue
FROM products AS p
JOIN orders AS o USING(product_id)
WHERE p.product_name ILIKE '%bread%' 
	AND o.order_date BETWEEN '2016-04-01' AND '2016-09-30';

--Q9 Which 3 products do people buy at night(2020-2022)?
SELECT product_name,
	SUM(o.quantity) AS Total_quantity
FROM products AS p
JOIN orders AS o USING(product_id)
WHERE o.order_date BETWEEN '2020-01-01' AND '2022-12-31'
	AND (o.order_hour_of_day BETWEEN '18' AND '23' 
	OR o.order_hour_of_day BETWEEN '0' AND '5')
GROUP BY p.product_name
ORDER BY Total_quantity DESC
LIMIT 3;

--Q10 What is the totalrevenue generated from juice products?
SELECT 
	'$'|| SUM(p.unit_price*o.quantity) AS Total_Revenue
FROM products AS p
JOIN orders AS o USING(product_id)
WHERE product_name ILIKE '%juice%'

