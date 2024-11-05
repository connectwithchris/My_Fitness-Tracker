/*Normalized flat file from the Fabric Lakehouse to the Data Warehouse. 
Used T-SQL to create views and utilized these views to build a semantic model for the Power BI report.*/

------------------------------------------------------------------------------------------------------

/*Created a view in the Data Warehouse from the Lakehouse for the fact_data fact table.*/

--DROP VIEW fact_data; --Be careful, as it will delete all the measures.
--CREATE VIEW fact_data AS

SELECT *
, CASE WHEN Steps >= 6000 THEN 'Yes' ELSE 'No' END AS ConsistencyTag
/*Created a conditional column for visualization 
because we can't create a calculated column using DAX in a semantic model.*/

FROM [CentralLakehouse].[dbo].[my_fitness_data];

------------------------------------------------------------------------------------------------------

/*Created a view in the Data Warehouse from the Lakehouse for the dim_date dimension table.*/

--DROP VIEW dim_date;
--CREATE VIEW dim_date AS

WITH CTE AS (
SELECT Date 
, YEAR(Date) AS Year, MONTH(Date) AS Month
, FORMAT(Date, 'MMM') AS MonthName
, FORMAT(Date, 'ddd') AS Weekday
, DATEPART(DW, Date) AS WeekdayNum
, DATEPART(WW, Date) AS WeekOfYear
FROM [CentralLakehouse].[dbo].[my_fitness_data]
)
SELECT *
, CONCAT(YEAR(Date), MONTH(Date)) AS YearMonth
, CONCAT(CAST(WeekdayNum AS VARCHAR), ' ', Weekday) AS WeekdaySort
, CONCAT(SUBSTRING(MonthName, 1, 3), '-', SUBSTRING(CAST(Year AS VARCHAR), 3, 4)) AS Month_Year
FROM CTE;

------------------------------------------------------------------------------------------------------

/*Created a view in the Data Warehouse from the Lakehouse for the last_4_months dimension table..*/

--DROP VIEW last_4_months;
--CREATE VIEW last_4_months AS

WITH CTE1 AS (
SELECT Date 
, CONCAT(YEAR(Date), MONTH(Date)) AS YearMonth
, FORMAT(Date, 'MMM') AS MonthName
FROM [CentralLakehouse].[dbo].[my_fitness_data]
)
, CTE2 AS (
SELECT DISTINCT YearMonth, MonthName
FROM CTE1
)
, CTE3 AS (
SELECT *
, ROW_NUMBER() OVER(ORDER BY YearMonth DESC) AS rn
FROM CTE2
)
SELECT YearMonth, MonthName FROM CTE3 WHERE rn <= 4;
