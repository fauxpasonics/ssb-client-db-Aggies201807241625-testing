SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_ReportYearList]
as

select distinct DGY.MemberYear  MemberYear
FROM ADVQADonorGroupbyYear DGY 
where memberyear between  cast(year(getdate())-5 as varchar) and  cast(year(getdate())+5 as varchar) 
order by  DGY.MemberYear desc
GO
