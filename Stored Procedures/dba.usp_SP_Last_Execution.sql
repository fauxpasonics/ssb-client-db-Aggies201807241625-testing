SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        
-- Create date:   
-- Description:   Last Execution of all SPs in a DB
--     *** Note SP Data is only available since the last 
--         time SQL was restarted. Change USE for the DB
--         being interaggated, or run just the "select"
--         portion of the script below.
-- =============================================
CREATE PROCEDURE [dba].[usp_SP_Last_Execution]
    
AS
BEGIN
SELECT sc.name as 'Schema', p.name as 'SP Name', st.last_execution_time, p.create_date, p.modify_date, st.object_id
FROM sys.procedures AS p
INNER JOIN sys.schemas AS sc
  ON p.[schema_id] = sc.[schema_id]
LEFT OUTER JOIN sys.dm_exec_procedure_stats AS st
ON p.[object_id] = st.[object_id]
--WHERE st.[object_id] IS NULL
ORDER BY sc.name, st.last_execution_time desc, p.name;
END
GO
