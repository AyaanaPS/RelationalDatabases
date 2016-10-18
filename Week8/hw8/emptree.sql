-- [Problem 1]
-- This computes the sum of all employee salaries
-- in a particular hierarchy in the employee adjlist
-- table. It uses a sub table 
-- to store the employee ids and salaries of employees
-- of employees in the subtree. It then computes
-- the sum of the salaries from that table and wipes
-- the table clean.

-- DROP FUNCTION IF EXISTS total_salaries_adjlist;


CREATE TABLE emps
    (emp_id INTEGER NOT NULL,
    salary INTEGER NOT NULL);
        
DELIMITER !

CREATE FUNCTION total_salaries_adjlist(
    employee_id INTEGER
) RETURNS INTEGER
BEGIN

    DECLARE sum INTEGER;

    INSERT INTO emps SELECT emp_id, salary
    FROM employee_adjlist
    WHERE emp_id = employee_id;
    
    IF ROW_COUNT() = 0
        THEN RETURN NULL;
        
    END IF;
    
    REPEAT
        INSERT INTO emps SELECT emp_id, salary
        FROM employee_adjlist
        WHERE manager_id IN 
            (SELECT emp_id FROM emps) AND
            emp_id NOT IN
            (SELECT emp_id FROM emps);
    UNTIL ROW_COUNT() = 0
    END REPEAT;
    
    SELECT SUM(salary) INTO sum
    FROM emps;
    
    DELETE FROM emps;
    
    RETURN sum;
    
END !

DELIMITER ;

-- [Problem 2]

DROP FUNCTION IF EXISTS total_salaries_nestset;
-- This computes the sum of all employee salaries
-- in a particular hierarchy of the employee nestset
-- table. It uses the low and high values of each
-- employee to do this.

DELIMITER !

CREATE FUNCTION total_salaries_nestset(
    employee_id INTEGER
) RETURNS INTEGER
BEGIN

    DECLARE lowVal INTEGER;
    DECLARE highVal INTEGER;
    DECLARE sum INTEGER;
    
    SELECT low, high INTO lowVal, highVal
    FROM employee_nestset
    WHERE emp_id = employee_id;
    
    IF lowVal IS NULL OR highVal IS NULL
        THEN RETURN 0;
    END IF;
    
    SELECT SUM(salary) INTO sum
    FROM employee_nestset
    WHERE low BETWEEN lowVal AND highVal
        AND high BETWEEN lowVal AND highVal;
        
    RETURN sum;
    
END !

DELIMITER ;

-- [Problem 3]
-- Leaves are the ones where no other employee
-- has their employee id as the manager id for
-- the employee adjlist table. This
-- finds the leaves by checking if the employee
-- id is a manager id.

SELECT emp_id, name, salary
FROM employee_adjlist
WHERE emp_id NOT IN
    (SELECT DISTINCT manager_id
    FROM employee_adjlist
    WHERE manager_ID IS NOT NULL);


-- [Problem 4]
-- Leaves are the ones who have low and high values
-- that do not contain those of any other employees.
-- This uses a join to compare low and high values
-- of every employee to every other employee.

SELECT A.emp_id, A.name, A.salary
FROM employee_nestset AS A LEFT JOIN employee_nestset AS B
    ON (B.low > A.low AND B.high < A.high)
WHERE B.emp_id IS NULL;
 
-- [Problem 5]
-- This computes depth by seeing how many times
-- the Repeat needs to be counted in order to 
-- travel down the tree.

CREATE TABLE depth_counter
    (emp_id INTEGER NOT NULL);
        
DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !

CREATE FUNCTION tree_depth() 
RETURNS INTEGER
BEGIN

    DECLARE depth INTEGER DEFAULT 0;
    DECLARE ceo_id INTEGER;
    
    SELECT emp_id INTO ceo_id
    FROM employee_adjlist
    WHERE manager_id IS NULL;
    
    INSERT INTO depth_counter SELECT emp_id
    FROM employee_adjlist
    WHERE emp_id = ceo_id;
    
    IF ROW_COUNT() = 0
        THEN RETURN NULL;
        
    END IF;
    
    REPEAT
        INSERT INTO depth_counter SELECT emp_id
        FROM employee_adjlist
        WHERE manager_id IN 
            (SELECT emp_id FROM depth_counter) AND
            emp_id NOT IN
            (SELECT emp_id FROM depth_counter);
        SET depth = depth + 1;
    UNTIL ROW_COUNT() = 0
    END REPEAT;
    
    DELETE FROM depth_counter;
    
    RETURN depth;
    
END !

DELIMITER ;

-- [Problem 6]
-- This finds the number of direct children by
-- creating a table of the children of the given
-- employee. It then finds all the roots of the
-- sub table by comparing low and high values.

CREATE TABLE subtree
    (emp_id INTEGER NOT NULL, 
    low INTEGER NOT NULL,
    high INTEGER NOT NULL);
 
DELIMITER !

CREATE FUNCTION emp_reports (
    employee_id INTEGER
) RETURNS INTEGER
BEGIN

    DECLARE minLow INTEGER;
    DECLARE maxHigh INTEGER;
    DECLARE directChildren INTEGER;
    
    SELECT low, high INTO minLow, maxHigh
    FROM employee_nestset
    WHERE emp_id = employee_id;

    INSERT INTO subtree SELECT emp_id, low, high
        FROM employee_nestset
        WHERE low > minLow AND high < maxHigh;
    
    SELECT COUNT(A.emp_id) INTO directChildren
    FROM subtree AS A LEFT JOIN subtree AS B
    ON A.low > B.low AND A.high < B.high
    WHERE B.emp_id IS NULL;
    
    DELETE FROM subtree;
    
    RETURN directChildren;

END !

DELIMITER ;
