/*---------------------------------------------------------------------
	บทที่ 06
	
	แบบฝึกหัดที่ 1
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	custid
,	companyname
,	contactname
,	address
,	city
,	country
,	phone
FROM Sales.Customers
WHERE country = N'Brazil';

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	custid
,	companyname
,	contactname
,	address
,	city
,	country
,	phone
FROM Sales.Customers
WHERE country IN (N'Brazil', N'UK', N'USA');

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT
	custid
,	companyname
,	contactname
,	address
,	city
,	country
,	phone
FROM Sales.Customers
WHERE contactname LIKE N'A%';

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

--4a
SELECT
	c.custid
,	c.companyname
,	o.orderid
FROM Sales.Customers AS c LEFT OUTER JOIN Sales.Orders AS o 
ON c.custid = o.custid AND c.city = N'Paris';

--4b
SELECT
	c.custid
,	c.companyname
,	o.orderid
FROM Sales.Customers AS c LEFT OUTER JOIN Sales.Orders AS o 
ON c.custid = o.custid 
WHERE c.city = N'Paris';

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

SELECT
	c.custid
,	c.companyname
FROM Sales.Customers AS c LEFT OUTER JOIN Sales.Orders AS o 
ON c.custid = o.custid 
WHERE o.custid IS NULL;
