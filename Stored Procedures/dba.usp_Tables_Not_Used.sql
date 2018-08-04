SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        Internet - with customized updates
-- Description:   List tables not used within a DB
-- **** Note - Change the DB Name in the USE statement
--    or run just the "select" portion of this script  
--    from the Source DB.
-- =============================================
CREATE PROCEDURE [dba].[usp_Tables_Not_Used]
    
AS
BEGIN
SELECT DISTINCT OBJECTNAME = OBJECT_NAME(I.OBJECT_ID), o.create_date AS 'Create_Date', o.modify_date AS 'Modify_Date', I.OBJECT_ID
FROM SYS.INDEXES AS I
INNER JOIN SYS.OBJECTS AS O
ON I.OBJECT_ID = O.OBJECT_ID
WHERE OBJECTPROPERTY(O.OBJECT_ID,'IsUserTable') = 1
AND I.OBJECT_ID
NOT IN (SELECT DISTINCT I.OBJECT_ID
FROM SYS.DM_DB_INDEX_USAGE_STATS AS S ,SYS.INDEXES AS I
WHERE S.OBJECT_ID = I.OBJECT_ID
AND I.INDEX_ID = S.INDEX_ID
AND DATABASE_ID = DB_ID(db_name()))
ORDER BY OBJECTNAME
END

/*
SELECT 
t.name
,i.*
from
sys.dm_db_index_usage_stats i JOIN
sys.tables t ON (t.object_id = i.object_id)
where
database_id = db_id()

SELECT @@ServerName AS server
,NAME AS dbname
,COUNT(STATUS) AS number_of_connections
,GETDATE() AS timestamp
FROM sys.databases sd
LEFT JOIN sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
GROUP BY NAME
 

select [name] from sys.databases
where database_id > 4
AND [name] NOT IN
(select DB_NAME(database_id)
from sys.dm_db_index_usage_stats
where coalesce(last_user_seek, last_user_scan, last_user_lookup,'1/1/1970') >
(select login_time from sysprocesses where spid = 1))
*/
GO
