-- Ahmed Ibrahim C402

/*
Aggregate Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     THEN records returned. 
*/

USE orderbook_activity_db;

-- #1: How many users do we have?
SELECT COUNT(DISTINCT userid) AS total_users FROM User;
/*
+-------------+
| total_users |
+-------------+
|           7 |
+-------------+
1 row in set (0.00 sec)
*/


-- #2: List the username, userid, and number of orders each user has placed.
SELECT U.uname, U.userid, COUNT(O.orderid) AS num_orders
FROM User U
LEFT JOIN `Order` O ON U.userid = O.userid
GROUP BY U.uname, U.userid;
/*
+--------+--------+------------+
| uname  | userid | num_orders |
+--------+--------+------------+
| admin  |      1 |          3 |
| alice  |      5 |          8 |
| james  |      3 |          3 |
| kendra |      4 |          5 |
| robert |      6 |          5 |
7 rows in set (0.00 sec)
*/


-- #3: List the username, symbol, and number of orders placed for each user and for each symbol. 
-- Sort results in alphabetical order by symbol.
SELECT U.uname, O.symbol, COUNT(O.orderid) AS num_orders
FROM User U
JOIN `Order` O ON U.userid = O.userid
GROUP BY U.uname, O.symbol
ORDER BY O.symbol ASC;
/*
+--------+--------+------------+
| uname  | symbol | num_orders |
+--------+--------+------------+
| alice  | A      |          5 |
| james  | A      |          1 |
| robert | AAA    |          1 |
| admin  | AAPL   |          1 |
| robert | AAPL   |          1 |
19 rows in set (0.01 sec)
*/


-- #4: Perform the same query as the one above, but only include admin users.
SELECT U.uname, O.symbol, COUNT(O.orderid) AS num_orders
FROM User U
JOIN `Order` O ON U.userid = O.userid
WHERE U.uname = 'admin'
GROUP BY O.symbol
ORDER BY O.symbol ASC;
/*
+-------+--------+------------+
| uname | symbol | num_orders |
+-------+--------+------------+
| admin | AAPL   |          1 |
| admin | GS     |          1 |
| admin | WLY    |          1 |
+-------+--------+------------+
3 rows in set (0.00 sec)
*/

-- #5: List the username and the average absolute net order amount for each user with an order.
-- Round the result to the nearest hundredth and use an alias (averageTradePrice).
-- Sort the results by averageTradePrice with the largest value at the top.
SELECT U.uname, ROUND(ABS(AVG(O.shares * O.price)), 2) AS averageTradePrice
FROM User U
JOIN `Order` O ON U.userid = O.userid
GROUP BY U.uname
ORDER BY averageTradePrice DESC;
/*
+--------+-------------------+
| uname  | averageTradePrice |
+--------+-------------------+
| kendra |          17109.53 |
| admin  |          10774.87 |
| alice  |           6000.47 |
| james  |           1187.80 |
| robert |            536.92 |
+--------+-------------------+
5 rows in set (0.00 sec)
*/

-- #6: How many shares for each symbol does each user have?
-- Display the username and symbol with number of shares.
SELECT U.uname, O.symbol, SUM(O.shares) AS total_shares
FROM User U
JOIN `Order` O ON U.userid = O.userid
GROUP BY U.uname, O.symbol;
/*
+--------+--------+--------------+
| uname  | symbol | total_shares |
+--------+--------+--------------+
| admin  | WLY    |          100 |
| admin  | GS     |          100 |
| admin  | AAPL   |          -15 |
| alice  | A      |           18 |
| alice  | SPY    |          100 |
19 rows in set (0.00 sec)
*/

-- #7: What symbols have at least 3 orders?
SELECT O.symbol, COUNT(O.orderid) AS num_orders
FROM `Order` O
GROUP BY O.symbol
HAVING num_orders >= 3;
/*
+--------+------------+
| symbol | num_orders |
+--------+------------+
| A      |          6 |
| AAPL   |          3 |
| WLY    |          3 |
+--------+------------+
3 rows in set (0.00 sec)
*/

-- #8: List all the symbols and absolute net fills that have fills exceeding $100.
-- Do not include the WLY symbol in the results.
-- Sort the results by highest net with the largest value at the top.
SELECT F.symbol, SUM(ABS(F.share * F.price)) AS net_fills
FROM Fill F
WHERE F.symbol != 'WLY'
GROUP BY F.symbol
HAVING net_fills > 100
ORDER BY net_fills DESC;
/*
+--------+-----------+
| symbol | net_fills |
+--------+-----------+
| SPY    |  54859.50 |
| AAPL   |   7038.00 |
| GS     |   6112.60 |
| A      |   2597.80 |
| TLT    |   1978.60 |
+--------+-----------+
5 rows in set (0.00 sec)
*/

-- #9: List the top five users with the greatest amount of outstanding orders.
-- Display the absolute amount filled, absolute amount ordered, and net outstanding.
-- Sort the results by the net outstanding amount with the largest value at the top.
SELECT U.uname, 
       SUM(ABS(F.share)) AS total_filled, 
       SUM(ABS(O.shares)) AS total_ordered, 
       SUM(ABS(O.shares - F.share)) AS net_outstanding
FROM User U
JOIN `Order` O ON U.userid = O.userid
JOIN Fill F ON O.orderid = F.orderid
GROUP BY U.uname
ORDER BY net_outstanding DESC;
/*
+--------+--------------+---------------+-----------------+
| uname  | total_filled | total_ordered | net_outstanding |
+--------+--------------+---------------+-----------------+
| admin  |           35 |           215 |             250 |
| alice  |           95 |           120 |             215 |
| kendra |           95 |            95 |             190 |
| robert |           35 |            60 |              95 |
| james  |           20 |            20 |              40 |
+--------+--------------+---------------+-----------------+
5 rows in set (0.01 sec)
*/