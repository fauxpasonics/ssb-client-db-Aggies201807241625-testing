SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileTransactionSummary]
@ADNumber int,
@TRANSYEAR nvarchar(100) = null
as

--if @TRANSYEAR  is null 
--set @TRANSYEAR = cast(year(getdate()) as nvarchar)+ ',CAP'

select programname,transyear,  DonFeeType, GiftInKind,pledge_trans_amount,   
    receipt_trans_amount,   
    pledge_match_amount,   
   receipt_match_amount, 
  credit_amount , 
   isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans t where t.programid  = b.programid 
 and resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = b.ContactID ), 0)  + 
  isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM advPaymentSchedule ps 
          where ps.ProgramID = b.ProgramId
               and @transyear  like '%'+ transyear+ '%'
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  b.contactid), 0) Scheduled_payments, pledge_trans_amount - receipt_trans_amount balance
  from 
(SELECT   adnumber , p.programname, p.programid,
c.contactid, c.AccountName, transyear,SpecialEvent,
case when transyear = 'CAP' then 'Capital' 
 when SpecialEvent = 1 then 'Fee'
else 'Annual' end DonFeeType,
case when transtype lIKE '%GIK%' then 'X' 
else null end GiftinKind,
  sum (CASE WHEN transtype LIKE '%Pledge%' THEN  l.TransAmount ELSE  0 END)  pledge_trans_amount,   
  sum (CASE WHEN transtype LIKE '%Receipt%' THEN l.TransAmount ELSE  0 END)  receipt_trans_amount,   
  sum (CASE WHEN transtype LIKE '%Pledge%' THEN  l.MatchAmount ELSE 0 END)  pledge_match_amount,   
  sum (CASE WHEN transtype LIKE '%Receipt%' THEN l.matchamount ELSE    0   END) receipt_match_amount, 
  sum (CASE WHEN transtype LIKE '%Credit%' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  credit_amount
          FROM advcontact c,
          advcontacttransheader h,
          advcontacttranslineitems l,
          advProgram p
where c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
--AND transyear IN (@currentyear, 'CAP')
AND (
(@transyear is not null and @transyear  like '%'+ ltrim(rtrim(transyear))+ '%') or
(@transyear is  null))
--and (matchinggift = 0 or matchinggift is null)
         and c.adnumber = @adnumber
        GROUP BY adnumber , p.programname,p.programid,
c.contactid, c.AccountName, transyear, SpecialEvent ,case when transtype lIKE '%GIK%' then 'X' 
else null end) b ORDER BY TRANSYEAR DESC
GO
