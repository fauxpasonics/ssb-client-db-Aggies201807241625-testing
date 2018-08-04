SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_PickListEvent](@Category NVARCHAR(100), @Year NVARCHAR(4))

AS

SELECT DISTINCT
	e.tixeventid
	,e.tixeventtitleshort
	FROM ods.VTXtixevents e
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON e.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1
	AND categoryname = @Category
	AND e.[tixeventstartdate] > '2013-01-01'
	AND DATEPART(yyyy, e.tixeventstartdate) = @Year
GO
