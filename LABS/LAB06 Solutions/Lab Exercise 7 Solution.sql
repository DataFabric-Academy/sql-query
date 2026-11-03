/*---------------------------------------------------------------------
	บทที่ 07
	
	แบบฝึกหัดที่ 3
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT 
	contactname
,	COALESCE(fax, N'No information') AS faxinformation
FROM Sales.Customers;

SELECT 
	contactname
,	ISNULL(fax, N'No information') AS faxinformation
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

DECLARE @region AS NVARCHAR(30) = NULL; 

SELECT 
	custid
,	region
FROM Sales.Customers
WHERE region = @region OR (region IS NULL AND @region IS NULL);

GO

DECLARE @region AS NVARCHAR(30) = N'WA'; 

SELECT 
	custid
,	region
FROM Sales.Customers
WHERE region = @region OR (region IS NULL AND @region IS NULL);

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	custid
,	contactname
,	city
,	region
FROM Sales.Customers 
WHERE region IS NULL OR LEN(region) <> 2;
