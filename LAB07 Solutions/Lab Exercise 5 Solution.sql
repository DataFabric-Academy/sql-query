/*---------------------------------------------------------------------
	บทที่ 13
	
	แบบฝึกหัด 1
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	country
,	city
,	COUNT(custid) AS noofcustomers
FROM Sales.Customers
GROUP BY 
GROUPING SETS 
			(
				(country, city)
			,	(country)
			,	(city)
			,	()
			);

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	YEAR(orderdate) AS orderyear
,	MONTH(orderdate) AS ordermonth
,	DAY(orderdate) AS orderday
,	SUM(val) AS salesvalue
FROM Sales.OrderValues
GROUP BY
CUBE (YEAR(orderdate), MONTH(orderdate), DAY(orderdate));


/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT
	YEAR(orderdate) AS orderyear
,	MONTH(orderdate) AS ordermonth
,	DAY(orderdate) AS orderday
,	SUM(val) AS salesvalue
FROM Sales.OrderValues
GROUP BY
ROLLUP (YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT
	GROUPING_ID(YEAR(orderdate), MONTH(orderdate)) as groupid
,	YEAR(orderdate) AS orderyear
,	MONTH(orderdate) AS ordermonth
,	SUM(val) AS salesvalue
FROM Sales.OrderValues
GROUP BY
ROLLUP (YEAR(orderdate), MONTH(orderdate))
ORDER BY groupid, orderyear, ordermonth;












