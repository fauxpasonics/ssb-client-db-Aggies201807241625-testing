SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_capstatement_header 21426, 2017
CREATE procedure [amy].[rpt_capstatement_header]
(@adnumber int, 
@ticketyear int)
as
select distinct c.adnumber, c.accountname, getdate() "Date",
c.accountname Accountname,
cast( --c.accountname +char(13) + char(10)+
case when Address1 is not null then Address1 + char(13) + char(10) else '' end + 
case when Address2 is not null then Address2 -- + char(13) + char(10)  
else '' end  +
case when Address3 is not null then Address3  --+ char(13) + char(10) 
else '' end   --+
  --City + ', ' +  State + ' '+ Zip  
 as varchar(2000))
as AddressLabel,
City ShipCity, state ShipRegion,Zip  ShipPostalCode
/*, 
tall.*,
case when pledge_amount <> 0  then receipt_amount/pledge_amount else 0 end percentpaid,
sr.CAPCredit, sr.CAP, sr.cap_amount, sr.seatregionname, sr.seatregionid, sr.[Ticket Total], sr.cap_20, sr.CAP_40, sr.CAP_60, sr.CAP_80, sr.CAP_100, sr.CAP_OTHER, sr.CAP_DUE, sr.CapStillDue
*/
from (
select contactid,  
(select distinct sr.seatregionid from seatallocation sa, seatarea sr where  sa.SeatAreaID = sr.seatareaid and sa.programid = t.ProgramID  and isnull(sa.inactive_ind,0) =0) seatregionid,
case when programgroup = 'Kyle Field Campaign' then programgroup  else 'Capital Pledges' end programgroup, 
programname + case when match = 'X' then ' (Matching Amount)' else '' end programname ,
pledge_amount , receipt_amount ,pledge_amount - receipt_amount  balance,
match, start_pledge_date ,
--case when programgroup = 'Kyle Field Campaign'  then
---case when receipt_amount >= .6*pledge_amount  then 0 else .6*pledge_amount -receipt_amount end
--else 0 end AmountDue,
ad_uoprogramname
from (select  contactid, al.programgroup, al.programname , al.programid,
sum(case when transtype like '%Pledge%' then transamount+matchamount else 0 end) pledge_amount ,
sum(case when transtype like '%Receipt%' then transamount+matchamount  else 0 end) receipt_amount ,
min(case when transtype like '%Pledge%' then transdate else null end) start_pledge_date,
max(case when transtype like '%Pledge%' then transdate else null end ) end_pledge_date,
max(case when transtype like '%Receipt%'  and (programname like '%TMF/AD%' or programname  like '%UO%' ) then 'X' else null end ) ad_uoprogramname,
null Match
from advcontacttransheader h 
join advcontacttranslineitems li on h.transid = li.transid
INNER JOIN  advprogram al   ON     li.ProgramID = al.ProgramID AND (al.programname not like '%Planned%' and al.programname <> 'KFC-Wait List')
where h.TransYear = 'CAP'  AND (matchinggift = 0 OR matchinggift IS NULL)
and programgroup = 'Kyle Field Campaign' 
group by  contactid, al.ProgramGroup,al.programname, al.programid  ) t
where pledge_amount > receipt_amount
) tall
 join advcontact c on tall.contactid = c.contactid
 join RPT_SEATREGION_TB sr on c.adnumber = sr.adnumber and tall.seatregionid = sr.seatregionid and sr.Sporttype = 'FB' and sr.Ticketyear = @ticketyear
 left join amy.advcontactaddresses_unique_primary_vw ca on c.contactid = ca.contactid 
where
c.status not in ('Deceased')  
--and pledge_amount - receipt_amount- CapCredit  > 0
/*
and adnumber in (select cast(adnumber as int) from dataqa..vtxcustomertypes where [customer type] like 'AD%' or  [customer type]  = 'TMS')
and adnumber not in (
26989	,19	,614000393	,423002752	,729059	,820000528	,221001972	,109006098	,102007102	,213006644	,
12182	,602015	,119002486	,741764	,32786440	,34276441	,814003019	,1005266	,18661	,26626442	,787214	,880342	,717791	,2949432	,874545	,743197	,323007546	,321008816	,909002011	,717791	,
7000	,7001	,7002	,7003	,7004	,7005	,7006	,7007	,7008	,7009	,7010	,7011	,7012	,7014	,7015	,7016	,7017	,7018	,7019	,7020	,7021	,7022	,7023	,7024	,7025	,7026	,7027	,7028	,7029	,7030	,7031	
) */
and c.adnumber = @adnumber
and programgroup = 'Kyle Field Campaign'  
order by adnumber
GO
