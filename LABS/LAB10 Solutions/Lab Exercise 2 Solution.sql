/*---------------------------------------------------------------------
	LAB 11
	
	แบบฝึกหัด 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING COUNT(DISTINCT d.productid) > 20;


/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	custid
FROM Sales.Customers 
WHERE country = 'USA'

EXCEPT

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING COUNT(DISTINCT d.productid) > 20;



/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING SUM(d.qty * d.unitprice * (1-d.discount)) > 10000;

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	custid
FROM Sales.Customers 
WHERE country = 'USA'

EXCEPT

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING COUNT(DISTINCT d.productid) > 20

INTERSECT

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING SUM(d.qty * d.unitprice * (1-d.discount)) > 10000;

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/
(
SELECT
	custid
FROM Sales.Customers 
WHERE country = 'USA'

EXCEPT

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING COUNT(DISTINCT d.productid) > 20
)
INTERSECT

SELECT 
	o.custid
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.custid
HAVING SUM(d.qty * d.unitprice * (1-d.discount)) > 10000;