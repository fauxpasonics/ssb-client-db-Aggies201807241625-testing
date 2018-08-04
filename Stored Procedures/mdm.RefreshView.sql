SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[RefreshView] (
	@ClientDB VARCHAR(50)
	,@viewName VARCHAR(150)
)
AS 
BEGIN 

SET NOCOUNT ON

--/**** TESTING ****/ DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV', @viewName VARCHAR(150) = 'mdm.vw_Overrides_ActiveOnly_PIVOT'

DECLARE 
	@sql NVARCHAR(MAX) = ''
	,@FieldList1 NVARCHAR(MAX) = ''
	,@FieldList2 NVARCHAR(MAX) = ''
	,@return_code INT = -1
	,@printMsg NVARCHAR(MAX) = ''
	,@errorMsg NVARCHAR(MAX) = ''
	,@guid VARCHAR(50) = REPLACE(CAST(NEWID() AS VARCHAR(50)),'-','')

IF (SELECT @@VERSION) LIKE '%Azure%'     
BEGIN     
SET @ClientDB = ''     
END     
     
SET @ClientDB = REPLACE(@ClientDB,'.','')  

SET @sql = ''
	+ 'IF ''' + @viewName + ''' NOT IN (''mdm.vw_Overrides_ActiveOnly_PIVOT'')' + CHAR(13)
	+ '		RAISERROR(''View ''''' + @viewName + ''''' is not supported.'',16,1)' + CHAR(13)

SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
EXEC @return_code = sp_executesql @sql

IF @return_code != 0
	RETURN
IF @viewName = 'mdm.vw_Overrides_ActiveOnly_PIVOT'
BEGIN
	IF OBJECT_ID('tempdb..#stdElement') IS NOT NULL
		DROP TABLE #stdElement

	CREATE TABLE #stdElement (ID INT, ElementGroupID INT, ElementID INT, Element VARCHAR(50), FieldID INT, FieldName VARCHAR(100))

	INSERT INTO #stdElement
	EXEC mdm.GetElementFields @ClientDB = @ClientDB,                   -- varchar(50)
									  @ElementType = 'Standard',                -- varchar(50)
									  @ElementIsCleanFieldFilter = 1 -- bit

	DELETE a
	--SELECT *
	FROM #stdElement a
	WHERE FieldName LIKE '%IsClean%'

	SELECT 
		@FieldList1 = CONCAT(@FieldList1, CASE WHEN ID != 1 THEN ',MAX(' ELSE 'MAX(' END,FieldName,') AS ',FieldName) + CHAR(13)
		,@FieldList2 = CONCAT(@FieldList2, CASE WHEN ID != 1 THEN ',' ELSE '' END,FieldName) + CHAR(13)
	FROM #stdElement

	--SELECT @FieldList

	SET @sql = ''
		+ ' IF OBJECT_ID(''' + @ClientDB + '.mdm.vw_Overrides_ActiveOnly_PIVOT'') IS NOT NULL' + CHAR(13)
		+ '		EXEC sp_rename ''mdm.vw_Overrides_ActiveOnly_PIVOT'', ''vw_Overrides_ActiveOnly_PIVOT_' + @guid + '''' + CHAR(13)
	
	SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
	EXEC sp_executesql @sql

	SET @sql = ''
		+ ' CREATE VIEW mdm.vw_Overrides_ActiveOnly_PIVOT' + CHAR(13)
		+ ' AS' + CHAR(13)
		+ ' SELECT DimCustomerID, SSID, SourceSystem,' + CHAR(13)
		+ @FieldList1
		+ ' FROM (SELECT * FROM mdm.Overrides WHERE StatusID = 1) p' + CHAR(13)
		+ ' PIVOT' + CHAR(13)
		+ ' (' + CHAR(13)
		+ '		MAX(Value)' + CHAR(13)
		+ '		FOR Field IN (' + @FieldList2 + ')' + CHAR(13)
		+ ' ) as pvt' + CHAR(13)
		+ ' GROUP BY DimCustomerID, SSID, SourceSystem' + CHAR(13)

	SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
	EXEC @return_code = sp_executesql @sql
	IF @return_code = 0
	BEGIN
		SET @sql = ''
			+ ' IF OBJECT_ID(''' + @ClientDB + '.mdm.vw_Overrides_ActiveOnly_PIVOT_' + @guid + ''') IS NOT NULL' + CHAR(13)
			+ '		DROP VIEW mdm.vw_Overrides_ActiveOnly_PIVOT_' + @guid + CHAR(13)

		SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
		EXEC @return_code = sp_executesql @sql
		
		SET @printMsg = 'View ''' + @viewName + ''' was successfully refreshed.' + CHAR(13)
		PRINT @printMsg
	END
    ELSE
	BEGIN
		SET @errorMsg = 'Failed to refresh view ''' + @viewName + '''.'
		RAISERROR (@errorMsg,16,1)
	END
END
ELSE 
BEGIN
	SET @errorMsg = 'Failed to refresh view ''' + @viewName + '''.'
	RAISERROR (@errorMsg,16,1)
END
END
GO
