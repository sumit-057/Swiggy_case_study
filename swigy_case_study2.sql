-- Swiggy Case Study 

-- 1 Find customers who have never ordered 
use zomato;

SELECT name FROM zomato.users 
WHERE user_id NOT IN (SELECT user_id FROM zomato.orders);

-- 2 What is the average price of each food item listed in the menu?
SELECT T1.f_name, AVG(T2.price) AS Avg_price
FROM zomato.food T1
JOIN zomato.menu T2 ON T1.f_id = T2.f_id
GROUP BY T1.f_id, T1.f_name;

-- 3 Which restaurant received the highest number of orders in the month of June?
SELECT T2.r_name, COUNT(*) AS num_orders
FROM zomato.orders T1
JOIN zomato.restaurants T2 ON T1.r_id = T2.r_id
WHERE MONTHNAME(T1.date) = 'June'
GROUP BY T2.r_name
ORDER BY num_orders DESC
LIMIT 1;

-- 4 Which restaurants generated more than ₹500 in revenue during the month of June?
SELECT T1.r_name,SUM(T2.amount) AS 'Revenue'
FROM zomato.orders T2
JOIN zomato.restaurants T1
ON T1.r_id = T2.r_id
where monthname(date) = 'June'
GROUP BY T1.r_name
HAVING Revenue> 500;

-- 5 show all orders with order details for a particular customer in a particular date range 
SELECT o.order_id,r.r_name,od.f_id,f.f_name FROM zomato.orders o
JOIN zomato.restaurants r
ON o.r_id = r.r_id 
JOIN zomato.order_details od
ON o.order_id = od.order_id
JOIN zomato.food f 
ON od.f_id = f.f_id
WHERE user_id = (SELECT user_id FROM zomato.users WHERE name = 'ankit')
AND (date > '2022-06-10'  AND date < '2022-07-10');

-- 6 find restaurants with max repeated customers
SELECT r.r_name, COUNT(*) AS loyal_customers
FROM (
    SELECT r_id, user_id, COUNT(*) AS Visits
    FROM zomato.orders
    GROUP BY r_id, user_id
    HAVING Visits >= 2
) t
JOIN zomato.restaurants r ON t.r_id = r.r_id
GROUP BY r.r_id, r.r_name
ORDER BY loyal_customers DESC
LIMIT 1;

-- 7 Month over month revenue growth of swiggy

SELECT month,((revenue - prev)/prev)*100
FROM (with sales AS
(
SELECT 
    MONTHNAME(date) AS month,
    MONTH(date) AS month_num,
    SUM(amount) AS revenue
FROM zomato.orders
GROUP BY month, month_num
ORDER BY month_num)

SELECT month,revenue,LAG(revenue,1) OVER(ORDER BY revenue) AS prev FROM sales) t;

-- 8 What is the most frequently ordered food item by each user?
WITH temp AS (
SELECT o.user_id,od.f_id,COUNT(*) AS 'frequency' FROM zomato.order_details od
JOIN zomato.orders o
ON od.order_id = o.order_id
GROUP BY o.user_id,od.f_id)

SELECT u.name,f.f_name,t1.frequency FROM temp t1 
JOIN zomato.users u 
ON t1.user_id = u.user_id
JOIN zomato.food f
ON f.f_id = t1.f_id
WHERE t1.frequency = (SELECT MAX(frequency) FROM temp t2 WHERE t1.user_id = t2.user_id)