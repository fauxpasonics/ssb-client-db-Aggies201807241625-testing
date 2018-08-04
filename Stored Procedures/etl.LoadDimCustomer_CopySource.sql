SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [etl].[LoadDimCustomer_CopySource]   
(  
	@ClientDB VARCHAR(50),  
	@LoadView VARCHAR(100),  
	@LoadGuid VARCHAR(50)  
)  
AS  
BEGIN  
  
/*[etl].[LoadDimCustomer_CopySource]   
* created: 7/2/2015 - GHolder - dynamic sql procedure to load source data to dbo.Source_DimCustomer. Pass in client db name and view to load from.  
*  
*/  
  
	-- TESTING  
	-- DECLARE @ClientDB VARCHAR(50) = 'CU', @LoadView VARCHAR(100) = 'etl.tmp_load_DE0111BA70C54451B35F5F9AC612106C', @LoadGuid VARCHAR(50) = 'DE0111BA70C54451B35F5F9AC612106C'  
  
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
		, @sourceColumns NVARCHAR(MAX) = ''  
		, @tmp_sourceColumn NVARCHAR(MAX) = ''  
		, @destColumns NVARCHAR(MAX) = ''  
		, @tmp_destColumn NVARCHAR(MAX) = ''  
  
		, @col_cursor CURSOR  
		, @columnName NVARCHAR(150)  
		, @position INT  
		, @dataType NVARCHAR(128)  
  
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
		+ 'ORDER BY ORDINAL_POSITION' + CHAR(13)   
		+ CHAR(13)   
		+ 'OPEN @cursor' + CHAR(13)  
  
	EXEC sp_executesql @dynamicSQL, N'@cursor CURSOR OUTPUT', @col_cursor OUTPUT  
		  
	FETCH NEXT FROM @col_cursor  
	INTO @columnName, @position, @dataType, @maxLen, @precision, @scale  
		  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @tmp_sourceColumn = ''  
		SET @tmp_destColumn = ''  
		SET @dynamicSQL =  
		'	IF (''' + @columnName + ''' != ''DimCustomerId'' AND EXISTS (' + CHAR(13)  
		+ '		SELECT * ' + CHAR(13)  
		+ '		FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS a' + CHAR(13)  
		+ '		INNER JOIN ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS b ON a.COLUMN_NAME = b.COLUMN_NAME' + CHAR(13)  
		+ '			AND a.DATA_TYPE = b.DATA_TYPE' + CHAR(13)  
		+ '			AND b.TABLE_SCHEMA + ''.'' + b.TABLE_NAME = ''dbo.Source_DimCustomer''' + CHAR(13)   
		+ '		WHERE 1=1' + CHAR(13)  
		+ '		AND a.TABLE_SCHEMA + ''.'' + a.TABLE_NAME = ''' + @LoadView + '''' + CHAR(13)  
		+ '		AND a.COLUMN_NAME = ''' + @columnName + '''))' + CHAR(13)  
		+ '	BEGIN' + CHAR(13)	  
		+ '		SELECT @tmp_sourceColumn = ' + CHAR(13)   
		+ '			'' CAST(a.' + @columnName + ' AS ' + UPPER(@dataType) + CASE WHEN ISNULL(@maxLen,0) != 0 THEN '(' + CASE WHEN @maxLen = -1 THEN 'MAX)' ELSE CAST(@maxLen AS VARCHAR(10)) + ')' END WHEN ISNULL(@precision,0) != 0 AND @dataType NOT IN ('int','bigint') THEN '(' + CAST(@precision AS VARCHAR(10)) + ',' + CAST(@scale AS VARCHAR(10)) + ')' ELSE '' END + ')'' + CHAR(13)' + CHAR(13)  
		+ '		SELECT @tmp_destColumn = ' + CHAR(13)  
		+ '			''' + @columnName + ''' + CHAR(13)' + CHAR(13)  
		+ '	END' + CHAR(13)  
		+ ' ELSE IF EXISTS (' + CHAR(13)  
		+ '		SELECT * ' + CHAR(13)  
		+ '		FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS a' + CHAR(13)  
		+ '		WHERE 1=1' + CHAR(13)  
		+ '		AND a.TABLE_SCHEMA + ''.'' + a.TABLE_NAME = ''dbo.Source_DimCustomer''' + CHAR(13)    
		+ '		AND a.COLUMN_NAME = ''' + @columnName + ''')' + CHAR(13)  
		+ '	BEGIN' + CHAR(13)	  
		+ '		SELECT @tmp_sourceColumn = ' + CHAR(13)   
		+ '			'' CAST(b.' + @columnName + ' AS ' + UPPER(@dataType) + CASE WHEN ISNULL(@maxLen,0) != 0 THEN '(' + CASE WHEN @maxLen = -1 THEN 'MAX)' ELSE CAST(@maxLen AS VARCHAR(10)) + ')' END WHEN ISNULL(@precision,0) != 0 AND @dataType NOT IN ('int','bigint') THEN '(' + CAST(@precision AS VARCHAR(10)) + ',' + CAST(@scale AS VARCHAR(10)) + ')' ELSE '' END + ')'' + CHAR(13)' + CHAR(13)  
		+ '		SELECT @tmp_destColumn = ' + CHAR(13)  
		+ '			''' + @columnName + ''' + CHAR(13)' + CHAR(13)  
		+ '	END' + CHAR(13)  
		+ ' ' + CHAR(13)  
  
		EXEC sp_executesql @dynamicSQL, N'@tmp_sourceColumn nvarchar(MAX) OUTPUT, @tmp_destColumn nvarchar(MAX) OUTPUT', @tmp_sourceColumn OUTPUT, @tmp_destColumn OUTPUT  
  
		SELECT @sourceColumns = @sourceColumns + CASE WHEN ISNULL(LTRIM(RTRIM(@tmp_sourceColumn)),'') != '' THEN CASE WHEN ISNULL(@sourceColumns,'') = '' THEN '' ELSE ',' END + @tmp_sourceColumn ELSE '' END   
		SELECT @destColumns = @destColumns + CASE WHEN ISNULL(LTRIM(RTRIM(@tmp_destColumn)),'') != '' THEN CASE WHEN ISNULL(@destColumns,'') = '' THEN '' ELSE ',' END + @tmp_destColumn ELSE '' END   
  
		FETCH NEXT FROM @col_cursor  
		INTO @columnName, @position, @dataType, @maxLen, @precision, @scale  
	END  
  
	CLOSE @col_cursor  
	DEALLOCATE @col_cursor  
  
	----SELECT @sourceColumns, @destColumns  
  
	SET @sql = @sql   
	+ 'IF (SELECT COUNT(0) FROM '+ @ClientDB + @LoadView + ') > 200000' + CHAR(13)  
	+ 'BEGIN' + CHAR(13)  
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''dbo.Source_DimCustomer''' + CHAR(13)  
	+ 'END'+ CHAR(13)  
	SET @sql = @sql + CHAR(13) + CHAR(13)  
	  
	SET @sql = @sql   
	+ ' DELETE b' + CHAR(13)  
	+ ' --SELECT COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13)   
	+ ' INNER JOIN ' + @ClientDB + 'dbo.Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13)   
	+ ' 	AND a.SourceSystem = b.SourceSystem' + CHAR(13)
	SET @sql = @sql + CHAR(13) 	  

	SET @sql = @sql   
	+ ' DELETE c' + CHAR(13)  
	+ ' --SELECT COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13)   
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)   
	+ ' 	AND a.SourceSystem = b.SourceSystem' + CHAR(13)  
	+ ' INNER JOIN ' + @ClientDB + 'dbo.Source_DimCustomer c on b.DimCustomerId = c.DimCustomerId' + CHAR(13)  
	SET @sql = @sql + CHAR(13) 	  
  
	SET @sql = @sql + CHAR(13)  
		+ 'INSERT INTO '+ @ClientDB + '[dbo].[Source_DimCustomer] (' + @destColumns + ')' + CHAR(13)  
		+ 'SELECT DISTINCT' + CHAR(13) + @sourceColumns + CHAR(13)  
		+ 'FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13)   
		+ 'INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)  
		+ '	AND a.SourceSystem = b.SourceSystem' + CHAR(13)  
		+ 'LEFT join ' + @Clientdb + 'dbo.dimcustomerssbid d' 
		+ ' ON b.dimcustomerid = d.dimcustomerid ' + CHAR(13) 
		+ ' LEFT JOIN (Select ssb_crmsystem_contact_id, data_deletion_completed_ts from ' 
		 + @ClientDB + 'dbo.DimCustomerPrivacy p inner join '+ @ClientDB + 'dbo.dimcustomerssbid ssb on p.dimcustomerid = ssb.dimcustomerid) c' + CHAR(13) 
		+ ' on d.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id ' + CHAR(13) 
		+ 'WHERE 1=1 and c.data_deletion_completed_ts is null ' + CHAR(13)  
		+ 'AND a.RecordRank = 1'  
	SET @sql = @sql + CHAR(13) + CHAR(13)  
  
	----SELECT @sql  
  
	SET @sql = @sql  
		+ 'INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ 'VALUES (current_timestamp, ''Load Source_DimCustomer'', ''Copy records from source'', @@ROWCOUNT);'  
	SET @sql = @sql + CHAR(13) + CHAR(13)  
  
	SET @sql = @sql   
		+ 'IF (SELECT COUNT(0) FROM ' + @ClientDB + @LoadView + ') > 200000' + CHAR(13)  
		+ 'BEGIN' + CHAR(13)  
		+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 1, ''dbo.Source_DimCustomer''' + CHAR(13)  
		+ 'END'+ CHAR(13) + CHAR(13) 
 
 
	+ ' IF OBJECT_ID(''tempdb..#dimcustomerEmail'') IS NOT NULL' + CHAR(13) 
	+ ' 	DROP TABLE #dimcustomerEmail' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT b.DimCustomerID, cast(a.EmailPrimary as varchar(256)) AS Email, b.EmailPrimaryDirtyHash AS EmailDirtyHash, 1 AS DimEmailTypeID, CAST(NULL AS INT) AS Source_DimEmailID, CAST(NULL AS INT) AS DimEmailID' + CHAR(13) 
	+ ' INTO #dimcustomerEmail' + CHAR(13)
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.EmailPrimary,'''') != ''''' + CHAR(13) + CHAR(13)

  
	+ ' INSERT INTO #dimcustomerEmail' + CHAR(13)
	+ ' SELECT b.DimCustomerID, cast(a.EmailOne as varchar(256)) AS Email, b.EmailOneDirtyHash AS EmailDirtyHash, 2 AS DimEmailTypeID, CAST(NULL AS INT) AS Source_DimEmailID, CAST(NULL AS INT) AS DimEmailID' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.EmailOne,'''') != ''''' + CHAR(13) + CHAR(13)

  
	+ ' INSERT INTO #dimcustomerEmail' + CHAR(13)
	+ ' SELECT b.DimCustomerID, cast(a.EmailTwo as varchar(256)) AS Email, b.EmailTwoDirtyHash AS EmailDirtyHash, 3 AS DimEmailTypeID, CAST(NULL AS INT) AS Source_DimEmailID, CAST(NULL AS INT) AS DimEmailID' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.EmailTwo,'''') != ''''' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#email_ranked'') IS NOT NULL' + CHAR(13) 
	+ ' 	DROP TABLE #email_ranked' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT *, ROW_NUMBER() OVER (PARTITION BY a.EmailDirtyHash ORDER BY a.EmailDirtyHash) AS ranking' + CHAR(13) 
	+ ' INTO #email_ranked' + CHAR(13) 
	+ ' FROM #dimcustomerEmail a' + CHAR(13) 
	+ ' WHERE ISNULL(Email,'''') != ''''' + CHAR(13) + CHAR(13) 
  
	+ ' IF OBJECT_ID(''tempdb..#source_email_insert'') IS NOT NULL' + CHAR(13) 
	+ '		DROP TABLE #source_email_insert' + CHAR(13) + CHAR(13) 
 
 	+ ' ;WITH source_email AS (' + CHAR(13) 
	+ ' 	SELECT DISTINCT a.Email, a.EmailDirtyHash' + CHAR(13) 
	+ ' 	FROM #email_ranked a' + CHAR(13) 
	+ ' 	WHERE a.ranking = 1' + CHAR(13) 
	+ ' )' + CHAR(13) 
	+ ' SELECT a.Email, a.EmailDirtyHash' + CHAR(13) 
	+ ' INTO #source_email_insert' + CHAR(13) 
	+ ' FROM source_email a' + CHAR(13) 
	+ ' LEFT JOIN ' + @ClientDB + 'email.Source_DimEmail b ON a.EmailDirtyHash = b.EmailDirtyHash' + CHAR(13) 
	+ ' WHERE b.Source_DimEmailID IS NULL' + CHAR(13) + CHAR(13) 

	+ ' IF (SELECT COUNT(0) FROM #source_email_insert) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load Source_DimEmail'', ''Disable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13) 
	+ ' 	                                 @TableName = ''email.Source_DimEmail'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'email.Source_DimEmail (Email, EmailDirtyHash)' + CHAR(13) 
	+ ' SELECT Email, EmailDirtyHash' + CHAR(13) 
	+ ' FROM #source_email_insert' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' VALUES (current_timestamp, ''Load Source_DimEmail'', ''Copy records from source'', @@ROWCOUNT);'  
	  
	+ ' IF (SELECT COUNT(0) FROM #source_email_insert) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load Source_DimEmail'', ''Enable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13) 
	+ ' 	                                 @TableName = ''email.Source_DimEmail'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
	+ ' UPDATE a' + CHAR(13) 
	+ ' SET a.Source_DimEmailID = b.Source_DimEmailID' + CHAR(13) 
	+ '		,a.DimEmailID = b.DimEmailID' + CHAR(13) 
	+ ' FROM #dimcustomerEmail a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'email.Source_DimEmail b ON a.EmailDirtyHash = b.EmailDirtyHash' + CHAR(13) + CHAR(13) 
 
	+ ' SELECT b.DimCustomerEmailID, a.Source_DimEmailID, a.DimEmailID' + CHAR(13) 
	+ ' INTO #dce_update' + CHAR(13) 
	+ ' FROM #dimcustomerEmail a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.DimEmailTypeID = b.DimEmailTypeID' + CHAR(13) 
	+ '		AND a.Source_DimEmailID != b.Source_DimEmailID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND a.Source_DimEmailID IS NOT NULL' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT a.DimCustomerID, a.Source_DimEmailID, a.DimEmailID, a.DimEmailTypeID' + CHAR(13) 
	+ ' INTO #dce_insert' + CHAR(13) 
	+ ' FROM #dimcustomerEmail a' + CHAR(13) 
	+ ' LEFT JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.DimEmailTypeID = b.DimEmailTypeID' + CHAR(13) +  
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND a.Source_DimEmailID IS NOT NULL' + CHAR(13) 
	+ ' AND b.DimCustomerEmailID IS NULL' + CHAR(13) + CHAR(13) 
 
	+ ' SELECT b.DimCustomerEmailID' + CHAR(13) 
	+ ' INTO #dce_delete' + CHAR(13) 
	+ ' FROM #dimcustomerEmail a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.DimEmailTypeID = b.DimEmailTypeID' + CHAR(13) 
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND ISNULL(Email,'''') = ''''' + CHAR(13) + CHAR(13) 
	 
	+ ' IF ((SELECT COUNT(0) FROM #dce_update) + (SELECT COUNT(0) FROM #dce_insert) + (SELECT COUNT(0) FROM #dce_delete)) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load cust.DimCustomerEmail'', ''Disable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13) 
	+ ' 	                                 @TableName = ''cust.DimCustomerEmail'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 

	+ ' DELETE b' + CHAR(13) 
	+ ' FROM #dce_delete a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerEmailID = b.DimCustomerEmailID' + CHAR(13) + CHAR(13) 
 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load cust.DimCustomerEmail'', ''Deleted'', @@Rowcount);' + CHAR(13) + CHAR(13) 
  
	+ ' UPDATE b' + CHAR(13) 
	+ ' SET b.Source_DimEmailID = a.Source_DimEmailID' + CHAR(13) 
	+ '		,b.DimEmailID = a.DimEmailID' + CHAR(13) 
	+ '		,b.UpdatedDate = GETDATE()' + CHAR(13) 
	+ ' FROM #dce_update a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerEmailID = b.DimCustomerEmailID' + CHAR(13) + CHAR(13) 
	 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load cust.DimCustomerEmail'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'cust.DimCustomerEmail (DimCustomerID, Source_DimEmailID, DimEmailID, DimEmailTypeID)' + CHAR(13) 
	+ ' SELECT * FROM #dce_insert' + CHAR(13) + CHAR(13) 
 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load cust.DimCustomerEmail'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' IF ((SELECT COUNT(0) FROM #dce_update) + (SELECT COUNT(0) FROM #dce_insert) + (SELECT COUNT(0) FROM #dce_delete)) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load cust.DimCustomerEmail'', ''Enable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13) 
	+ ' 	                                 @TableName = ''cust.DimCustomerEmail'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 

	+ ' IF OBJECT_ID(''tempdb..#dimcustomerPhone'') IS NOT NULL' + CHAR(13) 
	+ ' 	DROP TABLE #dimcustomerPhone' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT b.DimCustomerID, cast(a.PhonePrimary as varchar(25)) AS Phone, b.PhonePrimaryDirtyHash AS PhoneDirtyHash, CAST(''Primary'' AS VARCHAR(10)) AS PhoneType, CAST(NULL AS INT) AS Source_DimPhoneID, CAST(NULL AS INT) AS DimPhoneID' + CHAR(13) 
	+ ' INTO #dimcustomerPhone' + CHAR(13)
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhonePrimary,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' INSERT INTO #dimcustomerPhone (DimCustomerId, Phone, PhoneDirtyHash, PhoneType)' + CHAR(13)
	+ ' SELECT b.DimCustomerID, cast(a.PhoneHome as varchar(25)), b.PhoneHomeDirtyHash, ''Home'' AS PhoneType' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhoneHome,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' INSERT INTO #dimcustomerPhone (DimCustomerId, Phone, PhoneDirtyHash, PhoneType)' + CHAR(13) 
	+ ' SELECT b.DimCustomerID, cast(a.PhoneCell as varchar(25)), b.PhoneCellDirtyHash, ''Cell'' AS PhoneType' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhoneCell,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' INSERT INTO #dimcustomerPhone (DimCustomerId, Phone, PhoneDirtyHash, PhoneType)' + CHAR(13) 
	+ ' SELECT b.DimCustomerID, cast(a.PhoneBusiness as varchar(25)), b.PhoneBusinessDirtyHash, ''Business'' AS PhoneType' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhoneBusiness,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' INSERT INTO #dimcustomerPhone (DimCustomerId, Phone, PhoneDirtyHash, PhoneType)' + CHAR(13) 
	+ ' SELECT b.DimCustomerID, cast(a.PhoneFax as varchar(25)), b.PhoneFaxDirtyHash, ''Fax'' AS PhoneType' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhoneFax,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' INSERT INTO #dimcustomerPhone (DimCustomerId, Phone, PhoneDirtyHash, PhoneType)' + CHAR(13)
	+ ' SELECT b.DimCustomerID, cast(a.PhoneOther as varchar(25)), b.PhoneOtherDirtyHash, ''Other'' AS PhoneType' + CHAR(13) 
	+ ' FROM ' + @ClientDB + @LoadView + ' a' + CHAR(13) 
	+ ' INNER JOIN '+ @ClientDB + 'dbo.vw_Source_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
	+ ' AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ ' WHERE ISNULL(a.PhoneOther,'''') != ''''' + CHAR(13) + CHAR(13)
	
	+ ' IF OBJECT_ID(''tempdb..#phone_ranked'') IS NOT NULL' + CHAR(13) 
	+ ' 	DROP TABLE #phone_ranked' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT *, ROW_NUMBER() OVER (PARTITION BY a.PhoneDirtyHash ORDER BY a.PhoneDirtyHash) AS ranking' + CHAR(13) 
	+ ' INTO #phone_ranked' + CHAR(13) 
	+ ' FROM #dimcustomerPhone a' + CHAR(13) 
	+ ' WHERE ISNULL(Phone,'''') != ''''' + CHAR(13) + CHAR(13) 
 
	+ ' IF OBJECT_ID(''tempdb..#source_phone_insert'') IS NOT NULL' + CHAR(13) 
	+ '		DROP TABLE #source_phone_insert' + CHAR(13) + CHAR(13) 
 
 	+ ' ;WITH source_phone AS (' + CHAR(13) 
	+ ' 	SELECT DISTINCT a.Phone, a.PhoneDirtyHash' + CHAR(13) 
	+ ' 	FROM #phone_ranked a' + CHAR(13) 
	+ ' 	WHERE a.ranking = 1' + CHAR(13) 
	+ ' )' + CHAR(13) 
	+ ' SELECT a.Phone, a.PhoneDirtyHash' + CHAR(13) 
	+ ' INTO #source_phone_insert' + CHAR(13) 
	+ ' FROM source_phone a' + CHAR(13) 
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.Source_DimPhone b ON a.PhoneDirtyHash = b.PhoneDirtyHash' + CHAR(13) 
	+ ' WHERE b.Source_DimPhoneID IS NULL' + CHAR(13) + CHAR(13) 
 
	+ ' IF (SELECT COUNT(0) FROM #source_phone_insert) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load Source_DimPhone'', ''Disable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13) 
	+ ' 	                                 @TableName = ''dbo.Source_DimPhone'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'dbo.Source_DimPhone (Phone, PhoneDirtyHash)' + CHAR(13) 
	+ ' SELECT Phone, PhoneDirtyHash' + CHAR(13) 
	+ ' FROM #source_phone_insert' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' VALUES (current_timestamp, ''Load Source_DimPhone'', ''Copy records from source'', @@ROWCOUNT);'  
	  
	+ ' IF (SELECT COUNT(0) FROM #source_phone_insert) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load Source_DimPhone'', ''Enable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13) 
	+ ' 	                                 @TableName = ''dbo.Source_DimPhone'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
	+ ' UPDATE a' + CHAR(13) 
	+ ' SET a.Source_DimPhoneID = b.Source_DimPhoneID' + CHAR(13) 
	+ '		,a.DimPhoneID = b.DimPhoneID' + CHAR(13) 
	+ ' FROM #dimcustomerPhone a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.Source_DimPhone b ON a.PhoneDirtyHash = b.PhoneDirtyHash' + CHAR(13) + CHAR(13) 
 
	+ ' SELECT b.ID, a.Source_DimPhoneID, a.DimPhoneID' + CHAR(13) 
	+ ' INTO #dcp_update' + CHAR(13) 
	+ ' FROM #dimcustomerPhone a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.PhoneType = b.PhoneType' + CHAR(13) 
	+ '		AND a.Source_DimPhoneID != b.Source_DimPhoneID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND a.Source_DimPhoneID IS NOT NULL' + CHAR(13) + CHAR(13) 
	 
	+ ' SELECT a.DimCustomerID, a.Source_DimPhoneID, a.DimPhoneID, a.PhoneType' + CHAR(13) 
	+ ' INTO #dcp_insert' + CHAR(13) 
	+ ' FROM #dimcustomerPhone a' + CHAR(13) 
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.PhoneType = b.PhoneType' + CHAR(13) +  
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND a.Source_DimPhoneID IS NOT NULL' + CHAR(13) 
	+ ' AND b.ID IS NULL' + CHAR(13) + CHAR(13) 
 
	+ ' SELECT b.ID' + CHAR(13) 
	+ ' INTO #dcp_delete' + CHAR(13) 
	+ ' FROM #dimcustomerPhone a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) 
	+ '		AND a.PhoneType = b.PhoneType' + CHAR(13) 
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND ISNULL(Phone,'''') = ''''' + CHAR(13) + CHAR(13) 
	 
	+ ' IF ((SELECT COUNT(0) FROM #dcp_update) + (SELECT COUNT(0) FROM #dcp_insert) + (SELECT COUNT(0) FROM #dcp_delete)) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load dbo.DimCustomerPhone'', ''Disable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13) 
	+ ' 	                                 @TableName = ''dbo.DimCustomerPhone'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
	+ ' UPDATE b' + CHAR(13) 
	+ ' SET b.Source_DimPhoneID = a.Source_DimPhoneID' + CHAR(13) 
	+ '		,b.DimPhoneID = a.DimPhoneID' + CHAR(13) 
	+ '		,b.UpdatedDate = GETDATE()' + CHAR(13) 
	+ ' FROM #dcp_update a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.ID = b.ID' + CHAR(13) + CHAR(13) 
	 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load dbo.DimCustomerPhone'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'dbo.DimCustomerPhone (DimCustomerID, Source_DimPhoneID, DimPhoneID, PhoneType)' + CHAR(13) 
	+ ' SELECT * FROM #dcp_insert' + CHAR(13) + CHAR(13) 
 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load dbo.DimCustomerPhone'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' DELETE b' + CHAR(13) 
	+ ' FROM #dcp_delete a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.ID = b.ID' + CHAR(13) + CHAR(13) 
 
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' values (current_timestamp, ''Load dbo.DimCustomerPhone'', ''Deleted'', @@Rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' IF ((SELECT COUNT(0) FROM #dcp_update) + (SELECT COUNT(0) FROM #dcp_insert) + (SELECT COUNT(0) FROM #dcp_delete)) >= 100000' + CHAR(13) 
	+ ' BEGIN' + CHAR(13) 
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ ' 	VALUES (current_timestamp, ''Load dbo.DimCustomerPhone'', ''Enable indexes'', 0);' + CHAR(13) + CHAR(13) 
 
	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13) 
	+ ' 	                                 @TableName = ''dbo.DimCustomerPhone'',' + CHAR(13) 
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13) 
	+ ' END' + CHAR(13) + CHAR(13) 
 
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

	---SELECT @sql  
  
	EXEC sp_executesql @sql  

	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql
  
END


/****** Object:  StoredProcedure [etl].[UpdateDimCustomerFromCDIOOutput]    Script Date: 6/6/2018 9:56:08 AM ******/
SET ANSI_NULLS ON
GO
