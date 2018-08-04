SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[rpt_DonorGroupYearList] 
--DROP PROCEDURE [amy].[rpt_DonorGroupYearList]
CREATE PROCEDURE [amy].[rpt_DonorGroupYearList]

as


select distinct DGY.MemberYear, case when memberyear = cast(year(getdate()) as varchar) then 'X' else null end CurrentDate
FROM ADVQADonorGroupbyYear DGY 
order by  DGY.MemberYear desc
GO
