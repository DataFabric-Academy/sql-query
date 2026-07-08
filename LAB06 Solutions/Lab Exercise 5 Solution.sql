/*---------------------------------------------------------------------
	บทที่ 07
	
	แบบฝึกหัดที่ 1
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT N'The unit price for the ' + productname + N' is ' + CAST(unitprice AS NVARCHAR(10)) + N' $.' AS productdesc
FROM Production.Products;


/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	orderid
,	orderdate
,	shippeddate
,	COALESCE(shipregion, 'No region') AS shipregion
FROM Sales.Orders 
WHERE 
		orderdate >= CONVERT(DATETIME, '1/4/2007', 103) 
	AND orderdate <= CONVERT(DATETIME, '30/11/2007', 103)
	AND shippeddate > DATEADD(DAY, 30, orderdate);


SELECT 
	orderid
,	orderdate
,	shippeddate
,	COALESCE(shipregion, 'No region') AS shipregion
FROM Sales.Orders 
WHERE 
		orderdate >= PARSE('1/4/2007' AS DATETIME USING 'en-GB')
	AND orderdate <= PARSE('30/11/2007' AS DATETIME USING 'en-GB')
	AND shippeddate > DATEADD(DAY, 30, orderdate);

--ใช้ Thai Culture
SELECT 
	orderid
,	orderdate
,	shippeddate
,	COALESCE(shipregion, 'No region') AS shipregion
FROM Sales.Orders 
WHERE 
		orderdate >= PARSE('1/4/2550' AS DATETIME USING 'th-TH')
	AND orderdate <= PARSE('30/11/2550' AS DATETIME USING 'th-TH')
	AND shippeddate > DATEADD(DAY, 30, orderdate);

--ใช้แบบ Neutral
SELECT 
	orderid
,	orderdate
,	shippeddate
,	COALESCE(shipregion, 'No region') AS shipregion
FROM Sales.Orders 
WHERE 
		orderdate >= CONVERT(DATETIME,'1 April 2007')
	AND orderdate <= CONVERT(DATETIME,'30 November 2007')
	AND shippeddate > DATEADD(DAY, 30, orderdate);

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

-- error
SELECT 
	CONVERT(INT, REPLACE(REPLACE(REPLACE(REPLACE(phone, N'-', N''), N'(', ''), N')', ''), ' ', '')) AS phonenoasint
FROM Sales.Customers;


SELECT phone,
	TRY_CONVERT(INT, REPLACE(REPLACE(REPLACE(REPLACE(phone, N'-', N''), N'(', ''), N')', ''), ' ', '')) AS phonenoasint
FROM Sales.Customers;


