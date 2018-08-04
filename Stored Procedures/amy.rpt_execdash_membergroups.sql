SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_membergroups] as
select GroupName, MemberYear, donorcount, --lastyearsum, 
percentchange from amy.rpt_execdash_membergroups_vw 
order by GroupName, MemberYear
GO
