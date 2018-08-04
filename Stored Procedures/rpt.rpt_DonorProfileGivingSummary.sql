SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[rpt_DonorProfileGivingSummary] (@ADNumber int)

AS

DECLARE @CurrentYear VARCHAR(20)
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)

SELECT
	c.lifetimegiving AS LifetimeGiving
	,(
		SELECT 
			SUM(transamount + matchamount)
		FROM dbo.ADVContactTransHeader h
		INNER JOIN dbo.ADVContactTransLineItems l 
			ON (h.transid = l.transid
				AND (h.TransYear = @CurrentYear OR (h.TransYear = 'CAP'   
				AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
				AND transtype like '%Receipt%' )
		INNER JOIN dbo.ADVProgram  p on (l.programid = p.programid and lifetimegiving = 1)
	where h.contactid =  c.contactid) AS YTDReceipts,
	c.adjustedpp AS PriorityPts , 
	c.pprank AS Rank 
from dbo.ADVcontact c
left join dbo.ADVQAContactExtendedInfo cei 
	on cei.contactid = c.contactid
where c.ADNumber = @ADNumber
GO
