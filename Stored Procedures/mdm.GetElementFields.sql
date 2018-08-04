SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[GetElementFields] 
( 
	@ClientDB VARCHAR(50) 
	,@ElementType VARCHAR(50) 
	,@ElementIsCleanFieldFilter BIT
) 
AS 
BEGIN 
DECLARE  
	@sql NVARCHAR(MAX) 
	,@finalSql NVARCHAR(MAX) 
	,@tmpTblName NVARCHAR(250) = '#elementFields_' + REPLACE(CAST(NEWID() AS VARCHAR(50)),'-','') 
 
	/***** TESTING *****/ 
	--, @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV' 
	--, @ElementType VARCHAR(50) = 'Standard' 
 
	SET @ClientDB = REPLACE(@ClientDB,'.','') 
 
	EXEC mdm.GetElementFieldsSql @ClientDB = @ClientDB, @ElementType = @ElementType, @ElementIsCleanFieldFilter = @ElementIsCleanFieldFilter, @tmpTblName = @tmpTblName, @finalSql = @sql OUTPUT 
	 
	SET @sql = @sql + CHAR(13) + 'SELECT * FROM ' + @tmpTblName 
 
	SET @finalSql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + ''''; 
	EXEC sp_executesql @finalSql 
END
GO
