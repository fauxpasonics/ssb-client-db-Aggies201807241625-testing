SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconFBSportList]
as
select distinct sporttype  from PriorityEvents  where sporttype = 'FB'
GO
