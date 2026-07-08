/*---------------------------------------------------------------------
	บทที่ 06
	
	แบบฝึกหัดที่ 2
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	c.custid
,	c.contactname
,	o.orderid
,	o.orderdate
FROM Sales.Customers AS c INNER JOIN Sales.Orders AS o 
ON c.custid = o.custid 
WHERE o.orderdate >= 'April, 1 2008'
ORDER BY o.orderdate DESC, c.custid ASC;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	e.empid
,	e.lastname
,	e.firstname
,	e.title
,	e.mgrid
,	m.lastname AS mgrlastname
,	m.firstname AS mgrfirstname
FROM HR.Employees AS e INNER JOIN HR.Employees AS m 
ON e.mgrid = m.empid
WHERE m.lastname = N'Buck';

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

--3a
SELECT
	e.empid
,	e.lastname
,	e.firstname
,	e.title
,	e.mgrid
,	m.lastname AS mgrlastname
,	m.firstname AS mgrfirstname
FROM HR.Employees AS e INNER JOIN HR.Employees AS m 
ON e.mgrid = m.empid
ORDER BY m.firstname;

--3b
SELECT
	e.empid
,	e.lastname
,	e.firstname
,	e.title
,	e.mgrid
,	m.lastname AS mgrlastname
,	m.firstname AS mgrfirstname
FROM HR.Employees AS e INNER JOIN HR.Employees AS m 
ON e.mgrid = m.empid
ORDER BY mgrfirstname;

