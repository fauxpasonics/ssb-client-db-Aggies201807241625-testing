SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_Renewal_Dashboard_TTL2_SUM] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50)

set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);


select case when donorcount = 0 then null else cast(donorcount as varchar) + ' / ' +  cast(ticketqty as varchar) end "Ticket Requests" , "Donor Request", "ADA Request", "Faculty/Staff Request","Lettermen Request" from 
(
select   
count (distinct r.accountnumber  ) donorcount,
sum(r.qty) ticketqty , 
sum(case when seatpricecode in( 'Donor Request','TBA Season')  then qty else 0 end) "Donor Request",
sum(case when seatpricecode = 'ADA Request' then qty else 0 end) "ADA Request",
sum(case when seatpricecode like  'Faculty%Staff Request' then qty else 0 end) "Faculty/Staff Request",
sum(case when seatpricecode = 'Lettermen Request' then qty else 0 end)"Lettermen Request"
from seatdetail_flat r  where tixeventlookupid =@tixeventlookupid  and (seatpricecode like '%Request%' or seatpricecode like '%TBA%')
) t1 where donorcount <> 0
GO
