SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_AllFootballReport_Dtl]  (
 @ticketyear varchar(4)= '2016',
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
AS
begin
Declare @tixeventlookupid  varchar(50)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)
Declare @sporttype varchar(20)
Declare @pacseason varchar(20)

 Set @sporttype = 'FB'
 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')
 
 
 Set @tixeventlookupid   = (select tixeventlookupid from priorityevents pe where pe.sporttype = @sporttype and pe.ticketyear = @ticketyear);
 Set @pacseason   = (select pacseason from priorityevents pe where pe.sporttype = @sporttype and pe.ticketyear = @ticketyear);

select * from (
 /*select 'Tickets' Source,
cast(accountnumber as int) adnumber, 
ordernumber,  	
sum(ordergroupbottomlinegrandtotal) GrandTotal,
sum(ordergrouptotalpaymentsonhold) Scheduled,
sum(ordergrouptotalpaymentscleared) Paid,
	sum(ordergroupbottomlinegrandtotal) - sum(ordergrouptotalpaymentscleared) - sum(ordergrouptotalpaymentsonhold) StillDue,
max(Parking) Parking,
max(Bowl) Bowl,
max(Away) Away,
max(Home) Home,
max(Season) Season,
max(Arkansas) Arkansas,
max(VeritixDonations) VeritixDonations	
from rpt_fb_order_list_tb l  where sporttype = @sporttype and ticketyear = @ticketyear
and (Parking = 'X' or Away = 'X' or Season = 'X' or Arkansas = 'X' or VeritixDonations = 'X')
group by cast(accountnumber as int), ordernumber*/
 select 'Tickets' Source,
 l.customer adnumber, 
 null ordernumber,
sum(i_pay+ i_cpay+i_bal) Grandtotal,
( select sum(bamt) bamt from tk_bplan bp where season = @pacseason  and bdate > getdate()  and bp.customer = l.customer  ) Scheduled,
sum(i_pay+ i_cpay) Paid,
sum(i_bal) Balance,
max(case when l.item  in ('P') then 'X' else null end) Parking,
0 Bowl,
max(case when l.item  in ('F09','F10','F11','F12','F13','F08') then 'X' else null end) Away,
max(case when l.item  in ('F01','F02','F03','F04','F05','F06','F07') then 'X' else null  end) Home,
max(case when l.item = 'STH' then 'X' else null  end  ) Season,
max(case when l.item = 'F09' then 'X' else null  end  ) Arkansas,
max(case when l.ITEM in ('DON','FSD') then 'X' else null end  ) VeritixDonations	 
 from tk_odet l  where season = @pacseason 
group by l.customer 
union 
 select 'CAP' Source,
 adnumber , 
null ordernumber,  	
sum(  isnull(CAP_DUE, 0)) Grandtotal,
sum(isnull(KFCScheduledPayments ,0)) Scheduled,
sum(isnull( "Adv CAP Receipt AMount",0)  + isnull("Adv CAP Match Pledge",0) + isnull(  "Adv CAP Credit",0)) Paid,
	sum(isnull(CapStillDue,0 )) StillDue,
null Parking,
null Bowl,
null Away,
null Home,
'X' Season,
null Arkansas,
null VeritixDonations	 from
amy.rpt_seatrecon_tb l  where sporttype = @sporttype and ticketyear = @ticketyear
group by  adnumber , ordernumber
union 
 select 'Annual' Source,
 adnumber  , 
null ordernumber,  	
sum(   isnull(Annual,0)) Grandtotal,
sum(isnull(AnnualScheduledPayments,0)) Scheduled,
sum( isnull("Adv Annual Receipt",0)  + isnull("Adv Annual Match Pledge",0) + isnull("Adv Annual Credit",0)) Paid,
	sum( isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)) StillDue,
null Parking,
null Bowl,
null Away,
null Home,
'X' Season,
null Arkansas,
null VeritixDonations	 from
amy.rpt_seatrecon_tb l  where sporttype = @sporttype and ticketyear = @ticketyear
group by  adnumber , ordernumber 
union 
 select 'ArkDonations' Source,
 adnumber  , 
null ordernumber,  	
sum(   isnull(Annual,0)) Grandtotal,
sum(isnull(AnnualScheduledPayments,0)) Scheduled,
sum( isnull("Adv Annual Receipt",0)  + isnull("Adv Annual Match Pledge",0) + isnull("Adv Annual Credit",0)) Paid,
	sum( isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)) StillDue,
null Parking,
null Bowl,
null Away,
null Home,
'X' Season,
null Arkansas,
null VeritixDonations	 from
amy.rpt_seatrecon_tb l  where sporttype = @sporttype + '-Ark' and ticketyear = @ticketyear
group by  adnumber , ordernumber ) allfb
where (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast( allfb.adnumber as varchar)  +',%') 
--and  (@accountname  is null or  (select accountname from advcontact where adnumber = cast(sh.accountnumber as int))  like '%' + @accountname  +'%')
order by adnumber, source

end
GO
