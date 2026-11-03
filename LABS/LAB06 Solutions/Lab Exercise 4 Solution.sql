/*---------------------------------------------------------------------
	บทที่ 06
	
	แบบฝึกหัดที่ 4
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	contactname
,	SUBSTRING(contactname, 0, CHARINDEX(N',', contactname)) AS lastname
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	REPLACE(contactname, ',', '') AS newcontactname
,	SUBSTRING(contactname, CHARINDEX(N',', contactname)+1, LEN(contactname)-CHARINDEX(N',', contactname)+1) AS firstname
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	custid,
	N'C' + RIGHT(REPLICATE('0', 5) + CAST(custid AS VARCHAR(5)), 5) AS custnewid
FROM Sales.Customers;

-- ใช้ FORMAT แทน
SELECT
	custid,
	FORMAT(custid, N'\C00000') AS custnewid
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	contactname
,	LEN(contactname) - LEN(REPLACE(contactname, 'a', '')) AS numberofa
FROM Sales.Customers
ORDER BY numberofa DESC;

