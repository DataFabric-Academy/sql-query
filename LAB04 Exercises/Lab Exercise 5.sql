/*---------------------------------------------------------------------
	บทที่ 04
	
	แบบฝึกหัดที่ 5
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
	
	
	สั่งรันสคริป T-SQL ข้างล่าง ไม่ต้องกังวลและอย่าเสียเวลาทำความเข้าใจโค๊ด เป็นการเตรียมตาราง
	ขึ้นมาสำหรับทดลอง Cross Join ในงานต่อไปเท่านั้น 
---------------------------------------------------------------------*/
SET NOCOUNT ON;

IF OBJECT_ID('HR.Calendar') IS NOT NULL 
	DROP TABLE HR.Calendar;

CREATE TABLE HR.Calendar 
	(
		calendardate DATE CONSTRAINT PK_Calendar PRIMARY KEY
	);

DECLARE 
	@startdate	DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), 1, 1)
,	@enddate	DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), 12, 31);

WHILE @startdate <= @enddate
BEGIN
	INSERT INTO HR.Calendar (calendardate)
	VALUES (@startdate);

	SET @startdate = DATEADD(DAY, 1, @startdate);
END;

SET NOCOUNT OFF;

GO
-- ดูผลของตาราง HR.Calendar
SELECT 
	calendardate
FROM HR.Calendar;

/*---------------------------------------------------------------------
	งานที่ 2
	
	เขียนคำสั่ง SELECT เพื่อแสดงคอลัมน์ empid, firstname และ lastname จากตาราง 
	HR.Employees และคอลัมน์ calendardate จากตาราง HR.Calendar
	
	สั่งรันคำสั่งที่เขียนเสร็จเทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 5 - Task 2 Result.txt 
	(ผลลัพธ์จะใกล้เคียงกันแต่คงไม่ตรง เพราะตาราง HR.Calendar ต่างปีกัน)

---------------------------------------------------------------------*/






/*---------------------------------------------------------------------	
	คำถาม:  จำนวนแถวข้อมูลที่ได้จากการคิวรี่ มีเท่าไหร่ ?
			หากจำนวนแถวข้อมูลของตาราง HR.Employees มี 9 แถว จำนวนแถวข้อมูลของ
			ตาราง HR.Calendar มีจำนวนเท่าไหร่ โปรดคำนวน ?
---------------------------------------------------------------------*/

/*---------------------------------------------------------------------
	งานที่ 3
	
	สั่งรันสคริป T-SQL ที่เตรียมให้ เพื่อลบตาราง HR.Calendar ทิ้ง
---------------------------------------------------------------------*/

IF OBJECT_ID('HR.Calendar') IS NOT NULL 
	DROP TABLE HR.Calendar;

