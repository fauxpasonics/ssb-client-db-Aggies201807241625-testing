SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorLettermenMembershipReportGrid] (@InYear varchar(4) =null  )

AS
Declare @RunYear varchar(4)

if @InYear is null 
begin
  select @RunYear = cast(year(getdate()) as varchar)
end
else
begin
set @RunYear = @InYear
end


  --Lifetime Membership
  
  select t.adnumber ,accountname ,firstname ,lastname ,status ,donortype ,LifetimeGiving ,AdjustedPP ,pprank ,classyear prefclassyear ,UDF4 programname ,
  "Lettermen Dual Membership",
  "Lettermen Recent Grad Membership",
  "Lettermen Lifetime Membership",
  "Lettermen Current Lifetime Membership",
  "Lettermen Current Senior Lifetime Membership",
  "Lettermen Only Membership",
  "Lettermen Senior Dual Membership",
 --TTL
  "TTL - Lettermen Dual Membership",
  "TTL - Lettermen Recent Grad Membership",
  "TTL - Lettermen Lifetime Membership",
  "TTL - Lettermen Current Lifetime Membership",
  "TTL - Lettermen Current Senior Lifetime Membership",
  "TTL - Lettermen Only Membership",
  "TTL - Lettermen Senior Dual Membership",
 --  "Lettermen Senior Dual Credit" ,
   Email ,PHHome ,PHBusiness ,PHOther1 ,PHOther2 ,PHOther1Desc ,PHOther2Desc ,
null  AddressType ,null AttnName ,null Company ,Salutation ,Address1 ,Address2 ,  Address3 ,City ,State ,Zip , 
(select value from amy.donorcategory_vw cdc where categorycode = 'SPORT' and cdc.adnumber = t.adnumber )  Sport ,
transdate
from (
select  c.contactid, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.donortype donortype, c.LifetimeGiving, c.AdjustedPP, 
case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank,  c.UDF4, c.Email,
c.homephone PHHome, c.busphone PHBusiness, c.cellphone PHOther1, null PHOther2, 'Cell' PHOther1Desc, null PHOther2Desc, classyear,Salutation,
adj_address1 Address1 ,adj_address2 Address2 , adj_address3 Address3 , City ,State ,Zip,
trans.* from 
(select acct, 
     sum (p.PledgeAmt + p.MatchingPledgeAmt)   capital_pledge_amount,
     sum (p.PaymentAmt + p.MatchingPaymentAmt)   capital_receipt_amount,
     max(CASE WHEN   p.PaymentAmt + p.MatchingPaymentAmt >0 THEN  p.ReceivedDate  ELSE    null   END) max_receipt,
     sum (CASE WHEN  p.allocationid = 'LDM'  THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Dual Membership",
     sum (CASE WHEN  p.allocationid  = 'LRG'  THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Recent Grad Membership",
     sum (CASE WHEN  p.allocationid  = 'LLM'  THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Lifetime Membership",
     sum (CASE WHEN    p.allocationid = 'LCLM'  THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Current Lifetime Membership",
     sum (CASE WHEN  p.allocationid  = 'LCSLM'  THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Current Senior Lifetime Membership",
     sum (CASE WHEN   p.allocationid = 'LO' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Only Membership",
     sum (CASE WHEN   p.allocationid  = 'LSDM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "Lettermen Senior Dual Membership" ,
     max( p.ReceivedDate ) Transdate
   --sum (CASE WHEN   p.programcode = 'LSDC' and  transtype LIKE '%Credit%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Senior Dual Credit"
          FROM  amy.PacTranItem_alt_vw p join  amy.PatronExtendedInfo_vw c on c.patron = p.acct
AND  p.DriveYear  IN (@RunYear)
and p.AllocationID in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM'   /*no tickets*/ , 'LO'
   /*Credit*/, 'LSDC')
   group by acct) trans join  amy.PatronExtendedInfo_vw c on c.patron = trans.acct
) t 
join
(
select  acct, 
    sum (CASE WHEN  p.allocationid = 'LDM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Dual Membership",
    sum (CASE WHEN  p.allocationid = 'LRG' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Recent Grad Membership",
    sum (CASE WHEN  p.allocationid = 'LLM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Lifetime Membership",
    sum (CASE WHEN  p.allocationid = 'LCLM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Current Lifetime Membership",
    sum (CASE WHEN  p.allocationid = 'LCSLM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Current Senior Lifetime Membership",
    sum (CASE WHEN  p.allocationid = 'LO' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Only Membership",
    sum (CASE WHEN  p.allocationid= 'LSDM' THEN   p.PaymentAmt + p.MatchingPaymentAmt ELSE    0   END)   "TTL - Lettermen Senior Dual Membership" ,
    max(ReceivedDate) Transdate_all
    FROM amy.PacTranItem_alt_vw p where allocationid in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM'   /*no tickets*/ , 'LO'
   /*Credit*/, 'LSDC')
 group by acct
)  allyears  on t.acct= allyears.acct
  /* select t.adnumber ,accountname ,firstname ,lastname ,status ,donortype ,LifetimeGiving ,AdjustedPP ,pprank ,prefclassyear ,UDF4 programname ,
  "Lettermen Dual Membership",
  "Lettermen Recent Grad Membership",
  "Lettermen Lifetime Membership",
  "Lettermen Current Lifetime Membership",
  "Lettermen Current Senior Lifetime Membership",
  "Lettermen Only Membership",
  "Lettermen Senior Dual Membership",
 --TTL
  "TTL - Lettermen Dual Membership",
  "TTL - Lettermen Recent Grad Membership",
  "TTL - Lettermen Lifetime Membership",
  "TTL - Lettermen Current Lifetime Membership",
  "TTL - Lettermen Current Senior Lifetime Membership",
  "TTL - Lettermen Only Membership",
  "TTL - Lettermen Senior Dual Membership",
 --  "Lettermen Senior Dual Credit" ,
   Email ,PHHome ,PHBusiness ,PHOther1 ,PHOther2 ,PHOther1Desc ,PHOther2Desc ,
Code AddressType ,AttnName ,Company ,Salutation ,Address1 ,Address2 ,Address3 ,City ,State ,Zip , 
(select value from advcontactDonorCategories cdc where categoryid = 358 and cdc.contactid = t.contactid) Sport,
transdate
from (
select  c.contactid, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.udf2 donortype, c.LifetimeGiving, c.AdjustedPP, 
case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank,  c.UDF4, c.Email,
c.PHHome, c.PHBusiness, c.PHOther1, c.PHOther2, c.PHOther1Desc, c.PHOther2Desc, 
 sum (CASE WHEN    transtype LIKE '%Pledge%' THEN   l.TransAmount +  l.matchamount ELSE    0   END)   capital_pledge_amount,
  sum (CASE WHEN     transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   capital_receipt_amount,
  max(CASE WHEN     transtype LIKE '%Receipt%' THEN  transdate ELSE    null   END) max_receipt,
  sum (CASE WHEN  p.programcode = 'LDM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Dual Membership",
   sum (CASE WHEN   p.programcode = 'LRG' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Recent Grad Membership",
    sum (CASE WHEN  p.programcode = 'LLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Lifetime Membership",
   sum (CASE WHEN   p.programcode = 'LCLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Current Lifetime Membership",
     sum (CASE WHEN  p.programcode = 'LCSLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Current Senior Lifetime Membership",
   sum (CASE WHEN  p.programcode = 'LO' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Only Membership",
        sum (CASE WHEN  p.programcode = 'LSDM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Senior Dual Membership" ,
                max(h.transdate) Transdate
   --sum (CASE WHEN   p.programcode = 'LSDC' and  transtype LIKE '%Credit%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "Lettermen Senior Dual Credit"
          FROM advcontact c,advcontacttransheader h,advcontacttranslineitems l,advProgram p
         WHERE     c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND transyear IN (@RunYear)
and (matchinggift = 0 or matchinggift is null)
 --left join advcontactaddresses ca on ca.ContactID = c.ContactID
and programcode in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM'   /*no tickets*/ , 'LO'
   /*Credit*/, 'LSDC')
 group by adnumber, c.accountname, c.firstname, c.lastname, c.LifetimeGiving,
  c.AdjustedPP,  case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end, c.UDF4, c.Email,
c.PHHome, c.PHBusiness, c.PHOther1, c.PHOther2, c.PHOther1Desc, c.PHOther2Desc, c.contactid,  c.status, c.udf2 
) t 
join
(
select  h.contactid, 
  sum (CASE WHEN  p.programcode = 'LDM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Dual Membership",
   sum (CASE WHEN   p.programcode = 'LRG' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Recent Grad Membership",
    sum (CASE WHEN  p.programcode = 'LLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Lifetime Membership",
   sum (CASE WHEN   p.programcode = 'LCLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Current Lifetime Membership",
     sum (CASE WHEN  p.programcode = 'LCSLM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Current Senior Lifetime Membership",
   sum (CASE WHEN  p.programcode = 'LO' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Only Membership",
        sum (CASE WHEN  p.programcode = 'LSDM' and  transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   "TTL - Lettermen Senior Dual Membership" ,
        max(h.transdate) Transdate_all
         FROM advcontacttransheader h,advcontacttranslineitems l,advProgram p
         WHERE    h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
and (matchinggift = 0 or matchinggift is null)
and programcode in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM'   /*no tickets*/ , 'LO'
   /*Credit*/, 'LSDC')
 group by h.contactid
)  allyears  on t.contactid = allyears.contactid
left join amy.advcontactaddresses_unique_primary_vw ca on t.contactid= ca.contactid
left join advqaContactExtendedInfo ce on t.contactid = ce.contactid */
GO
