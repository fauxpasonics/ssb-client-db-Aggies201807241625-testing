SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileContactHistoryPrior] (@ADNumber INT)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT 
	corrdate
	,type
	,cc.ContactedBy  Rep
	,[subject] + CASE WHEN Notes IS NOT NULL THEN ' -  ' ELSE '' END + CAST( ISNULL(notes, '') AS VARCHAR) Notes
FROM dbo.ADVContactCorrespondence cc
WHERE contactid = @ContactID
AND DATEPART(yyyy,cc.CorrDate) <> @CurrentYear
ORDER BY cc.CorrDate DESC
GO
