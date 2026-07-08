/*---------------------------------------------------------------------
	บทที่ 11
	
	แบบฝึกหัดที่ 3
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
	
	เขียนคำสั่ง SELECT เพื่อแสดงใบสั่งซื้อ 2 ใบล่าสุดของแต่ละสินค้า โดยประกอบด้วยคอลัมน์
	productid และ productname จากตาราง Production.Products คอลัมน์ 
	orderid จากตาราง Sales.OrderDetail
	
	ใช้ตัวดำเนินการ CROSS APPLY และคิวรี่ย่อยที่เชื่อมโยงกับคิวรี่ตัวนอก และเรียงข้อมูลตาม
	productid
	
	
	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์  Lab Exercise 3 - Task 1 Result.txt
---------------------------------------------------------------------*/






/*---------------------------------------------------------------------
	งานที่ 2
	
	สั่งรันคำสั่ง  T-SQL ที่เตรียมให้เพื่อสร้าง inline-TVF ชื่อ fnGetTop3ProductsForCustomer
		
	เขียนคำสั่ง SELECT เพื่อแสดงคอลัมน์ custid และ contactname จากตาราง Sales.Customers
	ใช้ตัวดำเนินการ CROSS APPLY ทำกับฟังก์ชัน dbo.fnGetTop3ProductsForCustomer เพื่อ
	แสดงคอลัมน์ productid, productname และ totalsalesamount สำหรับลูกค้าแต่ละราย
	
	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 3 - Task 2 Result.txt
	สังเกตุและจดจำจำนวนแถวข้อมูล
---------------------------------------------------------------------*/
IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer;

GO

CREATE FUNCTION dbo.fnGetTop3ProductsForCustomer (@custid AS INT) RETURNS TABLE
AS
RETURN
	SELECT TOP(3)
		p.productid
	,	productname
	,	SUM(d.qty * d.unitprice * (1-d.discount)) AS totalsalesamount	
	FROM Sales.Orders AS o INNER JOIN Sales.OrderDetails AS d 
	ON d.orderid = o.orderid
	INNER JOIN Production.Products AS p 
	ON p.productid = d.productid
	WHERE custid = @custid
	GROUP BY p.productid,p.productname
	ORDER BY totalsalesamount DESC;

GO


/*---------------------------------------------------------------------
	งานที่ 3
	
	ก๊อปปี้คำสั่ง SELECT จากงานที่ 2 เปลี่ยนจากตัวดำเนินการ CROSS APPLY ไปเป็น OUTER APPLY
	
	
	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 3 - Task 3 Result.txt
	
	สังเกตุว่าจำนวนแถวข้อมูลมากกว่างานที่ 2
---------------------------------------------------------------------*/



/*---------------------------------------------------------------------
	งานที่ 4
	
	ก๊อปปี้คำสั่ง SELECT จากงานที่ 3 เพิ่มการกรองผลลัพธ์โดยแสดงเฉพาะลูกค้าที่เคยสั่งสินค้า 
		
	สั่งรันคำสั่งที่เขียนเสร็จ เทียบผลลัพธ์ที่ได้กับไฟล์ Lab Exercise 3 - Task 4 Result.txt
	
	ข้อแตกต่างของ CROSS APPLY และ OUTER APPLY คืออะไร ?
---------------------------------------------------------------------*/



/*---------------------------------------------------------------------
	งานที่ 5
	
	ลบ inline-TVF ที่สร้างขึ้นทิ้ง
---------------------------------------------------------------------*/

IF OBJECT_ID('dbo.fnGetTop3ProductsForCustomer') IS NOT NULL
	DROP FUNCTION dbo.fnGetTop3ProductsForCustomer;


