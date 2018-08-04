SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO

CREATE PROCEDURE [rpt].[MBB_Attendance_Games] (@season NVARCHAR(10))
	--@parameter_name AS scalar_data_type ( = default_value ), ...
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
begin
SELECT DISTINCT tixeventlookupid, opponent
FROM rpt.MBB_Attendance
WHERE season = @season
end
GO
