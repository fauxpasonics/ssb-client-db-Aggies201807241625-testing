SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[GetOverrideSourceValues]
(
	@ClientDB VARCHAR(50)
	,@tmpOverridesTblName NVARCHAR(250)
	,@getCompositeValues BIT = 1
)
AS
BEGIN
DECLARE 
	@sql NVARCHAR(MAX)
	,@finalSql NVARCHAR(MAX)
	,@tmpElementTblName NVARCHAR(250) = '##stdElementFields_' + REPLACE(CAST(NEWID() AS VARCHAR(50)),'-','')

	/**** TESTING ****/
	--,@ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV'
	--,@tmpOverridesTblName NVARCHAR(250) = '##overrides_0055424CBEBB404B87CBBCF93C23F177'

	IF OBJECT_ID('tempdb..#stdElementFields') IS NOT NULL
		DROP TABLE #stdElementFields

	CREATE TABLE #stdElementFields (ID INT, ELementGroupID INT, ElementID INT, Element VARCHAR(50), FieldID INT, FieldName VARCHAR(50))

	EXEC mdm.GetElementFieldsSql @ClientDB = @ClientDB, @ElementType = 'Standard', @ElementIsCleanFieldFilter = 1, @tmpTblName = @tmpElementTblName, @finalSql = @sql OUTPUT
	
	SET @sql = @sql + CHAR(13) + 'INSERT INTO #stdELementFields SELECT * FROM ' + @tmpElementTblName + ' WHERE FieldName NOT LIKE ''%IsCleanStatus%'''

	SET @finalSql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
	--SELECT @finalSql
	
	EXEC sp_executesql @finalSql

	--SELECT * FROM #stdElementFields 

	-- Get DimCustomer values
	SET @sql = ''
		+ ' SELECT a.*' + CHAR(13)
		+ ' INTO #dimCustomer'
		--+ ' INTO #overrides_source' + CHAR(13)
		+ ' FROM (' + CHAR(13)
		+ ' 	SELECT DISTINCT a.OverrideID' + CHAR(13)
		+ '			, a.DimCustomerID' + CHAR(13)
		+ '			, a.SourceSystem' + CHAR(13)
		+ '			, a.SSID' + CHAR(13)
		+ '			, a.StatusID' + CHAR(13)
		+ '			, a.ElementID' + CHAR(13)

	SELECT @sql = @sql + '		, CAST(b.' + FieldName + ' AS NVARCHAR(MAX)) AS ' + FieldName + CHAR(13)
	FROM #stdElementFields

	SET @sql = @sql
		+ '		FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)
		+ ' ) z' + CHAR(13)
		+ ' UNPIVOT (' + CHAR(13)
		+ '		dimcust_value FOR Field IN (' + CHAR(13)

	SELECT @sql = @sql + CASE WHEN ID != 1 THEN '		, ' ELSE '		' END + FieldName + CHAR(13)
	FROM #stdElementFields

	SET @sql = @sql
		+ '		)' + CHAR(13)
		+ ' ) AS a' + CHAR(13) 
		+ ' INNER JOIN ' + @tmpOverridesTblName + ' b ON ISNULL(a.OverrideID,0) = ISNULL(b.OverrideID,0)' + CHAR(13)
		+ '		AND a.DimCustomerID = b.DimCustomerID' + CHAR(13)
		+ '		AND a.ElementID = b.ElementID' + CHAR(13)
		+ '		AND a.Field = b.Field' + CHAR(13) + CHAR(13)

	-- Get compositerecord values
	IF @getCompositeValues = 1
	BEGIN
		SET @sql = @sql
			+ ' SELECT a.*' + CHAR(13)
			+ ' INTO #compositerecord'
			+ ' FROM (' + CHAR(13)
			+ ' 	SELECT DISTINCT a.OverrideID' + CHAR(13)
			+ '			, a.DimCustomerID' + CHAR(13)
			+ '			, a.SourceSystem' + CHAR(13)
			+ '			, a.SSID' + CHAR(13)
			+ '			, a.StatusID' + CHAR(13)
			+ '			, a.ElementID' + CHAR(13)

		SELECT @sql = @sql + '		, CAST(c.' + FieldName + ' AS NVARCHAR(MAX)) AS ' + FieldName + CHAR(13)
		FROM #stdElementFields

		SET @sql = @sql
			+ '		FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)
			+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK)  ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)
			+ '		INNER JOIN mdm.compositerecord c WITH (NOLOCK)  ON b.DimCustomerID = c.DimCustomerID' + CHAR(13)
			+ ' ) z' + CHAR(13)
			+ ' UNPIVOT (' + CHAR(13)
			+ '		composite_value FOR Field IN (' + CHAR(13)

		SELECT @sql = @sql + CASE WHEN ID != 1 THEN '		, ' ELSE '		' END + FieldName + CHAR(13)
		FROM #stdElementFields

		SET @sql = @sql
			+ '		)' + CHAR(13)
			+ ' ) AS a' + CHAR(13) 
			+ ' INNER JOIN ' + @tmpOverridesTblName + ' b ON ISNULL(a.OverrideID,0) = ISNULL(b.OverrideID,0)' + CHAR(13)
			+ '		AND a.DimCustomerID = b.DimCustomerID' + CHAR(13)
			+ '		AND a.ElementID = b.ElementID' + CHAR(13)
			+ '		AND a.Field = b.Field' + CHAR(13) + CHAR(13)
	END

	-- Get Source_DimCustomer values
	SET @sql = @sql
		+ ' SELECT a.*' + CHAR(13)
		+ ' INTO #sourceDimCustomer'
		+ ' FROM (' + CHAR(13)
		+ ' 	SELECT DISTINCT a.OverrideID' + CHAR(13)
		+ '			, a.DimCustomerID' + CHAR(13)
		+ '			, a.SourceSystem' + CHAR(13)
		+ '			, a.SSID' + CHAR(13)
		+ '			, a.StatusID' + CHAR(13)
		+ '			, a.ElementID' + CHAR(13)

	SELECT @sql = @sql + '		, CAST(c.' + FieldName + ' AS NVARCHAR(MAX)) AS ' + FieldName + CHAR(13)
	FROM #stdElementFields

	SET @sql = @sql
		+ '		FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK)  ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)
		+ '		INNER JOIN dbo.vw_Source_DimCustomer c WITH (NOLOCK)  ON b.SSID = c.SSID' + CHAR(13)
		+ '			AND b.SourceSystem = c.SourceSystem' + CHAR(13)
		+ ' ) z' + CHAR(13)
		+ ' UNPIVOT (' + CHAR(13)
		+ '		source_value FOR Field IN (' + CHAR(13)

	SELECT @sql = @sql + CASE WHEN ID != 1 THEN '		, ' ELSE '		' END + FieldName + CHAR(13)
	FROM #stdElementFields

	SET @sql = @sql
		+ '		)' + CHAR(13)
		+ ' ) AS a' + CHAR(13) 
		+ ' INNER JOIN ' + @tmpOverridesTblName + ' b ON ISNULL(a.OverrideID,0) = ISNULL(b.OverrideID,0)' + CHAR(13)
		+ '		AND a.DimCustomerID = b.DimCustomerID' + CHAR(13)
		+ '		AND a.ElementID = b.ElementID' + CHAR(13)
		+ '		AND a.Field = b.Field' + CHAR(13) + CHAR(13)

		+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, a.StatusID, a.ElementID, a.Field, a.dimcust_value, ' 
		+ CASE WHEN @getCompositeValues = 0 THEN 'CAST(NULL AS VARCHAR(MAX)) AS compositevalue' ELSE 'b.composite_value' END + ', c.source_value' + CHAR(13)
		+ ' FROM #dimCustomer a' + CHAR(13)
		+ CASE 
			WHEN @getCompositeValues = 1 THEN
				+ ' LEFT JOIN #compositerecord b ON ISNULL(a.OverrideID,0) = ISNULL(b.OverrideID,0)' + CHAR(13)
				+ '		AND a.DimCustomerID = b.DimCustomerID' + CHAR(13)
				+ '		AND a.ElementID = b.ElementID' + CHAR(13)
				+ '		AND a.Field = b.Field' + CHAR(13)
			ELSE '' 
		  END
		+ ' LEFT JOIN #sourceDimCustomer c ON ISNULL(a.OverrideID,0) = ISNULL(c.OverrideID,0)' + CHAR(13)
		+ '		AND a.DimCustomerID = c.DimCustomerID' + CHAR(13)
		+ '		AND a.ElementID = c.ElementID' + CHAR(13)
		+ '		AND a.Field = c.Field' + CHAR(13) + CHAR(13)

	SET @finalSql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';

	----SELECT @finalSql
	EXEC sp_executesql @finalSql
END
GO
