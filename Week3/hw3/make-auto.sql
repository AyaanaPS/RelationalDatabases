-- [Problem 1]
USE ayaanaps_db;

-- This is simple auto insurance database.

-- This part drops the tables in an order than respects
-- referential integrity.

DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS accident;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS person;

-- This table contains information about the driver.
CREATE TABLE person (
    -- This is the primary key. It is exactly 10 chars.
    driver_id CHAR(10) PRIMARY KEY,
    
    -- This is the name. It cannot be null.
    name CHAR(50) NOT NULL,
    
    -- This is the address. It cannot be null.
    address CHAR(200) NOT NULL
);

-- This table contains information about each car.
CREATE TABLE car (
    -- This is the primary key. It is exactly 7 chars.
    license CHAR(7) PRIMARY KEY,
    
    -- This is the model. It can be NULL.
    model VARCHAR(20),
    
    -- This is the year. It can be NULL.
    year INT
);

-- This table links each person to a car.
CREATE TABLE owns (

    -- This is one primary key. It is exactly 10 chars.
    driver_id CHAR(10),
    
    -- This is the other primary key. It is exactly 7 chars.
    license CHAR(7),
    
    -- This labels the primary keys.
    PRIMARY KEY (driver_id, license),
    
    -- driver_id refers to the driver_id in the person table.
    -- It cascades on delete and on update.
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    
    -- license refers to the license in the car table.
    -- It cascades on delete and on update.
    FOREIGN KEY (license) REFERENCES car(license)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- This table documents every accident that occurs.
CREATE TABLE accident (
    -- This is the auto incrementing report number.
    -- It is also the primary key and thus, can't be NULL.
    report_number INT AUTO_INCREMENT PRIMARY KEY,
    
    -- This is the date that the accident occurred. 
    date_occurred TIMESTAMP NOT NULL,
    
    -- This is where the accident occurred.
    location VARCHAR(200) NOT NULL,
    
    -- This is a description of the accident.
    description VARCHAR(5000)
);

-- This table documents the people involved in each accident.
CREATE TABLE participated (
    -- This is the driver_id of the participant.
    driver_id CHAR(10),
    
    -- This is the license of the of participant.
    license CHAR(7),
    
    -- This is the accident report number. It is an int.
    report_number INT,
    
    -- This is the damage_account. It has a monetary value.
    damage_account NUMERIC(10, 2),
    
    -- This labels the primary keys.
    PRIMARY KEY (driver_id, license, report_number),
    
    -- driver_id refers to the driver_id in the person table.
    -- It cascades on update.
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
    ON UPDATE CASCADE,
    
    -- license refers to the license in the car table.
    -- It cascades on update.
    FOREIGN KEY (license) REFERENCES car(license)
    ON UPDATE CASCADE,
    
    -- report_number refers to the accident report_number.
    -- It cascades on update.
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
    ON UPDATE CASCADE
);

