SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DriveYearList]

as

select * from (
select 'CAP' DriveYear, null  CurrentDate, '''0''' ValueYear
union 
select distinct DGY.Memberyear DriveYear, case when memberyear = cast(year(getdate()) as varchar) then 'X' else null end CurrentDate,  ' ''' + DGY.Memberyear + ''' ' ValueYear
FROM ADVQADonorGroupbyYear DGY  where memberyear >= '1989') y order by y.DriveYear desc
GO
