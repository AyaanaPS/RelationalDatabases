DELETE FROM cycles;
DELETE FROM dependencies;
DELETE FROM predicates;

-- Dependencies:
--
--            --------
--           /        \
--          v          \
--   p5 -> p4 -> p3 -> p2 -> p1
--
-- Cycles:
--
--   p4 -> p3 -> p2 -> p4

INSERT INTO predicates VALUES (1, 'p1', 'true');
INSERT INTO predicates VALUES (2, 'p2', 'p1 and p4');
INSERT INTO predicates VALUES (3, 'p3', 'p2');
INSERT INTO predicates VALUES (4, 'p4', 'p3');
INSERT INTO predicates VALUES (5, 'p5', 'p4');

INSERT INTO dependencies VALUES (2, 1), (2, 4), (3, 2), (4, 3), (5, 4);



