SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[proc_FB_order_list] (@ticketyear char(4) null)
as
 begin
 
 if @ticketyear is null
 set @ticketyear = ( select max(ticketyear) from PriorityEvents where sporttype ='FB')
 
 delete from rpt_FB_order_list_tb  where ticketyear = @ticketyear
 
 insert into rpt_FB_order_list_tb 
 SELECT -- distinct 
 'FB' sporttype, @ticketyear ticketyear,
	c.accountnumber , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared,  og.ordergrouppaymentbalance, og.ordergroup ordernumber, 
max(Parking) Parking, max(Bowl) Bowl, max(Away) Away, max(Home) Home, max(Season) Season, max(Arkansas)  Arkansas, max( VeritixDonations)  VeritixDonations ,
getdate() updatedate 
--count(
FROM [ods].[VTXtixeventzoneseats] a 
JOIN [ods].[VTXtixevents] e    ---yes
	ON a.tixeventid = e.tixeventid
JOIN [ods].[VTXordergroups] og    ---yes
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(255))
JOIN [ods].[VTXcustomers] c    --yes
	ON og.customerid = c.id and c.accountnumber not like  '%[A-Z,a-z]%'
  JOin (select f.tixeventid, f.tixeventlookupid, tixeventtitleshort, categoryname,
max(case when categoryname = 'Parking' then 'X' else null end) Parking,
max(case when categoryname = 'Bowl' then 'X' else null end) Bowl,
max(case when categoryname = 'Away' then 'X' else null end) Away,
max(case when categoryname = 'Home' then 'X' else null end) Home,
max(case when tixeventlookupid like '%Season' then 'X' else null end) Season,
max(case when tixeventtitleshort like '%Arkansas%' then 'X' else null end)  Arkansas,
max(case when categoryname  = 'Donations' then 'X' else null end)  VeritixDonations 
from  ods.VTXtixevents f, ods.VTXcategory c ,  ods.VTXeventcategoryrelation d 
where f.tixeventid = d.tixeventid   and c.categoryid = d.categoryid
 and  d.etl_isdeleted =0 and f.etl_isdeleted = 0  and  -- tixeventlookupid like 'F16%'
 f.tixeventid in (select f.tixeventid from 
 ods.VTXtixevents f, ods.VTXcategory c ,  ods.VTXeventcategoryrelation d , ods.VTXcategory cparent
where f.tixeventid = d.tixeventid   and c.categoryid = d.categoryid  and isnull(c.parentid, -1) = isnull(cparent.categoryid,-1)
 and  d.etl_isdeleted =0 and f.etl_isdeleted = 0  and c.categoryname = 'Football' and cparent.categoryname = @ticketyear)
 and  f.tixeventid not in (select f.tixeventid from 
 ods.VTXtixevents f, ods.VTXcategory c ,  ods.VTXeventcategoryrelation d 
where f.tixeventid = d.tixeventid   and c.categoryid = d.categoryid 
 and  d.etl_isdeleted =0 and f.etl_isdeleted = 0  and c.categoryname = 'Non-Event' )
 group by f.tixeventid , f.tixeventlookupid, tixeventtitleshort, categoryname) eventmess on eventmess.tixeventid = a.tixeventid
--WHERE ordergrouppaymentbalance <> 0  
group by 	c.accountnumber, ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared,  og.ordergrouppaymentbalance, 
og.ordergroup
    
end
GO
