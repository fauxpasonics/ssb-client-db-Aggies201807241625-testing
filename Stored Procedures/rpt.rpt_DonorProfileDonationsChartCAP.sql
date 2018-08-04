SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_DonorProfileDonationsChartCAP] (@ADNumber int)

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT 
	YEAR(transdate) TransYear
	,SUM(transamount+matchamount) AS Amount
FROM dbo.ADVContactTransHeader h
INNER JOIN dbo.ADVContactTransLineItems l 
	ON (h.transid = l.transid      
        AND (    h.TransYear = 'CAP'   
		AND year(transdate) >= @CurrentYear-4
        AND transtype like '%Receipt%'  ))
INNER JOIN dbo.ADVProgram  p on (l.programid = p.programid and lifetimegiving = 1) 
WHERE h.contactid = @ContactID
GROUP BY year(transdate)
GO
