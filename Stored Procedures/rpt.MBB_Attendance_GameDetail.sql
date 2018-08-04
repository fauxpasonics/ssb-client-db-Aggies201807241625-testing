SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [rpt].[MBB_Attendance_GameDetail] (@eventlookupid NVARCHAR(10))
AS
    


SELECT  DISTINCT
	season, 
	tixeventtitleshort, 
	tixeventstartdate, 
	tixeventlookupid, 
	opponent
	
FROM rpt.MBB_Attendance r

WHERE tixeventlookupid = @eventlookupid
GO
