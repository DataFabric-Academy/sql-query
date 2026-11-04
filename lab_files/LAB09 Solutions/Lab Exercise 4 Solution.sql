/*---------------------------------------------------------------------
	บทที่ 10
	
	แบบฝึกหัด 4
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

WITH ProductsBeverages AS
(
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
	WHERE categoryid = 1
)

SELECT
	productid
,	productname
FROM ProductsBeverages
WHERE pricetype = N'high';

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

WITH c2026 (custid, salesamt2026) AS
(
	SELECT
		custid
	,	SUM(val)
	FROM Sales.OrderValues
	WHERE YEAR(orderdate) = 2026
	GROUP BY custid
)

SELECT
	c.custid
,	c.contactname
,	c2026.salesamt2026
FROM Sales.Customers AS c LEFT OUTER JOIN c2026 
ON c.custid = c2026.custid;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

WITH c2026 (custid, salesamt2026) AS
(
	SELECT
		custid
	,	SUM(val)
	FROM Sales.OrderValues
	WHERE YEAR(orderdate) = 2026
	GROUP BY custid
),
c2025 (custid, salesamt2025) AS
(
	SELECT
		custid
	,	SUM(val)
	FROM Sales.OrderValues
	WHERE YEAR(orderdate) = 2025
	GROUP BY custid
)
SELECT
	c.custid
,	c.contactname
,	c2026.salesamt2026
,	c2025.salesamt2025
,	COALESCE((c2026.salesamt2026 - c2025.salesamt2025) / c2025.salesamt2025 * 100., 0) AS percentgrowth
FROM Sales.Customers AS c LEFT OUTER JOIN c2026 
ON c.custid = c2026.custid
LEFT OUTER JOIN c2025 
ON c.custid = c2025.custid
ORDER BY percentgrowth DESC;

