USE ayaanaps_db;

-- [Problem 1a]

/* 
 * This table contains information about the user.
 * including username, salt values and hashed
 * version of the password.
*/
DROP TABLE IF EXISTS user_info;

CREATE TABLE user_info (
    -- This represents the username. It is at most
    -- 20 characters long.
    username VARCHAR(20) PRIMARY KEY,
    
    -- This represents the salt value. It must be 
    -- at least 6 characters long (figure out how to
    -- do this.
    salt CHAR(20) NOT NULL,
    
    -- This is the hashed version of the password. It
    -- is generated in 256 bits and is represented as
    -- a sequence of hexadecimal characters.
    -- This is a value of exactly 64 characters. Each
    -- character holds 4 bits, so this holds exactly
    -- 256 bits.
    password_hash CHAR(64) NOT NULL
);

-- [Problem 1b]

/* This function adds a new user to the user_info
 * table. It adds the salt value and the hashed
 * and salt appended password.
*/

DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !

CREATE PROCEDURE sp_add_user(
    IN new_username VARCHAR(20),
    IN new_password VARCHAR(20)
)
BEGIN
    DECLARE salt CHAR(6);
    DECLARE hashed_password CHAR(64);
    
    SET salt = make_salt(6);
    SELECT CONCAT(new_password, salt) INTO new_password;
    SELECT SHA2(new_password, 256) INTO hashed_password;
    
    INSERT INTO user_info VALUES(new_username, salt, hashed_password);
    
END !
    
DELIMITER ;

-- [Problem 1c]

/* This function updates the password for an existing
 * user. It generates a new salt value.
*/

DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !

CREATE PROCEDURE sp_change_password(
    IN username VARCHAR(20),
    IN new_password VARCHAR(20)
)
BEGIN
    DECLARE new_salt CHAR(6);
    DECLARE changed_password CHAR(64);
    
    SET new_salt = make_salt(6);
    SELECT CONCAT(new_password, new_salt) INTO new_password;
    SELECT SHA2(new_password, 256) INTO changed_password;
    
    UPDATE user_info
        SET password_hash = changed_password, salt = new_salt
        WHERE user_info.username = username;

END !

DELIMITER ;
    
-- [Problem 1d]

DROP FUNCTION IF EXISTS authenticate; 

DELIMITER !

CREATE FUNCTION authenticate(
    usernameToCheck VARCHAR(20),
    passwordToCheck VARCHAR(25)
) RETURNS BOOLEAN

BEGIN
    
    DECLARE actualPassword CHAR(64);
    DECLARE salt_val VARCHAR(20);
    DECLARE computedPassword CHAR(64);
    
    
    IF usernameToCheck NOT IN 
        (SELECT username FROM user_info)
        THEN RETURN False;
    
    END IF;
    
    -- Figure out how to do this in one select statement.
    
    SELECT salt, password_hash INTO salt_val, actualPassword
    FROM user_info
    WHERE username = usernameToCheck;
    
    SELECT CONCAT(passwordToCheck, salt_val) INTO passwordToCheck;
    SELECT SHA2(passwordToCheck, 256) INTO computedPassword;
    
    IF computedPassword = actualPassword
        THEN RETURN True;
    ELSE RETURN False;
    
    END IF; 
    
END !

DELIMITER ;
        

SELECT * FROM user_info;

CALL sp_add_user('alice', 'hello');
CALL sp_add_user('bob', 'goodbye');

SELECT authenticate('carl', 'hello');
SELECT authenticate('alice', 'goodbye');
SELECT authenticate('alice', 'hello'); 
SELECT authenticate('bob', 'goodbye'); 

-- Error: Truncated incorrect Double value

CALL sp_change_password('alice', 'greetings');

SELECT authenticate('alice', 'hello'); 
SELECT authenticate('alice', 'greetings'); 
SELECT authenticate('bob', 'greetings'); 
