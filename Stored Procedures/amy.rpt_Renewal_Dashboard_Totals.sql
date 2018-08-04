SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_Totals]  (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS
declare @tixeventlookupid varchar(20)
declare @renewalacctcnt int
declare @renewalannualexpected int
declare @renewalticketcnt int


set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

select @renewalacctcnt = renewalacctcnt, @renewalticketcnt  = renewalticketcnt,@renewalannualexpected = renewalannualexpected
 from PriorityEvents  where sporttype =@sporttype  and ticketyear = @ticketyear

select Cast(Donorrenewed as varchar) + ' ('+ Cast(perdonorrenewed as varchar)  + '%)'  "Donors Renewed",
Cast(ticketrenewed as varchar) + ' ('+ Cast(perticketrenewed as varchar)  + '%)'  "Tickets Renewed",
Cast(receipts+MatchReceipts as varchar) + ' ('+ Cast(PerPaymentsReceived as varchar)  + '%)'  "Annual Received",
Cast((receipts + matchreceipts+ScheduledAnnual) as varchar) + ' ('+ Cast(PerScheduledReceived as varchar)  + '%)'  "Annual Received/Scheduled",
Cast(Pledge as varchar) + ' ('+ Cast(perpledge as varchar)  + '%)'  "Pledges"
from (
select s.*, ((receipts+MatchReceipts)/annualDue) * 100  PerPaymentsReceived, 
(receipts + matchreceipts+ScheduledAnnual)/annualDue * 100  PerScheduledReceived, 
 round(cast(donorrenewed as float )/cast(isnull(@renewalacctcnt,donorseatcounttotal) as float)*100 ,2)  perdonorrenewed , 
 round(cast( ticketrenewed as float)/cast(isnull(@renewalticketcnt,ticketcounttotal) as float)*100 ,2)   perticketrenewed,
 round(Pledge/isnull(@renewalannualexpected,AnnualDue)*100,2) perpledge
from (
select  
count( distinct adnumber) donorseatcounttotal,
COUNT (DISTINCT case when   renewed > 0 then ADNUMBER else NULL end)donorrenewed,
sum( t.Renewable ) ticketcounttotal,
sum( Renewed)  ticketrenewed,
sum(isnull("Adv Annual  Pledge",0 ) + isnull("Adv Annual Match Pledge",0 )) Pledge,
sum(annual) AnnualDue,
sum(isnull( "Adv Annual Receipt",0))  Receipts  , 
sum(isnull(  "Adv Annual Match Receipt",0)) MatchReceipts ,  
 sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual
from amy.rpt_seatrecon_tb  t where
  sporttype = @sporttype and ticketyear = @ticketyear 
   --and not ( isnull(  [UO-R], 0 ) +isnull( UO,  0 ) + isnull(Comp, 0 ) + isnull(FacultyAD,0 ) + isnull(DC,0)   > 0  and ticketpaidpercent = 0)
--and "Ticket Total" is not null
) s ) TT
GO
