SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:       
-- Create date: 
-- Description:  Identify DB's last login and last index usage
-- to determine if DB's are still used.
-- =============================================
CREATE PROCEDURE [dba].[usp_DBStillUsedIndexLogin]
    
AS
BEGIN
 

--Is Db still in use?
select name, database_id, create_date,compatibility_level, recovery_model_desc from sys.databases
where database_id > 4
AND [name] NOT IN
(select DB_NAME(database_id)
from sys.dm_db_index_usage_stats 
where coalesce(last_user_seek, last_user_scan, last_user_lookup,'1/1/1970') >
(select login_time from sysprocesses where spid = 1))
 END
GO
