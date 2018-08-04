SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:   6/8/2015
-- Description:  
-- =============================================
CREATE PROCEDURE [dba].[usp_SPUsingMostCPU]
    
AS
BEGIN
SELECT DB_NAME(st.dbid) DBName
      ,OBJECT_SCHEMA_NAME(st.objectid,dbid) SchemaName
      ,OBJECT_NAME(st.objectid,dbid) StoredProcedure
      ,max(cp.usecounts) Execution_count
      ,sum(qs.total_worker_time) total_cpu_time
      ,sum(qs.total_worker_time) / (max(cp.usecounts) * 1.0)  avg_cpu_time
 FROM sys.dm_exec_cached_plans cp join sys.dm_exec_query_stats qs on cp.plan_handle = qs.plan_handle
      CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
where DB_NAME(st.dbid) is not null and cp.objtype = 'proc' and DB_NAME(st.dbid) <> 'DBA'
group by DB_NAME(st.dbid),OBJECT_SCHEMA_NAME(objectid,st.dbid), OBJECT_NAME(objectid,st.dbid)
 order by sum(qs.total_worker_time) desc
 
END
GO
