-- Ahmed Ibrahim C402

/*
Basic Selects

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     Also include the total records returned.
*/

USE orderbook_activity_db;

-- #1: List all users, including username and dateJoined.
SELECT u.uname, u.dateJoined 
FROM User u;
/*
+--------+---------------------+
| uname  | dateJoined          |
+--------+---------------------+
| admin  | 2023-02-14 13:13:28 |
| wiley  | 2023-04-01 13:13:28 |
| james  | 2023-03-15 19:15:48 |
| kendra | 2023-03-15 19:16:06 |
| alice  | 2023-03-15 19:16:21 |
7 rows in set (0.00 sec)
*/


-- #2: List the username and datejoined from users with the newest users at the top.
SELECT u.uname, u.dateJoined 
FROM User u
ORDER BY u.dateJoined DESC;
/*
+--------+---------------------+
| uname  | dateJoined          |
+--------+---------------------+
| wiley  | 2023-04-01 13:13:28 |
| sam    | 2023-03-15 19:16:59 |
| robert | 2023-03-15 19:16:43 |
| alice  | 2023-03-15 19:16:21 |
| kendra | 2023-03-15 19:16:06 |
7 rows in set (0.00 sec)
*/


-- #3: List all usernames and dateJoined for users who joined in March 2023.
SELECT u.uname, u.dateJoined 
FROM User u
WHERE u.dateJoined >= '2023-03-01' AND u.dateJoined < '2023-04-01';
/*
+--------+---------------------+
| uname  | dateJoined          |
+--------+---------------------+
| james  | 2023-03-15 19:15:48 |
| kendra | 2023-03-15 19:16:06 |
| alice  | 2023-03-15 19:16:21 |
| robert | 2023-03-15 19:16:43 |
| sam    | 2023-03-15 19:16:59 |
+--------+---------------------+
5 rows in set (0.00 sec)
*/


-- #4: List the different role names a user can have.
SELECT DISTINCT r.name 
FROM Role r;
/*
+-------+
| name  |
+-------+
| admin |
| it    |
| user  |
+-------+
3 rows in set (0.00 sec)
*/


-- #5: List all the orders.
SELECT * 
FROM `Order`;
/*
+---------+--------+--------+------+---------------------+--------+--------+-----------------------+
| orderid | userid | symbol | side | orderTime           | shares | price  | status                |
+---------+--------+--------+------+---------------------+--------+--------+-----------------------+
|       1 |      1 | WLY    |    1 | 2023-03-15 19:20:35 |    100 |  38.73 | partial_fill          |
|       2 |      6 | WLY    |    2 | 2023-03-15 19:20:50 |    -10 |  38.73 | filled                |
|       3 |      6 | NFLX   |    2 | 2023-03-15 19:21:12 |   -100 | 243.15 | pending               |
|       4 |      5 | A      |    1 | 2023-03-15 19:21:31 |     10 | 129.89 | filled                |
|       5 |      3 | A      |    2 | 2023-03-15 19:21:39 |    -10 | 129.89 | filled                |
24 rows in set (0.00 sec)
*/


-- #6: List all orders in March where the absolute net order amount is greater than 1000.
SELECT o.orderid, o.symbol, o.shares, ABS(o.shares * o.price) AS absolute_net_order
FROM `Order` o
WHERE o.orderTime >= '2023-03-01' AND o.orderTime < '2023-04-01'
AND ABS(o.shares * o.price) > 1000;
/*
+---------+--------+--------+--------------------+
| orderid | symbol | shares | absolute_net_order |
+---------+--------+--------+--------------------+
|       1 | WLY    |    100 |            3873.00 |
|       3 | NFLX   |   -100 |           24315.00 |
|       4 | A      |     10 |            1298.90 |
|       5 | A      |    -10 |            1298.90 |
|       6 | GS     |    100 |           30563.00 |
16 rows in set (0.00 sec)
*/


-- #7: List all the unique status types from orders.
SELECT DISTINCT o.status 
FROM `Order` o;
/*
+-----------------------+
| status                |
+-----------------------+
| partial_fill          |
| filled                |
| pending               |
| canceled_partial_fill |
| canceled              |
+-----------------------+
5 rows in set (0.00 sec)
*/


-- #8: List all pending and partial fill orders with oldest orders first.
SELECT o.orderid, o.symbol, o.status, o.orderTime 
FROM `Order` o
WHERE o.status IN ('pending', 'partial_fill')
ORDER BY o.orderTime ASC;
/*
+---------+--------+--------------+---------------------+
| orderid | symbol | status       | orderTime           |
+---------+--------+--------------+---------------------+
|       1 | WLY    | partial_fill | 2023-03-15 19:20:35 |
|       3 | NFLX   | pending      | 2023-03-15 19:21:12 |
|      11 | SPY    | partial_fill | 2023-03-15 19:24:21 |
|      12 | QQQ    | pending      | 2023-03-15 19:24:32 |
|      13 | QQQ    | pending      | 2023-03-15 19:24:32 |
10 rows in set (0.00 sec)
*/


-- #9: List the 10 most expensive financial products where the productType is stock.
-- Sort the results with the most expensive product at the top
SELECT p.symbol, p.price 
FROM Product p 
WHERE p.productType = 'stock' 
ORDER BY p.price DESC 
LIMIT 10;
/*
+-----------+-----------+
| symbol    | price     |
+-----------+-----------+
| 207940.KS | 830000.00 |
| 003240.KS | 715000.00 |
| 000670.KS | 630000.00 |
| 010130.KS | 616000.00 |
| 006400.KS | 605000.00 |
10 rows in set (0.02 sec)
*/


-- #10: Display orderid, fillid, userid, symbol, and absolute net fill amount
-- from fills where the absolute net fill is greater than $1000.
-- Sort the results with the largest absolute net fill at the top.
SELECT f.orderid, f.fillid, f.userid, f.symbol, (f.share * f.price) AS absolute_net_fill 
FROM Fill f 
WHERE (f.share * f.price) > 1000 
ORDER BY absolute_net_fill DESC;
/*
+---------+--------+--------+--------+-------------------+
| orderid | fillid | userid | symbol | absolute_net_fill |
+---------+--------+--------+--------+-------------------+
|      14 |     12 |      4 | SPY    |          27429.75 |
|       7 |      6 |      4 | GS     |           3056.30 |
|      10 |     10 |      1 | AAPL   |           2111.40 |
|       9 |      8 |      4 | AAPL   |           1407.60 |
|       5 |      4 |      3 | A      |           1298.90 |
+---------+--------+--------+--------+-------------------+
5 rows in set (0.00 sec)
*/
