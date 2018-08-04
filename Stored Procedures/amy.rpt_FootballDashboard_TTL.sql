SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_TTL] as 
declare @currentseason char(4)
declare @tixeventlookupid varchar(20)
declare @renewalacctcnt int
declare @renewalannualexpected int
declare @renewalticketcnt int

set @currentseason = (select max(currentseason) from advcurrentyear)
select @renewalacctcnt = renewalacctcnt, @renewalticketcnt  = renewalticketcnt,@renewalannualexpected = renewalannualexpected
 from PriorityEvents  where sporttype ='FB' and ticketyear =@currentseason

select   Cast(Donorrenewed as varchar) + ' of ' +  convert(VARCHAR,@renewalacctcnt,1) + ' ('+ Cast(perdonorrenewed as varchar)  + '%) Web:' +  Cast( webrenewals as varchar) + ' ('+ Cast(perwebrenewed as varchar)  + '%)'  "Donors Renewed",
  Cast(ticketrenewed as varchar) +   ' of ' +   convert(VARCHAR,@renewalticketcnt,1)  +' ('+ Cast(perticketrenewed as varchar)  + '%)'  "Tickets Renewed",
 '$' + convert(VARCHAR,receipts+matchreceipts,1) + ' ('+ Cast(PerPaymentsReceived as varchar)  + '%)'  "Annual Received",
 '$' + convert(varchar,(receipts + matchreceipts+ScheduledAnnual) ,1) + ' ('+ Cast(PerScheduledReceived as varchar)  + '%)'  "Annual Received/Scheduled",
 '$' + convert(varchar,pledge,1)  +  ' of ' +  '$' +convert(varchar,cast(@renewalannualexpected as money) ,1)  --+ ' ('+ Cast(perpledge as varchar)  + '%)' 
 "Annual Pledges",
 '$' + convert(varchar,ALLCAPPledge,1) "CAP Pledges",
 '$' + convert(varchar,ALLCAPRECEIPTS,1)+ ' ('+ Cast(percapreceived as varchar)  + '%)' "CAP Receipts",
 '$' + convert(varchar,cast(OutstandingCAP as money),1) --+ ' (' -- + Cast(percapoutstanding as varchar)  + '/' 
 --+ Cast(percapoutstandingsuite as varchar) + '/' +  Cast(percapoutstandingns as varchar)  +')' 
 "CAP Expected (All/S/NS)" --, 
 --'$' + convert(varchar,cast(OutstandingSUITECAP as money),1)+ ' ('+ Cast(percapoutstandingsuite as varchar)  + '%)' "CAP Expected(Suite)",
-- '$' + convert(varchar,cast(OutstandingNONSUITECAP as money),1)+ ' ('+ Cast(percapoutstandingns as varchar)  + '%)' "CAP Expected(NonSuite)"
, donorseatcounttotal
from (
select s.*, ((receipts + matchreceipts)/annualDue) * 100  PerPaymentsReceived, 
(receipts + matchreceipts+ScheduledAnnual)/annualDue * 100  PerScheduledReceived, 
 round(cast(webrenewals as float )/ cast(@renewalacctcnt as float)   --cast(donorseatcounttotal as float)
 *100 ,2)  perwebrenewed , 
  round(cast(donorrenewed as float )/ cast(@renewalacctcnt as float)   --cast(donorseatcounttotal as float)
 *100 ,2)  perdonorrenewed , 
 round(cast( ticketrenewed as float)/  cast(@renewalticketcnt  as float) --cast(ticketcounttotal as float)
 *100 ,2)   perticketrenewed,
 round(pledge/@renewalannualexpected*100,2) perpledge,
 round(ALLCAPRECEIPTS/ALLCAPPledge*100,2) percapreceived,
 round(cast(OutstandingCAP as float)/cast(ALLCAPPledge as float)*100,1) percapoutstanding
 --, 
 --round(cast(OutstandingNONSUITECAP as float)/cast(ALLCAPPledge as float)*100,1) percapoutstandingns,
  --round(cast(OutstandingSUITECAP as float)/cast(ALLCAPPledge as float)*100,1) percapoutstandingsuite
from (
select  
 count(DISTINCT case when renewable > 0 then adnumber else null end) donorseatcounttotal,
COUNT (DISTINCT case when renewed > 0
then ADNUMBER else NULL end) donorrenewed,
COUNT (DISTINCT case when   renewed > 0 and
 ( renewal_date is not null) 
then ADNUMBER else NULL end) webrenewals,
sum(renewable ) ticketcounttotal,
sum(renewed) ticketrenewed,
sum(isnull("Adv Annual  Pledge",0 ) + isnull("Adv Annual Match Pledge",0 )) Pledge,
sum(annual) AnnualDue, 
sum(isnull( "Adv Annual Receipt",0))  Receipts  ,
sum(isnull(  "Adv Annual Match Receipt",0)) MatchReceipts ,  
 sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual,
 sum(isnull( "Adv CAP Pledge",0) +isnull("Adv CAP Match Pledge",0)) ALLCAPPledge,
 sum(isnull("Adv CAP Receipt AMount",0) + isnull("Adv CAP Match Receipt",0)) ALLCAPRECEIPTS,  
sum( case when   isnull(t.capstilldue,0)  >  0 then isnull(t.capstilldue,0) else 0 end ) OutstandingCAP    ,
--sum(case when OutstandingNONSUITECAP > 0 then OutstandingNONSUITECAP else 0 end) OutstandingNONSUITECAP,
--sum(case when  OutstandingSUITECAP  >  0 then OutstandingSUITECAP else 0 end) OutstandingSUITECAP
max(ordergroupbottomlinegrandtotal) ordergroupbottomlinegrandtotal,
max(ordergrouptotalpaymentscleared) ordergrouptotalpaymentscleared,
max(ordergrouptotalpaymentsonhold) ordergrouptotalpaymentsonhold,
sum("Adv Annual Credit") "Adv Annual Credit"
 from (
select adnumber , 
sum("Ticket Total") "Ticket Total",
sum(renewable ) renewable,
sum(renewed) renewed,
 sum(isnull( "Adv Annual Receipt" ,0)) "Adv Annual Receipt",
 sum( isnull(  "Adv Annual Match Receipt",0) ) "Adv Annual Match Receipt",
 sum( isnull(  "AnnualScheduledPayments",0) )   "AnnualScheduledPayments",
 min( isnull(t.ticketpaidpercent,0)) ticketpaidpercent,
 min(min_annual_receipt_date) min_annual_receipt_date,
sum(isnull("Adv Annual  Pledge",0 ))"Adv Annual  Pledge", 
sum(isnull("Adv Annual Match Pledge",0 )) "Adv Annual Match Pledge",
sum(annual) annual,
 sum(isnull( "Adv CAP Pledge",0)) "Adv CAP Pledge",
 sum(isnull("Adv CAP Match Pledge",0)) "Adv CAP Match Pledge",
 sum(isnull("Adv CAP Receipt AMount",0)) "Adv CAP Receipt AMount",
 sum( isnull("Adv CAP Match Receipt",0)) "Adv CAP Match Receipt",
sum(capstilldue ) capstilldue,
--sum(case when  seatregionname not like '%Suite%' then (isnull(t.capstilldue,0)) else 0 end)OutstandingNONSUITECAP,
--sum(case when  seatregionname like '%Suite%' then isnull(t.capstilldue,0) else 0 end) OutstandingSUITECAP,
 sum( isnull(t.Annual,0)) ExpectedPledge,
 sum(isnull( t.newitems+ t.addeditems ,0)) newtickets ,
 min(renewal_date) renewal_date,
 t.ordergroupbottomlinegrandtotal, t.ordergrouptotalpaymentscleared, t.ordergrouptotalpaymentsonhold,
 sum(isnull("Adv Annual Credit",0) ) "Adv Annual Credit"
--select top 100 *
from RPT_SEATrecon_TB  t where sporttype = 'FB' and ticketyear = @currentseason
group by adnumber,  t.ordergroupbottomlinegrandtotal, t.ordergrouptotalpaymentscleared, t.ordergrouptotalpaymentsonhold
) t     --and not (isnull(Comp, 0 ) + isnull(FacultyAD,0 ) + isnull(DC,0)   > 0 
--and   ((isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) 
--or isnull(t.ticketpaidpercent,0) > 0 or min_annual_receipt_date is not null   ))
--and "Ticket Total" is not null
) s ) TT
GO
