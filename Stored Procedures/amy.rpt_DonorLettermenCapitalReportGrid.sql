SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorLettermenCapitalReportGrid] 
as
select adnumber ,accountname ,firstname ,lastname ,status ,donortype , LifetimeGiving,AdjustedPP ,pprank ,classyear prefclassyear ,publishname programname ,
capital_pledge_amount "Total Pledge Amount" ,
capital_receipt_amount "Total Receipt Amount" , -- max_receipt "Max Transaction Date" ,
capital_receipt_cap4 "Cap 4 Receipt",
capital_receipt_cap5 "Cap 5 Receipt" ,Email ,PHHome ,PHBusiness ,PHOther1 ,PHOther2 ,PHOther1Desc ,PHOther2Desc ,
null AddressType ,null AttnName ,null Company ,Salutation ,Address1 ,Address2 ,Address3 ,City ,State ,Zip , 
--(select value from advcontactDonorCategories cdc where categoryid = 358 and cdc.contactid = t.contactid)   select * from advdonorcategories where pk=358 
(select value from amy.donorcategory_vw cdc where categorycode = 'SPORT' and cdc.adnumber = t.adnumber )  Sport from (
select  p.contactid,  p.adnumber,  p.accountname, p.firstname, p.lastname,
 p.status,  p.donortype,  p.lifetimegiving, p.adjustedpp, p.PPRank,
publishname ,  Email,
 p.homephone  PHHome, p.busphone  PHBusiness, p.busphone  PHOther1, null PHOther2, 'Cell' PHOther1Desc, null PHOther2Desc, 
   capital_pledge_amount,   capital_receipt_amount,  max_receipt,   capital_receipt_cap4,      capital_receipt_cap5  ,       
    p.Salutation,      p.adj_Address1 Address1,         p.adj_Address2   Address2, 
    p.adj_Address3  Address3, City ,  State ,  zip , classyear
 from 
 (select acct, 
      sum (PledgeAmt + MatchingPledgeAmt )   capital_pledge_amount,
      sum (PaymentAmt + MatchingPaymentAmt )   capital_receipt_amount,
      max(CASE WHEN     PaymentAmt is not null THEN  ReceivedDate ELSE    null   END) max_receipt,
      sum (CASE WHEN  a.AllocationID = 'CAP4-LLF' tHEN  PaymentAmt + MatchingPaymentAmt  ELSE    0   END)   capital_receipt_cap4,
      sum (CASE WHEN   a.AllocationID =  'CAP5-LLF' THEN PaymentAmt + MatchingPaymentAmt  ELSE    0   END)   capital_receipt_cap5  
 from  amy.PacTranItem_alt_vw a where driveyear = 0 and   a.allocationname like '%Letter%' and a.allocationid not like 'KFC%'
 group by acct
 )
 trans
join amy.PatronExtendedInfo_vw p   on p.patron = trans.acct
) t 
where   capital_pledge_amount  +  capital_receipt_amount <> 0
GO
