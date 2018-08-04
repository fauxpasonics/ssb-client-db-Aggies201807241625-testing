SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_ticket] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50) 
Declare @renewal_start_date date
set  @renewal_start_date = (select  p.renewal_start_date  from PriorityEvents p where sporttype = @sporttype and  ticketyear = @ticketyear )

select  
case when min_ticketpaymentdate is null or min_ticketpaymentdate <dateadd(DAY,-2,@renewal_start_date) then dateadd(DAY,-2,@renewal_start_date)
when min_ticketpaymentdate >  dateadd(DAY,50,@renewal_start_date) then dateadd(DAY,50,@renewal_start_date)
else min_ticketpaymentdate end   Cdate,
sum(case when renewal_complete = 1 and renewed >=1 then 1 else 0 end)
  donorseatcount,
sum(isnull(ordergrouptotalpaymentscleared,0) ) Pledge,
sum( isnull( ordergrouptotalpaymentscleared ,0)  ) PaymentReceived,
sum( isnull( ordergrouptotalpaymentsonhold ,0) ) AmountwithScheduledPayment  from 
(
select distinct renewed, renewal_complete, min_ticketpaymentdate, ordernumber, adnumber , t.ordergroupbottomlinegrandtotal, t.ordergrouptotalpaymentscleared, t.ordergrouptotalpaymentsonhold
from amy.rpt_seatrecon_tb  t   where t.sporttype  =  @sporttype  and  ticketyear =  @ticketyear  and ordergrouptotalpaymentscleared > 0 
) t
group by 
case when min_ticketpaymentdate is null or min_ticketpaymentdate <dateadd(DAY,-2,@renewal_start_date) then dateadd(DAY,-2,@renewal_start_date) 
when min_ticketpaymentdate >  dateadd(DAY,50,@renewal_start_date) then dateadd(DAY,50,@renewal_start_date)
else min_ticketpaymentdate end  
order by 
case when min_ticketpaymentdate is null or min_ticketpaymentdate <dateadd(DAY,-2,@renewal_start_date) then dateadd(DAY,-2,@renewal_start_date)
  when min_ticketpaymentdate >  dateadd(DAY,50,@renewal_start_date) then dateadd(DAY,50,@renewal_start_date)
 else min_ticketpaymentdate end
GO
