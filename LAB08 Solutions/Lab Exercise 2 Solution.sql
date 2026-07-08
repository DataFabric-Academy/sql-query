/*---------------------------------------------------------------------
	บทที่ 09
	
	แบบฝึกหัด 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	productid
,	productname
FROM Production.Products
WHERE productid	IN 
				(
				SELECT productid
				FROM Sales.OrderDetails
				WHERE qty > 100
				);

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				);


/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/


INSERT INTO Sales.Orders 
(custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, 
shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
VALUES
(NULL, 1, '20111231', '20111231', '20111231', 1, 0, 
'ShipOne', 'ShipAddress', 'ShipCity', 'RA', '1000', 'USA');

GO


-- NULL issue
SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				);

-- excplicit NULL check

SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				WHERE custid IS NOT NULL
				);



