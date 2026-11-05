---------------------------------------------------------------------
-- Script that creates the sample database TSQL
--
-- Supported versions of SQL Server: 2008+, Azure SQL Database
--
-- Based originally on the Northwind sample database
-- with changes in both schema and data
--
-- Last updated: 20210921
--
-- Original: TSQLV6 sample database, © Itzik Ben-Gan
-- Modified by DataFabric-Academy for the SQL Query course (2026-11-04):
--   - database renamed TSQLV6 -> TSQL (a rerun also drops the legacy TSQLV6)
--   - Sales.Orders dates shifted forward 4 years to span 2024-2026
--   - orderdate/requireddate/shippeddate changed from DATE to DATETIME
--     with realistic business-hours timestamps
--   - HR.Employees birthdates adjusted to appropriate ages for the new timeline
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Create empty database TSQL
---------------------------------------------------------------------

-- For SQL Server box product use the steps in section A and then proceed to section C
-- For Azure SQL Database use the steps in section B and then proceed to section C

---------------------------------------------------------------------
-- Section A - for SQL Server box product only
---------------------------------------------------------------------

-- 1. Connect to your SQL Server instance, master database

-- 2. Run the following code to create an empty database called TSQL
USE master;

-- Drop database (TSQLV6 is the legacy name from before the course rename)
IF DB_ID(N'TSQL')   IS NOT NULL DROP DATABASE TSQL;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR(N'Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE TSQL;
GO

USE TSQL;
GO

-- 3. Proceed to section C

---------------------------------------------------------------------
-- Section B - for Azure SQL Database only
---------------------------------------------------------------------

/*
-- 1. Connect to Azure SQL Database, master database
USE master; -- used only as a test; will fail if not connected to master

-- 2. Run following if TSQL database already exists, otherwise skip
DROP DATABASE TSQL; 
GO

-- 3. Run the following code to create an empty database called TSQL
CREATE DATABASE TSQL;
GO

-- 4. Connect to TSQL before running the rest of the code
USE TSQL; -- used only as a test; will fail if not connected to TSQL
GO

-- 5. Proceed to section C
*/

---------------------------------------------------------------------
-- Populate database TSQL with sample data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Section C - for both SQL Server box and Azure SQL Database
---------------------------------------------------------------------

-- 1. Highlight the remaining code in the script file and execute

---------------------------------------------------------------------
-- Create Schemas
---------------------------------------------------------------------

CREATE SCHEMA HR AUTHORIZATION dbo;
GO
CREATE SCHEMA Production AUTHORIZATION dbo;
GO
CREATE SCHEMA Sales AUTHORIZATION dbo;
GO
CREATE SCHEMA Stats AUTHORIZATION dbo;
GO

---------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------

-- Create table HR.Employees
CREATE TABLE HR.Employees
(
  empid           INT          NOT NULL IDENTITY,
  lastname        NVARCHAR(20) NOT NULL,
  firstname       NVARCHAR(10) NOT NULL,
  title           NVARCHAR(30) NOT NULL,
  titleofcourtesy NVARCHAR(25) NOT NULL,
  birthdate       DATE         NOT NULL,
  hiredate        DATE         NOT NULL,
  address         NVARCHAR(60) NOT NULL,
  city            NVARCHAR(15) NOT NULL,
  region          NVARCHAR(15) NULL,
  postalcode      NVARCHAR(10) NULL,
  country         NVARCHAR(15) NOT NULL,
  phone           NVARCHAR(24) NOT NULL,
  mgrid           INT          NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT FK_Employees_Employees FOREIGN KEY(mgrid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT CHK_birthdate CHECK(birthdate <= CAST(SYSDATETIME() AS DATE))
);

CREATE NONCLUSTERED INDEX idx_nc_lastname   ON HR.Employees(lastname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode ON HR.Employees(postalcode);

-- Create table Production.Suppliers
CREATE TABLE Production.Suppliers
(
  supplierid   INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Suppliers PRIMARY KEY(supplierid)
);

CREATE NONCLUSTERED INDEX idx_nc_companyname ON Production.Suppliers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Production.Suppliers(postalcode);

-- Create table Production.Categories
CREATE TABLE Production.Categories
(
  categoryid   INT           NOT NULL IDENTITY,
  categoryname NVARCHAR(15)  NOT NULL,
  description  NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_Categories PRIMARY KEY(categoryid)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryname ON Production.Categories(categoryname);

-- Create table Production.Products
CREATE TABLE Production.Products
(
  productid    INT          NOT NULL IDENTITY,
  productname  NVARCHAR(40) NOT NULL,
  supplierid   INT          NOT NULL,
  categoryid   INT          NOT NULL,
  unitprice    MONEY        NOT NULL
    CONSTRAINT DFT_Products_unitprice DEFAULT(0),
  discontinued BIT          NOT NULL 
    CONSTRAINT DFT_Products_discontinued DEFAULT(0),
  CONSTRAINT PK_Products PRIMARY KEY(productid),
  CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
    REFERENCES Production.Categories(categoryid),
  CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
    REFERENCES Production.Suppliers(supplierid),
  CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryid  ON Production.Products(categoryid);
CREATE NONCLUSTERED INDEX idx_nc_productname ON Production.Products(productname);
CREATE NONCLUSTERED INDEX idx_nc_supplierid  ON Production.Products(supplierid);

-- Create table Sales.Customers
CREATE TABLE Sales.Customers
(
  custid       INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE NONCLUSTERED INDEX idx_nc_city        ON Sales.Customers(city);
CREATE NONCLUSTERED INDEX idx_nc_companyname ON Sales.Customers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Sales.Customers(postalcode);
CREATE NONCLUSTERED INDEX idx_nc_region      ON Sales.Customers(region);

-- Create table Sales.Shippers
CREATE TABLE Sales.Shippers
(
  shipperid   INT          NOT NULL IDENTITY,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_Shippers PRIMARY KEY(shipperid)
);

-- Create table Sales.Orders
CREATE TABLE Sales.Orders
(
  orderid        INT          NOT NULL IDENTITY,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATETIME     NOT NULL,
  requireddate   DATETIME     NOT NULL,
  shippeddate    DATETIME     NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES Sales.Customers(custid),
  CONSTRAINT FK_Orders_Employees FOREIGN KEY(empid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT FK_Orders_Shippers FOREIGN KEY(shipperid)
    REFERENCES Sales.Shippers(shipperid)
);

CREATE NONCLUSTERED INDEX idx_nc_custid         ON Sales.Orders(custid);
CREATE NONCLUSTERED INDEX idx_nc_empid          ON Sales.Orders(empid);
CREATE NONCLUSTERED INDEX idx_nc_shipperid      ON Sales.Orders(shipperid);
CREATE NONCLUSTERED INDEX idx_nc_orderdate      ON Sales.Orders(orderdate);
CREATE NONCLUSTERED INDEX idx_nc_shippeddate    ON Sales.Orders(shippeddate);
CREATE NONCLUSTERED INDEX idx_nc_shippostalcode ON Sales.Orders(shippostalcode);

-- Create table Sales.OrderDetails
CREATE TABLE Sales.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES Sales.Orders(orderid),
  CONSTRAINT FK_OrderDetails_Products FOREIGN KEY(productid)
    REFERENCES Production.Products(productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_orderid   ON Sales.OrderDetails(orderid);
CREATE NONCLUSTERED INDEX idx_nc_productid ON Sales.OrderDetails(productid);

-- Create table Stats.Tests
CREATE TABLE Stats.Tests
(
  testid    VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Tests PRIMARY KEY(testid)
);

-- Create table Stats.Scores
CREATE TABLE Stats.Scores
(
  testid    VARCHAR(10) NOT NULL,
  studentid VARCHAR(10) NOT NULL,
  score     TINYINT     NOT NULL
    CONSTRAINT CHK_Scores_score CHECK (score BETWEEN 0 AND 100),
  CONSTRAINT PK_Scores PRIMARY KEY(testid, studentid),
  CONSTRAINT FK_Scores_Tests FOREIGN KEY(testid)
    REFERENCES Stats.Tests(testid)
);

CREATE NONCLUSTERED INDEX idx_nc_testid_score ON Stats.Scores(testid, score);

---------------------------------------------------------------------
-- Populate Tables
---------------------------------------------------------------------

SET NOCOUNT ON;

-- Populate table HR.Employees
SET IDENTITY_INSERT HR.Employees ON;
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(1, N'Davis', N'Sara', N'CEO', N'Ms.', '19661208', '20200501', N'7890 - 20th Ave. E., Apt. 2A', N'Seattle', N'WA', N'10003', N'USA', N'(206) 555-0101', NULL);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(2, N'Funk', N'Don', N'Vice President, Sales', N'Dr.', '19700219', '20200814', N'9012 W. Capital Way', N'Tacoma', N'WA', N'10001', N'USA', N'(206) 555-0100', 1);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(3, N'Lew', N'Judy', N'Sales Manager', N'Ms.', '19800830', '20200401', N'2345 Moss Bay Blvd.', N'Kirkland', N'WA', N'10007', N'USA', N'(206) 555-0103', 2);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(4, N'Peled', N'Yael', N'Sales Representative', N'Mrs.', '19860919', '20210503', N'5678 Old Redmond Rd.', N'Redmond', N'WA', N'10009', N'USA', N'(206) 555-0104', 3);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(5, N'Mortensen', N'Sven', N'Sales Manager', N'Mr.', '19820304', '20211017', N'8901 Garrett Hill', N'London', NULL, N'10004', N'UK', N'(71) 234-5678', 2);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(6, N'Suurs', N'Paul', N'Sales Representative', N'Mr.', '19900702', '20211017', N'3456 Coventry House, Miner Rd.', N'London', NULL, N'10005', N'UK', N'(71) 345-6789', 5);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(7, N'King', N'Russell', N'Sales Representative', N'Mr.', '19880529', '20220102', N'6789 Edgeham Hollow, Winchester Way', N'London', NULL, N'10002', N'UK', N'(71) 123-4567', 5);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(8, N'Cameron', N'Maria', N'Sales Representative', N'Ms.', '19920109', '20220305', N'4567 - 11th Ave. N.E.', N'Seattle', N'WA', N'10006', N'USA', N'(206) 555-0102', 3);
INSERT INTO HR.Employees(empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid)
  VALUES(9, N'Doyle', N'Patricia', N'Sales Representative', N'Ms.', '19950127', '20221115', N'1234 Houndstooth Rd.', N'London', NULL, N'10008', N'UK', N'(71) 456-7890', 5);
SET IDENTITY_INSERT HR.Employees OFF;

-- Populate table Production.Suppliers
SET IDENTITY_INSERT Production.Suppliers ON;
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(1, N'Supplier SWRXU', N'Adams, Terry', N'Purchasing Manager', N'2345 Gilbert St.', N'London', NULL, N'10023', N'UK', N'(171) 456-7890', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(2, N'Supplier VHQZD', N'Hance, Jim', N'Order Administrator', N'P.O. Box 5678', N'New Orleans', N'LA', N'10013', N'USA', N'(100) 555-0111', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(3, N'Supplier STUAZ', N'Parovszky, Alfons', N'Sales Representative', N'1234 Oxford Rd.', N'Ann Arbor', N'MI', N'10026', N'USA', N'(313) 555-0109', N'(313) 555-0112');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(4, N'Supplier QOVFD', N'Balázs, Erzsébet', N'Marketing Manager', N'7890 Sekimai Musashino-shi', N'Tokyo', NULL, N'10011', N'Japan', N'(03) 6789-0123', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(5, N'Supplier EQPNC', N'Hofmann, Roland', N'Export Administrator', N'Calle del Rosal 4567', N'Oviedo', N'Asturias', N'10029', N'Spain', N'(98) 123 45 67', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(6, N'Supplier QWUSF', N'Popkova, Darya', N'Marketing Representative', N'8901 Setsuko Chuo-ku', N'Osaka', NULL, N'10028', N'Japan', N'(06) 789-0123', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(7, N'Supplier GQRCV', N'Herp, Jesper', N'Marketing Manager', N'5678 Rose St. Moonie Ponds', N'Melbourne', N'Victoria', N'10018', N'Australia', N'(03) 123-4567', N'(03) 456-7890');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(8, N'Supplier BWGYE', N'Iallo, Lucio', N'Sales Representative', N'9012 King''s Way', N'Manchester', NULL, N'10021', N'UK', N'(161) 567-8901', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(9, N'Supplier QQYEU', N'Basalik, Evan', N'Sales Agent', N'Kaloadagatan 4567', N'Göteborg', NULL, N'10022', N'Sweden', N'031-345 67 89', N'031-678 90 12');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(10, N'Supplier UNAHG', N'Barnett, Dave', N'Marketing Manager', N'Av. das Americanas 2345', N'Sao Paulo', NULL, N'10034', N'Brazil', N'(11) 345 6789', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(11, N'Supplier ZPYVS', N'Jain, Mukesh', N'Sales Manager', N'Tiergartenstraße 3456', N'Berlin', NULL, N'10016', N'Germany', N'(010) 3456789', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(12, N'Supplier SVIYA', N'Reagan, April', N'International Marketing Mgr.', N'Bogenallee 9012', N'Frankfurt', NULL, N'10024', N'Germany', N'(069) 234567', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(13, N'Supplier TEGSC', N'Brehm, Peter', N'Coordinator Foreign Markets', N'Frahmredder 3456', N'Cuxhaven', NULL, N'10019', N'Germany', N'(04721) 1234', N'(04721) 2345');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(14, N'Supplier KEREV', N'Keil, Kendall', N'Sales Representative', N'Viale Dante, 6789', N'Ravenna', NULL, N'10015', N'Italy', N'(0544) 56789', N'(0544) 34567');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(15, N'Supplier NZLIF', N'Sałas-Szlejter, Karolina', N'Marketing Manager', N'Hatlevegen 1234', N'Sandvika', NULL, N'10025', N'Norway', N'(0)9-012345', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(16, N'Supplier UHZRG', N'Scholl, Thorsten', N'Regional Account Rep.', N'8901 - 8th Avenue Suite 210', N'Bend', N'OR', N'10035', N'USA', N'(503) 555-0108', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(17, N'Supplier QZGUF', N'Kleinerman, Christian', N'Sales Representative', N'Brovallavägen 0123', N'Stockholm', NULL, N'10033', N'Sweden', N'08-234 56 78', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(18, N'Supplier LVJUA', N'Canel, Fabrice', N'Sales Manager', N'3456, Rue des Francs-Bourgeois', N'Paris', NULL, N'10031', N'France', N'(1) 90.12.34.56', N'(1) 01.23.45.67');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(19, N'Supplier JDNUG', N'Chapman, Greg', N'Wholesale Account Agent', N'Order Processing Dept. 7890 Paul Revere Blvd.', N'Boston', N'MA', N'10027', N'USA', N'(617) 555-0110', N'(617) 555-0113');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(20, N'Supplier CIYNM', N'Koch, Christine', N'Owner', N'6789 Serangoon Loop, Suite #402', N'Singapore', NULL, N'10037', N'Singapore', N'012-3456', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(21, N'Supplier XOXZA', N'Shakespear, Paul', N'Sales Manager', N'Lyngbysild Fiskebakken 9012', N'Lyngby', NULL, N'10012', N'Denmark', N'67890123', N'78901234');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(22, N'Supplier FNUXM', N'Skelly, Bonnie L.', N'Accounting Manager', N'Verkoop Rijnweg 8901', N'Zaandam', NULL, N'10014', N'Netherlands', N'(12345) 8901', N'(12345) 5678');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(23, N'Supplier ELCRN', N'Lamb, Karin', N'Product Manager', N'Valtakatu 1234', N'Lappeenranta', NULL, N'10032', N'Finland', N'(953) 78901', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(24, N'Supplier JNNES', N'Clarkson, John', N'Sales Representative', N'6789 Prince Edward Parade Hunter''s Hill', N'Sydney', N'NSW', N'10030', N'Australia', N'(02) 234-5678', N'(02) 567-8901');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(25, N'Supplier ERVYZ', N'Sprenger, Christof', N'Marketing Manager', N'7890 Rue St. Laurent', N'Montréal', N'Québec', N'10017', N'Canada', N'(514) 456-7890', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(26, N'Supplier ZWZDM', N'Cunha, Gonçalo', N'Order Administrator', N'Via dei Gelsomini, 5678', N'Salerno', NULL, N'10020', N'Italy', N'(089) 4567890', N'(089) 4567890');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(27, N'Supplier ZRYDZ', N'Paturskis, Leonids', N'Sales Manager', N'4567, rue H. Voiron', N'Montceau', NULL, N'10036', N'France', N'89.01.23.45', NULL);
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(28, N'Supplier OAVQT', N'Teper, Jeff', N'Sales Representative', N'Bat. B 2345, rue des Alpes', N'Annecy', NULL, N'10010', N'France', N'01.23.45.67', N'89.01.23.45');
INSERT INTO Production.Suppliers(supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(29, N'Supplier OGLRK', N'Walters, Rob', N'Accounting Manager', N'0123 rue Chasseur', N'Ste-Hyacinthe', N'Québec', N'10009', N'Canada', N'(514) 567-890', N'(514) 678-9012');
SET IDENTITY_INSERT Production.Suppliers OFF;

-- Populate table Production.Categories
SET IDENTITY_INSERT Production.Categories ON;
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(1, N'Beverages', N'Soft drinks, coffees, teas, beers, and ales');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(2, N'Condiments', N'Sweet and savory sauces, relishes, spreads, and seasonings');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(3, N'Confections', N'Desserts, candies, and sweet breads');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(4, N'Dairy Products', N'Cheeses');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(5, N'Grains/Cereals', N'Breads, crackers, pasta, and cereal');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(6, N'Meat/Poultry', N'Prepared meats');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(7, N'Produce', N'Dried fruit and bean curd');
INSERT INTO Production.Categories(categoryid, categoryname, description)
  VALUES(8, N'Seafood', N'Seaweed and fish');
SET IDENTITY_INSERT Production.Categories OFF;

-- Populate table Production.Products
SET IDENTITY_INSERT Production.Products ON;
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(1, N'Product HHYDP', 1, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(2, N'Product RECZE', 1, 1, 19.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(3, N'Product IMEHJ', 1, 2, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(4, N'Product KSBRM', 2, 2, 22.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(5, N'Product EPEIM', 2, 2, 21.35, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(6, N'Product VAIIV', 3, 2, 25.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(7, N'Product HMLNI', 3, 7, 30.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(8, N'Product WVJFP', 3, 2, 40.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(9, N'Product AOZBW', 4, 6, 97.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(10, N'Product YHXGE', 4, 8, 31.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(11, N'Product QMVUN', 5, 4, 21.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(12, N'Product OSFNS', 5, 4, 38.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(13, N'Product POXFU', 6, 8, 6.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(14, N'Product PWCJB', 6, 7, 23.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(15, N'Product KSZOI', 6, 2, 15.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(16, N'Product PAFRH', 7, 3, 17.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(17, N'Product BLCAX', 7, 6, 39.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(18, N'Product CKEDC', 7, 8, 62.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(19, N'Product XKXDO', 8, 3, 9.20, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(20, N'Product QHFFP', 8, 3, 81.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(21, N'Product VJZZH', 8, 3, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(22, N'Product CPHFY', 9, 5, 21.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(23, N'Product JLUDZ', 9, 5, 9.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(24, N'Product QOGNU', 10, 1, 4.50, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(25, N'Product LYLNI', 11, 3, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(26, N'Product HLGZA', 11, 3, 31.23, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(27, N'Product SMIOH', 11, 3, 43.90, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(28, N'Product OFBNT', 12, 7, 45.60, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(29, N'Product VJXYN', 12, 6, 123.79, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(30, N'Product LYERX', 13, 8, 25.89, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(31, N'Product XWOXC', 14, 4, 12.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(32, N'Product NUNAW', 14, 4, 32.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(33, N'Product ASTMN', 15, 4, 2.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(34, N'Product SWNJY', 16, 1, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(35, N'Product NEVTJ', 16, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(36, N'Product GMKIJ', 17, 8, 19.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(37, N'Product EVFFA', 17, 8, 26.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(38, N'Product QDOMO', 18, 1, 263.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(39, N'Product LSOFL', 18, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(40, N'Product YZIXQ', 19, 8, 18.40, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(41, N'Product TTEEX', 19, 8, 9.65, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(42, N'Product RJVNM', 20, 5, 14.00, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(43, N'Product ZZZHR', 20, 1, 46.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(44, N'Product VJIEO', 20, 2, 19.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(45, N'Product AQOKR', 21, 8, 9.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(46, N'Product CBRRL', 21, 8, 12.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(47, N'Product EZZPR', 22, 3, 9.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(48, N'Product MYNXN', 22, 3, 12.75, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(49, N'Product FPYPN', 23, 3, 20.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(50, N'Product BIUDV', 23, 3, 16.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(51, N'Product APITJ', 24, 7, 53.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(52, N'Product QSRXF', 24, 5, 7.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(53, N'Product BKGEA', 24, 6, 32.80, 1);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(54, N'Product QAQRL', 25, 6, 7.45, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(55, N'Product YYWRT', 25, 6, 24.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(56, N'Product VKCMF', 26, 5, 38.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(57, N'Product OVLQI', 26, 5, 19.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(58, N'Product ACRVI', 27, 8, 13.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(59, N'Product UKXRI', 28, 4, 55.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(60, N'Product WHBYK', 28, 4, 34.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(61, N'Product XYZPE', 29, 2, 28.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(62, N'Product WUXYK', 29, 3, 49.30, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(63, N'Product ICKNK', 7, 2, 43.90, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(64, N'Product HCQDE', 12, 5, 33.25, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(65, N'Product XYWBZ', 2, 2, 21.05, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(66, N'Product LQMGN', 2, 2, 17.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(67, N'Product XLXQF', 16, 1, 14.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(68, N'Product TBTBL', 8, 3, 12.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(69, N'Product COAXA', 15, 4, 36.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(70, N'Product TOONT', 7, 1, 15.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(71, N'Product MYMOI', 15, 4, 21.50, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(72, N'Product GEEOO', 14, 4, 34.80, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(73, N'Product WEUJZ', 17, 8, 15.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(74, N'Product BKAZJ', 4, 7, 10.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(75, N'Product BWRLG', 12, 1, 7.75, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(76, N'Product JYGFE', 23, 1, 18.00, 0);
INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued)
  VALUES(77, N'Product LUNZZ', 12, 2, 13.00, 0);
SET IDENTITY_INSERT Production.Products OFF;

-- Populate table Sales.Customers
SET IDENTITY_INSERT Sales.Customers ON;
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(1, N'Customer NRZBB', N'Allen, Michael', N'Sales Representative', N'Obere Str. 0123', N'Berlin', NULL, N'10092', N'Germany', N'030-3456789', N'030-0123456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(2, N'Customer MLTDN', N'Hassall, Mark', N'Owner', N'Avda. de la Constitución 5678', N'México D.F.', NULL, N'10077', N'Mexico', N'(5) 789-0123', N'(5) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(3, N'Customer KBUDE', N'Strome, David', N'Owner', N'Mataderos  7890', N'México D.F.', NULL, N'10097', N'Mexico', N'(5) 123-4567', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(4, N'Customer HFBZG', N'Cunningham, Conor', N'Sales Representative', N'7890 Hanover Sq.', N'London', NULL, N'10046', N'UK', N'(171) 456-7890', N'(171) 456-7891');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(5, N'Customer HGVLZ', N'Higginbotham, Tom', N'Order Administrator', N'Berguvsvägen  5678', N'Luleå', NULL, N'10112', N'Sweden', N'0921-67 89 01', N'0921-23 45 67');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(6, N'Customer XHXJV', N'Poland, Carole', N'Sales Representative', N'Forsterstr. 7890', N'Mannheim', NULL, N'10117', N'Germany', N'0621-67890', N'0621-12345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(7, N'Customer QXVLA', N'Bansal, Dushyant', N'Marketing Manager', N'2345, place Kléber', N'Strasbourg', NULL, N'10089', N'France', N'67.89.01.23', N'67.89.01.24');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(8, N'Customer QUHWH', N'Ilyina, Julia', N'Owner', N'C/ Araquil, 0123', N'Madrid', NULL, N'10104', N'Spain', N'(91) 345 67 89', N'(91) 012 34 56');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(9, N'Customer RTXGC', N'Raghav, Amritansh', N'Owner', N'6789, rue des Bouchers', N'Marseille', NULL, N'10105', N'France', N'23.45.67.89', N'23.45.67.80');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(10, N'Customer EEALV', N'Culp, Scott', N'Accounting Manager', N'8901 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10111', N'Canada', N'(604) 901-2345', N'(604) 678-9012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(11, N'Customer UBHAU', N'Jaffe, David', N'Sales Representative', N'Fauntleroy Circus 4567', N'London', NULL, N'10064', N'UK', N'(171) 789-0123', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(12, N'Customer PSNMQ', N'Ray, Mike', N'Sales Agent', N'Cerrito 3456', N'Buenos Aires', NULL, N'10057', N'Argentina', N'(1) 890-1234', N'(1) 567-8901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(13, N'Customer VMLOG', N'Benito, Almudena', N'Marketing Manager', N'Sierras de Granada 7890', N'México D.F.', NULL, N'10056', N'Mexico', N'(5) 456-7890', N'(5) 123-4567');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(14, N'Customer WNMAF', N'Jelitto, Jacek', N'Owner', N'Hauptstr. 0123', N'Bern', NULL, N'10065', N'Switzerland', N'0452-678901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(15, N'Customer JUWXK', N'Richardson, Shawn', N'Sales Associate', N'Av. dos Lusíadas, 6789', N'Sao Paulo', N'SP', N'10087', N'Brazil', N'(11) 012-3456', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(16, N'Customer GYBBY', N'Birkby, Dana', N'Sales Representative', N'Berkeley Gardens 0123 Brewery', N'London', NULL, N'10039', N'UK', N'(171) 234-5678', N'(171) 234-5679');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(17, N'Customer FEVNN', N'Sun, Nate', N'Order Administrator', N'Walserweg 4567', N'Aachen', NULL, N'10067', N'Germany', N'0241-789012', N'0241-345678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(18, N'Customer BSVAR', N'Lieber, Justin', N'Owner', N'3456, rue des Cinquante Otages', N'Nantes', NULL, N'10041', N'France', N'89.01.23.45', N'89.01.23.46');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(19, N'Customer RFNQC', N'Boseman, Randall', N'Sales Agent', N'5678 King George', N'London', NULL, N'10110', N'UK', N'(171) 345-6789', N'(171) 345-6780');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(20, N'Customer THHDP', N'Kane, John', N'Sales Manager', N'Kirchgasse 9012', N'Graz', NULL, N'10059', N'Austria', N'1234-5678', N'9012-3456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(21, N'Customer KIDPX', N'Russo, Giuseppe', N'Marketing Assistant', N'Rua Orós, 3456', N'Sao Paulo', N'SP', N'10096', N'Brazil', N'(11) 456-7890', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(22, N'Customer DTDMN', N'Daly, Jim', N'Accounting Manager', N'C/ Moralzarzal, 5678', N'Madrid', NULL, N'10080', N'Spain', N'(91) 890 12 34', N'(91) 567 89 01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(23, N'Customer WVFAF', N'Liu, Jenny', N'Assistant Sales Agent', N'4567, chaussée de Tournai', N'Lille', NULL, N'10048', N'France', N'45.67.89.01', N'45.67.89.02');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(24, N'Customer CYZTN', N'Grisso, Geoff', N'Owner', N'Åkergatan 5678', N'Bräcke', NULL, N'10114', N'Sweden', N'0695-67 89 01', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(25, N'Customer AZJED', N'Carlson, Jason', N'Marketing Manager', N'Berliner Platz 9012', N'München', NULL, N'10091', N'Germany', N'089-8901234', N'089-5678901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(26, N'Customer USDBG', N'Koch, Paul', N'Marketing Manager', N'9012, rue Royale', N'Nantes', NULL, N'10101', N'France', N'34.56.78.90', N'34.56.78.91');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(27, N'Customer WMFEA', N'Schmöllerl, Martin', N'Sales Representative', N'Via Monte Bianco 4567', N'Torino', NULL, N'10099', N'Italy', N'011-2345678', N'011-9012345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(28, N'Customer XYUFB', N'Cavaglieri, Giorgio', N'Sales Manager', N'Jardim das rosas n. 8901', N'Lisboa', NULL, N'10054', N'Portugal', N'(1) 456-7890', N'(1) 123-4567');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(29, N'Customer MDLWA', N'Kolesnikova, Katerina', N'Marketing Manager', N'Rambla de Cataluña, 8901', N'Barcelona', NULL, N'10081', N'Spain', N'(93) 789 0123', N'(93) 456 7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(30, N'Customer KSLQF', N'Grossman, Seth', N'Sales Manager', N'C/ Romero, 1234', N'Sevilla', NULL, N'10075', N'Spain', N'(95) 901 23 45', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(31, N'Customer YJCBX', N'Orint, Neil', N'Sales Associate', N'Av. Brasil, 5678', N'Campinas', N'SP', N'10128', N'Brazil', N'(11) 567-8901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(32, N'Customer YSIQX', N'Krishnan, Venky', N'Marketing Manager', N'6789 Baker Blvd.', N'Eugene', N'OR', N'10070', N'USA', N'(503) 555-0122', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(33, N'Customer FVXPQ', N'Yuksel, Ayca', N'Owner', N'5ª Ave. Los Palos Grandes 3456', N'Caracas', N'DF', N'10043', N'Venezuela', N'(2) 789-0123', N'(2) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(34, N'Customer IBVRG', N'Zhang, Frank', N'Accounting Manager', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10076', N'Brazil', N'(21) 789-0123', N'(21) 789-0124');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(35, N'Customer UMTLM', N'Langohr, Kris', N'Sales Representative', N'Carrera 1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10066', N'Venezuela', N'(5) 567-8901', N'(5) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(36, N'Customer LVJSO', N'Smith, Denise', N'Sales Representative', N'City Center Plaza 2345 Main St.', N'Elgin', N'OR', N'10103', N'USA', N'(503) 555-0126', N'(503) 555-0135');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(37, N'Customer FRXZL', N'Óskarsson, Jón Harry', N'Sales Associate', N'9012 Johnstown Road', N'Cork', N'Co. Cork', N'10051', N'Ireland', N'8901 234', N'5678 9012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(38, N'Customer LJUCA', N'Orton, Jon', N'Marketing Manager', N'Garden House Crowther Way 3456', N'Cowes', N'Isle of Wight', N'10063', N'UK', N'(198) 567-8901', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(39, N'Customer GLLAG', N'Song, Lolan', N'Sales Associate', N'Maubelstr. 8901', N'Brandenburg', NULL, N'10060', N'Germany', N'0555-34567', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(40, N'Customer EFFTC', N'Owens, Ron', N'Sales Representative', N'2345, avenue de l''Europe', N'Versailles', NULL, N'10108', N'France', N'12.34.56.78', N'12.34.56.79');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(41, N'Customer XIIWM', N'Litton, Tim', N'Sales Manager', N'3456 rue Alsace-Lorraine', N'Toulouse', NULL, N'10053', N'France', N'90.12.34.56', N'90.12.34.57');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(42, N'Customer IAIJK', N'Zaki, Amr', N'Marketing Assistant', N'2345 Oak St.', N'Vancouver', N'BC', N'10098', N'Canada', N'(604) 567-8901', N'(604) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(43, N'Customer UISOJ', N'Wu, Qiong', N'Marketing Manager', N'8901 Orchestra Terrace', N'Walla Walla', N'WA', N'10069', N'USA', N'(509) 555-0119', N'(509) 555-0130');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(44, N'Customer OXFRU', N'Louverdis, George', N'Sales Representative', N'Magazinweg 8901', N'Frankfurt a.M.', NULL, N'10095', N'Germany', N'069-7890123', N'069-4567890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(45, N'Customer QXPPT', N'Wright, David', N'Owner', N'1234 Polk St. Suite 5', N'San Francisco', N'CA', N'10062', N'USA', N'(415) 555-0118', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(46, N'Customer XPNIK', N'Neves, Paulo', N'Accounting Manager', N'Carrera 7890 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10093', N'Venezuela', N'(9) 789-0123', N'(9) 456-7890');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(47, N'Customer PSQUZ', N'Lupu, Cornel', N'Owner', N'Ave. 5 de Mayo Porlamar 5678', N'I. de Margarita', N'Nueva Esparta', N'10121', N'Venezuela', N'(8) 01-23-45', N'(8) 67-89-01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(48, N'Customer DVFMB', N'Szymczak, Radosław', N'Sales Manager', N'9012 Chiaroscuro Rd.', N'Portland', N'OR', N'10073', N'USA', N'(503) 555-0117', N'(503) 555-0129');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(49, N'Customer CQRAA', N'Duerr, Bernard', N'Marketing Manager', N'Via Ludovico il Moro 6789', N'Bergamo', NULL, N'10106', N'Italy', N'035-345678', N'035-901234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(50, N'Customer JYPSC', N'Goldin, Maxim', N'Sales Agent', N'Rue Joseph-Bens 0123', N'Bruxelles', NULL, N'10074', N'Belgium', N'(02) 890 12 34', N'(02) 567 89 01');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(51, N'Customer PVDZC', N'Taylor, Maurice', N'Marketing Assistant', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10040', N'Canada', N'(514) 345-6789', N'(514) 012-3456');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(52, N'Customer PZNLA', N'Natarajan, Mrina', N'Marketing Assistant', N'Heerstr. 4567', N'Leipzig', NULL, N'10125', N'Germany', N'0342-12345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(53, N'Customer GCJSG', N'Mallit, Ken', N'Sales Associate', N'South House 1234 Queensbridge', N'London', NULL, N'10061', N'UK', N'(171) 890-1234', N'(171) 890-1235');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(54, N'Customer TDKEG', N'Nash, Mike', N'Sales Agent', N'Ing. Gustavo Moncada 0123 Piso 20-A', N'Buenos Aires', NULL, N'10094', N'Argentina', N'(1) 123-4567', N'(1) 890-1234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(55, N'Customer KZQZT', N'Wood, Robin', N'Sales Representative', N'7890 Bering St.', N'Anchorage', N'AK', N'10050', N'USA', N'(907) 555-0115', N'(907) 555-0128');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(56, N'Customer QNIVZ', N'Miller, Lisa', N'Owner', N'Mehrheimerstr. 9012', N'Köln', NULL, N'10047', N'Germany', N'0221-0123456', N'0221-7890123');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(57, N'Customer WVAXS', N'Tollevsen, Bjørn', N'Owner', N'5678, boulevard Charonne', N'Paris', NULL, N'10085', N'France', N'(1) 89.01.23.45', N'(1) 89.01.23.46');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(58, N'Customer AHXHT', N'Frank, Jill', N'Sales Representative', N'Calle Dr. Jorge Cash 8901', N'México D.F.', NULL, N'10116', N'Mexico', N'(5) 890-1234', N'(5) 567-8901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(59, N'Customer LOLJO', N'Wang, Tony', N'Sales Manager', N'Geislweg 2345', N'Salzburg', NULL, N'10127', N'Austria', N'4567-8901', N'2345-6789');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(60, N'Customer QZURI', N'Uppal, Sunil', N'Sales Representative', N'Estrada da saúde n. 6789', N'Lisboa', NULL, N'10083', N'Portugal', N'(1) 789-0123', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(61, N'Customer WULWD', N'Meisels, Josh', N'Accounting Manager', N'Rua da Panificadora, 1234', N'Rio de Janeiro', N'RJ', N'10115', N'Brazil', N'(21) 678-9012', N'(21) 678-9013');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(62, N'Customer WFIZJ', N'Misiec, Anna', N'Marketing Assistant', N'Alameda dos Canàrios, 1234', N'Sao Paulo', N'SP', N'10102', N'Brazil', N'(11) 901-2345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(63, N'Customer IRRVL', N'Veronesi, Giorgio', N'Accounting Manager', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10126', N'Germany', N'0372-12345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(64, N'Customer LWGMD', N'Gaffney, Lawrie', N'Sales Representative', N'Av. del Libertador 3456', N'Buenos Aires', NULL, N'10124', N'Argentina', N'(1) 234-5678', N'(1) 901-2345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(65, N'Customer NYUHS', N'Moore, Michael', N'Assistant Sales Representative', N'6789 Milton Dr.', N'Albuquerque', N'NM', N'10109', N'USA', N'(505) 555-0125', N'(505) 555-0134');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(66, N'Customer LHANT', N'Voss, Florian', N'Sales Associate', N'Strada Provinciale 7890', N'Reggio Emilia', NULL, N'10038', N'Italy', N'0522-012345', N'0522-678901');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(67, N'Customer QVEPD', N'Garden, Euan', N'Assistant Sales Agent', N'Av. Copacabana, 6789', N'Rio de Janeiro', N'RJ', N'10052', N'Brazil', N'(21) 345-6789', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(68, N'Customer CCKOT', N'Myrcha, Jacek', N'Sales Manager', N'Grenzacherweg 0123', N'Genève', NULL, N'10122', N'Switzerland', N'0897-012345', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(69, N'Customer SIUIH', N'Troup, Carol', N'Accounting Manager', N'Gran Vía, 4567', N'Madrid', NULL, N'10071', N'Spain', N'(91) 567 8901', N'(91) 234 5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(70, N'Customer TMXGN', N'Makovac, Zrinka', N'Owner', N'Erling Skakkes gate 2345', N'Stavern', NULL, N'10123', N'Norway', N'07-89 01 23', N'07-45 67 89');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(71, N'Customer LCOUJ', N'Navarro, Tomás', N'Sales Representative', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10078', N'USA', N'(208) 555-0116', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(72, N'Customer AHPOP', N'Welcker, Brian', N'Sales Manager', N'4567 Wadhurst Rd.', N'London', NULL, N'10088', N'UK', N'(171) 901-2345', N'(171) 901-2346');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(73, N'Customer JMIKW', N'Gonzalez, Nuria', N'Owner', N'Vinbæltet 3456', N'Kobenhavn', NULL, N'10079', N'Denmark', N'12 34 56 78', N'90 12 34 56');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(74, N'Customer YSHXL', N'MacDonald, Scott', N'Marketing Manager', N'9012, rue Lauriston', N'Paris', NULL, N'10058', N'France', N'(1) 23.45.67.89', N'(1) 23.45.67.80');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(75, N'Customer XOJYP', N'Downs, Chris', N'Sales Manager', N'P.O. Box 1234', N'Lander', N'WY', N'10113', N'USA', N'(307) 555-0114', N'(307) 555-0127');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(76, N'Customer SFOGW', N'Luper, Steve', N'Accounting Manager', N'Boulevard Tirou, 2345', N'Charleroi', NULL, N'10100', N'Belgium', N'(071) 56 78 90 12', N'(071) 34 56 78 90');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(77, N'Customer LCYBZ', N'Didcock, Cliff', N'Marketing Manager', N'2345 Jefferson Way Suite 2', N'Portland', N'OR', N'10042', N'USA', N'(503) 555-0120', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(78, N'Customer NLTYP', N'Ma, Andrew', N'Marketing Assistant', N'0123 Grizzly Peak Rd.', N'Butte', N'MT', N'10107', N'USA', N'(406) 555-0121', N'(406) 555-0131');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(79, N'Customer FAPSM', N'Wickham, Jim', N'Marketing Manager', N'Luisenstr. 0123', N'Münster', NULL, N'10118', N'Germany', N'0251-456789', N'0251-012345');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(80, N'Customer VONTK', N'Toh, Karen', N'Owner', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10044', N'Mexico', N'(5) 678-9012', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(81, N'Customer YQQWW', N'Edwards, Josh', N'Sales Representative', N'Av. Inês de Castro, 1234', N'Sao Paulo', N'SP', N'10120', N'Brazil', N'(11) 123-4567', N'(11) 234-5678');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(82, N'Customer EYHKM', N'Veninga, Tjeerd', N'Sales Associate', N'1234 DaVinci Blvd.', N'Kirkland', N'WA', N'10119', N'USA', N'(206) 555-0124', N'(206) 555-0133');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(83, N'Customer ZRNDE', N'Manar, Karim', N'Sales Manager', N'Smagsloget 3456', N'Århus', NULL, N'10090', N'Denmark', N'23 45 67 89', N'01 23 45 67');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(84, N'Customer NRCSK', N'Tuntisangaroon, Sittichai', N'Sales Agent', N'6789, rue du Commerce', N'Lyon', NULL, N'10072', N'France', N'78.90.12.34', N'78.90.12.35');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(85, N'Customer ENQZT', N'Elliott, Patrick', N'Accounting Manager', N'5678 rue de l''Abbaye', N'Reims', NULL, N'10082', N'France', N'56.78.90.12', N'56.78.90.13');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(86, N'Customer SNXOJ', N'Syamala, Manoj', N'Sales Representative', N'Adenauerallee 7890', N'Stuttgart', NULL, N'10086', N'Germany', N'0711-345678', N'0711-901234');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(87, N'Customer ZHYOS', N'Ludwig, Michael', N'Accounting Manager', N'Torikatu 9012', N'Oulu', NULL, N'10045', N'Finland', N'981-123456', N'981-789012');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(88, N'Customer SRQVM', N'Li, Yan', N'Sales Manager', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10084', N'Brazil', N'(14) 234-5678', NULL);
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(89, N'Customer YBQTI', N'Smith Jr., Ronaldo', N'Owner', N'8901 - 14th Ave. S. Suite 3B', N'Seattle', N'WA', N'10049', N'USA', N'(206) 555-0123', N'(206) 555-0132');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(90, N'Customer XBBVR', N'Larsson, Katarina', N'Owner/Marketing Assistant', N'Keskuskatu 2345', N'Helsinki', NULL, N'10055', N'Finland', N'90-012 3456', N'90-789 0123');
INSERT INTO Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
  VALUES(91, N'Customer CCFIZ', N'Vasa, Petr', N'Owner', N'ul. Filtrowa 6789', N'Warszawa', NULL, N'10068', N'Poland', N'(26) 234-5678', N'(26) 901-2345');
SET IDENTITY_INSERT Sales.Customers OFF;

-- Populate table Sales.Shippers
SET IDENTITY_INSERT Sales.Shippers ON;
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137');
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(2, N'Shipper ETYNR', N'(425) 555-0136');
INSERT INTO Sales.Shippers(shipperid, companyname, phone)
  VALUES(3, N'Shipper ZHISN', N'(415) 555-0138');
SET IDENTITY_INSERT Sales.Shippers OFF;

-- Populate table Sales.Orders
SET IDENTITY_INSERT Sales.Orders ON;
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10248, 85, 5, '20240704 10:56:09', '20240801 08:27:22', '20240716 16:52:09', 3, 32.38, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims', NULL, N'10345', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10249, 79, 6, '20240705 12:10:02', '20240816 17:02:52', '20240710 16:18:48', 1, 11.61, N'Ship to 79-C', N'Luisenstr. 9012', N'Münster', NULL, N'10328', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10250, 34, 4, '20240708 10:03:41', '20240805 08:36:54', '20240712 10:36:09', 2, 65.83, N'Destination SCQXA', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10195', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10251, 84, 3, '20240708 14:50:09', '20240805 17:00:20', '20240715 11:14:19', 1, 41.34, N'Ship to 84-A', N'3456, rue du Commerce', N'Lyon', NULL, N'10342', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10252, 76, 4, '20240709 08:51:44', '20240806 14:10:21', '20240711 09:47:07', 2, 51.30, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10253, 34, 3, '20240710 17:47:06', '20240724 13:11:11', '20240716 10:40:35', 2, 58.17, N'Destination JPAIY', N'Rua do Paço, 8901', N'Rio de Janeiro', N'RJ', N'10196', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10254, 14, 5, '20240711 14:09:41', '20240808 12:46:47', '20240723 09:38:13', 2, 22.98, N'Destination YUJRD', N'Hauptstr. 1234', N'Bern', NULL, N'10139', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10255, 68, 9, '20240712 17:51:36', '20240809 13:04:20', '20240715 16:34:00', 3, 148.33, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10256, 88, 3, '20240715 17:07:05', '20240812 09:08:04', '20240717 17:55:37', 2, 13.97, N'Ship to 88-B', N'Rua do Mercado, 5678', N'Resende', N'SP', N'10354', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10257, 35, 4, '20240716 14:33:46', '20240813 17:21:36', '20240722 12:52:28', 3, 81.91, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10258, 20, 1, '20240717 12:56:19', '20240814 15:02:05', '20240723 11:53:55', 1, 140.51, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10259, 13, 4, '20240718 13:41:18', '20240815 09:48:07', '20240725 17:00:10', 3, 3.25, N'Destination LGGCH', N'Sierras de Granada 9012', N'México D.F.', NULL, N'10137', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10260, 56, 4, '20240719 12:56:39', '20240816 16:33:50', '20240729 16:49:33', 1, 55.09, N'Ship to 56-A', N'Mehrheimerstr. 0123', N'Köln', NULL, N'10258', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10261, 61, 4, '20240719 12:22:32', '20240816 12:09:26', '20240730 08:36:43', 2, 3.05, N'Ship to 61-B', N'Rua da Panificadora, 6789', N'Rio de Janeiro', N'RJ', N'10274', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10262, 65, 8, '20240722 10:32:41', '20240819 13:43:58', '20240725 17:21:09', 3, 48.29, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10263, 20, 9, '20240723 10:34:23', '20240820 10:17:26', '20240731 12:15:06', 3, 146.06, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10264, 24, 6, '20240724 12:52:27', '20240821 13:22:07', '20240823 09:00:33', 3, 3.67, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10265, 7, 2, '20240725 08:06:20', '20240822 16:41:39', '20240812 15:01:43', 1, 55.28, N'Ship to 7-A', N'0123, place Kléber', N'Strasbourg', NULL, N'10329', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10266, 87, 3, '20240726 15:19:45', '20240906 16:17:32', '20240731 14:15:37', 3, 25.73, N'Ship to 87-B', N'Torikatu 2345', N'Oulu', NULL, N'10351', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10267, 25, 4, '20240729 14:52:01', '20240826 15:32:19', '20240806 17:29:03', 1, 208.58, N'Destination VAPXU', N'Berliner Platz 0123', N'München', NULL, N'10168', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10268, 33, 8, '20240730 15:52:17', '20240827 16:09:25', '20240802 15:20:49', 3, 66.29, N'Destination QJVQH', N'5ª Ave. Los Palos Grandes 5678', N'Caracas', N'DF', N'10193', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10269, 89, 5, '20240731 08:23:33', '20240814 16:53:53', '20240809 16:23:13', 1, 4.56, N'Ship to 89-B', N'8901 - 12th Ave. S.', N'Seattle', N'WA', N'10357', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10270, 87, 1, '20240801 10:44:06', '20240829 11:56:27', '20240802 10:34:08', 1, 136.54, N'Ship to 87-B', N'Torikatu 2345', N'Oulu', NULL, N'10351', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10271, 75, 6, '20240801 09:17:13', '20240829 10:19:15', '20240830 11:33:46', 2, 4.54, N'Ship to 75-C', N'P.O. Box 7890', N'Lander', N'WY', N'10316', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10272, 65, 6, '20240802 10:45:16', '20240830 08:42:47', '20240806 16:52:03', 2, 98.03, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10273, 63, 3, '20240805 11:14:55', '20240902 14:03:54', '20240812 14:46:50', 3, 76.07, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10274, 85, 6, '20240806 10:16:35', '20240903 14:36:14', '20240816 16:14:10', 1, 6.01, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims', NULL, N'10345', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10275, 49, 1, '20240807 08:36:25', '20240904 12:16:20', '20240809 13:41:54', 1, 26.93, N'Ship to 49-A', N'Via Ludovico il Moro 8901', N'Bergamo', NULL, N'10235', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10276, 80, 8, '20240808 09:15:59', '20240822 13:08:36', '20240814 08:50:25', 3, 13.84, N'Ship to 80-C', N'Avda. Azteca 5678', N'México D.F.', NULL, N'10334', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10277, 52, 2, '20240809 11:19:02', '20240906 13:44:09', '20240813 10:04:41', 3, 125.77, N'Ship to 52-A', N'Heerstr. 9012', N'Leipzig', NULL, N'10247', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10278, 5, 8, '20240812 15:18:58', '20240909 13:02:43', '20240816 12:00:58', 2, 92.69, N'Ship to 5-C', N'Berguvsvägen  1234', N'Luleå', NULL, N'10269', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10279, 44, 8, '20240813 17:24:03', '20240910 12:18:45', '20240816 17:58:06', 2, 25.83, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10280, 5, 2, '20240814 17:17:41', '20240911 15:16:00', '20240912 09:29:23', 1, 8.98, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10281, 69, 4, '20240814 08:22:42', '20240828 09:52:24', '20240821 14:29:30', 1, 2.94, N'Ship to 69-A', N'Gran Vía, 9012', N'Madrid', NULL, N'10297', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10282, 69, 4, '20240815 13:16:32', '20240912 09:50:07', '20240821 08:32:48', 1, 12.69, N'Ship to 69-B', N'Gran Vía, 0123', N'Madrid', NULL, N'10298', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10283, 46, 3, '20240816 09:55:27', '20240913 16:59:52', '20240823 16:07:15', 3, 84.81, N'Ship to 46-A', N'Carrera 0123 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10227', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10284, 44, 4, '20240819 09:44:10', '20240916 14:25:27', '20240827 12:01:50', 1, 76.56, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10285, 63, 1, '20240820 15:07:12', '20240917 16:12:59', '20240826 16:28:37', 2, 76.83, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10286, 63, 8, '20240821 16:01:18', '20240918 08:23:17', '20240830 09:02:55', 3, 229.24, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10287, 67, 8, '20240822 08:06:07', '20240919 10:37:24', '20240828 09:56:42', 3, 12.76, N'Ship to 67-A', N'Av. Copacabana, 3456', N'Rio de Janeiro', N'RJ', N'10291', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10288, 66, 4, '20240823 12:51:57', '20240920 15:10:29', '20240903 16:36:37', 1, 7.45, N'Ship to 66-C', N'Strada Provinciale 2345', N'Reggio Emilia', NULL, N'10290', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10289, 11, 7, '20240826 11:09:25', '20240923 16:08:04', '20240828 13:54:40', 3, 22.77, N'Destination DLEUN', N'Fauntleroy Circus 4567', N'London', NULL, N'10132', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10290, 15, 8, '20240827 12:51:08', '20240924 11:43:11', '20240903 14:11:25', 1, 79.70, N'Destination HQZHO', N'Av. dos Lusíadas, 4567', N'Sao Paulo', N'SP', N'10142', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10291, 61, 6, '20240827 17:00:40', '20240924 13:28:10', '20240904 12:30:57', 2, 6.40, N'Ship to 61-A', N'Rua da Panificadora, 5678', N'Rio de Janeiro', N'RJ', N'10273', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10292, 81, 1, '20240828 12:40:20', '20240925 15:10:48', '20240902 17:20:52', 2, 1.35, N'Ship to 81-A', N'Av. Inês de Castro, 6789', N'Sao Paulo', N'SP', N'10335', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10293, 80, 1, '20240829 15:18:21', '20240926 10:55:30', '20240911 12:22:27', 3, 21.18, N'Ship to 80-B', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10333', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10294, 65, 4, '20240830 16:56:42', '20240927 08:42:58', '20240905 13:28:25', 2, 147.26, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10295, 85, 2, '20240902 16:35:08', '20240930 15:33:36', '20240910 12:18:50', 2, 1.15, N'Ship to 85-C', N'7890 rue de l''Abbaye', N'Reims', NULL, N'10346', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10296, 46, 6, '20240903 10:22:31', '20241001 16:55:02', '20240911 08:07:01', 1, 0.12, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10297, 7, 5, '20240904 13:52:48', '20241016 11:03:38', '20240910 17:00:07', 2, 5.74, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10298, 37, 6, '20240905 17:58:49', '20241003 08:52:41', '20240911 15:45:04', 2, 168.22, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10299, 67, 4, '20240906 11:40:05', '20241004 10:35:32', '20240913 08:50:19', 2, 29.76, N'Ship to 67-A', N'Av. Copacabana, 3456', N'Rio de Janeiro', N'RJ', N'10291', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10300, 49, 2, '20240909 09:50:58', '20241007 11:35:45', '20240918 08:03:45', 2, 17.68, N'Ship to 49-A', N'Via Ludovico il Moro 8901', N'Bergamo', NULL, N'10235', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10301, 86, 8, '20240909 10:36:03', '20241007 15:49:19', '20240917 12:30:48', 2, 45.08, N'Ship to 86-A', N'Adenauerallee 8901', N'Stuttgart', NULL, N'10347', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10302, 76, 4, '20240910 15:35:23', '20241008 08:09:12', '20241009 12:54:15', 2, 6.27, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10303, 30, 7, '20240911 10:46:15', '20241009 13:31:16', '20240918 16:03:48', 2, 107.83, N'Destination IIYDD', N'C/ Romero, 5678', N'Sevilla', NULL, N'10183', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10304, 80, 1, '20240912 11:56:12', '20241010 09:44:50', '20240917 12:15:25', 2, 63.79, N'Ship to 80-C', N'Avda. Azteca 5678', N'México D.F.', NULL, N'10334', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10305, 55, 8, '20240913 10:37:49', '20241011 12:02:23', '20241009 09:08:24', 3, 257.62, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10306, 69, 1, '20240916 15:37:13', '20241014 14:11:34', '20240923 14:20:56', 3, 7.56, N'Ship to 69-B', N'Gran Vía, 0123', N'Madrid', NULL, N'10298', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10307, 48, 2, '20240917 11:40:24', '20241015 13:14:36', '20240925 08:41:23', 2, 0.56, N'Ship to 48-B', N'6789 Chiaroscuro Rd.', N'Portland', N'OR', N'10233', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10308, 2, 7, '20240918 13:54:58', '20241016 10:57:20', '20240924 11:56:19', 3, 1.61, N'Destination QMVCI', N'Avda. de la Constitución 2345', N'México D.F.', NULL, N'10180', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10309, 37, 3, '20240919 15:14:55', '20241017 08:38:35', '20241023 15:13:34', 1, 47.30, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10310, 77, 8, '20240920 10:01:16', '20241018 09:32:06', '20240927 08:31:26', 2, 17.52, N'Ship to 77-B', N'2345 Jefferson Way Suite 2', N'Portland', N'OR', N'10321', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10311, 18, 1, '20240920 15:55:24', '20241004 14:33:46', '20240926 08:10:20', 3, 24.69, N'Destination SNPXM', N'0123, rue des Cinquante Otages', N'Nantes', NULL, N'10148', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10312, 86, 2, '20240923 16:50:44', '20241021 09:53:49', '20241003 16:06:57', 2, 40.26, N'Ship to 86-B', N'Adenauerallee 9012', N'Stuttgart', NULL, N'10348', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10313, 63, 2, '20240924 09:24:10', '20241022 17:40:14', '20241004 13:19:24', 2, 1.96, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10314, 65, 1, '20240925 10:09:02', '20241023 10:55:01', '20241004 08:07:59', 2, 74.16, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10315, 38, 4, '20240926 12:44:55', '20241024 11:48:15', '20241003 15:24:02', 2, 41.76, N'Destination AXVHD', N'Garden House Crowther Way 9012', N'Cowes', N'Isle of Wight', N'10207', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10316, 65, 1, '20240927 12:48:56', '20241025 16:10:20', '20241008 15:52:16', 3, 150.15, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10317, 48, 6, '20240930 12:50:19', '20241028 15:40:28', '20241010 10:26:26', 1, 12.69, N'Ship to 48-B', N'6789 Chiaroscuro Rd.', N'Portland', N'OR', N'10233', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10318, 38, 8, '20241001 12:31:01', '20241029 08:19:31', '20241004 14:38:11', 2, 4.73, N'Destination AXVHD', N'Garden House Crowther Way 9012', N'Cowes', N'Isle of Wight', N'10207', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10319, 80, 7, '20241002 17:51:59', '20241030 13:39:20', '20241011 09:29:29', 3, 64.50, N'Ship to 80-B', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10333', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10320, 87, 5, '20241003 15:18:47', '20241017 15:22:00', '20241018 11:46:00', 3, 34.57, N'Ship to 87-A', N'Torikatu 1234', N'Oulu', NULL, N'10350', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10321, 38, 3, '20241003 11:57:43', '20241031 15:07:52', '20241011 14:33:37', 2, 3.43, N'Destination LMVGS', N'Garden House Crowther Way 8901', N'Cowes', N'Isle of Wight', N'10206', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10322, 58, 7, '20241004 13:15:10', '20241101 14:58:09', '20241023 17:17:25', 3, 0.40, N'Ship to 58-A', N'Calle Dr. Jorge Cash 3456', N'México D.F.', NULL, N'10261', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10323, 39, 4, '20241007 16:05:36', '20241104 12:12:03', '20241014 11:19:04', 1, 4.88, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10324, 71, 9, '20241008 10:55:00', '20241105 16:52:00', '20241010 12:07:50', 1, 214.27, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10325, 39, 1, '20241009 09:54:00', '20241023 12:03:37', '20241014 10:03:22', 3, 64.86, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10326, 8, 4, '20241010 13:50:08', '20241107 11:31:34', '20241014 14:00:44', 2, 77.92, N'Ship to 8-A', N'C/ Araquil, 0123', N'Madrid', NULL, N'10359', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10327, 24, 2, '20241011 09:45:49', '20241108 16:56:20', '20241014 13:58:45', 1, 63.36, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10328, 28, 4, '20241014 12:57:44', '20241111 13:57:45', '20241017 08:15:17', 3, 87.03, N'Destination CIRQO', N'Jardim das rosas n. 8901', N'Lisboa', NULL, N'10176', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10329, 75, 4, '20241015 15:26:28', '20241126 14:59:04', '20241023 12:31:29', 2, 191.67, N'Ship to 75-C', N'P.O. Box 7890', N'Lander', N'WY', N'10316', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10330, 46, 3, '20241016 08:56:03', '20241113 08:36:34', '20241028 09:31:01', 1, 12.75, N'Ship to 46-A', N'Carrera 0123 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10227', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10331, 9, 9, '20241016 10:01:21', '20241127 12:30:09', '20241021 12:57:51', 1, 10.19, N'Ship to 9-C', N'0123, rue des Bouchers', N'Marseille', NULL, N'10369', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10332, 51, 3, '20241017 11:43:01', '20241128 15:41:03', '20241021 10:16:06', 2, 52.84, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10333, 87, 5, '20241018 11:57:11', '20241115 16:29:14', '20241025 13:41:52', 3, 0.59, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10334, 84, 8, '20241021 11:10:07', '20241118 13:17:57', '20241028 14:07:17', 2, 8.56, N'Ship to 84-B', N'4567, rue du Commerce', N'Lyon', NULL, N'10343', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10335, 37, 7, '20241022 11:55:39', '20241119 13:38:35', '20241024 14:15:16', 2, 42.11, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10336, 60, 7, '20241023 15:22:34', '20241120 09:04:24', '20241025 10:02:46', 2, 15.51, N'Ship to 60-B', N'Estrada da saúde n. 3456', N'Lisboa', NULL, N'10271', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10337, 25, 4, '20241024 14:24:31', '20241121 13:16:35', '20241029 11:44:41', 3, 108.26, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10338, 55, 4, '20241025 17:11:25', '20241122 15:42:30', '20241029 09:21:59', 3, 84.21, N'Ship to 55-C', N'9012 Bering St.', N'Anchorage', N'AK', N'10257', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10339, 51, 2, '20241028 14:43:46', '20241125 12:15:44', '20241104 12:29:05', 2, 15.66, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10340, 9, 1, '20241029 12:32:45', '20241126 09:47:15', '20241108 17:17:55', 3, 166.31, N'Ship to 9-A', N'8901, rue des Bouchers', N'Marseille', NULL, N'10367', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10341, 73, 7, '20241029 08:07:23', '20241126 13:05:04', '20241105 12:06:38', 3, 26.78, N'Ship to 73-A', N'Vinbæltet 1234', N'Kobenhavn', NULL, N'10310', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10342, 25, 4, '20241030 17:50:54', '20241113 12:07:46', '20241104 08:31:03', 2, 54.83, N'Destination VAPXU', N'Berliner Platz 0123', N'München', NULL, N'10168', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10343, 44, 4, '20241031 14:58:34', '20241128 13:35:43', '20241106 14:01:17', 1, 110.37, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10344, 89, 4, '20241101 16:18:57', '20241129 17:57:13', '20241105 17:07:53', 2, 23.29, N'Ship to 89-A', N'7890 - 12th Ave. S.', N'Seattle', N'WA', N'10356', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10345, 63, 2, '20241104 11:08:05', '20241202 09:53:25', '20241111 13:32:37', 2, 249.06, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10346, 65, 3, '20241105 12:03:22', '20241217 10:36:11', '20241108 09:41:18', 3, 142.08, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10347, 21, 4, '20241106 15:27:19', '20241204 17:00:49', '20241108 16:15:06', 3, 3.10, N'Destination KKELL', N'Rua Orós, 4567', N'Sao Paulo', N'SP', N'10162', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10348, 86, 4, '20241107 10:01:50', '20241205 11:48:02', '20241115 17:02:19', 2, 0.78, N'Ship to 86-B', N'Adenauerallee 9012', N'Stuttgart', NULL, N'10348', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10349, 75, 7, '20241108 10:31:06', '20241206 08:04:23', '20241115 11:47:43', 1, 8.63, N'Ship to 75-C', N'P.O. Box 7890', N'Lander', N'WY', N'10316', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10350, 41, 6, '20241111 16:37:42', '20241209 12:37:40', '20241203 15:24:13', 2, 64.19, N'Destination DWJIO', N'9012 rue Alsace-Lorraine', N'Toulouse', NULL, N'10217', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10351, 20, 1, '20241111 11:04:16', '20241209 10:35:00', '20241120 12:11:12', 1, 162.33, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10352, 28, 3, '20241112 16:24:20', '20241126 09:57:01', '20241118 08:36:19', 3, 1.30, N'Destination OTSWR', N'Jardim das rosas n. 9012', N'Lisboa', NULL, N'10177', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10353, 59, 7, '20241113 13:04:30', '20241211 08:48:18', '20241125 13:24:04', 3, 360.63, N'Ship to 59-B', N'Geislweg 7890', N'Salzburg', NULL, N'10265', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10354, 58, 8, '20241114 09:18:40', '20241212 12:32:48', '20241120 15:10:45', 3, 53.80, N'Ship to 58-C', N'Calle Dr. Jorge Cash 5678', N'México D.F.', NULL, N'10263', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10355, 4, 6, '20241115 08:03:39', '20241213 11:16:44', '20241120 15:43:22', 1, 41.95, N'Ship to 4-A', N'Brook Farm Stratford St. Mary 0123', N'Colchester', N'Essex', N'10238', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10356, 86, 6, '20241118 13:34:12', '20241216 14:09:20', '20241127 08:28:41', 2, 36.71, N'Ship to 86-A', N'Adenauerallee 8901', N'Stuttgart', NULL, N'10347', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10357, 46, 1, '20241119 10:22:09', '20241217 16:45:28', '20241202 12:28:38', 3, 34.88, N'Ship to 46-B', N'Carrera 1234 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10228', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10358, 41, 5, '20241120 08:50:09', '20241218 16:26:46', '20241127 12:58:56', 1, 19.64, N'Ship to 41-C', N'0123 rue Alsace-Lorraine', N'Toulouse', NULL, N'10218', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10359, 72, 5, '20241121 17:12:59', '20241219 08:46:18', '20241126 15:48:22', 3, 288.43, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10360, 7, 4, '20241122 16:17:25', '20241220 16:50:58', '20241202 14:04:00', 3, 131.70, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10361, 63, 1, '20241122 16:55:47', '20241220 11:52:23', '20241203 14:15:41', 2, 183.17, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10362, 9, 3, '20241125 08:32:26', '20241223 12:35:38', '20241128 14:06:55', 1, 96.04, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10363, 17, 4, '20241126 09:09:57', '20241224 13:31:06', '20241204 11:24:09', 3, 30.54, N'Destination BJCXA', N'Walserweg 7890', N'Aachen', NULL, N'10145', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10364, 19, 1, '20241126 10:22:34', '20250107 15:18:57', '20241204 13:59:01', 1, 71.97, N'Destination QTKCU', N'3456 King George', N'London', NULL, N'10151', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10365, 3, 3, '20241127 10:07:41', '20241225 17:30:16', '20241202 12:00:59', 2, 22.00, N'Destination FQFLS', N'Mataderos  3456', N'México D.F.', NULL, N'10211', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10366, 29, 8, '20241128 13:37:31', '20250109 16:56:32', '20241230 15:51:42', 2, 10.14, N'Destination VPNNG', N'Rambla de Cataluña, 0123', N'Barcelona', NULL, N'10178', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10367, 83, 7, '20241128 12:03:03', '20241226 16:15:43', '20241202 13:57:33', 3, 13.55, N'Ship to 83-B', N'Smagsloget 1234', N'Århus', NULL, N'10340', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10368, 20, 2, '20241129 17:12:13', '20241227 14:15:07', '20241202 14:05:29', 2, 101.95, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10369, 75, 8, '20241202 12:14:54', '20241230 08:18:00', '20241209 11:35:36', 2, 195.68, N'Ship to 75-C', N'P.O. Box 7890', N'Lander', N'WY', N'10316', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10370, 14, 6, '20241203 11:33:22', '20241231 16:48:29', '20241227 14:42:20', 2, 1.17, N'Destination YUJRD', N'Hauptstr. 1234', N'Bern', NULL, N'10139', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10371, 41, 1, '20241203 12:27:55', '20241231 12:33:28', '20241224 13:15:48', 1, 0.45, N'Ship to 41-C', N'0123 rue Alsace-Lorraine', N'Toulouse', NULL, N'10218', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10372, 62, 5, '20241204 08:29:17', '20250101 14:08:14', '20241209 09:48:19', 2, 890.78, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10373, 37, 4, '20241205 16:06:53', '20250102 16:53:15', '20241211 16:43:09', 3, 124.12, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10374, 91, 1, '20241205 15:42:16', '20250102 17:00:00', '20241209 15:15:47', 3, 3.94, N'Ship to 91-A', N'ul. Filtrowa 5678', N'Warszawa', NULL, N'10364', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10375, 36, 3, '20241206 08:20:16', '20250103 16:49:23', '20241209 10:46:59', 2, 20.12, N'Destination HOHCR', N'City Center Plaza 3456 Main St.', N'Elgin', N'OR', N'10201', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10376, 51, 1, '20241209 13:12:11', '20250106 16:08:56', '20241213 12:25:23', 2, 20.39, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10377, 72, 1, '20241209 09:56:13', '20250106 10:12:56', '20241213 09:30:34', 3, 22.21, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10378, 24, 5, '20241210 14:21:37', '20250107 11:32:36', '20241219 12:35:05', 3, 5.44, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10379, 61, 2, '20241211 15:21:57', '20250108 12:58:45', '20241213 12:39:22', 1, 45.03, N'Ship to 61-B', N'Rua da Panificadora, 6789', N'Rio de Janeiro', N'RJ', N'10274', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10380, 37, 8, '20241212 12:46:38', '20250109 08:41:57', '20250116 12:15:12', 3, 35.03, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10381, 46, 3, '20241212 10:13:27', '20250109 09:21:58', '20241213 10:37:00', 3, 7.99, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10382, 20, 4, '20241213 09:45:59', '20250110 09:56:53', '20241216 08:20:01', 1, 94.77, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10383, 4, 8, '20241216 17:16:23', '20250113 14:56:34', '20241218 10:11:06', 3, 34.24, N'Ship to 4-B', N'Brook Farm Stratford St. Mary 1234', N'Colchester', N'Essex', N'10239', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10384, 5, 3, '20241216 16:23:09', '20250113 14:29:24', '20241220 14:10:56', 3, 168.64, N'Ship to 5-C', N'Berguvsvägen  1234', N'Luleå', NULL, N'10269', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10385, 75, 1, '20241217 14:50:11', '20250114 15:30:22', '20241223 11:48:52', 2, 30.96, N'Ship to 75-B', N'P.O. Box 6789', N'Lander', N'WY', N'10315', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10386, 21, 9, '20241218 11:21:56', '20250101 17:17:36', '20241225 10:00:40', 3, 13.99, N'Destination RNSMS', N'Rua Orós, 2345', N'Sao Paulo', N'SP', N'10160', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10387, 70, 1, '20241218 11:57:24', '20250115 16:13:41', '20241220 12:54:25', 2, 93.63, N'Ship to 70-B', N'Erling Skakkes gate 5678', N'Stavern', NULL, N'10303', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10388, 72, 2, '20241219 09:16:19', '20250116 14:13:54', '20241220 08:08:07', 1, 34.86, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10389, 10, 4, '20241220 11:24:25', '20250117 08:22:36', '20241224 10:52:30', 2, 47.42, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10390, 20, 6, '20241223 08:01:56', '20250120 08:41:01', '20241226 13:24:34', 1, 126.38, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10391, 17, 3, '20241223 14:45:03', '20250120 16:51:33', '20241231 09:57:44', 3, 5.45, N'Destination AJTHX', N'Walserweg 9012', N'Aachen', NULL, N'10147', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10392, 59, 2, '20241224 13:06:44', '20250121 15:51:54', '20250101 14:05:18', 3, 122.46, N'Ship to 59-A', N'Geislweg 6789', N'Salzburg', NULL, N'10264', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10393, 71, 1, '20241225 14:20:32', '20250122 11:06:30', '20250103 13:35:01', 3, 126.56, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10394, 36, 1, '20241225 14:45:34', '20250122 13:38:29', '20250103 14:56:32', 3, 30.34, N'Destination AWPJG', N'City Center Plaza 2345 Main St.', N'Elgin', N'OR', N'10200', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10395, 35, 6, '20241226 13:55:18', '20250123 15:07:10', '20250103 16:13:52', 1, 184.41, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10396, 25, 1, '20241227 13:06:19', '20250110 14:10:11', '20250106 17:53:40', 3, 135.35, N'Destination VAPXU', N'Berliner Platz 0123', N'München', NULL, N'10168', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10397, 60, 5, '20241227 15:10:43', '20250124 12:02:39', '20250102 08:55:33', 1, 60.26, N'Ship to 60-A', N'Estrada da saúde n. 2345', N'Lisboa', NULL, N'10270', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10398, 71, 2, '20241230 14:40:28', '20250127 12:46:10', '20250109 08:43:20', 3, 89.16, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10399, 83, 8, '20241231 12:27:41', '20250114 13:38:41', '20250108 15:22:45', 3, 27.36, N'Ship to 83-C', N'Smagsloget 2345', N'Århus', NULL, N'10341', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10400, 19, 1, '20250101 08:53:00', '20250129 08:55:33', '20250116 09:46:29', 3, 83.93, N'Destination BBMRT', N'4567 King George', N'London', NULL, N'10152', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10401, 65, 1, '20250101 16:35:42', '20250129 14:42:52', '20250110 14:02:45', 1, 12.51, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10402, 20, 8, '20250102 13:12:54', '20250213 12:34:42', '20250110 16:41:25', 2, 67.88, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10403, 20, 4, '20250103 15:15:19', '20250131 13:27:30', '20250109 08:30:32', 3, 73.79, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10404, 49, 2, '20250103 12:06:27', '20250131 11:17:42', '20250108 17:27:40', 1, 155.97, N'Ship to 49-B', N'Via Ludovico il Moro 9012', N'Bergamo', NULL, N'10236', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10405, 47, 1, '20250106 08:40:52', '20250203 14:27:54', '20250122 17:54:52', 1, 34.82, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10406, 62, 7, '20250107 14:39:13', '20250218 14:37:46', '20250113 14:25:12', 1, 108.04, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10407, 56, 2, '20250107 08:51:44', '20250204 13:27:23', '20250130 12:16:28', 2, 91.48, N'Ship to 56-B', N'Mehrheimerstr. 1234', N'Köln', NULL, N'10259', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10408, 23, 8, '20250108 08:18:24', '20250205 10:26:05', '20250114 13:26:01', 1, 11.26, N'Destination PXQRR', N'5678, chaussée de Tournai', N'Lille', NULL, N'10163', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10409, 54, 3, '20250109 17:49:46', '20250206 16:33:22', '20250114 17:07:42', 1, 29.83, N'Ship to 54-C', N'Ing. Gustavo Moncada 6789 Piso 20-A', N'Buenos Aires', NULL, N'10254', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10410, 10, 3, '20250110 14:23:14', '20250207 09:48:20', '20250115 11:18:04', 3, 2.40, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10411, 10, 9, '20250110 16:06:17', '20250207 10:43:20', '20250121 15:07:09', 3, 23.65, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10412, 87, 8, '20250113 14:23:58', '20250210 17:53:17', '20250115 16:30:30', 2, 3.77, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10413, 41, 3, '20250114 16:43:15', '20250211 13:21:25', '20250116 16:34:29', 2, 95.66, N'Destination DWJIO', N'9012 rue Alsace-Lorraine', N'Toulouse', NULL, N'10217', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10414, 21, 2, '20250114 08:55:07', '20250211 11:55:06', '20250117 17:00:36', 3, 21.48, N'Destination SSYXZ', N'Rua Orós, 3456', N'Sao Paulo', N'SP', N'10161', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10415, 36, 3, '20250115 09:00:09', '20250212 14:52:11', '20250124 11:20:36', 1, 0.20, N'Destination AWPJG', N'City Center Plaza 2345 Main St.', N'Elgin', N'OR', N'10200', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10416, 87, 8, '20250116 11:35:55', '20250213 15:23:09', '20250127 10:40:08', 3, 22.72, N'Ship to 87-A', N'Torikatu 1234', N'Oulu', NULL, N'10350', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10417, 73, 4, '20250116 14:40:57', '20250213 12:52:52', '20250128 09:03:53', 3, 70.29, N'Ship to 73-C', N'Vinbæltet 2345', N'Kobenhavn', NULL, N'10311', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10418, 63, 4, '20250117 16:47:24', '20250214 14:41:50', '20250124 11:45:16', 1, 17.55, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10419, 68, 4, '20250120 08:20:32', '20250217 08:51:05', '20250130 12:33:40', 2, 137.35, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10420, 88, 3, '20250121 11:58:50', '20250218 10:13:52', '20250127 15:40:33', 1, 44.12, N'Ship to 88-C', N'Rua do Mercado, 6789', N'Resende', N'SP', N'10355', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10421, 61, 8, '20250121 15:30:20', '20250304 11:47:16', '20250127 11:30:58', 1, 99.23, N'Ship to 61-C', N'Rua da Panificadora, 7890', N'Rio de Janeiro', N'RJ', N'10275', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10422, 27, 2, '20250122 10:39:07', '20250219 16:53:09', '20250131 10:24:34', 1, 3.02, N'Destination FFLQT', N'Via Monte Bianco 6789', N'Torino', NULL, N'10174', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10423, 31, 6, '20250123 14:15:56', '20250206 15:13:15', '20250224 12:50:47', 3, 24.50, N'Destination VNIAG', N'Av. Brasil, 9012', N'Campinas', N'SP', N'10187', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10424, 51, 7, '20250123 17:21:53', '20250220 11:03:34', '20250127 12:55:28', 2, 370.61, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10425, 41, 6, '20250124 14:29:10', '20250221 16:13:19', '20250214 10:03:13', 2, 7.93, N'Destination DWJIO', N'9012 rue Alsace-Lorraine', N'Toulouse', NULL, N'10217', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10426, 29, 4, '20250127 12:30:25', '20250224 14:03:57', '20250206 10:20:44', 1, 18.69, N'Destination WOFLH', N'Rambla de Cataluña, 1234', N'Barcelona', NULL, N'10179', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10427, 59, 4, '20250127 15:20:16', '20250224 08:27:42', '20250303 10:02:19', 2, 31.29, N'Ship to 59-C', N'Geislweg 8901', N'Salzburg', NULL, N'10266', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10428, 66, 7, '20250128 17:21:43', '20250225 14:00:10', '20250204 16:52:21', 1, 11.09, N'Ship to 66-C', N'Strada Provinciale 2345', N'Reggio Emilia', NULL, N'10290', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10429, 37, 3, '20250129 08:13:04', '20250312 09:18:15', '20250207 16:45:04', 2, 56.63, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10430, 20, 4, '20250130 14:55:18', '20250213 10:14:33', '20250203 13:41:55', 1, 458.78, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10431, 10, 4, '20250130 15:19:37', '20250213 11:08:09', '20250207 17:18:54', 2, 44.17, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10432, 75, 3, '20250131 12:17:36', '20250214 12:03:28', '20250207 12:20:04', 2, 4.34, N'Ship to 75-A', N'P.O. Box 5678', N'Lander', N'WY', N'10314', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10433, 60, 3, '20250203 12:08:51', '20250303 17:57:20', '20250304 16:13:14', 3, 73.83, N'Ship to 60-A', N'Estrada da saúde n. 2345', N'Lisboa', NULL, N'10270', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10434, 24, 3, '20250203 15:04:07', '20250303 08:59:19', '20250213 10:42:11', 2, 17.92, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10435, 16, 8, '20250204 11:22:52', '20250318 15:30:51', '20250207 17:20:57', 2, 9.21, N'Destination QKQNB', N'Berkeley Gardens 5678  Brewery', N'London', NULL, N'10143', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10436, 7, 3, '20250205 08:05:18', '20250305 10:56:10', '20250211 16:03:55', 2, 156.66, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10437, 87, 8, '20250205 08:16:01', '20250305 16:34:00', '20250212 16:42:44', 1, 19.97, N'Ship to 87-A', N'Torikatu 1234', N'Oulu', NULL, N'10350', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10438, 79, 3, '20250206 15:25:10', '20250306 09:10:45', '20250214 09:45:05', 2, 8.24, N'Ship to 79-A', N'Luisenstr. 7890', N'Münster', NULL, N'10326', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10439, 51, 6, '20250207 16:20:29', '20250307 13:06:22', '20250210 17:02:14', 3, 4.07, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10440, 71, 4, '20250210 12:03:40', '20250310 17:08:53', '20250228 17:46:56', 2, 86.53, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10441, 55, 3, '20250210 10:50:59', '20250324 15:53:15', '20250314 13:06:52', 2, 73.02, N'Ship to 55-C', N'9012 Bering St.', N'Anchorage', N'AK', N'10257', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10442, 20, 3, '20250211 08:44:17', '20250311 09:11:01', '20250218 08:38:33', 2, 47.94, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10443, 66, 8, '20250212 15:57:07', '20250312 09:47:00', '20250214 11:12:28', 1, 13.95, N'Ship to 66-C', N'Strada Provinciale 2345', N'Reggio Emilia', NULL, N'10290', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10444, 5, 3, '20250212 16:27:31', '20250312 09:21:02', '20250221 13:42:22', 3, 3.50, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10445, 5, 3, '20250213 16:36:44', '20250313 14:33:52', '20250220 08:43:16', 1, 9.30, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10446, 79, 6, '20250214 09:39:47', '20250314 17:31:47', '20250219 09:22:33', 1, 14.68, N'Ship to 79-C', N'Luisenstr. 9012', N'Münster', NULL, N'10328', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10447, 67, 4, '20250214 11:03:23', '20250314 15:42:12', '20250307 14:53:20', 2, 68.66, N'Ship to 67-C', N'Av. Copacabana, 5678', N'Rio de Janeiro', N'RJ', N'10293', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10448, 64, 4, '20250217 12:30:35', '20250317 09:00:34', '20250224 10:20:20', 2, 38.82, N'Ship to 64-A', N'Av. del Libertador 4567', N'Buenos Aires', NULL, N'10282', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10449, 7, 3, '20250218 10:19:54', '20250318 09:31:24', '20250227 15:16:49', 2, 53.30, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10450, 84, 8, '20250219 14:47:13', '20250319 08:13:59', '20250311 11:49:48', 2, 7.23, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10451, 63, 4, '20250219 14:08:16', '20250305 10:51:59', '20250312 08:50:09', 3, 189.09, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10452, 71, 8, '20250220 15:43:55', '20250320 13:03:09', '20250226 13:33:52', 1, 140.26, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10453, 4, 1, '20250221 12:20:43', '20250321 15:59:44', '20250226 12:24:03', 2, 25.36, N'Ship to 4-C', N'Brook Farm Stratford St. Mary 2345', N'Colchester', N'Essex', N'10240', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10454, 41, 4, '20250221 08:49:38', '20250321 10:21:05', '20250225 12:36:06', 3, 2.74, N'Ship to 41-C', N'0123 rue Alsace-Lorraine', N'Toulouse', NULL, N'10218', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10455, 87, 8, '20250224 17:24:39', '20250407 10:36:58', '20250303 14:28:11', 2, 180.45, N'Ship to 87-B', N'Torikatu 2345', N'Oulu', NULL, N'10351', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10456, 39, 8, '20250225 08:05:03', '20250408 08:21:48', '20250228 13:02:50', 2, 8.12, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10457, 39, 2, '20250225 15:53:08', '20250325 10:55:52', '20250303 17:11:01', 1, 11.57, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10458, 76, 7, '20250226 16:48:12', '20250326 12:37:35', '20250304 08:09:02', 3, 147.06, N'Ship to 76-A', N'Boulevard Tirou, 8901', N'Charleroi', NULL, N'10317', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10459, 84, 4, '20250227 10:17:53', '20250327 16:40:10', '20250228 13:42:41', 2, 25.09, N'Ship to 84-B', N'4567, rue du Commerce', N'Lyon', NULL, N'10343', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10460, 24, 8, '20250228 17:45:10', '20250328 17:07:33', '20250303 10:12:30', 1, 16.27, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10461, 46, 1, '20250228 12:30:18', '20250328 11:34:49', '20250305 17:02:23', 3, 148.61, N'Ship to 46-A', N'Carrera 0123 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10227', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10462, 16, 2, '20250303 12:02:39', '20250331 10:26:26', '20250318 16:11:08', 1, 6.17, N'Destination ARRMM', N'Berkeley Gardens 6789  Brewery', N'London', NULL, N'10144', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10463, 76, 5, '20250304 09:22:27', '20250401 11:32:21', '20250306 17:53:49', 3, 14.78, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10464, 28, 4, '20250304 10:59:48', '20250401 08:53:54', '20250314 13:29:22', 2, 89.00, N'Destination OTSWR', N'Jardim das rosas n. 9012', N'Lisboa', NULL, N'10177', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10465, 83, 1, '20250305 13:01:42', '20250402 14:15:07', '20250314 14:12:10', 3, 145.04, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10466, 15, 4, '20250306 11:59:59', '20250403 11:13:54', '20250313 16:42:25', 1, 11.93, N'Destination GGSQD', N'Av. dos Lusíadas, 2345', N'Sao Paulo', N'SP', N'10140', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10467, 49, 8, '20250306 16:53:00', '20250403 15:08:24', '20250311 09:26:53', 2, 4.93, N'Ship to 49-C', N'Via Ludovico il Moro 0123', N'Bergamo', NULL, N'10237', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10468, 39, 3, '20250307 12:44:41', '20250404 12:08:31', '20250312 14:53:22', 3, 44.12, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10469, 89, 1, '20250310 08:42:50', '20250407 09:26:48', '20250314 13:42:50', 1, 60.18, N'Ship to 89-C', N'9012 - 12th Ave. S.', N'Seattle', N'WA', N'10358', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10470, 9, 4, '20250311 10:52:21', '20250408 14:41:42', '20250314 14:33:53', 2, 64.56, N'Ship to 9-C', N'0123, rue des Bouchers', N'Marseille', NULL, N'10369', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10471, 11, 2, '20250311 17:00:35', '20250408 09:38:47', '20250318 14:41:47', 3, 45.59, N'Destination NZASL', N'Fauntleroy Circus 5678', N'London', NULL, N'10133', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10472, 72, 8, '20250312 16:30:09', '20250409 10:46:21', '20250319 12:56:40', 1, 4.20, N'Ship to 72-A', N'0123 Wadhurst Rd.', N'London', NULL, N'10308', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10473, 38, 1, '20250313 12:46:45', '20250327 10:44:44', '20250321 15:49:07', 3, 16.37, N'Destination AXVHD', N'Garden House Crowther Way 9012', N'Cowes', N'Isle of Wight', N'10207', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10474, 58, 5, '20250313 10:04:29', '20250410 09:31:01', '20250321 11:26:52', 2, 83.49, N'Ship to 58-C', N'Calle Dr. Jorge Cash 5678', N'México D.F.', NULL, N'10263', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10475, 76, 9, '20250314 12:48:55', '20250411 09:57:21', '20250404 09:42:03', 1, 68.52, N'Ship to 76-C', N'Boulevard Tirou, 0123', N'Charleroi', NULL, N'10319', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10476, 35, 8, '20250317 17:15:15', '20250414 16:29:31', '20250324 13:57:11', 3, 4.41, N'Destination SXYQX', N'Carrera 0123 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10198', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10477, 60, 5, '20250317 14:20:35', '20250414 13:37:29', '20250325 12:35:18', 2, 13.02, N'Ship to 60-A', N'Estrada da saúde n. 2345', N'Lisboa', NULL, N'10270', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10478, 84, 2, '20250318 13:16:33', '20250401 11:59:48', '20250326 09:13:58', 3, 4.81, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10479, 65, 3, '20250319 11:12:26', '20250416 17:47:48', '20250321 10:33:55', 3, 708.95, N'Ship to 65-C', N'9012 Milton Dr.', N'Albuquerque', N'NM', N'10287', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10480, 23, 6, '20250320 17:45:47', '20250417 17:30:58', '20250324 12:00:49', 2, 1.35, N'Destination AGPCO', N'6789, chaussée de Tournai', N'Lille', NULL, N'10164', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10481, 67, 8, '20250320 09:22:38', '20250417 12:42:47', '20250325 13:21:23', 2, 64.33, N'Ship to 67-A', N'Av. Copacabana, 3456', N'Rio de Janeiro', N'RJ', N'10291', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10482, 43, 1, '20250321 17:11:30', '20250418 13:02:34', '20250410 14:36:17', 3, 7.48, N'Ship to 43-B', N'3456 Orchestra Terrace', N'Walla Walla', N'WA', N'10221', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10483, 89, 7, '20250324 12:15:43', '20250421 17:50:24', '20250425 15:24:31', 2, 15.28, N'Ship to 89-A', N'7890 - 12th Ave. S.', N'Seattle', N'WA', N'10356', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10484, 11, 3, '20250324 16:57:05', '20250421 14:45:58', '20250401 10:21:32', 3, 6.88, N'Destination DLEUN', N'Fauntleroy Circus 4567', N'London', NULL, N'10132', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10485, 47, 4, '20250325 09:14:46', '20250408 08:16:48', '20250331 10:47:19', 2, 64.45, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10486, 35, 1, '20250326 11:12:48', '20250423 16:21:22', '20250402 12:06:22', 2, 30.53, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10487, 62, 2, '20250326 13:42:30', '20250423 12:26:13', '20250328 11:16:53', 2, 71.07, N'Ship to 62-B', N'Alameda dos Canàrios, 9012', N'Sao Paulo', N'SP', N'10277', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10488, 25, 8, '20250327 09:42:11', '20250424 12:37:20', '20250402 17:27:06', 2, 4.93, N'Destination VAPXU', N'Berliner Platz 0123', N'München', NULL, N'10168', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10489, 59, 6, '20250328 12:21:22', '20250425 10:39:46', '20250409 08:10:59', 2, 5.29, N'Ship to 59-C', N'Geislweg 8901', N'Salzburg', NULL, N'10266', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10490, 35, 7, '20250331 11:35:59', '20250428 17:26:02', '20250403 12:07:49', 2, 210.19, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10491, 28, 8, '20250331 12:53:55', '20250428 10:21:24', '20250408 13:36:40', 3, 16.96, N'Destination OTSWR', N'Jardim das rosas n. 9012', N'Lisboa', NULL, N'10177', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10492, 10, 3, '20250401 10:31:14', '20250429 11:14:05', '20250411 08:05:45', 1, 62.89, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10493, 41, 4, '20250402 10:41:34', '20250430 17:16:46', '20250410 08:41:05', 3, 10.64, N'Destination OLJND', N'8901 rue Alsace-Lorraine', N'Toulouse', NULL, N'10216', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10494, 15, 4, '20250402 14:38:02', '20250430 13:21:48', '20250409 17:00:02', 2, 65.99, N'Destination EVHYA', N'Av. dos Lusíadas, 3456', N'Sao Paulo', N'SP', N'10141', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10495, 42, 3, '20250403 15:58:08', '20250501 09:23:19', '20250411 13:23:40', 3, 4.65, N'Ship to 42-C', N'2345 Elm St.', N'Vancouver', N'BC', N'10220', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10496, 81, 7, '20250404 17:53:19', '20250502 13:40:59', '20250407 11:57:45', 2, 46.77, N'Ship to 81-C', N'Av. Inês de Castro, 7890', N'Sao Paulo', N'SP', N'10336', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10497, 44, 7, '20250404 12:10:53', '20250502 14:06:23', '20250407 08:15:38', 1, 36.21, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10498, 35, 8, '20250407 16:11:02', '20250505 09:58:54', '20250411 09:16:50', 2, 29.75, N'Destination SXYQX', N'Carrera 0123 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10198', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10499, 46, 4, '20250408 17:09:05', '20250506 11:43:33', '20250416 12:23:15', 2, 102.02, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10500, 41, 6, '20250409 10:52:39', '20250507 08:56:19', '20250417 15:50:49', 1, 42.68, N'Destination OLJND', N'8901 rue Alsace-Lorraine', N'Toulouse', NULL, N'10216', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10501, 6, 9, '20250409 13:59:09', '20250507 16:49:11', '20250416 16:14:06', 3, 8.85, N'Ship to 6-C', N'Forsterstr. 4567', N'Mannheim', NULL, N'10302', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10502, 58, 2, '20250410 12:47:58', '20250508 11:16:24', '20250429 12:13:04', 1, 69.32, N'Ship to 58-B', N'Calle Dr. Jorge Cash 4567', N'México D.F.', NULL, N'10262', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10503, 37, 6, '20250411 17:11:42', '20250509 10:10:40', '20250416 08:20:41', 2, 16.74, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10504, 89, 4, '20250411 14:24:13', '20250509 08:26:21', '20250418 08:50:00', 3, 59.13, N'Ship to 89-B', N'8901 - 12th Ave. S.', N'Seattle', N'WA', N'10357', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10505, 51, 3, '20250414 11:04:37', '20250512 15:28:07', '20250421 13:45:06', 3, 7.13, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10506, 39, 9, '20250415 12:18:39', '20250513 14:07:03', '20250502 08:18:05', 2, 21.19, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10507, 3, 7, '20250415 17:47:15', '20250513 17:41:52', '20250422 16:02:42', 1, 47.45, N'Destination FQFLS', N'Mataderos  3456', N'México D.F.', NULL, N'10211', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10508, 56, 1, '20250416 14:49:36', '20250514 08:53:08', '20250513 16:29:23', 2, 4.99, N'Ship to 56-C', N'Mehrheimerstr. 2345', N'Köln', NULL, N'10260', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10509, 6, 4, '20250417 13:23:58', '20250515 13:59:24', '20250429 11:19:00', 1, 0.15, N'Ship to 6-A', N'Forsterstr. 2345', N'Mannheim', NULL, N'10300', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10510, 71, 6, '20250418 17:44:31', '20250516 15:46:54', '20250428 14:02:57', 3, 367.63, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10511, 9, 4, '20250418 16:02:44', '20250516 14:00:46', '20250421 17:42:00', 3, 350.64, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10512, 21, 7, '20250421 09:45:46', '20250519 16:42:56', '20250424 16:30:04', 2, 3.53, N'Destination RNSMS', N'Rua Orós, 2345', N'Sao Paulo', N'SP', N'10160', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10513, 86, 7, '20250422 12:24:27', '20250603 13:16:44', '20250428 10:23:45', 1, 105.65, N'Ship to 86-A', N'Adenauerallee 8901', N'Stuttgart', NULL, N'10347', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10514, 20, 3, '20250422 10:16:39', '20250520 09:04:28', '20250516 16:05:59', 2, 789.95, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10515, 63, 2, '20250423 11:00:42', '20250507 13:57:44', '20250523 12:13:45', 1, 204.47, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10516, 37, 2, '20250424 08:19:56', '20250522 16:42:46', '20250501 10:19:28', 3, 62.78, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10517, 53, 3, '20250424 15:37:06', '20250522 17:19:59', '20250429 14:48:02', 3, 32.07, N'Ship to 53-A', N'South House 2345 Queensbridge', N'London', NULL, N'10250', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10518, 80, 4, '20250425 12:27:03', '20250509 13:04:05', '20250505 16:12:52', 2, 218.15, N'Ship to 80-B', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10333', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10519, 14, 6, '20250428 11:47:34', '20250526 08:23:13', '20250501 12:11:42', 3, 91.76, N'Destination NRTZZ', N'Hauptstr. 0123', N'Bern', NULL, N'10138', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10520, 70, 7, '20250429 11:15:31', '20250527 08:22:01', '20250501 08:58:19', 1, 13.37, N'Ship to 70-B', N'Erling Skakkes gate 5678', N'Stavern', NULL, N'10303', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10521, 12, 8, '20250429 17:43:44', '20250527 10:46:32', '20250502 13:36:36', 2, 17.22, N'Destination QTHBC', N'Cerrito 6789', N'Buenos Aires', NULL, N'10134', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10522, 44, 4, '20250430 14:49:10', '20250528 17:17:51', '20250506 12:05:53', 1, 45.33, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10523, 72, 7, '20250501 14:52:45', '20250529 11:06:41', '20250530 12:24:01', 2, 77.63, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10524, 5, 1, '20250501 08:25:48', '20250529 16:43:56', '20250507 16:01:15', 2, 244.79, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10525, 9, 1, '20250502 17:43:09', '20250530 11:55:29', '20250523 08:41:39', 2, 11.06, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10526, 87, 4, '20250505 08:19:39', '20250602 14:15:01', '20250515 10:43:35', 2, 58.59, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10527, 63, 7, '20250505 17:04:05', '20250602 08:53:28', '20250507 13:06:40', 1, 41.90, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10528, 32, 6, '20250506 16:02:56', '20250520 17:21:38', '20250509 17:47:17', 2, 3.35, N'Destination LLUXZ', N'1234 Baker Blvd.', N'Eugene', N'OR', N'10189', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10529, 50, 5, '20250507 11:37:29', '20250604 14:25:31', '20250509 16:42:14', 2, 66.69, N'Ship to 50-B', N'Rue Joseph-Bens 4567', N'Bruxelles', NULL, N'10242', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10530, 59, 3, '20250508 10:12:24', '20250605 09:20:44', '20250512 12:23:26', 2, 339.22, N'Ship to 59-C', N'Geislweg 8901', N'Salzburg', NULL, N'10266', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10531, 54, 7, '20250508 08:37:27', '20250605 10:17:32', '20250519 16:03:31', 1, 8.12, N'Ship to 54-A', N'Ing. Gustavo Moncada 4567 Piso 20-A', N'Buenos Aires', NULL, N'10252', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10532, 19, 7, '20250509 09:43:09', '20250606 10:31:30', '20250512 14:23:40', 3, 74.46, N'Destination QTKCU', N'3456 King George', N'London', NULL, N'10151', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10533, 24, 8, '20250512 11:17:21', '20250609 12:50:15', '20250522 11:30:54', 1, 188.04, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10534, 44, 8, '20250512 10:03:59', '20250609 14:42:46', '20250514 09:27:10', 2, 27.94, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10535, 3, 4, '20250513 12:56:16', '20250610 15:35:17', '20250521 16:19:10', 1, 15.64, N'Destination FQFLS', N'Mataderos  3456', N'México D.F.', NULL, N'10211', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10536, 44, 3, '20250514 09:24:14', '20250611 09:44:47', '20250606 09:23:15', 2, 58.88, N'Ship to 44-B', N'Magazinweg 5678', N'Frankfurt a.M.', NULL, N'10223', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10537, 68, 1, '20250514 15:24:20', '20250528 15:34:44', '20250519 13:52:13', 1, 78.85, N'Ship to 68-B', N'Starenweg 7890', N'Genève', NULL, N'10295', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10538, 11, 9, '20250515 14:21:08', '20250612 14:49:51', '20250516 15:49:46', 3, 4.87, N'Destination DLEUN', N'Fauntleroy Circus 4567', N'London', NULL, N'10132', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10539, 11, 6, '20250516 10:26:45', '20250613 13:51:31', '20250523 11:39:43', 3, 12.36, N'Destination DLEUN', N'Fauntleroy Circus 4567', N'London', NULL, N'10132', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10540, 63, 3, '20250519 08:27:33', '20250616 10:29:44', '20250613 15:48:37', 3, 1007.64, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10541, 34, 2, '20250519 17:40:01', '20250616 09:32:18', '20250529 17:45:18', 1, 68.65, N'Destination SCQXA', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10195', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10542, 39, 1, '20250520 09:43:58', '20250617 12:09:20', '20250526 08:25:50', 3, 10.95, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10543, 46, 8, '20250521 12:22:13', '20250618 16:15:46', '20250523 11:05:06', 2, 48.17, N'Ship to 46-B', N'Carrera 1234 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10228', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10544, 48, 4, '20250521 14:41:50', '20250618 09:33:29', '20250530 13:24:46', 1, 24.91, N'Ship to 48-C', N'7890 Chiaroscuro Rd.', N'Portland', N'OR', N'10234', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10545, 43, 8, '20250522 16:46:12', '20250619 16:58:10', '20250626 08:44:30', 2, 11.92, N'Ship to 43-B', N'3456 Orchestra Terrace', N'Walla Walla', N'WA', N'10221', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10546, 84, 1, '20250523 12:32:30', '20250620 13:28:51', '20250527 11:43:34', 3, 194.72, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10547, 72, 3, '20250523 14:41:01', '20250620 10:39:38', '20250602 12:44:32', 2, 178.43, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10548, 79, 3, '20250526 15:55:01', '20250623 10:38:04', '20250602 11:26:28', 2, 1.43, N'Ship to 79-A', N'Luisenstr. 7890', N'Münster', NULL, N'10326', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10549, 63, 5, '20250527 11:09:35', '20250610 16:16:19', '20250530 12:31:55', 1, 171.24, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10550, 30, 7, '20250528 14:01:25', '20250625 08:44:12', '20250606 09:01:22', 3, 4.32, N'Destination GGQIR', N'C/ Romero, 6789', N'Sevilla', NULL, N'10184', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10551, 28, 4, '20250528 16:42:16', '20250709 14:29:03', '20250606 13:12:26', 3, 72.95, N'Destination OTSWR', N'Jardim das rosas n. 9012', N'Lisboa', NULL, N'10177', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10552, 35, 2, '20250529 08:44:38', '20250626 17:23:49', '20250605 14:24:31', 1, 83.22, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10553, 87, 2, '20250530 11:18:32', '20250627 15:46:07', '20250603 12:13:16', 2, 149.49, N'Ship to 87-B', N'Torikatu 2345', N'Oulu', NULL, N'10351', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10554, 56, 4, '20250530 14:16:14', '20250627 15:15:06', '20250605 14:08:43', 3, 120.97, N'Ship to 56-C', N'Mehrheimerstr. 2345', N'Köln', NULL, N'10260', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10555, 71, 6, '20250602 17:52:55', '20250630 09:46:41', '20250604 16:49:37', 3, 252.49, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10556, 73, 2, '20250603 17:33:33', '20250715 15:52:37', '20250613 13:58:38', 1, 9.80, N'Ship to 73-A', N'Vinbæltet 1234', N'Kobenhavn', NULL, N'10310', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10557, 44, 9, '20250603 17:53:22', '20250617 10:48:19', '20250606 14:16:20', 2, 96.72, N'Ship to 44-C', N'Magazinweg 6789', N'Frankfurt a.M.', NULL, N'10224', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10558, 4, 1, '20250604 15:35:23', '20250702 09:35:05', '20250610 16:18:01', 2, 72.97, N'Ship to 4-B', N'Brook Farm Stratford St. Mary 1234', N'Colchester', N'Essex', N'10239', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10559, 7, 6, '20250605 14:49:08', '20250703 10:04:06', '20250613 15:32:46', 1, 8.05, N'Ship to 7-B', N'1234, place Kléber', N'Strasbourg', NULL, N'10330', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10560, 25, 8, '20250606 15:01:10', '20250704 11:21:51', '20250609 10:02:48', 1, 36.65, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10561, 24, 2, '20250606 16:15:54', '20250704 15:20:20', '20250609 12:20:15', 2, 242.21, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10562, 66, 1, '20250609 13:36:23', '20250707 17:05:42', '20250612 12:47:10', 1, 22.95, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10563, 67, 2, '20250610 15:04:58', '20250722 14:18:10', '20250624 08:47:46', 2, 60.43, N'Ship to 67-B', N'Av. Copacabana, 4567', N'Rio de Janeiro', N'RJ', N'10292', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10564, 65, 4, '20250610 09:40:29', '20250708 13:28:51', '20250616 13:24:49', 3, 13.75, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10565, 51, 8, '20250611 11:38:38', '20250709 14:21:33', '20250618 13:30:42', 2, 7.15, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10566, 7, 9, '20250612 15:20:27', '20250710 09:20:31', '20250618 10:41:17', 1, 88.40, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10567, 37, 1, '20250612 11:03:33', '20250710 17:19:46', '20250617 15:07:12', 1, 33.97, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10568, 29, 3, '20250613 15:30:03', '20250711 09:51:59', '20250709 11:05:34', 3, 6.54, N'Destination VPNNG', N'Rambla de Cataluña, 0123', N'Barcelona', NULL, N'10178', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10569, 65, 5, '20250616 17:09:47', '20250714 15:30:12', '20250711 12:53:37', 1, 58.98, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10570, 51, 3, '20250617 15:38:36', '20250715 08:14:30', '20250619 15:21:25', 3, 188.99, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10571, 20, 8, '20250617 14:19:29', '20250729 09:21:04', '20250704 11:06:39', 3, 26.06, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10572, 5, 3, '20250618 10:36:02', '20250716 15:16:15', '20250625 13:02:05', 2, 116.43, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10573, 3, 7, '20250619 16:21:44', '20250717 17:08:43', '20250620 10:10:48', 3, 84.84, N'Destination LANNN', N'Mataderos  4567', N'México D.F.', NULL, N'10212', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10574, 82, 4, '20250619 10:24:02', '20250717 15:59:04', '20250630 13:26:18', 2, 37.60, N'Ship to 82-A', N'8901 DaVinci Blvd.', N'Kirkland', N'WA', N'10337', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10575, 52, 5, '20250620 14:35:47', '20250704 12:01:15', '20250630 12:44:38', 1, 127.34, N'Ship to 52-C', N'Heerstr. 1234', N'Leipzig', NULL, N'10249', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10576, 80, 3, '20250623 09:18:56', '20250707 13:01:40', '20250630 09:26:08', 3, 18.56, N'Ship to 80-C', N'Avda. Azteca 5678', N'México D.F.', NULL, N'10334', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10577, 82, 9, '20250623 17:54:24', '20250804 09:29:00', '20250630 13:32:39', 2, 25.41, N'Ship to 82-B', N'9012 DaVinci Blvd.', N'Kirkland', N'WA', N'10338', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10578, 11, 4, '20250624 17:40:27', '20250722 08:14:41', '20250725 11:06:48', 3, 29.60, N'Destination NZASL', N'Fauntleroy Circus 5678', N'London', NULL, N'10133', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10579, 45, 1, '20250625 17:21:33', '20250723 08:49:08', '20250704 10:44:30', 2, 13.73, N'Ship to 45-C', N'9012 Polk St. Suite 5', N'San Francisco', N'CA', N'10226', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10580, 56, 4, '20250626 12:29:43', '20250724 17:52:51', '20250701 15:01:06', 3, 75.89, N'Ship to 56-C', N'Mehrheimerstr. 2345', N'Köln', NULL, N'10260', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10581, 21, 3, '20250626 17:25:50', '20250724 13:09:13', '20250702 10:18:23', 1, 3.01, N'Destination SSYXZ', N'Rua Orós, 3456', N'Sao Paulo', N'SP', N'10161', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10582, 6, 3, '20250627 10:21:15', '20250725 08:37:51', '20250714 17:48:33', 2, 27.71, N'Ship to 6-A', N'Forsterstr. 2345', N'Mannheim', NULL, N'10300', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10583, 87, 2, '20250630 11:39:08', '20250728 09:34:48', '20250704 15:31:50', 2, 7.28, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10584, 7, 4, '20250630 17:55:31', '20250728 14:51:24', '20250704 17:36:49', 1, 59.14, N'Ship to 7-B', N'1234, place Kléber', N'Strasbourg', NULL, N'10330', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10585, 88, 7, '20250701 15:03:47', '20250729 10:47:17', '20250710 10:35:37', 1, 13.41, N'Ship to 88-A', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10353', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10586, 66, 9, '20250702 17:13:23', '20250730 12:29:55', '20250709 08:05:42', 1, 0.48, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10587, 61, 1, '20250702 17:03:50', '20250730 13:16:47', '20250709 11:45:15', 1, 62.52, N'Ship to 61-C', N'Rua da Panificadora, 7890', N'Rio de Janeiro', N'RJ', N'10275', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10588, 63, 2, '20250703 08:19:09', '20250731 16:33:39', '20250710 15:18:41', 3, 194.67, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10589, 32, 8, '20250704 12:05:24', '20250801 08:15:26', '20250714 10:17:42', 2, 4.42, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10590, 51, 4, '20250707 15:30:08', '20250804 11:08:57', '20250714 12:50:16', 3, 44.77, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10591, 83, 1, '20250707 14:27:34', '20250721 12:05:51', '20250716 09:39:37', 1, 55.92, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10592, 44, 3, '20250708 08:39:23', '20250805 17:55:33', '20250716 09:50:39', 1, 32.10, N'Ship to 44-B', N'Magazinweg 5678', N'Frankfurt a.M.', NULL, N'10223', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10593, 44, 7, '20250709 17:28:52', '20250806 16:50:45', '20250813 08:54:52', 2, 174.20, N'Ship to 44-C', N'Magazinweg 6789', N'Frankfurt a.M.', NULL, N'10224', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10594, 55, 3, '20250709 12:06:58', '20250806 15:22:00', '20250716 13:05:13', 2, 5.24, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10595, 20, 2, '20250710 08:14:10', '20250807 17:25:42', '20250714 16:31:35', 1, 96.78, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10596, 89, 8, '20250711 15:58:50', '20250808 08:35:42', '20250812 17:43:46', 1, 16.34, N'Ship to 89-C', N'9012 - 12th Ave. S.', N'Seattle', N'WA', N'10358', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10597, 59, 7, '20250711 08:36:34', '20250808 13:58:25', '20250718 15:27:16', 3, 35.12, N'Ship to 59-B', N'Geislweg 7890', N'Salzburg', NULL, N'10265', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10598, 65, 1, '20250714 17:16:02', '20250811 11:36:15', '20250718 13:23:37', 3, 44.42, N'Ship to 65-C', N'9012 Milton Dr.', N'Albuquerque', N'NM', N'10287', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10599, 11, 6, '20250715 14:53:11', '20250826 11:30:08', '20250721 08:14:25', 3, 29.98, N'Destination DLEUN', N'Fauntleroy Circus 4567', N'London', NULL, N'10132', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10600, 36, 4, '20250716 12:15:22', '20250813 11:03:26', '20250721 15:00:10', 1, 45.13, N'Destination HOHCR', N'City Center Plaza 3456 Main St.', N'Elgin', N'OR', N'10201', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10601, 35, 7, '20250716 11:50:28', '20250827 12:27:34', '20250722 13:52:06', 1, 58.30, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10602, 83, 8, '20250717 11:42:45', '20250814 11:25:48', '20250722 16:57:07', 2, 2.92, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10603, 71, 8, '20250718 13:18:01', '20250815 08:45:54', '20250808 16:07:51', 2, 48.77, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10604, 28, 1, '20250718 11:44:57', '20250815 11:24:04', '20250729 10:24:37', 1, 7.46, N'Destination CIRQO', N'Jardim das rosas n. 8901', N'Lisboa', NULL, N'10176', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10605, 51, 1, '20250721 16:39:08', '20250818 14:19:25', '20250729 10:01:33', 2, 379.13, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10606, 81, 4, '20250722 17:32:57', '20250819 14:20:30', '20250731 11:15:03', 3, 79.40, N'Ship to 81-C', N'Av. Inês de Castro, 7890', N'Sao Paulo', N'SP', N'10336', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10607, 71, 5, '20250722 12:56:36', '20250819 08:55:58', '20250725 11:01:43', 1, 200.24, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10608, 79, 4, '20250723 13:16:16', '20250820 14:59:50', '20250801 11:56:18', 2, 27.79, N'Ship to 79-C', N'Luisenstr. 9012', N'Münster', NULL, N'10328', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10609, 18, 7, '20250724 11:30:48', '20250821 08:33:47', '20250730 08:59:17', 2, 1.85, N'Destination SNPXM', N'0123, rue des Cinquante Otages', N'Nantes', NULL, N'10148', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10610, 41, 8, '20250725 17:35:30', '20250822 11:42:56', '20250806 09:05:19', 1, 26.78, N'Ship to 41-C', N'0123 rue Alsace-Lorraine', N'Toulouse', NULL, N'10218', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10611, 91, 6, '20250725 17:38:31', '20250822 16:55:33', '20250801 17:47:47', 2, 80.65, N'Ship to 91-B', N'ul. Filtrowa 6789', N'Warszawa', NULL, N'10365', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10612, 71, 1, '20250728 11:13:38', '20250825 08:13:59', '20250801 09:04:25', 2, 544.08, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10613, 35, 4, '20250729 15:34:40', '20250826 11:45:03', '20250801 10:22:06', 2, 8.11, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10614, 6, 8, '20250729 13:09:33', '20250826 13:09:07', '20250801 11:24:56', 3, 1.93, N'Ship to 6-A', N'Forsterstr. 2345', N'Mannheim', NULL, N'10300', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10615, 90, 2, '20250730 08:25:20', '20250827 11:32:37', '20250806 15:49:51', 3, 0.75, N'Ship to 90-B', N'Keskuskatu 3456', N'Helsinki', NULL, N'10362', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10616, 32, 1, '20250731 11:38:54', '20250828 14:57:35', '20250805 10:50:18', 2, 116.53, N'Destination LLUXZ', N'1234 Baker Blvd.', N'Eugene', N'OR', N'10189', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10617, 32, 4, '20250731 15:30:10', '20250828 17:51:21', '20250804 13:51:16', 2, 18.53, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10618, 51, 1, '20250801 13:07:04', '20250912 15:18:11', '20250808 17:36:23', 1, 154.68, N'Ship to 51-C', N'8901 rue St. Laurent', N'Montréal', N'Québec', N'10246', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10619, 51, 3, '20250804 08:08:31', '20250901 09:51:46', '20250807 12:18:22', 3, 91.05, N'Ship to 51-B', N'7890 rue St. Laurent', N'Montréal', N'Québec', N'10245', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10620, 42, 2, '20250805 10:25:17', '20250902 12:12:48', '20250814 11:47:37', 3, 0.94, N'Ship to 42-A', N'1234 Elm St.', N'Vancouver', N'BC', N'10219', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10621, 38, 4, '20250805 14:23:40', '20250902 10:11:27', '20250811 11:23:37', 2, 23.73, N'Destination LMVGS', N'Garden House Crowther Way 8901', N'Cowes', N'Isle of Wight', N'10206', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10622, 67, 4, '20250806 12:44:58', '20250903 08:51:37', '20250811 17:57:05', 3, 50.97, N'Ship to 67-A', N'Av. Copacabana, 3456', N'Rio de Janeiro', N'RJ', N'10291', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10623, 25, 8, '20250807 11:28:03', '20250904 09:32:28', '20250812 15:57:41', 2, 97.18, N'Destination VAPXU', N'Berliner Platz 0123', N'München', NULL, N'10168', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10624, 78, 4, '20250807 11:50:23', '20250904 16:23:35', '20250819 17:37:35', 2, 94.80, N'Ship to 78-C', N'6789 Grizzly Peak Rd.', N'Butte', N'MT', N'10325', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10625, 2, 3, '20250808 10:33:28', '20250905 10:57:27', '20250814 14:25:18', 1, 43.90, N'Destination QOTQA', N'Avda. de la Constitución 3456', N'México D.F.', NULL, N'10181', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10626, 5, 1, '20250811 10:14:27', '20250908 14:14:16', '20250820 09:56:08', 2, 138.69, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10627, 71, 8, '20250811 16:51:00', '20250922 10:02:43', '20250821 12:33:15', 3, 107.46, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10628, 7, 4, '20250812 17:22:57', '20250909 08:15:05', '20250820 12:35:31', 3, 30.36, N'Ship to 7-B', N'1234, place Kléber', N'Strasbourg', NULL, N'10330', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10629, 30, 4, '20250812 08:35:33', '20250909 09:48:02', '20250820 16:05:51', 3, 85.46, N'Destination IIYDD', N'C/ Romero, 5678', N'Sevilla', NULL, N'10183', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10630, 39, 1, '20250813 12:49:36', '20250910 09:45:09', '20250819 12:41:02', 2, 32.35, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10631, 41, 8, '20250814 09:22:42', '20250911 16:00:25', '20250815 15:42:06', 1, 0.87, N'Destination OLJND', N'8901 rue Alsace-Lorraine', N'Toulouse', NULL, N'10216', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10632, 86, 8, '20250814 14:55:32', '20250911 17:59:29', '20250819 10:45:34', 1, 41.38, N'Ship to 86-C', N'Adenauerallee 0123', N'Stuttgart', NULL, N'10349', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10633, 20, 7, '20250815 14:57:27', '20250912 10:08:00', '20250818 14:17:53', 3, 477.90, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10634, 23, 4, '20250815 11:53:15', '20250912 14:47:40', '20250821 09:51:32', 3, 487.38, N'Destination AGPCO', N'6789, chaussée de Tournai', N'Lille', NULL, N'10164', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10635, 49, 8, '20250818 13:06:55', '20250915 15:44:06', '20250821 09:47:11', 3, 47.46, N'Ship to 49-A', N'Via Ludovico il Moro 8901', N'Bergamo', NULL, N'10235', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10636, 87, 4, '20250819 11:32:25', '20250916 08:07:23', '20250826 11:30:27', 1, 1.15, N'Ship to 87-A', N'Torikatu 1234', N'Oulu', NULL, N'10350', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10637, 62, 6, '20250819 12:43:30', '20250916 12:45:55', '20250826 16:37:06', 1, 201.29, N'Ship to 62-C', N'Alameda dos Canàrios, 0123', N'Sao Paulo', N'SP', N'10278', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10638, 47, 3, '20250820 11:43:46', '20250917 16:32:06', '20250901 12:53:10', 1, 158.44, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10639, 70, 7, '20250820 08:14:17', '20250917 14:02:37', '20250827 16:30:54', 3, 38.64, N'Ship to 70-B', N'Erling Skakkes gate 5678', N'Stavern', NULL, N'10303', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10640, 86, 4, '20250821 09:42:55', '20250918 13:07:52', '20250828 08:48:09', 1, 23.55, N'Ship to 86-A', N'Adenauerallee 8901', N'Stuttgart', NULL, N'10347', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10641, 35, 4, '20250822 13:56:50', '20250919 14:20:29', '20250826 16:51:01', 2, 179.61, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10642, 73, 7, '20250822 11:49:50', '20250919 13:35:05', '20250905 17:04:08', 3, 41.89, N'Ship to 73-C', N'Vinbæltet 2345', N'Kobenhavn', NULL, N'10311', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10643, 1, 6, '20250825 17:26:14', '20250922 16:52:35', '20250902 12:20:38', 1, 29.46, N'Destination LOUIE', N'Obere Str. 6789', N'Berlin', NULL, N'10154', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10644, 88, 3, '20250825 10:49:58', '20250922 13:58:33', '20250901 08:15:37', 2, 0.14, N'Ship to 88-A', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10353', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10645, 34, 4, '20250826 17:35:34', '20250923 08:59:22', '20250902 11:28:23', 1, 12.41, N'Destination DPCVR', N'Rua do Paço, 6789', N'Rio de Janeiro', N'RJ', N'10194', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10646, 37, 9, '20250827 13:58:49', '20251008 11:03:44', '20250903 09:46:12', 3, 142.33, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10647, 61, 4, '20250827 14:14:50', '20250910 08:37:32', '20250903 12:36:40', 2, 45.54, N'Ship to 61-B', N'Rua da Panificadora, 6789', N'Rio de Janeiro', N'RJ', N'10274', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10648, 67, 5, '20250828 08:21:57', '20251009 16:45:03', '20250909 17:26:22', 2, 14.25, N'Ship to 67-C', N'Av. Copacabana, 5678', N'Rio de Janeiro', N'RJ', N'10293', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10649, 50, 5, '20250828 12:06:40', '20250925 09:06:06', '20250829 08:15:19', 3, 6.20, N'Ship to 50-B', N'Rue Joseph-Bens 4567', N'Bruxelles', NULL, N'10242', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10650, 21, 5, '20250829 15:38:58', '20250926 09:56:23', '20250903 17:53:53', 3, 176.81, N'Destination SSYXZ', N'Rua Orós, 3456', N'Sao Paulo', N'SP', N'10161', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10651, 86, 8, '20250901 13:00:54', '20250929 17:04:56', '20250911 10:18:52', 2, 20.60, N'Ship to 86-A', N'Adenauerallee 8901', N'Stuttgart', NULL, N'10347', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10652, 31, 4, '20250901 10:43:34', '20250929 16:54:21', '20250908 13:10:49', 2, 7.14, N'Destination VNIAG', N'Av. Brasil, 9012', N'Campinas', N'SP', N'10187', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10653, 25, 1, '20250902 11:41:11', '20250930 17:02:23', '20250919 08:29:54', 1, 93.25, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10654, 5, 5, '20250902 15:04:57', '20250930 12:20:50', '20250911 08:52:52', 1, 55.26, N'Ship to 5-C', N'Berguvsvägen  1234', N'Luleå', NULL, N'10269', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10655, 66, 1, '20250903 10:50:28', '20251001 14:54:47', '20250911 11:03:47', 2, 4.41, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10656, 32, 6, '20250904 12:24:28', '20251002 13:17:44', '20250910 10:03:00', 1, 57.15, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10657, 71, 2, '20250904 10:45:55', '20251002 13:26:45', '20250915 16:24:29', 2, 352.69, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10658, 63, 4, '20250905 14:31:16', '20251003 11:13:50', '20250908 10:18:03', 1, 364.15, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10659, 62, 7, '20250905 12:02:24', '20251003 13:24:13', '20250910 17:32:24', 2, 105.81, N'Ship to 62-B', N'Alameda dos Canàrios, 9012', N'Sao Paulo', N'SP', N'10277', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10660, 36, 8, '20250908 15:08:58', '20251006 08:18:48', '20251015 13:27:56', 1, 111.29, N'Destination HOHCR', N'City Center Plaza 3456 Main St.', N'Elgin', N'OR', N'10201', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10661, 37, 7, '20250909 12:00:54', '20251007 12:33:47', '20250915 11:19:28', 3, 17.55, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10662, 48, 3, '20250909 11:09:14', '20251007 17:21:18', '20250918 12:26:58', 2, 1.28, N'Ship to 48-C', N'7890 Chiaroscuro Rd.', N'Portland', N'OR', N'10234', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10663, 9, 2, '20250910 14:05:28', '20250924 10:58:37', '20251003 16:26:23', 2, 113.15, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10664, 28, 1, '20250910 12:35:25', '20251008 11:12:18', '20250919 10:58:19', 3, 1.27, N'Destination OTSWR', N'Jardim das rosas n. 9012', N'Lisboa', NULL, N'10177', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10665, 48, 1, '20250911 16:18:37', '20251009 13:18:08', '20250917 11:30:33', 2, 26.31, N'Ship to 48-B', N'6789 Chiaroscuro Rd.', N'Portland', N'OR', N'10233', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10666, 68, 7, '20250912 08:00:26', '20251010 13:06:01', '20250922 17:42:11', 2, 232.42, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10667, 20, 7, '20250912 17:36:18', '20251010 10:50:49', '20250919 10:17:23', 1, 78.09, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10668, 86, 1, '20250915 12:32:37', '20251013 09:10:11', '20250923 16:44:07', 2, 47.22, N'Ship to 86-C', N'Adenauerallee 0123', N'Stuttgart', NULL, N'10349', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10669, 73, 2, '20250915 10:30:27', '20251013 08:00:32', '20250922 15:33:48', 1, 24.39, N'Ship to 73-A', N'Vinbæltet 1234', N'Kobenhavn', NULL, N'10310', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10670, 25, 4, '20250916 08:37:44', '20251014 13:58:25', '20250918 13:24:20', 1, 203.48, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10671, 26, 1, '20250917 10:58:30', '20251015 15:18:32', '20250924 09:13:14', 1, 30.34, N'Destination OPXJT', N'4567, rue Royale', N'Nantes', NULL, N'10172', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10672, 5, 9, '20250917 15:18:02', '20251001 15:37:48', '20250926 13:43:55', 2, 95.75, N'Ship to 5-C', N'Berguvsvägen  1234', N'Luleå', NULL, N'10269', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10673, 90, 2, '20250918 10:24:39', '20251016 10:12:35', '20250919 09:32:33', 1, 22.76, N'Ship to 90-B', N'Keskuskatu 3456', N'Helsinki', NULL, N'10362', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10674, 38, 4, '20250918 10:58:10', '20251016 10:38:06', '20250930 16:46:00', 2, 0.90, N'Destination QVTLW', N'Garden House Crowther Way 7890', N'Cowes', N'Isle of Wight', N'10205', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10675, 25, 5, '20250919 17:03:17', '20251017 16:39:34', '20250923 16:23:18', 2, 31.85, N'Destination WEGWI', N'Berliner Platz 2345', N'München', NULL, N'10170', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10676, 80, 2, '20250922 13:51:02', '20251020 16:39:06', '20250929 12:41:09', 2, 2.01, N'Ship to 80-C', N'Avda. Azteca 5678', N'México D.F.', NULL, N'10334', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10677, 3, 1, '20250922 16:52:22', '20251020 17:36:04', '20250926 14:24:18', 3, 4.03, N'Destination LANNN', N'Mataderos  4567', N'México D.F.', NULL, N'10212', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10678, 71, 7, '20250923 17:04:03', '20251021 16:57:00', '20251016 16:46:59', 3, 388.98, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10679, 7, 8, '20250923 10:02:09', '20251021 12:33:44', '20250930 08:45:33', 3, 27.94, N'Ship to 7-A', N'0123, place Kléber', N'Strasbourg', NULL, N'10329', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10680, 55, 1, '20250924 10:12:25', '20251022 15:04:39', '20250926 09:16:58', 1, 26.61, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10681, 32, 3, '20250925 09:09:11', '20251023 10:56:00', '20250930 15:14:33', 3, 76.13, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10682, 3, 3, '20250925 08:25:40', '20251023 12:54:53', '20251001 10:58:17', 2, 36.13, N'Destination RTGIS', N'Mataderos  2345', N'México D.F.', NULL, N'10210', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10683, 18, 2, '20250926 10:19:50', '20251024 13:42:29', '20251001 14:27:17', 1, 4.40, N'Destination FVRGC', N'2345, rue des Cinquante Otages', N'Nantes', NULL, N'10150', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10684, 56, 3, '20250926 08:20:08', '20251024 10:59:05', '20250930 08:49:19', 1, 145.63, N'Ship to 56-B', N'Mehrheimerstr. 1234', N'Köln', NULL, N'10259', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10685, 31, 4, '20250929 08:18:26', '20251013 12:48:15', '20251003 12:23:09', 2, 33.75, N'Destination VNIAG', N'Av. Brasil, 9012', N'Campinas', N'SP', N'10187', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10686, 59, 2, '20250930 13:36:49', '20251028 14:24:09', '20251008 15:47:39', 1, 96.50, N'Ship to 59-B', N'Geislweg 7890', N'Salzburg', NULL, N'10265', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10687, 37, 9, '20250930 08:09:39', '20251028 11:40:44', '20251030 15:25:23', 2, 296.43, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10688, 83, 4, '20251001 15:22:07', '20251015 14:07:11', '20251007 16:02:35', 2, 299.09, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10689, 5, 1, '20251001 15:22:37', '20251029 08:18:30', '20251007 09:21:31', 2, 13.42, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10690, 34, 1, '20251002 11:05:08', '20251030 16:36:23', '20251003 08:10:51', 1, 15.80, N'Destination JPAIY', N'Rua do Paço, 8901', N'Rio de Janeiro', N'RJ', N'10196', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10691, 63, 2, '20251003 17:04:55', '20251114 10:36:47', '20251022 08:43:53', 2, 810.05, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10692, 1, 4, '20251003 10:43:32', '20251031 12:52:46', '20251013 16:06:37', 2, 61.02, N'Destination RSVRP', N'Obere Str. 8901', N'Berlin', NULL, N'10156', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10693, 89, 3, '20251006 11:39:32', '20251020 10:21:31', '20251010 09:41:53', 3, 139.34, N'Ship to 89-C', N'9012 - 12th Ave. S.', N'Seattle', N'WA', N'10358', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10694, 63, 8, '20251006 08:29:34', '20251103 16:06:07', '20251009 16:55:02', 3, 398.36, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10695, 90, 7, '20251007 14:50:12', '20251118 08:25:02', '20251014 13:27:54', 1, 16.72, N'Ship to 90-C', N'Keskuskatu 4567', N'Helsinki', NULL, N'10363', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10696, 89, 8, '20251008 10:48:57', '20251119 16:35:51', '20251014 17:09:19', 3, 102.55, N'Ship to 89-A', N'7890 - 12th Ave. S.', N'Seattle', N'WA', N'10356', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10697, 47, 3, '20251008 14:42:36', '20251105 11:32:38', '20251014 17:22:46', 1, 45.52, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10698, 20, 4, '20251009 16:01:28', '20251106 14:00:48', '20251017 11:09:18', 1, 272.47, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10699, 52, 3, '20251009 12:48:58', '20251106 12:20:00', '20251013 13:25:48', 3, 0.58, N'Ship to 52-B', N'Heerstr. 0123', N'Leipzig', NULL, N'10248', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10700, 71, 3, '20251010 08:18:20', '20251107 10:59:07', '20251016 16:49:12', 1, 65.10, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10701, 37, 6, '20251013 13:01:46', '20251027 14:42:32', '20251015 16:15:38', 3, 220.31, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10702, 1, 4, '20251013 10:29:44', '20251124 12:19:19', '20251021 16:12:43', 1, 23.94, N'Destination ZELZJ', N'Obere Str. 7890', N'Berlin', NULL, N'10155', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10703, 24, 6, '20251014 09:42:31', '20251111 16:51:23', '20251020 13:41:54', 2, 152.30, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10704, 62, 6, '20251014 08:12:59', '20251111 17:07:59', '20251107 16:48:09', 1, 4.78, N'Ship to 62-C', N'Alameda dos Canàrios, 0123', N'Sao Paulo', N'SP', N'10278', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10705, 35, 9, '20251015 11:51:32', '20251112 11:13:52', '20251118 12:52:18', 2, 3.52, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10706, 55, 8, '20251016 17:11:40', '20251113 09:26:31', '20251021 10:17:32', 3, 135.63, N'Ship to 55-C', N'9012 Bering St.', N'Anchorage', N'AK', N'10257', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10707, 4, 4, '20251016 09:43:19', '20251030 08:57:28', '20251023 10:35:04', 3, 21.74, N'Ship to 4-A', N'Brook Farm Stratford St. Mary 0123', N'Colchester', N'Essex', N'10238', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10708, 77, 6, '20251017 08:13:38', '20251128 12:21:24', '20251105 10:20:35', 2, 2.96, N'Ship to 77-C', N'3456 Jefferson Way Suite 2', N'Portland', N'OR', N'10322', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10709, 31, 1, '20251017 13:16:59', '20251114 08:17:53', '20251120 11:24:51', 3, 210.80, N'Destination GWPFK', N'Av. Brasil, 0123', N'Campinas', N'SP', N'10188', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10710, 27, 1, '20251020 11:17:57', '20251117 16:55:43', '20251023 10:16:27', 1, 4.98, N'Destination FFLQT', N'Via Monte Bianco 6789', N'Torino', NULL, N'10174', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10711, 71, 5, '20251021 12:54:58', '20251202 13:23:22', '20251029 09:22:50', 2, 52.41, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10712, 37, 3, '20251021 16:00:54', '20251118 14:17:04', '20251031 10:52:41', 1, 89.93, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10713, 71, 1, '20251022 16:50:50', '20251119 09:10:17', '20251024 12:31:16', 1, 167.05, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10714, 71, 5, '20251022 17:37:36', '20251119 08:10:32', '20251027 17:34:27', 3, 24.49, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10715, 9, 3, '20251023 13:40:19', '20251106 08:48:59', '20251029 12:44:08', 1, 63.20, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10716, 64, 4, '20251024 11:03:25', '20251121 17:09:41', '20251027 12:16:44', 2, 22.57, N'Ship to 64-B', N'Av. del Libertador 5678', N'Buenos Aires', NULL, N'10283', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10717, 25, 1, '20251024 11:14:51', '20251121 12:56:56', '20251029 17:08:10', 2, 59.25, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10718, 39, 1, '20251027 16:39:19', '20251124 08:10:49', '20251029 14:30:25', 3, 170.88, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10719, 45, 8, '20251027 14:27:18', '20251124 13:46:26', '20251105 08:52:35', 2, 51.44, N'Ship to 45-A', N'8901 Polk St. Suite 5', N'San Francisco', N'CA', N'10225', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10720, 61, 8, '20251028 16:54:44', '20251111 14:07:05', '20251105 14:46:23', 2, 9.53, N'Ship to 61-C', N'Rua da Panificadora, 7890', N'Rio de Janeiro', N'RJ', N'10275', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10721, 63, 5, '20251029 09:24:52', '20251126 17:54:07', '20251031 11:37:50', 3, 48.92, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10722, 71, 8, '20251029 16:06:33', '20251210 10:28:53', '20251104 16:04:39', 1, 74.58, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10723, 89, 3, '20251030 10:39:18', '20251127 09:26:29', '20251125 13:26:28', 1, 21.72, N'Ship to 89-C', N'9012 - 12th Ave. S.', N'Seattle', N'WA', N'10358', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10724, 51, 8, '20251030 10:48:46', '20251211 16:41:19', '20251105 11:20:08', 2, 57.75, N'Ship to 51-A', N'6789 rue St. Laurent', N'Montréal', N'Québec', N'10244', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10725, 21, 4, '20251031 16:02:46', '20251128 08:00:36', '20251105 13:28:14', 3, 10.83, N'Destination KKELL', N'Rua Orós, 4567', N'Sao Paulo', N'SP', N'10162', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10726, 19, 4, '20251103 13:15:35', '20251117 14:19:55', '20251205 11:15:17', 1, 16.56, N'Destination FRCGJ', N'5678 King George', N'London', NULL, N'10153', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10727, 66, 2, '20251103 15:23:51', '20251201 15:21:48', '20251205 12:33:46', 1, 89.90, N'Ship to 66-A', N'Strada Provinciale 0123', N'Reggio Emilia', NULL, N'10288', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10728, 62, 4, '20251104 10:12:26', '20251202 13:47:38', '20251111 11:56:58', 2, 58.33, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10729, 47, 8, '20251104 11:24:00', '20251216 12:11:44', '20251114 14:15:54', 3, 141.06, N'Ship to 47-A', N'Ave. 5 de Mayo Porlamar 3456', N'I. de Margarita', N'Nueva Esparta', N'10230', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10730, 9, 5, '20251105 12:44:14', '20251203 17:08:44', '20251114 13:47:03', 1, 20.12, N'Ship to 9-A', N'8901, rue des Bouchers', N'Marseille', NULL, N'10367', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10731, 14, 7, '20251106 13:12:26', '20251204 09:49:20', '20251114 10:25:34', 1, 96.65, N'Destination YUJRD', N'Hauptstr. 1234', N'Bern', NULL, N'10139', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10732, 9, 3, '20251106 10:41:45', '20251204 09:24:42', '20251107 17:31:36', 1, 16.97, N'Ship to 9-A', N'8901, rue des Bouchers', N'Marseille', NULL, N'10367', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10733, 5, 1, '20251107 16:43:17', '20251205 16:22:35', '20251110 08:38:02', 3, 110.11, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10734, 31, 2, '20251107 11:17:17', '20251205 15:30:53', '20251112 15:31:29', 3, 1.63, N'Destination VNIAG', N'Av. Brasil, 9012', N'Campinas', N'SP', N'10187', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10735, 45, 6, '20251110 13:06:16', '20251208 15:16:37', '20251121 12:46:37', 2, 45.97, N'Ship to 45-A', N'8901 Polk St. Suite 5', N'San Francisco', N'CA', N'10225', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10736, 37, 9, '20251111 10:46:25', '20251209 13:29:30', '20251121 15:53:23', 2, 44.10, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10737, 85, 2, '20251111 09:59:51', '20251209 17:25:15', '20251118 16:50:16', 2, 7.79, N'Ship to 85-C', N'7890 rue de l''Abbaye', N'Reims', NULL, N'10346', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10738, 74, 2, '20251112 09:49:23', '20251210 12:50:34', '20251118 17:21:36', 1, 2.91, N'Ship to 74-A', N'3456, rue Lauriston', N'Paris', NULL, N'10312', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10739, 85, 3, '20251112 16:03:52', '20251210 10:01:36', '20251117 12:50:43', 3, 11.08, N'Ship to 85-C', N'7890 rue de l''Abbaye', N'Reims', NULL, N'10346', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10740, 89, 4, '20251113 09:33:57', '20251211 16:20:48', '20251125 08:28:43', 2, 81.88, N'Ship to 89-B', N'8901 - 12th Ave. S.', N'Seattle', N'WA', N'10357', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10741, 4, 4, '20251114 08:22:56', '20251128 13:29:17', '20251118 13:43:16', 3, 10.96, N'Ship to 4-C', N'Brook Farm Stratford St. Mary 2345', N'Colchester', N'Essex', N'10240', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10742, 10, 3, '20251114 13:17:51', '20251212 11:02:23', '20251118 11:17:23', 3, 243.73, N'Destination LPHSI', N'3456 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10131', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10743, 4, 1, '20251117 10:35:27', '20251215 08:14:33', '20251121 15:32:41', 2, 23.72, N'Ship to 4-C', N'Brook Farm Stratford St. Mary 2345', N'Colchester', N'Essex', N'10240', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10744, 83, 6, '20251117 17:12:29', '20251215 13:56:10', '20251124 15:58:55', 1, 69.19, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10745, 63, 9, '20251118 08:55:23', '20251216 12:54:59', '20251127 09:08:56', 1, 3.52, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10746, 14, 1, '20251119 16:35:26', '20251217 08:05:39', '20251121 08:46:44', 3, 31.43, N'Destination NRTZZ', N'Hauptstr. 0123', N'Bern', NULL, N'10138', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10747, 59, 6, '20251119 16:11:37', '20251217 16:17:37', '20251126 08:09:46', 1, 117.33, N'Ship to 59-B', N'Geislweg 7890', N'Salzburg', NULL, N'10265', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10748, 71, 3, '20251120 17:53:52', '20251218 09:59:59', '20251128 14:42:56', 1, 232.55, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10749, 38, 4, '20251120 14:09:10', '20251218 11:02:59', '20251219 16:05:42', 2, 61.53, N'Destination QVTLW', N'Garden House Crowther Way 7890', N'Cowes', N'Isle of Wight', N'10205', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10750, 87, 9, '20251121 17:22:07', '20251219 09:58:39', '20251124 12:46:54', 1, 79.30, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10751, 68, 3, '20251124 16:56:19', '20251222 17:24:27', '20251203 14:41:18', 3, 130.79, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10752, 53, 2, '20251124 10:58:06', '20251222 15:08:33', '20251128 12:43:29', 3, 1.39, N'Ship to 53-C', N'South House 3456 Queensbridge', N'London', NULL, N'10251', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10753, 27, 3, '20251125 08:11:35', '20251223 13:35:22', '20251127 08:20:03', 1, 7.70, N'Destination DICGM', N'Via Monte Bianco 7890', N'Torino', NULL, N'10175', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10754, 49, 6, '20251125 15:23:10', '20251223 17:27:35', '20251127 11:49:05', 3, 2.38, N'Ship to 49-B', N'Via Ludovico il Moro 9012', N'Bergamo', NULL, N'10236', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10755, 9, 4, '20251126 16:17:25', '20251224 12:21:28', '20251128 10:27:43', 2, 16.71, N'Ship to 9-C', N'0123, rue des Bouchers', N'Marseille', NULL, N'10369', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10756, 75, 8, '20251127 10:47:51', '20251225 09:02:00', '20251202 12:52:43', 2, 73.21, N'Ship to 75-C', N'P.O. Box 7890', N'Lander', N'WY', N'10316', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10757, 71, 6, '20251127 13:18:00', '20251225 14:31:49', '20251215 08:04:02', 1, 8.19, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10758, 68, 3, '20251128 17:01:35', '20251226 17:02:11', '20251204 13:43:15', 3, 138.17, N'Ship to 68-C', N'Starenweg 8901', N'Genève', NULL, N'10296', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10759, 2, 3, '20251128 17:50:59', '20251226 14:48:44', '20251212 13:08:14', 3, 11.99, N'Destination QOTQA', N'Avda. de la Constitución 3456', N'México D.F.', NULL, N'10181', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10760, 50, 4, '20251201 13:34:58', '20251229 09:12:04', '20251210 11:06:01', 1, 155.64, N'Ship to 50-B', N'Rue Joseph-Bens 4567', N'Bruxelles', NULL, N'10242', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10761, 65, 5, '20251202 10:22:11', '20251230 15:01:49', '20251208 16:42:58', 2, 18.66, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10762, 24, 3, '20251202 14:52:17', '20251230 08:17:18', '20251209 12:06:05', 1, 328.74, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10763, 23, 3, '20251203 13:34:20', '20251231 14:27:29', '20251208 09:21:52', 3, 37.35, N'Destination PXQRR', N'5678, chaussée de Tournai', N'Lille', NULL, N'10163', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10764, 20, 6, '20251203 08:03:57', '20251231 17:34:24', '20251208 14:42:26', 3, 145.45, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10765, 63, 3, '20251204 15:19:29', '20260101 13:52:49', '20251209 12:21:18', 3, 42.74, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10766, 56, 4, '20251205 16:22:43', '20260102 14:39:41', '20251209 10:33:08', 1, 157.55, N'Ship to 56-C', N'Mehrheimerstr. 2345', N'Köln', NULL, N'10260', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10767, 76, 4, '20251205 15:42:20', '20260102 11:28:27', '20251215 10:59:53', 3, 1.59, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10768, 4, 3, '20251208 16:34:30', '20260105 17:02:05', '20251215 08:40:26', 2, 146.32, N'Ship to 4-B', N'Brook Farm Stratford St. Mary 1234', N'Colchester', N'Essex', N'10239', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10769, 83, 3, '20251208 12:43:20', '20260105 15:16:41', '20251212 10:24:08', 1, 65.06, N'Ship to 83-C', N'Smagsloget 2345', N'Århus', NULL, N'10341', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10770, 34, 8, '20251209 11:15:21', '20260106 12:18:17', '20251217 11:19:41', 3, 5.32, N'Destination JPAIY', N'Rua do Paço, 8901', N'Rio de Janeiro', N'RJ', N'10196', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10771, 20, 9, '20251210 13:41:31', '20260107 11:55:41', '20260102 08:09:43', 2, 11.19, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10772, 44, 3, '20251210 11:48:21', '20260107 12:53:23', '20251219 11:16:46', 2, 91.28, N'Ship to 44-B', N'Magazinweg 5678', N'Frankfurt a.M.', NULL, N'10223', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10773, 20, 1, '20251211 08:48:34', '20260108 13:51:53', '20251216 14:26:38', 3, 96.43, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10774, 24, 4, '20251211 13:03:17', '20251225 14:27:50', '20251212 10:12:57', 1, 48.20, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10775, 78, 7, '20251212 16:31:54', '20260109 11:47:07', '20251226 14:46:59', 1, 20.25, N'Ship to 78-A', N'4567 Grizzly Peak Rd.', N'Butte', N'MT', N'10323', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10776, 20, 1, '20251215 14:16:31', '20260112 09:05:08', '20251218 15:05:24', 3, 351.53, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10777, 31, 7, '20251215 15:53:49', '20251229 14:39:25', '20260121 10:49:39', 2, 3.01, N'Destination GWPFK', N'Av. Brasil, 0123', N'Campinas', N'SP', N'10188', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10778, 5, 3, '20251216 09:20:29', '20260113 08:18:17', '20251224 11:09:27', 1, 6.79, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10779, 52, 3, '20251216 14:26:57', '20260113 17:30:29', '20260114 13:28:35', 2, 58.13, N'Ship to 52-A', N'Heerstr. 9012', N'Leipzig', NULL, N'10247', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10780, 46, 2, '20251216 09:19:20', '20251230 10:17:42', '20251225 10:09:41', 1, 42.13, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10781, 87, 2, '20251217 09:51:31', '20260114 11:00:34', '20251219 17:48:34', 3, 73.16, N'Ship to 87-A', N'Torikatu 1234', N'Oulu', NULL, N'10350', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10782, 12, 9, '20251217 14:58:44', '20260114 09:37:10', '20251222 11:32:50', 3, 1.10, N'Destination CJDJB', N'Cerrito 8901', N'Buenos Aires', NULL, N'10136', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10783, 34, 4, '20251218 16:26:39', '20260115 14:50:26', '20251219 10:02:09', 2, 124.98, N'Destination DPCVR', N'Rua do Paço, 6789', N'Rio de Janeiro', N'RJ', N'10194', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10784, 49, 4, '20251218 16:58:49', '20260115 17:14:10', '20251222 10:54:05', 3, 70.09, N'Ship to 49-A', N'Via Ludovico il Moro 8901', N'Bergamo', NULL, N'10235', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10785, 33, 1, '20251218 12:51:52', '20260115 11:31:53', '20251224 08:26:26', 3, 1.51, N'Destination FQJFJ', N'5ª Ave. Los Palos Grandes 4567', N'Caracas', N'DF', N'10192', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10786, 62, 8, '20251219 08:20:53', '20260116 10:07:54', '20251223 08:38:49', 1, 110.87, N'Ship to 62-B', N'Alameda dos Canàrios, 9012', N'Sao Paulo', N'SP', N'10277', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10787, 41, 2, '20251219 16:37:22', '20260102 17:02:18', '20251226 13:00:46', 1, 249.93, N'Destination DWJIO', N'9012 rue Alsace-Lorraine', N'Toulouse', NULL, N'10217', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10788, 63, 1, '20251222 11:48:33', '20260119 15:18:43', '20260119 09:52:28', 2, 42.70, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10789, 23, 1, '20251222 16:22:10', '20260119 12:24:39', '20251231 12:20:42', 2, 100.60, N'Destination PXQRR', N'5678, chaussée de Tournai', N'Lille', NULL, N'10163', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10790, 31, 6, '20251222 17:14:54', '20260119 12:46:56', '20251226 11:30:06', 1, 28.23, N'Destination XOIGC', N'Av. Brasil, 8901', N'Campinas', N'SP', N'10186', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10791, 25, 6, '20251223 15:13:21', '20260120 16:20:21', '20260101 08:06:12', 2, 16.85, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10792, 91, 1, '20251223 09:01:35', '20260120 13:39:09', '20251231 12:23:06', 3, 23.79, N'Ship to 91-C', N'ul. Filtrowa 7890', N'Warszawa', NULL, N'10366', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10793, 4, 3, '20251224 08:52:53', '20260121 14:18:59', '20260108 13:06:47', 3, 4.52, N'Ship to 4-B', N'Brook Farm Stratford St. Mary 1234', N'Colchester', N'Essex', N'10239', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10794, 61, 6, '20251224 16:54:56', '20260121 13:39:59', '20260102 08:48:18', 1, 21.49, N'Ship to 61-C', N'Rua da Panificadora, 7890', N'Rio de Janeiro', N'RJ', N'10275', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10795, 20, 8, '20251224 12:34:52', '20260121 16:40:10', '20260120 16:14:19', 2, 126.66, N'Destination FFXKT', N'Kirchgasse 0123', N'Graz', NULL, N'10158', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10796, 35, 3, '20251225 09:51:29', '20260122 12:01:24', '20260114 17:01:37', 1, 26.52, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10797, 17, 7, '20251225 17:41:39', '20260122 11:11:17', '20260105 14:35:10', 2, 33.35, N'Destination AJTHX', N'Walserweg 9012', N'Aachen', NULL, N'10147', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10798, 38, 2, '20251226 09:57:21', '20260123 09:59:17', '20260105 12:06:07', 1, 2.33, N'Destination AXVHD', N'Garden House Crowther Way 9012', N'Cowes', N'Isle of Wight', N'10207', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10799, 39, 9, '20251226 12:42:44', '20260206 15:23:55', '20260105 14:44:34', 3, 30.76, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10800, 72, 1, '20251226 15:09:38', '20260123 12:45:44', '20260105 12:51:57', 3, 137.44, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10801, 8, 4, '20251229 11:40:09', '20260126 13:08:40', '20251231 13:34:58', 2, 97.09, N'Ship to 8-C', N'C/ Araquil, 1234', N'Madrid', NULL, N'10360', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10802, 73, 4, '20251229 14:52:57', '20260126 08:57:28', '20260102 09:56:36', 2, 257.26, N'Ship to 73-A', N'Vinbæltet 1234', N'Kobenhavn', NULL, N'10310', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10803, 88, 4, '20251230 16:32:30', '20260127 08:43:33', '20260106 11:12:44', 1, 55.23, N'Ship to 88-B', N'Rua do Mercado, 5678', N'Resende', N'SP', N'10354', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10804, 72, 6, '20251230 11:01:40', '20260127 10:12:21', '20260107 08:31:37', 2, 27.33, N'Ship to 72-C', N'1234 Wadhurst Rd.', N'London', NULL, N'10309', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10805, 77, 2, '20251230 15:09:24', '20260127 14:02:29', '20260109 17:09:40', 3, 237.34, N'Ship to 77-A', N'1234 Jefferson Way Suite 2', N'Portland', N'OR', N'10320', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10806, 84, 3, '20251231 14:12:36', '20260128 08:05:16', '20260105 12:02:08', 2, 22.11, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10807, 27, 4, '20251231 12:15:17', '20260128 08:46:48', '20260130 16:57:56', 1, 1.36, N'Destination XNLFB', N'Via Monte Bianco 5678', N'Torino', NULL, N'10173', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10808, 55, 2, '20260101 14:53:25', '20260129 15:50:46', '20260109 11:52:45', 3, 45.53, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10809, 88, 7, '20260101 14:29:20', '20260129 17:02:07', '20260107 12:59:40', 1, 4.87, N'Ship to 88-C', N'Rua do Mercado, 6789', N'Resende', N'SP', N'10355', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10810, 42, 2, '20260101 11:19:27', '20260129 10:30:19', '20260107 12:13:55', 3, 4.33, N'Ship to 42-A', N'1234 Elm St.', N'Vancouver', N'BC', N'10219', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10811, 47, 8, '20260102 17:08:31', '20260130 10:05:21', '20260108 12:45:51', 1, 31.22, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10812, 66, 5, '20260102 12:37:06', '20260130 13:19:11', '20260112 17:56:09', 1, 59.78, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10813, 67, 1, '20260105 08:10:35', '20260202 08:40:10', '20260109 17:44:28', 1, 47.38, N'Ship to 67-C', N'Av. Copacabana, 5678', N'Rio de Janeiro', N'RJ', N'10293', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10814, 84, 3, '20260105 16:43:46', '20260202 17:47:46', '20260114 09:11:59', 3, 130.94, N'Ship to 84-B', N'4567, rue du Commerce', N'Lyon', NULL, N'10343', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10815, 71, 2, '20260105 14:37:48', '20260202 14:02:54', '20260114 16:20:27', 3, 14.62, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10816, 32, 4, '20260106 12:19:35', '20260203 08:33:31', '20260204 12:08:18', 2, 719.78, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10817, 39, 3, '20260106 12:09:01', '20260120 17:40:51', '20260113 12:34:15', 2, 306.07, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10818, 49, 7, '20260107 17:30:38', '20260204 16:55:20', '20260112 11:55:59', 3, 65.48, N'Ship to 49-B', N'Via Ludovico il Moro 9012', N'Bergamo', NULL, N'10236', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10819, 12, 2, '20260107 14:28:48', '20260204 09:48:05', '20260116 17:29:27', 3, 19.76, N'Destination QTHBC', N'Cerrito 6789', N'Buenos Aires', NULL, N'10134', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10820, 65, 3, '20260107 10:41:46', '20260204 15:27:06', '20260113 10:44:16', 2, 37.52, N'Ship to 65-B', N'8901 Milton Dr.', N'Albuquerque', N'NM', N'10286', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10821, 75, 1, '20260108 10:28:08', '20260205 12:43:27', '20260115 14:23:29', 1, 36.68, N'Ship to 75-A', N'P.O. Box 5678', N'Lander', N'WY', N'10314', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10822, 82, 6, '20260108 16:55:08', '20260205 17:57:11', '20260116 08:25:38', 3, 7.00, N'Ship to 82-B', N'9012 DaVinci Blvd.', N'Kirkland', N'WA', N'10338', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10823, 46, 5, '20260109 15:42:30', '20260206 16:30:50', '20260113 08:23:09', 2, 163.97, N'Ship to 46-A', N'Carrera 0123 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10227', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10824, 24, 8, '20260109 10:42:02', '20260206 09:50:30', '20260130 09:44:03', 1, 1.23, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10825, 17, 1, '20260109 15:32:47', '20260206 12:24:19', '20260114 11:51:41', 1, 79.25, N'Destination BJCXA', N'Walserweg 7890', N'Aachen', NULL, N'10145', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10826, 7, 6, '20260112 16:04:57', '20260209 08:20:02', '20260206 11:54:23', 1, 7.09, N'Ship to 7-C', N'2345, place Kléber', N'Strasbourg', NULL, N'10331', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10827, 9, 1, '20260112 08:50:53', '20260126 15:09:30', '20260206 08:01:24', 2, 63.54, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10828, 64, 9, '20260113 11:55:04', '20260127 16:30:20', '20260204 14:44:37', 1, 90.85, N'Ship to 64-B', N'Av. del Libertador 5678', N'Buenos Aires', NULL, N'10283', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10829, 38, 9, '20260113 15:13:02', '20260210 16:12:28', '20260123 08:21:26', 1, 154.72, N'Destination QVTLW', N'Garden House Crowther Way 7890', N'Cowes', N'Isle of Wight', N'10205', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10830, 81, 4, '20260113 13:48:47', '20260224 08:57:25', '20260121 08:46:37', 2, 81.83, N'Ship to 81-C', N'Av. Inês de Castro, 7890', N'Sao Paulo', N'SP', N'10336', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10831, 70, 3, '20260114 10:24:53', '20260211 13:53:21', '20260123 17:23:38', 2, 72.19, N'Ship to 70-B', N'Erling Skakkes gate 5678', N'Stavern', NULL, N'10303', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10832, 41, 2, '20260114 11:53:54', '20260211 14:34:59', '20260119 13:49:55', 2, 43.26, N'Ship to 41-C', N'0123 rue Alsace-Lorraine', N'Toulouse', NULL, N'10218', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10833, 56, 6, '20260115 12:54:48', '20260212 13:13:24', '20260123 09:25:08', 2, 71.49, N'Ship to 56-B', N'Mehrheimerstr. 1234', N'Köln', NULL, N'10259', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10834, 81, 1, '20260115 10:28:40', '20260212 17:40:25', '20260119 08:50:03', 3, 29.78, N'Ship to 81-A', N'Av. Inês de Castro, 6789', N'Sao Paulo', N'SP', N'10335', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10835, 1, 1, '20260115 16:35:41', '20260212 17:04:43', '20260121 10:18:41', 3, 69.53, N'Destination LOUIE', N'Obere Str. 6789', N'Berlin', NULL, N'10154', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10836, 20, 7, '20260116 11:12:48', '20260213 10:48:08', '20260121 13:35:44', 1, 411.88, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10837, 5, 9, '20260116 09:08:17', '20260213 10:03:07', '20260123 15:10:05', 3, 13.32, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10838, 47, 3, '20260119 11:52:06', '20260216 15:49:10', '20260123 16:23:02', 3, 59.28, N'Ship to 47-A', N'Ave. 5 de Mayo Porlamar 3456', N'I. de Margarita', N'Nueva Esparta', N'10230', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10839, 81, 3, '20260119 08:29:34', '20260216 17:57:54', '20260122 15:18:39', 3, 35.43, N'Ship to 81-C', N'Av. Inês de Castro, 7890', N'Sao Paulo', N'SP', N'10336', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10840, 47, 4, '20260119 17:08:32', '20260302 08:57:42', '20260216 15:45:11', 2, 2.71, N'Ship to 47-A', N'Ave. 5 de Mayo Porlamar 3456', N'I. de Margarita', N'Nueva Esparta', N'10230', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10841, 76, 5, '20260120 10:00:35', '20260217 16:22:09', '20260129 09:15:48', 2, 424.30, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10842, 80, 1, '20260120 16:26:59', '20260217 17:59:33', '20260129 12:15:29', 3, 54.42, N'Ship to 80-A', N'Avda. Azteca 3456', N'México D.F.', NULL, N'10332', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10843, 84, 4, '20260121 08:54:18', '20260218 14:43:52', '20260126 14:38:52', 2, 9.26, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10844, 59, 8, '20260121 10:04:20', '20260218 10:25:53', '20260126 10:53:50', 2, 25.22, N'Ship to 59-A', N'Geislweg 6789', N'Salzburg', NULL, N'10264', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10845, 63, 8, '20260121 17:35:21', '20260204 09:35:18', '20260130 17:29:00', 1, 212.98, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10846, 76, 2, '20260122 17:09:09', '20260305 11:30:26', '20260123 13:41:31', 3, 56.46, N'Ship to 76-C', N'Boulevard Tirou, 0123', N'Charleroi', NULL, N'10319', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10847, 71, 4, '20260122 09:04:03', '20260205 11:16:14', '20260210 15:48:54', 3, 487.57, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10848, 16, 7, '20260123 09:30:18', '20260220 12:11:25', '20260129 14:38:43', 2, 38.24, N'Destination QKQNB', N'Berkeley Gardens 5678  Brewery', N'London', NULL, N'10143', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10849, 39, 9, '20260123 11:20:07', '20260220 14:00:20', '20260130 15:24:43', 2, 0.56, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10850, 84, 1, '20260123 12:21:40', '20260306 11:55:55', '20260130 13:59:28', 1, 49.19, N'Ship to 84-C', N'5678, rue du Commerce', N'Lyon', NULL, N'10344', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10851, 67, 5, '20260126 10:38:27', '20260223 17:04:29', '20260202 16:53:06', 1, 160.55, N'Ship to 67-C', N'Av. Copacabana, 5678', N'Rio de Janeiro', N'RJ', N'10293', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10852, 65, 8, '20260126 11:08:50', '20260209 09:14:38', '20260130 13:56:43', 1, 174.05, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10853, 6, 9, '20260127 17:45:21', '20260224 09:20:19', '20260203 15:48:05', 2, 53.83, N'Ship to 6-B', N'Forsterstr. 3456', N'Mannheim', NULL, N'10301', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10854, 20, 3, '20260127 12:00:49', '20260224 12:35:06', '20260205 11:22:35', 2, 100.22, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10855, 55, 3, '20260127 09:13:47', '20260224 11:03:34', '20260204 13:41:46', 1, 170.97, N'Ship to 55-A', N'7890 Bering St.', N'Anchorage', N'AK', N'10255', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10856, 3, 3, '20260128 10:31:04', '20260225 16:22:44', '20260210 16:09:42', 2, 58.43, N'Destination FQFLS', N'Mataderos  3456', N'México D.F.', NULL, N'10211', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10857, 5, 8, '20260128 11:04:37', '20260225 14:22:56', '20260206 08:02:22', 2, 188.85, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10858, 40, 2, '20260129 08:17:18', '20260226 11:23:45', '20260203 12:43:20', 1, 52.51, N'Destination POAEW', N'7890, avenue de l''Europe', N'Versailles', NULL, N'10215', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10859, 25, 1, '20260129 09:03:21', '20260226 10:22:43', '20260202 10:54:52', 2, 76.10, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10860, 26, 3, '20260129 16:25:37', '20260226 15:01:35', '20260204 13:21:29', 3, 19.26, N'Destination XBVKN', N'3456, rue Royale', N'Nantes', NULL, N'10171', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10861, 89, 4, '20260130 12:36:04', '20260227 17:09:21', '20260217 13:43:06', 2, 14.93, N'Ship to 89-C', N'9012 - 12th Ave. S.', N'Seattle', N'WA', N'10358', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10862, 44, 8, '20260130 08:24:45', '20260313 15:12:06', '20260202 14:11:45', 2, 53.23, N'Ship to 44-C', N'Magazinweg 6789', N'Frankfurt a.M.', NULL, N'10224', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10863, 35, 4, '20260202 14:44:11', '20260302 16:02:59', '20260217 12:28:01', 2, 30.26, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10864, 4, 4, '20260202 08:56:37', '20260302 11:13:23', '20260209 11:14:43', 2, 3.04, N'Ship to 4-C', N'Brook Farm Stratford St. Mary 2345', N'Colchester', N'Essex', N'10240', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10865, 63, 2, '20260202 15:28:04', '20260216 11:47:26', '20260212 12:15:10', 1, 348.14, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10866, 5, 5, '20260203 12:04:27', '20260303 14:31:40', '20260212 08:34:39', 1, 109.11, N'Ship to 5-B', N'Berguvsvägen  0123', N'Luleå', NULL, N'10268', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10867, 48, 6, '20260203 10:44:25', '20260317 16:24:32', '20260211 15:37:33', 1, 1.93, N'Ship to 48-B', N'6789 Chiaroscuro Rd.', N'Portland', N'OR', N'10233', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10868, 62, 7, '20260204 08:43:57', '20260304 09:10:46', '20260223 08:16:58', 2, 191.27, N'Ship to 62-C', N'Alameda dos Canàrios, 0123', N'Sao Paulo', N'SP', N'10278', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10869, 72, 5, '20260204 09:20:27', '20260304 17:12:08', '20260209 12:25:05', 1, 143.28, N'Ship to 72-A', N'0123 Wadhurst Rd.', N'London', NULL, N'10308', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10870, 91, 5, '20260204 08:23:33', '20260304 10:09:38', '20260213 17:20:12', 3, 12.04, N'Ship to 91-A', N'ul. Filtrowa 5678', N'Warszawa', NULL, N'10364', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10871, 9, 9, '20260205 16:46:34', '20260305 17:27:04', '20260210 15:36:18', 2, 112.27, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10872, 30, 5, '20260205 17:48:46', '20260305 08:50:12', '20260209 09:24:15', 2, 175.32, N'Destination GGQIR', N'C/ Romero, 6789', N'Sevilla', NULL, N'10184', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10873, 90, 4, '20260206 16:42:36', '20260306 15:20:27', '20260209 16:48:28', 1, 0.82, N'Ship to 90-B', N'Keskuskatu 3456', N'Helsinki', NULL, N'10362', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10874, 30, 5, '20260206 14:26:35', '20260306 15:06:34', '20260211 12:15:50', 2, 19.58, N'Destination IIYDD', N'C/ Romero, 5678', N'Sevilla', NULL, N'10183', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10875, 5, 4, '20260206 14:23:43', '20260306 16:59:24', '20260303 13:15:12', 2, 32.37, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10876, 9, 7, '20260209 08:29:01', '20260309 17:15:42', '20260212 11:56:31', 3, 60.42, N'Ship to 9-A', N'8901, rue des Bouchers', N'Marseille', NULL, N'10367', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10877, 67, 1, '20260209 08:41:11', '20260309 17:52:18', '20260219 17:56:49', 1, 38.06, N'Ship to 67-B', N'Av. Copacabana, 4567', N'Rio de Janeiro', N'RJ', N'10292', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10878, 63, 4, '20260210 09:56:42', '20260310 16:30:35', '20260212 08:35:13', 1, 46.69, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10879, 90, 3, '20260210 14:23:24', '20260310 12:34:54', '20260212 09:17:56', 3, 8.50, N'Ship to 90-A', N'Keskuskatu 2345', N'Helsinki', NULL, N'10361', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10880, 24, 7, '20260210 10:21:14', '20260324 16:09:55', '20260218 11:09:59', 1, 88.01, N'Destination KBSBN', N'Åkergatan 9012', N'Bräcke', NULL, N'10167', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10881, 12, 4, '20260211 10:05:55', '20260311 09:53:24', '20260218 15:02:25', 1, 2.84, N'Destination IGLOB', N'Cerrito 7890', N'Buenos Aires', NULL, N'10135', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10882, 71, 4, '20260211 14:34:51', '20260311 15:22:20', '20260220 16:29:58', 3, 23.10, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10883, 48, 8, '20260212 11:16:08', '20260312 11:27:44', '20260220 15:56:42', 3, 0.53, N'Ship to 48-C', N'7890 Chiaroscuro Rd.', N'Portland', N'OR', N'10234', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10884, 45, 4, '20260212 12:06:19', '20260312 17:39:30', '20260213 09:28:32', 2, 90.97, N'Ship to 45-C', N'9012 Polk St. Suite 5', N'San Francisco', N'CA', N'10226', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10885, 76, 6, '20260212 10:45:09', '20260312 17:52:32', '20260218 09:11:18', 3, 5.64, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10886, 34, 1, '20260213 12:25:29', '20260313 10:24:26', '20260302 10:27:29', 1, 4.99, N'Destination SCQXA', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10195', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10887, 29, 8, '20260213 17:19:04', '20260313 16:25:45', '20260216 16:16:46', 3, 1.25, N'Destination VPNNG', N'Rambla de Cataluña, 0123', N'Barcelona', NULL, N'10178', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10888, 30, 1, '20260216 12:34:58', '20260316 09:40:05', '20260223 14:14:56', 2, 51.87, N'Destination IIYDD', N'C/ Romero, 5678', N'Sevilla', NULL, N'10183', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10889, 65, 9, '20260216 15:39:34', '20260316 12:48:07', '20260223 11:33:00', 3, 280.61, N'Ship to 65-C', N'9012 Milton Dr.', N'Albuquerque', N'NM', N'10287', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10890, 18, 7, '20260216 11:14:06', '20260316 08:45:10', '20260218 12:14:32', 1, 32.76, N'Destination JNSYI', N'1234, rue des Cinquante Otages', N'Nantes', NULL, N'10149', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10891, 44, 7, '20260217 16:23:39', '20260317 16:20:17', '20260219 11:30:32', 2, 20.37, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10892, 50, 4, '20260217 10:51:37', '20260317 08:14:51', '20260219 11:41:51', 2, 120.27, N'Ship to 50-A', N'Rue Joseph-Bens 3456', N'Bruxelles', NULL, N'10241', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10893, 39, 9, '20260218 15:54:22', '20260318 14:22:23', '20260220 10:06:55', 2, 77.78, N'Destination RMBHM', N'Maubelstr. 1234', N'Brandenburg', NULL, N'10209', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10894, 71, 1, '20260218 12:07:32', '20260318 08:18:06', '20260220 13:02:30', 1, 116.13, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10895, 20, 3, '20260218 12:48:08', '20260318 12:24:46', '20260223 12:17:34', 1, 162.75, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10896, 50, 7, '20260219 10:19:52', '20260319 13:42:25', '20260227 09:34:46', 3, 32.45, N'Ship to 50-A', N'Rue Joseph-Bens 3456', N'Bruxelles', NULL, N'10241', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10897, 37, 3, '20260219 10:47:17', '20260319 08:09:07', '20260225 14:22:10', 2, 603.54, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10898, 54, 4, '20260220 09:49:01', '20260320 14:25:27', '20260306 15:36:35', 2, 1.27, N'Ship to 54-B', N'Ing. Gustavo Moncada 5678 Piso 20-A', N'Buenos Aires', NULL, N'10253', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10899, 46, 5, '20260220 17:56:25', '20260320 13:39:07', '20260226 12:41:25', 3, 1.21, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10900, 88, 1, '20260220 15:27:48', '20260320 14:23:08', '20260304 09:39:16', 2, 1.66, N'Ship to 88-A', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10353', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10901, 35, 4, '20260223 09:33:53', '20260323 09:24:22', '20260226 14:18:09', 1, 62.09, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10902, 24, 1, '20260223 16:18:25', '20260323 17:01:47', '20260303 11:23:06', 1, 44.15, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10903, 34, 3, '20260224 14:46:47', '20260324 08:25:26', '20260304 13:31:36', 3, 36.71, N'Destination DPCVR', N'Rua do Paço, 6789', N'Rio de Janeiro', N'RJ', N'10194', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10904, 89, 3, '20260224 08:25:35', '20260324 15:52:01', '20260227 15:06:12', 3, 162.95, N'Ship to 89-A', N'7890 - 12th Ave. S.', N'Seattle', N'WA', N'10356', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10905, 88, 9, '20260224 08:15:08', '20260324 14:15:02', '20260306 16:24:58', 2, 13.72, N'Ship to 88-A', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10353', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10906, 91, 4, '20260225 09:21:07', '20260311 09:06:25', '20260303 12:56:05', 3, 26.29, N'Ship to 91-B', N'ul. Filtrowa 6789', N'Warszawa', NULL, N'10365', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10907, 74, 6, '20260225 17:42:52', '20260325 15:43:24', '20260227 13:28:18', 3, 9.19, N'Ship to 74-B', N'4567, rue Lauriston', N'Paris', NULL, N'10313', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10908, 66, 4, '20260226 09:12:16', '20260326 12:31:34', '20260306 14:41:15', 2, 32.96, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10909, 70, 1, '20260226 17:28:17', '20260326 09:41:24', '20260310 17:28:11', 2, 53.05, N'Ship to 70-C', N'Erling Skakkes gate 6789', N'Stavern', NULL, N'10304', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10910, 90, 1, '20260226 10:55:25', '20260326 15:01:58', '20260304 17:30:24', 3, 38.11, N'Ship to 90-A', N'Keskuskatu 2345', N'Helsinki', NULL, N'10361', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10911, 30, 3, '20260226 13:33:07', '20260326 10:52:50', '20260305 17:45:17', 1, 38.19, N'Destination IIYDD', N'C/ Romero, 5678', N'Sevilla', NULL, N'10183', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10912, 37, 2, '20260226 12:55:51', '20260326 10:23:24', '20260318 09:44:42', 2, 580.91, N'Destination DGKOU', N'6789 Johnstown Road', N'Cork', N'Co. Cork', N'10204', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10913, 62, 4, '20260226 12:47:06', '20260326 16:18:08', '20260304 17:08:45', 1, 33.05, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10914, 62, 6, '20260227 11:27:00', '20260327 13:48:12', '20260302 08:46:07', 1, 21.19, N'Ship to 62-B', N'Alameda dos Canàrios, 9012', N'Sao Paulo', N'SP', N'10277', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10915, 80, 2, '20260227 10:17:35', '20260327 16:45:52', '20260302 14:24:01', 2, 3.51, N'Ship to 80-C', N'Avda. Azteca 5678', N'México D.F.', NULL, N'10334', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10916, 64, 1, '20260227 14:47:43', '20260327 12:56:29', '20260309 11:23:46', 2, 63.77, N'Ship to 64-C', N'Av. del Libertador 6789', N'Buenos Aires', NULL, N'10284', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10917, 69, 4, '20260302 17:09:27', '20260330 15:03:03', '20260311 13:05:12', 2, 8.29, N'Ship to 69-C', N'Gran Vía, 1234', N'Madrid', NULL, N'10299', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10918, 10, 3, '20260302 14:06:21', '20260330 16:58:26', '20260311 12:39:24', 3, 48.83, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10919, 47, 2, '20260302 09:34:58', '20260330 09:42:05', '20260304 11:19:56', 2, 19.80, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10920, 4, 4, '20260303 17:11:33', '20260331 14:12:20', '20260309 08:01:57', 2, 29.61, N'Ship to 4-A', N'Brook Farm Stratford St. Mary 0123', N'Colchester', N'Essex', N'10238', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10921, 83, 1, '20260303 08:22:50', '20260414 17:40:24', '20260309 12:27:56', 1, 176.48, N'Ship to 83-A', N'Smagsloget 0123', N'Århus', NULL, N'10339', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10922, 34, 5, '20260303 10:44:39', '20260331 16:09:56', '20260305 16:13:56', 3, 62.74, N'Destination DPCVR', N'Rua do Paço, 6789', N'Rio de Janeiro', N'RJ', N'10194', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10923, 41, 7, '20260303 12:15:58', '20260414 14:35:26', '20260313 17:19:30', 3, 68.26, N'Destination OLJND', N'8901 rue Alsace-Lorraine', N'Toulouse', NULL, N'10216', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10924, 5, 3, '20260304 08:46:55', '20260401 09:14:02', '20260408 14:55:49', 2, 151.52, N'Ship to 5-A', N'Berguvsvägen  9012', N'Luleå', NULL, N'10267', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10925, 34, 3, '20260304 08:01:06', '20260401 16:17:33', '20260313 14:39:57', 1, 2.27, N'Destination JPAIY', N'Rua do Paço, 8901', N'Rio de Janeiro', N'RJ', N'10196', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10926, 2, 4, '20260304 14:18:40', '20260401 16:45:05', '20260311 11:25:34', 3, 39.92, N'Destination RAIGI', N'Avda. de la Constitución 4567', N'México D.F.', NULL, N'10182', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10927, 40, 4, '20260305 08:58:25', '20260402 11:41:31', '20260408 16:26:24', 1, 19.79, N'Destination WWJLO', N'6789, avenue de l''Europe', N'Versailles', NULL, N'10214', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10928, 29, 1, '20260305 12:28:55', '20260402 13:44:54', '20260318 14:06:23', 1, 1.36, N'Destination WOFLH', N'Rambla de Cataluña, 1234', N'Barcelona', NULL, N'10179', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10929, 25, 6, '20260305 17:50:18', '20260402 12:31:12', '20260312 15:49:59', 1, 33.93, N'Destination QOCBL', N'Berliner Platz 1234', N'München', NULL, N'10169', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10930, 76, 4, '20260306 17:26:07', '20260417 09:48:28', '20260318 14:02:34', 3, 15.55, N'Ship to 76-A', N'Boulevard Tirou, 8901', N'Charleroi', NULL, N'10317', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10931, 68, 4, '20260306 10:17:09', '20260320 14:52:47', '20260319 11:36:06', 2, 13.60, N'Ship to 68-B', N'Starenweg 7890', N'Genève', NULL, N'10295', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10932, 9, 8, '20260306 10:24:11', '20260403 11:46:33', '20260324 12:34:29', 1, 134.64, N'Ship to 9-B', N'9012, rue des Bouchers', N'Marseille', NULL, N'10368', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10933, 38, 6, '20260306 15:10:56', '20260403 09:43:32', '20260316 11:42:25', 3, 54.15, N'Destination QVTLW', N'Garden House Crowther Way 7890', N'Cowes', N'Isle of Wight', N'10205', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10934, 44, 3, '20260309 12:15:18', '20260406 11:50:30', '20260312 15:11:31', 3, 32.01, N'Ship to 44-C', N'Magazinweg 6789', N'Frankfurt a.M.', NULL, N'10224', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10935, 88, 4, '20260309 14:33:29', '20260406 15:54:16', '20260318 10:21:48', 3, 47.59, N'Ship to 88-A', N'Rua do Mercado, 4567', N'Resende', N'SP', N'10353', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10936, 32, 3, '20260309 12:02:50', '20260406 11:48:17', '20260318 15:05:43', 2, 33.68, N'Destination AVQUS', N'2345 Baker Blvd.', N'Eugene', N'OR', N'10190', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10937, 12, 7, '20260310 10:40:29', '20260324 13:08:37', '20260313 08:02:30', 3, 31.51, N'Destination QTHBC', N'Cerrito 6789', N'Buenos Aires', NULL, N'10134', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10938, 63, 3, '20260310 09:28:19', '20260407 11:24:40', '20260316 14:19:55', 2, 31.89, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10939, 49, 2, '20260310 08:04:09', '20260407 08:02:57', '20260313 10:52:17', 2, 76.33, N'Ship to 49-A', N'Via Ludovico il Moro 8901', N'Bergamo', NULL, N'10235', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10940, 9, 8, '20260311 08:09:56', '20260408 11:21:51', '20260323 13:12:43', 3, 19.77, N'Ship to 9-C', N'0123, rue des Bouchers', N'Marseille', NULL, N'10369', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10941, 71, 7, '20260311 08:37:57', '20260408 10:21:24', '20260320 09:32:32', 2, 400.81, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10942, 66, 9, '20260311 12:55:41', '20260408 12:31:19', '20260318 11:35:44', 3, 17.95, N'Ship to 66-C', N'Strada Provinciale 2345', N'Reggio Emilia', NULL, N'10290', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10943, 11, 4, '20260311 13:11:50', '20260408 17:39:50', '20260319 09:39:00', 2, 2.17, N'Destination NZASL', N'Fauntleroy Circus 5678', N'London', NULL, N'10133', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10944, 10, 6, '20260312 16:24:01', '20260326 14:02:57', '20260313 13:32:34', 3, 52.92, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10945, 52, 4, '20260312 09:42:39', '20260409 17:07:49', '20260318 17:18:41', 1, 10.22, N'Ship to 52-B', N'Heerstr. 0123', N'Leipzig', NULL, N'10248', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10946, 83, 1, '20260312 08:38:32', '20260409 15:54:45', '20260319 15:49:22', 2, 27.20, N'Ship to 83-B', N'Smagsloget 1234', N'Århus', NULL, N'10340', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10947, 11, 3, '20260313 09:44:58', '20260410 08:26:59', '20260316 11:01:23', 2, 3.26, N'Destination NZASL', N'Fauntleroy Circus 5678', N'London', NULL, N'10133', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10948, 30, 3, '20260313 08:19:19', '20260410 16:36:07', '20260319 11:46:00', 3, 23.39, N'Destination GGQIR', N'C/ Romero, 6789', N'Sevilla', NULL, N'10184', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10949, 10, 2, '20260313 10:23:16', '20260410 15:38:03', '20260317 10:06:10', 3, 74.44, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10950, 49, 1, '20260316 10:31:47', '20260413 11:04:24', '20260323 12:30:15', 2, 2.50, N'Ship to 49-B', N'Via Ludovico il Moro 9012', N'Bergamo', NULL, N'10236', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10951, 68, 9, '20260316 15:31:51', '20260427 14:36:49', '20260407 17:56:51', 2, 30.85, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10952, 1, 1, '20260316 08:04:24', '20260427 12:02:36', '20260324 08:10:14', 1, 40.42, N'Destination LOUIE', N'Obere Str. 6789', N'Berlin', NULL, N'10154', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10953, 4, 9, '20260316 17:25:03', '20260330 17:11:48', '20260325 11:31:17', 2, 23.72, N'Ship to 4-B', N'Brook Farm Stratford St. Mary 1234', N'Colchester', N'Essex', N'10239', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10954, 47, 5, '20260317 15:55:07', '20260428 15:40:51', '20260320 17:05:53', 1, 27.91, N'Ship to 47-B', N'Ave. 5 de Mayo Porlamar 4567', N'I. de Margarita', N'Nueva Esparta', N'10231', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10955, 24, 8, '20260317 15:29:20', '20260414 16:06:01', '20260320 11:06:50', 2, 3.26, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10956, 6, 6, '20260317 10:05:07', '20260428 08:45:59', '20260320 17:27:12', 2, 44.65, N'Ship to 6-B', N'Forsterstr. 3456', N'Mannheim', NULL, N'10301', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10957, 35, 8, '20260318 15:14:15', '20260415 08:29:12', '20260327 10:59:42', 3, 105.36, N'Destination UOUWK', N'Carrera 9012 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10197', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10958, 54, 7, '20260318 10:34:22', '20260415 14:10:16', '20260327 10:55:50', 2, 49.56, N'Ship to 54-C', N'Ing. Gustavo Moncada 6789 Piso 20-A', N'Buenos Aires', NULL, N'10254', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10959, 31, 6, '20260318 13:06:36', '20260429 14:30:40', '20260323 09:55:12', 2, 4.98, N'Destination GWPFK', N'Av. Brasil, 0123', N'Campinas', N'SP', N'10188', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10960, 35, 3, '20260319 15:02:06', '20260402 11:49:46', '20260408 12:38:42', 1, 2.08, N'Destination SXYQX', N'Carrera 0123 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10198', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10961, 62, 8, '20260319 14:44:19', '20260416 08:27:42', '20260330 10:28:53', 1, 104.47, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10962, 63, 8, '20260319 08:29:29', '20260416 12:55:54', '20260323 16:43:18', 2, 275.79, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10963, 28, 9, '20260319 09:26:27', '20260416 11:29:26', '20260326 10:20:15', 3, 2.70, N'Destination CIRQO', N'Jardim das rosas n. 8901', N'Lisboa', NULL, N'10176', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10964, 74, 3, '20260320 14:28:26', '20260417 11:42:32', '20260324 10:33:54', 2, 87.38, N'Ship to 74-B', N'4567, rue Lauriston', N'Paris', NULL, N'10313', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10965, 55, 6, '20260320 13:14:12', '20260417 08:43:38', '20260330 09:59:00', 3, 144.38, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10966, 14, 4, '20260320 12:50:40', '20260417 17:21:51', '20260408 15:54:04', 1, 27.19, N'Destination NRTZZ', N'Hauptstr. 0123', N'Bern', NULL, N'10138', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10967, 79, 2, '20260323 17:42:21', '20260420 09:36:38', '20260402 16:18:35', 2, 62.22, N'Ship to 79-B', N'Luisenstr. 8901', N'Münster', NULL, N'10327', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10968, 20, 1, '20260323 16:04:09', '20260420 16:26:06', '20260401 11:15:49', 3, 74.60, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10969, 15, 1, '20260323 14:21:38', '20260420 15:11:00', '20260330 14:12:21', 2, 0.21, N'Destination EVHYA', N'Av. dos Lusíadas, 3456', N'Sao Paulo', N'SP', N'10141', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10970, 8, 9, '20260324 16:54:35', '20260407 17:21:07', '20260424 15:41:12', 1, 16.16, N'Ship to 8-C', N'C/ Araquil, 1234', N'Madrid', NULL, N'10360', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10971, 26, 2, '20260324 17:37:27', '20260421 16:06:54', '20260402 14:15:37', 2, 121.82, N'Destination XBVKN', N'3456, rue Royale', N'Nantes', NULL, N'10171', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10972, 40, 4, '20260324 12:34:35', '20260421 10:37:34', '20260326 13:27:43', 2, 0.02, N'Destination MVTWX', N'5678, avenue de l''Europe', N'Versailles', NULL, N'10213', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10973, 40, 6, '20260324 12:40:20', '20260421 16:54:21', '20260327 14:45:36', 2, 15.17, N'Destination WWJLO', N'6789, avenue de l''Europe', N'Versailles', NULL, N'10214', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10974, 75, 3, '20260325 12:23:33', '20260408 13:23:24', '20260403 10:47:19', 3, 12.96, N'Ship to 75-B', N'P.O. Box 6789', N'Lander', N'WY', N'10315', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10975, 10, 1, '20260325 11:56:39', '20260422 10:10:52', '20260327 11:06:38', 3, 32.27, N'Destination OLSSJ', N'2345 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10130', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10976, 35, 1, '20260325 14:36:49', '20260506 09:11:53', '20260403 12:04:15', 1, 37.97, N'Destination SXYQX', N'Carrera 0123 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10198', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10977, 24, 8, '20260326 13:00:57', '20260423 13:09:51', '20260410 14:17:03', 3, 208.50, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10978, 50, 9, '20260326 13:44:50', '20260423 11:39:20', '20260423 08:11:38', 2, 32.82, N'Ship to 50-A', N'Rue Joseph-Bens 3456', N'Bruxelles', NULL, N'10241', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10979, 20, 8, '20260326 14:02:34', '20260423 17:21:02', '20260331 10:14:52', 2, 353.07, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10980, 24, 4, '20260327 16:26:51', '20260508 13:18:16', '20260417 09:03:06', 1, 1.26, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10981, 34, 1, '20260327 14:38:45', '20260424 08:44:02', '20260402 13:54:58', 2, 193.37, N'Destination JPAIY', N'Rua do Paço, 8901', N'Rio de Janeiro', N'RJ', N'10196', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10982, 10, 2, '20260327 11:05:58', '20260424 16:41:38', '20260408 16:27:29', 1, 14.01, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10983, 71, 2, '20260327 11:08:05', '20260424 11:47:48', '20260406 15:59:26', 2, 657.54, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10984, 71, 1, '20260330 13:41:07', '20260427 13:59:43', '20260403 13:13:47', 3, 211.22, N'Ship to 71-B', N'8901 Suffolk Ln.', N'Boise', N'ID', N'10306', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10985, 37, 2, '20260330 11:06:37', '20260427 10:27:54', '20260402 12:41:37', 1, 91.51, N'Destination ATSOA', N'4567 Johnstown Road', N'Cork', N'Co. Cork', N'10202', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10986, 54, 8, '20260330 15:27:41', '20260427 14:21:32', '20260421 12:03:11', 2, 217.86, N'Ship to 54-A', N'Ing. Gustavo Moncada 4567 Piso 20-A', N'Buenos Aires', NULL, N'10252', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10987, 19, 8, '20260331 08:28:05', '20260428 17:30:10', '20260406 16:49:15', 1, 185.48, N'Destination FRCGJ', N'5678 King George', N'London', NULL, N'10153', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10988, 65, 3, '20260331 15:04:23', '20260428 08:54:08', '20260410 16:27:48', 2, 61.14, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10989, 61, 2, '20260331 09:31:42', '20260428 12:36:08', '20260402 09:31:14', 1, 34.76, N'Ship to 61-A', N'Rua da Panificadora, 5678', N'Rio de Janeiro', N'RJ', N'10273', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10990, 20, 2, '20260401 16:47:02', '20260513 17:24:11', '20260407 12:19:33', 3, 117.61, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10991, 63, 1, '20260401 13:07:45', '20260429 08:15:18', '20260407 16:17:51', 1, 38.51, N'Ship to 63-A', N'Taucherstraße 1234', N'Cunewalde', NULL, N'10279', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10992, 77, 1, '20260401 09:41:17', '20260429 09:18:37', '20260403 11:42:41', 3, 4.27, N'Ship to 77-C', N'3456 Jefferson Way Suite 2', N'Portland', N'OR', N'10322', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10993, 24, 7, '20260401 08:24:48', '20260429 11:41:54', '20260410 11:05:29', 3, 8.81, N'Destination NCKKO', N'Åkergatan 7890', N'Bräcke', NULL, N'10165', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10994, 83, 2, '20260402 11:03:44', '20260416 14:28:28', '20260409 08:47:03', 3, 65.53, N'Ship to 83-C', N'Smagsloget 2345', N'Århus', NULL, N'10341', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10995, 58, 1, '20260402 11:48:00', '20260430 13:33:13', '20260406 12:01:11', 3, 46.00, N'Ship to 58-B', N'Calle Dr. Jorge Cash 4567', N'México D.F.', NULL, N'10262', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10996, 63, 4, '20260402 11:53:59', '20260430 17:51:40', '20260410 11:17:58', 2, 1.12, N'Ship to 63-C', N'Taucherstraße 3456', N'Cunewalde', NULL, N'10281', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10997, 46, 8, '20260403 14:04:42', '20260515 17:37:02', '20260413 16:41:34', 2, 73.91, N'Ship to 46-A', N'Carrera 0123 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10227', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10998, 91, 8, '20260403 08:56:42', '20260417 17:06:28', '20260417 15:35:27', 2, 20.31, N'Ship to 91-A', N'ul. Filtrowa 5678', N'Warszawa', NULL, N'10364', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(10999, 56, 6, '20260403 10:39:42', '20260501 13:14:36', '20260410 11:26:27', 2, 96.35, N'Ship to 56-B', N'Mehrheimerstr. 1234', N'Köln', NULL, N'10259', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11000, 65, 2, '20260406 11:56:42', '20260504 11:30:12', '20260414 17:36:04', 3, 55.12, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11001, 24, 2, '20260406 17:34:41', '20260504 16:10:58', '20260414 13:44:26', 2, 197.30, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11002, 71, 4, '20260406 14:23:37', '20260504 12:28:59', '20260416 17:01:59', 1, 141.16, N'Ship to 71-A', N'7890 Suffolk Ln.', N'Boise', N'ID', N'10305', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11003, 78, 3, '20260406 10:04:51', '20260504 16:04:47', '20260408 12:16:07', 3, 14.91, N'Ship to 78-B', N'5678 Grizzly Peak Rd.', N'Butte', N'MT', N'10324', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11004, 50, 3, '20260407 11:06:23', '20260505 14:48:36', '20260420 10:49:36', 1, 44.84, N'Ship to 50-C', N'Rue Joseph-Bens 5678', N'Bruxelles', NULL, N'10243', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11005, 90, 2, '20260407 11:25:09', '20260505 14:06:03', '20260410 13:11:42', 1, 0.75, N'Ship to 90-A', N'Keskuskatu 2345', N'Helsinki', NULL, N'10361', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11006, 32, 3, '20260407 16:11:06', '20260505 16:01:56', '20260415 14:40:53', 2, 25.19, N'Destination LLUXZ', N'1234 Baker Blvd.', N'Eugene', N'OR', N'10189', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11007, 60, 8, '20260408 09:13:03', '20260506 10:40:41', '20260413 16:39:27', 2, 202.24, N'Ship to 60-C', N'Estrada da saúde n. 4567', N'Lisboa', NULL, N'10272', N'Portugal');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11008, 20, 7, '20260408 11:00:55', '20260506 14:02:22', NULL, 3, 79.46, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11009, 30, 2, '20260408 17:28:12', '20260506 15:27:00', '20260410 08:22:36', 1, 59.11, N'Destination WVLDH', N'C/ Romero, 7890', N'Sevilla', NULL, N'10185', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11010, 66, 2, '20260409 13:58:17', '20260507 09:49:59', '20260421 17:11:48', 2, 28.71, N'Ship to 66-A', N'Strada Provinciale 0123', N'Reggio Emilia', NULL, N'10288', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11011, 1, 3, '20260409 13:28:29', '20260507 15:36:15', '20260413 15:09:03', 1, 1.21, N'Destination LOUIE', N'Obere Str. 6789', N'Berlin', NULL, N'10154', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11012, 25, 1, '20260409 12:59:08', '20260423 11:45:10', '20260417 15:34:47', 3, 242.95, N'Destination WEGWI', N'Berliner Platz 2345', N'München', NULL, N'10170', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11013, 69, 2, '20260409 17:22:19', '20260507 17:11:38', '20260410 12:51:29', 1, 32.99, N'Ship to 69-A', N'Gran Vía, 9012', N'Madrid', NULL, N'10297', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11014, 47, 2, '20260410 14:06:09', '20260508 14:20:11', '20260415 11:27:27', 3, 23.60, N'Ship to 47-A', N'Ave. 5 de Mayo Porlamar 3456', N'I. de Margarita', N'Nueva Esparta', N'10230', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11015, 70, 2, '20260410 10:33:50', '20260424 16:34:30', '20260420 09:01:06', 2, 4.62, N'Ship to 70-C', N'Erling Skakkes gate 6789', N'Stavern', NULL, N'10304', N'Norway');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11016, 4, 9, '20260410 12:29:48', '20260508 12:19:22', '20260413 14:15:28', 2, 33.80, N'Ship to 4-A', N'Brook Farm Stratford St. Mary 0123', N'Colchester', N'Essex', N'10238', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11017, 20, 9, '20260413 17:25:42', '20260511 10:44:48', '20260420 14:48:31', 2, 754.26, N'Destination CUVPF', N'Kirchgasse 1234', N'Graz', NULL, N'10159', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11018, 48, 4, '20260413 15:18:55', '20260511 08:43:08', '20260416 12:09:11', 2, 11.65, N'Ship to 48-B', N'6789 Chiaroscuro Rd.', N'Portland', N'OR', N'10233', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11019, 64, 6, '20260413 12:46:22', '20260511 16:08:18', NULL, 3, 3.17, N'Ship to 64-B', N'Av. del Libertador 5678', N'Buenos Aires', NULL, N'10283', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11020, 56, 2, '20260414 08:34:02', '20260512 17:16:05', '20260416 11:17:20', 2, 43.30, N'Ship to 56-B', N'Mehrheimerstr. 1234', N'Köln', NULL, N'10259', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11021, 63, 3, '20260414 14:03:35', '20260512 11:08:28', '20260421 12:18:37', 1, 297.18, N'Ship to 63-B', N'Taucherstraße 2345', N'Cunewalde', NULL, N'10280', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11022, 34, 9, '20260414 10:04:18', '20260512 16:34:12', '20260504 11:10:08', 2, 6.27, N'Destination SCQXA', N'Rua do Paço, 7890', N'Rio de Janeiro', N'RJ', N'10195', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11023, 11, 1, '20260414 13:32:57', '20260428 08:50:01', '20260424 08:05:33', 2, 123.83, N'Destination NZASL', N'Fauntleroy Circus 5678', N'London', NULL, N'10133', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11024, 19, 4, '20260415 09:05:34', '20260513 16:59:55', '20260420 16:03:27', 1, 74.36, N'Destination BBMRT', N'4567 King George', N'London', NULL, N'10152', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11025, 87, 6, '20260415 08:39:01', '20260513 10:23:58', '20260424 10:40:07', 3, 29.17, N'Ship to 87-C', N'Torikatu 3456', N'Oulu', NULL, N'10352', N'Finland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11026, 27, 4, '20260415 08:16:12', '20260513 17:53:07', '20260428 15:09:46', 1, 47.09, N'Destination DICGM', N'Via Monte Bianco 7890', N'Torino', NULL, N'10175', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11027, 10, 1, '20260416 17:05:57', '20260514 11:22:00', '20260420 11:06:19', 1, 52.52, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11028, 39, 2, '20260416 15:50:57', '20260514 14:51:10', '20260422 13:25:23', 1, 29.59, N'Destination DKMQA', N'Maubelstr. 0123', N'Brandenburg', NULL, N'10208', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11029, 14, 4, '20260416 11:03:15', '20260514 11:17:00', '20260427 09:32:31', 1, 47.84, N'Destination YUJRD', N'Hauptstr. 1234', N'Bern', NULL, N'10139', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11030, 71, 7, '20260417 15:53:18', '20260515 16:20:03', '20260427 15:34:41', 2, 830.75, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11031, 71, 6, '20260417 09:50:40', '20260515 17:02:58', '20260424 14:30:19', 2, 227.22, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11032, 89, 2, '20260417 14:44:28', '20260515 17:10:50', '20260423 13:14:07', 3, 606.19, N'Ship to 89-B', N'8901 - 12th Ave. S.', N'Seattle', N'WA', N'10357', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11033, 68, 7, '20260417 12:53:22', '20260515 14:08:19', '20260423 08:57:14', 3, 84.74, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11034, 55, 8, '20260420 17:08:00', '20260601 17:36:09', '20260427 08:04:22', 1, 40.32, N'Ship to 55-B', N'8901 Bering St.', N'Anchorage', N'AK', N'10256', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11035, 76, 2, '20260420 12:48:47', '20260518 16:23:17', '20260424 13:58:37', 2, 0.17, N'Ship to 76-B', N'Boulevard Tirou, 9012', N'Charleroi', NULL, N'10318', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11036, 17, 8, '20260420 13:18:48', '20260518 17:48:08', '20260422 17:52:25', 3, 149.47, N'Destination YPUYI', N'Walserweg 8901', N'Aachen', NULL, N'10146', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11037, 30, 7, '20260421 11:00:52', '20260519 09:48:14', '20260427 12:55:35', 1, 3.20, N'Destination GGQIR', N'C/ Romero, 6789', N'Sevilla', NULL, N'10184', N'Spain');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11038, 76, 1, '20260421 16:49:33', '20260519 17:24:45', '20260430 08:59:13', 2, 29.59, N'Ship to 76-A', N'Boulevard Tirou, 8901', N'Charleroi', NULL, N'10317', N'Belgium');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11039, 47, 1, '20260421 08:53:00', '20260519 10:21:17', NULL, 2, 65.00, N'Ship to 47-C', N'Ave. 5 de Mayo Porlamar 5678', N'I. de Margarita', N'Nueva Esparta', N'10232', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11040, 32, 4, '20260422 16:54:24', '20260520 10:59:17', NULL, 3, 18.84, N'Destination VYOBK', N'3456 Baker Blvd.', N'Eugene', N'OR', N'10191', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11041, 14, 3, '20260422 16:16:14', '20260520 10:35:58', '20260428 12:53:30', 2, 48.22, N'Destination YUJRD', N'Hauptstr. 1234', N'Bern', NULL, N'10139', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11042, 15, 2, '20260422 11:11:17', '20260506 17:46:18', '20260501 14:25:28', 1, 29.99, N'Destination EVHYA', N'Av. dos Lusíadas, 3456', N'Sao Paulo', N'SP', N'10141', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11043, 74, 5, '20260422 12:34:14', '20260520 12:12:08', '20260429 12:21:09', 2, 8.80, N'Ship to 74-B', N'4567, rue Lauriston', N'Paris', NULL, N'10313', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11044, 91, 4, '20260423 12:03:13', '20260521 12:41:09', '20260501 13:57:58', 1, 8.72, N'Ship to 91-B', N'ul. Filtrowa 6789', N'Warszawa', NULL, N'10365', N'Poland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11045, 10, 6, '20260423 12:40:01', '20260521 09:55:54', NULL, 2, 70.58, N'Destination LPHSI', N'3456 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10131', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11046, 86, 8, '20260423 13:37:58', '20260521 14:42:10', '20260424 17:27:16', 2, 71.64, N'Ship to 86-C', N'Adenauerallee 0123', N'Stuttgart', NULL, N'10349', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11047, 19, 7, '20260424 11:04:02', '20260522 17:16:53', '20260501 17:53:33', 3, 46.62, N'Destination FRCGJ', N'5678 King George', N'London', NULL, N'10153', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11048, 10, 7, '20260424 17:01:27', '20260522 09:18:01', '20260430 08:40:09', 3, 24.12, N'Destination XJIBQ', N'1234 Tsawassen Blvd.', N'Tsawassen', N'BC', N'10129', N'Canada');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11049, 31, 3, '20260424 09:45:18', '20260522 16:25:09', '20260504 17:15:04', 1, 8.34, N'Destination XOIGC', N'Av. Brasil, 8901', N'Campinas', N'SP', N'10186', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11050, 24, 8, '20260427 16:30:36', '20260525 15:17:58', '20260505 09:15:18', 2, 59.41, N'Destination YCMPK', N'Åkergatan 8901', N'Bräcke', NULL, N'10166', N'Sweden');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11051, 41, 7, '20260427 17:49:14', '20260525 13:32:11', NULL, 3, 2.79, N'Destination OLJND', N'8901 rue Alsace-Lorraine', N'Toulouse', NULL, N'10216', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11052, 34, 3, '20260427 08:18:16', '20260525 12:37:53', '20260501 12:05:02', 1, 67.26, N'Destination DPCVR', N'Rua do Paço, 6789', N'Rio de Janeiro', N'RJ', N'10194', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11053, 59, 2, '20260427 13:04:07', '20260525 08:41:14', '20260429 17:51:24', 2, 53.05, N'Ship to 59-A', N'Geislweg 6789', N'Salzburg', NULL, N'10264', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11054, 12, 8, '20260428 16:14:49', '20260526 08:17:14', NULL, 1, 0.33, N'Destination QTHBC', N'Cerrito 6789', N'Buenos Aires', NULL, N'10134', N'Argentina');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11055, 35, 7, '20260428 09:37:09', '20260526 11:02:09', '20260505 11:17:29', 2, 120.92, N'Destination JYDLM', N'Carrera1234 con Ave. Carlos Soublette #8-35', N'San Cristóbal', N'Táchira', N'10199', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11056, 19, 8, '20260428 10:01:03', '20260512 10:27:43', '20260501 17:00:16', 2, 278.96, N'Destination QTKCU', N'3456 King George', N'London', NULL, N'10151', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11057, 53, 3, '20260429 13:56:06', '20260527 14:23:58', '20260501 16:32:04', 3, 4.13, N'Ship to 53-C', N'South House 3456 Queensbridge', N'London', NULL, N'10251', N'UK');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11058, 6, 9, '20260429 13:21:12', '20260527 16:01:12', NULL, 3, 31.14, N'Ship to 6-A', N'Forsterstr. 2345', N'Mannheim', NULL, N'10300', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11059, 67, 2, '20260429 12:38:40', '20260610 16:44:39', NULL, 2, 85.80, N'Ship to 67-A', N'Av. Copacabana, 3456', N'Rio de Janeiro', N'RJ', N'10291', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11060, 27, 2, '20260430 10:23:47', '20260528 09:34:22', '20260504 10:54:18', 2, 10.98, N'Destination DICGM', N'Via Monte Bianco 7890', N'Torino', NULL, N'10175', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11061, 32, 4, '20260430 11:50:44', '20260611 08:54:35', NULL, 3, 14.01, N'Destination VYOBK', N'3456 Baker Blvd.', N'Eugene', N'OR', N'10191', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11062, 66, 4, '20260430 12:47:13', '20260528 10:53:10', NULL, 2, 29.93, N'Ship to 66-B', N'Strada Provinciale 1234', N'Reggio Emilia', NULL, N'10289', N'Italy');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11063, 37, 3, '20260430 10:05:25', '20260528 11:20:11', '20260506 10:58:44', 2, 81.73, N'Destination KPVYJ', N'5678 Johnstown Road', N'Cork', N'Co. Cork', N'10203', N'Ireland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11064, 71, 1, '20260501 09:49:16', '20260529 17:49:30', '20260504 08:27:34', 1, 30.09, N'Ship to 71-C', N'9012 Suffolk Ln.', N'Boise', N'ID', N'10307', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11065, 46, 8, '20260501 15:08:44', '20260529 10:04:41', NULL, 1, 12.91, N'Ship to 46-C', N'Carrera 2345 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10229', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11066, 89, 7, '20260501 09:38:22', '20260529 09:00:31', '20260504 10:23:53', 2, 44.72, N'Ship to 89-A', N'7890 - 12th Ave. S.', N'Seattle', N'WA', N'10356', N'USA');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11067, 17, 1, '20260504 09:16:43', '20260518 14:03:39', '20260506 12:11:50', 2, 7.98, N'Destination BJCXA', N'Walserweg 7890', N'Aachen', NULL, N'10145', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11068, 62, 8, '20260504 14:58:10', '20260601 08:49:51', NULL, 2, 81.75, N'Ship to 62-A', N'Alameda dos Canàrios, 8901', N'Sao Paulo', N'SP', N'10276', N'Brazil');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11069, 80, 1, '20260504 11:35:54', '20260601 16:29:44', '20260506 16:57:31', 2, 15.67, N'Ship to 80-B', N'Avda. Azteca 4567', N'México D.F.', NULL, N'10333', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11070, 44, 2, '20260505 15:40:19', '20260602 12:53:01', NULL, 1, 136.00, N'Ship to 44-A', N'Magazinweg 4567', N'Frankfurt a.M.', NULL, N'10222', N'Germany');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11071, 46, 1, '20260505 09:21:37', '20260602 17:09:20', NULL, 1, 0.93, N'Ship to 46-B', N'Carrera 1234 con Ave. Bolívar #65-98 Llano Largo', N'Barquisimeto', N'Lara', N'10228', N'Venezuela');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11072, 20, 4, '20260505 16:38:51', '20260602 17:52:48', NULL, 2, 258.64, N'Destination RVDMF', N'Kirchgasse 9012', N'Graz', NULL, N'10157', N'Austria');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11073, 58, 2, '20260505 08:57:16', '20260602 09:34:40', NULL, 2, 24.95, N'Ship to 58-B', N'Calle Dr. Jorge Cash 4567', N'México D.F.', NULL, N'10262', N'Mexico');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11074, 73, 7, '20260506 10:27:19', '20260603 11:15:12', NULL, 2, 18.44, N'Ship to 73-A', N'Vinbæltet 1234', N'Kobenhavn', NULL, N'10310', N'Denmark');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11075, 68, 8, '20260506 15:12:04', '20260603 08:23:32', NULL, 2, 6.19, N'Ship to 68-A', N'Starenweg 6789', N'Genève', NULL, N'10294', N'Switzerland');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11076, 9, 4, '20260506 14:50:20', '20260603 11:27:36', NULL, 2, 38.28, N'Ship to 9-A', N'8901, rue des Bouchers', N'Marseille', NULL, N'10367', N'France');
INSERT INTO Sales.Orders(orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
  VALUES(11077, 65, 1, '20260506 17:12:50', '20260603 08:17:56', NULL, 2, 8.53, N'Ship to 65-A', N'7890 Milton Dr.', N'Albuquerque', N'NM', N'10285', N'USA');
SET IDENTITY_INSERT Sales.Orders OFF;

-- Populate table Sales.OrderDetails
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 11, 14.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 42, 9.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10248, 72, 34.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10249, 14, 18.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10249, 51, 42.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 41, 7.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 51, 42.40, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10250, 65, 16.80, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 22, 16.80, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 57, 15.60, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10251, 65, 16.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 20, 64.80, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 33, 2.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10252, 60, 27.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 31, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 39, 14.40, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10253, 49, 16.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 24, 3.60, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 55, 19.20, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10254, 74, 8.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 2, 15.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 16, 13.90, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 36, 15.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10255, 59, 44.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10256, 53, 26.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10256, 77, 10.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 27, 35.10, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 39, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10257, 77, 10.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 2, 15.20, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 5, 17.00, 65, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10258, 32, 25.60, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10259, 21, 8.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10259, 37, 20.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 41, 7.70, 16, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 57, 15.60, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 62, 39.40, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10260, 70, 12.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10261, 21, 8.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10261, 35, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 5, 17.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 7, 24.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10262, 56, 30.40, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 16, 13.90, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 24, 3.60, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 30, 20.70, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10263, 74, 8.00, 36, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10264, 2, 15.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10264, 41, 7.70, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10265, 17, 31.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10265, 70, 12.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10266, 12, 30.40, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 40, 14.70, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 59, 44.00, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10267, 76, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10268, 29, 99.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10268, 72, 27.80, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10269, 33, 2.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10269, 72, 27.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10270, 36, 15.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10270, 43, 36.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10271, 33, 2.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 20, 64.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 31, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10272, 72, 27.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 10, 24.80, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 31, 10.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 33, 2.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 40, 14.70, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10273, 76, 14.40, 33, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10274, 71, 17.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10274, 72, 27.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10275, 24, 3.60, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10275, 59, 44.00, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10276, 10, 24.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10276, 13, 4.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10277, 28, 36.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10277, 62, 39.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 44, 15.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 59, 44.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 63, 35.10, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10278, 73, 12.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10279, 17, 31.20, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 24, 3.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 55, 19.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10280, 75, 6.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 19, 7.30, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 24, 3.60, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10281, 35, 14.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10282, 30, 20.70, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10282, 57, 15.60, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 15, 12.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 19, 7.30, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 60, 27.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10283, 72, 27.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 27, 35.10, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 44, 15.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 60, 27.20, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10284, 67, 11.20, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 1, 14.40, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 40, 14.70, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10285, 53, 26.20, 36, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10286, 35, 14.40, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10286, 62, 39.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 16, 13.90, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 34, 11.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10287, 46, 9.60, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10288, 54, 5.90, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10288, 68, 10.00, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10289, 3, 8.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10289, 64, 26.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 5, 17.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 29, 99.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 49, 16.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10290, 77, 10.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 13, 4.80, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 44, 15.50, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10291, 51, 42.40, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10292, 20, 64.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 18, 50.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 24, 3.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 63, 35.10, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10293, 75, 6.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 1, 14.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 17, 31.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 43, 36.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 60, 27.20, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10294, 75, 6.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10295, 56, 30.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 11, 16.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 16, 13.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10296, 69, 28.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10297, 39, 14.40, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10297, 72, 27.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 2, 15.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 36, 15.20, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 59, 44.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10298, 62, 39.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10299, 19, 7.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10299, 70, 12.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10300, 66, 13.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10300, 68, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10301, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10301, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 17, 31.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 28, 36.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10302, 43, 36.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 40, 14.70, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 65, 16.80, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10303, 68, 10.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 49, 16.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 59, 44.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10304, 71, 17.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 18, 50.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 29, 99.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10305, 39, 14.40, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 30, 20.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 53, 26.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10306, 54, 5.90, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10307, 62, 39.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10307, 68, 10.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10308, 69, 28.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10308, 70, 12.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 4, 17.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 6, 20.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 42, 11.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 43, 36.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10309, 71, 17.20, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10310, 16, 13.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10310, 62, 39.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10311, 42, 11.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10311, 69, 28.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 28, 36.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 43, 36.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 53, 26.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10312, 75, 6.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10313, 36, 15.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 32, 25.60, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 58, 10.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10314, 62, 39.40, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10315, 34, 11.20, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10315, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10316, 41, 7.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10316, 62, 39.40, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10317, 1, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10318, 41, 7.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10318, 76, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 17, 31.20, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 28, 36.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10319, 76, 14.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10320, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10321, 35, 14.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10322, 52, 5.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 15, 12.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 25, 11.20, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10323, 39, 14.40, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 16, 13.90, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 35, 14.40, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 46, 9.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 59, 44.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10324, 63, 35.10, 80, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 6, 20.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 13, 4.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 14, 18.60, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 31, 10.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10325, 72, 27.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 4, 17.60, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 57, 15.60, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10326, 75, 6.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 2, 15.20, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 11, 16.80, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 30, 20.70, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10327, 58, 10.60, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 59, 44.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 65, 16.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10328, 68, 10.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 19, 7.30, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 30, 20.70, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 38, 210.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10329, 56, 30.40, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10330, 26, 24.90, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10330, 72, 27.80, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10331, 54, 5.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 18, 50.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 42, 11.20, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10332, 47, 7.60, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 14, 18.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 21, 8.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10333, 71, 17.20, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10334, 52, 5.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10334, 68, 10.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 2, 15.20, 7, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 31, 10.00, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 32, 25.60, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10335, 51, 42.40, 48, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10336, 4, 17.60, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 23, 7.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 26, 24.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 36, 15.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 37, 20.80, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10337, 72, 27.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10338, 17, 31.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10338, 30, 20.70, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 4, 17.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 17, 31.20, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10339, 62, 39.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 18, 50.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 41, 7.70, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10340, 43, 36.80, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10341, 33, 2.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10341, 59, 44.00, 9, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 2, 15.20, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 31, 10.00, 56, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 36, 15.20, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10342, 55, 19.20, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 64, 26.60, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 68, 10.00, 4, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10343, 76, 14.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10344, 4, 17.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10344, 8, 32.00, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 8, 32.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 19, 7.30, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10345, 42, 11.20, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10346, 17, 31.20, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10346, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 25, 11.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 39, 14.40, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 40, 14.70, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10347, 75, 6.20, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10348, 1, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10348, 23, 7.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10349, 54, 5.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10350, 50, 13.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10350, 69, 28.80, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 38, 210.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 41, 7.70, 13, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 44, 15.50, 77, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10351, 65, 16.80, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10352, 24, 3.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10352, 54, 5.90, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10353, 11, 16.80, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10353, 38, 210.80, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10354, 1, 14.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10354, 29, 99.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10355, 24, 3.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10355, 57, 15.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 31, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 55, 19.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10356, 69, 28.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 10, 24.80, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 26, 24.90, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10357, 60, 27.20, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 24, 3.60, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 34, 11.20, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10358, 36, 15.20, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 16, 13.90, 56, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 31, 10.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10359, 60, 27.20, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 28, 36.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 29, 99.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 38, 210.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 49, 16.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10360, 54, 5.90, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10361, 39, 14.40, 54, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10361, 60, 27.20, 55, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 25, 11.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 51, 42.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10362, 54, 5.90, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 31, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 75, 6.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10363, 76, 14.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10364, 69, 28.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10364, 71, 17.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10365, 11, 16.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10366, 65, 16.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10366, 77, 10.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 34, 11.20, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 54, 5.90, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 65, 16.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10367, 77, 10.40, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 21, 8.00, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 28, 36.40, 13, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 57, 15.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10368, 64, 26.60, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10369, 29, 99.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10369, 56, 30.40, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 1, 14.40, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 64, 26.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10370, 74, 8.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10371, 36, 15.20, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 20, 64.80, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 38, 210.80, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 60, 27.20, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10372, 72, 27.80, 42, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10373, 58, 10.60, 80, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10373, 71, 17.20, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10374, 31, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10374, 58, 10.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10375, 14, 18.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10375, 54, 5.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10376, 31, 10.00, 42, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10377, 28, 36.40, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10377, 39, 14.40, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10378, 71, 17.20, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 41, 7.70, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 63, 35.10, 16, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10379, 65, 16.80, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 30, 20.70, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 53, 26.20, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 60, 27.20, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10380, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10381, 74, 8.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 5, 17.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 18, 50.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 29, 99.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 33, 2.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10382, 74, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 13, 4.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 50, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10383, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10384, 20, 64.80, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10384, 60, 27.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 7, 24.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 60, 27.20, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10385, 68, 10.00, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10386, 24, 3.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10386, 34, 11.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 24, 3.60, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 28, 36.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 59, 44.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10387, 71, 17.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 45, 7.60, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 52, 5.60, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10388, 53, 26.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 10, 24.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 55, 19.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 62, 39.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10389, 70, 12.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 31, 10.00, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 35, 14.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 46, 9.60, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10390, 72, 27.80, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10391, 13, 4.80, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10392, 69, 28.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 2, 15.20, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 14, 18.60, 42, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 25, 11.20, 7, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 26, 24.90, 70, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10393, 31, 10.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10394, 13, 4.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10394, 62, 39.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 46, 9.60, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 53, 26.20, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10395, 69, 28.80, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 23, 7.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 71, 17.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10396, 72, 27.80, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10397, 21, 8.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10397, 51, 42.40, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10398, 35, 14.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10398, 55, 19.20, 120, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 68, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 76, 14.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10399, 77, 10.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 29, 99.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 35, 14.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10400, 49, 16.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 30, 20.70, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 56, 30.40, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 65, 16.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10401, 71, 17.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10402, 23, 7.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10402, 63, 35.10, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10403, 16, 13.90, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10403, 48, 10.20, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 26, 24.90, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 42, 11.20, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10404, 49, 16.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10405, 3, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 1, 14.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 21, 8.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 28, 36.40, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 36, 15.20, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10406, 40, 14.70, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 11, 16.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 69, 28.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10407, 71, 17.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 37, 20.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 54, 5.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10408, 62, 39.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10409, 14, 18.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10409, 21, 8.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10410, 33, 2.00, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10410, 59, 44.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 41, 7.70, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 44, 15.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10411, 59, 44.00, 9, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10412, 14, 18.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 1, 14.40, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 62, 39.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10413, 76, 14.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10414, 19, 7.30, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10414, 33, 2.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10415, 17, 31.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10415, 33, 2.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 19, 7.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 53, 26.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10416, 57, 15.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 38, 210.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 46, 9.60, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 68, 10.00, 36, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10417, 77, 10.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 2, 15.20, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 47, 7.60, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 61, 22.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10418, 74, 8.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10419, 60, 27.20, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10419, 69, 28.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 9, 77.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 13, 4.80, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 70, 12.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10420, 73, 12.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 19, 7.30, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 53, 26.20, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10421, 77, 10.40, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10422, 26, 24.90, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10423, 31, 10.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10423, 59, 44.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 35, 14.40, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 38, 210.80, 49, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10424, 68, 10.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10425, 55, 19.20, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10425, 76, 14.40, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10426, 56, 30.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10426, 64, 26.60, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10427, 14, 18.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10428, 46, 9.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10429, 50, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10429, 63, 35.10, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 17, 31.20, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 21, 8.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 56, 30.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10430, 59, 44.00, 70, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 17, 31.20, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 40, 14.70, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10431, 47, 7.60, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10432, 26, 24.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10432, 54, 5.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10433, 56, 30.40, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10434, 11, 16.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10434, 76, 14.40, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 2, 15.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 22, 16.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10435, 72, 27.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 46, 9.60, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 56, 30.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 64, 26.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10436, 75, 6.20, 24, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10437, 53, 26.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 19, 7.30, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 34, 11.20, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10438, 57, 15.60, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 12, 30.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 16, 13.90, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 64, 26.60, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10439, 74, 8.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 2, 15.20, 45, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 16, 13.90, 49, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 29, 99.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10440, 61, 22.80, 90, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10441, 27, 35.10, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 11, 16.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 54, 5.90, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10442, 66, 13.60, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10443, 11, 16.80, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10443, 28, 36.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 17, 31.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 26, 24.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 35, 14.40, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10444, 41, 7.70, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10445, 39, 14.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10445, 54, 5.90, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 19, 7.30, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 24, 3.60, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 31, 10.00, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10446, 52, 5.60, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 19, 7.30, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 65, 16.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10447, 71, 17.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10448, 26, 24.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10448, 40, 14.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 10, 24.80, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 52, 5.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10449, 62, 39.40, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10450, 10, 24.80, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10450, 54, 5.90, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 55, 19.20, 120, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 64, 26.60, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 65, 16.80, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10451, 77, 10.40, 55, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10452, 28, 36.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10452, 44, 15.50, 100, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10453, 48, 10.20, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10453, 70, 12.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 16, 13.90, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 33, 2.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10454, 46, 9.60, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 39, 14.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 53, 26.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 61, 22.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10455, 71, 17.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10456, 21, 8.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10456, 49, 16.00, 21, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10457, 59, 44.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 28, 36.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 43, 36.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 56, 30.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10458, 71, 17.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 7, 24.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 46, 9.60, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10459, 72, 27.80, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10460, 68, 10.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10460, 75, 6.20, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 21, 8.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 30, 20.70, 28, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10461, 55, 19.20, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10462, 13, 4.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10462, 23, 7.20, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10463, 19, 7.30, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10463, 42, 11.20, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 4, 17.60, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 43, 36.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 56, 30.40, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10464, 60, 27.20, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 24, 3.60, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 29, 99.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 40, 14.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 45, 7.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10465, 50, 13.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10466, 11, 16.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10466, 46, 9.60, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10467, 24, 3.60, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10467, 25, 11.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10468, 30, 20.70, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10468, 43, 36.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 2, 15.20, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 16, 13.90, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10469, 44, 15.50, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 18, 50.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 23, 7.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10470, 64, 26.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10471, 7, 24.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10471, 56, 30.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10472, 24, 3.60, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10472, 51, 42.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10473, 33, 2.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10473, 71, 17.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 14, 18.60, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 28, 36.40, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 40, 14.70, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10474, 75, 6.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 31, 10.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 66, 13.60, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10475, 76, 14.40, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10476, 55, 19.20, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10476, 70, 12.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 1, 14.40, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 21, 8.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10477, 39, 14.40, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10478, 10, 24.80, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 38, 210.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 53, 26.20, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 59, 44.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10479, 64, 26.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10480, 47, 7.60, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10480, 59, 44.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10481, 49, 16.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10481, 60, 27.20, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10482, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10483, 34, 11.20, 35, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10483, 77, 10.40, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 21, 8.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 40, 14.70, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10484, 51, 42.40, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 2, 15.20, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 3, 8.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 55, 19.20, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10485, 70, 12.00, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 11, 16.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 51, 42.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10486, 74, 8.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 19, 7.30, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 26, 24.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10487, 54, 5.90, 24, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10488, 59, 44.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10488, 73, 12.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10489, 11, 16.80, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10489, 16, 13.90, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 59, 44.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 68, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10490, 75, 6.20, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10491, 44, 15.50, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10491, 77, 10.40, 7, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10492, 25, 11.20, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10492, 42, 11.20, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 65, 16.80, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 66, 13.60, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10493, 69, 28.80, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10494, 56, 30.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 23, 7.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 41, 7.70, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10495, 77, 10.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10496, 31, 10.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 56, 30.40, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 72, 27.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10497, 77, 10.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 24, 4.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 40, 18.40, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10498, 42, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10499, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10499, 49, 20.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10500, 15, 15.50, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10500, 28, 45.60, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10501, 54, 7.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 45, 9.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 53, 32.80, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10502, 67, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10503, 14, 23.25, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10503, 65, 21.05, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 2, 19.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 21, 10.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 53, 32.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10504, 61, 28.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10505, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10506, 25, 14.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10506, 70, 15.00, 14, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10507, 43, 46.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10507, 48, 12.75, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10508, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10508, 39, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10509, 28, 45.60, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10510, 29, 123.79, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10510, 75, 7.75, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 4, 22.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 7, 30.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10511, 8, 40.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 24, 4.50, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 46, 12.00, 9, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 47, 9.50, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10512, 60, 34.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 21, 10.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 32, 32.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10513, 61, 28.50, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 20, 81.00, 39, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 28, 45.60, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 56, 38.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 65, 21.05, 39, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10514, 75, 7.75, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 9, 97.00, 16, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 16, 17.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 27, 43.90, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 33, 2.50, 16, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10515, 60, 34.00, 84, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 18, 62.50, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 41, 9.65, 80, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10516, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 52, 7.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 59, 55.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10517, 70, 15.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 24, 4.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 38, 263.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10518, 44, 19.45, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 10, 31.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 56, 38.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10519, 60, 34.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10520, 24, 4.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10520, 53, 32.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 35, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 41, 9.65, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10521, 68, 12.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 1, 18.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 8, 40.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 30, 25.89, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10522, 40, 18.40, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 17, 39.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 20, 81.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 37, 26.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10523, 41, 9.65, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 10, 31.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 30, 25.89, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 43, 46.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10524, 54, 7.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10525, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10525, 40, 18.40, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 1, 18.00, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10526, 56, 38.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10527, 4, 22.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10527, 36, 19.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 11, 21.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 33, 2.50, 8, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10528, 72, 34.80, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 55, 24.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10529, 69, 36.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 17, 39.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 43, 46.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 61, 28.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10530, 76, 18.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10531, 59, 55.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10532, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10532, 66, 17.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 4, 22.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 72, 34.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10533, 73, 15.00, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 30, 25.89, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 40, 18.40, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10534, 54, 7.45, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 11, 21.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 40, 18.40, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 57, 19.50, 5, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10535, 59, 55.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 12, 38.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10536, 60, 34.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 31, 12.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 51, 53.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 58, 13.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 72, 34.80, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10537, 73, 15.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10538, 70, 15.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10538, 72, 34.80, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 13, 6.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 21, 10.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 33, 2.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10539, 49, 20.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 3, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 26, 31.23, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 38, 263.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10540, 68, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 24, 4.50, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 38, 263.50, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 65, 21.05, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10541, 71, 21.50, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10542, 11, 21.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10542, 54, 7.45, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10543, 12, 38.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10543, 23, 9.00, 70, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10544, 28, 45.60, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10544, 67, 14.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10545, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 7, 30.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 35, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10546, 62, 49.30, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10547, 32, 32.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10547, 36, 19.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10548, 34, 14.00, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10548, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 31, 12.50, 55, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 45, 9.50, 100, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10549, 51, 53.00, 48, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 17, 39.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 19, 9.20, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 21, 10.00, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10550, 61, 28.50, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 16, 17.45, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 35, 18.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10551, 44, 19.45, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10552, 69, 36.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10552, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 16, 17.45, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 22, 21.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 31, 12.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10553, 35, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 16, 17.45, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 23, 9.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10554, 77, 13.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 14, 23.25, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 19, 9.20, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 24, 4.50, 18, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 51, 53.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10555, 56, 38.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10556, 72, 34.80, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10557, 64, 33.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10557, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 47, 9.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 52, 7.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 53, 32.80, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10558, 73, 15.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10559, 41, 9.65, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10559, 55, 24.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10560, 30, 25.89, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10560, 62, 49.30, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10561, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10561, 51, 53.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10562, 33, 2.50, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10562, 62, 49.30, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10563, 36, 19.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10563, 52, 7.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 17, 39.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 31, 12.50, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10564, 55, 24.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10565, 24, 4.50, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10565, 64, 33.25, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 11, 21.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 18, 62.50, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10566, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 31, 12.50, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 51, 53.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10567, 59, 55.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10568, 10, 31.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10569, 31, 12.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10569, 76, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10570, 11, 21.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10570, 56, 38.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10571, 14, 23.25, 11, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10571, 42, 14.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 16, 17.45, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 32, 32.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 40, 18.40, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10572, 75, 7.75, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 17, 39.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 34, 14.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10573, 53, 32.80, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 33, 2.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 40, 18.40, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10574, 64, 33.25, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 59, 55.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 63, 43.90, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 72, 34.80, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10575, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10576, 44, 19.45, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 39, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10577, 77, 13.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10578, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10578, 57, 19.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10579, 15, 15.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10579, 75, 7.75, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 14, 23.25, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 41, 9.65, 9, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10580, 65, 21.05, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10581, 75, 7.75, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10582, 57, 19.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10582, 76, 18.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 60, 34.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10583, 69, 36.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10584, 31, 12.50, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10585, 47, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10586, 52, 7.00, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 26, 31.23, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10587, 77, 13.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10588, 18, 62.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10588, 42, 14.00, 100, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10589, 35, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10590, 1, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10590, 77, 13.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 3, 10.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 7, 30.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10591, 54, 7.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10592, 15, 15.50, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10592, 26, 31.23, 5, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 20, 81.00, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 69, 36.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10593, 76, 18.00, 4, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10594, 52, 7.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10594, 58, 13.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 35, 18.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 61, 28.50, 120, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10595, 69, 36.00, 65, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 56, 38.00, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 63, 43.90, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10596, 75, 7.75, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 24, 4.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10597, 65, 21.05, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10598, 27, 43.90, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10598, 71, 21.50, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10599, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10600, 54, 7.45, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10600, 73, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10601, 13, 6.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10601, 59, 55.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10602, 77, 13.00, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10603, 22, 21.00, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10603, 49, 20.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10604, 48, 12.75, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10604, 76, 18.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 16, 17.45, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 59, 55.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 60, 34.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10605, 71, 21.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 4, 22.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 55, 24.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10606, 62, 49.30, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 7, 30.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 17, 39.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 33, 2.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 40, 18.40, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10607, 72, 34.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10608, 56, 38.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 1, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10609, 21, 10.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10610, 36, 19.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 1, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10611, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 10, 31.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 36, 19.00, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 49, 20.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 60, 34.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10612, 76, 18.00, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10613, 13, 6.00, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10613, 75, 7.75, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 11, 21.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 21, 10.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10614, 39, 18.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10615, 55, 24.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 38, 263.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 56, 38.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 70, 15.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10616, 71, 21.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10617, 59, 55.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 6, 25.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 56, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10618, 68, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10619, 21, 10.00, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10619, 22, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10620, 24, 4.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10620, 52, 7.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 19, 9.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 23, 9.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 70, 15.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10621, 71, 21.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10622, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10622, 68, 12.50, 18, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 14, 23.25, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 19, 9.20, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 21, 10.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 24, 4.50, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10623, 35, 18.00, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 28, 45.60, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 29, 123.79, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10624, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 14, 23.25, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 42, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10625, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 53, 32.80, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 60, 34.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10626, 71, 21.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10627, 62, 49.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10627, 73, 15.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10628, 1, 18.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10629, 29, 123.79, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10629, 64, 33.25, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10630, 55, 24.00, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10630, 76, 18.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10631, 75, 7.75, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10632, 2, 19.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10632, 33, 2.50, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 12, 38.00, 36, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 13, 6.00, 13, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 26, 31.23, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10633, 62, 49.30, 80, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 7, 30.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 18, 62.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 51, 53.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10634, 75, 7.75, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 4, 22.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 5, 21.35, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10635, 22, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10636, 4, 22.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10636, 58, 13.25, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 50, 16.25, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10637, 56, 38.00, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 45, 9.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10638, 72, 34.80, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10639, 18, 62.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10640, 69, 36.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10640, 70, 15.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10641, 2, 19.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10641, 40, 18.40, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10642, 21, 10.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10642, 61, 28.50, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 28, 45.60, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 39, 18.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10643, 46, 12.00, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 18, 62.50, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 43, 46.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10644, 46, 12.00, 21, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10645, 18, 62.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10645, 36, 19.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 1, 18.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 10, 31.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 71, 21.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10646, 77, 13.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10647, 19, 9.20, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10647, 39, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10648, 22, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10648, 24, 4.50, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10649, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10649, 72, 34.80, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 53, 32.80, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10650, 54, 7.45, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10651, 19, 9.20, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10651, 22, 21.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10652, 30, 25.89, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10652, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10653, 16, 17.45, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10653, 60, 34.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 4, 22.00, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 39, 18.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10654, 54, 7.45, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10655, 41, 9.65, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 14, 23.25, 3, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 44, 19.45, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10656, 47, 9.50, 6, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 15, 15.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 41, 9.65, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 46, 12.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 47, 9.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 56, 38.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10657, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 21, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 40, 18.40, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 60, 34.00, 55, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10658, 77, 13.00, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 31, 12.50, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 40, 18.40, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10659, 70, 15.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10660, 20, 81.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10661, 39, 18.00, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10661, 58, 13.25, 49, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10662, 68, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 40, 18.40, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 42, 14.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10663, 51, 53.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 10, 31.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 56, 38.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10664, 65, 21.05, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 59, 55.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10665, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10666, 29, 123.79, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10666, 65, 21.05, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10667, 69, 36.00, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10667, 71, 21.50, 14, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 31, 12.50, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 55, 24.00, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10668, 64, 33.25, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10669, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 23, 9.00, 32, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 46, 12.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 67, 14.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 73, 15.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10670, 75, 7.75, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 16, 17.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 62, 49.30, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10671, 65, 21.05, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10672, 38, 263.50, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10672, 71, 21.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 42, 14.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10673, 43, 46.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10674, 23, 9.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 14, 23.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 53, 32.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10675, 58, 13.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 10, 31.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 19, 9.20, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10676, 44, 19.45, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10677, 26, 31.23, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10677, 33, 2.50, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 12, 38.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 41, 9.65, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10678, 54, 7.45, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10679, 59, 55.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 16, 17.45, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 31, 12.50, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10680, 42, 14.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 19, 9.20, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 21, 10.00, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10681, 64, 33.25, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 66, 17.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10682, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10683, 52, 7.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 40, 18.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 47, 9.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10684, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 10, 31.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 41, 9.65, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10685, 47, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10686, 17, 39.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10686, 26, 31.23, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 9, 97.00, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10687, 36, 19.00, 6, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 10, 31.00, 18, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 28, 45.60, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10688, 34, 14.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10689, 1, 18.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10690, 56, 38.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10690, 77, 13.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 1, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 29, 123.79, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 43, 46.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 44, 19.45, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10691, 62, 49.30, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10692, 63, 43.90, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 9, 97.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 54, 7.45, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 69, 36.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10693, 73, 15.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 7, 30.00, 90, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10694, 70, 15.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 8, 40.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 12, 38.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10695, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10696, 17, 39.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10696, 46, 12.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 19, 9.20, 7, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 35, 18.00, 9, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 58, 13.25, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10697, 70, 15.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 17, 39.00, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 29, 123.79, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 65, 21.05, 65, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10698, 70, 15.00, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10699, 47, 9.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 1, 18.00, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 34, 14.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 68, 12.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10700, 71, 21.50, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 59, 55.00, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 71, 21.50, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10701, 76, 18.00, 35, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10702, 3, 10.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10702, 76, 18.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 2, 19.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 59, 55.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10703, 73, 15.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 4, 22.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 24, 4.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10704, 48, 12.75, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10705, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10705, 32, 32.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 43, 46.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10706, 59, 55.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 55, 24.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 57, 19.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10707, 70, 15.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10708, 5, 21.35, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10708, 36, 19.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 8, 40.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 51, 53.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10709, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10710, 19, 9.20, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10710, 47, 9.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 41, 9.65, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10711, 53, 32.80, 120, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10712, 53, 32.80, 3, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10712, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 10, 31.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 26, 31.23, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 45, 9.50, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10713, 46, 12.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 2, 19.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 17, 39.00, 27, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 47, 9.50, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 56, 38.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10714, 58, 13.25, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10715, 10, 31.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10715, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 21, 10.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 51, 53.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10716, 61, 28.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 21, 10.00, 32, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 54, 7.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10717, 69, 36.00, 25, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 12, 38.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 36, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10718, 62, 49.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 18, 62.50, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 30, 25.89, 3, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10719, 54, 7.45, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10720, 35, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10720, 71, 21.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10721, 44, 19.45, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 2, 19.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 31, 12.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 68, 12.50, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10722, 75, 7.75, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10723, 26, 31.23, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10724, 10, 31.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10724, 61, 28.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 52, 7.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10725, 55, 24.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10726, 4, 22.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10726, 11, 21.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 17, 39.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 56, 38.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10727, 59, 55.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 40, 18.40, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 55, 24.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10728, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 1, 18.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 21, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10729, 50, 16.25, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 16, 17.45, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 31, 12.50, 3, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10730, 65, 21.05, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10731, 21, 10.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10731, 51, 53.00, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10732, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 14, 23.25, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10733, 52, 7.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 6, 25.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10734, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10735, 61, 28.50, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10735, 77, 13.00, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10736, 65, 21.05, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10736, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10737, 13, 6.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10737, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10738, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10739, 36, 19.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10739, 52, 7.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 28, 45.60, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 35, 18.00, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 45, 9.50, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10740, 56, 38.00, 14, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10741, 2, 19.00, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 3, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 60, 34.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10742, 72, 34.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10743, 46, 12.00, 28, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10744, 40, 18.40, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 18, 62.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 44, 19.45, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 59, 55.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10745, 72, 34.80, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 13, 6.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 42, 14.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 62, 49.30, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10746, 69, 36.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 31, 12.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 41, 9.65, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 63, 43.90, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10747, 69, 36.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 23, 9.00, 44, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 40, 18.40, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10748, 56, 38.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 56, 38.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 59, 55.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10749, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 14, 23.25, 5, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 45, 9.50, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10750, 59, 55.00, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 26, 31.23, 12, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 50, 16.25, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10751, 73, 15.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10752, 1, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10752, 69, 36.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10753, 45, 9.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10753, 74, 10.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10754, 40, 18.40, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 47, 9.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 56, 38.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 57, 19.50, 14, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10755, 69, 36.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 18, 62.50, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 36, 19.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 68, 12.50, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10756, 69, 36.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 34, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 59, 55.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 62, 49.30, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10757, 64, 33.25, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 26, 31.23, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 52, 7.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10758, 70, 15.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10759, 32, 32.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 25, 14.00, 12, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 27, 43.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10760, 43, 46.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10761, 25, 14.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10761, 75, 7.75, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 39, 18.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 47, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 51, 53.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10762, 56, 38.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 21, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 22, 21.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10763, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10764, 3, 10.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10764, 39, 18.00, 130, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10765, 65, 21.05, 80, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 2, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 7, 30.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10766, 68, 12.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10767, 42, 14.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 22, 21.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 31, 12.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10768, 71, 21.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 41, 9.65, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 52, 7.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 61, 28.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10769, 62, 49.30, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10770, 11, 21.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10771, 71, 21.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10772, 29, 123.79, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10772, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 17, 39.00, 33, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 31, 12.50, 70, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10773, 75, 7.75, 7, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10774, 31, 12.50, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10774, 66, 17.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10775, 10, 31.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10775, 67, 14.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 31, 12.50, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 42, 14.00, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 45, 9.50, 27, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10776, 51, 53.00, 120, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10777, 42, 14.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10778, 41, 9.65, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10779, 16, 17.45, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10779, 62, 49.30, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10780, 70, 15.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10780, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 54, 7.45, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 56, 38.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10781, 74, 10.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10782, 31, 12.50, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10783, 31, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10783, 38, 263.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 36, 19.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 39, 18.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10784, 72, 34.80, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10785, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10785, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 8, 40.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 30, 25.89, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10786, 75, 7.75, 42, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10787, 2, 19.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10787, 29, 123.79, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10788, 19, 9.20, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10788, 75, 7.75, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 18, 62.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 35, 18.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 63, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10789, 68, 12.50, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10790, 7, 30.00, 3, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10790, 56, 38.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10791, 29, 123.79, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10791, 41, 9.65, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 54, 7.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10792, 68, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10793, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10793, 52, 7.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10794, 14, 23.25, 15, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10794, 54, 7.45, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10795, 16, 17.45, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10795, 17, 39.00, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 26, 31.23, 21, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 44, 19.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 64, 33.25, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10796, 69, 36.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10797, 11, 21.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10798, 62, 49.30, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10798, 72, 34.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 13, 6.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 24, 4.50, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10799, 59, 55.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 11, 21.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 51, 53.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10800, 54, 7.45, 7, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10801, 17, 39.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10801, 29, 123.79, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 30, 25.89, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 51, 53.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 55, 24.00, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10802, 62, 49.30, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 19, 9.20, 24, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 25, 14.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10803, 59, 55.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 10, 31.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 28, 45.60, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10804, 49, 20.00, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10805, 34, 14.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10805, 38, 263.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 2, 19.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 65, 21.05, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10806, 74, 10.00, 15, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10807, 40, 18.40, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10808, 56, 38.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10808, 76, 18.00, 50, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10809, 52, 7.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 13, 6.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 25, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10810, 70, 15.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 19, 9.20, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 23, 9.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10811, 40, 18.40, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 31, 12.50, 16, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 72, 34.80, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10812, 77, 13.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10813, 2, 19.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10813, 46, 12.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 41, 9.65, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 43, 46.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 48, 12.75, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10814, 61, 28.50, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10815, 33, 2.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10816, 38, 263.50, 30, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10816, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 26, 31.23, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 38, 263.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 40, 18.40, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10817, 62, 49.30, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10818, 32, 32.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10818, 41, 9.65, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10819, 43, 46.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10819, 75, 7.75, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10820, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10821, 35, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10821, 51, 53.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10822, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10822, 70, 15.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 11, 21.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 59, 55.00, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10823, 77, 13.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10824, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10824, 70, 15.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10825, 26, 31.23, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10825, 53, 32.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10826, 31, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10826, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10827, 10, 31.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10827, 39, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10828, 20, 81.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10828, 38, 263.50, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 2, 19.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 8, 40.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10829, 60, 34.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 6, 25.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 39, 18.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 60, 34.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10830, 68, 12.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 19, 9.20, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 35, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 38, 263.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10831, 43, 46.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 13, 6.00, 3, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 25, 14.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 44, 19.45, 16, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10832, 64, 33.25, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 7, 30.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 31, 12.50, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10833, 53, 32.80, 9, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10834, 29, 123.79, 8, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10834, 30, 25.89, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10835, 59, 55.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10835, 77, 13.00, 2, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 22, 21.00, 52, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 35, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 57, 19.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 60, 34.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10836, 64, 33.25, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 13, 6.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 40, 18.40, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 47, 9.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10837, 76, 18.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 1, 18.00, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 18, 62.50, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10838, 36, 19.00, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10839, 58, 13.25, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10839, 72, 34.80, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10840, 25, 14.00, 6, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10840, 39, 18.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 10, 31.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 56, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 59, 55.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10841, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 43, 46.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10842, 70, 15.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10843, 51, 53.00, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10844, 22, 21.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 23, 9.00, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 35, 18.00, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 42, 14.00, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 58, 13.25, 60, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10845, 64, 33.25, 48, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 4, 22.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10846, 74, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 1, 18.00, 80, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 19, 9.20, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 37, 26.00, 60, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 45, 9.50, 36, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 60, 34.00, 45, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10847, 71, 21.50, 55, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10848, 5, 21.35, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10848, 9, 97.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10849, 3, 10.00, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10849, 26, 31.23, 18, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 25, 14.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 33, 2.50, 4, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10850, 70, 15.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 2, 19.00, 5, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 25, 14.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 57, 19.50, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10851, 59, 55.00, 42, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 2, 19.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10852, 62, 49.30, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10853, 18, 62.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10854, 10, 31.00, 100, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10854, 13, 6.00, 65, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 16, 17.45, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 31, 12.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 56, 38.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10855, 65, 21.05, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10856, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10856, 42, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 3, 10.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 26, 31.23, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10857, 29, 123.79, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 7, 30.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 27, 43.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10858, 70, 15.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 24, 4.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 54, 7.45, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10859, 64, 33.25, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10860, 51, 53.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10860, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 17, 39.00, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 18, 62.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 21, 10.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 33, 2.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10861, 62, 49.30, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10862, 11, 21.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10862, 52, 7.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10863, 1, 18.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10863, 58, 13.25, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10864, 35, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10864, 67, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10865, 38, 263.50, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10865, 39, 18.00, 80, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 2, 19.00, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 24, 4.50, 6, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10866, 30, 25.89, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10867, 53, 32.80, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 26, 31.23, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 35, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10868, 49, 20.00, 42, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 1, 18.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 23, 9.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10869, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10870, 35, 18.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10870, 51, 53.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 6, 25.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 16, 17.45, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10871, 17, 39.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 55, 24.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 62, 49.30, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 64, 33.25, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10872, 65, 21.05, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10873, 21, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10873, 28, 45.60, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10874, 10, 31.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 19, 9.20, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 47, 9.50, 21, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10875, 49, 20.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10876, 46, 12.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10876, 64, 33.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10877, 16, 17.45, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10877, 18, 62.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10878, 20, 81.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 40, 18.40, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 65, 21.05, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10879, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 23, 9.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 61, 28.50, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10880, 70, 15.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10881, 73, 15.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 42, 14.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 49, 20.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10882, 54, 7.45, 32, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10883, 24, 4.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 21, 10.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 56, 38.00, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10884, 65, 21.05, 12, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10885, 77, 13.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 10, 31.00, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 31, 12.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10886, 77, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10887, 25, 14.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10888, 2, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10888, 68, 12.50, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10889, 11, 21.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10889, 38, 263.50, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 17, 39.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 34, 14.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10890, 41, 9.65, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10891, 30, 25.89, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10892, 59, 55.00, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 8, 40.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 24, 4.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 29, 123.79, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 30, 25.89, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10893, 36, 19.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 13, 6.00, 28, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 69, 36.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10894, 75, 7.75, 120, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 24, 4.50, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 39, 18.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 40, 18.40, 91, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10895, 60, 34.00, 100, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10896, 45, 9.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10896, 56, 38.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10897, 29, 123.79, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10897, 30, 25.89, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10898, 13, 6.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10899, 39, 18.00, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10900, 70, 15.00, 3, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10901, 41, 9.65, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10901, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10902, 55, 24.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10902, 62, 49.30, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 13, 6.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10903, 68, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10904, 58, 13.25, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10904, 62, 49.30, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10905, 1, 18.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10906, 61, 28.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10907, 75, 7.75, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10908, 7, 30.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10908, 52, 7.00, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 7, 30.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 16, 17.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10909, 41, 9.65, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 49, 20.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10910, 61, 28.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 17, 39.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10911, 67, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10912, 11, 21.00, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10912, 29, 123.79, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 4, 22.00, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 33, 2.50, 40, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10913, 58, 13.25, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10914, 71, 21.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 17, 39.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10915, 54, 7.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 16, 17.45, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 32, 32.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10916, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10917, 30, 25.89, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10917, 60, 34.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10918, 1, 18.00, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10918, 60, 34.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 16, 17.45, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 25, 14.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10919, 40, 18.40, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10920, 50, 16.25, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10921, 35, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10921, 63, 43.90, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10922, 17, 39.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10922, 24, 4.50, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 42, 14.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 43, 46.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10923, 67, 14.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 10, 31.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 28, 45.60, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10924, 75, 7.75, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10925, 36, 19.00, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10925, 52, 7.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 11, 21.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 13, 6.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 19, 9.20, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10926, 72, 34.80, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 20, 81.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 52, 7.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10927, 76, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10928, 47, 9.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10928, 76, 18.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 21, 10.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 75, 7.75, 49, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10929, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 21, 10.00, 36, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 27, 43.90, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 55, 24.00, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10930, 58, 13.25, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10931, 13, 6.00, 42, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10931, 57, 19.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 16, 17.45, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 62, 49.30, 14, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 72, 34.80, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10932, 75, 7.75, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10933, 53, 32.80, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10933, 61, 28.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10934, 6, 25.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 1, 18.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 18, 62.50, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10935, 23, 9.00, 8, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10936, 36, 19.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10937, 28, 45.60, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10937, 34, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 13, 6.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 43, 46.00, 24, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 60, 34.00, 49, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10938, 71, 21.50, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10939, 2, 19.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10939, 67, 14.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10940, 7, 30.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10940, 13, 6.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 31, 12.50, 44, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 62, 49.30, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 68, 12.50, 80, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10941, 72, 34.80, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10942, 49, 20.00, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 13, 6.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 22, 21.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10943, 46, 12.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 11, 21.00, 5, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 44, 19.45, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10944, 56, 38.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10945, 13, 6.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10945, 31, 12.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 10, 31.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 24, 4.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10946, 77, 13.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10947, 59, 55.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 50, 16.25, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 51, 53.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10948, 55, 24.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 6, 25.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 10, 31.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10949, 62, 49.30, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10950, 4, 22.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 33, 2.50, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 41, 9.65, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10951, 75, 7.75, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10952, 6, 25.00, 16, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10952, 28, 45.60, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10953, 20, 81.00, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10953, 31, 12.50, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 16, 17.45, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 31, 12.50, 25, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 45, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10954, 60, 34.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10955, 75, 7.75, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 21, 10.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 47, 9.50, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10956, 51, 53.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 30, 25.89, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 35, 18.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10957, 64, 33.25, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 5, 21.35, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 7, 30.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10958, 72, 34.80, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10959, 75, 7.75, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10960, 24, 4.50, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10960, 41, 9.65, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10961, 52, 7.00, 6, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10961, 76, 18.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 7, 30.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 13, 6.00, 77, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 53, 32.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 69, 36.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10962, 76, 18.00, 44, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10963, 60, 34.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 18, 62.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 38, 263.50, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10964, 69, 36.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10965, 51, 53.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 37, 26.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 56, 38.00, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10966, 62, 49.30, 12, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10967, 19, 9.20, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10967, 49, 20.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 12, 38.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 24, 4.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10968, 64, 33.25, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10969, 46, 12.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10970, 52, 7.00, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10971, 29, 123.79, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10972, 17, 39.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10972, 33, 2.50, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 26, 31.23, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 41, 9.65, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10973, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10974, 63, 43.90, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10975, 8, 40.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10975, 75, 7.75, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10976, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 39, 18.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 47, 9.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 51, 53.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10977, 63, 43.90, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 8, 40.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 21, 10.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 40, 18.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10978, 44, 19.45, 6, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 7, 30.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 12, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 24, 4.50, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 27, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 31, 12.50, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10979, 63, 43.90, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10980, 75, 7.75, 40, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10981, 38, 263.50, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10982, 7, 30.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10982, 43, 46.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10983, 13, 6.00, 84, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10983, 57, 19.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 16, 17.45, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10984, 36, 19.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 16, 17.45, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 18, 62.50, 8, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10985, 32, 32.00, 35, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 11, 21.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 20, 81.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 76, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10986, 77, 13.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 43, 46.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10987, 72, 34.80, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10988, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10988, 62, 49.30, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 6, 25.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 11, 21.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10989, 41, 9.65, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 21, 10.00, 65, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 34, 14.00, 60, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 55, 24.00, 65, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10990, 61, 28.50, 66, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 2, 19.00, 50, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 70, 15.00, 20, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10991, 76, 18.00, 90, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10992, 72, 34.80, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10993, 29, 123.79, 50, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10993, 41, 9.65, 35, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10994, 59, 55.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10995, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10995, 60, 34.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10996, 42, 14.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 32, 32.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 46, 12.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10997, 52, 7.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 61, 28.50, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 74, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10998, 75, 7.75, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 41, 9.65, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 51, 53.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(10999, 77, 13.00, 21, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 4, 22.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 24, 4.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11000, 77, 13.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 7, 30.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 22, 21.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 46, 12.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11001, 55, 24.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 13, 6.00, 56, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 35, 18.00, 15, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 42, 14.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11002, 55, 24.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 1, 18.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 40, 18.40, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11003, 52, 7.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11004, 26, 31.23, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11004, 76, 18.00, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11005, 1, 18.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11005, 59, 55.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11006, 1, 18.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11006, 29, 123.79, 2, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 8, 40.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 29, 123.79, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11007, 42, 14.00, 14, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 28, 45.60, 70, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 34, 14.00, 90, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11008, 71, 21.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 24, 4.50, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 36, 19.00, 18, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11009, 60, 34.00, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11010, 7, 30.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11010, 24, 4.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11011, 58, 13.25, 40, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11011, 71, 21.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 19, 9.20, 50, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 60, 34.00, 36, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11012, 71, 21.50, 60, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 23, 9.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 42, 14.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 45, 9.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11013, 68, 12.50, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11014, 41, 9.65, 28, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11015, 30, 25.89, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11015, 77, 13.00, 18, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11016, 31, 12.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11016, 36, 19.00, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 3, 10.00, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 59, 55.00, 110, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11017, 70, 15.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 12, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 18, 62.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11018, 56, 38.00, 5, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11019, 46, 12.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11019, 49, 20.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11020, 10, 31.00, 24, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 2, 19.00, 11, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 20, 81.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 26, 31.23, 63, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 51, 53.00, 44, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11021, 72, 34.80, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11022, 19, 9.20, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11022, 69, 36.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11023, 7, 30.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11023, 43, 46.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 26, 31.23, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 33, 2.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 65, 21.05, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11024, 71, 21.50, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11025, 1, 18.00, 10, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11025, 13, 6.00, 20, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11026, 18, 62.50, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11026, 51, 53.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11027, 24, 4.50, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11027, 62, 49.30, 21, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11028, 55, 24.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11028, 59, 55.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11029, 56, 38.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11029, 63, 43.90, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 2, 19.00, 100, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 5, 21.35, 70, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 29, 123.79, 60, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11030, 59, 55.00, 100, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 1, 18.00, 45, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 13, 6.00, 80, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 24, 4.50, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 64, 33.25, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11031, 71, 21.50, 16, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 36, 19.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 38, 263.50, 25, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11032, 59, 55.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11033, 53, 32.80, 70, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11033, 69, 36.00, 36, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 21, 10.00, 15, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 44, 19.45, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11034, 61, 28.50, 6, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 1, 18.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 35, 18.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 42, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11035, 54, 7.45, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11036, 13, 6.00, 7, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11036, 59, 55.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11037, 70, 15.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 40, 18.40, 5, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 52, 7.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11038, 71, 21.50, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 28, 45.60, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 35, 18.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 49, 20.00, 60, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11039, 57, 19.50, 28, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11040, 21, 10.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11041, 2, 19.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11041, 63, 43.90, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11042, 44, 19.45, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11042, 61, 28.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11043, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11044, 62, 49.30, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11045, 33, 2.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11045, 51, 53.00, 24, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 12, 38.00, 20, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 32, 32.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11046, 35, 18.00, 18, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11047, 1, 18.00, 25, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11047, 5, 21.35, 30, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11048, 68, 12.50, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11049, 2, 19.00, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11049, 12, 38.00, 4, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11050, 76, 18.00, 50, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11051, 24, 4.50, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11052, 43, 46.00, 30, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11052, 61, 28.50, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 18, 62.50, 35, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 32, 32.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11053, 64, 33.25, 25, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11054, 33, 2.50, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11054, 67, 14.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 24, 4.50, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 25, 14.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 51, 53.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11055, 57, 19.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 7, 30.00, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 55, 24.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11056, 60, 34.00, 50, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11057, 70, 15.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 21, 10.00, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 60, 34.00, 21, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11058, 61, 28.50, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 13, 6.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 17, 39.00, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11059, 60, 34.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11060, 60, 34.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11060, 77, 13.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11061, 60, 34.00, 15, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11062, 53, 32.80, 10, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11062, 70, 15.00, 12, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 34, 14.00, 30, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 40, 18.40, 40, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11063, 41, 9.65, 30, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 17, 39.00, 77, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 41, 9.65, 12, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 53, 32.80, 25, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 55, 24.00, 4, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11064, 68, 12.50, 55, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11065, 30, 25.89, 4, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11065, 54, 7.45, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 16, 17.45, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 19, 9.20, 42, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11066, 34, 14.00, 35, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11067, 41, 9.65, 9, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 28, 45.60, 8, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 43, 46.00, 36, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11068, 77, 13.00, 28, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11069, 39, 18.00, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 1, 18.00, 40, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 2, 19.00, 20, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 16, 17.45, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11070, 31, 12.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11071, 7, 30.00, 15, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11071, 13, 6.00, 10, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 2, 19.00, 8, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 41, 9.65, 40, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 50, 16.25, 22, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11072, 64, 33.25, 130, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11073, 11, 21.00, 10, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11073, 24, 4.50, 20, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11074, 16, 17.45, 14, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 2, 19.00, 10, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 46, 12.00, 30, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11075, 76, 18.00, 2, 0.15);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 6, 25.00, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 14, 23.25, 20, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11076, 19, 9.20, 10, 0.25);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 2, 19.00, 24, 0.2);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 3, 10.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 4, 22.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 6, 25.00, 1, 0.02);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 7, 30.00, 1, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 8, 40.00, 2, 0.1);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 10, 31.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 12, 38.00, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 13, 6.00, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 14, 23.25, 1, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 16, 17.45, 2, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 20, 81.00, 1, 0.04);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 23, 9.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 32, 32.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 39, 18.00, 2, 0.05);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 41, 9.65, 3, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 46, 12.00, 3, 0.02);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 52, 7.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 55, 24.00, 2, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 60, 34.00, 2, 0.06);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 64, 33.25, 2, 0.03);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 66, 17.00, 1, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 73, 15.00, 2, 0.01);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 75, 7.75, 4, 0);
INSERT INTO Sales.OrderDetails(orderid, productid, unitprice, qty, discount)
  VALUES(11077, 77, 13.00, 2, 0);

-- Populate table Stats.Tests
INSERT INTO Stats.Tests(testid) VALUES ('Test ABC');
INSERT INTO Stats.Tests(testid) VALUES ('Test XYZ');

-- Populate table Stats.Scores
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student A', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student B', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student C', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student D', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student E', 50);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student F', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student G', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student H', 65);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test ABC', 'Student I', 75);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student A', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student B', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student C', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student D', 55);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student E', 50);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student F', 80);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student G', 95);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student H', 65);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student I', 75);
INSERT INTO Stats.Scores(testid, studentid, score) VALUES
  ('Test XYZ', 'Student J', 95);
GO

-- Create and Populate table dbo.Nums
CREATE TABLE dbo.Nums(n INT NOT NULL CONSTRAINT PK_Nums PRIMARY KEY);

DECLARE @max AS INT, @rc AS INT;
SET @max = 100000;
SET @rc = 1;

INSERT INTO dbo.Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

SET NOCOUNT OFF;
GO

---------------------------------------------------------------------
-- Create Views and Functions
---------------------------------------------------------------------

CREATE VIEW Sales.OrderValues
  WITH SCHEMABINDING
AS

SELECT O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate;
GO

CREATE VIEW Sales.OrderTotalsByYear
  WITH SCHEMABINDING
AS

SELECT
  YEAR(O.orderdate) AS orderyear,
  SUM(OD.qty) AS qty
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);
GO

CREATE VIEW Sales.CustOrders
  WITH SCHEMABINDING
AS

SELECT
  O.custid, 
  DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE)) AS ordermonth,
  SUM(OD.qty) AS qty
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY custid, DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE));
GO

CREATE VIEW Sales.EmpOrders  
  WITH SCHEMABINDING  
AS  
  
SELECT  
  O.empid,
  DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE)) AS ordermonth,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - discount))  
       AS NUMERIC(12, 2)) AS val,
  COUNT(*) AS numorders  
FROM Sales.Orders AS O  
  JOIN Sales.OrderDetails AS OD  
    ON OD.orderid = O.orderid  
GROUP BY empid, DATEADD(month, DATEDIFF(month, CAST('19000101' AS DATE), O.orderdate), CAST('19000101' AS DATE));
GO

CREATE FUNCTION dbo.GetNums(@low AS BIGINT = 1, @high AS BIGINT)
  RETURNS TABLE
AS
RETURN
  WITH
    L0 AS ( SELECT 1 AS c 
            FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),
                        (1),(1),(1),(1),(1),(1),(1),(1)) AS D(c) ),
    L1 AS ( SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B ),
    L2 AS ( SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B ),
    L3 AS ( SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B ),
    Nums AS ( SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
              FROM L3 )
  SELECT TOP(@high - @low + 1)
     rownum AS rn,
     @high + 1 - rownum AS op,
     @low - 1 + rownum AS n
  FROM Nums
  ORDER BY rownum;
GO

---------------------------------------------------------------------
-- LAB04 / LAB06: course-prepared views for a shared server
-- HR.Calendar     : all dates of the current year
-- Sales.Somedates : sample strings that may or may not be valid dates
---------------------------------------------------------------------

CREATE VIEW HR.Calendar
AS
  SELECT
    DATEADD(DAY, n - 1, DATEFROMPARTS(YEAR(SYSDATETIME()), 1, 1)) AS calendardate
  FROM dbo.GetNums(1, DATEDIFF(DAY, DATEFROMPARTS(YEAR(SYSDATETIME()), 1, 1),
                               DATEFROMPARTS(YEAR(SYSDATETIME()), 12, 31)));
GO

CREATE VIEW Sales.Somedates
AS
  SELECT isitdate
  FROM (VALUES
          ('20110101'),
          ('20110102'),
          ('20110103X'),
          ('20110104'),
          ('20110105'),
          ('20110106'),
          ('20110107Y'),
          ('20110108')
       ) AS D (isitdate);
GO
