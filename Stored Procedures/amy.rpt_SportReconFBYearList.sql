SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconFBYearList]
as
select distinct ticketyear from PriorityEvents where ticketyear >= '2015'
order by ticketyear desc
GO
