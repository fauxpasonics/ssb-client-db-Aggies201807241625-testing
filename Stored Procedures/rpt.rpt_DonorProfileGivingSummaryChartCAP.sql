SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileGivingSummaryChartCAP] (@ADNumber INT)

AS

DECLARE @CurrentYear VARCHAR(20)
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)

--Annual Graph 
SELECT 
	p.ProgramName
	,con.ADNumber
	,SUM( cashreceipts+matchreceipts) "Amount"
FROM dbo.ADVdonationsummary ds
JOIN dbo.ADVProgram p 
	ON ds.ProgramID = p.ProgramID
JOIN dbo.ADVContact con
	ON ds.ContactID = con.ContactID
WHERE 1=1
	AND con.ADNumber = @ADNumber 
	AND ds.TransYear = 'CAP'
	AND p.LifetimeGiving = 1
GROUP BY p.programname, con.ADNumber
HAVING SUM( cashreceipts+matchreceipts) <>0
GO
