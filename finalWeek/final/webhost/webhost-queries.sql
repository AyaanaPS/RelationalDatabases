-- [Problem 4a]

-- This finds the shared servers who have more accounts
-- than their max sites value. It uses a subquery to 
-- compute the number of accounts for every shared
-- server and then compares this number to the maxSites
-- value. It returns the hostname from this subquery.

SELECT hostname
FROM
    (SELECT hostname, COUNT(username) AS numSites
    FROM basicAccount NATURAL JOIN
    (sharedServer NATURAL JOIN servers)
    GROUP BY hostname
    HAVING COUNT(username) > maxSites) AS valid_hosts;


-- [Problem 4b]

-- This updates the customer account table so that
-- the price of basic accounts is lowered by 2 if the
-- account uses 3 or more software packages.
-- It does this by finding the number of packages used
-- and checking to see if it is greater than 3 - if so, 
-- it returns the username.
-- It then updates the price where the account username
-- is in the usernames returned from the above described
-- subquery.

UPDATE customerAccount
    SET subPrice = subPrice - 2
    WHERE username IN
        (SELECT username
        FROM
            (SELECT username, COUNT(*) AS num_packages
            FROM uses NATURAL JOIN 
                (basicAccount NATURAL JOIN customerAccount)
            GROUP BY username
            HAVING COUNT(*) >= 3) AS valid_accounts);
        


