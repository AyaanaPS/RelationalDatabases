-- [Problem 3]

-- These tables are dropped in an order that 
-- respects the referential integrity.


-- Fact Tables

DROP TABLE IF EXISTS visitor_fact;
DROP TABLE IF EXISTS resource_fact;

-- Dimension Tables

DROP TABLE IF EXISTS datetime_dim;
DROP TABLE IF EXISTS resource_dim;
DROP TABLE IF EXISTS visitor_dim;

-- This dimension table contains information about 
-- the date and time of the requests.

CREATE TABLE datetime_dim (
    -- This is an auto incrementing integer specifying
    -- the unique date of the request.
    date_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This contains the date of the request.
    date_val DATE NOT NULL,
    
    -- This contains the hour of the request.
    hour_val INTEGER NOT NULL,
    
    -- This boolean specifies if the date lies
    -- on a weekend.
    weekend BOOLEAN NOT NULL,
    
    -- This specifies if the date is a holiday. It
    -- can be Null.
    holiday VARCHAR(20),
    
    -- The combination of date and hour is a candidate
    -- key.
    UNIQUE KEY(date_val, hour_val)
);

-- This dimension table contians information about 
-- the resources for each request.

CREATE TABLE resource_dim (
    -- This is an auto incrementing integer specifying
    -- the unique resources of the request.
    resource_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This contains the resource of the request.
    resource VARCHAR(200) NOT NULL,
    
    -- This contains the method of the request.
    method VARCHAR(15),
    
    -- This contains the protocol of the request.
    protocol VARCHAR(200),
    
    -- This contains the response to the request. It
    -- cannot be Null.
    response INTEGER NOT NULL,
    
    -- The combination of resource, method, protocol, 
    -- response
    UNIQUE KEY(resource, method, protocol, response)
);

-- This dimension table contains information about 
-- the visitors for each request.

CREATE TABLE visitor_dim (
    -- This is an auto incrementing integer specifying
    -- the unique visitor of the request.
    visitor_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    
    -- This contains the ip address of the request.
    ip_addr VARCHAR(200) NOT NULL,
    
    -- This contains the unique visit_val. It is a 
    -- candidate key.
    visit_val INTEGER NOT NULL UNIQUE
);

-- This fact table contains information about resources.

CREATE TABLE resource_fact (
    -- This is the unique date id for the resource.
    date_id INTEGER,
    
    -- This is the unique resource id.
    resource_id INTEGER,
    
    -- This is the number of requests for each resource.
    num_requests INTEGER NOT NULL,
    
    -- This is the total number of bytes sent for each
    -- resource.
    total_bytes BIGINT,
    
    -- The combined date_id and resource_id values are the
    -- primary key for this table.
    PRIMARY KEY(date_id, resource_id),
    
    -- The date_id refers to the datetime dimension tables
    -- date_id.
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    
    -- The resource_id refers to the resource dimension tables
    -- resource_id.
    FOREIGN KEY (resource_id) REFERENCES resource_dim(resource_id)
);

-- This fact table contains information about the visitors.
CREATE TABLE visitor_fact (

    -- This is the unique date_id.
    date_id INTEGER,
    
    -- This is the unique visitor_id.
    visitor_id INTEGER,
    
    -- This is the number of requests for each visitor.
    num_requests INTEGER NOT NULL,
    
    -- This is the total number of bytes sent for each
    -- visitor.
    total_bytes BIGINT,
    
    -- The combined date_id and visitor_id values are the
    -- primary key for this table.    
    PRIMARY KEY(date_id, visitor_id),
    
    -- The date_id refers to the datetime dimension tables
    -- date_id.    
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    
    -- The visitor_id refers to the visitor dimension tables
    -- visitor_id.
    FOREIGN KEY (visitor_id) REFERENCES visitor_dim(visitor_id)
);
    