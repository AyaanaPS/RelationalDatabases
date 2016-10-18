-- [Problem a]

-- This correlated query counts how many loans each customer has,
-- ordered by decreasing amount of loans.
-- To make it decorrelated, I used a Natural Left Join.

SELECT customer_name, COUNT(loan_number) AS num_loans
FROM customer NATURAL LEFT JOIN borrower
GROUP BY customer_name
ORDER BY num_loans DESC;


-- [Problem b]

-- This query selects the branches who have more assets than total
-- loans given out. To decorrelate, I selected from a derived
-- table.

SELECT branch_name 
FROM (
    SELECT branch_name, SUM(amount) AS tot_loans 
    FROM loan
    GROUP BY branch_name) 
    AS branch_loans NATURAL JOIN branch
WHERE assets < tot_loans;

-- [Problem c]

-- This computes the number of accounts and the number of loans
-- at each branch by selecting each of these attributes
-- individually from different tables.

SELECT branch_name, 
    (SELECT COUNT(account_number) FROM account a
    WHERE a.branch_name = b.branch_name) AS num_accounts,
    (SELECT COUNT(loan_number) FROM loan l
    WHERE l.branch_name = b.branch_name) AS num_loans
FROM branch b ORDER BY branch_name;

-- [Problem d]

-- This is a decorrelated version of the above query. 
-- To decorrelate it, I Natural Left Joined branch, loan and
-- account and then selected the desired attributes.

SELECT branch_name, COUNT(DISTINCT account_number) AS num_accounts, 
    COUNT(DISTINCT loan_number) AS num_loans
FROM branch NATURAL LEFT JOIN loan NATURAL LEFT JOIN account
GROUP BY branch_name;
