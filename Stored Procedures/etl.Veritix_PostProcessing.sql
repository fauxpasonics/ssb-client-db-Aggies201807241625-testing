SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Veritix_PostProcessing]

AS 
BEGIN

	EXEC rpt.rpt_PickListTickets_Update

	EXEC rpt.MBB_Attendance_Load

	--EXEC amy.rpt_SportSeatRefresh

END
GO
