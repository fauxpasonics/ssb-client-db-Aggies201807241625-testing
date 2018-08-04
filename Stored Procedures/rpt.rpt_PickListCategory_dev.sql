SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[rpt_PickListCategory_dev] (@YearID INT) AS

--DECLARE @YearID INT = 18854737--177
SELECT '-SELECT ONE-' categoryname, -1 AS categoryid
UNION ALL
SELECT DISTINCT categoryname, categoryid
FROM ods.VTXCategory
WHERE parentid = @YearID
GO
