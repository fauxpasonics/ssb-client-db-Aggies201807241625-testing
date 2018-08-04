SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_TTL] (@sporttype varchar(20) , 
 @ticketyear varchar(4)
 )
AS


declare @tixeventlookupid varchar(20)
declare @renewalacctcnt int
declare @renewalannualexpected int
declare @renewalticketcnt int

select @renewalacctcnt = renewalacctcnt, @renewalticketcnt  = renewalticketcnt,@renewalannualexpected = renewalannualexpected
 from PriorityEvents  where sporttype =@sporttype and ticketyear = @ticketyear
 
set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

select * from (
select  case when Donorrenewed = 0  then null else Cast(Donorrenewed as varchar) + ' ('+ Cast(perdonorrenewed as varchar)  + '%)' end  "Donors Renewed",
  Cast(ticketrenewed as varchar) + ' ('+ Cast(perticketrenewed as varchar)  + '%)'  "Tickets Renewed",
 '$' + convert(VARCHAR,receipts,1) + ' ('+ Cast(PerPaymentsReceived as varchar)  + '%)'  "Annual Received",
 '$' + convert(varchar,(receipts+ScheduledAnnual) ,1) + ' ('+ Cast(PerScheduledReceived as varchar)  + '%)'  "Annual Received/Scheduled",
 '$' + convert(varchar,Pledge,1) + ' ('+ Cast(perpledge as varchar)  + '%)'  "Annual Pledges",
 '$' + convert(varchar,ALLCAPPledge,1) "CAP Pledges",
 '$' + convert(varchar,ALLCAPRECEIPTS,1)+ ' ('+ Cast(percapreceived as varchar)  + '%)' "CAP Receipts",
 '$' + convert(varchar,cast(OutstandingCAP as money),1)    "CAP Expected" 
from (
select s.*, 
 case when  annualDue  <> 0 then  (receipts/annualDue) * 100  else 0 end PerPaymentsReceived, 
 case when  annualDue  <> 0 then  (receipts + matchreceipts+ScheduledAnnual)/annualDue * 100  else 0 end PerScheduledReceived, 
  case when cast(@renewalacctcnt as float)  <> 0 then  round(cast(donorrenewed as float )/cast(@renewalacctcnt as float)*100 ,2) else 0 end  perdonorrenewed ,  --replace  donorseatcounttotal
  case when cast(@renewalticketcnt as float) <> 0 then  round(cast( ticketrenewed as float)/cast( @renewalticketcnt as float)*100 ,2) else 0 end    perticketrenewed,  --replace  ticketcounttotal 
  case when @renewalannualexpected  <> 0 then  round(Pledge/@renewalannualexpected*100,2) else 0 end  perpledge,  --replace AnnualDue
 case when  ALLCAPPledge*100  <> 0 then round(ALLCAPRECEIPTS/ALLCAPPledge*100,2) else 0 end  percapreceived,
 case when  cast(ALLCAPPledge as float)*100  <> 0 then  round(cast(OutstandingCAP as float)/ cast(ALLCAPPledge as float)*100,1) else 0 end percapoutstanding 
from (
select  
sum("Ticket Total") "Ticket Total",
sum(renewable ) renewable,
sum(renewed) renewed,
count(DISTINCT case when renewable > 0  then adnumber else null end) donorseatcounttotal,
COUNT (DISTINCT case when  renewed >0 then ADNUMBER else NULL end) donorrenewed,
sum(renewable) ticketcounttotal,
sum(renewed) ticketrenewed,
sum(isnull("Adv Annual  Pledge",0 ) + isnull("Adv Annual Match Pledge",0 )) Pledge,
sum(annual) AnnualDue, sum(isnull( "Adv Annual Receipt",0)+ isnull(  "Adv Annual Match Receipt",0))  Receipts  , 
 sum(isnull( "Adv Annual Receipt",0))  RegReceipts  , 
sum(isnull(  "Adv Annual Match Receipt",0)) MatchReceipts ,  
 sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual,
 sum(isnull( "Adv CAP Pledge",0) +isnull("Adv CAP Match Pledge",0)) ALLCAPPledge,
 sum(isnull("Adv CAP Receipt AMount",0) + isnull("Adv CAP Match Receipt",0)) ALLCAPRECEIPTS,
sum(case when CapStillDue  >  0  then CapStillDue else 0 end) OutstandingCAP
from amy.rpt_seatrecon_tb  t where  sporttype = @sporttype and ticketyear = @ticketyear
--and not (isnull(Comp, 0 ) + isnull(FacultyAD,0 ) + isnull(DC,0)   > 0  and ticketpaidpercent = 0)
--and "Ticket Total" is not null
) s ) TT ) t1 -- where "Donors Renewed" is not null
GO
