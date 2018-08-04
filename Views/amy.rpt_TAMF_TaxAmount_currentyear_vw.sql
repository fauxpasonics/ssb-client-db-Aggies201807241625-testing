SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[rpt_TAMF_TaxAmount_currentyear_vw] as 
select acct ADNUMBER, allocationname Programname, allocationgroup ProgramGroup,       year(ReceivedDate) YearGiven,  sum(PaymentAmt)  TotalDonation
from [amy].[PacTranItem_alt_vw] where (isnull(CharitablePct ,0) <> 0  or allocationgroup = 'Kyle Field Campaign')
and year(ReceivedDate)>=year(getdate())
group by acct , allocationname , allocationgroup ,       year(ReceivedDate) /*
 SELECT ADNUMBER, 
  advProgram.ProgramName, 
   advProgram.ProgramGroup,
   YearGiven,
  Donations.TotalDonation
 advCONTACT C
  JOIN ( SELECT advContactTransHeader.ReceiptID, advContactTransLineItems.ProgramID, 
         SUM(ISNULL(advContactTransLineItems.TransAmount, 0)) AS TotalDonation, 
          year(transdate) YearGiven
          FROM advContactTransHeader 
            JOIN advContactTransLineItems ON advContactTransHeader.TransID = advContactTransLineItems.TransID
          WHERE  
            (advContactTransHeader.TransType IN ('Cash Receipt', 'GIK Receipt' ))
          GROUP BY advContactTransLineItems.ProgramID, advContactTransHeader.ReceiptID ,  year(transdate) ) Donations ON C.CONTACTID = DONATIONS.RECEIPTID
   JOIN advProgram ON Donations.ProgramID = advProgram.ProgramID
 WHERE (isnull(advProgram.DonationValue,0) <> 0 OR advProgram.ProgramID IN (SELECT ProgramID FROM advProgram WHERE ProgramGroup = 'Kyle Field Campaign'))
 and yeargiven >=year(getdate()) */
GO
