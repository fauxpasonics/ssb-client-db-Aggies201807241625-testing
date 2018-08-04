SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_Changes] as

declare @currentseason char(4)
Declare @tixeventlookupid varchar(50)
Declare @sportabbrv varchar(20)
Declare @relocateproductid  int
Declare @renewalcategory varchar(20)
Declare @cancelproductid  int
Declare @tixeventtitleshort varchar(40)




set @currentseason = (select max(currentseason) from advcurrentyear)

select @tixeventlookupid = tixeventlookupid , @relocateproductid = relocateproductid, @cancelproductid = cancelproductid ,@renewalcategory = renewalcategory, @tixeventtitleshort = tixeventtitleshort
from amy.PriorityEvents pe1 where sporttype = 'FB' and ticketyear =@currentseason 

select   cast( "Relocate Donor Count" as varchar)  +  ' / '  + cast(  (select  count(*) relocatetotal from seatdetail_individual_history g where seatpricecode not like '%SRO%' 
and cancel_ind is null and tixeventlookupid = 'F18-Season' and accountnumber in (select   distinct acct FROM  ADVEvents_tbl_order_line l
LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id WHERE o.category = '2018' + 'FB' and renewal_descr not like    '%SRO%'  AND submit_date IS NOT NULL and  l.product_id =100)) as varchar) 
"Relocate Counts" ,
  cast( "Release Donor Count" as varchar) +  ' / ' + cast( "Release Seats Count"as varchar)  "Release Counts" from (
select max(case when SeatChange = 'Relocate Seats'  then DonorCount else null end ) "Relocate Donor Count",
max(case when SeatChange = 'Relocate Seats'  then SeatCount   else null end  ) "Relocate Seats Count",
max(case when SeatChange = 'Release Seats'  then DonorCount else null end  ) "Release Donor Count",
max(case when SeatChange = 'Release Seats'  then SeatCount  else null end  ) "Release Seats Count" from (
SELECT  case when l.product_id = 100 then 'Relocate Seats' 
           when l.product_id = 98 then 'Release Seats'
           else null end SeatChange,   count( distinct o.acct) DonorCount,  count(  o.acct) SeatCount 
FROM  ADVEvents_tbl_order_line l
LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
left join (
select g.accountnumber, count(*) relocatetotal from seatdetail_individual_history g where seatpricecode not like '%SRO%' 
and cancel_ind is not null and tixeventlookupid = @tixeventlookupid
group by g.accountnumber) tk on o.acct =  tk.accountnumber
--LEFT JOIN events..tbl_product p ON p.id = l.product_id
WHERE o.category = @currentseason + 'FB' and renewal_descr not like    '%SRO%'  -- and renewal_descr  like   @currentseason +' Football Season%'
AND submit_date IS NOT NULL
--AND p.category IN ('2016FB-RELOCATE', '2016FB-RELEASE')'2016FB-RELOCATE' (454), '2016FB-RELEASE'(467)
and  l.product_id in (98, 100)
group by  case when l.product_id = 100 then 'Relocate Seats' 
           when l.product_id = 98 then 'Release Seats'
           else null end  ) T ) TTLLINE
GO
