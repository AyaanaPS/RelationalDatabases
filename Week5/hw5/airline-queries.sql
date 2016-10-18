-- [Problem 6a]
-- This displays all the purchase history for a single
-- customer. This retrieves all purchases and ticket
-- information (I was ensure of what to select because that
-- was slightly ambiguous). 

SELECT purchaseID, flightDate, lastName, firstName, salePrice
FROM purchase JOIN ticket USING (purchaseID)
    JOIN customer ON (ticket.customerID = customer.customerID)
    JOIN buys USING (ticketID)
WHERE purchase.customerID = 54321
ORDER BY purchaseDate DESC,
    flightDate, lastName, firstName ASC;
    
-- [Problem 6b]
-- This reports the total revenue from ticket sales for
-- each kind of airplane with a departure time within
-- the last two weeks.

SELECT IATA, SUM(salePrice) AS total_revenue
FROM aircraft NATURAL LEFT JOIN (buys NATURAL JOIN ticket)
WHERE flightDate BETWEEN
    (CURRENT_DATE() - INTERVAL 2 WEEK) AND
        (CURRENT_DATE())
GROUP BY IATA;

-- [Problem 6c]
-- This reports all travelers on international flights that 
-- have not specified all of their information.
SELECT customerID
FROM buys NATURAL JOIN ticket NATURAL JOIN traveler NATURAL JOIN flight
WHERE domesticFlag IS FALSE AND (passportNo IS NULL OR citizenship IS NULL
    OR contactName IS NULL OR contactPhone IS NULL);
