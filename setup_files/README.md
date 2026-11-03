# Setup — สร้าง sample database TSQL

ไฟล์ `TSQL.sql` สร้างและเติมข้อมูล sample database ชื่อ **TSQL** สำหรับแบบฝึกหัดทั้งหมดใน `lab_files/`
ดัดแปลงจาก TSQLV6 sample database ของ Itzik Ben-Gan (ตำรา *T-SQL Fundamentals*)

## สิ่งที่สคริปต์ทำ

1. ลบ database `TSQL` ที่มีอยู่เดิม (และ `TSQLV6` ชื่อเก่า หากยังตกค้าง) แล้วสร้างใหม่เสมอ
2. สร้าง schemas: `HR`, `Production`, `Sales`, `Stats`
3. สร้างตาราง 10 ตาราง, views 4 ตัว (`Sales.OrderValues`, `Sales.OrderTotalsByYear`,
   `Sales.CustOrders`, `Sales.EmpOrders`), และ utility `dbo.Nums` / `dbo.GetNums`
4. เติมข้อมูลตัวอย่างตามตารางด้านล่าง

| ตาราง | จำนวนแถว | หมายเหตุ |
|-------|----------|----------|
| HR.Employees | 9 | วันเกิดปรับให้อยู่ในวัยทำงานเหมาะสมกับช่วงข้อมูล 2024–2026 |
| Sales.Customers | 91 | |
| Sales.Shippers | 3 | |
| Production.Suppliers | 29 | |
| Production.Categories | 8 | |
| Production.Products | 77 | |
| Sales.Orders | 830 | วันที่ 2024-07-04 → 2026-05-06; เป็น **DATETIME** มีเวลาทำการ 08:00–18:00; `shippeddate` เป็น NULL 21 รายการ (ตามสถานะยังไม่จัดส่ง) |
| Sales.OrderDetails | 2,155 | |
| Stats.Tests / Stats.Scores | 2 / 19 | ชุดข้อมูลสำหรับสาธิต |

รองรับ SQL Server 2019+ และ Azure SQL Database

## วิธีรัน

### SQL Server Management Studio (แนะนำ)

1. เปิด SSMS เชื่อมต่อไปยัง server ของคุณ
2. `File → Open → File...` เลือก `TSQL.sql`
3. กด **Execute** (F5) — สคริปต์จะทำทุกขั้นตอนจนจบ (Section A สำหรับ SQL Server แบบติดตั้งเอง
   และ Section C สำหรับ populate; Section B เป็นขั้นตอนสำหรับ Azure SQL Database ซึ่งอยู่ในรูป comment)

### sqlcmd (command line)

```bat
sqlcmd -S <server> -U <user> -P <password> -i TSQL.sql
```

## ข้อควรระวัง

- **สคริปต์ drop แล้วสร้าง database ใหม่ทุกครั้ง** — ข้อมูลที่แก้ไขเพิ่มเติมจะหายหมด
  จึงใช้รันซ้ำเพื่อ "reset" ข้อมูลกลับค่าเริ่มต้นก่อนเริ่มคาบเรียนได้
- หากยังมี query window ใดเปิดค้างอยู่ที่ database `TSQL` การ drop จะล้มเหลว
  พร้อมข้อความ *"Database cannot be dropped because there are still open connections."*
  → ปิดหน้าต่างที่ต่อ `TSQL` ค้างก่อน แล้วรันใหม่
- หากรันสำเร็จ จะเห็นข้อความ `Changed database context to 'TSQL'` เป็นอย่างน้อย
  ตรวจสอบความพร้อมได้ด้วย:

```sql
USE TSQL;
SELECT COUNT(*) AS orders, MIN(orderdate) AS first_order, MAX(orderdate) AS last_order
FROM Sales.Orders;
-- ค่าที่ถูกต้อง: 830 | 2024-07-04 10:56:09.000 | 2026-05-06 17:12:50.000
```

## การดัดแปลงจาก TSQLV6 ต้นฉบับ

| รายการ | ต้นฉบับ | ฉบับนี้ |
|--------|---------|---------|
| ชื่อ database | TSQLV6 | **TSQL** |
| ช่วงวันที่ orders | 2020–2022 (ตำราพิมพ์ 2006–2008) | **2024–2026** |
| ชนิดคอลัมน์วันที่ใน Orders | DATE | **DATETIME** (+ เวลาทำการ 08:00–18:00) |
| วันเกิด HR.Employees | 1957–1986 | 1966–1995 (วัยทำงานเหมาะสมกับช่วงข้อมูล) |

## Credit

ดัดแปลงจาก TSQLV6 sample database — © Itzik Ben-Gan
