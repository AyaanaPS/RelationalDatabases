-- [Problem 1]
/* The function min_submit_interval takes one
variable and returns an integer representing the
minimum value. It does this using two cursors 
representing the values for sub_date read from 
fileset. It then computes the difference of these 
values and checks to see if they are the less than
the min. If so, they replace the min value. Then,
the values of first_val and second_val are updated.
If only one value was found, NULL will be returned. */

DELIMITER !

CREATE FUNCTION min_submit_interval(
    ID INTEGER
) RETURNS INTEGER
BEGIN

    DECLARE minTime INTEGER DEFAULT NULL;
    DECLARE difference INTEGER;
    DECLARE first_val TIMESTAMP;
    DECLARE second_val TIMESTAMP;
    DECLARE done INT DEFAULT 0;
    
    DECLARE cur CURSOR FOR
        SELECT sub_date
        FROM fileset
        WHERE sub_id = ID;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
        
    OPEN cur;    
    
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET difference = 
                UNIX_TIMESTAMP(second_val) - UNIX_TIMESTAMP(first_val);
            IF minTime IS NULL OR minTime > difference 
                THEN SET minTime = difference;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    
    CLOSE cur;
    
    RETURN minTime;
    
END; !

DELIMITER ;

-- [Problem 2]

/* The function max_submit_interval takes one
variable and returns an integer representing the
maximum value. It does this using two cursors 
representing the values for sub_date read from 
fileset. It then computes the difference of these 
values and checks to see if they are greater than
the max. If so, they replace the max value. Then,
the values of first_val and second_val are updated.
If only one value was found, NULL will be returned. */

DELIMITER !

CREATE FUNCTION max_submit_interval(
    ID INTEGER
) RETURNS INTEGER
BEGIN

    DECLARE maxTime INTEGER DEFAULT NULL;
    DECLARE difference INTEGER;
    DECLARE first_val TIMESTAMP;
    DECLARE second_val TIMESTAMP;
    DECLARE done INT DEFAULT 0;
    
    DECLARE cur CURSOR FOR
        SELECT sub_date
        FROM fileset
        WHERE sub_id = ID;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
        
    OPEN cur;    
    
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET difference = 
                UNIX_TIMESTAMP(second_val) - UNIX_TIMESTAMP(first_val);
            IF maxTime IS NULL OR difference > maxTime 
                THEN SET maxTime = difference;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    
    CLOSE cur;
    
    RETURN maxTime;
    
END; !

DELIMITER ;

-- [Problem 3]

/* The function avg_submit_interval takes one
variable and returns an integer representing the
average val. It does this by finding the min value
of the sub_date and the max value of the sub_date
and then computing the difference. Then, after 
confirming there are more than one submission 
times, the average is computed. If there is only
one submission time, the average will be NULL.*/

DELIMITER !

CREATE FUNCTION avg_submit_interval(
    ID INTEGER
) RETURNS DOUBLE
BEGIN

    DECLARE max INTEGER;
    DECLARE min INTEGER;
    DECLARE interv INTEGER;
    DECLARE num_submits INTEGER;
    DECLARE average DOUBLE; 
    
    SELECT UNIX_TIMESTAMP(min(sub_date)),
        UNIX_TIMESTAMP(max(sub_date)) into min, max
    FROM fileset
    WHERE sub_id = ID;
    
    SET interv = max - min;
    
    SELECT COUNT(*) into num_submits
    FROM fileset
    WHERE sub_id = ID;
    
    IF num_submits >= 2 THEN
        SET average = interv/(num_submits - 1);
        
    END IF;
    
    RETURN average;
    
END !

DELIMITER ;

/* Just to check everything

SELECT sub_id,
    min_submit_interval(sub_id) AS min_interval,
    max_submit_interval(sub_id) AS max_interval,
    avg_submit_interval(sub_id) AS avg_interval
FROM (SELECT sub_id FROM fileset
    GROUP BY sub_id HAVING COUNT(*) > 1) AS multi_subs
ORDER BY min_interval, max_interval; */

-- [Problem 4]

/* This creates an index on the fileset with
sub_id and sub_date because those are used for
the min_submit_interval, max_submit_interval and
avg_submit_interval. */

CREATE INDEX idx ON fileset (sub_id, sub_date);
