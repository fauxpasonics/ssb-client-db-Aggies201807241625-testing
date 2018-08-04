SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[GetElementFieldsSQL] 
( 
	@ClientDB VARCHAR(50) 
	,@ElementType VARCHAR(50) 
	,@ElementIsCleanFieldFilter BIT
	,@tmpTblName VARCHAR(MAX) 
	,@finalSql NVARCHAR(MAX) OUTPUT 
) 
AS 
BEGIN 
DECLARE  
	@sql NVARCHAR(MAX) 
 
	/**** TESTING ****/ 
	----,@ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV' 
	----,@ElementType VARCHAR(50) = 'Standard' 
	----,@ElementIsCleanFieldFilter BIT = 1
	----,@tmpTblName VARCHAR(MAX) = '##elementFields_' + REPLACE(CAST(NEWID() AS VARCHAR(50)),'-','') 
	----,@finalSql NVARCHAR(MAX) 
 
	----SELECT @tmpTblName 
	/*************************************************************************************************/ 
	 
IF @ElementIsCleanFieldFilter IS NULL
	SET @ElementIsCleanFieldFilter = 0

SET @sql = ''  
	+ ' SELECT ROW_NUMBER() OVER (ORDER BY a.Element, a.FieldName) AS ID, DENSE_RANK() OVER (ORDER BY Element) AS ElementGroupID, a.ElementID, a.Element' + CHAR(13) 
	+ ' ,ROW_NUMBER() OVER (PARTITION BY Element ORDER BY FieldName) AS FieldID, REPLACE(LTRIM(RTRIM(FieldName)),''dimcust.'','''') AS FieldName' + CHAR(13) 
	+ ' INTO ' + @tmpTblName + CHAR(13) 
	+ ' FROM (' + CHAR(13)            
	+ ' 	SELECT DISTINCT' + CHAR(13)            
	+ ' 		A.ElementID, A.Element, Split.a.value(''.'', ''VARCHAR(100)'') AS FieldName' + CHAR(13)              
	+ ' 	FROM' + CHAR(13)              
	+ ' 	(' + CHAR(13)            
	+ ' 		SELECT ElementID, Element, CAST (''<M>'' + REPLACE(LTRIM(RTRIM(ElementFieldList)), '','', ''</M><M>'') + ''</M>'' AS XML) AS Data' + CHAR(13)   
	+ ' 		FROM mdm.Element' + CHAR(13) 
	+ ' 		WHERE 1=1' + CHAR(13) 
	+ ' 		AND ElementType = ''' + @ElementType + '''' + CHAR(13)   
	+ '			AND ISNULL(IsDeleted,0) = 0' + CHAR(13)
	+ CASE 
		WHEN @ElementIsCleanFieldFilter = 1 THEN '		AND ElementIsCleanField IS NOT NULL' + CHAR(13)      
		ELSE ''
	END   
	+ ' 	) AS A CROSS APPLY Data.nodes (''/M'') AS Split(a)' + CHAR(13)            
	+ ' ) a' + CHAR(13)            
	+ ' WHERE ISNULL(a.FieldName,'''') != ''''' + CHAR(13) 
	--+ ' AND ISNULL(a.FieldName,'''') NOT LIKE ''%IsClean%''' + CHAR(13)  
 
SET @finalSql = @sql 
----SELECT @finalSql 
RETURN 
END
GO
