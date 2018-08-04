SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:   6/8/2015
-- Description:   SP's executed most often
-- =============================================
CREATE PROCEDURE [dba].[usp_SPExecMostOften]
    
AS
BEGIN
 
SELECT DB_NAME(st.dbid) DBName
      ,OBJECT_SCHEMA_NAME(st.objectid,dbid) SchemaName
      ,OBJECT_NAME(st.objectid,dbid) StoredProcedure
      ,max(cp.usecounts) Execution_count
FROM sys.dm_exec_cached_plans cp
         CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
where DB_NAME(st.dbid) is not null and cp.objtype = 'proc' and DB_NAME(st.dbid) <> 'DBA'
   group by cp.plan_handle, DB_NAME(st.dbid),
            OBJECT_SCHEMA_NAME(objectid,st.dbid),
   OBJECT_NAME(objectid,st.dbid)
 order by max(cp.usecounts) desc
 
END
GO
