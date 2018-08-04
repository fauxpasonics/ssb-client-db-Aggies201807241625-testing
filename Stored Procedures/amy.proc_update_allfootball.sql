SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec proc_update_allfootball 2018
CREATE procedure [amy].[proc_update_allfootball] (@ticketyear int = 2017) AS

declare @pacseason varchar(20)

select @pacseason = pacseason from priorityevents where ticketyear = @ticketyear  and sporttype = 'FB'

begin
delete from rpt_allfootball where ticketyear  =  @ticketyear 

insert into rpt_allfootball
select alldata.*, 'FB' sporttype, @ticketyear ticketyear   from (
select  cust.customer adnumber, isnull(accountname,  arkaccountname) accountname, 
isnull(status,'') status,
isnull("Ticket Total", 0) "Ticket Total" ,
isnull(r.CAP, 0) CAP, isnull(r.Annual,0) Annual, isnull(r.CAPCredit,0 ) CAPCredit, isnull(r.AnnualCredit,0) AnnualCredit,
isnull(r.[Adv CAP Pledge],0) [Adv CAP Pledge],
isnull( r.[Adv CAP Receipt AMount],0) [Adv CAP Receipt AMount],
isnull(r.[Adv CAP Match Pledge],0) [Adv CAP Match Pledge], 
isnull(r.[Adv CAP Match Receipt],0) [Adv CAP Match Receipt], 
isnull(r.[Adv CAP Credit],0 ) [Adv CAP Credit],
isnull("Adv Annual  Pledge",0) [Adv Annual  Pledge], 
isnull("Adv Annual Receipt",0) "Adv Annual Receipt", 
isnull("Adv Annual Match Pledge",0) [Adv Annual Match Pledge], 
isnull(r.[Adv Annual Match Receipt],0) [Adv Annual Match Receipt], 
isnull(r.[Adv Annual Credit],0) [Adv Annual Credit],
isnull(r.scheduledpayments,0) scheduledpayments,
isnull(r.AnnualScheduledPayments,0) AnnualScheduledPayments,
isnull(r.KFCScheduledPayments,0) KFCScheduledPayments,
r.min_annual_receipt_date,
r.renewal_date,
isnull(r.email,'') email,
isnull(r.vtxcusttype,0) vtxcusttype,
isnull(r.ordergrouptotalpaymentsonhold,0) ordergrouptotalpaymentsonhold,
isnull(r.ordergrouptotalpaymentscleared,0) ordergrouptotalpaymentscleared,
isnull(r.ordergroupbottomlinegrandtotal,0)  ordergroupbottomlinegrandtotal,
  allorders.*,
 isnull(CAP,0) - isnull("Adv CAP Pledge",0) - isnull("Adv CAP Match Pledge",0)  - isnull("Adv CAP Credit",0)  EG_CapPledgeDifference,
 isnull(Annual,0)- isnull("Adv Annual  Pledge",0) - isnull("Adv Annual Match Pledge",0)  - isnull("Adv Annual Credit",0) EG_AnnualPledgeDifference, 
 case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 
then  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 
 end
 EG_CurrentYearAnnualPastDue,
  case when  isnull(ArkAnnual,0)-  isnull("Ark Adv Annual Receipt",0) - isnull("Ark Adv Annual Match Pledge",0) -  isnull(ArkAnnualScheduledPayments,0) - isnull("Ark Adv Annual Credit",0)   > 0 
then  isnull(ArkAnnual,0)-  isnull("Ark Adv Annual Receipt",0) - isnull("Ark Adv Annual Match Pledge",0) -  isnull(ArkAnnualScheduledPayments,0) - isnull("Ark Adv Annual Credit",0)  else 0 
 end
 EG_ArkCurrentYearAnnualPastDue,
 case when 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) > 0 
 then 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) else 0 end 
 EG_TicketOrderPerPastDue,
 isnull(CapStillDue,0 ) CapStillDue,
 isnull(CAP_DUE, 0) CAP_DUE,
 case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > .5  then 1 else 0 end EG_CapDue, 
 case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > .5 then 1 else 0 end EG_AnnualDue, 
 case when   isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)  > 0   then 1 else 0 end EG_TicketsDue, 
 --Annual
 ( case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 then 
 isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 
 end ) +
 --CAP
 ( case when CapStillDue > 0
 then isnull(CapStillDue,0 )  else 0 end) +
 --Tickets
 (  case  when isnull(allorders.grandtotal,0) - isnull(allorders.Paid,0)- isnull(allorders.Scheduled ,0)    > 0 
 then  isnull(allorders.grandtotal,0) - isnull(allorders.Paid,0)- isnull(allorders.Scheduled ,0)  else 0 end
 )+
 --Ark
  ( case when  isnull(ArkAnnual,0)-  isnull("Ark Adv Annual Receipt",0) - isnull("Ark Adv Annual Match Pledge",0) -  isnull(ArkAnnualScheduledPayments,0) - isnull("Ark Adv Annual Credit",0)   > 0 then 
 isnull(ArkAnnual,0)-  isnull("Ark Adv Annual Receipt",0) - isnull("Ark Adv Annual Match Pledge",0) -  isnull(ArkAnnualScheduledPayments,0) - isnull("Ark Adv Annual Credit",0)  else 0 
 end ) 
 EG_ItemsDue,
  (  case when isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)    > 0 
 then  isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0) else 0 end
 ) TicketDueAmount,
  isnull( "Adv CAP Receipt AMount",0)  + isnull("Adv CAP Match Pledge",0)   + isnull(  "Adv CAP Credit",0) DP_CAPReceiptwithCredits,
   isnull("Adv Annual Receipt",0)  + isnull("Adv Annual Match Pledge",0)   +isnull("Adv Annual Credit",0) DP_AnnualReceiptwithCredits,
  isnull("Ark Adv Annual Receipt",0)  + isnull("Ark Adv Annual Match Pledge",0)   +isnull("Ark Adv Annual Credit",0) DP_ArkAnnualReceiptwithCredits,
 arkadnumber,  isnull( ArkAnnual,0) ArkAnnual , isnull( "Ark Adv Annual Receipt" ,0) "Ark Adv Annual Receipt" , 
 isnull("Ark Adv Annual Match Pledge" ,0) "Ark Adv Annual Match Pledge" ,
 isnull(ArkAnnualScheduledPayments,0) ArkAnnualScheduledPayments, 
 isnull("Ark Adv Annual Credit" ,0) "Ark Adv Annual Credit"  
  ,  ordernumber
   from  (select distinct customer from tk_odet  where season ='F18'
   union  select distinct adnumber from SuiteAllocations where renewalyear  = @ticketyear  and sporttype = 'FB') cust
 left join amy.rpt_seatrecon_tb r on cust.customer = r.adnumber and  (sporttype = 'FB') and ticketyear = @ticketyear
 left join (select  adnumber arkadnumber, accountname arkaccountname,  isnull(Annual,0) ArkAnnual , isnull("Adv Annual Receipt",0) "Ark Adv Annual Receipt" , 
 isnull("Adv Annual Match Pledge",0) "Ark Adv Annual Match Pledge" ,
 isnull(AnnualScheduledPayments,0) ArkAnnualScheduledPayments, 
 isnull("Adv Annual Credit",0) "Ark Adv Annual Credit"  
 from amy.rpt_seatrecon_tb where sporttype= 'FB-Ark' and ticketyear = @ticketyear) ark on cust.customer = ark.arkadnumber
 left join ( /*select 
accountnumber, 	sum(ordergroupbottomlinegrandtotal) Grandtotal,
sum(ordergrouptotalpaymentsonhold) Scheduled,
sum(ordergrouptotalpaymentscleared) Paid,
sum(ordergrouppaymentbalance) Balance,
count(ordernumber)  OrderCount,
max(Parking) Parking,
max(Bowl) Bowl,
max(Away) Away,
max(Home) Home,
max(Season) Season,
max(Arkansas) Arkansas,
max(VeritixDonations) VeritixDonations	
from rpt_fb_order_list_tb l where sporttype ='FB' and ticketyear = @ticketyear and (Parking = 'X' or Away = 'X' or Season = 'X' or Arkansas = 'X' or VeritixDonations = 'X')
group by accountnumber ) allorders on  allorders.accountnumber = r.adnumber 

*/

select l.customer accountnumber, 
sum(i_pay+ i_cpay+i_bal) Grandtotal,
( select sum(bamt) bamt from tk_bplan bp where season = @pacseason  and bdate > getdate()  and bp.customer = l.customer  ) Scheduled,
sum(i_pay+ i_cpay) Paid,
sum(i_bal) Balance,
1  OrderCount,
max(case when l.item  in ('P') then 'X' else null end) Parking,
0 Bowl,
max(case when l.item  in ('F09','F10','F11','F12','F13','F08') then 'X' else null end) Away,
max(case when l.item  in ('F01','F02','F03','F04','F05','F06','F07') then 'X' else null  end) Home,
max(case when l.item = 'FS' then 'X' else null  end  ) Season,
max(case when l.item = 'F09' then 'X' else null  end  ) Arkansas,
max(case when l.ITEM in ('DON','FSD') then 'X' else null end  ) VeritixDonations	 from 
(select * from tk_odet  where season = @pacseason ) l
group by l.customer ) allorders on  allorders.accountnumber = cust.customer
 ) alldata

 
 end
GO
