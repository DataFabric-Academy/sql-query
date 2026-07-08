/*---------------------------------------------------------------------
	บทที่ 04
	
	แบบฝึกหัดที่ 3
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	e.empid
,	e.lastname
,	e.firstname
,	e.title
,	e.mgrid
FROM HR.Employees AS e;

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
ON e.mgrid = m.empid;



