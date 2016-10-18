-- PLEASE DO NOT INCLUDE date-udfs HERE!!!

-- [Problem 4a]
-- This populates the resource_dim table with unique combinations
-- of resource, method, protocol and response.

INSERT INTO resource_dim (resource, method, protocol, response)
    SELECT DISTINCT resource, method, protocol, response
    FROM raw_web_log;

-- [Problem 4b]
-- This populates the visitor_dim table with unique values
-- of visit_val.

INSERT INTO visitor_dim (ip_addr, visit_val)
    SELECT DISTINCT ip_addr, visit_val
    FROM raw_web_log;


-- [Problem 4c]

DELIMITER !

-- This procedure populates the datetime_dim table
-- with dates and hours between the inputted dates.

CREATE PROCEDURE populate_dates (
    d_start DATE,
    d_end DATE
) BEGIN
    
    DECLARE d DATE;
    DECLARE h INTEGER;
    
    DELETE FROM datetime_dim
    WHERE date_val BETWEEN
        d_start AND d_end;
    
    SET d = d_start;
    
    WHILE d <= d_end DO
        SET h = 0;
        WHILE h <= 23 DO
            INSERT INTO datetime_dim 
                (date_val, hour_val, weekend, holiday)
                VALUES (d, h, is_weekend(d), is_holiday(d));
            SET h = h + 1;
        END WHILE;
        
        SET d = d + INTERVAL 1 DAY;
        
    END WHILE;

END!

DELIMITER ;

-- This call populates the datetime_dim table with
-- dates and hours between the entered dates:
-- 7/1/95 and 8/31/95.

CALL populate_dates('1995-07-01', '1995-08-31');

-- [Problem 5a]
-- This populates the resource_fact table. It uses a 
-- JOIN between the raw_web_log, resource_dim and 
-- datetime_dim table.

INSERT INTO resource_fact (
    date_id, resource_id, 
    num_requests, total_bytes
)
SELECT date_id, resource_id,
    COUNT(*) AS count_requests, SUM(bytes_sent) AS sum_bytes
FROM raw_web_log JOIN resource_dim ON 
    (raw_web_log.resource <=> resource_dim.resource AND 
    raw_web_log.method <=> resource_dim.method AND
    raw_web_log.protocol <=> resource_dim.protocol AND
    raw_web_log.response <=> resource_dim.response)
    JOIN datetime_dim ON 
    (DATE(raw_web_log.logtime) <=> datetime_dim.date_val AND
    HOUR(raw_web_log.logtime) <=> datetime_dim.hour_val)
GROUP BY date_id, resource_id;


-- Tester Function:
-- SELECT date_id, COUNT(*) AS c FROM resource_fact
-- GROUP BY date_id ORDER BY c DESC LIMIT 3;

-- [Problem 5b]
-- This populates the visitor_fact table. It uses a
-- JOIN between the raw_web_log, visitor_dim and
-- datetime_dim table.

INSERT INTO visitor_fact (
    date_id, visitor_id,
    num_requests, total_bytes
)
SELECT date_id, visitor_id,
    COUNT(*) AS count_requests, SUM(bytes_sent) AS sum_bytes
FROM raw_web_log JOIN visitor_dim ON
    (raw_web_log.ip_addr <=> visitor_dim.ip_addr AND
    raw_web_log.visit_val <=> visitor_dim.visit_val)
    JOIN datetime_dim ON
    (DATE(raw_web_log.logtime) <=> datetime_dim.date_val AND
    HOUR(raw_web_log.logtime) <=> datetime_dim.hour_val)
GROUP BY date_id, visitor_id;

-- Tester Function:
-- SELECT date_id, COUNT(*) AS c FROM visitor_fact
-- GROUP BY date_id ORDER BY c DESC LIMIT 3;
