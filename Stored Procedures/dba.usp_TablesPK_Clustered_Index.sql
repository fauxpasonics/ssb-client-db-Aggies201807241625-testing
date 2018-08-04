SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:   
-- Description:   DB Tables Primary Key and Clustered 
-- Indexes
-- =============================================
CREATE PROCEDURE [dba].[usp_TablesPK_Clustered_Index]
     
AS
BEGIN
 

DECLARE @dbid INT
SELECT @dbid = DB_ID(DB_NAME())

SELECT	Databases.Name AS [Database],
	Objects.NAME AS [Table],
	Indexes.NAME AS [Index],
	Indexes.type_desc, 
	Indexes.is_primary_key
	
FROM SYS.INDEXES Indexes
	INNER JOIN SYS.OBJECTS Objects ON Indexes.OBJECT_ID = Objects.OBJECT_ID
	LEFT JOIN sys.dm_db_index_physical_stats(@dbid, null, null, null, null) PhysicalStats
		ON PhysicalStats.object_id = Indexes.object_id 
                     AND PhysicalStats.index_id = indexes.index_id
	INNER JOIN sys.databases Databases
		ON Databases.database_id = PhysicalStats.database_id
WHERE Objects.type = 'U' -- Is User Table
 AND (Indexes.is_primary_key = 1 OR indexes.type = '1')

ORDER BY --PhysicalStats.page_count DESC,
	Objects.NAME,
        Indexes.INDEX_ID,
        Indexes.NAME ASC

END
GO
