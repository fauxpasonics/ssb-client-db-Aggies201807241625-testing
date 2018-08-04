SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DriveYearListnoCAP]

as

select  distinct yearcategory DriveYear, case when yearcategory = cast(year(getdate()) as varchar) then 'X' else null end CurrentDate,  ' ''' + yearcategory + ''' ' ValueYear from 
 amy.veritix_events where  category not in ('Highschool Events','Base') and subcategory in ('SeasonParking','Season') 
and subcategory not in ('Non-Event') and subcategoryalt not in ('Non-Event') 
order by yearcategory desc
GO
