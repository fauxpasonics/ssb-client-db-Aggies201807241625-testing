SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:  06/15/2015
-- Description:   Query to identify a runaway query
--                consuming CPU. The type of query
--                running, full script and sessionID are displayed
-- =============================================
CREATE PROCEDURE [dba].[usp_RunAwayQueries]
    
AS
BEGIN
 
SELECT
Spid,
Hostname,
Program_name,
Nt_username,
Loginame,
Cmd,
t.text
FROM sys.sysprocesses
CROSS APPLY(SELECT text FROM sys.dm_exec_sql_text(sql_handle))t
 
END
GO
