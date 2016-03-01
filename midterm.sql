
-- existing schema/instance could be tested
-- http://www.w3schools.com/sql/trysql.asp?filename=trysql_select_in


-- my solution
SELECT CategoryID 
From Categories 
Where CategoryID in 
(SELECT CategoryID 
FROM Products NATURAL JOIN Categories
GROUP by CategoryID
Having max(Price) < 100);

-- posted solution
SELECT CategoryID
FROM Categories
WHERE NOT EXISTS (
  SELECT * 
  FROM Products p JOIN Categories c ON c.CategoryID = p.CategoryID
  WHERE Price > 100
);


-- some helper function
select * from Products
Where CategoryID = 4
ORDER BY Price;







SELECT CategoryID
FROM Categories
WHERE EXISTS (
  SELECT *
  FROM Products p JOIN Categories c on p.CategoryID = c.CategoryID
  WHERE Price < 10
);