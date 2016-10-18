-- [Problem 1]

/* This creates an index on the account with
branch_name and balance because those are used for
the triggers written below and thus make
computations faster. */

CREATE INDEX idx ON account (branch_name, balance);

-- [Problem 2]
/* This creates the materialized view
mv_branch_account_stats with the appropriate
columns. */

CREATE TABLE mv_branch_account_stats (
    branch_name VARCHAR(20) PRIMARY KEY,
    num_accounts INTEGER NOT NULL,
    total_deposits NUMERIC (12, 2) NOT NULL,
    min_balance NUMERIC (12, 2) NOT NULL,
    max_balance NUMERIC (12, 2) NOT NULL
);

-- [Problem 3]
/* This inserts the correct values from
account into mv_branch_account_stats */

INSERT INTO mv_branch_account_stats
    (SELECT branch_name,
        COUNT(*) AS num_accounts,
        SUM(balance) AS total_deposits,
        MIN(balance) AS min_balance,
        MAX(balance) AS max_balance
    FROM account GROUP BY branch_name);


-- [Problem 4]
/* This creates a view called branch_account_stats
that contains all the columns. It also includes
avg_balance which it computes using its other values
num_accounts and total_deposits. */

CREATE VIEW branch_account_stats AS
    SELECT branch_name,
        num_accounts,
        total_deposits,
        (total_deposits/num_accounts) AS avg_balance,
        min_balance,
        max_balance
    FROM mv_branch_account_stats;

-- [Problem 5]
/* This is a trigger for inserts into account that 
updates the values of mv_branch_account_stats. It uses
a procedure to insert the appropriate values if it is the
first branch_name. If it is an already existing branch, it
updates th values. */

DELIMITER !

CREATE TRIGGER trg_branch_account_inserts AFTER INSERT
ON account FOR EACH ROW
BEGIN

    CALL help_insert(NEW.branch_name, NEW.balance);
    
END !

DELIMITER ;

DELIMITER !

CREATE PROCEDURE help_insert (
    IN branchName VARCHAR(20),
    IN bal NUMERIC(12, 2)
)
BEGIN
    INSERT INTO mv_branch_account_stats VALUES
        (branchName, 1, bal, bal, bal)
    ON DUPLICATE KEY UPDATE
        num_accounts = num_accounts + 1,
        total_deposits = total_deposits + bal,
        min_balance = LEAST(min_balance, bal),
        max_balance = GREATEST(max_balance, bal);
END !

DELIMITER ;

-- [Problem 6]
/* This is a trigger for deletes into account that 
updates the values of mv_branch_account_stats. It uses
a procedure to delete the branch if it is the first one.
If it is an already existing branch, it
updates the values. */

DELIMITER !

CREATE TRIGGER trg_branch_account_deletes AFTER DELETE
ON account FOR EACH ROW
BEGIN
    CALL help_delete(OLD.branch_name, OLD.balance);
END !

DELIMITER ;

DELIMITER !

CREATE PROCEDURE help_delete (
    IN branchName VARCHAR(20),
    IN bal NUMERIC(12, 2)
)
BEGIN

    DECLARE newMaxBal NUMERIC(12, 2);
    DECLARE newMinBal NUMERIC(12, 2);
    DECLARE countBranch INTEGER;
    
    SELECT MAX(balance), MIN(balance), COUNT(branch_name) 
        INTO newMaxBal, newMinBal, countBranch
    FROM account
    WHERE branch_name = branchName;
    
    IF countBranch = 0 THEN
        DELETE FROM mv_branch_account_stats
        WHERE branch_name = branchName;
    ELSE
        UPDATE mv_branch_account_stats SET 
            num_accounts = num_accounts - 1,
            total_deposits = total_deposits - bal,
            min_balance = newMinBal,
            max_balance = newMaxBal
        WHERE branch_name = branchName;
    END IF;
END !

DELIMITER ;

-- [Problem 7]
/* This is a trigger for updates into account that 
updates the values of mv_branch_account_stats. It 
uses the insert and delete keys if the old and new
branch_names are not equal. If they are equal, 
then the values are appropriately updated. */

DELIMITER !

CREATE TRIGGER trg_branch_account_updates AFTER UPDATE
ON account FOR EACH ROW
BEGIN
    
    DECLARE newMaxBal NUMERIC(12, 2);
    DECLARE newMinBal NUMERIC(12, 2);
    
    SELECT MAX(balance), MIN(balance)
        INTO newMaxBal, newMinBal
    FROM account
    WHERE branch_name = NEW.branchName;
    
    IF OLD.branch_name = NEW.branch_name THEN
        UPDATE mv_branch_account_stats SET
            total_deposits = total_deposits - OLD.balance + NEW.balance,
            min_balance = newMinBal,
            max_balance = newMaxBal
        WHERE branch_name = NEW.branch_name;
    ELSE
        CALL help_delete(OLD.branch_name, OLD.balance);
        CALL help_insert(NEW.branch_name, NEW.balance);
        
    END IF;
    
END !

DELIMITER ;
