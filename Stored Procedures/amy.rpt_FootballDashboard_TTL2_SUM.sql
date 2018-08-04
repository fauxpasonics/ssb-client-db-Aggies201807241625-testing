SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_TTL2_SUM] as

declare @currentseason char(4)
declare @tixeventlookupid varchar(20)
declare @renewal_start_date datetime
set @currentseason = (select max(currentseason) from advcurrentyear)

set  @tixeventlookupid= (select tixeventlookupid from PriorityEvents where ticketyear = @currentseason  and sporttype = 'FB')
set   @renewal_start_date= (select  y.renewal_start_date  from PriorityEvents y where ticketyear = @currentseason  and sporttype = 'FB')
select tktype  + cast( ticketqtyrenewed  as varchar) + ' Complete / ' +  cast(ticketqty as varchar) + ' TTL Possible' "Ticket Requests" , "Donor Request", "ADA Request", "Faculty/Staff Request","Lettermen Request" from 
(
select  
'Add On: ' tktype,
count (distinct r.accountnumber  ) donorcount,
count(*) ticketqty , 
count (distinct case when renewal_date is not null or (paidpercent + schpercent >= .95 ) then r.accountnumber else null end  ) donorcountrenewed,
sum(case when renewal_date is not null or   (paidpercent + schpercent >= .95)  then 1 else 0 end) ticketqtyrenewed , 
sum(case when seatpricecode like 'Donor%'  then 1 else 0 end) "Donor Request",
sum(case when seatpricecode like 'ADA%' then 1 else 0 end) "ADA Request",
sum(case when seatpricecode like  'Faculty%Staff%' then 1 else 0 end) "Faculty/Staff Request",
sum(case when seatpricecode like'Lettermen%' then 1 else 0 end)"Lettermen Request"
from seatdetail_individual_history r  where tixeventlookupid =   @tixeventlookupid
and addonticket = 1  and cancel_ind is  null and accountnumber not in (select adnumber from advcontact where accountname like '%Test%') and seatpricecode <> 'Suite Member' and seatpricecode not  like '%SRO%'
union all
select   
'New: ' tktype,
count (distinct r.accountnumber  ) donorcount,
count(*) ticketqty , 
count (distinct case when renewal_date is not null  or (paidpercent + schpercent >= .95 ) then r.accountnumber else null end  ) donorcountrenewed,
sum(case when renewal_date is not null or (paidpercent + schpercent >= .95 ) then 1 else 0 end) ticketqtyrenewed , 
sum(case when seatpricecode like 'Donor%'  then 1 else 0 end) "Donor Request",
sum(case when seatpricecode like 'ADA%' then 1 else 0 end) "ADA Request",
sum(case when seatpricecode like  'Faculty%Staff%' then 1 else 0 end) "Faculty/Staff Request",
sum(case when seatpricecode like'Lettermen%' then 1 else 0 end)"Lettermen Request"
from seatdetail_individual_history r  where tixeventlookupid =  @tixeventlookupid and new_ticket = 1
  and cancel_ind is  null  and accountnumber not in (select adnumber from advcontact where accountname like '%Test%') and seatpricecode <> 'Suite Member' and seatpricecode not  like '%SRO%'
) t1
GO
