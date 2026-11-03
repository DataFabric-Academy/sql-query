/*---------------------------------------------------------------------
	บทที่ 11
	
	แบบฝึกหัด 3
---------------------------------------------------------------------*/

/*---------------------------------------------------------------------
	หมายเหตุสำหรับผู้เรียน (server ใช้ร่วมกัน)
	
	object ที่แบบฝึกหัดนี้สร้าง มีชื่อลงท้ายด้วย _XX ให้แทน XX ด้วยเลขประจำตัวของคุณ
	ก่อนรันทุกครั้ง เช่น _XX -> _07 เพื่อไม่ให้ชนกับ object ของผู้เรียนท่านอื่น
	ที่ใช้ database TSQL เดียวกัน (object จะถูกลบด้วยคำสั่งท้ายแบบฝึกหัด)
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	p.productid
,	p.productname
,	o.orderid
FROM Production.Products AS p
CROSS APPLY 
	(
	SELECT TOP(2)
		d.orderid	
	FROM Sales.OrderDetails AS d
	WHERE d.productid = p.productid
	ORDER BY d.orderid DESC
	) o
ORDER BY p.productid;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/
IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer_XX') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer_XX;

GO

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer_XX (@custid AS INT) RETURNS TABLE
AS
RETURN
	SELECT TOP(3)
		p.productid
	,	productname
	,	SUM(d.qty * d.unitprice * (1-d.discount)) AS totalsalesamount	
	FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
	ON d.orderid = o.orderid
	INNER JOIN Production.Products AS p 
	ON p.productid = d.productid
	WHERE custid = @custid
	GROUP BY p.productid,p.productname
	ORDER BY totalsalesamount DESC;

GO

SELECT
	c.custid
,	c.contactname
,	p.productid
,	p.productname
,	p.totalsalesamount
FROM Sales.Customers AS c
CROSS APPLY dbo.fnGetTop3ProductsForCustomer_XX (c.custid) AS p
ORDER BY c.custid;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT
	c.custid
,	c.contactname
,	p.productid
,	p.productname
,	p.totalsalesamount
FROM Sales.Customers AS c
OUTER APPLY dbo.fnGetTop3ProductsForCustomer_XX (c.custid) AS p
ORDER BY c.custid;


/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	c.custid
,	c.contactname
,	p.productid
,	p.productname
,	p.totalsalesamount
FROM Sales.Customers AS c
OUTER APPLY dbo.fnGetTop3ProductsForCustomer_XX (c.custid) AS p
WHERE p.productid IS NULL;

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer_XX') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer_XX;