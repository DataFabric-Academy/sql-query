/*---------------------------------------------------------------------
	บทที่ 10
	
	แบบฝึกหัดที่ 2
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
	
	เขียนคำสั่ง SELECT เพื่อสืบค้นยอดสั่งซื้อของลูกค้าแต่ละรายในปี 2025 จากวิวชื่อ Sales.OrderValues
	โดยแสดงคอลัมน์ต่อไปนี้
	
		-	custid 
		-	totalsalesamount หาผลรวมจากคอลัมน์ val
		
	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 2 - Task 1 Result.txt 
	
	สร้าง inline-TVF โดยนำเอาคำสั่ง SELECT ที่เขียนก่อนหน้าใส่ลงในโค๊ดที่เตียมไว้ข้างล่าง โดยใส่
	หลังประโยค RETURN จากนั้นนำพารามิเตอร์ @orderyear ไปใส่แทนปี 2025 
	
	สั่งรันคำสั่งที่เขียนเสร็จเพื่อสร้าง inline-TVF ชื่อ dbo.fnGetSalesByCustomer_XX
---------------------------------------------------------------------*/

-- initial SQL statement

CREATE FUNCTION dbo.fnGetSalesByCustomer_XX
(@orderyear AS INT) RETURNS TABLE
AS
RETURN
-- copy here the SQL statement


GO


/*---------------------------------------------------------------------
	งานที่ 2
	
	เขียนคำสั่ง SELECT เพื่อแสดง custid และ totalsalesamount จาก TVF ชื่อ
	dbo.fnGetSalesByCustomer_XX โดยใช้ 2025 เป็นค่าพารามิเตอร์	

	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 2 - Task 2 Result.txt
---------------------------------------------------------------------*/


/*---------------------------------------------------------------------
	งานที่ 3
	
	เขียนคำสั่ง SELECT เพื่อสืบค้นรายการสินค้าที่ขายให้กับลูกค้าที่มี custid เท่ากับ 1 สูงสุด 
	3 อันดับแรก โดยแสดงคอลัมน์
		- productid
		- productname
		- totalsalesamount ได้จากคอลัมน์ qty, unitprice และ discount 
		  ในตาราง Sales.OrderDetails

	
	สั่งรันคำสั่ง  T-SQL เทียบผลลัพธ์ ที่ได้กับไฟล์ Lab Exercise 2 - Task 3 Result.txt
	
	สร้าง inline-TVF โดยนำเอาคำสั่ง SELECT ที่เขียนก่อนหน้าใส่ลงในโค๊ดที่เตียมไว้ข้างล่าง โดยใส่
	หลังประโยค RETURN จากนั้นนำพารามิเตอร์ @custid ไปใส่แทน 1 (custid)
	
	สั่งรันคำสั่งที่เขียนเสร็จเพื่อสร้าง inline-TVF ชื่อ dbo.fnGetTop3ProductsForCustomer_XX
	
---------------------------------------------------------------------*/

-- initial SQL statement

GO

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer_XX
(@custid AS INT) RETURNS TABLE
AS
RETURN
-- copy here the SQL statement


GO

-- write here the SQL statement against the created function


/*---------------------------------------------------------------------
	งานที่ 4
	
	เขียนคำสั่ง SELECT เพื่อแสดง productid , productname และ totalsalesamount 
	จาก TVF ชื่อ dbo.fnGetTop3ProductsForCustomer_XX โดยใช้ 20 เป็นค่าพารามิเตอร์	

	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 2 - Task 2 Result.txt

---------------------------------------------------------------------*/



/*---------------------------------------------------------------------
	งานที่ 5
	
	ลบ inline table-valued functions ที่สร้างขึ้นทิ้ง
---------------------------------------------------------------------*/

IF OBJECT_ID('dbo.fnGetSalesByCustomer_XX') IS NOT NULL
	DROP FUNCTION dbo.fnGetSalesByCustomer_XX;

IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer_XX') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer_XX;
GO


