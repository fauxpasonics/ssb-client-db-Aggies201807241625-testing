SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_1_test] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50) 
declare @renewal_start_date date
select @renewal_start_date =renewal_start_date  from priorityevents where sporttype = @sporttype and ticketyear =   @ticketyear

select  
 --t.min_annual_receipt_date
 case when renewal_date is null   and t.min_annual_receipt_date is  null
and  (isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) 
then dateadd(DAY,-2,@renewal_start_date) 
when renewal_date is not null then renewal_date
when t.min_annual_receipt_date  is not null then  dateadd(DAY,-2,@renewal_start_date) else null end  
 Cdate,
count(  DISTINCT CASE
                                         WHEN     "Ticket Total" 
										 IS NOT NULL
                                              AND (   renewal_date   IS NOT NULL
                                                   OR (    (  isnull (
                                                                 ordergroupbottomlinegrandtotal,
                                                                 0)
                                                            - isnull (
                                                                 ordergrouptotalpaymentscleared,
                                                                 0)
                                                            - isnull (
                                                                 ordergrouptotalpaymentsonhold,
                                                                 0) <= 0)
                                                       AND (  isnull (Annual,
                                                                      0)
                                                            - isnull (
                                                                 "Adv Annual Receipt",
                                                                 0)
                                                            - isnull (
                                                                 "Adv Annual Match Pledge",
                                                                 0)
                                                            - isnull (
                                                                 AnnualScheduledPayments,
                                                                 0)
                                                            - isnull (
                                                                 "Adv Annual Credit",
                                                                 0) <= 0)))
                                         THEN
                                            ADNUMBER
                                         ELSE
                                            NULL
                                      END 
									 ) donorseatcount,
sum(isnull("Adv Annual  Pledge",0) + isnull("Adv Annual Match Pledge",0)) Pledge,
sum( isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) ) PaymentReceived,
sum( isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0)) AmountwithScheduledPayment 

from amy.rpt_seatrecon_tb  t where t.sporttype  = @sporttype and  ticketyear =  @ticketyear 
---and "Ticket Total" is not null 
and  ((isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) or isnull(t.ticketpaidpercent,0) > 0  or min_annual_receipt_date is not null)
group by 
-- t.min_annual_receipt_date  
 case when renewal_date is null   and t.min_annual_receipt_date is  null
and  (isnull( "Adv Annual Receipt" ,0)  + isnull(  "Adv Annual Match Receipt",0) + isnull(  "AnnualScheduledPayments",0) >0) 
then dateadd(DAY,-2,@renewal_start_date) 
when renewal_date is not null then renewal_date
when t.min_annual_receipt_date  is not null then  dateadd(DAY,-2,@renewal_start_date) else null end
GO
