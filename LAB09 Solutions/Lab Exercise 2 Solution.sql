/*---------------------------------------------------------------------
	บทที่ 10
	
	แบบฝึกหัด 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	custid
,	SUM(val) AS totalsalesamount
FROM Sales.OrderValues
WHERE YEAR(orderdate) = 2007
GROUP BY custid;

GO

CREATE FUNCTION dbo.fnGetSalesByCustomer (@orderyear AS INT) RETURNS TABLE
AS
RETURN
	SELECT
		custid
	,	SUM(val) AS totalsalesamount
	FROM Sales.OrderValues
	WHERE YEAR(orderdate) = @orderyear
	GROUP BY custid;

GO


/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	custid
,	totalsalesamount
FROM dbo.fnGetSalesByCustomer(2007);

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT TOP(3)
	p.productid
,	p.productname
,	SUM(d.qty * d.unitprice*(1-d.discount)) AS totalsalesamount	
FROM Sales.Orders AS o
INNER JOIN Sales.OrderDetails AS d ON d.orderid = o.orderid
INNER JOIN Production.Products AS p ON p.productid = d.productid
WHERE custid = 1
GROUP BY p.productid,p.productname
ORDER BY totalsalesamount DESC;
GO

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer
(@custid AS INT) RETURNS TABLE
AS
RETURN
SELECT TOP(3)
	d.productid, 
	MAX(p.productname) AS productname, 
	SUM(d.qty * d.unitprice*(1-d.discount)) AS totalsalesamount	
FROM Sales.Orders AS o
INNER JOIN Sales.OrderDetails AS d ON d.orderid = o.orderid
INNER JOIN Production.Products AS p ON p.productid = d.productid
WHERE custid = @custid
GROUP BY d.productid
ORDER BY totalsalesamount DESC;

GO



/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT 
	p.productid,
	p.productname,
	p.totalsalesamount
FROM dbo.fnGetTop3ProductsForCustomer(20) AS p;

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

IF OBJECT_ID('dbo.fnGetSalesByCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetSalesByCustomer;

IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer;
GO


