/*---------------------------------------------------------------------
	บทที่ 08
	
	แบบฝึกหัดที่ 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	o.orderid
,	o.orderdate
,	SUM(d.qty * d.unitprice*(1-d.discount)) AS salesamount
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.orderid, o.orderdate
ORDER BY salesamount DESC;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	o.orderid
,	o.orderdate
, 	SUM(d.qty * d.unitprice*(1-d.discount)) AS salesamount
,	COUNT(*) AS noofoderlines
,	AVG(d.qty * d.unitprice*(1-d.discount)) AS avgsalesamountperorderline
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY o.orderid, o.orderdate
ORDER BY salesamount DESC;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/
SELECT
	YEAR(orderdate) * 100 + MONTH(orderdate) AS yearmonthno, 
	SUM(d.qty * d.unitprice*(1-d.discount)) AS saleamountpermonth
FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
ON d.orderid = o.orderid
GROUP BY YEAR(orderdate), MONTH(orderdate)
ORDER BY yearmonthno;

/*---------------------------------------------------------------------
	งานที่ 4
---------------------------------------------------------------------*/

SELECT 
	c.custid
,	c.contactname
,	SUM(d.qty * d.unitprice*(1-d.discount)) AS totalsalesamount
,	MAX(d.qty * d.unitprice*(1-d.discount)) AS maxsalesamountperorderline
,	COUNT(*) AS numberofrows
,	COUNT(o.orderid) AS numberoforderlines
FROM Sales.Customers AS c
LEFT OUTER JOIN Sales.Orders AS o ON o.custid = c.custid
LEFT OUTER JOIN Sales.OrderDetails AS d ON d.orderid = o.orderid
GROUP BY c.custid, c.contactname
ORDER BY totalsalesamount;



