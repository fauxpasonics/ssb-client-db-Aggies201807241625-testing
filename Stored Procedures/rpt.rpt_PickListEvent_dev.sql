SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_PickListEvent_dev](@CategoryID NVARCHAR(100)) AS

--DECLARE @CategoryID NVARCHAR(100) = 18854740

SELECT 
DISTINCT e.tixeventid, e.tixeventtitleshort 
	FROM ods.VTXtixevents e
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON e.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1
	AND cat.categoryid = @CategoryID
	--AND DATEPART(yyyy, e.tixeventstartdate) = '2015' --@Year
GO
