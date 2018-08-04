SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[PacTranItem_alt_vw] as
select 
replace((case when MatchedDonorAccountid  is not null  then MatchedDonorAccountID else p.AccountID end),'?','') ACCT,
replace((case when MatchedDonorAccountid is not null then p.AccountID 
when isnull(matchingpaymentdonorid,'') <> '' then matchingpaymentdonorid
else  MatchedDonorAccountID end),'?','')  MATCHACCT,
replace(p.AccountID, '?','') AccountID, p.MatchedDonorAccountID, p.MatchingPaymentDonorID, 
p.DriveYear,
p.AllocationID, p.ReceivedDate,
case when MatchedDonorAccountid <> 0 then 0 else p.PaymentAmt/100 end PaymentAmt, 
p.PledgeAmt/100 PledgeAmt,
p.MatchingPledgeAmt/100 MatchingPledgeAmt,  
case when MatchedDonorAccountid <> 0 then PaymentAmt/100 else  0 end MatchingPaymentAmt,
p.CreditAmt/100 CreditAmt,
p.OrganizationID, p.PacTranID, p.PacTranItemID, p.ItemTypeCodeDbID, p.ItemTypeCodeType, p.ItemTypeCodeSubtype, p.ItemTypeCode, p.AccountDbID,  p.ChannelID, p.Comments, 
p.EmailRecipient, p.FundTypeCodeDbID, p.FundTypeCodeType, p.FundTypeCodeSubtype, p.FundTypeCode, p.FundMotiveID, p.FundSourceID, 
p.IsEmailConfirmationSent, p.IsPaymentScheduled, p.IsPledgeRolledOver, p.IsPrinted, p.IsRenewable, 
p.Note, p.PacBatchID,  p.SpecialEventID, p.ReceiptedDonorAccountID,
p.sys_UpdateTS, p.sys_CreateTS,
l.[Name] allocationname,
al.[Name] allocationgroup,
CharitablePct,
ptp2.paycodeid,
ptp2.paymenttypecode
from PacTranItem p
join allocationlanguage l on l.languagecode = 'en_US'  and l.allocationid = p.allocationid
join allocation a on  a.allocationid = p.allocationid
join allocationgrouplanguage al  on al.LanguageCode = 'en_US'  and al.AllocationGroupID = a.AllocationGroupID
left join  (select PacTranID, accountid, max(ptp.paycodeid) paycodeid,max(ptp.paymenttypecode) paymenttypecode from PacTranPayment ptp 
group by   pactranid, accountid) ptp2 on    p.PacTraniD = ptp2.PacTranID and p.accountid = ptp2.accountid
GO
