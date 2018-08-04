SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconSportTypeList]
as
select distinct sporttype  from PriorityEvents p where p.sporttotalreport = 1
GO
