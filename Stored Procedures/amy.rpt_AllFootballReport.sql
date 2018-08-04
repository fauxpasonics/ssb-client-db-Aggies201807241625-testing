SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_AllFootballReport] (
 @ticketyear varchar(4)= '2017', 
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null,
 @pastdue bit = null)
AS


Declare @tixeventlookupid varchar(50)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)
Declare @sporttype varchar(20)

Set @sporttype = 'FB'

 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')
 


set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

select * from amy.rpt_allfootball where sporttype = @sporttype and ticketyear = @ticketyear 
    and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%') 
and  (isnull(@pastdue,0) =0 or (@pastdue = 1 and EG_ItemsDue >=1))
/*
select * from (
select r.adnumber, accountname, status, "Ticket Total",
r.CAP, r.Annual, r.CAPCredit, r.AnnualCredit, r.[Adv CAP Pledge], r.[Adv CAP Receipt AMount], r.[Adv CAP Match Pledge], r.[Adv CAP Match Receipt], r.[Adv CAP Credit],
r.[Adv Annual  Pledge], r.[Adv Annual Receipt], r.[Adv Annual Match Pledge], r.[Adv Annual Match Receipt], r.[Adv Annual Credit], r.scheduledpayments, r.AnnualScheduledPayments,
r.KFCScheduledPayments, r.min_annual_receipt_date, r.renewal_date, r.email, r.vtxcusttype, r.ordergrouptotalpaymentsonhold, r.ordergrouptotalpaymentscleared, r.ordergroupbottomlinegrandtotal,
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
  , STUFF((SELECT ', ' + cast(ordernumber  as varchar)
  FROM rpt_fb_order_list_tb AS p
   WHERE allorders.accountnumber = p.accountnumber and sporttype = 'FB' and ticketyear = @ticketyear
   ORDER BY accountnumber
   FOR XML PATH('')), 1, 1, '') ordernumber
 from amy.rpt_seatrecon_tb r
 left join (select  adnumber arkadnumber,  isnull(Annual,0) ArkAnnual , isnull("Adv Annual Receipt",0) "Ark Adv Annual Receipt" , 
 isnull("Adv Annual Match Pledge",0) "Ark Adv Annual Match Pledge" ,
 isnull(AnnualScheduledPayments,0) ArkAnnualScheduledPayments, 
 isnull("Adv Annual Credit",0) "Ark Adv Annual Credit"  
 from amy.rpt_seatrecon_tb where sporttype= 'FB-Ark' and ticketyear = @ticketyear) ark on r.adnumber = ark.arkadnumber
 left join ( select 
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
from rpt_fb_order_list_tb l where sporttype = @sporttype and ticketyear = @ticketyear
group by accountnumber ) allorders on  allorders.accountnumber = r.adnumber 
where (sporttype = @sporttype ) and ticketyear = @ticketyear
    and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%') ) alldata
where (isnull(@pastdue,0) =0 or (@pastdue = 1 and EG_ItemsDue >0))
--and accountname is not null
*/
GO
