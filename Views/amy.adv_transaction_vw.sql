SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[adv_transaction_vw] as select  c.contactid, c.adnumber, c.accountname, c.status, h.transid,
h.TransYear, h.TransDate, h.TransGroup, h.TransType, h.MatchingAcct, h.MatchingTransID, h.PaymentType, h.ReceiptID, h.BatchRefNo, h.notes, 
p.programname,
li.ProgramID, li.MatchProgramID, li.TransAmount, li.MatchAmount, li.MatchingGift, li.PK, li.Comments  , r.adnumber receiptadnumber, r.accountname receiptname, r.status receiptstatus
from advcontact c
left join advcontacttransheader h on  c.contactid = h.contactid 
left join advcontacttranslineitems li on  h.transid = li.transid
left join advprogram p on  p.programid = li.programid
left join advcontact r on h.ReceiptID = r.contactid
GO
