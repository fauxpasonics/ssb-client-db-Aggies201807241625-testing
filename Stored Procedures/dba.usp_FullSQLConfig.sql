SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
-- =============================================
-- Author:         
-- Create date:    
-- Description:   Display full SQL configuration
-- settings
-- =============================================
CREATE PROCEDURE [dba].[usp_FullSQLConfig]
    
AS
BEGIN
 
SELECT  *
FROM    sys.configurations
ORDER BY name ;
 
 
END
GO
