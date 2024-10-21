-- Ahmed Ibrahim C402

/*
Join Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     Also include the total records returned.
*/

USE orderbook_activity_db;

-- #1: Display the dateJoined and username for admin users.
SELECT u.dateJoined, u.uname
FROM User u
JOIN UserRoles ur ON u.userid = ur.userid
JOIN Role r ON ur.roleid = r.roleid
WHERE r.name = 'admin';
/*
+---------------------+-------+
| dateJoined          | uname |
+---------------------+-------+
| 2023-02-14 13:13:28 | admin |
| 2023-04-01 13:13:28 | wiley |
| 2023-03-15 19:16:21 | alice |
+---------------------+-------+
3 rows in set (0.00 sec)
*/


-- #2: Display each absolute order net (share*price), status, symbol, trade date, and username.
-- Sort the results with largest the absolute order net (share*price) at the top.
-- Include only orders that were not canceled or partially canceled.
SELECT o.orderid, (o.shares * o.price) AS absolute_order_net, o.status, o.symbol, o.orderTime, u.uname
FROM `Order` o
JOIN User u ON o.userid = u.userid
WHERE o.status NOT IN ('canceled', 'canceled_partial_fill')
ORDER BY absolute_order_net DESC;
/*
+---------+--------------------+--------------+--------+---------------------+--------+
| orderid | absolute_order_net | status       | symbol | orderTime           | uname  |
+---------+--------------------+--------------+--------+---------------------+--------+
|      11 |           36573.00 | partial_fill | SPY    | 2023-03-15 19:24:21 | alice  |
|       1 |            3873.00 | partial_fill | WLY    | 2023-03-15 19:20:35 | admin  |
|      20 |            3873.00 | pending      | WLY    | 2023-03-15 19:51:06 | james  |
|       8 |            3519.00 | filled       | AAPL   | 2023-03-15 19:23:22 | robert |
|       4 |            1298.90 | filled       | A      | 2023-03-15 19:21:31 | alice  |
20 rows in set (0.00 sec)
*/


-- #3: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Note that filledShares are the opposite sign (+-) because they subtract from ordershares!
/*
+---------+--------+-----------------------+--------------+---------------+--------+
| orderid | symbol | status                | order_shares | filled_shares | price  |
+---------+--------+-----------------------+--------------+---------------+--------+
|       1 | WLY    | partial_fill          |          100 |          -110 |  38.73 |
|       2 | WLY    | filled                |          -10 |            20 |  38.73 |
|       4 | A      | filled                |           10 |           -20 | 129.89 |
|       5 | A      | filled                |          -10 |            20 | 129.89 |
|       6 | GS     | canceled_partial_fill |          100 |          -110 | 305.63 |
13 rows in set (0.00 sec)
*/

-- #4: Display all partial_fill orders and how many outstanding shares are left.
-- Also include the username, symbol, and orderid.
SELECT o.orderid, o.symbol, o.shares - SUM(f.share) AS outstanding_shares, u.uname
FROM `Order` o
JOIN Fill f ON o.orderid = f.orderid
JOIN User u ON o.userid = u.userid
WHERE o.status = 'partial_fill'
GROUP BY o.orderid;
/* 
+---------+--------+--------------------+-------+
| orderid | symbol | outstanding_shares | uname |
+---------+--------+--------------------+-------+
|       1 | WLY    |                110 | admin |
|      11 | SPY    |                175 | alice |
+---------+--------+--------------------+-------+
2 rows in set (0.00 sec)
*/


-- #5: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Also include the username, role, absolute net amount of shares filled, and absolute net order.
-- Sort by the absolute net order with the largest value at the top.
SELECT 
    o.orderid, o.symbol, o.status, o.shares AS order_shares, 
    (SUM(f.share)) AS filled_shares,
    o.price, u.uname, r.name AS role,
    (SUM(f.share) * o.price) AS absolute_net_amount_filled,
    (o.shares * o.price) AS absolute_net_order
FROM 
    `Order` o
JOIN 
    Fill f ON o.orderid = f.orderid
JOIN 
    User u ON o.userid = u.userid
JOIN 
    UserRoles ur ON u.userid = ur.userid
JOIN 
    Role r ON ur.roleid = r.roleid
GROUP BY 
    o.orderid, o.symbol, o.status, o.shares, o.price, u.uname, r.name  -- Include all non-aggregated columns
ORDER BY 
    absolute_net_order DESC;
/*
+---------+--------+-----------------------+--------------+---------------+--------+--------+-------+----------------------------+--------------------+
| orderid | symbol | status                | order_shares | filled_shares | price  | uname  | role  | absolute_net_amount_filled | absolute_net_order |
+---------+--------+-----------------------+--------------+---------------+--------+--------+-------+----------------------------+--------------------+
|      11 | SPY    | partial_fill          |          100 |           -75 | 365.73 | alice  | admin |                  -27429.75 |           36573.00 |
|       6 | GS     | canceled_partial_fill |          100 |           -10 | 305.63 | admin  | admin |			-3056.30 |           30563.00 |
|       1 | WLY    | partial_fill          |          100 |           -10 |  38.73 | admin  | admin |			 -387.30 |            3873.00 |
|       8 | AAPL   | filled                |           25 |           -25 | 140.76 | robert | user  |			-3519.00 |            3519.00 |
|       4 | A      | filled                |           10 |           -10 | 129.89 | alice  | admin |			-1298.90 |            1298.90 |
13 rows in set (0.00 sec)
*/

-- #6: Display the username and user role for users who have not placed an order.
SELECT u.uname, r.name AS role
FROM User u
LEFT JOIN `Order` o ON u.userid = o.userid
JOIN UserRoles ur ON u.userid = ur.userid
JOIN Role r ON ur.roleid = r.roleid
WHERE o.orderid IS NULL;
/*
+-------+-------+
| uname | role  |
+-------+-------+
| sam   | user  |
| wiley | admin |
+-------+-------+
2 rows in set (0.00 sec)
*/


-- #7: Display orderid, username, role, symbol, price, and number of shares for orders with no fills.
SELECT o.orderid, u.uname, r.name AS role, o.symbol, o.price, o.shares
FROM `Order` o
JOIN User u ON o.userid = u.userid
JOIN UserRoles ur ON u.userid = ur.userid
JOIN Role r ON ur.roleid = r.roleid
LEFT JOIN Fill f ON o.orderid = f.orderid
WHERE f.orderid IS NULL;
/*
+---------+--------+-------+--------+--------+--------+
| orderid | uname  | role  | symbol | price  | shares |
+---------+--------+-------+--------+--------+--------+
|      19 | alice  | admin | GOOG   | 100.82 |    100 |
|      21 | alice  | admin | A      | 129.89 |     -1 |
|      22 | alice  | admin | A      | 129.89 |      2 |
|      23 | alice  | admin | A      | 129.89 |      5 |
|      24 | alice  | admin | A      | 129.89 |      2 |
*/


-- #8: Display the symbol, username, role, and number of filled shares where the order symbol is WLY.
-- Include all orders, even if the order has no fills.
SELECT o.symbol, u.uname, r.name AS role, 
       COALESCE(SUM(f.share), 0) AS filled_shares
FROM `Order` o
JOIN User u ON o.userid = u.userid
JOIN UserRoles ur ON u.userid = ur.userid
JOIN Role r ON ur.roleid = r.roleid
LEFT JOIN Fill f ON o.orderid = f.orderid
WHERE o.symbol = 'WLY'
GROUP BY o.symbol, u.uname, r.name;
/*
+--------+--------+-------+---------------+
| symbol | uname  | role  | filled_shares |
+--------+--------+-------+---------------+
| WLY    | admin  | admin |           -10 |
| WLY    | robert | user  |            10 |
| WLY    | james  | user  |             0 |
+--------+--------+-------+---------------+
3 rows in set (0.00 sec)
*/



