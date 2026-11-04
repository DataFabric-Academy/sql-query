/*---------------------------------------------------------------------
	บทที่ 04
	
	แบบฝึกหัดที่ 5
---------------------------------------------------------------------*/

/*---------------------------------------------------------------------
	หมายเหตุสำหรับผู้เรียน (server ใช้ร่วมกัน)
	
	object ที่แบบฝึกหัดนี้สร้าง มีชื่อลงท้ายด้วย _XX ให้แทน XX ด้วยเลขประจำตัวของคุณ
	ก่อนรันทุกครั้ง เช่น _XX -> _07 เพื่อไม่ให้ชนกับ object ของผู้เรียนท่านอื่น
	ที่ใช้ database TSQL เดียวกัน (object จะถูกลบด้วยคำสั่งท้ายแบบฝึกหัด)
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SET NOCOUNT ON;

IF OBJECT_ID('HR.Calendar_XX') IS NOT NULL 
	DROP TABLE HR.Calendar_XX;

CREATE TABLE HR.Calendar_XX 
	(
		calendardate DATE CONSTRAINT PK_Calendar_XX PRIMARY KEY
	);

DECLARE 
	@startdate	DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), 1, 1)
,	@enddate	DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), 12, 31);

WHILE @startdate <= @enddate
BEGIN
	INSERT INTO HR.Calendar_XX (calendardate)
	VALUES (@startdate);

	SET @startdate = DATEADD(DAY, 1, @startdate);
END;

SET NOCOUNT OFF;

GO
-- ดูผลของตาราง HR.Calendar_XX
SELECT 
	calendardate
FROM HR.Calendar_XX;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT 
	e.empid
,	e.firstname
,	e.lastname
,	c.calendardate
FROM HR.Employees AS e CROSS JOIN HR.Calendar_XX AS c;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/

IF OBJECT_ID('HR.Calendar_XX') IS NOT NULL 
	DROP TABLE HR.Calendar_XX;
