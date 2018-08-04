SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:   6/8/2015
-- Description:   SP with Longest Execution Time
-- =============================================
CREATE PROCEDURE [dba].[usp_SPLongestExecTime]
    
AS
BEGIN
 
SELECT DB_NAME(st.dbid) DBName
      ,OBJECT_SCHEMA_NAME(objectid,st.dbid) SchemaName
      ,OBJECT_NAME(objectid,st.dbid) StoredProcedure
      ,max(cp.usecounts) execution_count
      ,sum(qs.total_elapsed_time) total_elapsed_time
      ,sum(qs.total_elapsed_time) / max(cp.usecounts) avg_elapsed_time
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle
  where DB_NAME(st.dbid) is not null and cp.objtype = 'proc' and DB_NAME(st.dbid) <> 'DBA'
group by DB_NAME(st.dbid),OBJECT_SCHEMA_NAME(objectid,st.dbid), OBJECT_NAME(objectid,st.dbid)
 order by (avg_elapsed_time) desc
 
END
GO
