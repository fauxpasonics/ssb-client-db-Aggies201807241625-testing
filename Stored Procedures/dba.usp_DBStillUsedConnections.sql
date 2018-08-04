SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:       
-- Create date: 
-- Description:  Identify DB's connections to determine if 
-- DB's are still used.
-- =============================================
CREATE PROCEDURE [dba].[usp_DBStillUsedConnections]
    
AS
BEGIN
 

SELECT @@ServerName AS server
,NAME AS dbname
,COUNT(STATUS) AS number_of_connections
,GETDATE() AS timestamp
FROM sys.databases sd
LEFT JOIN sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
GROUP BY NAME
END
GO
