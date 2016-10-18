-- [Problem 6a]
-- This returns each distinct HTTP protocol value
-- and the number of requests that use it.
-- It only includes the top 10 ones.

SELECT protocol, SUM(num_requests) AS tot_requests
FROM resource_dim NATURAL JOIN resource_fact
GROUP BY protocol
ORDER BY tot_requests DESC
LIMIT 10;

-- [Problem 6b]
-- This returns the top 20 resource and response pairs
-- based on greater error count. Errors are indicated
-- by a response value greater than or equal to 400.

SELECT resource, response, SUM(num_requests) AS error_count
FROM resource_dim NATURAL JOIN resource_fact
WHERE response >= 400
GROUP BY resource, response
ORDER BY error_count DESC
LIMIT 20;

-- [Problem 6c]
-- This finds the top 20 clients based on the total 
-- amount of bytes sent to each client. It is ordered
-- by decreasing total bytes sent.

SELECT ip_addr, COUNT(DISTINCT visit_val) AS num_visits,
    SUM(num_requests) AS tot_requests, SUM(total_bytes) AS tot_bytes
FROM visitor_dim NATURAL JOIN visitor_fact
GROUP BY ip_addr
ORDER BY tot_bytes DESC
LIMIT 20;

-- [Problem 6d]
-- The gap on the second of August is because, according
-- to the given website, no accesses were recorded between
-- 01/Aug/1995:14:52:01 until 03/Aug/1995:04:36:13 due to 
-- Hurricane Erin.The gap from July 29, 1995 to July 31,
-- 1995 has no explanation.

SELECT date_val, SUM(num_requests) AS daily_requests,
    SUM(total_bytes) AS daily_bytes
FROM datetime_dim NATURAL LEFT JOIN resource_fact
WHERE date_val BETWEEN '1995-07-23' AND
    '1995-08-12'
GROUP BY date_val;

-- [Problem 6e]
-- This returns the resource that generated the maximum bytes
-- served for every day in the data-set. The result includes
-- the date, the resource, the total number of requests and the
-- total bytes.

SELECT date_val, resource, daily_requests, max_bytes
FROM
(SELECT date_val, MAX(tot_bytes) AS max_bytes
FROM
    (SELECT date_val, resource, SUM(total_bytes) AS tot_bytes,
        SUM(num_requests) AS daily_requests
    FROM resource_fact NATURAL JOIN resource_dim NATURAL JOIN 
        datetime_dim
    GROUP BY date_val, resource) AS subquery1
GROUP BY date_val) AS subquery2 NATURAL JOIN
(SELECT datetime_dimdate_val, resource, SUM(total_bytes) AS max_bytes,
        SUM(num_requests) AS daily_requests
    FROM resource_fact NATURAL JOIN resource_dim NATURAL JOIN 
        datetime_dim
    GROUP BY date_val, resource) AS subquery3;

-- [Problem 6f]
-- This returns the average weekday visits and the average
-- weekend visits by hour.

SELECT * 
FROM
(SELECT hour_val, AVG(num_visits_weekday) AS avg_weekday_visits
FROM
(SELECT date_val, hour_val, COUNT(DISTINCT visit_val) AS num_visits_weekday
FROM visitor_dim NATURAL JOIN visitor_fact NATURAL JOIN datetime_dim
WHERE weekend = 0
GROUP BY hour_val, date_val) AS weekday_stats
GROUP BY hour_val) AS weekday_visits
NATURAL JOIN
(SELECT hour_val, AVG(num_visits_weekend) AS avg_weekend_visits
FROM
(SELECT date_val, hour_val, COUNT(DISTINCT visit_val) AS num_visits_weekend
FROM visitor_dim NATURAL JOIN visitor_fact NATURAL JOIN datetime_dim
WHERE weekend = 1
GROUP BY hour_val, date_val) AS weekend_stats
GROUP BY hour_val) AS weekend_visits;