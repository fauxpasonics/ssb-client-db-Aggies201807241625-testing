SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:         
-- Create date:    
-- Description:   Generates Grant Statements for Roles
--                 
-- =============================================
CREATE PROCEDURE [dba].[usp_GeneratesGrantStmtsforRoles]
    
AS
BEGIN

-- 

SELECT 'GRANT ' + database_permissions.permission_name + ' ON ' + CASE database_permissions.class_desc
        WHEN 'SCHEMA'
            THEN '[' + schema_name(major_id) + ']'
        WHEN 'OBJECT_OR_COLUMN'
            THEN CASE 
                    WHEN minor_id = 0
                        THEN'['+OBJECT_SCHEMA_NAME(major_id) + '].' + '[' + object_name(major_id) + ']' COLLATE Latin1_General_CI_AS_KS_WS
                    ELSE (
                            SELECT object_name(object_id) + ' (' + NAME + ')'
                            FROM sys.columns
                            WHERE object_id = database_permissions.major_id
                                AND column_id = database_permissions.minor_id
                            )
                    END
        ELSE 'other'
        END + ' TO [' + database_principals.NAME + ']' COLLATE Latin1_General_CI_AS_KS_WS
FROM sys.database_permissions
JOIN sys.database_principals ON database_permissions.grantee_principal_id = database_principals.principal_id
LEFT JOIN sys.objects --left because it is possible that it is a schema
    ON objects.object_id = database_permissions.major_id
WHERE database_permissions.major_id > 0
    AND permission_name IN (
        'SELECT'
        ,'INSERT'
        ,'UPDATE'
        ,'DELETE'
        ,'EXECUTE'
        )
		END
GO
