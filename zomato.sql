-- PROJECT ZOMATO 

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'),
(3,'2017-04-21');


drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) VALUES (1,'2014-09-02');
INSERT INTO users(userid,signup_date) VALUES (2,'2015-01-15');
INSERT INTO users(userid,signup_date) VALUES (3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2017-04-19',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (3,'2019-12-18',1);
INSERT INTO sales(userid,created_date,product_id) VALUES (2,'2020-07-20',3);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2019-10-23',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2018-03-19',3);
INSERT INTO sales(userid,created_date,product_id) VALUES (3,'2016-12-20',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2016-11-09',1);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2016-05-20',3);
INSERT INTO sales(userid,created_date,product_id) VALUES (2,'2017-09-24',1);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2017-03-11',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2016-03-11',1);
INSERT INTO sales(userid,created_date,product_id) VALUES (3,'2016-11-10',1);
INSERT INTO sales(userid,created_date,product_id) VALUES (3,'2017-12-07',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (3,'2016-12-15',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (2,'2017-11-08',2);
INSERT INTO sales(userid,created_date,product_id) VALUES (2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


-- Total amount each customer spent on zomato
SELECT sales.userid as USER, SUM(product.price) as TOTAL
FROM sales
JOIN product
ON sales.product_id = product.product_id
GROUP BY sales.userid;

-- How many days each customer visited zomato
 SELECT sales.userid as USER, COUNT(DISTINCT sales.created_date) as DAYS
 FROM sales
 GROUP BY sales.userid;
 
 -- First product purchased by each customer
SELECT sales.userid, sales.created_date, sales.product_id , rank() 
OVER ( partition by sales.userid order by sales.created_date desc ) 
AS 'rank' FROM sales ;

-- Most bought product and how many times
SELECT sales.product_id as PRODUCT , COUNT(sales.product_id) as NUM
FROM sales
GROUP BY sales.product_id
ORDER BY COUNT(sales.product_id) DESC
LIMIT 1 ;

-- Which product is most popular of each user
SELECT sales.userid, sales.product_id, COUNT(sales.product_id) as cnt 
FROM sales
GROUP BY sales.userid, sales.product_id 
ORDER BY userid desc, cnt DESC ;

-- Which item was purchased first by the customer after they became a gold member
SELECT sales.userid, sales.created_date, sales.product_id, goldusers_signup.gold_signup_date , rank() 
OVER ( partition by sales.userid order by sales.created_date ) 
AS 'rank'
FROM sales
JOIN goldusers_signup
ON sales.userid = goldusers_signup.userid AND sales.created_date >= goldusers_signup.gold_signup_date ;

-- Which item was purchased just before customer became the gold member
SELECT sales.userid, sales.created_date, sales.product_id, goldusers_signup.gold_signup_date , rank() 
OVER ( partition by sales.userid order by sales.created_date ) 
AS 'rank'  
FROM sales
JOIN goldusers_signup
ON sales.userid = goldusers_signup.userid AND sales.created_date <= goldusers_signup.gold_signup_date;

-- What is the total order and the amount spent by each customer before becoming a member
SELECT userid, COUNT(created_date), SUM(price)
FROM (SELECT c.* , d.price 
FROM (SELECT sales.userid, sales.created_date, sales.product_id, goldusers_signup.gold_signup_date 
FROM sales
JOIN goldusers_signup
ON sales.userid = goldusers_signup.userid AND sales.created_date <= goldusers_signup.gold_signup_date) c
JOIN product d
ON c.product_id = d.product_id) e 
GROUP BY sales.userid ;

-- Product 1 has 5rs= 1pnt, Product 2 has 10rs= 5pnt, Product 3 has 5rs=1pnt
-- Find out the total number of points earned by each customer 
SELECT userid, SUM(Total)
FROM (SELECT e.*, (AMOUNT/POINTS) AS Total
FROM (SELECT d.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as POINTS --
FROM ( SELECT c.userid, c.product_id, SUM(price) AS AMOUNT
FROM ( SELECT sales.userid, sales.product_id, product.price
FROM sales
INNER JOIN product
ON sales.product_id = product.product_id) c
GROUP BY sales.userid, sales.product_id 
ORDER BY sales.userid ) d ) e) f
GROUP BY userid; 

-- In the first year after joining gold membership, who earned more points if 5 points = 10 rs spent
SELECT d.userid, price/2 as POINTS
FROM (
SELECT c.*, product.price 
FROM(SELECT sales.userid, sales.created_date, sales.product_id, goldusers_signup.gold_signup_date 
FROM sales
JOIN goldusers_signup
ON sales.userid = goldusers_signup.userid AND sales.created_date >= goldusers_signup.gold_signup_date AND sales.created_date <= DATE_ADD(goldusers_signup.gold_signup_date, INTERVAL 1 YEAR) ) c 
JOIN product
ON c.product_id = product.product_id) d ;  

-- Rank all transactions of customer
SELECT * , rank()
OVER ( partition by userid ORDER BY created_date)
AS 'rank'
FROM SALES;

-- Rank all transactions when user had gold membership and other time as 0
SELECT c.*,case when gold_signup_date is NULL then 0 else rank()
OVER ( PARTITION BY userid ORDER BY created_date DESC) end 
AS 'rank'
FROM(
SELECT sales.userid, sales.created_date, sales.product_id, goldusers_signup.gold_signup_date 
FROM sales
LEFT JOIN goldusers_signup
ON sales.userid = goldusers_signup.userid AND sales.created_date >= goldusers_signup.gold_signup_date) c ;



