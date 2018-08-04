SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfilePriorityPointsBreakdown] (@ADNumber INT)

AS 
--Breakdown

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT 
	[Description]
	,Points 
FROM dbo.ADVContactPointsSummary cps
JOIN dbo.ADVContact con
	ON cps.ContactID = con.ContactID
WHERE con.ADNumber = @ADNumber
GO
