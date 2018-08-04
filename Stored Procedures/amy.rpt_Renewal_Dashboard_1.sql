SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_1] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50) 
declare @renewal_start_date date
select @renewal_start_date =renewal_start_date  from priorityevents where sporttype = @sporttype and ticketyear =   @ticketyear

select case when Cdate >=  dateadd(DAY,50,@renewal_start_date) then dateadd(DAY,50,@renewal_start_date)  else cdate end Cdate, 
sum(donorseatcount) donorseatcount ,
sum(Pledge) Pledge, 
sum(PaymentReceived)  PaymentReceived,
sum(AmountwithScheduledPayment) AmountwithScheduledPayment
 from (
select convert( date,convert( varchar, case when renewal_date is null   and t.min_annual_receipt_date is  null
and  (isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) 
then dateadd(DAY,-5,@renewal_start_date) 
when renewal_date is not null then renewal_date
when t.min_annual_receipt_date  is not null and t.min_annual_receipt_date  <dateadd(DAY,-5,@renewal_start_date) then  dateadd(DAY,-5,@renewal_start_date) 
when t.min_annual_receipt_date  is not null then t.min_annual_receipt_date
else dateadd(DAY,-5,@renewal_start_date) end ,101 ))  Cdate,
count( distinct case when renewal_complete = 1   and renewed >=1 then adnumber else 0 end)
donorseatcount,
sum(isnull("Adv Annual  Pledge",0) + isnull("Adv Annual Match Pledge",0)) Pledge,
sum( isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) ) PaymentReceived,
sum( isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0)) AmountwithScheduledPayment --,
--sum(annual) AnnualDue, sum(isnull( "Adv Annual Receipt",0))  Receipts  , 
--sum(isnull(  "Adv Annual Match Receipt",0)) MatchReceipts ,  
--- sum(isnull(  "AnnualScheduledPayments",0)) ScheduledAnnual
from RPT_SEATrecon_TB  t where ticketyear =  @ticketyear and sporttype = @sporttype
---and "Ticket Total" is not null 
  and  ((isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) or isnull(t.ticketpaidpercent,0) > 0  or min_annual_receipt_date is not null)
group by 
convert( date,convert( varchar, case when renewal_date is null   and t.min_annual_receipt_date is  null
and  (isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) 
then dateadd(DAY,-5,@renewal_start_date) 
when renewal_date is not null then renewal_date
when t.min_annual_receipt_date  is not null and t.min_annual_receipt_date  <dateadd(DAY,-5,@renewal_start_date) then  dateadd(DAY,-5,@renewal_start_date) 
when t.min_annual_receipt_date  is not null then t.min_annual_receipt_date
else dateadd(DAY,-5,@renewal_start_date) end ,101 ))
)  b  group by   case when Cdate >=  dateadd(DAY,50,@renewal_start_date) then dateadd(DAY,50,@renewal_start_date)  else cdate end
order by cdate
GO
