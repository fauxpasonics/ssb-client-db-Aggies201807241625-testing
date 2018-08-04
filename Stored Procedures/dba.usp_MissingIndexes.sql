SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:        SSB
-- Create date:   06/15/2015
-- Description:   usp_MissingIndexes
--    adding include statments to indexes is not 
--    always the best solution           
-- =============================================
 
CREATE PROCEDURE  [dba].[usp_MissingIndexes] 
AS  SELECT TOP 30
ROUND(s.avg_total_user_cost *
       s.avg_user_impact
        * (s.user_seeks + s.user_scans),0) AS [Total Cost]
                                ,d.[statement] AS [Table Name]
                                ,equality_columns AS [Required Key Columns]
                                ,inequality_columns AS [Secondary Key Columns]
--                                ,included_columns
FROM sys.dm_db_missing_index_groups g
INNER JOIN sys.dm_db_missing_index_group_stats s
  ON s.group_handle = g.index_group_handle
INNER JOIN sys.dm_db_missing_index_details d
  ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC
GO
