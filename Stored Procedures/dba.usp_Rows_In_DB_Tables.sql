SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:         
-- Create date:    
-- Description:   Number of Rows in a DB table
-- =============================================
CREATE PROCEDURE [dba].[usp_Rows_In_DB_Tables]
     
AS
BEGIN
CREATE TABLE #TableSizes
(TableName NVARCHAR(255),
 TableRows INT,
 ReservedSpaceKB VARCHAR(20),
 DataSpaceKB VARCHAR(20),
 IndexSizeKB VARCHAR(20),
 UnusedSpaceKB VARCHAR(20))
INSERT INTO #TableSizes
--EXEC sp_msforeachtable 'sp_spaceused ''?'''
SELECT * FROM #TableSizes
ORDER BY TableRows DESC
END
GO
