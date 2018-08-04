SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[LoadDimCustomer_ChangeLog] 
(
	@ClientDB VARCHAR(50),
	@LoadGuid VARCHAR(50),
	@LogLevel INT
)
AS
BEGIN


/*[etl].[LoadDimCustomer] 
* created: 7/2/2015 - Kwyss - dynamic sql procedure to load data to dimcustomer.   Pass in client db name and view to load from.
* modified: 10/15/2015 - GHolder
* Log Levels - 0 = none; 1 = record; 2 = detail
*
*/

-- TESTING
--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV', @LoadGuid VARCHAR(50) = '7A330C9CD16E46EBBF24C2C049FD80CA', @LogLevel INT = 1

-- Remove square brackets
SELECT @ClientDB = REPLACE(REPLACE(@ClientDB,'[',''),']','')

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

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''

IF @LogLevel >= 1
BEGIN
	/*Insert records with changes into change log*/
	SET @sql =
		+ CHAR(13)
		+' ALTER TABLE ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + ' ADD CONSTRAINT pk_dimcust_' + @LoadGuid + ' Primary Key Clustered (dimcustomerid);' + CHAR(13)
		+' ALTER TABLE ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + ' ADD CONSTRAINT pk_changes_' + @LoadGuid + ' Primary Key Clustered (dimcustomerid);' + CHAR(13)
		+ CHAR(13)
		
	EXEC sp_executesql @sql;

	SET @sql =
		+ CHAR(13)
		+' INSERT INTO ' + @ClientDB + 'audit.ChangeLog' + CHAR(13)
		+' SELECT a.dimcustomerid' + CHAR(13)
		+' , ''Incoming Record''' + CHAR(13)
		+' , ''DataLoad''' + CHAR(13)
		+' , dbo.fnStripLowAscii(Replace((SELECT dimcustomer.*' + CHAR(13)
		+ ' FROM ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + ' as dimcustomer WHERE dimcustomerid = a.dimcustomerid FOR XML AUTO, ELEMENTS XSINIL), ''&'', ''&amp;'')) AS xmldata  ' + CHAR(13)
		+' , a.ChangedOn' + CHAR(13)
		+' FROM  ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + ' a' + CHAR(13)

		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ 'values (current_timestamp, ''Load DimCustomer'', ''Load audit.ChangeLog'', @@ROWCOUNT);'
	SET @sql = @sql + CHAR(13) + CHAR(13)	

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
END

---SELECT @sql

EXEC sp_executesql @sql;

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
