-- [Problem 2b]
-- The function that I created removes the (pid, depends_on_pid)
-- pairs that cannot be in any cycles. These are the pairs in 
-- which the pid value does not ever appear in the depends_on_pid
-- value or vice versa. If this happens, it means that no pair can
-- lead to the pid value or the depends_on_pid value leads to 
-- no other pair. These can essentially be thought of as
-- acyclic pairs.
-- It then repeats this process until nothing else is removed. 
-- The repetitions will remove any pairs which will lead only
-- to acyclic pairs. These new pairs cannot be a part of a cycle
-- if they only lead to an acyclic pair or are only led to by an 
-- acyclic pair. This is because there is no way to get back to
-- or away from an acyclic pair. This in turn makes these new
-- pairs acyclic pairs. 

-- When no more pairs are deleted, we must be left with only
-- those that cycle amongst each other. Thus, the cycle table
-- will be filled with all pairs part of some cycle.

-- [Problem 2a]
-- This function finds all the cycles in a dependency table.
-- It then modifies the cycles table so that it only contains
-- dependencies that are part of a cycle.


-- The following helper table holds pid values that are
-- absolutely not part of a cycle.

-- DROP TABLE IF EXISTS acyclicPids;

CREATE TABLE acyclicPids (
    pid INTEGER NOT NULL
);

-- DROP PROCEDURE IF EXISTS fill_table;

DELIMITER !

CREATE PROCEDURE fill_table (
) BEGIN

    DECLARE pid_current INT;
    DECLARE depends_on_current INT;
    
    INSERT INTO cycles (pid, depends_on_pid)
    SELECT *
    FROM dependencies;
    
    REPEAT

        DELETE FROM acyclicPids;
        
        INSERT INTO acyclicPids
            SELECT pid FROM predicates
            WHERE pid NOT IN
                (SELECT pid FROM cycles)
                OR pid NOT IN
                (SELECT depends_on_pid FROM cycles);

    
        DELETE FROM cycles WHERE 
            pid IN (SELECT pid FROM acyclicPids) OR
            depends_on_pid IN (SELECT pid FROM acyclicPids);
        
    UNTIL ROW_COUNT() = 0
    END REPEAT;
    
    DELETE FROM acyclicPids;
        
END !

DELIMITER ;

