SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[LoadDimCustomer_GenerateMerge]
(
	@ClientDB VARCHAR(50)
	, @LoadView VARCHAR(100)
	, @LoadGuid VARCHAR(50)
	, @LogLevel INT
	, @baseColumns_sql NVARCHAR(MAX)
	, @targetColumns_sql NVARCHAR(MAX)
	, @groupID_sql NVARCHAR(MAX)
	, @groupDesc_sql NVARCHAR(MAX)
	, @getOutput_sql NVARCHAR(MAX)
	, @matchCondition_sql NVARCHAR(MAX)

	, @sql NVARCHAR(MAX) OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON
		
	DECLARE
		@mdm_process VARCHAR(50) = 'Load DimCustomer'
		, @columnName NVARCHAR(150)
		, @ordinalPosition INT
		, @dataType NVARCHAR(150)
		, @maxLen INT
		, @precision INT
		, @scale INT
		, @getOutput BIT
		, @mergeCondition BIT
		, @matchCondition BIT
		, @groupID INT
		, @groupDesc NVARCHAR(100)
		, @groupCount INT
		, @i INT = 1

		, @dynamicSQL NVARCHAR(MAX) = '' 
		, @output_createTblSql NVARCHAR(MAX) = ''
		, @merge_sql NVARCHAR(MAX) = ''
		, @merge_updateSQL NVARCHAR(MAX) = ''
		, @merge_outputSQL NVARCHAR(MAX) = ''
		, @audit_sql NVARCHAR(MAX) = ''
		, @auditDetail_insertOldSQL NVARCHAR(MAX) = ''
		, @auditDetail_insertNewSQL NVARCHAR(MAX) = ''

		, @output_createTblSql2 NVARCHAR(MAX) = ''
		, @merge_sql2 NVARCHAR(MAX) = ''
		, @merge_updateSQL2 NVARCHAR(MAX) = ''
		, @merge_outputSQL2 NVARCHAR(MAX) = ''
		, @audit_sql2 NVARCHAR(MAX) = ''
		, @auditDetail_insertOldSQL2 NVARCHAR(MAX) = ''
		, @auditDetail_insertNewSQL2 NVARCHAR(MAX) = ''

	CREATE TABLE #targetColumns (
		ColumnName NVARCHAR(150),
		OrdinalPosition INT,
		DataType NVARCHAR(150),
		CHARACTER_MAXIMUM_LENGTH INT,
		NUMERIC_PRECISION INT,
		NUMERIC_SCALE INT,
		GetOutput BIT,
		GroupID INT,
		GroupDesc NVARCHAR(100),
		MergeCondition BIT,
		MatchCondition BIT
	)

	SET @sql = ''

	-- Get base columns
	SET @dynamicSQL = @dynamicSQL
		+ 'INSERT INTO #targetColumns' + CHAR(13)
		+ 'SELECT COLUMN_NAME AS ColumnName, ORDINAL_POSITION AS OrdinalPosition, DATA_TYPE AS DataType, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE' + CHAR(13)
		+ '	, 0 AS GetOutput' + CHAR(13)
		+ '	, 0 AS GroupID' + CHAR(13)
		+ '	, NULL AS GroupDesc' + CHAR(13)
		+ '	, 0 MergeCondition' + CHAR(13)
		+ '	, 0 AS MatchCondition' + CHAR(13)
		+ 'FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS' + CHAR(13)
		+ 'WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''dbo.DimCustomer''' + CHAR(13)
		+ 'AND COLUMN_NAME IN (' + @baseColumns_sql + ')' + CHAR(13)
		+ 'ORDER BY ORDINAL_POSITION' + CHAR(13)
	SET @dynamicSQL = @dynamicSQL + CHAR(13)

	-- Get target columns
	SET @dynamicSQL = @dynamicSQL + 
	+ 'INSERT INTO #targetColumns' + CHAR(13)
	+ 'SELECT COLUMN_NAME AS ColumnName, ORDINAL_POSITION AS OrdinalPosition, DATA_TYPE AS DataType, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE' + CHAR(13)
	+ '	, ' + @getOutput_sql + ' AS GetOutput' + CHAR(13)
	+ '	, ' + @groupID_sql + ' AS GroupID' + CHAR(13)
	+ '	, ' + @groupDesc_sql + ' AS GroupDesc' + CHAR(13)
	+ '	, 0 AS MergeCondition' + CHAR(13)
	+ '	, ' + @matchCondition_sql + ' AS MatchCondition' + CHAR(13)
	+ 'FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS' + CHAR(13)
	+ 'WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''dbo.DimCustomer''' + CHAR(13)
	+ 'AND COLUMN_NAME IN (' + @targetColumns_sql + ')' + CHAR(13)
	+ 'ORDER BY ORDINAL_POSITION' + CHAR(13)
	+ '' + CHAR(13)

	+ 'DELETE a' + CHAR(13)
	+ 'FROM #targetColumns a' + CHAR(13)
	+ 'LEFT JOIN (' + CHAR(13)
	+ '	SELECT COLUMN_NAME' + CHAR(13)
	+ '	FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS' + CHAR(13)
	+ '	WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''' + @LoadView + '''' + CHAR(13)
	+ ') b ON a.ColumnName = b.COLUMN_NAME' + CHAR(13)
	+ 'WHERE 1=1' + CHAR(13)
	+ 'AND b.COLUMN_NAME IS NULL' + CHAR(13)

	----SELECT @dynamicSQL
	EXEC sp_executesql @dynamicSQL

	---- Get ALL DimCustomer columns & position
	--CREATE TABLE #dimcust_cols (COLUMN_NAME sysname, ORDINAL_POSITION INT)
	
	--SET @dynamicSQL = 
	--	+ 'INSERT INTO #dimcust_cols' + CHAR(13)
	--	+ 'SELECT a.COLUMN_NAME, a.ORDINAL_POSITION' + CHAR(13)
	--	+ 'FROM MDM_CLIENT_DEV.INFORMATION_SCHEMA.COLUMNS a' + CHAR(13)
	--	+ 'WHERE a.TABLE_SCHEMA + ''.'' + a.TABLE_NAME = ''dbo.DimCustomer''' + CHAR(13)

	SELECT @groupCount = MAX(GroupID)
	FROM #targetColumns

	-- Generate merge statement(s)
	WHILE @i <= @groupCount
	BEGIN 
		DECLARE col_cursor CURSOR FOR
		SELECT ColumnName, OrdinalPosition, DataType, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE, GetOutput, GroupID, GroupDesc, MergeCondition, MatchCondition
		FROM #targetColumns
		WHERE (GroupID = @i
			OR GroupID = 0)
		ORDER BY GroupID, OrdinalPosition

		OPEN col_cursor

		FETCH NEXT FROM col_cursor
		INTO @columnName, @ordinalPosition, @dataType, @maxLen, @precision, @scale, @getOutput, @groupID, @groupDesc, @mergeCondition, @matchCondition

		SET @merge_sql = 'MERGE ' + @ClientDB + 'dbo.DimCustomer AS myTarget' + CHAR(13)
			+ 'USING (select * from ' + @ClientDB + '' + @LoadView + ' WHERE RecordRank = 1) as mySource' + CHAR(13)
			+ '    ON' + CHAR(13)
			--+ '	myTarget.SourceDB = mySource.SourceDB' + CHAR(13)
			+ '	myTarget.SourceSystem = mySource.SourceSystem' + CHAR(13)
			+ '	and myTarget.SSID = mySource.SSID' + CHAR(13)

		SET @merge_updateSQL = CHAR(13) + 'WHEN MATCHED' + CHAR(13) + 'THEN UPDATE SET' + CHAR(13) + 'myTarget.UpdatedBy = ''CI''' + CHAR(13)
				+', myTarget.UpdatedDate = CURRENT_TIMESTAMP' + CHAR(13)

		SET @audit_sql = ''
		
		IF @LogLevel > 0
		BEGIN
			SET @output_createTblSql = 'CREATE TABLE #output_' + CAST(@i AS NVARCHAR(2)) + ' (' + CHAR(13)
				+ 'ChangeType NVARCHAR(50)' + CHAR(13)
				--+ ',SourceDB NVARCHAR(MAX)' + CHAR(13)
				+ ',SourceSystem NVARCHAR(MAX)' + CHAR(13)
				+ ',SSID NVARCHAR(MAX)' + CHAR(13)
				+ ',DateTimeChanged DATETIME DEFAULT GETDATE()' + CHAR(13)
			
			IF @LogLevel > 1
			BEGIN
				SET @merge_outputSQL = 'OUTPUT ''' + ISNULL(@groupDesc,'') + ' Updated'' AS ChangeType, /*mySource.SourceDB,*/ mySource.SourceSystem, mySource.SSID, CURRENT_TIMESTAMP AS DateTimeChanged'
	
				SET @auditDetail_insertOldSQL = ' dbo.fnStripLowAscii(Replace((SELECT SSID, SourceSystem/*, SourceDB*/ '
				SET @auditDetail_insertNewSQL = ' dbo.fnStripLowAscii(Replace((SELECT SSID, SourceSystem/*, SourceDB*/ '
			END
			ELSE
				SET @merge_outputSQL = 'OUTPUT ''' + ISNULL(@groupDesc,'') + ' Incoming Record'' AS ChangeType, /*mySource.SourceDB,*/ mySource.SourceSystem, mySource.SSID, CURRENT_TIMESTAMP AS DateTimeChanged'
		END

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @output_createTblSql2 = ''
			SET @merge_sql2 = ''
			SET @merge_updateSQL2 = ''
			SET @merge_outputSQL2 = ''
			SET @audit_sql2 = ''
			SET @auditDetail_insertOldSQL2 = ''
			SET @auditDetail_insertNewSQL2 = ''	

			SET @dynamicSQL = 
				'IF EXISTS (SELECT * FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''' + @LoadView + ''' AND COLUMN_NAME = ''' +  @columnName + ''')' + CHAR(13)
				+ 'BEGIN' + CHAR(13)
				+ '	SELECT @merge_sql2 = ' + CASE WHEN @matchCondition = 1 THEN ''' AND ISNULL(CAST(mySource.' + @columnName + ' AS NVARCHAR(MAX)),''''NULL'''') <> ISNULL(CAST(myTarget.' + @columnName + ' AS NVARCHAR(MAX)), ''''NULL'''')''' ELSE '''''' END + CHAR(13)		
				+ '	SELECT @merge_updateSQL2 = '', myTarget.' + @columnName + ' = CAST(mySource.' + @columnName + ' AS ' + UPPER(@dataType) + CASE WHEN ISNULL(@maxLen,0) != 0 THEN '(' + CASE WHEN @maxLen = -1 THEN 'MAX)' ELSE CAST(@maxLen AS VARCHAR(10)) + ')' END WHEN ISNULL(@precision,0) != 0 AND @dataType NOT IN ('int','bigint') THEN '(' + CAST(@precision AS VARCHAR(10)) + ',' + CAST(@scale AS VARCHAR(10)) + ')' ELSE '' END + ')'' + CHAR(13)' + CHAR(13)
				+ CHAR(13)

				+ 'IF ' + CAST(@LogLevel AS VARCHAR(1)) + ' > 1' + CHAR(13)
				+ 'BEGIN' + CHAR(13)
				+ '	SELECT @merge_outputSQL2 = ' + CASE WHEN @getOutput = 1 THEN ''', Deleted.' + @columnName + ' AS ' + @columnName + '_old''' ELSE '''''' END + CHAR(13)
				+ '	SELECT @merge_outputSQL2 = @merge_outputSQL2 + ' + CASE WHEN @getOutput = 1 THEN ''', Inserted.' + @columnName + ' AS ' + @columnName + '_new''' ELSE '''''' END + CHAR(13)
				+ '' + CHAR(13)
				+ '	SELECT @output_createTblSql2 = ' + CASE WHEN @getOutput = 1 THEN + ''',' + @columnName + '_old NVARCHAR(MAX)'' + CHAR(13)' ELSE '''''' END + CHAR(13)
				+ '	SELECT @output_createTblSql2 = @output_createTblSql2 + ' + CASE WHEN @getOutput = 1 THEN + ''',' + @columnName + '_new NVARCHAR(MAX)'' + CHAR(13)' ELSE '''''' END + CHAR(13)
				+ '' + CHAR(13)
				+ '	SELECT @auditDetail_insertOldSQL2 = ' + CASE WHEN @getOutput = 1 THEN + ''',' + @columnName + '_old''' ELSE '''''' END + CHAR(13)
				+ '	SELECT @auditDetail_insertNewSQL2 = ' + CASE WHEN @getOutput = 1 THEN + ''',' + @columnName + '_new''' ELSE '''''' END + CHAR(13)
				+ '	END' + CHAR(13)
				+ 'END' + CHAR(13)

			EXEC sp_executesql @dynamicSQL, N'@merge_sql2 VARCHAR(MAX) OUTPUT, @merge_updateSQL2 VARCHAR(MAX) OUTPUT, @merge_outputSQL2 VARCHAR(MAX) OUTPUT, @output_createTblSql2 VARCHAR(MAX) OUTPUT, @auditDetail_insertOldSQL2 VARCHAR(MAX) OUTPUT, @auditDetail_insertNewSQL2 VARCHAR(MAX) OUTPUT'
				, @merge_sql2 OUTPUT, @merge_updateSQL2 OUTPUT, @merge_outputSQL2 OUTPUT, @output_createTblSql2 OUTPUT, @auditDetail_insertOldSQL2 OUTPUT, @auditDetail_insertNewSQL2 OUTPUT

			SELECT @merge_sql = @merge_sql + @merge_sql2
			SELECT @merge_updateSQL = @merge_updateSQL + @merge_updateSQL2
			SELECT @merge_outputSQL = @merge_outputSQL + @merge_outputSQL2
			SELECT @output_createTblSql = @output_createTblSql + @output_createTblSql2
			SELECT @auditDetail_insertOldSQL = @auditDetail_insertOldSQL + @auditDetail_insertOldSQL2
			SELECT @auditDetail_insertNewSQL = @auditDetail_insertNewSQL + @auditDetail_insertNewSQL2

			FETCH NEXT FROM col_cursor
			INTO @columnName, @ordinalPosition, @dataType, @maxLen, @precision, @scale, @getOutput, @groupID, @groupDesc, @mergeCondition, @matchCondition
		END

		CLOSE col_cursor
		DEALLOCATE col_cursor

		IF @LogLevel > 0
		BEGIN
			SET @output_createTblSql = @output_createTblSql + ');' + CHAR(13)
			SET @merge_outputSQL = @merge_outputSQL + CHAR(13) + 'INTO #output_' + CAST(@i AS NVARCHAR(2)) + ';' + CHAR(13)

			IF @LogLevel > 1
			BEGIN
				SET @auditDetail_insertOldSQL = @auditDetail_insertOldSQL + ' FROM #output_' + CAST(@i AS NVARCHAR(2)) + ' as Changes WHERE ssid = a.ssid AND sourcesystem = a.sourcesystem and changetype = a.changetype FOR XML AUTO, Elements XSINIL), ''&'', ''&amp;'')) AS Old' + CHAR(13)
				SET @auditDetail_insertNewSQL = @auditDetail_insertNewSQL + ' FROM #output_' + CAST(@i AS NVARCHAR(2)) + ' as Changes WHERE ssid = a.ssid AND sourcesystem = a.sourcesystem and changetype = a.changetype FOR XML AUTO, Elements XSINIL), ''&'', ''&amp;'')) AS New' + CHAR(13)
			END
		END
		ELSE
			SET @merge_updateSQL = @merge_updateSQL + ';' + CHAR(13)


		SET @audit_sql = 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
			+'values (current_timestamp, ''' + @mdm_process + ''', ''' + @groupDesc + ' Changes'', @@ROWCOUNT);'
		SET @audit_sql = @audit_sql + CHAR(13)
		
		IF @LogLevel > 0
		BEGIN
			SET @audit_sql = @audit_sql + CHAR(13)
				+ 'INSERT INTO ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + ' (DimCustomerId, SSID, SourceSystem, ChangedOn)' + CHAR(13)
				+ ' SELECT DISTINCT b.DimCustomerId, b.SSID, b.SourceSystem, a.DateTimeChanged' + CHAR(13)
				+ ' FROM #output_' + CAST(@i AS NVARCHAR(2)) + ' a' + CHAR(13)
				+ ' INNER JOIN ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + ' b ON a.SSID = b.SSID' + CHAR(13)
				+ '		AND a.SourceSystem = b.SourceSystem' + CHAR(13)
				+ ' LEFT JOIN ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + ' c ON b.DimCustomerId = c.DimCustomerId' + CHAR(13)
				+ ' WHERE c.DimCustomerId IS NULL'
			SET @audit_sql = @audit_sql + CHAR(13) + CHAR(13)

			SET @audit_sql = @audit_sql
				+ 'Insert into  ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
				+ 'values (current_timestamp, ''' + @mdm_process + ''', ''Log Change Records'', @@ROWCOUNT);'
			SET @audit_sql = @audit_sql + CHAR(13) + CHAR(13)

			IF @LogLevel > 1
			BEGIN
				SET @audit_sql = @audit_sql + CHAR(13)
					+ 'INSERT INTO ' + @ClientDB  + 'audit.ChangeLogDetail ' + CHAR(13)
					+ ' SELECT ''Dimcustomer'', ChangeType, ''Data Load'', DateTimeChanged ' + CHAR(13)
					+ ',' + @auditDetail_insertOldSQL
					+ ',' + @auditDetail_insertNewSQL
					+ ' FROM #output_' + CAST(@i AS NVARCHAR(2)) + ' a;'
				SET @audit_sql = @audit_sql + CHAR(13) + CHAR(13)

				SET @audit_sql = @audit_sql + CHAR(13)
					+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
					+ 'values (current_timestamp, ''' + @mdm_process + ''', ''' + ISNULL(@groupDesc,'') + ' Change Details'', @@ROWCOUNT);'
				SET @audit_sql = @audit_sql + CHAR(13)
			END

			SET @audit_sql = @audit_sql + CHAR(13) + 'DROP TABLE #output_' + CAST(@i AS NVARCHAR(2)) + CHAR(13) 
		END		
		
		SELECT @sql = @sql + '/****** ' + ISNULL(@groupDesc,'') + ' ******/' + CHAR(13) + @output_createTblSql + @merge_sql + @merge_updateSQL + @merge_outputSQL + CHAR(13) + @audit_sql + CHAR(13) + CHAR(13)

		SET @i = @i + 1
	END 

	RETURN
END
GO
