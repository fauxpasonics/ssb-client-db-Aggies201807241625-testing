SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[MBB_Attendance_Seasons]
	--@parameter_name AS scalar_data_type ( = default_value ), ...
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS

SELECT DISTINCT 
	REPLACE(REPLACE(Season,'-MB',''),'B','20') AS SeasonYear
, Season AS SeasonCode
FROM rpt.MBB_Attendance
GO
