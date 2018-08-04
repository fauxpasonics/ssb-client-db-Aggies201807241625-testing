SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [rpt].[rpt_PickListYear_max]  AS 


SELECT DISTINCT MAX(categoryname) [Year], MAX(categoryid) YearID
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
GO
