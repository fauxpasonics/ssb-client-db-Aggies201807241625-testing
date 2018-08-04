SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[endowedcreditsummary] as
select  elist.*, EndowedCreditTotal - capcredit-annualcredit - ppacredit  diff
/* ,
(select sum(transamount) from advcontact c, advcontacttransheader h, advcontacttranslineitems li where  c.contactid = h.ContactID and h.TransID = li.TransID and programid =  CAPProgramid and c.adnumber = elist.adnumber
and transtype =  'Credit' and  transyear = 'CAP') CAPCREDITapplied,
(select sum(transamount) from advcontact c, advcontacttransheader h, advcontacttranslineitems li where  c.contactid = h.ContactID and h.TransID = li.TransID and programid =  AnnualProgramid and c.adnumber = elist.adnumber
and transtype =  'Credit' and  transyear = renewalyear) AnnualCREDITapplied,
(select sum(transamount) from advcontact c, advcontacttransheader h, advcontacttranslineitems li where  c.contactid = h.ContactID and h.TransID = li.TransID and programid =  PPAProgramid and c.adnumber = elist.adnumber
and transtype =  'Credit' and  transyear = renewalyear) PPACREDITapplied,
(select sum(credit) from EndowedCreditsbyYear ECY1 where  ECY1.EndowedSetupID = elist.EndowedSetupID and credittype like 'CAP' and ECY1.renewalyear <= elist.renewalyear) CAPappliedthroughrenewalyear */
from (
select es.adnumber, ES.AccountName, ES.ActiveStatus, es.status, ES.ActualQtyUsed,
ES.EndowedSetupID, ES.SeasonQty, ES.RoadGameQty, ES.PriceCode, ES.EndowedCreditTotal, ES.EndowmentNumber,
renewalyear,   --seatregionname, 
--max(  case when credittype like 'CAP' then programid else null end)  CAPProgramid,
  sum( case when credittype like 'CAP' then credit else 0 end)  CAPCredit,
 --   max( case when credittype like 'Annual' then programid else null end) AnnualPRogramid,
  sum( case when credittype like 'Annual' then credit else 0 end)  Annualcredit,
 --  max(  case when credittype like 'PPA' then programid else null end ) PPAprogramid,
 sum( case when credittype like 'PPA' then credit else 0 end)  PPAcredit,
 sum(credit) totalcredit
from amy.EndowedSetup ES left join   EndowedCreditsbyYear ECY
on (  --renewalyear=2017 and
ES.EndowedSetupID = ECY.EndowedSetupID)
--where es.adnumber = 13086 
group by es.adnumber, renewalyear , ES.AccountName,ES.ActiveStatus, es.status, ES.ActualQtyUsed,
ES.EndowedSetupID, ES.SeasonQty, ES.RoadGameQty, ES.PriceCode, ES.EndowedCreditTotal, ES.EndowmentNumber
) elist  where activestatus not in ('Buyback','Terminated','Consolidated','DNSS')  -- and EndowedCreditTotal - capcredit-annualcredit - ppacredit  <> 0
GO
