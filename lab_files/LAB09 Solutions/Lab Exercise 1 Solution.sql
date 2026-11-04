/*---------------------------------------------------------------------
	บทที่ 10
	
	แบบฝึกหัด 1
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
	productid
,	productname
,	supplierid
,	unitprice
,	discontinued
FROM Production.Products
WHERE categoryid = 1;

GO

CREATE VIEW Production.ProductsBeverages_XX 
AS
	SELECT
		productid
	,	productname
	,	supplierid
	,	unitprice
	,	discontinued
	FROM Production.Products
	WHERE categoryid = 1;
	
GO

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT	
	productid
,	productname
FROM Production.ProductsBeverages_XX
WHERE supplierid = 1;

GO
/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

ALTER VIEW Production.ProductsBeverages_XX 
AS
	SELECT
		productid
	,	productname
	,	supplierid
	,	unitprice
	,	discontinued
	FROM Production.Products
	WHERE categoryid = 1
	ORDER BY productname;

GO

ALTER VIEW Production.ProductsBeverages_XX 
AS
	SELECT TOP(100) PERCENT
		productid
	,	productname
	,	supplierid
	,	unitprice
	,	discontinued
	FROM Production.Products
	WHERE categoryid = 1
	ORDER BY productname;

GO
/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

ALTER VIEW Production.ProductsBeverages_XX 
AS
	SELECT
		productid
	,	productname
	,	supplierid
	,	unitprice
	,	discontinued
	,	CASE 
			WHEN unitprice > 100. THEN N'high' 
			ELSE N'normal' 
		END
	FROM Production.Products
	WHERE categoryid = 1;

GO

ALTER VIEW Production.ProductsBeverages_XX 
AS
	SELECT
		productid
	,	productname
	,	supplierid
	,	unitprice
	,	discontinued
	,	CASE 
			WHEN unitprice > 100. THEN N'high' 
			ELSE N'normal' 
		END AS pricetype
	FROM Production.Products
	WHERE categoryid = 1;

GO

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

IF OBJECT_ID(N'Production.ProductsBeverages_XX', N'V') IS NOT NULL
	DROP VIEW Production.ProductsBeverages_XX;
