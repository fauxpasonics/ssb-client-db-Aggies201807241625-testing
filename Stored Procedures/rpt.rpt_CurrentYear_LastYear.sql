SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_CurrentYear_LastYear] AS




SELECT c.[Year] AS CurYear, c.YearID AS CurYearID, x.[Year] AS LastYear, x.YearID AS LastYearID, t.[Year] AS TwoYearsAgo, t.YearID AS TwoYearsAgoID
FROM 
(
SELECT DISTINCT MAX(CAST(categoryname AS INT)) [Year], MAX(CAST(categoryid AS BIGINT)) YearID
FROM ods.VTXCategory
WHERE categorytypeid = 1
	AND parentid IS NULL
    AND NOT categoryid IN (
		22490420,  --Test
		86, --HighschoolEvents
		188, --KFR
		189 --Base
		)
	AND createdate >= '10/2/2012' ) c
	LEFT JOIN 
	(
	SELECT DISTINCT (CAST(categoryname AS INT)) [Year], (CAST(categoryid AS BIGINT)) YearID
FROM ods.VTXCategory
WHERE categorytypeid = 1
	AND parentid IS NULL
    AND NOT categoryid IN (
		22490420,  --Test
		86, --HighschoolEvents
		188, --KFR
		189 --Base
		)
	AND createdate >= '10/2/2012'
	) x ON x.[Year] = (c.[Year]-1)
	LEFT JOIN 
	(
	SELECT DISTINCT (CAST(categoryname AS INT)) [Year], (CAST(categoryid AS BIGINT)) YearID
FROM ods.VTXCategory
WHERE categorytypeid = 1
	AND parentid IS NULL
    AND NOT categoryid IN (
		22490420,  --Test
		86, --HighschoolEvents
		188, --KFR
		189 --Base
		)
	AND createdate >= '10/2/2012'
	) t ON t.[Year] = (c.[Year]-2)
GO
