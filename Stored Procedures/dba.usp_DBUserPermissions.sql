SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:       
-- Create date: 
-- Description:  Get objects permission of specified  
-- user databases. Change Use statement to needed DB 
-- or run from specific Database
-- =============================================
CREATE PROCEDURE [dba].[usp_DBUserPermissions]
    
AS
BEGIN

DECLARE @Obj VARCHAR(4000)
DECLARE @T_Obj TABLE (UserName SYSNAME, ObjectName SYSNAME, Permission NVARCHAR(128))
SET @Obj='
SELECT Us.name AS username, Obj.name AS object,  dp.permission_name AS permission 
FROM sys.database_permissions dp
JOIN sys.sysusers Us 
ON dp.grantee_principal_id = Us.uid 
JOIN sys.sysobjects Obj
ON dp.major_id = Obj.id '
INSERT @T_Obj 
--EXEC sp_MSforeachdb @Obj
SELECT * FROM @T_Obj 
Order by UserName
END

/****** Object:  StoredProcedure [dba].[usp_Fragmentation]    Script Date: 10/5/2015 5:02:28 PM ******/
SET ANSI_NULLS ON
GO
