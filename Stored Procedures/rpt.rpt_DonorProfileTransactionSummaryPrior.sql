SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileTransactionSummaryPrior] (@ADNumber INT)

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

select  
  	programname
	,b.TransYear
	,DonFeeType
	,b.GiftInKind
	,pledge_trans_amount   
    ,receipt_trans_amount   
    ,pledge_match_amount   
	,receipt_match_amount 
	,credit_amount
   	,ISNULL
	(
		(  
			SELECT  
				SUM(pmt_amount) 
			FROM dbo.ADVEvents_tbl_trans t 
			WHERE t.programid  = b.programid 
				AND resp_code IS NULL AND resp_text IS NULL 
				AND t.contactid = b.ContactID 
		)
	, 0)  
	+ 
	ISNULL
	( 
		(
			SELECT 
				SUM (transamount) Annual_ScheduledPayments
			FROM dbo.ADVPaymentSchedule ps 
			WHERE ps.ProgramID = b.ProgramId
               --AND transyear  in (:selectedyear)
			   AND transyear NOT IN ('2015', 'CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= GETDATE()
               AND ps.contactid =  b.contactid
		), 0
	) Scheduled_payments
FROM
(
	SELECT   
		adnumber
		,p.programname
		,p.programid
		,c.contactid
		,c.AccountName
		,transyear
		,SpecialEvent
		,MAX(CASE WHEN transtype LIKE '%GIK%' THEN 'X' END) GiftInKind
		,CASE 
			WHEN transyear = 'CAP' THEN 'Capital' 
			WHEN SpecialEvent = 1 THEN 'Fee'
			ELSE 'Annual' 
		END DonFeeType
		,SUM (CASE WHEN transtype LIKE '%Pledge%' THEN  l.TransAmount ELSE  0 END)  pledge_trans_amount
		,SUM (CASE WHEN transtype LIKE '%Receipt%' THEN l.TransAmount ELSE  0 END)  receipt_trans_amount 
		,SUM (CASE WHEN transtype LIKE '%Pledge%' THEN  l.MatchAmount ELSE 0 END)  pledge_match_amount   
		,SUM (CASE WHEN transtype LIKE '%Receipt%' THEN l.matchamount ELSE    0   END) receipt_match_amount 
		,SUM (CASE WHEN transtype LIKE '%Credit%' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  credit_amount
	FROM dbo.ADVcontact c
    JOIN dbo.ADVcontacttransheader h
		ON c.contactid = h.contactid
    JOIN dbo.ADVcontacttranslineitems l
		ON h.TransID = l.TransID
    JOIN dbo.ADVProgram p
		ON p.ProgramID = l.ProgramID
	WHERE 1=1
		AND transyear NOT IN (@CurrentYear, 'CAP')
		--AND transyear IN (:selectedyear)
		--and (matchinggift = 0 or matchinggift is null)
		AND c.adnumber = @ADNumber
	GROUP BY 
		adnumber
		,p.programname
		,p.programid
		,c.contactid
		,c.AccountName
		,transyear
		,SpecialEvent 
) b
GO
