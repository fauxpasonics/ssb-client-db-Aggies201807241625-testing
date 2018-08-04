SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_EndowedSetup] (@renewalyear varchar(4), @activeonly bit , @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
as
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)

 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')
 
if @renewalyear is not null
begin
select es.adnumber, es.accountname, es.EndowmentNumber, es.ActiveStatus , es.pricecode, es.seasonqty, es.roadgameqty, es.actualqtyused, 
es.endowment, es.establishedyear,es.enddate, es.EndDateInitialLength, es.terms, es.Beneficiaries, es.SpouseName, es.pastadnumber, 
es.Notes, es.EndowedCreditTotal, cby.RenewalYear, cby.CAP,cby.Annual, cby.PPA, 
case when activestatus in ('Yes','Consolidated') and cby.CAP + cby.Annual + cby.PPA  <> EndowedCreditTotal then  'No Match' else null end "Endowment check"
, Adv_Annual, Adv_CAP,  Adv_PPA, 
case when activestatus in ('Yes','Consolidated') and Adv_CAP + Adv_Annual + Adv_PPA  <> EndowedCreditTotal then  'No Match' else null end "Advantage check",
es.endowedsetupid
from EndowedSetup es
left join 
(select endowedsetupid, --seatregionname,
renewalyear,
sum(case when credittype = 'CAP' then isnull(credit,0) else 0 end) CAP,
sum(case when credittype = 'Annual' then isnull(credit,0) else 0 end) Annual,
sum(case when credittype = 'PPA' then isnull(credit,0) else 0 end) PPA from EndowedCreditsbyYear where renewalyear = @renewalyear
group by endowedsetupid, -- seatregionname,
renewalyear) cby on es.endowedsetupid = cby.endowedsetupid
left join (
select adnumber, contactid, esid, sum(Adv_Annual) Adv_Annual, sum(Adv_CAP) Adv_CAP, sum(Adv_PPA) Adv_PPA from (
select  acct adnumber, null contactid,
--SUBSTRING(cast(l.comments as varchar(max)), CHARINDEX('esid: ', cast(l.comments as varchar(max)))+6,len(cast(l.comments as varchar(max))))
null esid, 
--comments,
case when allocationid = 'PPA' then isnull(CreditAmt,0) else 0 end Adv_PPA,
case when allocationid in ( 'FEC-ST','FEC') and driveyear =@renewalyear  then isnull(CreditAmt,0) else 0 end Adv_Annual,
case when allocationid not in  ( 'PPA', 'FEC-ST','FEC') and driveyear =0  then isnull(CreditAmt,0) else 0 end Adv_CAP 
from pactranitem_alt_vw l where l.driveYear in ( @renewalyear,0) --and transtype = 'Credit' and notes like '%RY%'+@renewalyear+'%'
and (allocationid in ('PPA') or allocationname like '%Endowed%')

) y group by adnumber, contactid, esid ) AdvData -- on AdvData.esid =  es.endowedsetupid
on AdvData.adnumber=  es.adnumber
where ( ( @activeonly  = 1 and es.ActiveStatus in ('Yes','Active','Consolidated')) or isnull(@activeonly,0) =0)
    and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(es.adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%')
order by adnumber, endowmentnumber 
/*
select es.adnumber, es.accountname, es.EndowmentNumber, es.ActiveStatus , es.pricecode, es.seasonqty, es.roadgameqty, es.actualqtyused, 
es.endowment, es.establishedyear,es.enddate, es.EndDateInitialLength, es.terms, es.Beneficiaries, es.SpouseName, es.pastadnumber, 
es.Notes, es.EndowedCreditTotal, cby.RenewalYear, cby.CAP,cby.Annual, cby.PPA, 
case when activestatus in ('Yes','Consolidated') and cby.CAP + cby.Annual + cby.PPA  <> EndowedCreditTotal then  'No Match' else null end "Endowment check"
, Adv_Annual, Adv_CAP,  Adv_PPA, 
case when activestatus in ('Yes','Consolidated') and Adv_CAP + Adv_Annual + Adv_PPA  <> EndowedCreditTotal then  'No Match' else null end "Advantage check",
es.endowedsetupid
from EndowedSetup es
left join 
(select endowedsetupid, --seatregionname,
renewalyear,
sum(case when credittype = 'CAP' then isnull(credit,0) else 0 end) CAP,
sum(case when credittype = 'Annual' then isnull(credit,0) else 0 end) Annual,
sum(case when credittype = 'PPA' then isnull(credit,0) else 0 end) PPA from EndowedCreditsbyYear where renewalyear = @renewalyear
group by endowedsetupid, -- seatregionname,
renewalyear) cby on es.endowedsetupid = cby.endowedsetupid
left join (
select adnumber, contactid, esid, sum(Adv_Annual) Adv_Annual, sum(Adv_CAP) Adv_CAP, sum(Adv_PPA) Adv_PPA from (
select adnumber, contactid,SUBSTRING(cast(l.comments as varchar(max)), CHARINDEX('esid: ', cast(l.comments as varchar(max)))+6,len(cast(l.comments as varchar(max)))) esid, 
case when programid = 131 then isnull(transamount,0) else 0 end Adv_PPA,
case when programid in (678,679) and transyear =@renewalyear  then isnull(transamount,0) else 0 end Adv_Annual,
case when programid not in  (131,678,679) and transyear ='CAP'  then isnull(transamount,0) else 0 end Adv_CAP
from adv_transaction_vw  l where l.TransYear in ( @renewalyear,'CAP') and transtype = 'Credit' and notes like '%RY%'+@renewalyear+'%'
and (programid in (131) or programname like '%Endowed%')
) y group by adnumber, contactid, esid ) AdvData on AdvData.esid =  es.endowedsetupid
where ( ( @activeonly  = 1 and es.ActiveStatus in ('Yes','Active','Consolidated')) or isnull(@activeonly,0) =0)
    and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(es.adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%')
order by adnumber, endowmentnumber */
end
GO
