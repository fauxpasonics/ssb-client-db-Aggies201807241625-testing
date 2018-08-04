SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[LoadDimCustomer_LoadNew]  
( 
	@ClientDB VARCHAR(50), 
	@LoadView VARCHAR(100), 
	@LoadGuid VARCHAR(50) 
) 
AS 
BEGIN 
 
/*[etl].[LoadDimCustomer_LoadNew]  
* created: 7/2/2015 - Kwyss - dynamic sql procedure to load data to dimcustomer.   Pass in client db name and view to load from. 
* modified: 10/14/2015 - GHolder 
* modified: 11/28/2016 - GHolder - excluding ContactGUID 
* 
*/ 
 
	-- TESTING 
----DECLARE @ClientDB VARCHAR(50) = 'NASCARPROD', @LoadView VARCHAR(100) = 'etl.tmp_load_16E9669CC91B49D3B588A28BD4FF30D9', @LoadGuid VARCHAR(50) = '16E9669CC91B49D3B588A28BD4FF30D9' 
 
	-- Remove square brackets 
	SELECT @ClientDB = REPLACE(REPLACE(@ClientDB,'[',''),']','') 
	SELECT @LoadView = REPLACE(REPLACE(@LoadView,'[',''),']','') 
 
	-- Remove database name from @LoadView 
	SELECT @LoadView = CASE WHEN LEFT(@LoadView,LEN(@ClientDB + '.')) = @ClientDB + '.' THEN REPLACE(@LoadView, @ClientDB + '.', '') ELSE @LoadView END	 
 
	IF (SELECT @@VERSION) LIKE '%Azure%' 
	BEGIN 
		SET @ClientDB = '' 
	END 
 
	IF (SELECT @@VERSION) NOT LIKE '%Azure%' 
	BEGIN 
		SET @ClientDB = @ClientDB + '.' 
	END 
 
	DECLARE 
		@sql NVARCHAR(MAX) = '' 
		, @dynamicSQL NVARCHAR(MAX) = '' 
		, @destColumns NVARCHAR(MAX) = '' 
		, @sourceColumns NVARCHAR(MAX) = '' 
 
		, @sourceColumns2 NVARCHAR(MAX) = '' 
 
		, @col_cursor CURSOR 
		, @columnName NVARCHAR(150) 
		, @position INT 
		, @dataType NVARCHAR(128) 
		--, @maxLen NVARCHAR(128) 
		 
		, @maxLen INT 
		, @precision INT 
		, @scale INT 
 
	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql
	SET @sql = ''

	SET @dynamicSQL =  
		'SET @cursor = CURSOR FOR' + CHAR(13) 
		+ 'SELECT COLUMN_NAME, ORDINAL_POSITION, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE' + CHAR(13) 
		+ 'FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS' + CHAR(13) 
		+ 'WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''dbo.DimCustomer''' + CHAR(13) 
		+ ' and column_name NOT IN (''dimcustomerid'',''ContactGUID'')' + CHAR(13) 
		---+ 'AND COLUMNPROPERTY(object_id(TABLE_SCHEMA + ''.'' + TABLE_NAME), COLUMN_NAME, ''IsIdentity'') = 0' + CHAR(13) 
		+ 'ORDER BY ORDINAL_POSITION' + CHAR(13)  
		+ CHAR(13)  
		+ 'OPEN @cursor' + CHAR(13) 
 
	EXEC sp_executesql @dynamicSQL, N'@cursor CURSOR OUTPUT', @col_cursor OUTPUT 
		 
	FETCH NEXT FROM @col_cursor 
	INTO @columnName, @position, @dataType, @maxLen, @precision, @scale 
		 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SELECT @destColumns = @destColumns + CASE WHEN ISNULL(LTRIM(RTRIM(@destColumns)),'') != '' THEN ',' ELSE '' END + @columnName + CHAR(13) 
 
		SET @dynamicSQL = 
		'	IF EXISTS (SELECT * FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''' + @LoadView + ''' AND COLUMN_NAME = ''' + @columnName + ''')' + CHAR(13) 
		+ '	BEGIN' + CHAR(13)	 
		+ '		SELECT @sourceColumns2 = ' + CHAR(13)  
		+ '			'' TRY_CAST(a.' + @columnName + ' AS ' + UPPER(@dataType) + CASE WHEN ISNULL(@maxLen,0) != 0 THEN '(' + CASE WHEN @maxLen = -1 THEN 'MAX)' ELSE CAST(@maxLen AS VARCHAR(10)) + ')' END WHEN ISNULL(@precision,0) != 0 AND @dataType NOT IN ('int','bigint') THEN '(' + CAST(@precision AS VARCHAR(10)) + ',' + CAST(@scale AS VARCHAR(10)) + ')' ELSE '' END + ')'' + CHAR(13)' + CHAR(13) 
		+ '	END' + CHAR(13) 
		+ '	ELSE' + CHAR(13) 
		+ '	BEGIN' + CHAR(13) 
		+ '		SELECT @sourceColumns2 = ' + CHAR(13) 
		--+ '			''NULL AS ' + @columnName + ''' + CHAR(13)' + CHAR(13) 
		+ '			CASE WHEN ''' + @columnName + ''' IN (''CreatedDate'', ''UpdatedDate'') THEN ''GETDATE()'' WHEN ''' + @columnName + ''' IN (''IsDeleted'') THEN ''0'' ELSE ''NULL'' END + '' AS ' + @columnName + ''' + CHAR(13)' + CHAR(13) 
		+ '	END' + CHAR(13)	 
		 
		----SELECT @dynamicSQL 
 
		EXEC sp_executesql @dynamicSQL, N'@sourceColumns2 nvarchar(MAX) OUTPUT', @sourceColumns2 OUTPUT 
 
		SELECT @sourceColumns = @sourceColumns + CASE WHEN ISNULL(LTRIM(RTRIM(@sourceColumns)),'') != '' THEN ',' ELSE '' END + @sourceColumns2 
 
		FETCH NEXT FROM @col_cursor 
		INTO @columnName, @position, @dataType, @maxLen, @precision, @scale 
	END 
 
	CLOSE @col_cursor 
	DEALLOCATE @col_cursor 
 
	----SELECT @sourceColumns, @destColumns 

	 
	SET @sql = @sql + CHAR(13) 
		+ 'SELECT a.* '+ CHAR(13) 
		+ 'into #tmp_new '
		+ 'FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13)  
		+ 'LEFT JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
		+ '	AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
		+ 'WHERE b.DimCustomerId IS NULL' + CHAR(13) 
		+ 'AND a.RecordRank = 1' 
	SET @sql = @sql + CHAR(13) + CHAR(13) 

 
	SET @sql = @sql  
	+ 'IF (SELECT COUNT(0) FROM #tmp_new) > 200000' + CHAR(13) 
	+ 'BEGIN' + CHAR(13) 
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''dbo.DimCustomer''' + CHAR(13) 
	+ 'END'+ CHAR(13) 
	SET @sql = @sql + CHAR(13) + CHAR(13) 
 
	SET @sql = @sql + CHAR(13) 
		+ 'INSERT INTO '+ @ClientDB + '[dbo].[DimCustomer] (' + @destColumns + ')' + CHAR(13) 
		+ 'SELECT' + CHAR(13) + @sourceColumns + CHAR(13) 
		+ 'FROM #tmp_new a' + CHAR(13)  
	SET @sql = @sql + CHAR(13) + CHAR(13) 
 
	--SELECT @sql 
 
	SET @sql = @sql 
		+ 'INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'VALUES (current_timestamp, ''Load DimCustomer'', ''Insert New Records'', @@ROWCOUNT);' 
	SET @sql = @sql + CHAR(13) + CHAR(13) 
 
	SET @sql = @sql  
		+ 'IF (SELECT COUNT(0) FROM #tmp_new) > 200000' + CHAR(13) 
		+ 'BEGIN' + CHAR(13) 
		+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 1, ''dbo.DimCustomer''' + CHAR(13) 
		+ 'END'+ CHAR(13) 
 
 	-- Add TRY/CATCH block to force stoppage and log error      
	SET @sql = ''     
		+ ' BEGIN TRY' + CHAR(13)      
			+ @sql  
		+ ' END TRY' + CHAR(13)     
		+ ' BEGIN CATCH' + CHAR(13)     
		+ '		DECLARE @ErrorMessage NVARCHAR(92)' + CHAR(13)     
		+ '			, @ErrorSeverity INT' + CHAR(13)     
		+ '			, @ErrorState INT' + CHAR(13) + CHAR(13)     
     
		+ '		SELECT @ErrorMessage = LEFT(ERROR_MESSAGE(), 92)' + CHAR(13)      
		+ '			, @ErrorSeverity = ERROR_SEVERITY()' + CHAR(13)      
		+ '			, @ErrorState = ERROR_STATE()' + CHAR(13) + CHAR(13)     
     
		+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
		+ '		VALUES (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)     
     
		+ '		RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)     
		+ '             @ErrorSeverity, -- Severity.' + CHAR(13)     
		+ '             @ErrorState -- State.' + CHAR(13)     
		+ '             );' + CHAR(13)     
		+ ' END CATCH' + CHAR(13) + CHAR(13) 

----SELECT @sql 
 
	EXEC sp_executesql @sql 
 
	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql

END
GO
