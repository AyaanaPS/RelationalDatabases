-- [Problem 3]

-- This is a database for a web hosting service,
-- which is a company that provides web servers
-- for customers to use for their websites. It
-- includes information about each customer
-- account, server and packages hosted/installed.

-- This part drops the tables in an order that
-- respects referential integrity.

-- DROP TABLE commands

DROP TABLE IF EXISTS installed;
DROP TABLE IF EXISTS uses;
DROP TABLE IF EXISTS packages;
DROP TABLE IF EXISTS preferredAccount;
DROP TABLE IF EXISTS basicAccount;
DROP TABLE IF EXISTS dedicatedServer;
DROP TABLE IF EXISTS sharedServer;
DROP TABLE IF EXISTS servers;
DROP TABLE IF EXISTS customerAccounts;

-- CREATE TABLE commands

-- This table contains information about each account.
CREATE TABLE customerAccount (
    -- This represents the username
    username VARCHAR(20) PRIMARY KEY,
    
    -- This represents the email of the customer.
    email VARCHAR(50),
    
    -- This represents the URL of their website.
    -- It is a unique value and thus a candidate key.
    webURL VARCHAR(200) UNIQUE,
    
    -- This indicates the timestamp that the customer
    -- opened an account. I was unsure of whether both
    -- date and time were necessary (which seemed more
    -- logical) or just the time
    -- This is not null because the account must have
    -- been opened at some time.
    openTime DATETIME NOT NULL,
    
    -- This indicates the monthly subscription price that
    -- the customer must pay.
    -- This is not null because the customer must pay
    -- something (or $0)
    subPrice NUMERIC(12, 2) NOT NULL,
    
    -- This indicates the type of the account. If it is
    -- basic, it is denoted by a 'b'. If it is preferred,
    -- it is denoted by a 'p'. It cannot be Null because
    -- accounts must be one of these two types.
    accountType CHAR(1) NOT NULL
);

-- This table contains information about each server.
CREATE TABLE servers (
    -- This represents the hostname
    hostname VARCHAR(40) PRIMARY KEY,
    
    -- This represents the operating-system type.
    OSType VARCHAR(25),
    
    -- This represents the maximum number of sites
    -- that can be hosted on the machine.
    maxSites INTEGER NOT NULL
);

-- This table contains all the servers that are of type 
-- This table contains information about each package.
CREATE TABLE packages (
    -- This represents the package name
    packageName VARCHAR(40),
    
    -- This represents the package version.
    version VARCHAR(20),
    
    -- This is a brief description of the package
    description VARCHAR(1000),
    
    -- This is the monthly price of the package. T his
    -- is not null because the customer must have to
    -- pay something (or $0)
    price NUMERIC(12, 2) NOT NULL,
    
    -- The primary key is a combination of the 
    -- package name and version.
    PRIMARY KEY (packageName, version)
);

-- This table contains information about the packages used
-- by each account. Every account can use multiple
-- packages and every package can be used by multiple
-- accounts.
CREATE TABLE uses (
    -- This represents the account username from the
    -- account table. It is a foreign key.
    username VARCHAR(20) 
        REFERENCES customerAccount(username),
    
    -- This represents the package name from the 
    -- packages table. It is a foreign key.
    packageName VARCHAR(40) 
        REFERENCES packages(packageName),
    
    -- This represents the package version from the
    -- packages table. It is a foreign key.
    version VARCHAR(20)
        REFERENCES packages(version),
    
    -- The following combination is the primary  key.
    PRIMARY KEY (username, packageName, version)
);

-- This table contains information about the packages used
-- by each server. Every server must install at least one 
-- package and every package must be installed by at least one
-- server. Every server can install multiple packages and every
-- package can be installed by multiple servers.
CREATE TABLE installed (
    -- This represents the server hostname from the server
    -- table. It is a foreign key.
    hostname VARCHAR(40)
        REFERENCES servers(hostname),
    
    -- This represents the package name from the packages table.
    -- It is a foreign key.
    packageName VARCHAR(40)
        REFERENCES packages(packageName),
        
    -- This represents the package version from the packages
    -- table. It is a foreign key.
    version VARCHAR(20)
        REFERENCES packages(version),
    
    -- The following combination is the primary key.
    PRIMARY KEY (hostname, packageName, version)
);

-- This table contains all the servers that are shared.
CREATE TABLE sharedServer (
    -- This represents the server hostname from the
    -- server table. It is a foreign key.
    hostname VARCHAR(40) PRIMARY KEY
        REFERENCES servers(hostname)
);

-- This table contains all the servers that are dedicated.
CREATE TABLE dedicatedServer (
    -- This represents the server hostname from the server
    -- table. It is a foreign key.
    hostname VARCHAR(40) PRIMARY KEY
        REFERENCES servers(hostname)
);

-- This table contains all accounts that are basic.
CREATE TABLE basicAccount (
    -- This represents the account username from the
    -- customerAccount table. It is a foreign key.
    username VARCHAR(20) PRIMARY KEY
        REFERENCES customerAccount(hostname),
    
    -- This represents the server hostname. The server
    -- must be shared. This is a foreign key.
    hostname VARCHAR(40) NOT NULL
        REFERENCES sharedServer(hostname)
);

-- This table contains all accounts that are preferred.
CREATE TABLE preferredAccount (
    -- This represents the account username from the
    -- customerAccount table. It is a foreign key.
    username VARCHAR(20) PRIMARY KEY
        REFERENCES customerAccount(hostname),
    
    -- This represents the server hostname. The server
    -- must be dedicated. This is a foreign key.
    hostname VARCHAR(40) NOT NULL
        REFERENCES dedicatedServer(hostname)
        
);


