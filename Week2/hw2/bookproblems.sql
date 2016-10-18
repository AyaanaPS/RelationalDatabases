USE ayaanaps_db;

-- [Problem 1a]
-- This chooses the student names whose corresponding course_ids contain 
-- the phrase 'CS'.

SELECT DISTINCT name 
FROM student  NATURAL JOIN takes 
WHERE course_id LIKE '%CS%';

-- [Problem 1c]
-- This chooses the department name and max instructor salary from the 
-- instructor relation.

SELECT dept_name, MAX(salary) AS max_sal 
FROM instructor 
GROUP BY dept_name;

-- [Problem 1d]
-- This selects the minimum of the maximum salaries from the table 
-- derived in the query above (which has been copied here).

SELECT MIN(max_sal) as min_max FROM
    (SELECT dept_name, MAX(salary) AS max_sal 
    FROM instructor
    GROUP BY dept_name) AS dept_max;

-- [Problem 2a]
-- This inserts the course CS-001 in the course table.

INSERT INTO course VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', '0');

-- [Problem 2b]
-- This inserts a section of CS-001 with the specified columns into 
-- section.

INSERT INTO section (course_id, sec_id, semester, year) 
    VALUES('CS-001' , '1' , 'Autumn' , '2009');

-- [Problem 2c]
-- This enrolls all CS students into the CS section defined before.

INSERT INTO takes(ID, course_id, sec_id, semester, year) 
    SELECT ID, 'CS-001', '1', 'Autumn', '2009' 
    FROM student 
    WHERE department_name = 'Comp. Sci.';

-- [Problem 2d]
-- This deletes the CS-001 section for Chavez.

DELETE FROM takes 
WHERE course_id = 'CS-001' AND sec_id = 1 AND ID IN 
    (SELECT ID 
    FROM student 
    WHERE name = 'Chavez');

-- [Problem 2e]
-- The referential integrity is not being maintained if this delete statement
-- is run before deleting offerengs of this course. This is because the course 
-- 'CS-001' is still being referenced to in other places.

DELETE FROM course 
WHERE course_id = 'CS-001';

-- [Problem 2f]
-- This deletes any courses in takes that contain 'Database' in their title.

DELETE FROM takes 
WHERE course_id IN
    (SELECT course_id 
    FROM course 
    WHERE title LIKE LOWER('%Database%'));

-- [Problem 3a]
-- This finds the members who have borrowed a book published by McGraw-Hill.

SELECT name 
FROM member NATURAL JOIN borrowed NATURAL JOIN book 
WHERE publisher = 'McGraw-Hill';

-- [Problem 3b]
-- This finds the members who have borrowed all books published by 
-- McGraw-Hill. It counts the amount of books published by McGraw-Hill that
-- each member has read and sees if it is equal to the number of books 
-- published by McGraw-Hill.

SELECT name 
FROM 
    (SELECT name, COUNT(isbn) AS book_count 
    FROM member NATURAL JOIN borrowed NATURAL JOIN book 
    WHERE publisher = 'McGraw-Hill' GROUP BY name) AS name_count 
WHERE book_count IN 
    (SELECT count(isbn) AS McG_count 
    FROM book 
    WHERE publisher = 'McGraw-Hill');

-- [Problem 3c]
-- This finds the members who have read more than 5 books from one
-- publisher.

SELECT publisher, name 
FROM member NATURAL JOIN borrowed NATURAL JOIN book
GROUP BY publisher, name
HAVING COUNT(isbn) > 5;

-- [Problem 3d]
-- This calculates the average books read per member by adding
-- the number of books read by each member and dividing it by
-- the number of members.

SELECT SUM(book_count)/(SELECT COUNT(*) AS mem_count FROM member) 
    AS member_count 
FROM 
    (SELECT memb_no, COUNT(isbn) AS book_count 
    FROM book NATURAL JOIN borrowed 
    GROUP BY memb_no) 
AS memb_bookCount;
