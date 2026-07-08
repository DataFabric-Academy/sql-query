/*---------------------------------------------------------------------
	บทที่ 09
	
	แบบฝึกหัด 3
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	c.custid
,	c.contactname
,	(
	SELECT MAX(o.orderdate) 
	FROM Sales.Orders AS o 
	WHERE o.custid = c.custid
	) AS lastorderdate
FROM Sales.Customers AS c;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	c.custid
,	c.contactname
FROM Sales.Customers AS c
WHERE NOT EXISTS 
			(
			SELECT * 
			FROM Sales.Orders AS o 
			WHERE o.custid = c.custid
			);

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	c.custid
,	c.contactname
FROM Sales.Customers AS c
WHERE 
	EXISTS	(
			SELECT * 
			FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
			ON d.orderid = o.orderid
			WHERE		o.custid = c.custid
					AND d.unitprice > 100.00
					AND o.orderdate >= '20080401' 
		);

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	YEAR(o.orderdate) as orderyear
,	SUM(d.qty * d.unitprice*(1-d.discount)) AS totalsales
,	(
	SELECT SUM(d2.qty * d2.unitprice*(1-d2.discount))
	FROM Sales.Orders AS o2	INNER JOIN Sales.OrderDetails AS d2 
	ON d2.orderid = o2.orderid
	WHERE YEAR(o2.orderdate) <= YEAR(o.orderdate)
	) AS runsales
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY YEAR(o.orderdate)
ORDER BY orderyear;


/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

DELETE Sales.Orders
WHERE custid IS NULL;


