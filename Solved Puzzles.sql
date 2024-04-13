--PUZZLE 1:
SELECT COALESCE(xx.item, '') AS 'Item Cart 1', COALESCE(xx.item2,'') AS 'Item Cart 2'
FROM 
(SELECT c1.item AS item, c2.item AS item2, 1 AS sort
FROM #Cart1 AS c1
JOIN #Cart2 AS c2
ON c1.item = c2.item
UNION
SELECT c1.item AS item, c2.item AS item2, 2 AS sort
FROM #Cart1 AS  c1
LEFT JOIN #Cart2 AS c2
ON c1.item = c2.item
WHERE c2.item IS NULL
UNION 
SELECT c1.item AS item, c2.item AS item2, 3 AS sort
FROM #Cart1 AS c1
RIGHT JOIN #Cart2 AS c2
ON c1.item = c2.item
WHERE c1.item IS NULL) xx
ORDER BY sort, xx.item DESC;

--PUZZLE 2: 
WITH employee_hier (employeeID, ManagerID, JobTitle, Depth) AS 
(SELECT employeeID, ManagerID, JobTitle, 0 AS Depth
FROM #Employees 
WHERE JobTitle = 'President'
UNION ALL 
SELECT ee.employeeID, ee.ManagerID, ee.JobTitle, m.Depth + 1 AS Depth
FROM employee_hier AS m
JOIN #Employees as ee
ON m.employeeID = ee.ManagerID)
SELECT *
FROM employee_hier;

-- PUZZLE 3: 
-- answer (FINISH) 

-- PUZZLE 4: 
SELECT texas.*
FROM #Orders AS cali
JOIN #Orders AS texas
ON cali.CustomerID = texas.CustomerID
AND cali.DeliveryState = 'CA' 
AND texas.DeliveryState = 'TX';

-- PUZZLE 5: 
-- Your customer phone directory table allows to set up a home, cellular, or work phone number. 
-- Convert the column 'Type' into their own columns with the customers' number in the rows 

SELECT *
FROM #PhoneDirectory;

--ANSWER 
SELECT  DISTINCT p.CustomerID, COALESCE((SELECT PhoneNumber
                                FROM #PhoneDirectory pp
                                WHERE [Type] = 'Cellular'
                                AND p.CustomerID = pp.CustomerID),' ') AS Cellular, 
                                      COALESCE((SELECT PhoneNumber
                                      FROM #PhoneDirectory pp
                                      WHERE [Type] = 'Work'
                                      AND p.CustomerID = pp.CustomerID),' ') AS Work, 
                                        COALESCE((SELECT PhoneNumber
                                        FROM #PhoneDirectory pp
                                        WHERE [Type] = 'Home'
                                        AND p.CustomerID = pp.CustomerID),' ') AS Home
FROM #PhoneDirectory AS p;

-- PUZZLE 6:
SELECT Workflow
FROM #WorkflowSteps
GROUP BY Workflow 
HAVING SUM(CASE WHEN CompletionDate IS NULL THEN 1 ELSE 0 END) = 1;

-- PUZZLE 7: 
SELECT c.CandidateID
FROM #Candidates AS c
LEFT JOIN #Requirements AS r
ON c.Occupation = r.Requirement
GROUP BY CandidateID
HAVING SUM(CASE WHEN c.Occupation = r.Requirement THEN 1 ELSE 0 END) = (SELECT COUNT(DISTINCT Requirement)

-- PUZZLE 8:   
SELECT Workflow, Case1 + Case2 + Case3 AS Passed 
FROM #WorkflowCases;
 
-- PUZZLE 9: 
WITH cte AS 
(SELECT employeeid,  ARRAY_TO_STRING(ARRAY_AGG(license),',') AS licenses, COUNT(DISTINCT(license)) AS cnt
FROM Employees
GROUP BY employeeid) 
SELECT a.employeeid, b.employeeid, a.cnt
FROM cte a
JOIN cte b
ON a.licenses = b.licenses
AND a.cnt = b.cnt
AND a.employeeid <> b.employeeid;

--Puzzle 10:
-- MEAN
SELECT ROUND(AVG(integervalue),2)
FROM sampledata;


--MEDIAN
WITH median AS
(SELECT integervalue, PERCENT_RANK() OVER(ORDER BY integervalue) AS rnk
FROM sampledata)
SELECT integervalue 
FROM median 
WHERE rnk = 0.5;

--(different function for median)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY integervalue)  AS median
FROM sampledata;

--MODE 
WITH mode_ AS
(SELECT integervalue, COUNT(integervalue) AS count
FROM sampledata
GROUP BY integervalue
ORDER BY count DESC
LIMIT 1)
SELECT integervalue
FROM mode_;
-- another way with using mode function
SELECT MODE() WITHIN GROUP (ORDER BY integervalue) AS mode_value
FROM sampledata;

-- RANGE 
SELECT MAX(integervalue) - MIN(integervalue) AS range_
FROM sampledata;

-- Puzzle 11:
-- ANSWER (FINISH) 
																		
-- Puzzle 12:
SELECT DISTINCT xx.workflow, FLOOR(AVG(xx.date_diff) OVER (PARTITION BY xx.workflow)) AS Average_Days
FROM
(SELECT *, EXTRACT(DAY FROM AGE(LEAD(executiondate) OVER (PARTITION BY workflow ORDER BY executiondate),executiondate)) AS date_diff
FROM ProcessLog) xx
ORDER BY workflow;

																		
-- PUZZLE 13:																		
SELECT *, SUM(quantityadjustment) OVER (ORDER BY inventorydate) AS current_inventory
FROM inventory;

-- PUZZLE 14:
SELECT workflow,
    CASE WHEN COUNT(DISTINCT runstatus) = 1 THEN MAX(runstatus) 
	     WHEN COUNT(DISTINCT runstatus) > 1 AND COUNT(CASE WHEN runstatus = 'Error' THEN 1 END) > 0 THEN 'Indeterminate' 
	     WHEN COUNT(DISTINCT runstatus) > 1 AND COUNT(CASE WHEN runstatus IN ('Complete', 'Running') THEN 1 END) = 2 THEN 'Running'
         END AS Status
FROM processlog
GROUP BY workflow;


-- Puzzle 15:
SELECT ARRAY_TO_STRING(ARRAY_AGG(string), ' ') AS Syntax
FROM DMLTable;

--Puzzle 16:  
SELECT 
  LEAST(PlayerA, PlayerB) AS PlayerA,
  GREATEST(PlayerA, PlayerB) AS PlayerB,
  SUM(Score) AS TotalScore
FROM 
  PlayerScores
GROUP BY 
  LEAST(PlayerA, PlayerB),
  GREATEST(PlayerA, PlayerB);

-- Puzzle 17:
WITH recursive cte AS 
(SELECT productdescription, quantity, 1 as lvl
FROM Ungroup
UNION 
SELECT productdescription, quantity, lvl + 1 AS lvl
FROM cte 
WHERE quantity > lvl)
SELECT productdescription, 1 AS quantity
FROM cte
ORDER BY productdescription;

-- PUZZLE 18:
SELECT xxr.aa, xxr.gap_end 
FROM
(SELECT xx.aa, xx.bb, LEAD(xx.aa) OVER() - 1 AS gap_end
FROM
(SELECT a.seatnumber AS aa, b.seatnumber AS bb
FROM SeatingChart a
LEFT JOIN seatingchart b
ON a.seatnumber = b.seatnumber - 1
ORDER BY a.seatnumber) xx) xxr
WHERE xxr.bb IS NULL;

-- GAPS 
SELECT GapStart, GapEnd
FROM
(SELECT 1 AS GapStart, MIN(seatnumber) - 1 AS GapEnd, 1 as sort
FROM seatingchart
UNION
SELECT seatnumber + 1 AS GapStart, lead -1 AS GapEnd, 2 as sort
FROM
(SELECT *, LEAD(seatnumber) OVER(), LEAD(seatnumber) OVER() - seatnumber AS summ
FROM seatingchart) 
WHERE summ <> 1)
ORDER BY sort;

-- Missing Numbers
WITH RECURSIVE cte AS 
( SELECT 1 AS num 
 UNION
 SELECT num + 1 
 FROM cte 
 WHERE num < (SELECT MAX(seatnumber)
              FROM seatingchart))
SELECT COUNT(num) AS TotalMissingNumbers
FROM cte a 
LEFT JOIN seatingchart b
ON a.num = b.seatnumber
WHERE seatnumber IS NULL;

-- count of even and odd numbers 
SELECT 'Odd Numbers' AS Type, COUNT(seatnumber)
FROM seatingchart
WHERE MOD(seatnumber, 2) <> 0
UNION
SELECT 'Even Numbers' AS Type, COUNT(seatnumber)
FROM seatingchart
WHERE MOD(seatnumber, 2) = 0;

-- PUZZLE 19: 
WITH defining AS -- defining the end dates as ones with nulls 
(SELECT a.startdate AS asd, a.enddate AS aed, b.startdate AS bsd, b.enddate AS bed
FROM timeperiods a
LEFT JOIN timeperiods b 
ON a.enddate >= b.startdate
AND a.enddate < b.enddate), 
distinctstartdates AS -- getting the start dates to then join the end dates with
(SELECT DISTINCT startdate
FROM timeperiods
ORDER BY startdate),
validenddates AS -- getting the valid end dates 
(SELECT a.aed
FROM defining a
WHERE a.bsd IS NULL),
startwithend AS -- joining dist start dates with the minimum enddate for each start date and grouping by start date 
(SELECT a.startdate, MIN(b.aed) AS enddate
FROM distinctstartdates a 
JOIN validenddates b
ON a.startdate < b.aed
GROUP BY a.startdate)
SELECT MIN(a.startdate) AS startdate, enddate -- getting the minimum start date with the appropriate end date and grouping by enddate
FROM startwithend AS a
GROUP BY a.enddate;

-- PUZZLE 20:
SELECT productid, TO_CHAR(effectivedate, 'mm/dd/YYYY'), unitprice
FROM
(SELECT productid, effectivedate, unitprice,
ROW_NUMBER() OVER(PARTITION BY productid ORDER BY effectivedate DESC) rnk
FROM ValidPrices)
WHERE rnk = 1
ORDER BY productid;

--PUZZLE 21: 
SELECT x.state
FROM 
(SELECT customerid, EXTRACT(MONTH FROM orderdate), state, ROUND(AVG(CAST(Amount AS NUMERIC)),2) AS avg_monthly
FROM Orders
GROUP BY customerid, EXTRACT(MONTH FROM orderdate), state) x
GROUP BY state
HAVING MIN(avg_monthly) >= 100;

-- PUZZLE 22: 
SELECT (SELECT workflow 
		FROM Processlog p1
		WHERE p1.occurrences = MAX(p2.occurrences)) AS workflow, p2.logmessage,MAX(p2.occurrences) 
FROM Processlog p2
GROUP BY p2.logmessage
ORDER BY p2.logmessage;

-- (another way)
SELECT p1.workflow, p2.logmessage, p2.occ
FROM Processlog p1
JOIN 
(SELECT logmessage, MAX(occurrences) AS occ 
FROM Processlog
GROUP BY logmessage) p2 
ON p1.occurrences = p2.occ
ORDER BY p2.logmessage;

-- PUZZLE 23: 
SELECT CASE WHEN perc >= 0.5 THEN 1 ELSE 2 END AS Quartile, playerid, score
FROM
(SELECT *, PERCENT_RANK() OVER(ORDER BY score) AS perc
FROM PlayerScores)
ORDER BY Quartile, playerid;


-- PUZZLE 24: 
SELECT *
FROM Orders
WHERE orderid BETWEEN 5 and 9
ORDER BY orderid;

--  OFFSET FETCH Version  
SELECT  OrderID, CustomerID, OrderDate, Amount, State
FROM    Orders
ORDER BY OrderID
OFFSET 4 ROWS 
FETCH NEXT 5 ROWS ONLY;

-- OFFSET LIMIT Version 
SELECT  OrderID, CustomerID, OrderDate, Amount, State
FROM    Orders
ORDER BY OrderID
OFFSET 4  
LIMIT 5;

-- cool random number variation 
SELECT *
FROM Orders
ORDER BY random()
OFFSET floor(random() * (SELECT COUNT(*) FROM Orders))
FETCH NEXT 5 ROWS ONLY;

																		
-- PUZZLE 25: 
SELECT b.customerid, a.vendor
FROM Orders a
JOIN
(SELECT customerid, MAX(Count) maxx
FROM Orders
GROUP BY customerid) b
ON b.customerid = a.customerid
AND a.count = b.maxx; 

-- PUZZLE 26
SELECT  CAST(MAX(CASE WHEN year = 2023 THEN summ END) AS MONEY) AS "2023",
        CAST(MAX(CASE WHEN year = 2022 THEN summ END) AS MONEY) AS "2022",
        CAST(MAX(CASE WHEN year = 2021 THEN summ END) AS MONEY) AS "2021"
FROM
(SELECT DISTINCT year, summ
FROM
(SELECT *, SUM(amount) OVER(PARTITION BY year ORDER BY amount DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS summ
FROM Sales)
ORDER BY year);

-- PUZZLE 27 
-- adding id column to be able to effectively delete duplicates 
ALTER TABLE Sampledata
ADD COLUMN id SERIAL PRIMARY KEY;

-- finding duplicates 
SELECT integervalue, COUNT(integervalue)
FROM Sampledata
GROUP BY integervalue
HAVING COUNT(integervalue) > 1;

-- delete duplicates 
DELETE FROM Sampledata
WHERE id IN (
SELECT MAX(id) 
FROM Sampledata
WHERE integervalue IN
(SELECT integervalue
FROM Sampledata
GROUP BY integervalue
HAVING COUNT(integervalue) > 1)
GROUP BY integervalue);

-- drop id column 
ALTER TABLE Sampledata
DROP COLUMN id;

-- expected output 
SELECT *
FROM Sampledata;
																
-- PUZZLE 28: 
WITH cte AS
(SELECT RowNumber, TestCase, COUNT(TestCase) OVER (ORDER BY rownumber) AS Count
FROM Gaps)
SELECT RowNumber, MAX(TestCase) OVER (PARTITION BY Count) AS TestCase
FROM cte
ORDER BY RowNumber;

-- PUZZLE 29:  
SELECT s.status, ss.status 
FROM Groupings s
JOIN Groupings ss
ON s.stepnumber + 1 = ss.stepnumber 
AND s.status = ss.status;

-- PUZZLE 32: 
WITH rnk AS 
(SELECT jobdescription,spacemanid,missioncount, 
RANK() OVER (PARTITION BY jobdescription ORDER BY missioncount ASC) AS min_rank,
RANK() OVER (PARTITION BY jobdescription ORDER BY missioncount DESC) AS max_rank
FROM Personal)
SELECT jobdescription,
MAX(CASE WHEN max_rank = 1 THEN spacemanid END) AS Most_experienced,																	
MAX(CASE WHEN min_rank = 1 THEN spacemanid END) AS Least_experienced
FROM rnk
GROUP BY jobdescription
ORDER BY jobdescription;
																		
-- PUZZLE 33:
WITH fulfillment AS																		
(SELECT o.orderid, o.product, o.daystodeliver, mf.component, mf.daystomanufacture, 
SUM(CASE WHEN daystodeliver >= daystomanufacture THEN 1 ELSE 0 END) OVER (PARTITION BY orderid) AS components_on_time,
COUNT(o.orderid) OVER (PARTITION BY orderid) AS total_parts																		
FROM Orders o 
JOIN Manufacturingtimes mf
ON o.product = mf.product)
SELECT DISTINCT orderid, product																		
FROM fulfillment
WHERE total_parts = components_on_time;	
																		
--Puzzle 34: 
SELECT *
FROM Orders
WHERE CASE WHEN customerid = 1001 AND Amount = '$50' THEN 0 ELSE 1 END = 1;	

--Puzzle 35: 
SELECT salesrepid																
FROM Orders	
GROUP BY salesrepid
HAVING COUNT(DISTINCT salestype) < 2;																			
																		
-- Puzzle 36: 																		
-- find all possible routes 
																		
-- PUZZLE 37
SELECT DENSE_RANK() OVER (ORDER BY distributor, facility), *																		
FROM Groupcriteria;																	

-- PUZZLE 38: 																																
WITH drall  AS 
(SELECT DISTINCT r.distributor, n.region 
FROM RegionSales r
CROSS JOIN																		
(SELECT DISTINCT region
FROM RegionSales) n )																		
SELECT d.region,d.distributor, COALESCE(s.sales,0) AS sales
FROM drall d
LEFT JOIN regionsales s															
ON 	d.distributor = s.distributor 																	
AND d.region = s.region
 ORDER BY distributor, CASE
    WHEN d.region = 'North' THEN 1
    WHEN d.region = 'South' THEN 2
    WHEN d.region = 'East' THEN 3
    WHEN d.region = 'West' THEN 4 END; 	

-- PUZZLE 39:
																	
-- PUZZLE 41: 
WITH RECURSIVE cte AS
(SELECT associate1, associate2
FROM associates
UNION
SELECT a.associate1, b.associate2
FROM associates a 
JOIN cte b
ON a.associate2 = b.associate1)
SELECT associate1, associate2
INTO associates2
FROM cte
UNION
SELECT associate1, associate1
FROM associates;

SELECT MIN(associate1) AS associate1, associate2
INTO associates3
FROM associates2
GROUP BY associate2;

SELECT DENSE_RANK() OVER (ORDER BY associate1) AS grouping_number, associate2 AS associate
FROM associates3;																		

																		
-- goal: calculate the number of mutual friends  																																				
-- need to somehow count the number of friends they both share with eachother 
SELECT * 																		
FROM friends;
																		
WITH RECURSIVE friends3 AS
(SELECT friend1, friend2 																		
FROM friends 																		
UNION 																		
SELECT 																		
from friends 	
JOIN 
 
SELECT *
INTO friends2
FROM 
(SELECT friend1, friend2
FROM friends 
UNION  
SELECT friend2, friend1
FROM friends)
 ORDER BY friend1;
 
 SELECT * 
FROM friends2 f
 JOIN friends2 ff
 ON f.friend2 = ff.friend1
AND f.friend1 <> ff.friend2 ;
AND f.friend1 = ff.friend2
 AND f.friend2 <> f.friend1;
 

SELECT * 
FROM brands;


 
 
 
 
 
 