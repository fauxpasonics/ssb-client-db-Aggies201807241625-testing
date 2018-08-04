SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        
-- Create date:   
-- Description:   Index Statistics have to be run
-- for each DB. Highlight everything below the 'AS'
-- and run under the databse to be examined
-- =============================================
CREATE PROCEDURE  [dba].[usp_IndexUnusedSpecificDB]
AS
SELECT
   @@SERVERNAME AS [ServerName]
    , DB_NAME() AS [DatabaseName]
    , SCHEMA_NAME([sObj].[schema_id]) AS [SchemaName]
    , [sObj].[name] AS [ObjectName]
    , CASE
       WHEN [sObj].[type] = 'U' THEN 'Table'
       WHEN [sObj].[type] = 'V' THEN 'View'
      END AS [ObjectType]
    , [sIdx].[index_id] AS [IndexID]
    , ISNULL([sIdx].[name], 'N/A') AS [IndexName]
    , CASE
       WHEN [sIdx].[type] = 0 THEN 'Heap'
       WHEN [sIdx].[type] = 1 THEN 'Clustered'
       WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
       WHEN [sIdx].[type] = 3 THEN 'XML'
       WHEN [sIdx].[type] = 4 THEN 'Spatial'
       WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
       WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
      END AS [IndexType]
 FROM
    [sys].[indexes] AS [sIdx]
    INNER JOIN [sys].[objects] AS [sObj]
       ON [sIdx].[object_id] = [sObj].[object_id]
 WHERE
    NOT EXISTS (
                SELECT *
                FROM [sys].[dm_db_index_usage_stats] AS [sdmfIUS]
                WHERE 
                  [sIdx].[object_id] = [sdmfIUS].[object_id]
                   AND [sIdx].[index_id] = [sdmfIUS].[index_id]
                   AND [sdmfIUS].[database_id] = DB_ID()
             )
    AND [sObj].[type] IN ('U','V')     -- Look in Tables & Views
    AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
    AND [sIdx].[is_disabled] = 0x0     -- Exclude Disabled Indexes
GO
