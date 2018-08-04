SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_2] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50)

set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear); 

select @sporttype  seatregionname, AnnualDue, Receipts, ScheduledAnnual, 
(receipts/annualDue) * 100 [Annual Received] , (receipts + ScheduledAnnual)/annualDue * 100 [Planned Receipts], 100 TTL,
receipts + ScheduledAnnual PlannedReceiptAmt from (
select 
sum(annual) AnnualDue, sum(isnull( "Adv Annual Receipt",0))  + sum(isnull(  "Adv Annual Match Receipt",0)) Receipts  ,
 sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual
from amy.rpt_seatrecon_tb  t where t.sporttype  = @sporttype and  ticketyear =  @ticketyear  and not (isnull(Comp, 0 ) + isnull(FacultyAD,0 ) + isnull(DC,0)   > 0  and ticketpaidpercent = 0)
--and "Ticket Total" is not null
) s
GO
