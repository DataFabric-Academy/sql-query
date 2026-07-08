/*---------------------------------------------------------------------
	บทที่ 03
	
	แบบฝึกหัด 4
---------------------------------------------------------------------*/

USE TSQL;
GO

/*---------------------------------------------------------------------
	งานที่ 1
---------------------------------------------------------------------*/

SELECT 
	p.categoryid
,	p.productname
FROM Production.Products AS p;

/*---------------------------------------------------------------------
	งานที่ 2
---------------------------------------------------------------------*/
SELECT 
	p.categoryid
,	p.productname
,	CASE p.categoryid
		WHEN 1 THEN 'Beverages'
		WHEN 2 THEN 'Condiments'
		WHEN 3 THEN 'Confections'
		WHEN 4 THEN 'Dairy Products'
		WHEN 5 THEN 'Grains/Cereals'
		WHEN 6 THEN 'Meat/Poultry'
		WHEN 7 THEN 'Produce'
		WHEN 8 THEN 'Seafood'
		ELSE 'Other'
	END AS categoryname
FROM Production.Products AS p;

/*---------------------------------------------------------------------
	งานที่ 3
---------------------------------------------------------------------*/
SELECT 
	p.categoryid
,	p.productname
,	CASE p.categoryid
		WHEN 1 THEN 'Beverages'
		WHEN 2 THEN 'Condiments'
		WHEN 3 THEN 'Confections'
		WHEN 4 THEN 'Dairy Products'
		WHEN 5 THEN 'Grains/Cereals'
		WHEN 6 THEN 'Meat/Poultry'
		WHEN 7 THEN 'Produce'
		WHEN 8 THEN 'Seafood'
		ELSE 'Other'
	END AS categoryname
,	CASE	
		WHEN p.categoryid IN (1, 7, 8) THEN 'Campaign Products'
		ELSE 'Non-Campaign Products' 
	END AS iscampaign
FROM Production.Products AS p;