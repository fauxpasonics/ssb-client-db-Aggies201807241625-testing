SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconSportTypeList_suite]
as
select distinct sporttype  from PriorityEvents p where  sporttype in( 'FB','BSB')
GO
