SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_Totals] as 
declare @currentseason char(4)
declare @tixeventlookupid varchar(20)
declare @renewalacctcnt int
declare @renewalannualexpected int
declare @renewalticketcnt int

set @currentseason = (select max(currentseason) from advcurrentyear)
select @renewalacctcnt = renewalacctcnt, @renewalticketcnt  = renewalticketcnt,@renewalannualexpected = renewalannualexpected
 from PriorityEvents  where sporttype ='FB' and ticketyear =@currentseason
 
 
select Cast(Donorrenewed as varchar) + ' ('+ Cast(perdonorrenewed as varchar)  + '%)'  "Donors Renewed",
Cast(ticketrenewed as varchar) + ' ('+ Cast(perticketrenewed as varchar)  + '%)'  "Tickets Renewed",
Cast((receipts+MatchReceipts) as varchar) + ' ('+ Cast(PerPaymentsReceived as varchar)  + '%)'  "Annual Received",
Cast((receipts + matchreceipts+ScheduledAnnual) as varchar) + ' ('+ Cast(PerScheduledReceived as varchar)  + '%)'  "Annual Received/Scheduled",
Cast(Pledge as varchar) + ' ('+ Cast(perpledge as varchar)  + '%)'  "Pledges"
from (
select s.*, ((receipts+MatchReceipts)/annualDue) * 100  PerPaymentsReceived, 
(receipts + matchreceipts+ScheduledAnnual)/annualDue * 100  PerScheduledReceived, 
 round(cast(donorrenewed as float )/ cast(@renewalacctcnt as float) *100 ,2)  perdonorrenewed , 
 round(cast( ticketrenewed as float)/cast(@renewalticketcnt  as float)*100 ,2)   perticketrenewed,
 round(Pledge/@renewalannualexpected*100,2) perpledge
from (
select  
 count(DISTINCT case when "Ticket Total" is not null  then adnumber else null end)  donorseatcounttotal,
COUNT (DISTINCT case when   renewed > 0
then ADNUMBER else NULL end)donorrenewed,
sum( t.Renewable ) ticketcounttotal,
sum( Renewed)  ticketrenewed,
sum(isnull("Adv Annual  Pledge",0 ) + isnull("Adv Annual Match Pledge",0 )) Pledge,
sum(annual) AnnualDue, sum(isnull( "Adv Annual Receipt",0))  Receipts  , sum(isnull(  "Adv Annual Match Receipt",0)) MatchReceipts ,  
 sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual
--SELECT TOP 100  *
from RPT_SEATrecon_TB  t where sporttype = 'FB' and ticketyear =@currentseason
--and "Ticket Total" is not null
) s ) TT
GO
