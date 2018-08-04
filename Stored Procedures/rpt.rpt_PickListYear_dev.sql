SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[rpt_PickListYear_dev]  AS 

/*
SELECT
	--DISTINCT DATEPART(yyyy, e.tixeventstartdate) AS Year
	DISTINCT cat2.categoryname Year, cat2.categoryid YearID
FROM ods.VTXtixevents e (NOLOCK)
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr (NOLOCK)
	ON e.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat (NOLOCK)
	ON ecr.categoryid = cat.categoryid 
LEFT JOIN [ods].[VTXcategory] cat2 (NOLOCK)
	ON cat.parentid = cat2.categoryid
WHERE 1=1
	AND cat.categoryname = @Category
	AND e.[tixeventstartdate] > '2013-01-01'
	AND cat2.categoryname IS NOT NULL
*/  


SELECT DISTINCT categoryname Year, categoryid YearID
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
