-- [Problem 1a]

-- This sums up all the perfect scores to find the
-- total perfect score.

SELECT SUM(perfectscore) AS best_grade
FROM assignment;

-- [Problem 1b]

-- This returns each section and the number of students
-- in the section.

SELECT sec_name, COUNT(username) AS num_students
FROM student NATURAL JOIN section
GROUP BY sec_name;

-- [Problem 1c]

-- The totalscores view computes the total score over all
-- assignments for each student. It contains the student's
-- username and total score.

DROP VIEW IF EXISTS totalscores;

CREATE VIEW totalscores AS
    SELECT username, SUM(score) AS total_score
    FROM submission
    WHERE graded = TRUE
    GROUP BY username;

-- [Problem 1d]

-- The passing view contains the username and scores of all
-- students who passed the course.

DROP VIEW IF EXISTS passing;

CREATE VIEW passing AS
    SELECT *
    FROM totalscores
    WHERE total_score >= 40;

-- [Problem 1e]

-- The failing view contains the username and scores of all 
-- students who failed the course.

DROP VIEW IF EXISTS failing;

CREATE VIEW failing AS
    SELECT *
    FROM totalscores
    WHERE total_score < 40;

-- [Problem 1f]

-- This finds the username of all students who failed to
-- submit work for at least one lab, but passed the course.
-- It Natural Left Joins submission and fileset and then
-- Joins assignment. It then returns the usernames where
-- there is no indication of submission (fset_id = NULL), 
-- the assignment is a lab and the username is in the passing
-- view.

SELECT username 
FROM (submission NATURAL LEFT JOIN fileset) 
    NATURAL JOIN assignment
WHERE fset_id IS NULL 
    AND shortname LIKE 'lab%' 
    AND username IN 
        (SELECT username FROM passing);
        
-- Result of running this query: ['harris', 'ross', 'miller', 'turner', 
-- 'edwards', 'murphy', 'simmons', 'tucker', 'coleman', 'flores', 'gibson']

-- [Problem 1g]

-- This does the same as above, except it looks for when the assignment
-- is a midterm or a final.

SELECT username 
FROM (submission NATURAL LEFT JOIN fileset) 
    NATURAL JOIN assignment
WHERE fset_id IS NULL 
    AND (shortname LIKE 'midterm' 
        OR shortname LIKE 'final')
    AND username IN 
        (SELECT username FROM passing);
        
-- Result of running this query: ['collins']

-- [Problem 2a]

-- This finds the students who submitted their midterm late.
-- It does this by comparing submission date to due date.

SELECT DISTINCT username 
FROM fileset NATURAL JOIN submission NATURAL JOIN assignment
WHERE shortname LIKE 'midterm' AND sub_date > due;

-- [Problem 2b]

-- This finds the number of submissions per hour of the day by
-- grouping by hour of the day and counting the submissions.

SELECT EXTRACT(HOUR FROM sub_date) AS hour, COUNT(sub_id) AS num_submits
FROM submission NATURAL JOIN fileset NATURAL JOIN assignment
WHERE shortname LIKE 'lab%'
GROUP BY hour;

-- [Problem 2c]

-- This finds the number of finals submitted 30 minutes before
-- the due date by using the INTERVAL function.

SELECT COUNT(sub_id) AS num_finals
FROM submission NATURAL JOIN fileset NATURAL JOIN assignment
WHERE shortname LIKE 'final' AND sub_date 
    BETWEEN (due - INTERVAL 30 MINUTE) AND due;

-- [Problem 3a]

-- This adds an email column to student and populates it with
-- username@school.edu. It then changes the email column to have
-- a NOT NULL constraint.

ALTER TABLE student
    ADD COLUMN email VARCHAR(200);

UPDATE student
SET email = CONCAT(username, '@school.edu');
    
ALTER TABLE student
    CHANGE COLUMN email email VARCHAR(200) NOT NULL;
    
-- [Problem 3b]

-- This adds the submit_files column to assignment and sets
-- its value to false for all daily quizzes.

ALTER TABLE assignment
    ADD COLUMN submit_files BOOLEAN DEFAULT TRUE;
    
UPDATE assignment
SET submit_files = FALSE
WHERE shortname LIKE 'dq%';

-- [Problem 3c]

-- This makes a new gradescheme table and populates it with
-- 3 grading schemes. It then alters the gradescheme column
-- in assignment and makes that column refer to the new 
-- gradescheme table.

CREATE TABLE gradescheme (
    scheme_id INT PRIMARY KEY,
    scheme_desc VARCHAR(100) NOT NULL
);

INSERT INTO gradescheme VALUES
    (0, 'Lab assignment with min-grading.'),
    (1, 'Daily quiz.'),
    (2, 'Midterm or final exam.');
    
ALTER TABLE assignment
    CHANGE COLUMN gradescheme scheme_id INT NOT NULL;
    
ALTER TABLE assignment
    ADD FOREIGN KEY (scheme_id) REFERENCES gradescheme (scheme_id);

-- [Problem 4a]

DROP FUNCTION IF EXISTS is_weekend;

-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.

DELIMITER !

-- Given a date value, returns TRUE if it is a weekend,
-- or FALSE if it is a weekday.

CREATE FUNCTION is_weekend (d DATE) RETURNS BOOLEAN
BEGIN

-- This works becaue these statements return either
-- True or False.

RETURN DAYOFWEEK(d) = 1 OR DAYOFWEEK(d) = 7;

END !

DELIMITER ;


-- [Problem 4b]

DROP FUNCTION IF EXISTS is_holiday;

-- Set the "end of statement" character to ! so that
-- semicolons in the function body won't confuse MySQL.

DELIMITER !

-- Given a date value, return a corresponding statement
-- indicating what holiday the date falls on or Null
-- if the date is not a holiday.

CREATE FUNCTION is_holiday (d DATE) RETURNS VARCHAR(20)
BEGIN

    -- Declare variables for the result, month, day
    -- and day of the week.
    
    DECLARE result VARCHAR(20);

    DECLARE mDate INT;
    
    DECLARE dDate INT;

    DECLARE dayWeek INT;
    
    -- Set the initial values for each of these variables.
    
    SET result = NULL;
    
    SET mDATE = MONTH(d);
    
    SET dDATE = DAY(d);
    
    SET dayWeek = DAYOFWEEK(d);
    
    -- If month is January and day is 1 it's New Years.
    
    IF mDate = 1 AND dDate = 1 THEN SET result = 'New Year\'s Day';
    
    -- If month is May and weekday is Monday and it's the last monday
    -- it's Memorial Day.

    ELSEIF mDate = 5 AND dayWeek = 2 AND dDate 
        BETWEEN 25 AND 31 THEN SET result = 'Memorial Day';

    -- If month is July and day is 4, it's Independence Day.
    
    ELSEIF mDate = 7 AND dDate = 4 THEN SET result = 'Independence Day';

    -- If month is September and it's the first Monday, it's Labor Day.
    
    ELSEIF mDATE = 9 AND dayWeek = 2 AND dDate 
        BETWEEN 1 AND 7 THEN SET result = 'Labor Day';

    -- If month is November and it's the fourth Thursday,
    -- it's Thanksgiving.
    
    ELSEIF mDate = 11 AND dayWeek = 5 AND dDate 
        BETWEEN 22 AND 28 THEN SET result = 'Thanksgiving';

    END IF;

    RETURN result;

END !

DELIMITER ;

-- [Problem 5a]

-- This counts all the files submitted on a holiday.

SELECT is_holiday(DATE(sub_date)) AS holiday, COUNT(*) AS num_sub
FROM fileset
GROUP BY holiday;

-- [Problem 5b]

-- This counts how many files were submitted on a weekday
-- and how many were submitted on a weekend.

SELECT (CASE is_weekend(DATE(sub_date)) 
    WHEN 0 THEN 'weekday' ELSE 'weekend' END) AS dayOfWeek, 
    COUNT(*) AS num_sub
FROM fileset
GROUP BY dayOfWeek;


