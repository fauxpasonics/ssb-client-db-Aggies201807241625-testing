SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorCategoryList]

as


--select distinct pk categoryid, DGY.CategoryCode + ' - '  + DGY.CategoryName longname,  DGY.CategoryName FROM ADVDonorCategories DGY  order by  DGY.CategoryName
select  DonorCategoryID categoryid,  DonorCategoryID + ' - '  + [Name]   collate DATABASE_DEFAULT longname,  DGY.[Name] CategoryName   from ods.PAC_DCatDefinitionLanguage DGY
GO
