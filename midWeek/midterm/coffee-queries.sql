-- [Problem 2]
-- This increments the no_votes by 1 for
-- maxwell@house.com's rating on coffee 2561.

UPDATE rating
    SET no_votes = no_votes + 1
    WHERE email = 'maxwell@house.com' AND
        coffee_id = 2561;

-- [Problem 3]
-- This removes all rows corresponding to user
-- maxwell@house.com. In order to respect
-- referential integrity, we should delete the
-- email from the rating table before the club table.

DELETE FROM rating
WHERE email = 'maxwell@house.com';

DELETE FROM club
WHERE email = 'maxwell@house.com';


-- [Problem 4a]
-- This uses a cross join to retrieve the emails
-- where stores are opening in the next 2 weeks.
-- It finds the stores opening in the next 2 weeks
-- using a Between and an Interval.

SELECT DISTINCT email FROM 
    club, (SELECT store_city FROM store
            WHERE opening_date BETWEEN
                CURRENT_DATE() AND
                (CURRENT_DATE + INTERVAL 2 WEEK))
                    AS opening_soon
    WHERE club.member_city = opening_soon.store_city;

-- [Problem 4b]
-- This uses a Set Membership Test to retrieve the 
-- emails where stores are opening in the next 2 weeks.
-- It finds the stores opening in the next 2 weeks
-- using a Between and an Interval.

SELECT email FROM club
WHERE member_city IN
    (SELECT store_city FROM store
    WHERE opening_date BETWEEN
        CURRENT_DATE() AND
        (CURRENT_DATE + INTERVAL 2 WEEK));

-- [Problem 5]
-- This updates the price_per_lb of coffees in
-- the coffee table whose category is 'budget' and
-- whose rating is less than or equal to 2.

UPDATE coffee
SET price_per_lb = price_per_lb * 0.80
WHERE category = 'budget' AND 
    coffee_id IN 
        (SELECT coffee_id FROM rating
        WHERE score <= 2);
            

-- [Problem 6]
-- This finds the emails of club members who have
-- rated less coffees than the average number of 
-- ratings. It uses views to store information 
-- regarding the number of ratings for every email
-- (including those who have rated 0 coffees) and
-- the average number of ratings.

CREATE VIEW num_ratings AS
    SELECT email, COUNT(score) AS num_rates
    FROM club NATURAL LEFT JOIN rating
    GROUP BY email;

SELECT DISTINCT email 
FROM num_ratings, 
    (SELECT AVG(num_rates) AS average_number
        FROM  num_ratings) AS averages
WHERE num_rates < average_number;

-- [Problem 7]
-- This report card view has information about the
-- coffe_id, coffee_name, number of ratings and
-- average rating. It uses the IFNULL function to 
-- ensure that appropriate values are returned if the
-- coffee has not been rated.

CREATE VIEW report_card AS
    SELECT coffee_ID, coffee_name,
        IFNULL(COUNT(score), 0) AS num_ratings, 
        IFNULL(AVG(score), NULL) AS avg_rating
    FROM coffee NATURAL LEFT JOIN rating
    GROUP BY coffee_ID;

-- [Problem 8]
-- This adds a suspended flag attribute to the club table.
-- It cannot be Null and defaults to false.

ALTER TABLE club
    ADD COLUMN suspended BOOLEAN DEFAULT false NOT NULL;
    
UPDATE club
    SET suspended = TRUE
    WHERE email LIKE '%spamalot%';

-- [Problem 9]
-- This comment_spotlight view contains information about
-- comments made under particular specifications:
-- the member was not suspended, the score given was 
-- greater than 4.5, the comment is not null, and
-- 70% of total votes are yes_votes.

CREATE VIEW comment_spotlight AS
    SELECT coffee_id, coffee_name, member_name, comment
    FROM rating NATURAL JOIN club NATURAL JOIN coffee
    WHERE suspended = false AND score >= 4.5 AND
        comment IS NOT NULL AND yes_votes > 0 AND
        (yes_votes/(yes_votes + no_votes)) >= 0.70;

-- [Problem 10]
-- This hall_of_fame view contains information about the
-- members who have rated all of the coffees and who 
-- have not been suspended. It finds the members who have
-- rated all the coffees by counting the number of coffees
-- and comparing it to the number of ratings.

CREATE VIEW hall_of_fame AS
    SELECT email, member_name, member_street, member_city
    FROM (SELECT email, member_name, member_street, member_city,
        COUNT(score) AS num_ratings, suspended
        FROM club NATURAL JOIN rating
        GROUP BY email) AS email_count
    WHERE num_ratings IN
        (SELECT COUNT(coffee_id) AS num_coffees
        FROM coffee) AND 
        suspended = FALSE;
        
-- These should help speed up the queries.
-- They were chosen because they are commonly used
-- attributes in the queries I wrote above.

CREATE INDEX idx ON club (email);
CREATE INDEX idx2 ON coffee (coffee_id);