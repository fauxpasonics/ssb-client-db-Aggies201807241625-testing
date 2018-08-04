SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*****

DCH 2018-05-25	-	swapped amy.rpt_SportSeatRefresh for amy.proc_POSTETL_BuildReports 


*****/



CREATE PROCEDURE [etl].[Veritix_PostProcessing_AggiesCustom]

AS 
BEGIN

--	EXEC amy.rpt_SportSeatRefresh			--	DCH 2018-05-25

	EXEC amy.proc_POSTETL_BuildReports;		--	DCH 2018-05-25


	/* SSB compleation step. Do not remove below statement*/
	DELETE dba.PriceLevelOverridePeriod WHERE ExpirationDateUTC > GETUTCDATE()	

END
GO
