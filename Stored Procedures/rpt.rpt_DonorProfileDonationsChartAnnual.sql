SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_DonorProfileDonationsChartAnnual] (@ADNumber int)

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT  
	TransYear 
	,sum( cashreceipts+matchreceipts+GIKReceipts) Amount
FROM dbo.ADVDonationSummary ds
JOIN dbo.ADVProgram p 
	ON (ds.ProgramID = p.ProgramID and p.LifetimeGiving = 1)
  WHERE contactid = @ContactID
  AND    TransYear >=  @CurrentYear-4 
  AND transyear<> 'CAP'
  GROUP BY TransYear
GO
