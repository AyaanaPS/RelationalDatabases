-- Clean up old versions of the tables if they are present...
DROP TABLE IF EXISTS cycles;
DROP TABLE IF EXISTS dependencies;
DROP TABLE IF EXISTS predicates;


-- This table stores the predicates that can be evaluated in the
-- predicate evaluator.
CREATE TABLE predicates (
    -- Predicates are given a unique ID that we use to reference
    -- other predicates
    pid INTEGER AUTO_INCREMENT PRIMARY KEY,

    -- Predicates are given a unique name
    name VARCHAR(30) NOT NULL UNIQUE,

    -- The body of the predicate, e.g. 'a > 5 and another_predicate'
    body VARCHAR(1000)
);


-- This table specifies the dependency graph between all predicates.
-- It is a directed acyclic graph.
CREATE TABLE dependencies (
    -- The ID of the referencing predicate
    pid INTEGER REFERENCES predicates(pid),

    -- The ID of the referenced predicate
    depends_on_pid INTEGER REFERENCES predicates(pid),
    
    PRIMARY KEY (pid, depends_on_pid) 
);


-- This table is populated by the stored procedure sp_find_cycles(),
-- such that it contains all dependencies that are part of cycles in the
-- dependency graph.
CREATE TABLE cycles (
    -- The ID of the referencing predicate in the cycle
    pid INTEGER REFERENCES predicates(pid),

    -- The ID of the referenced predicate in the cycle
    depends_on_pid INTEGER REFERENCES predicates(pid),

    PRIMARY KEY (pid, depends_on_pid) 
);

