-- [Problem 5]

-- This is a database for a airport.
-- It includes information about each flight,
-- aircraft, customer, etc.

-- This part drops the tables in an order that
-- respects referential integrity.

-- DROP TABLE commands:

DROP TABLE IF EXISTS buys;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS phoneNumbers;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS aircraft;

-- CREATE TABLE commands:

-- This table contains information about each aircraft.
CREATE TABLE aircraft (
    -- This is the International Air Transport Association
    -- type code. It's value is unique for every kind of
    -- aircraft. Thus, it is a fixed character primary key.
    IATA CHAR(3) PRIMARY KEY,
    
    -- This is the aircraft model. Its value cannot be Null.
    model VARCHAR(20) NOT NULL,
    
    -- This is the manufacturer's company. Its value cannot
    -- be Null.
    manufacturer VARCHAR(20) NOT NULL
);

-- This table contains information about each flight.
CREATE TABLE flight (
    -- Each flight has a flight number that is a short string.
    -- This is one of the two primary keys.
    flightNumber VARCHAR(10),
    
    -- Each flight has a particular date.
    flightDate DATE,
    
    -- Each flight has a particular time.
    flightTime TIME NOT NULL,
    
    -- This refers to the source airport IATA code.
    sourceAirport CHAR(3) NOT NULL,
    
    -- This refers to the destination airport IATA code.
    destination CHAR(3) NOT NULL,
    
    -- This flag marks a flight as domestic or international.
    -- If it is True, it is a domestic flight. Else,
    -- it is international.
    domesticFlag BOOLEAN NOT NULL,
    
    -- This is the aircraft type code. 
    -- It is a foreign key that refers to the aircraft
    -- table. It cascades on update and delete.
    IATA CHAR(3) NOT NULL REFERENCES aircraft(IATA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- The combination of flightNumber and flightDate is 
    -- unique.
    PRIMARY KEY (flightNumber, flightDate)
);

-- This has information about the seats available.
CREATE TABLE seat (
    -- This specifies the row of the seat and the letter
    -- specifying the position within the row.
    seatNumber VARCHAR(4),
    
    -- This is the aircraft type code.
    -- It is a foreign key that refers to the aircraft
    -- table. It cascades on update and delete.
    IATA CHAR(3) REFERENCES aircraft(IATA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This refers to the seat class (such as first class,
    -- business or coach). It cannot be Null.
    class VARCHAR(10) NOT NULL,
    
    -- This is the type of seat (aisle, middle, window). 
    -- It cannot be Null.
    seatType VARCHAR(10) NOT NULL,
    
    -- This flag specifies if the seat is in an exit row.
    -- If it is true, then it is in an exit row.
    exitFlag BOOLEAN NOT NULL,
    
    -- This specifies the primary keys of the table:
    -- seatNumber and IATA.
    PRIMARY KEY (seatNumber, IATA)
);

-- This table refers to customers generally.
CREATE TABLE customer (
    -- This is the customerID. This is the auto
    -- incrementing primary key.
    customerID INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This represents the customers first name.
    -- It cannot be null.
    firstName VARCHAR(20) NOT NULL,
    
    -- This represents the customers last name.
    -- It cannot be null.
    lastName VARCHAR(20) NOT NULL,
    
    -- This represents the customers email.
    -- It cannot be null.
    email VARCHAR(50) NOT NULL
);

-- This table refers to the phone numbers associated
-- with each customer.
CREATE TABLE phoneNumbers (

    customerID INTEGER REFERENCES customer(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    -- This refers to the phone numbers.
    phoneNumber VARCHAR(20),
    
    -- This specifies the primary keys. The customerID and
    -- phoneNumber will be unique combinations.
    PRIMARY KEY (customerID, phoneNumber)
);

-- This table describes travelers (people who are actually
-- going on a particular flight. All values except the customerID
-- can be null.
CREATE TABLE traveler (
    -- This refers to the customer ID. It is a foreign
    -- key that refers to the customer table. It 
    -- cascades on delete and on update.    
    customerID INTEGER PRIMARY KEY REFERENCES customer(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This refers to the customers passport number.
    passportNo VARCHAR(40),
    
    -- This refers to the customers country of citizenship.
    citizenship VARCHAR(25),
    
    -- This refers to the name of an emergency contact. It is
    -- the full name.
    contactName VARCHAR(20),
    
    -- This is the single phone number for the above given
    -- phone number.
    contactPhone VARCHAR(20),
    
    -- This is the optionally entered frequent flyer number. 
    frequentFlyerNo CHAR(7)
);

-- This refers to the purchasers. These are the people who
-- purchase tickets for specific flights.
CREATE TABLE purchaser (
    -- This refers to the customer ID. It is a foreign
    -- key that refers to the customer table. It 
    -- cascades on delete and on update.
    customerID INTEGER PRIMARY KEY REFERENCES customer(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE        ,
    
    -- This is the credit card number. It can be Null.
    cardNo CHAR(16),
    
    -- This is the expiration date. It can be Null.
    expDate CHAR(4),
    
    -- This is the verification code. It can be Null.
    securityCode CHAR(3)
);

-- This refers to each purchase made.
CREATE TABLE purchase (
    -- This refers to the unique purchaseID of each purchase.
    -- It is an auto incrementing primary key.
    purchaseID INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This refers to the customer ID. It is a foreign
    -- key that refers to the purchaser table. It 
    -- cascades on delete and on update.
    customerID INTEGER NOT NULL REFERENCES puchaser(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This refers to the date of the purchase. It cannot be
    -- Null.
    purchaseDate TIMESTAMP NOT NULL,
    
    -- This refers to the unique confirmation number of the
    -- purchase. It is a candidate key.
    conf_number CHAR(6) UNIQUE NOT NULL
);

-- This has information about each ticket.
CREATE TABLE ticket (
    -- This refers to the unique ticket ID. It is an
    -- auto incrementing integer and it is the primary
    -- key.
    ticketID INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This refers to the customer ID. It is a foreign
    -- key that refers to the traveler table. It 
    -- cascades on delete and on update.    
    customerID INTEGER NOT NULL REFERENCES traveler(customerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This refers to the purchase ID. It is a foreign key
    -- that refers to the purchase table. It cascades
    -- on delete and on update.
    purchaseID INTEGER NOT NULL REFERENCES purchase(purchaseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This is the sale price of the ticket. It cannot
    -- be null and is a numeric value.
    salePrice NUMERIC(7, 2) NOT NULL
);
 
-- This table ties the ticket, flight and seat tables.
CREATE TABLE buys (
    -- Each flight has a flight number that is a short string.
    -- This is one of the two primary keys.    
    flightNumber VARCHAR(10),
    
    -- Each flight has a particular date.    
    flightDate DATE,
    
    -- This specifies the row of the seat and the letter
    -- specifying the position within the row.    
    seatNumber VARCHAR(4),
    
    -- This is the aircraft type code.    
    IATA CHAR(3),
    
    -- This refers to the unique ticket ID. It is an
    -- auto incrementing integer. This is a foreign key
    -- that refers to the ticket table.
    ticketID INTEGER UNIQUE REFERENCES ticket(ticketID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- This specifies all of the primary keys.
    PRIMARY KEY (flightNumber, flightDate, seatNumber, IATA),
    
    -- This shows the foreign keys that refer to the flight
    -- table. They both cascade on delete and update.
    FOREIGN KEY (flightNumber, flightDate) 
        REFERENCES flight(flightNumber, flightDate)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
            
    -- This shows the foreign keys that refer to the seat
    -- table. They both cascade on delete and update.        
    FOREIGN KEY (seatNumber, IATA) 
        REFERENCES seat(seatNumber, IATA)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);
    
    
    


