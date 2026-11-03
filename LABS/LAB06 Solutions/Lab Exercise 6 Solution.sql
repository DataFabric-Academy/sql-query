/*---------------------------------------------------------------------
	บทที่ 07
	
	แบบฝึกหัดที่ 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	custid
,	contactname
,	IIF(country = N'Mexico' AND contacttitle = N'Owner', N'Target group', N'Other') AS segmentgroup
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	custid
,	contactname
,	IIF(contacttitle = N'Owner' OR region IS NOT NULL, N'Target group', N'Other') AS segmentgroup
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT
	custid
,	contactname
,	CHOOSE(custid % 4 + 1, N'Group One', N'Group Two', N'Group Three', N'Group Four') AS segmentgroup
FROM Sales.Customers;


