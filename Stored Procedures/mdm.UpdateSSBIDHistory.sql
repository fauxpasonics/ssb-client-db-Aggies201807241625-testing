SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [mdm].[UpdateSSBIDHistory]  
( 
	@ClientDB VARCHAR(50), 
	@debug int = 0 
) 
AS 
BEGIN 
 
/* mdm.UpdateSSBIDHistory - captures changes in acct and contact id for audit/troubleshooting  
* created: 11/18/2014 kwyss 
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL 
* modified: 09/17/2015 - GHolder -- Applied changes from KWyss which included Azure check for ClientDB parameter and indexing 
* modified: 05/03/2017 - GHolder -- Added houshold IDs 
* 
*/ 
 
--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_TEST', @debug int = 1
 
IF (SELECT @@VERSION) LIKE '%Azure%' 
BEGIN 
SET @ClientDB = '' 
END 
 
IF (SELECT @@VERSION) NOT LIKE '%Azure%' 
BEGIN 
SET @ClientDB = @ClientDB + '.' 
END 
 
DECLARE  
	@sql NVARCHAR(MAX) = ' ' + CHAR(13) 

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
 
SET @sql = @sql 
	+ 'select ssid, sourcesystem, max(createddate) as createddate' + CHAR(13) 
	+ 'into #mostrecent' + CHAR(13) 
	+ 'from ' + @ClientDB + 'mdm.ssb_id_history WITH (NOLOCK)' + CHAR(13) 
	+ 'group by ssid, sourcesystem;' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'CREATE index ix_mostrecent on #mostrecent(ssid, sourcesystem);' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
        
SET @sql = @sql 
	+ 'select distinct dimcust.ssid, dimcust.sourcesystem,' + CHAR(13) 
	+ 'dimcust.SSB_CRMSYSTEM_ACCT_ID, dimcust.SSB_CRMSYSTEM_CONTACT_ID, dimcust.SSB_CRMSYSTEM_PRIMARY_FLAG, CURRENT_TIMESTAMP as createddate,' + CHAR(13) 
	+ 'dimcust.SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG, dimcust.SSB_CRMSYSTEM_HOUSEHOLD_ID, dimcust.SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG' + CHAR(13)
	+ 'INTO #tmpInsert' + CHAR(13) 
	+ 'FROM ' + @ClientDB + 'mdm.ssb_id_history hist WITH (NOLOCK)' + CHAR(13) 
	+ 'inner join #mostrecent b' + CHAR(13) 
	+ 'on hist.ssid = b.ssid' + CHAR(13) 
	+ 'and hist.sourcesystem = b.sourcesystem' + CHAR(13) 
	+ 'and hist.createddate = b.createddate' + CHAR(13) 
	+ 'inner join ' + @ClientDB + 'dbo.dimcustomerssbid dimcust WITH (NOLOCK)' + CHAR(13) 
	+ 'on dimcust.ssid = hist.ssid' + CHAR(13) 
	+ 'and dimcust.sourcesystem = hist.sourcesystem' + CHAR(13) 
	+ 'WHERE 1=1' + CHAR(13)
	+ 'and (isnull(dimcust.SSB_CRMSYSTEM_ACCT_ID, '''') != isnull(hist.ssb_crmsystem_acct_id, '''') ' + CHAR(13) 
	+ 'or dimcust.SSB_CRMSYSTEM_CONTACT_ID != hist.ssb_crmsystem_contact_id ' + Char(13)  
	+ 'or dimcust.ssb_crmsystem_primary_flag != hist.ssb_crmsystem_primary_flag )' + CHAR(13)
	+ 'or isnull(dimcust.SSB_CRMSYSTEM_HOUSEHOLD_ID, '''') != isnull(hist.SSB_CRMSYSTEM_HOUSEHOLD_ID, '''')' + CHAR(13)
	+ 'or isnull(dimcust.SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG, '''') != isnull(hist.SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG, '''');' + CHAR(13)	 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'INSERT into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''SSB Update History'', ''Updated Records'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'INSERT  INTO #tmpInsert' + CHAR(13) 
	+ 'select distinct dimcust.ssid, dimcust.sourcesystem,' + CHAR(13) 
	+ 'dimcust.SSB_CRMSYSTEM_ACCT_ID, dimcust.SSB_CRMSYSTEM_CONTACT_ID, dimcust.SSB_CRMSYSTEM_PRIMARY_FLAG, CURRENT_TIMESTAMP as createddate,' + CHAR(13) 
	+ 'dimcust.SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG, dimcust.SSB_CRMSYSTEM_HOUSEHOLD_ID, dimcust.SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.dimcustomerssbid dimcust WITH (NOLOCK)' + CHAR(13) 
	+ 'left join ' + @ClientDB + 'mdm.ssb_id_history hist WITH (NOLOCK)' + CHAR(13) 
	+ 'on dimcust.ssid = hist.ssid' + CHAR(13) 
	+ 'and dimcust.sourcesystem = hist.sourcesystem' + CHAR(13) 
	+ 'where hist.ssid is null;' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'INSERT into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''SSB Update History'', ''New Records'', @@ROWCOUNT);'  
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ '---- DISABLE INDEXES IF RecordCount in tmpInsert > 10000' + CHAR(13) 
	+ 'IF (SELECT COUNT(0) FROM #tmpInsert) > 1000' + CHAR(13) 
	+ '	EXEC ' + @ClientDB + 'dbo.sp_enableDisableIndexes 0, ''' + @ClientDB + 'mdm.ssb_id_history''' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.SSB_ID_History (SSID, sourcesystem, ssb_crmsystem_acct_id, ssb_crmsystem_contact_id, ssb_crmsystem_primary_flag, createddate, SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG, SSB_CRMSYSTEM_HOUSEHOLD_ID, SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG)' + CHAR(13)
	+ 'SELECT * FROM #tmpInsert;' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'Update a ' + CHAR(13) 
	+ 'set UpdatedDate = current_timestamp '  + CHAR(13) 
	+ 'from ' + @ClientDB + 'dbo.dimcustomerssbid a ' + CHAR(13) 
	+ 'inner join #tmpInsert b ' + CHAR(13) 
	+ 'on a.ssid = b.ssid and a.sourcesystem = b.sourcesystem;' + CHAR(13) 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
  
SET @sql = @sql        
	+ '---- ReEnable INDEXES IF RecordCount in tmpInsert > 10000' + CHAR(13) 
	+ 'IF (SELECT COUNT(0) FROM #tmpInsert) > 1000' + CHAR(13) 
	+ '	EXEC ' + @ClientDB + 'dbo.sp_enableDisableIndexes 1, ''' + @ClientDB + 'mdm.ssb_id_history''' 
SET @sql = @sql + CHAR(13) + CHAR(13) 

If @debug = 1 
Begin 
	SELECT @sql	 
end 
else  
Begin 
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

	EXEC sp_executesql @sql 
End 

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
