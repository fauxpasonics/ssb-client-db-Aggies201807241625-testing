SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:        
-- Create date:    
-- Description:   Defragmentation Script
--                Rule of Thumb: for Large DB’s
--                Rebuild Indexes over 30% Defrag
-- =============================================
CREATE PROCEDURE [dba].[usp_Fragmentation]
    
AS

BEGIN
SELECT dbschemas.[name] as 'Schema', 
dbtables.[name] as 'Table', 
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(N'AGGIES'), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID(N'AGGIES')
ORDER BY dbschemas.[name], indexstats.avg_fragmentation_in_percent desc
END
GO
