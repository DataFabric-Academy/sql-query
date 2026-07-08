/*---------------------------------------------------------------------
	บทที่ 09
	
	แบบฝึกหัด 1
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT MAX(orderdate) AS lastorderdate 
FROM Sales.Orders;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	orderid
,	orderdate
,	empid
,	custid
FROM Sales.Orders
WHERE orderdate		= 
					(
					SELECT 
					MAX(orderdate) 
					FROM Sales.Orders
					);

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT
	orderid
,	orderdate
,	empid
,	custid
FROM Sales.Orders
WHERE custid	= 
				(
					SELECT custid
					FROM Sales.Customers
					WHERE contactname LIKE N'I%'
				);

-- error
SELECT
	orderid
,	orderdate
,	empid
,	custid
FROM Sales.Orders
WHERE custid	= 
				(
					SELECT custid
					FROM Sales.Customers
					WHERE contactname LIKE N'B%'
				);

-- fixed
SELECT
	orderid
,	orderdate
,	empid
,	custid
FROM Sales.Orders
WHERE custid	IN 
				(
					SELECT custid
					FROM Sales.Customers
					WHERE contactname LIKE N'B%'
				);

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	o.orderid
,	SUM(d.qty * d.unitprice*(1-d.discount)) AS totalsalesamount
,	SUM(d.qty * d.unitprice*(1-d.discount))	/
											(
												SELECT SUM(d.qty * d.unitprice*(1-d.discount)) 
												FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
												ON d.orderid = o.orderid
												WHERE o.orderdate >= '20080501' AND o.orderdate < '20080601'
											) * 100.00 AS salespctoftotal
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
WHERE o.orderdate >= '20080501' AND o.orderdate < '20080601'
GROUP BY o.orderid;




