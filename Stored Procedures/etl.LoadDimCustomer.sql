SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [etl].[LoadDimCustomer]  
( 
	@ClientDB VARCHAR(50), 
	@LoadView VARCHAR(100), 
	@LogLevel varchar(10), 
	@DropTemp varchar(10), 
	@IsDataUploaderSource varchar(10) = '0' 
) 
AS 
BEGIN 
 
/*[etl].[LoadDimCustomer]  
* created: 7/2/2015 - Kwyss - dynamic sql procedure to load data to dimcustomer.   Pass in client db name and view to load from. 
* Log Levels - 0 = none; 1 = record; 2 = detail 
* 
*/ 
 
-- TESTING 
--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV', @LoadView VARCHAR(100) = 'MDM_CLIENT_DEV.api.UploadDimCustomerStaging', @LogLevel varchar(10) = '0', @DropTemp varchar(10) = '1', @IsDataUploaderSource varchar(10) = '1' 
 
-- Remove square brackets 
SELECT @ClientDB = REPLACE(REPLACE(@ClientDB,'[',''),']','') 
SELECT @LoadView = REPLACE(REPLACE(@LoadView,'[',''),']','') 
 
-- Remove database name from @LoadView 
SELECT @LoadView = CASE WHEN LEFT(@LoadView,LEN(@ClientDB + '.')) = @ClientDB + '.' THEN REPLACE(@LoadView, @ClientDB + '.', '') ELSE @LoadView END	 
 
DECLARE @LoadGuid VARCHAR(50) = REPLACE(NEWID(), '-', ''); 
 
 
 
DECLARE  
	@sql NVARCHAR(MAX) = '' 

SET @sql = @sql  
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Load view -' + @LoadView + ''', 0);' + CHAR(13) + CHAR(13) 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
 
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Load Guid -' + @LoadGuid + ''', 0);' + CHAR(13)  + CHAR(13)  

	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Log level - ' + @LogLevel + ''', 0);' + CHAR(13) + CHAR(13)  

	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Drop temp - ' + @DropTemp + ''', 0);' + CHAR(13) + CHAR(13)  

	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Data uploader source - ' + @IsDataUploaderSource + ''', 0);' + CHAR(13) + CHAR(13)  

SET @sql = @sql + CHAR(13) + CHAR(13) 
 
 
DECLARE @recordcount int = 1 
DECLARE @countsql nVARCHAR(1000)  
 
IF CAST(@IsDataUploaderSource AS BIT) = 1  
Begin 
	SET @countsql = 'SELECT @recordcount =  COUNT(0) FROM '+ @ClientDB + '.' + @LoadView + ' WHERE processed = 0' 
	 EXEC sp_executesql @countsql  , N'@recordcount Int OUTPUT' , @recordcount  OUTPUT 
	---PRINT @recordcount 
	IF @RecordCount = 0 
	BEGIN  
	SET @sql = @sql 
 
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''No Records to Load'', 0);' 
	+ CHAR(13) + CHAR(13) 
	+ ' PRINT '' DimCustomerPrivacy '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomerPrivacy @clientdb = ''' + @ClientDB + ''', @LoadGuid = ''' + @LoadGuid + ''', @Loadview = ''' + @LoadView + ''',  @LogLevel = ' + @LogLevel  + ',  @IsDataUploaderSource  = ''' + @IsDataUploaderSource  + '''' + CHAR(13) 
+ CHAR(13) 
	SET @sql = @sql + CHAR(13) + CHAR(13) 
	 
	END 
End 
 
 
IF @RecordCount >= 1 
Begin 
 
SET @sql = @sql 
+ ' PRINT '' Create Temp Tables '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_CreateTempTables @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + ', @IsDataUploaderSource = ''' + @IsDataUploaderSource  + '''' + CHAR(13) 
 
SET @LoadView = 'etl.tmp_load_' + @LoadGuid 
 
SET @sql = @sql 
+ ' PRINT '' NameChanges '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_NameChanges @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + CHAR(13) 
+ ' PRINT '' Address Changes '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_AddressChanges @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + CHAR(13) 
+ ' PRINT '' Phone Changes '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_PhoneChanges @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + CHAR(13) 
+ ' PRINT '' Email Changes '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_EmailChanges @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + CHAR(13) 
+ ' PRINT '' Attribute Changes '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_AttributeChanges @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + ''', @LogLevel = ' + @LogLevel + CHAR(13) 
+ ' PRINT '' Load New '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_LoadNew @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + '''' + CHAR(13) 
+ ' PRINT '' Change Log '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_ChangeLog @clientdb = ''' + @ClientDB + ''', @LoadGuid = ''' + @LoadGuid + ''',  @LogLevel = ' + @LogLevel  + CHAR(13) 
+ ' PRINT '' DimCustomerAttributes '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomerAttributes @clientdb = ''' + @ClientDB + ''', @Loadview = ''' + @LoadView + ''',  @LogLevel = ' + @LogLevel  + ',  @IsDataUploaderSource  = ''' + @IsDataUploaderSource  + '''' + CHAR(13) 
+ CHAR(13) 
+ ' PRINT '' copy source '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_CopySource @clientdb = ''' + @ClientDB + ''',  @loadview =''' + @LoadView + ''', @LoadGuid = ''' + @LoadGuid + '''' + CHAR(13) 
+ CHAR(13) 
+ ' PRINT '' DimCustomerPrivacy '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomerPrivacy @clientdb = ''' + @ClientDB + ''', @LoadGuid = ''' + @LoadGuid + ''', @Loadview = ''' + @LoadView + ''',  @LogLevel = ' + @LogLevel  + ',  @IsDataUploaderSource  = ''' + @IsDataUploaderSource  + '''' + CHAR(13) 
+ CHAR(13) 
 
--SET @sql = @sql  
--	+ 'DELETE b' + CHAR(13) 
--	+ '--SELECT *' + CHAR(13) 
--	+ 'FROM ' + @ClientDB + '.' + @LoadView + ' a' + CHAR(13) 
--	+ 'INNER JOIN ' + @ClientDB + '.dbo.CD_DimCustomer b ON a.SSID = b.SSID' + CHAR(13) 
--	+ '	AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
--SET @sql = @sql + CHAR(13) + CHAR(13) 
 
--SET @sql = @sql  
--	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
--	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Purge CD_DimCustomer - delete stale records'', @@Rowcount);' 
--SET @sql = @sql + CHAR(13) + CHAR(13)	 
+ ' PRINT '' delete master_dimcustomer deltas '''+ CHAR(13) 
SET @sql = @sql  
	+ 'DELETE b' + CHAR(13) 
	+ '--SELECT *' + CHAR(13) 
	+ 'FROM ' + @ClientDB + '.' + @LoadView + ' a' + CHAR(13) 
	+ 'INNER JOIN ' + @ClientDB + '.dbo.Master_DimCustomer_Deltas b ON a.SSID = b.SSID' + CHAR(13) 
	+ '	AND a.SourceSystem = b.SourceSystem' + CHAR(13) 
	+ 'WHERE 1=1' + CHAR(13) 
	+ 'AND b.ProcessedDate IS NULL' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql  
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''Load DimCustomer'', ''Purge Master_DimCustomer_Deltas - delete stale records'', @@Rowcount);' 
SET @sql = @sql + CHAR(13) + CHAR(13)	 
 
IF CAST(@IsDataUploaderSource AS BIT) = 1 
BEGIN 
 
	-- Mark applicable records in Data Uploader staging table as processed 
	SET @sql = @sql 
	+ ' PRINT '' update processed '''+ CHAR(13) 
	+' UPDATE b' + CHAR(13) 
	+' SET Processed = 1' + CHAR(13) 
	+' FROM ' + @ClientDB + '.' + @LoadView + ' a' + CHAR(13) 
	+' INNER JOIN ' + @ClientDB + '.api.UploadDimCustomerStaging b on a.SessionId = b.SessionId' + CHAR(13) 
	+'	AND a.SSID = b.SSID' + CHAR(13) 
	+'	AND a.SourceSystem = b.SourceSystem' 
	+ CHAR(13) + CHAR(13) 
END 
 
 
IF @DropTemp = 1  
BEGIN 
SET @sql = @sql 
+ ' PRINT '' Drop Temp Tables '''+ CHAR(13) 
+ 'EXEC etl.LoadDimCustomer_DropTempTable @clientdb = ''' + @ClientDB + ''', @LoadGuid = ''' + @LoadGuid + ''',  @LogLevel = ' + @LogLevel  + CHAR(13) 
END 
 
END 

SET @sql = @sql
	+ 'DECLARE @startDate DATE = CAST(GETDATE() AS DATE)'
	+ 'EXEC mdm.UpdateStandardLoadAuditLog @ClientDB = ''' + @ClientDB + ''', @startDate = @startDate' + CHAR(13) + CHAR(13)

-- Add TRY/CATCH block to force stoppage and log error      
SET @sql = ''     
	+ ' BEGIN TRY' + CHAR(13)      
		+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)
		+ @sql  
		+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);'
	+ ' END TRY' + CHAR(13)     
	+ ' BEGIN CATCH' + CHAR(13)     
	+ '		DECLARE @ErrorMessage NVARCHAR(92)' + CHAR(13)     
	+ '			, @ErrorSeverity INT' + CHAR(13)     
	+ '			, @ErrorState INT' + CHAR(13) + CHAR(13)     
     
	+ '		SELECT @ErrorMessage = LEFT(ERROR_MESSAGE(), 92)' + CHAR(13)      
	+ '			, @ErrorSeverity = ERROR_SEVERITY()' + CHAR(13)      
	+ '			, @ErrorState = ERROR_STATE()' + CHAR(13) + CHAR(13)     
     
	+ '		INSERT INTO ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ '		VALUES (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)     
     
	+ '		RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)     
	+ '             @ErrorSeverity, -- Severity.' + CHAR(13)     
	+ '             @ErrorState -- State.' + CHAR(13)     
	+ '             );' + CHAR(13)     
	+ ' END CATCH' + CHAR(13) + CHAR(13)  
 
----SELECT @sql 
EXEC sp_executesql @sql; 
 
END
GO
