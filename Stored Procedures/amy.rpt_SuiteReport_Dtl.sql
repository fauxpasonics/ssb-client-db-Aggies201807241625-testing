SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SuiteReport_Dtl] (--@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016' --, 
-- @reporttype int = 3,
-- @ADNUMBERLIST nvarchar(MAX) = null,
-- @accountname nvarchar(100) = null
 )
AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
reporttype 3 = all
*/

DECLARE @percent1 decimal
DECLARE @percent2 decimal
declare @percentdue decimal
Declare @tixeventlookupid varchar(50)
Declare @sporttype varchar(20)
--Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)
-- Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')

set @sporttype = 'FB'
set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype  and ticketyear = @ticketyear);

select r.*,  
--case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > 0 then isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0) - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0 )  else 0 end CapStillDue, 
 isnull(CAP,0) - isnull("Adv CAP Pledge",0) - isnull("Adv CAP Match Pledge",0)  - isnull("Adv CAP Credit",0)  EG_CapPledgeDifference,
 isnull(Annual,0)- isnull("Adv Annual  Pledge",0) - isnull("Adv Annual Match Pledge",0)  - isnull("Adv Annual Credit",0) EG_AnnualPledgeDifference, 
 case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 
then  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 end EG_CurrentYearAnnualPastDue,
 case when 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) > 0 
 then 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) else 0 end 
 EG_TicketOrderPerPastDue ,
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
   a.AttnName, a.Company, a.Address1, a.Address2, a.Address3, a.City, a.State, a.Zip zip, a.Salutation, c.email, c.PHHome, c.PHBusiness, c.Mobile
 from RPT_SUITESEATREGION_TB r left join advcontact c on r.adnumber = c.ADNumber  
  left join amy.advcontactaddresses_unique_primary_vw a on  c.ContactID = a.ContactID
 where sporttype = @sporttype  and ticketyear = @ticketyear
GO
