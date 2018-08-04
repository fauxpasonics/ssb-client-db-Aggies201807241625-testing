SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileDonorCategories] (@ADNumber INT)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT  
	dc.CategoryCode
	,categoryname
	,value
	,cdc.CreateDate
	,cdc.UpdateDate
FROM dbo.ADVDonorCategories dc
JOIN dbo.ADVQA_adv_contactdonorcategories cdc
ON pk = cdc.categoryid 
AND contactid  = @ContactID
GO
