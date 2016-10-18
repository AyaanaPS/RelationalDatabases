-- [Problem 1]
-- This function deposits the inputted amount into the 
-- inputted account. It uses transactions to ensure
-- that the data is locked while the function interacts
-- it. The function returns a status which indicates
-- the success of the transaction.

-- DROP PROCEDURE IF EXISTS sp_deposit;

DELIMITER !

CREATE PROCEDURE sp_deposit (
    IN account_number VARCHAR(15),
    IN amount NUMERIC(12, 2),
    OUT status INTEGER
) BEGIN

    DECLARE saved_balance NUMERIC(12, 2);
    
    IF amount < 0
        THEN SET STATUS = -1;
        
    ELSE
        START TRANSACTION;
            
            SELECT balance INTO saved_balance
            FROM account
            WHERE account.account_number = account_number
            FOR UPDATE;
            
            IF saved_balance IS NULL
                THEN SET status = -2;
            ELSE 
                UPDATE account
                    SET balance = balance + amount
                    WHERE account.account_number = account_number;
                IF ROW_COUNT() > 0 THEN
                    -- if there is actually a change, commit.
                    COMMIT;
                    SET status = 0;
                ELSE
                    -- if there is no change, rollback all updates.
                    ROLLBACK;
                    SET status = -2;
                END IF;
                    
            END IF;
            
    END IF;
    
END !

DELIMITER ;

-- [Problem 2]
-- This function withdraws the inputted amount out of the 
-- inputted account. It uses transactions to ensure
-- that the data is locked while the function interacts
-- it. The function returns a status which indicates
-- the success of the transaction.

DROP PROCEDURE IF EXISTS sp_withdraw;

DELIMITER !

CREATE PROCEDURE sp_withdraw (
    IN account_number VARCHAR(15),
    IN amount NUMERIC(12, 2),
    OUT status INTEGER
) BEGIN

    DECLARE saved_balance NUMERIC(12, 2);
    
    IF amount < 0
        THEN SET STATUS = -1;
        
    ELSE
        START TRANSACTION;
            
            SELECT balance INTO saved_balance
            FROM account
            WHERE account.account_number = account_number
            FOR UPDATE;
            
            IF saved_balance IS NULL
                THEN SET status = -2;
            ELSEIF saved_balance < amount
                THEN SET status = -3;
            ELSE 
                UPDATE account
                    SET balance = balance - amount
                    WHERE account.account_number = account_number;
                IF ROW_COUNT() > 0 THEN
                    -- if there is actually a change, commit.
                    COMMIT;
                    SET status = 0;
                ELSE
                    -- if there is no change, rollback all updates.
                    ROLLBACK;
                    SET status = -2;
                    
                END IF;
                    
            END IF;
       
    END IF;
    
END !

DELIMITER ;

-- [Problem 3]
-- This function transfers the inputted amount between the 
-- inputted accounts. It uses transactions to ensure
-- that the data is locked while the function interacts
-- it. The function returns a status which indicates
-- the success of the transaction.

DROP PROCEDURE IF EXISTS sp_transfer;

DELIMITER !

CREATE PROCEDURE sp_transfer (
    IN account_1_number VARCHAR(15),
    IN account_2_number VARCHAR(15),
    IN amount NUMERIC(12, 2),
    OUT status INTEGER
) BEGIN

    DECLARE saved_balance1 NUMERIC(12, 2);
    DECLARE saved_balance2 NUMERIC(12, 2);
    
    IF amount < 0
        THEN SET STATUS = -1;
        
    ELSE
        START TRANSACTION;
            
            SELECT balance INTO saved_balance1
            FROM account
            WHERE account_number = account_1_number
            FOR UPDATE;
            
            SELECT balance INTO saved_balance2
            FROM account
            WHERE account_number = account_2_number
            FOR UPDATE;
            
            IF saved_balance1 IS NULL OR saved_balance2 IS NULL
                THEN SET status = -2;
            ELSEIF saved_balance1 < amount
                THEN SET status = -3;
            ELSE 
                UPDATE account
                    SET balance = balance - amount
                    WHERE account.account_number = account_1_number;

                UPDATE account
                    SET balance = balance + amount
                    WHERE account.account_number = account_2_number;
                
                IF ROW_COUNT() > 0 THEN
                    -- if there is actually a change, commit.
                    COMMIT;
                    SET status = 0;
                ELSE
                    -- if there is no change, rollback all updates.
                    ROLLBACK;
                    SET status = -2;
                    
                END IF;
                
            END IF;
            
    END IF;
    
END !

DELIMITER ;
