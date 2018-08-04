SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconYearList]
as
select distinct ticketyear from PriorityEvents where ticketyear is not null 
order by ticketyear desc
GO
