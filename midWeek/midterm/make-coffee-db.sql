-- [Problem 1]

USE ayaanaps_db;

-- This is a database for a coffee shop.
-- It includes information about each store,
-- the coffee club and coffee ratings.

-- This part drops the tables in an order that
-- respects referential integrity.

DROP TABLE IF EXISTS rating;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS club;
DROP TABLE IF EXISTS coffee;

-- This table contains information about each coffee.
CREATE TABLE coffee (
    -- This is the primary key, which is an integer
    -- representing the coffee_id.
    coffee_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This is a candidate key, that cannot be null.
    -- The name must be 20 characters or less.
    coffee_name VARCHAR(100) NOT NULL UNIQUE,
    
    -- This is the coffee category. It cannot be null
    -- and must be 20 characters or less.
    category VARCHAR(20) NOT NULL,
    
    -- This contains information about the price per
    -- lb of the coffee. It is a numeric value so it
    -- can store both dollars and cents. It cannot be
    -- null.
    price_per_lb NUMERIC(5, 2) NOT NULL
);

-- This table contains information about the coffee club.
CREATE TABLE club (
    -- This is the primary key of the table. 
    -- It is the email value that can be at most 100 char.
    email VARCHAR(100) PRIMARY KEY,
    
    -- This represents the member_name. It cannot be null 
    -- and must be at most 100 characters.
    member_name VARCHAR(100) NOT NULL,
    
    -- This represents the member_street. It can be null,
    -- but must be less than or equal to 100 characters.
    member_street VARCHAR(100),
    
    -- This represents the member_city. It can be null,
    -- but must be less than or equal to 100 characters.
    member_city VARCHAR(100)
);

-- This table contains information about each store.
CREATE TABLE store (
    -- This is the primary key. It represents the
    -- store_id, which is an integer value.
    store_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This represents the store_street. It cannot
    -- be null and is at most 100 characters.
    store_street VARCHAR(100) NOT NULL,
    
    -- This represents the store_city. It cannot
    -- be null and is at most 100 characters.
    store_city VARCHAR(100) NOT NULL,
    
    -- This represents the store_phone number. It
    -- cannot be null and is exactly 14 characters.
    -- It is always formatted (xxx) xxx-xxxx
    store_phone CHAR(14) NOT NULL,
    
    -- This represents the opening date. It cannot
    -- be null and is a date value.
    opening_date DATE NOT NULL
);

-- This table contains information about each rating.
CREATE TABLE rating (
    -- This refers to the coffe ID. This is an integer.
    coffee_id INTEGER,
    
    -- This refers to the email, which is at most 100
    -- characters.
    email VARCHAR(100),
    
    -- This refers to the score (rating). This cannot be
    -- null. It is a numeric rating of 0 to 5 in 0,5
    -- step increments. The check statement is below.
    score NUMERIC(2, 1) NOT NULL,
    
    -- This refers to the comment, which can be null.
    -- It must be at most 1000 characters.
    comment VARCHAR(10000),
    
    -- This refers to how many other users agree with
    -- the rating. It cannot be null. It is an integer
    -- that defaults to 0.
    yes_votes INTEGER DEFAULT 0 NOT NULL,
    
    -- This refers to how many other users disagree with
    -- this rating. It cannot be null. It is an integer
    -- that defaults to 0.
    no_votes INTEGER DEFAULT 0 NOT NULL,
    
    -- This labels the primary keys, which are
    -- coffee_id and email.
    PRIMARY KEY (coffee_id, email),
    
    -- coffee_id refers to coffee_id in the coffee table.
    -- It cascades on delete and update.
    FOREIGN KEY(coffee_id) REFERENCES coffee(coffee_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    
    -- email refers to the email in the club table.
    -- It cascades on delete and update.
    FOREIGN KEY(email) REFERENCES club(email)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    
    -- This check ensures that the score is one of the
    -- possible values.
    CHECK (score IN
        (0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 4))
);


    