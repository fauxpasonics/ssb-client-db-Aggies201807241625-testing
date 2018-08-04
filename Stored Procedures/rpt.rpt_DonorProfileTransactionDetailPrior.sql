SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileTransactionDetailPrior] (@ADNumber INT)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT  -- adnumber ,
	l.TransID Transid
	,transdate Date
	,transtype Type
	,transyear Year
	,transamount TransAmount
	,matchamount MatchAmount
	,p.programname AS AppliesTo
	,h.PaymentType
	,CASE WHEN p.SpecialEvent = 'True' THEN 'X' END AS SpecialEvent
	,(SELECT CAST(c1.adnumber AS VARCHAR)+ '-'+ c1.AccountName FROM dbo.ADVcontact c1 WHERE c1.contactid = h.ReceiptID) ReceiptedTo
	,CASE WHEN matchinggift = 'True' THEN 'X' END "Matching Gift"
	,CASE WHEN transtype LIKE '%GIK%' THEN 'X' END GiftInKind
FROM dbo.ADVcontact c
JOIN dbo.ADVcontacttransheader h
	ON c.contactid = h.contactid
JOIN dbo.ADVcontacttranslineitems l
	ON h.TransID = l.TransID
JOIN dbo.ADVProgram p
	ON p.ProgramID = l.ProgramID
WHERE 1=1
AND transyear NOT IN (@CurrentYear, 'CAP')
AND c.adnumber = @ADNumber
ORDER BY h.TransYear,c.ProgramName DESC
GO
