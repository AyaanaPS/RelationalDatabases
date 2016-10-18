-- [Problem 2a]

-- Returns the total number of rows in the table.

SELECT COUNT(*) AS num_rows FROM raw_web_log;

-- [Problem 2b]

-- Returns the total number of requests from the
-- top 20 IP addresses.

SELECT ip_addr, COUNT(*) AS num_requests
FROM raw_web_log
GROUP BY ip_addr
ORDER BY num_requests DESC
LIMIT 20;

-- [Problem 2c]

-- Returns the total number of requests and the 
-- total number of bytes for each resource.

SELECT resource, COUNT(*) AS num_requests, 
    SUM(bytes_sent) AS num_bytes
FROM raw_web_log
GROUP BY resource
ORDER BY num_bytes DESC
LIMIT 20;

-- [Problem 2d]

-- Returns information about each visit made, 
-- including the total number of requests, the
-- starting and ending time.

SELECT visit_val, ip_addr, COUNT(*) AS num_requests, 
    MIN(logtime) AS starting_time, MAX(logtime) AS ending_time
FROM raw_web_log
GROUP BY visit_val, ip_addr
ORDER BY num_requests DESC
LIMIT 20;
