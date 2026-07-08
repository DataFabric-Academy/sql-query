/*---------------------------------------------------------------------
	บทที่ 13
	
	แบบฝึกหัด 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

WITH OrderRows AS
(
	SELECT 
		orderid
	,	orderdate
	,	val
	,	ROW_NUMBER() OVER (ORDER BY orderdate, orderid) AS rowno
	FROM Sales.OrderValues
)
SELECT 
	co.orderid
,	co.orderdate
,	co.val as curval
,	po.val as prevval
,	co.val - po.val as diffprev
FROM OrderRows AS co LEFT OUTER JOIN OrderRows AS po 
ON co.rowno - 1 = po.rowno;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	orderid
,	orderdate
,	val as curval
,	LAG(val,1) OVER (ORDER BY orderdate, orderid) AS prevval
,	val - LAG(val) OVER (ORDER BY orderdate, orderid) AS diffprev
FROM Sales.OrderValues;



/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/
WITH SalesMonth2007 AS
(
	SELECT
		MONTH(orderdate) AS monthno
	,	SUM(val) AS val
	FROM Sales.OrderValues
	WHERE orderdate >= '20070101' AND orderdate < '20080101'
	GROUP BY MONTH(orderdate)
)
SELECT
	monthno
,	val
,	(LAG(val, 1, 0) OVER (ORDER BY monthno) + LAG(val, 2, 0) OVER (ORDER BY monthno) + LAG(val, 3, 0) OVER (ORDER BY monthno)) / 3 AS avglast3months
,	val - FIRST_VALUE(val) OVER (ORDER BY monthno ROWS UNBOUNDED PRECEDING) AS diffjanuary
,	LEAD(val) OVER (ORDER BY monthno) AS nextval
FROM SalesMonth2007;


