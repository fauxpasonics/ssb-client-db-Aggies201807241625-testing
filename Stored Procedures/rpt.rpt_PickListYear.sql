SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_PickListYear](@Category VARCHAR(100)) AS 

SELECT DISTINCT
	DATEPART(yyyy, e.tixeventstartdate) AS Year
FROM ods.VTXtixevents e
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON e.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1
	AND categoryname = @Category
	AND e.[tixeventstartdate] > '2013-01-01'
GO
