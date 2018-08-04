SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_LettermenBurgessReport](@InYear varchar(4) =null  )

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

select t.adnumber ,accountname ,firstname ,lastname ,status ,donortype ,LifetimeGiving ,AdjustedPP ,pprank ,prefclassyear ,UDF4 programname ,
pledge_amount "Total Pledge Amount" ,
receipt_amount "Total Receipt Amount" , -- max_receipt "Max Transaction Date" ,
Email ,PHHome ,PHBusiness ,PHOther1 ,PHOther2 ,PHOther1Desc ,PHOther2Desc ,
null AddressType , null AttnName , null Company ,Salutation ,Address1 ,Address2 ,Address3 ,City ,State ,Zip  from (
select  c.contactid, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.donortype, c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank,  c.UDF4, c.Email,
c.homephone PHHome, c.BusPhone PHBusiness, c.CellPhone PHOther1, null PHOther2, 'Cell' PHOther1Desc, null PHOther2Desc, 
 Salutation ,adj_address1 Address1 ,adj_address2 Address2 ,adj_address3 Address3 ,City ,State ,Zip , classyear prefclassyear,
 trans.* from 
 (select acct,sum (PledgeAmt+ MatchingPledgeAmt)   pledge_amount,
  sum (PaymentAmt+ MatchingPaymentAmt)   receipt_amount
   from amy.PacTranItem_alt_vw a  where driveyear IN (@RunYear)
and allocationname like '%Lettermen Burgess Banquet%' 
   group by acct) trans join amy.PatronExtendedInfo_vw c   on trans.acct = c.patron
) t 
where  pledge_amount  +  receipt_amount <> 0
/*select t.adnumber ,accountname ,firstname ,lastname ,status ,donortype ,LifetimeGiving ,AdjustedPP ,pprank ,prefclassyear ,UDF4 programname ,
pledge_amount "Total Pledge Amount" ,
receipt_amount "Total Receipt Amount" , -- max_receipt "Max Transaction Date" ,
Email ,PHHome ,PHBusiness ,PHOther1 ,PHOther2 ,PHOther1Desc ,PHOther2Desc ,
Code AddressType ,AttnName ,Company ,Salutation ,Address1 ,Address2 ,Address3 ,City ,State ,Zip  from (
select  c.contactid, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.udf2 donortype, c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank,  c.UDF4, c.Email,
c.PHHome, c.PHBusiness, c.PHOther1, c.PHOther2, c.PHOther1Desc, c.PHOther2Desc, 
 sum (CASE WHEN    transtype LIKE '%Pledge%' THEN   l.TransAmount +  l.matchamount ELSE    0   END)   pledge_amount,
  sum (CASE WHEN     transtype LIKE '%Receipt%' THEN  l.TransAmount +   l.matchamount ELSE    0   END)   receipt_amount
          FROM advcontact c,advcontacttransheader h,advcontacttranslineitems l,advProgram p
         WHERE     c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND transyear IN (:RunYear)
and (matchinggift = 0 or matchinggift is null)
 --left join advcontactaddresses ca on ca.ContactID = c.ContactID
and p.programname like '%Lettermen Burgess Banquet%'  --and p.programid = 268
 group by adnumber, c.accountname, c.firstname, c.lastname, c.LifetimeGiving,
  c.AdjustedPP,  case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end, c.UDF4, c.Email,
c.PHHome, c.PHBusiness, c.PHOther1, c.PHOther2, c.PHOther1Desc, c.PHOther2Desc, c.contactid,  c.status, c.udf2 
) t 
left join  amy.advcontactaddresses_unique_primary_vw ca  on t.contactid= ca.contactid -- and primaryaddress = 1
left join advqaContactExtendedInfo ce on t.contactid = ce.contactid
where  pledge_amount  +  receipt_amount <> 0 */
GO
