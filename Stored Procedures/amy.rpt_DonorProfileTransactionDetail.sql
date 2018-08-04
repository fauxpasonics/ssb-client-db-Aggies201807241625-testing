SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileTransactionDetail]
@ADNumber int,
@TRANSYEAR nvarchar(100) = null
as

--if @TRANSYEAR  is null 
--set @TRANSYEAR = cast(year(getdate()) as nvarchar)+ ',CAP'

 SELECT  -- adnumber ,
l.TransID [Transid], transdate [Date], transtype [Type], transyear [Year], 
transamount [TransAmount], matchamount [MatchAmount],
p.programname [AppliesTo], h.PaymentType, case when p.SpecialEvent = 1 then 'X' else null end SpecialEvent, 
(select cast(c1.adnumber as varchar)+ '-'+ c1.AccountName
from advcontact c1 where c1.contactid = h.ReceiptID) [ReceiptedTo], 
case when matchinggift = 1 then 'X' else null end  [Matching Gift], 
case when transtype lIKE '%GIK%' then 'X' 
else null end GiftinKind
          FROM advcontact c,
          advcontacttransheader h,
          advcontacttranslineitems l,
          advProgram p
where c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND (
(@transyear is not null and @transyear  like '%'+ ltrim(rtrim(transyear))+ '%') or
(@transyear is  null))
/*and (matchinggift = 0 or matchinggift is null)*/
         and c.adnumber = @ADNumber order BY transdate DESC, transid desc
GO
