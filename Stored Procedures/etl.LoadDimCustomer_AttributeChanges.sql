SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[LoadDimCustomer_AttributeChanges] 
(
	@ClientDB VARCHAR(50),
	@LoadView VARCHAR(100),
	@LoadGuid VARCHAR(50),
	@LogLevel INT
)
AS
BEGIN

	-- TESTING
	--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV', @LoadView VARCHAR(100) = 'etl.tmp_changes_64F7F5F7AF814F8DA6359E9F2737A80E', @LogLevel INT = 0

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
		-- List base columns here - these will be included in the update section of EACH merge statement generated
		@baseColumns_sql NVARCHAR(MAX) = 
			'''SSCreatedBy'',''SSUpdatedBy'',''SSCreatedDate'',''SSUpdatedDate''' 
		-- List ALL object-specfic columns for the auto-generated merge statement(s) here 
		, @targetColumns_sql NVARCHAR(MAX) = 
			'''CustomerType'',''CustomerStatus'',''AccountType'',''AccountRep'',''CompanyName'',''SalutationName'',''DonorMailName'',''DonorFormalName'',''Birthday'',''Gender''
			,''AccountId'',''MergedRecordFlag'',''MergedIntoSSID'',''IsBusiness'',''IsDeleted''
			,''ExtAttribute1'',''ExtAttribute2'',''ExtAttribute3'',''ExtAttribute4'',''ExtAttribute5'',''ExtAttribute6'',''ExtAttribute7'',''ExtAttribute8'',''ExtAttribute9'',''ExtAttribute10'',''ExtAttribute11'',''ExtAttribute12''
			,''ExtAttribute13'',''ExtAttribute14'',''ExtAttribute15'',''ExtAttribute16'',''ExtAttribute17'',''ExtAttribute18'',''ExtAttribute19'',''ExtAttribute20'',''ExtAttribute21'',''ExtAttribute22'',''ExtAttribute23'',''ExtAttribute24''
			,''ExtAttribute25'',''ExtAttribute26'',''ExtAttribute27'',''ExtAttribute28'',''ExtAttribute29'',''ExtAttribute30'',''ExtAttribute31'',''ExtAttribute32'',''ExtAttribute33'',''ExtAttribute34'',''ExtAttribute35''
			,''contactattrDirtyHash'',''extattr1_10DirtyHash'',''extattr11_20DirtyHash'',''extattr21_30DirtyHash'',''extattr21_30DirtyHash'',''extattr31_35DirtyHash'''
		-- To generate a single merge statement, set @groupID_sql = '1'. Otherwise, use a CASE statement to identify object-specific groups
		, @groupID_sql NVARCHAR(MAX) = 
			--'1'
			'CASE 
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 1 AND 10) OR (COLUMN_NAME LIKE ''extattr1[_]%'') THEN 1 
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 11 AND 20) OR (COLUMN_NAME LIKE ''extattr11[_]%'') THEN 2
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 21 AND 30) OR (COLUMN_NAME LIKE ''extattr21[_]%'') THEN 3
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 31 AND 35) OR (COLUMN_NAME LIKE ''extattr31[_]%'') THEN 4
				WHEN COLUMN_NAME != ''IsDeleted'' THEN 5
				ELSE 6
			END'
		-- For each object-specific group identified (e.g. AddressPrimary, AddressOne, etc.), provide a description. The description will be referenced during logging.
		, @groupDesc_sql NVARCHAR(MAX) = 
			--'''Attribute'''
			'CASE 
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 1 AND 10) OR (COLUMN_NAME LIKE ''extattr1[_]%'') THEN ''External Attribute 1-10'' 
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 11 AND 20) OR (COLUMN_NAME LIKE ''extattr11[_]%'') THEN ''External Attribute 11-20''
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 21 AND 30) OR (COLUMN_NAME LIKE ''extattr21[_]%'') THEN ''External Attribute 21-30''
				WHEN (COLUMN_NAME LIKE ''ExtAttribute%'' AND REPLACE(COLUMN_NAME,''ExtAttribute'','''') BETWEEN 31 AND 35) OR (COLUMN_NAME LIKE ''extattr31[_]%'') THEN ''External Attribute 31-35''
				WHEN COLUMN_NAME != ''IsDeleted'' THEN ''Other Attribute''
				ELSE COLUMN_NAME
			END'
		-- Identify which condition(s) will determine whether or not the object-specific column (listed in @targetColumns_sql) is included in the OUTPUT clause of the merge statement. 
		-- To include ALL set @getOutput_sql = '1'
		, @getOutput_sql NVARCHAR(MAX) = 
			'1'
		-- Identify which condition(s) will determine whether or not the object-specific column is included in the matching process of the merge statement. These will be in addition to the defaults. 
		-- To use default matching only, set @matchCondiation_sql to '0'
		, @matchCondition_sql NVARCHAR(MAX) = 
			'CASE WHEN COLUMN_NAME LIKE ''%Hash%'' OR COLUMN_NAME = ''IsDeleted'' THEN 1 ELSE 0 END'
		, @sql NVARCHAR(MAX) = ''

	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql
	SET @sql = ''

	-- Generate merge script (will include record level logging if @LogLevel > 0 and detail level logging if @LogLevel > 1) 
	EXEC etl.LoadDimCustomer_GenerateMerge @ClientDB = @ClientDB, -- varchar(50)
		@LoadView = @LoadView, -- varchar(100)
		@LoadGuid = @LoadGuid, -- varchar(50)
		@LogLevel = @LogLevel, -- int
		@baseColumns_sql = @baseColumns_sql, -- nvarchar(max)
		@targetColumns_sql = @targetColumns_sql, -- nvarchar(max)
		@groupID_sql = @groupID_sql, -- nvarchar(max)
		@groupDesc_sql = @groupDesc_sql, -- nvarchar(max)
		@getOutput_sql =@getOutput_sql, -- nvarchar(max)
		@matchCondition_sql = @matchCondition_sql, -- nvarchar(max)
		@sql = @sql OUTPUT -- nvarchar(max)
	
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
