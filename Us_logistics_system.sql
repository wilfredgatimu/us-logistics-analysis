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
	Count(*) From  US_Logistics_Shipments;
Select *
From US_Logistics_Shipments
;
Select 	 
Carrier,     
Count(*)  As Total_Shipments
From US_Logistics_Shipments
Where Status = 'Delivered'
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
  Having Count(*) = 10
  Order by Avg_Cost_Per_Mile Desc
  Limit 15
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
Having Count(*) = 10
Order by Avg_Cost_Per_Mile Desc
;
Select	
Carrier,    
Origin_warehouse,    
Destination,    
Round(Avg(Cost / NullIF(Distance_miles, 0)), 2) As Avg_Cost_Per_Mile,    
Count(*) As Total_shipments,    
Sum(Cost) As Total_Spend
From US_Logistics_Shipments
Where Distance_miles > 0 
Group by Carrier, Origin_warehouse, Destination
Having Count(*) = 10
Order by Avg_Cost_Per_Mile Desc
;
Select	
Carrier,    
Origin_warehouse,    
Destination,    
Round(Avg(Cost / NullIF(Distance_miles, 0)), 2) As Avg_Cost_Per_Mile,    
Count(*) As Total_shipments,    
Sum(Cost) As Total_Spend
From US_Logistics_Shipments
Where Distance_miles > 0
Group by Carrier, Origin_warehouse, Destination
Order by Avg_Cost_Per_Mile Desc
;
Select	
Carrier,    
Origin_warehouse,    
Destination,    
Round(Avg(Cost / NullIF(Distance_miles, 0)), 2) As Avg_Cost_Per_Mile,    
Count(*) As Total_shipments,    
Sum(Cost) As Total_Spend
From US_Logistics_Shipments
Where Distance_miles > 0 
Group by Carrier, Origin_warehouse, Destination
Order by Avg_Cost_Per_Mile Desc
Limit 15
;
