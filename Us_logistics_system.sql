CREATE TABLE US_Logistics_Shipments 
(    
 Shipment_id VARCHAR(20),   
 Origin_warehouse VARCHAR(50),    
 Destination VARCHAR(50),    
 Carrier VARCHAR(50),    
 Shipment_date VARCHAR(20),    
 Delivery_date VARCHAR(20),    
 Weight_Kg DECIMAL(10,2),    
 Cost DECIMAL(10,2),    
 Status VARCHAR(20),    
 Distance_Miles DECIMAL(10,2),    
 Transit_days INT
 )
;

Insert into US_Logistics_Shipments
Select *
From logistics_shipments
;

Select *
From US_Logistics_Shipments
;

Select 
	Count(*) From  US_Logistics_Shipments
;


Select 	 
Carrier, 
status,    
Count(*)  As Total_Shipments
From US_Logistics_Shipments
Where Status = 'Delivered'
group by status, Carrier
order by Total_Shipments Desc
;

Select 	 
Carrier,     
Count(*)  As Total_Shipments,     
Sum(Case When delivery_date = date_add(Shipment_date, interval Transit_days Day)	Then 1 	Else 0 End) As On_time_shipments,		
round(100.0 * Sum(Case When delivery_date &lt= Date_Add(shipment_date, Interval Transit_days Day)					Then 1 Else 0 End) / Count(*), 2) As On_time_Rate_percent
From US_Logistics_Shipments
Where Status = 'Delivered' And Delivery_date Is not Null
group by Carrier
Order by On_time_Rate_percent Asc
;

Select	
  Carrier,    
  Origin_warehouse,    
  Destination,    
  Round(Avg(Cost / NullIF(Distance_miles, 0)), 2) As Avg_Cost_Per_Mile,    
  Count(*) As Total_shipments,    
  Sum(Cost) As Total_Spend
  From US_Logistics_Shipments
  Where Distance_Miles > 0
  Group by Carrier, Origin_warehouse, Destination
  Having Count(*) = 3
  Order by Avg_Cost_Per_Mile Desc
  Limit 15
;



-- WEIGHT TIER ANALYSIS
SELECT 
CASE 
  WHEN Weight_kg < 10 THEN '0-10KG'
  WHEN Weight_Kg < 25 THEN '10-25KG'
  WHEN Weight_Kg < 50 THEN '25-50KG'
  ELSE '50KG+'
END AS Weight_tier,
COUNT(*) AS Shipments,
ROUND(AVG(Cost / NULLIF(Weight_Kg, 0)), 2) AS Cost_per_kg,
ROUND(AVG(Cost / NULLIF(Distance_Miles, 0)), 2) AS Cost_per_mile
FROM US_Logistics_Shipments
WHERE Weight_Kg > 0 AND Distance_Miles > 0
GROUP BY Weight_tier
ORDER BY Cost_per_kg DESC
;

-- DELAY ANALYSIS BY ROUTE
SELECT 
Carrier,
Origin_warehouse,
Destination,
AVG(Transit_days) AS Avg_Promised_Days,
AVG(DATEDIFF(Delivery_date, Shipment_date)) AS Avg_Actual_Days,
ROUND(AVG(DATEDIFF(Delivery_date, Shipment_date) - Transit_days), 2) AS Avg_delay_days
FROM US_Logistics_Shipments
WHERE Status = 'Delivered' AND Delivery_date IS NOT NULL
GROUP BY Carrier, Origin_warehouse, Destination
ORDER BY Avg_delay_days DESC
LIMIT 10
;

-- PAGE 3: TOP COSTLY ROUTES 
SELECT 
CONCAT(Origin_warehouse, ' ', Destination) AS Route,
COUNT(*) AS Shipments,
SUM(Cost) AS Total_Cost,
AVG(DATEDIFF(Delivery_date, Shipment_date)) AS Avg_delivery_Days,
ROUND(100.0 * SUM(CASE WHEN Delivery_date > DATE_ADD(Shipment_date, INTERVAL Transit_days DAY) THEN 1 ELSE 0 END) / COUNT(*), 1) AS Late_rate_percent
FROM US_Logistics_Shipments
WHERE Status = 'Delivered'
GROUP BY Origin_warehouse, Destination
ORDER BY Total_Cost DESC, Late_rate_percent DESC
LIMIT 10
;
-- LA Vs Hou per mile
SELECT 
CONCAT(Origin_warehouse, ' ', Destination) AS Route,
Carrier,
COUNT(*) AS Shipments,
ROUND(SUM(Cost), 2) AS Total_Cost,
ROUND(AVG(Cost / NULLIF(Distance_Miles, 0)), 2) AS Cost_Per_Mile
FROM US_Logistics_Shipments
WHERE Status = 'Delivered'
AND CONCAT(Origin_warehouse, ' ', Destination) IN ('Warehouse_LA San Francisco', 'Warehouse_HOU Detroit')
GROUP BY Route, Carrier
ORDER BY Total_Cost DESC
;
-- La Vs Hou Per Kg
SELECT 
CONCAT(Origin_warehouse, ' ', Destination) AS Route,
ROUND(AVG(Weight_Kg), 1) AS Avg_Weight_Kg,
ROUND(AVG(Cost / NULLIF(Weight_Kg, 0)), 2) AS Cost_Per_Kg
FROM US_Logistics_Shipments
WHERE Status = 'Delivered'
AND CONCAT(Origin_warehouse, ' ', Destination) IN ('Warehouse_LA San Francisco', 'Warehouse_HOU Detroit')
GROUP BY Route
;

-- PAGE 6: MONTHLY TREND
SELECT 
DATE_FORMAT(Shipment_date, '%Y-%m') AS Month,
COUNT(*) AS Shipments,
SUM(Cost) AS Monthly_Cost,
ROUND(AVG(DATEDIFF(Delivery_date, Shipment_date)), 1) AS Avg_Delivery_Days,
ROUND(100.0 * SUM(CASE WHEN Delivery_date > DATE_ADD(Shipment_date, INTERVAL Transit_days DAY) THEN 1 ELSE 0 END) / COUNT(*), 1) AS Late_Rate_Percent
FROM US_Logistics_Shipments
WHERE Shipment_date IS NOT NULL
GROUP BY DATE_FORMAT(Shipment_date, '%Y-%m')
ORDER BY Month
;

--  WAREHOUSE PROBLEM RATE 
SELECT 
Origin_warehouse,
COUNT(*) AS Shipments_Out,
ROUND(AVG(DATEDIFF(Delivery_date, Shipment_date)), 1) AS Avg_Delivery_Days,
ROUND(100.0 * SUM(CASE WHEN Status = 'Delayed' OR Status = 'Lost' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Problem_Rate_Percent
FROM US_Logistics_Shipments
WHERE Shipment_date IS NOT NULL
GROUP BY Origin_warehouse
ORDER BY Problem_Rate_Percent DESC
;

-- On-Time Rate by Carrier
SELECT Carrier, 
COUNT(*) AS Total_Shipments,
ROUND(100.0 * SUM(CASE WHEN Delivery_date <= DATE_ADD(Shipment_date, INTERVAL Transit_days DAY) THEN 1 ELSE 0 END) / COUNT(*), 2) AS On_time_Rate_percent
FROM US_Logistics_Shipments 
WHERE Status='Delivered' AND Delivery_date IS NOT NULL GROUP BY Carrier ORDER BY On_time_Rate_percent ASC
;



