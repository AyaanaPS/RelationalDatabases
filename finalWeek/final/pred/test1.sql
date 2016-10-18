DELETE FROM cycles;
DELETE FROM dependencies;
DELETE FROM predicates;

-- Dependencies:
--
--   p4 -> p3 -> p2 -> p1
--
-- Cycles:
--
--   none

INSERT INTO predicates VALUES (1, 'p1', 'true');
INSERT INTO predicates VALUES (2, 'p2', 'p1');
INSERT INTO predicates VALUES (3, 'p3', 'p2');
INSERT INTO predicates VALUES (4, 'p4', 'p3');
INSERT INTO dependencies VALUES (2, 1), (3, 2), (4, 3);


