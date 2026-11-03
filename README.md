# SQL Query Labs — DataFabric-Academy

แบบฝึกหัด T-SQL (LAB02–LAB11) สำหรับหลักสูตร **SQL Query** ใช้คู่กับ sample database ชื่อ **TSQL**
ดัดแปลงจาก TSQLV6 sample database ของ Itzik Ben-Gan (ตำรา *T-SQL Fundamentals*) ให้ตรงกับ
บริบทของหลักสูตร: ข้อมูลปี **2024–2026** และใช้ **server กลางเครื่องเดียว หลายผู้เรียน**

## โครงสร้างของ repository

```
├── README.md              ← ไฟล์นี้
├── Setup/
│   ├── TSQL.sql           ← สคริปต์สร้าง + populate database TSQL
│   └── README.md          ← วิธีติดตั้งและรายละเอียดข้อมูล
└── LABS/
    ├── SQL Query.slnx     ← เปิดทุก project พร้อมกันใน SSMS
    ├── LAB02 Exercises/   LAB02 Solutions/   (โครงสร้างเดียวกันถึง LAB11)
    │   ├── Lab Exercise N.sql        ← โจทย์/เฉลย
    │   ├── Lab Exercise N - Task M Result.txt  ← ผลลัพธ์ที่ถูกต้อง (เฉพาะฝั่ง Exercises)
    │   └── LABxx Exercises.ssmssqlproj         ← project ของ SSMS
    └── ...
```

## การเตรียมสภาพแวดล้อม

1. SQL Server 2019 ขึ้นไป (หรือ Azure SQL Database) และ SSMS
2. รัน `Setup/TSQL.sql` ดูวิธีละเอียดใน [Setup/README.md](Setup/README.md)
3. เปิด `LABS/SQL Query.slnx` ด้วย SSMS — ได้ project ของทุก LAB ในหน้าต่างเดียว
4. ผู้เรียนเชื่อมต่อไปยัง database **TSQL** (server / user / password ตามที่อาจารย์แจ้ง)

## แบบฝึกหัดทั้งหมด

| LAB | บทที่ | หัวข้อ | หมายเหตุ |
|-----|-------|--------|----------|
| LAB02 | 02 | พื้นฐาน SELECT และการใช้ SSMS | ไม่มีไฟล์ผลลัพธ์ (งานเน้นทักษะการใช้เครื่องมือ) |
| LAB03 | 03 | การสืบค้นข้อมูลและ JOIN | |
| LAB04 | 04 | Subqueries (มีงานสร้างตาราง `HR.Calendar_XX`) | ใช้กฎ `_XX` |
| LAB05 | 05 | Subqueries ต่อยอด / Table expressions | |
| LAB06 | 06 | ฟังก์ชันวันที่และเวลา, CAST/CONVERT/PARSE | มีงานสร้าง `Sales.Somedates_XX`; ตัวอย่างวันที่ปี 2011 ใน task สาธิตการแปลงเป็นของตัวเองโดยตั้งใจ |
| LAB07 | 08 | GROUP BY และฟังก์ชัน aggregate | |
| LAB08 | 09 | การแก้ไขข้อมูล (INSERT / DELETE) | เพิ่มข้อมูลลงตารางร่วม — ต้องรันคำสั่งลบปิดท้ายตามขั้นตอน |
| LAB09 | 10 | Views และ Inline TVF | สร้าง `ProductsBeverages_XX`, `fnGetSalesByCustomer_XX`, `fnGetTop3ProductsForCustomer_XX` |
| LAB10 | 11 | Set operators (UNION / EXCEPT / INTERSECT) | สร้าง `fnGetTop3ProductsForCustomer_XX` |
| LAB11 | 12 | Window functions (RANK, LAG, LEAD, FIRST_VALUE) | |

หมายเหตุ: หมายเลข บทที่ ตรงตาม comment ในไฟล์แบบฝึกหัด (หลักสูตรข้ามบทที่ 07 ของตำรา)

## วิธีทำแบบฝึกหัด

1. เปิดไฟล์ใน folder `Exercises` — แต่ละไฟล์มีหัวข้อ `งานที่ N` พร้อมคำอธิบายภาษาไทย
2. เขียนคำสั่ง T-SQL ในช่องว่างใต้โจทย์ แล้วรัน
3. เทียบผลลัพธ์กับไฟล์ `Lab Exercise N - Task M Result.txt` (รูปแบบ: ข้อมูล + `(N row(s) affected)`;
   ผลลัพธ์ที่มีมากกว่า 20 แถวจะย่อเป็น 4 แถวแรก + `...` + 3 แถวท้าย)
4. ตรวจคำตอบด้วยตัวเองได้จากไฟล์ใน folder `Solutions`

## การใช้ server/database ร่วมกัน (สำคัญ)

ผู้เรียนทุกคนต่อไปยัง database **TSQL** บน server เครื่องเดียวกัน จึงมีกฎเพื่อไม่ให้กระทบกัน:

- **object ที่แบบฝึกหัดสั่งสร้าง** (table/view/function) ใช้ชื่อลงท้าย `_XX`
  → ให้แทน `XX` ด้วยเลขประจำตัวของคุณก่อนรันทุกครั้ง เช่น `_XX` → `_07`
  (Ctrl+H แทนที่รวดเดียวในไฟล์นั้น) — ครอบคลุม LAB04, LAB06, LAB09, LAB10
- **LAB08** จะเพิ่มแถวข้อมูลเข้า `Sales.Orders` ซึ่งเป็นตารางใช้ร่วมกัน
  → หลังสังเกตผล ต้องรันคำสั่ง DELETE ตามงานที่ 5 ของแบบฝึกหัดที่ 3 ทุกครั้ง
- งานอื่น ๆ เป็นการอ่านข้อมูลล้วน ทำพร้อมกันได้ปลอดภัย

## การดัดแปลงจากต้นฉบับ (TSQLV6)

- วันที่ใน `Sales.Orders` เลื่อนเป็นช่วง **2024-07-04 ถึง 2026-05-06**
  (filter วันที่ในแบบฝึกหัดปรับตาม: ปี 2007 → 2025, ปี 2008 → 2026)
- คอลัมน์ `orderdate` / `requireddate` / `shippeddate` เป็น **DATETIME** พร้อมเวลาทำการ 08:00–18:00
  (ต้นฉบับเป็น DATE ไม่มีเวลา)
- วันเกิดใน `HR.Employees` ปรับให้อยู่ในวัยทำงานเหมาะสมกับช่วงข้อมูลใหม่
- ไฟล์ `Result.txt` ทุกไฟล์ generate จาก database ชุดนี้โดยตรง — ตรวจสอบความถูกต้องแล้ว

## Credit

- Sample database ดัดแปลงจาก **TSQLV6** และแบบฝึกหัดอ้างอิงโครงสร้างจากตำรา
  *T-SQL Fundamentals* — © Itzik Ben-Gan
- ปรับปรุงสำหรับหลักสูตร SQL Query โดย DataFabric-Academy
