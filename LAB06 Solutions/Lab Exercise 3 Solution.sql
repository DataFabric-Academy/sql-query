/*---------------------------------------------------------------------
	บทที่ 06
	
	แบบฝึกหัดที่ 3
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT 
	CONCAT(contactname, N' (city: ', city, N')') AS contactwithcity
FROM Sales.Customers;

SELECT 
	contactname + N' (city: ' + city + N')' AS contactwithcity 
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	CONCAT(contactname, N' (city: ', city,  N', region: ', region, N')') AS fullcontact
FROM Sales.Customers;

SELECT 
	contactname + N' (city: ' + city + N', region: ' + COALESCE(region, '') + N')' AS fullcontact
FROM Sales.Customers;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	contactname
,	contacttitle
FROM Sales.Customers
WHERE contactname LIKE N'[A-G]%'
ORDER BY contactname;


