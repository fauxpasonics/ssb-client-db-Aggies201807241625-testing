SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_Changes]  (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50)
Declare @sportabbrv varchar(20)
Declare @relocateproductid  int
Declare @renewalcategory varchar(20)
Declare @cancelproductid  int
Declare @tixeventtitleshort varchar(40)


select @tixeventlookupid = tixeventlookupid , @relocateproductid = relocateproductid, @cancelproductid = cancelproductid ,@renewalcategory = renewalcategory, @tixeventtitleshort = tixeventtitleshort
from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear


select * from (
select   cast( "Relocate Donor Count" as varchar) +  ' / ' + cast( 
(select  count(*) relocatetotal from seatdetail_individual_history g where seatpricecode not like '%SRO%' 
and cancel_ind is null and tixeventlookupid = @tixeventlookupid  and accountnumber in (select   distinct acct FROM  ADVEvents_tbl_order_line l
LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id WHERE o.category = @renewalcategory and renewal_descr not like    '%SRO%' 
AND submit_date IS NOT NULL and  l.product_id =@relocateproductid)) as varchar) "Relocate Counts" ,
  cast( "Release Donor Count" as varchar) +  ' / ' + cast( "Release Seats Count"as varchar)  "Release Counts" from (
select max(case when SeatChange = 'Relocate Seats'  then DonorCount else null end ) "Relocate Donor Count",
max(case when SeatChange = 'Relocate Seats'  then SeatCount  else null end  ) "Relocate Seats Count",
max(case when SeatChange = 'Release Seats'  then DonorCount else null end  ) "Release Donor Count",
max(case when SeatChange = 'Release Seats'  then SeatCount  else null end  ) "Release Seats Count" from (
           select SeatChange, count(acct ) seatcount ,   count( distinct acct) DonorCount from            
           (select case when  product_id = @relocateproductid  then 'Relocate Seats' 
           when product_id = @cancelproductid then 'Release Seats'
           else null end SeatChange,  o.acct          
           from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = @renewalcategory  --and renewal_descr like @tixeventtitleshort +'%'   
           and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and   product_id in (@cancelproductid, @relocateproductid )
           ) SeatChange 
          group by SeatChange
           ) T ) TTLLINE ) tline1 where "Relocate Counts"  is not null or "Release Counts" is not null
GO
