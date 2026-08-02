create database finalproject;
use finalproject;
select *from walmartsales;
#=============================================================================================
#TASK 1  Identifying the Top Branch by Sales Growth Rate (6 Marks)
WITH MonthlySales AS
(SELECT Branch,
        DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS YearMonth, 
	    SUM(Total) AS TotalSales
FROM walmartsales
GROUP BY Branch, YearMonth),
MonthlyGrowth AS (
SELECT Branch,
	   YearMonth,
	   TotalSales,
	   LAG(TotalSales) OVER (PARTITION BY Branch ORDER BY YearMonth) AS PrevMonthSales
FROM MonthlySales
)
SELECT Branch,
    AVG(((TotalSales - PrevMonthSales) / PrevMonthSales) * 100) AS AvgMonthlyGrowthRate
FROM MonthlyGrowth
WHERE PrevMonthSales IS NOT NULL
GROUP BY Branch
ORDER BY AvgMonthlyGrowthRate DESC
limit 1;
#===========================================================================
#TASK 2:- Finding the Most Profitable Product Line for Each Branch (6 Marks)

WITH profitline_of_all_branches as
(select 
      Branch,
      `Product line`,Sum(Total),Sum(cogs) ,Sum(Total)-Sum(cogs) as grossincome
      from walmartsales 
      group by Branch ,`Product line`
)
select
      Branch,
      `Product line`
      ,grossincome
from profitline_of_all_branches
where (Branch,grossincome) in
(select Branch ,Max(grossincome) 
 from profitline_of_all_branches 
 group by Branch)
 order by Branch;

 #=========================================================================
 
 #Task 3: Analyzing Customer Segmentation Based on Spending (6 Marks)
 
 select *from walmartsales;
 with avgspendcus as
 (select `Customer ID` ,Avg(Total) as avgspend from walmartsales
 group by `Customer ID` )
 
SELECT `Customer ID`,
        avgspend as averagespending,
        
CASE WHEN avgspend between 260 AND 300 THEN 'LOW'
     WHEN avgspend between 301 AND 350 THEN 'MEDIUM'
     ELSE 'HIGH'
     End as `category wise spending`
from avgspendcus
order by avgspend desc;

#===============================================================================
#Task 4: Detecting Anomalies in Sales Transactions (6 Marks)

WITH ProductLineAverage AS (
    SELECT `Product line`, AVG(Total) AS avg_sales
    FROM walmartsales
    GROUP BY `Product line`)
SELECT w.`Customer ID`,w.`Product line`,w.Total AS transaction_sales,
    pl.avg_sales,
    ABS(w.Total - pl.avg_sales) AS difference_from_avg,
    CASE WHEN ABS(w.Total - pl.avg_sales) > pl.avg_sales * 1.5 THEN 'Anomaly'
         ELSE 'Normal'
    END AS transaction_status
FROM walmartsales w
JOIN ProductLineAverage pl
    ON w.`Product line` = pl.`Product line`
ORDER BY transaction_status DESC, transaction_sales DESC;

#======================================================================================
#Task 5: Most Popular Payment Method by City (6 Marks)
select *from walmartsales;
Select 
      City,
      Payment,
      Count(*) as count
from walmartsales
Group by Payment,City
order by count desc
limit 3;

WITH PaymentMethodCount AS (
    SELECT City, Payment, COUNT(*) AS PaymentCount
    FROM walmartsales
    GROUP BY City, Payment
)
SELECT City, Payment
FROM PaymentMethodCount
WHERE (City, PaymentCount) IN (
        SELECT City, MAX(PaymentCount) AS MaxCount
        FROM PaymentMethodCount
        GROUP BY City)
ORDER BY City;

#================================================================================
#Task 6: Monthly Sales Distribution by Gender (6 Marks)
select *from walmartsales;
select Gender,
	   DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m') AS YearMonth, 
       SUM(Total)  as total 
from walmartsales
group by Gender,YearMonth
order by YearMonth asc;
#===================================================================================

#Task 7: Best Product Line by Customer Type (6 Marks)

Select `Customer Type` ,`Product line`,SUM(Total) as total
from walmartsales 
group by `Customer Type`,`Product line`
order by total desc
limit 2;


#++++++++++++++++++++++++++======================================================


SELECT `Customer Type`, `Product line`, SUM(Total) AS total
FROM walmartsales
GROUP BY `Customer Type`, `Product line`
HAVING SUM(Total) = (
        SELECT MAX(total_sales)
        FROM (SELECT `Customer Type`, `Product line`, SUM(Total) AS total_sales
              FROM walmartsales
             GROUP BY `Customer Type`, `Product line`
        ) AS max_sales_per_product
        WHERE max_sales_per_product.`Customer Type` = walmartsales.`Customer Type`
    )
ORDER BY `Customer Type`;

#==========================================================================================
#Task 8: Identifying Repeat Customers (6 Marks)
select *from walmartsales;



WITH CustomerPurchases AS (
    SELECT `Customer ID`,
        STR_TO_DATE(`Date`, '%d-%m-%Y') AS PurchaseDate,
        `Invoice ID`,
        `Product line`,
        ROW_NUMBER() OVER (PARTITION BY `Customer ID` ORDER BY STR_TO_DATE(`Date`, '%d-%m-%Y')) AS PurchaseSeq
    FROM walmartsales
)

SELECT 
    a.`Customer ID`,
    DATE_FORMAT(a.PurchaseDate, '%d-%m-%Y') AS FirstPurchaseDate,
    DATE_FORMAT(b.PurchaseDate, '%d-%m-%Y') AS SecondPurchaseDate,
    DATEDIFF(b.PurchaseDate, a.PurchaseDate) AS DaysBetweenPurchases,
    a.`Product line` AS FirstPurchaseCategory,
    b.`Product line` AS SecondPurchaseCategory,
    a.`Invoice ID` AS FirstInvoiceID,
    b.`Invoice ID` AS SecondInvoiceID
FROM CustomerPurchases a
JOIN CustomerPurchases b 
    ON a.`Customer ID` = b.`Customer ID`
    AND a.PurchaseSeq = b.PurchaseSeq - 1
WHERE DATEDIFF(b.PurchaseDate, a.PurchaseDate) <= 30
ORDER BY a.`Customer ID`, a.PurchaseDate;

#===================================================================================================
select *from walmartsales;
#Task 9: Finding Top 5 Customers by Sales Volume (6 Marks)
 #Walmart wants to reward its top 5 customers who have generated the most sales Revenue
 
 SELECT `Customer ID`,Sum(Total) as total_revenue
 from walmartsales 
 group by `Customer ID`
 Order by total_revenue desc
 limit 5;

#=========================================================================================
# Task 10: Analyzing Sales Trends by Day of the Week (6 Marks)
select *from walmartsales;

select DAYNAME(STR_TO_DATE(`Date`, '%d-%m-%Y')) AS DayOfWeek,Sum(Total) as totalsale
from walmartsales
group by DayOfWeek
order by totalsale desc;

#=================================================THANK YOU=============================================================================
