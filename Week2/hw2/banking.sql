USE ayaanaps_db;

-- [Problem 1a]
-- This finds loan numbers whose amount is between 1000 and 2000.

SELECT loan_number, amount 
FROM loan 
WHERE amount <= 2000 AND amount >= 1000;

-- [Problem 1b]
-- This finds all loans owned by Smith.

SELECT loan_number, amount 
FROM loan NATURAL JOIN borrower 
WHERE customer_name = 'SMITH' 
ORDER BY loan_number;

-- [Problem 1c]
-- This finds the branch_city where 'A-446' was opened.

SELECT branch_city 
FROM account NATURAL JOIN branch
WHERE account_number = 'A-446';

-- [Problem 1d]
-- This finds the information relating to the customers whose names
-- begin with 'J'. The information is ordered by customer_name.

SELECT customer_name, account_number, branch_name, balance 
FROM account NATURAL JOIN depositor 
WHERE customer_name LIKE 'J%' 
ORDER BY customer_name;

-- [Problem 1e]
-- This finds the customers who have more than 5 accounts.
SELECT customer_name 
FROM depositor 
GROUP BY customer_name 
HAVING COUNT(account_number) > 5;

-- [Problem 2a]
-- This view contains the information for customers of the Pownal branch.

DROP VIEW IF EXISTS pownal_customers;

CREATE VIEW pownal_customers AS 
    SELECT account_number, customer_name 
    FROM account NATURAL JOIN depositor 
    WHERE branch_name = 'Pownal';

-- [Problem 2b]
-- This returns the information of customers who have an account,
-- but not a loan.

DROP VIEW IF EXISTS onlyacct_customers;

CREATE VIEW onlyacct_customers AS
    SELECT *
    FROM customer
    WHERE customer_name IN (SELECT customer_name FROM depositor)
        AND customer_name NOT IN (SELECT customer_name FROM borrower);
    
-- [Problem 2c]
-- This finds the name, total balance and average balance for each branch.

DROP VIEW IF EXISTS branch_deposits;

CREATE VIEW branch_deposits AS
    SELECT branch_name, IFNULL(SUM(balance), 0) AS total_bal, 
        IFNULL(AVG(balance), NULL) AS avg_bal 
    FROM branch NATURAL LEFT JOIN account GROUP BY branch_name;

-- [Problem 3a]
-- This finds cities where customers live, where there is no branch.

SELECT DISTINCT customer_city 
FROM customer 
WHERE customer_city NOT IN (SELECT branch_city FROM branch) 
ORDER BY customer_city;

-- [Problem 3b]
-- This finds the customers who have neither an account nor a loan.

SELECT customer_name 
FROM customer 
WHERE customer_name NOT IN 
    (SELECT customer_name FROM borrower NATURAL JOIN loan) 
AND customer_name NOT IN 
    (SELECT customer_name FROM depositor NATURAL JOIN account);

-- [Problem 3c]
-- This increases the balance of each account held at branches in 
-- 'Horseneck' by $50.

UPDATE account SET balance = balance + 50 
WHERE branch_name IN 
    (SELECT branch_name FROM branch WHERE branch_city = 'Horseneck');

-- [Problem 3d]
-- This increases the balance of each account held at branches in 
-- 'Horseneck' by $50.

UPDATE account, branch SET balance = balance + 50 
WHERE branch_city = 'Horseneck';

-- [Problem 3e]
-- This finds all the data for the largest account held at each branch.

SELECT account_number, branch_name, balance 
FROM account NATURAL JOIN 
    (SELECT branch_name, MAX(balance) AS balance 
    FROM account 
    GROUP BY branch_name) AS maxPer;

-- [Problem 3f]
-- This finds all the data for the largest account held at each branch.

SELECT account_number, branch_name, balance 
FROM account 
WHERE (branch_name, balance) IN 
    (SELECT branch_name, MAX(balance) AS balance 
    FROM account 
    GROUP BY branch_name);

-- [Problem 4]
-- This ranks all the branches by largest assets held.
-- This is done by joining branch with a copy of itself and then
-- comparing the size of the assets.

SELECT branch.branch_name, branch.assets, 
    COUNT(branch_copy.branch_name) + 1 AS rank 
FROM branch LEFT JOIN branch AS branch_copy 
    ON branch.assets < branch_copy.assets
GROUP BY branch.branch_name, branch.assets 
ORDER BY rank, branch_name; 