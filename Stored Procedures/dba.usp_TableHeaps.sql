SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:        
-- Create date:   
-- Description:   HEAPS - Tables without Indexes
-- =============================================
CREATE PROCEDURE [dba].[usp_TableHeaps]
     
AS
BEGIN
 

-- GET UNUSED INDEXES
-- Index = "NULL" are tables without PK or index
DECLARE @dbid INT
SELECT @dbid = DB_ID(DB_NAME())

SELECT	Distinct Databases.Name AS [Database],
    Objects.Schema_id AS [Schema ID],
	Objects.NAME AS [Table],
	Indexes.NAME AS [Index],
	Indexes.type_desc 
	
FROM SYS.INDEXES Indexes
	INNER JOIN SYS.OBJECTS Objects ON Indexes.OBJECT_ID = Objects.OBJECT_ID
	LEFT JOIN sys.dm_db_index_physical_stats(@dbid, null, null, null, null) PhysicalStats
		ON PhysicalStats.object_id = Indexes.object_id 
                     AND PhysicalStats.index_id = indexes.index_id
	INNER JOIN sys.databases Databases
		ON Databases.database_id = PhysicalStats.database_id
WHERE Objects.type = 'U' -- Is User Table
AND (Indexes.name is NULL) 

ORDER BY 
	Databases.Name,
	Objects.Schema_id, 
	Objects.NAME,
	Indexes.NAME,
	Indexes.type_desc ASC
END
GO
