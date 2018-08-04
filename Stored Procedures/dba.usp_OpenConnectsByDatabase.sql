SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:      
-- Create date: 
-- Description:   List the open connections and
-- groups by DB
-- =============================================
CREATE PROCEDURE [dba].[usp_OpenConnectsByDatabase]
AS
BEGIN
    SELECT
    DB_NAME(dbid) as DBName,
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE
    dbid > 0
GROUP BY
    dbid, loginame
order by dbid, loginame
END
GO
