SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:        SSB
-- Create date:   06/15/2015
-- Description:   TempDB currently in Use
--Actual TempDB space in use:            
-- =============================================
CREATE PROCEDURE [dba].[usp_TempDBInUse]
    
AS
BEGIN
 
 
SELECT name AS FileName,
    size*1.0/128 AS FileSizeinMB,
    CASE max_size
        WHEN 0
                                                THEN 'Autogrowth is off.'
        WHEN -1
                                                THEN 'Autogrowth is on.'
        ELSE 'Log file will grow to a maximum size of 2 TB.'
    END,
    growth AS 'GrowthValue',
    'GrowthIncrement' =
        CASE
            WHEN growth = 0
                                                                THEN 'Size is fixed and will not grow.'
            WHEN growth > 0 AND is_percent_growth = 0
                THEN 'Growth value is in 8-KB pages.'
            ELSE 'Growth value is a percentage.'
        END
FROM tempdb.sys.database_files;
 
END
GO
