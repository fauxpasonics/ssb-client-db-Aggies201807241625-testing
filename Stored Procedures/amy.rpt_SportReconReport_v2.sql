SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconReport_v2] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016', 
 @reporttype int = 3,
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
reporttype 3 = all
*/

DECLARE @percent1 decimal
DECLARE @percent2 decimal
declare @percentdue decimal
Declare @tixeventlookupid varchar(50)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)

 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')
 


set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

select r.*,  
 isnull(CAP,0) - isnull("Adv CAP Pledge",0) - isnull("Adv CAP Match Pledge",0)  - isnull("Adv CAP Credit",0)  EG_CapPledgeDifference,
 isnull(Annual,0)- isnull("Adv Annual  Pledge",0) - isnull("Adv Annual Match Pledge",0)  - isnull("Adv Annual Credit",0) EG_AnnualPledgeDifference, 
 case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 
then  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 
 end
 EG_CurrentYearAnnualPastDue,
 case when 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) > 0 
 then 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) else 0 end 
 EG_TicketOrderPerPastDue,
 case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > .5  then 1 else 0 end EG_CapDue, 
 case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > .5 then 1 else 0 end EG_AnnualDue, 
 case when   isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)  > 0   then 1 else 0 end EG_TicketsDue, 
 ( case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 then 
 isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 
 end ) +
 ( case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > 0
 then isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0) - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0 )  else 0 end) +
 (  case when isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)    > 0 
 then  isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0) else 0 end
 ) EG_ItemsDue,
  (  case when isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)    > 0 
 then  isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0) else 0 end
 ) TicketDueAmount,
  isnull( "Adv CAP Receipt AMount",0)  + isnull("Adv CAP Match Pledge",0)   + isnull(  "Adv CAP Credit",0) DP_CAPReceiptwithCredits,
   isnull("Adv Annual Receipt",0)  + isnull("Adv Annual Match Pledge",0)   +isnull("Adv Annual Credit",0) DP_AnnualReceiptwithCredits, 
   r.email
 from amy.rpt_seatrecon_tb r
where  (sporttype = @sporttype or @sporttype = 'ALL') and ticketyear = @ticketyear and
(
(@reporttype = 1 and ((isnull(ANNUAL,0) -isnull( "Advantage Adjusted Annual Pledge", 0)  <>0)) )
 or
 (@reporttype =2 and
  (
  (isnull(ANNUAL,0)  - ((isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) )>.5) 
  or (isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)  > 0 )  
  or (isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > .5 )
 )
 )
 or
 (@reporttype = 3)
 or
  (@reporttype =4 and (isnull(ANNUAL,0)  - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) <=0))
  or
 ( @reporttype =5 and 1=2)
   or  -- Receipt higher than pledge
 ( @reporttype =6 and 
 (isnull("Adv Annual  Pledge",0) <  isnull("Adv Annual Receipt",0) or isnull("Adv Annual Match Pledge",0) < isnull("Adv Annual Match Receipt",0))
  )
  
     or  -- CAP Receipt higher than pledge
 ( @reporttype =7 and 
 ( isnull( "Adv CAP Pledge", 0) < isnull( "Adv CAP Receipt AMount",0)  or isnull("Adv CAP Match Pledge" ,0) <isnull( "Adv CAP Match Receipt" ,0))
  )
  )
    and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%')
--and accountname is not null
GO
