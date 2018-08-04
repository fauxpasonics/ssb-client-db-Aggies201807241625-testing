SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_PickListCategory_dev2] (@YearID INT, @LastYearID int, @TwoYearsAgoID int) AS

begin

/*
DECLARE @YearID INT = 23240860 
DECLARE @LastYearID INT = 18854737 
DECLARE @TwoYearsAgoID INT = 190
--*/



SELECT 
' - SELECT ONE - 'SportDesc, 'NA - Season' tixeventlookupid, -1 tixeventid, -1 categoryid, -1 AS ParentYear, 
'NA' AS SingleGameEventListView, 'NA' AS CurSeason, 'NA' AS CurSeasonGamePrefix,
'NA - Last Season' AS ly_tixeventlookupid, -2 AS ly_tixeventid, -2 AS ly_categoryid, -2 AS ly_ParentYear

UNION ALL

SELECT c.SportDesc, c.tixeventlookupid, c.tixeventid, c.categoryid, c.ticketyear AS ParentYear, c.SingleGameEventListView, c.CurSeason, c.CurSeasonGamePrefix,
y.tixeventlookupid AS ly_tixeventlookupid, y.tixeventid AS ly_tixeventid, y.categoryid AS ly_categoryid, y.ticketyear AS ly_ParentYear
FROM (
SELECT x.* 
FROM (
	Select DISTINCT s.SportDesc , pe.tixeventlookupid, pe.tixeventid, c.categoryid, pe.ticketyear, 
		scd.SingleGameEventListView + '_CY' AS SingleGameEventListView, scd.CurSeason, scd.CurSeasonGamePrefix,
		RANK() OVER (PARTITION BY s.SportDesc ORDER BY e.tixeventid DESC) rnk
	FROM ods.VTXcategory c
		INNER JOIN ods.VTXeventcategoryrelation ecr ON ecr.categoryid = c.categoryid
		INNER JOIN ods.VTXtixevents e ON e.tixeventid = ecr.tixeventid 
		INNER JOIN amy.PriorityEvents pe ON pe.tixeventid = e.tixeventid
		INNER JOIN amy.Sport s ON pe.sporttype = s.SportType
		INNER JOIN amy.vw_SportCodeDetail scd ON scd.SportID = s.SportID
	WHERE IncludePriorityPoints = 'X' AND (c.parentid = @YearID OR c.parentid = @LastYearID OR c.parentid = @TwoYearsAgoID)
		AND c.categorytypeid = 1 AND c.ETL_IsDeleted = 0 AND ecr.ETL_IsDeleted = 0 AND e.ETL_IsDeleted = 0
) x
WHERE x.rnk = 1
) c LEFT JOIN (
SELECT x.* 
FROM (
	Select DISTINCT s.SportDesc , pe.tixeventlookupid, pe.tixeventid, c.categoryid, pe.ticketyear, 
		RANK() OVER (PARTITION BY s.SportDesc ORDER BY e.tixeventid DESC) rnk
	FROM ods.VTXcategory c
		INNER JOIN ods.VTXeventcategoryrelation ecr ON ecr.categoryid = c.categoryid
		INNER JOIN ods.VTXtixevents e ON e.tixeventid = ecr.tixeventid 
		INNER JOIN amy.PriorityEvents pe ON pe.tixeventid = e.tixeventid
		INNER JOIN amy.Sport s ON pe.sporttype = s.SportType
		INNER JOIN amy.vw_SportCodeDetail scd ON scd.SportID = s.SportID
	WHERE IncludePriorityPoints = 'X' AND (c.parentid = @YearID OR c.parentid = @LastYearID OR c.parentid = @TwoYearsAgoID)
		AND c.categorytypeid = 1 AND c.ETL_IsDeleted = 0 AND ecr.ETL_IsDeleted = 0 AND e.ETL_IsDeleted = 0
) x
WHERE x.rnk = 2 ) y ON y.SportDesc = c.SportDesc

end
GO
