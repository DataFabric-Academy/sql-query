/*---------------------------------------------------------------------
	บทที่ 09
	
	แบบฝึกหัด 2
---------------------------------------------------------------------*/

/*---------------------------------------------------------------------
	หมายเหตุสำหรับผู้เรียน (server ใช้ร่วมกัน)
	
	งานที่ 3 ของแบบฝึกหัดนี้จะเพิ่มแถวข้อมูลเข้าตาราง Sales.Orders ซึ่งใช้ร่วมกับทุกคน
	หลังสังเกตผลแล้ว ให้รันคำสั่ง DELETE ในงานที่ 5 ของแบบฝึกหัดที่ 3 ทุกครั้ง
	เพื่อลบข้อมูลที่เพิ่มเข้าไป ไม่ให้กระทบผลลัพธ์ของผู้เรียนท่านอื่น
	(คำสั่งลบจะลบเฉพาะแถวที่ custid เป็น NULL ซึ่งมีจากแบบฝึกหัดนี้เท่านั้น)
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT
	productid
,	productname
FROM Production.Products
WHERE productid	IN 
				(
				SELECT productid
				FROM Sales.OrderDetails
				WHERE qty > 100
				);

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/

SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				);


/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/


INSERT INTO Sales.Orders 
(custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, 
shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
VALUES
(NULL, 1, '20261231', '20261231', '20261231', 1, 0, 
'ShipOne', 'ShipAddress', 'ShipCity', 'RA', '1000', 'USA');

GO


-- NULL issue
SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				);

-- excplicit NULL check

SELECT
	custid
,	contactname
FROM Sales.Customers
WHERE custid NOT IN 
				(
				SELECT custid
				FROM Sales.Orders
				WHERE custid IS NOT NULL
				);



