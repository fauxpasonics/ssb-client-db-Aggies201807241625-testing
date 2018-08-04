SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorGroupList]

as


--select -1 groupid , 'All' groupname
--union all
select groupid , groupname FROM advqagroup
order by groupname
GO
