SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[LoadDimCustomerPrivacy] (
	@ClientDB VARCHAR(50),
	@LoadView VARCHAR(100)  = 'api.UploadDimCustomerPrivacyStaging',
	@LoadGuid varchar(50),
	@LogLevel INT = 0,
	@IsDataUploaderSource varchar(10) = 1
)
AS
BEGIN



----DECLARE @ClientDB VARCHAR(50) = 'mdm_client_test', @loadview varchar(100) = 'api.UploadDimCustomerStaging', @IsDataUploaderSource varchar(10)= 1, @LoadGuid varchar(50)= 'DE0111BA70C54451B35F5F9AC612106C', @LogLevel INT = 0

Declare @PrivacyLoadView varchar(100);

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
		@sql NVARCHAR(MAX) = '  '

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''

IF @IsDataUploaderSource = 1
Begin
SET @Loadview = 'api.UploadDimCustomerPrivacyStaging'
END

SET @sql = @sql 
---VERIFY Table has all the columns needed for Privacy Data Load
+' IF (' + CHAR(13)
+'Select count(a.column_name) from ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS  a' + CHAR(13)
+'Left JOIN ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS b' + CHAR(13)
+'on a.column_name = b.column_name ' + CHAR(13)
+'and b.table_name =  substring(''' + @Loadview + ''', charindex(''.'', ''' + @Loadview + ''')+ 1, len(''' + @Loadview + ''') - charindex(''.'', ''' + @Loadview + ''')) ' + CHAR(13)
+'and b.Table_Schema = substring(''' + @Loadview + ''', 1, charindex(''.'', ''' + @Loadview + ''')-1)' + CHAR(13)
+'where a.table_name = ''UploadDimCustomerPrivacyStaging'' and a.table_schema = ''api''' + CHAR(13)
+'	and a.column_name not in (''SessionID'', ''RecordCreatedDate'', ''Processed'') and b.column_name is null) > 0' + CHAR(13)

+'BEGIN'+ CHAR(13)
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''Load DimCustomerPrivacy'', ''Missing Columns - Unable to Load Privacy Data'', @@Rowcount);' + CHAR(13)

+'END' + CHAR(13)
+'ELSE' + CHAR(13)
+'BEGIN' + CHAR(13)



SET @sql = @sql 
+'IF OBJECT_ID(''' + @ClientDb + 'etl.tmp_privacy_' + @loadguid + ''') IS NOT NULL '+ CHAR(13)
+'	DROP TABLE ' + @ClientDb + 'etl.tmp_privacy_' + @loadguid + char(13)

+ 'select a.* ' 
IF @IsDataUploaderSource = 1
Begin
SET @sql = @sql 
+ ', ROW_NUMBER() OVER (PARTITION BY a.SSID, a.SourceSystem ORDER BY a.RecordCreatedDate DESC) as RecordRank' + CHAR(13)
END
Set @SQL = @SQL
+ 'into ' + @ClientDB + 'etl.tmp_privacy_' + @loadguid + CHAR(13)
+ 'FROM ' + @ClientDB + @LoadView + ' a ' + CHAR(13)
+ 'INNER JOIN ' + @ClientDB + 'dbo.dimcustomer b ' + CHAR(13)
+ 'ON a.ssid = b.ssid AND a.sourcesystem = b.sourcesystem ' + CHAR(13)
IF @IsDataUploaderSource = 1
Begin
SET @sql = @sql 
+ 'WHERE ISNULL(processed,0) = 0 ' + CHAR(13)
END
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''Load DimCustomerPrivacy'', ''Assign DimCustomerID'', @@Rowcount);'
SET @sql = @sql + CHAR(13) + CHAR(13)

set @PrivacyLoadview = @ClientDB + 'etl.tmp_privacy_' + @loadguid


SET @sql = @sql 
+ 'UPDATE a ' + CHAR(13)
+ 'SET UpdatedDate = RecordCreatedDate' + CHAR(13)
+ ', Verified_Consent_TS = CASE WHEN isnull(b.Verified_Consent_TS, ''1/1/1900'') > isnull(a.Verified_Consent_TS, ''1/1/1900'') THEN b.Verified_Consent_TS ELSE a.verified_consent_ts end' + CHAR(13)
+ ', Verified_Consent_Source = CASE WHEN ISNULL(b.verified_consent_source, '''') != '''' THEN b.Verified_Consent_Source ELSE a.Verified_Consent_Source END' + CHAR(13)
+ ', Data_Deletion_Request_TS = CASE WHEN  isnull(b.Data_Deletion_Request_TS, ''1/1/1900'') > isnull(a.Data_Deletion_Request_TS, ''1/1/1900'') THEN b.Data_Deletion_Request_TS ELSE a.Data_Deletion_Request_TS end' + CHAR(13)
+ ', Data_Deletion_Request_Reason = CASE WHEN ISNULL(b.Data_Deletion_Request_Reason, '''') != '''' THEN b.Data_Deletion_Request_Reason ELSE a.Data_Deletion_Request_Reason END' + CHAR(13)
+ ', Data_Deletion_Request_Source = CASE WHEN ISNULL(b.Data_Deletion_Request_Source, '''') != '''' THEN b.Data_Deletion_Request_Source ELSE a.Data_Deletion_Request_Source END' + CHAR(13)
+ ', Subject_Access_Request_TS = CASE WHEN isnull(b.Subject_Access_Request_TS, ''1/1/1900'') > isnull(a.Subject_Access_Request_TS, ''1/1/1900'') THEN b.Subject_Access_Request_TS ELSE a.Subject_Access_Request_TS END' + CHAR(13)
+ ', Subject_Access_Request_Source = CASE WHEN ISNULL(b.Subject_Access_Request_Source, '''') != '''' THEN b.Subject_Access_Request_Source ELSE a.Subject_Access_Request_Source End' + CHAR(13)
+ ', Direct_Marketing_OptOut_TS = CASE WHEN isnull(b.Direct_Marketing_OptOut_TS, ''1/1/1900'') > isnull(a.Direct_Marketing_Optout_TS, ''1/1/1900'') THEN b.Direct_Marketing_OptOut_TS else a.Direct_Marketing_OptOut_TS End' + CHAR(13)
+ ', Direct_Marketing_OptOut_Reason = CASE WHEN ISNULL(b.Direct_Marketing_OptOut_Reason, '''') != '''' THEN b.Direct_Marketing_OptOUt_Reason ELSE a.Direct_Marketing_Optout_Reason END' + CHAR(13)
+ ', Direct_Marketing_OptOut_Source = CASE WHEN ISNULL(b.Direct_Marketing_OptOut_Source, '''') != '''' THEN b.Direct_Marketing_OptOut_Source ELSE a.Direct_Marketing_OptOut_Source end' + CHAR(13)
+ 'FROM ' + @ClientDB + 'dbo.DimCustomerPrivacy a' + CHAR(13)
+ 'inner join ' + @ClientDB + 'dbo.dimcustomer d' + Char(13)
+ 'on  a.dimcustomerid = d.dimcustomerid' + char(13)
+ 'Inner JOIN '+ @PrivacyLoadView + '  b' + CHAR(13)
+ 'ON a.dimcustomerid = d.dimcustomerid and b.recordrank = 1;' + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''Load DimCustomerPrivacy'', ''Update Records'', @@Rowcount);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
+ 'INSERT INTO ' + @ClientDB + 'dbo.DimCustomerPrivacy (DimCustomerID, Verified_Consent_TS, Verified_Consent_Source,' + CHAR(13)
+ ' Data_Deletion_Request_TS, Data_Deletion_Request_Reason, Data_Deletion_Request_Source, ' + CHAR(13)
+ ' Subject_Access_Request_TS, Subject_Access_Request_Source,' + CHAR(13)
+ 'Direct_Marketing_OptOut_TS, Direct_Marketing_OptOut_Reason, Direct_Marketing_OptOut_Source, CreatedDate, UpdatedDate)' + CHAR(13)
+ 'SELECT a.DimCustomerID, a.Verified_Consent_TS, a.Verified_Consent_Source,' + CHAR(13)
+ ' a.Data_Deletion_Request_TS, a.Data_Deletion_Request_Reason, a.Data_Deletion_Request_Source, ' + CHAR(13)
+ ' a.Subject_Access_Request_TS, a.Subject_Access_Request_Source,' + CHAR(13)
+ 'a.Direct_Marketing_OptOut_TS, a.Direct_Marketing_OptOut_Reason, a.Direct_Marketing_OptOut_Source, RecordCreatedDate AS CreatedDate, RecordCreatedDate AS UpdatedDate' + CHAR(13)
+ 'FROM '+ @PrivacyLoadView + ' a' + CHAR(13)
+ 'inner join ' + @ClientDb + 'dbo.dimcustomer d' + char(13)
+ 'on a.dimcustomerid = d.dimcustomerid' + char(13)
+ 'LEFT JOIN ' + @ClientDB + 'dbo.DimCustomerPrivacy b' + CHAR(13)
+ 'ON d.dimcustomerid = b.dimcustomerid ' + CHAR(13)
+ 'WHERE b.dimcustomerid IS null and a.recordrank = 1;' + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''Load DimCustomerPrivacy'', ''Insert New Records'', @@Rowcount);'
SET @sql = @sql + CHAR(13) + CHAR(13)

IF @IsDataUploaderSource = 1
Begin
SET @sql = @sql 
+ 'UPDATE a' + CHAR(13)
+ 'SET Processed = 1' + CHAR(13)
+ 'FROM ' + @ClientDB  + @LoadView + ' a' + CHAR(13)
+ 'INNER JOIN ' + @PrivacyLoadView + ' b' + CHAR(13)
+ 'ON a.ssid = b.ssid and a.sourcesystem = b.sourcesystem AND a.sessionid = b.sessionid;' + CHAR(13)
END

SET @sql = @sql 
+'END' + CHAR(13)


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

----SELECT @SQL

EXEC sp_executesql @sql

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
