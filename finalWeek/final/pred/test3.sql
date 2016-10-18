DELETE FROM cycles;
DELETE FROM dependencies;
DELETE FROM predicates;

-- Dependencies:
--
--   p8 -     --------     -> p6 -
--       \   /        \   /       \
--        v v          \ /         v
--   p5 -> p4 -> p3 -> p2 -> p1 -> p7
--
-- Cycles:
--
--   p4 -> p3 -> p2 -> p4

INSERT INTO predicates VALUES (1, 'p1', 'p7');
INSERT INTO predicates VALUES (2, 'p2', 'p1 and p4 and p6');
INSERT INTO predicates VALUES (3, 'p3', 'p2');
INSERT INTO predicates VALUES (4, 'p4', 'p3');
INSERT INTO predicates VALUES (5, 'p5', 'p4');
INSERT INTO predicates VALUES (7, 'p7', 'true');
INSERT INTO predicates VALUES (6, 'p6', 'p7');
INSERT INTO predicates VALUES (8, 'p8', 'p4');

INSERT INTO dependencies VALUES (1, 7);
INSERT INTO dependencies VALUES (2, 1), (2, 4), (2, 6);
INSERT INTO dependencies VALUES (3, 2);
INSERT INTO dependencies VALUES (4, 3);
INSERT INTO dependencies VALUES (5, 4);
INSERT INTO dependencies VALUES (6, 7);
INSERT INTO dependencies VALUES (8, 4);

