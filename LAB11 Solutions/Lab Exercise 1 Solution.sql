/*---------------------------------------------------------------------
	บทที่ 12
	
	แบบฝึกหัด 1
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT 
	orderid
,	orderdate
,	val
,	ROW_NUMBER() OVER (ORDER BY orderdate) AS rowno
FROM Sales.OrderValues;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	orderid
,	orderdate
,	val
,	ROW_NUMBER() OVER (ORDER BY orderdate) AS rowno
,	RANK() OVER (ORDER BY orderdate) AS rankno
FROM Sales.OrderValues;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

SELECT 
	orderid
,	orderdate
,	custid
,	val
,	RANK() OVER (PARTITION BY custid ORDER BY val DESC) AS orderrankno
FROM Sales.OrderValues;

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT 
	custid
,	YEAR(orderdate) as orderyear
,	val
,	DENSE_RANK() OVER (PARTITION BY custid, YEAR(orderdate) ORDER BY val DESC) AS orderrankno
FROM Sales.OrderValues;

/*---------------------------------------------------------------------
	งานที่ 5
---------------------------------------------------------------------*/

SELECT
	s.custid,
	s.orderyear,
	s.orderrankno,
	s.val
FROM
(
	SELECT 
		custid
	,	YEAR(orderdate) as orderyear
	,	val
	,	DENSE_RANK() OVER (PARTITION BY custid, YEAR(orderdate) ORDER BY val DESC) AS orderrankno
	FROM Sales.OrderValues
) AS s
WHERE s.orderrankno <= 2;

