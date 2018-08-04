SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
 
 
CREATE procedure [mdm].[ForceMergeUnmergeHousehold] 
( 
	@ClientDB VARCHAR(50) 
) 
 as 
Begin 
 
/* mdm.ForceMergeUnmergeHousehold - Merges/Unmerges Household Records. 
* created: 4/1/2015 kwyss 
* modified: 09/17/2015 - GHolder -- Added Azure check for @ClientDB parameter 
* 
* 
*/ 
 
--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_TEST' 
 
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
 
+'IF OBJECT_ID(''tempdb..#tmp_forceHousehold'') IS NOT NULL' + CHAR(13) 
	+'DROP TABLE #tmp_forceHousehold;' + CHAR(13)+ CHAR(13)   
	+'SELECT a.dimcustomerid, a.ssb_crmsystem_contact_id, a.SSB_CRMSYSTEM_HOUSEHOLD_ID, b.groupingid' + CHAR(13) 
	+'into #tmp_forceHousehold' 
	+ CHAR(13) +'	FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13) 
	+'	INNER JOIN ' + @ClientDB + 'mdm.ForceHouseholdGrouping b' + CHAR(13) 
	+'	ON a.dimcustomerid = b.dimcustomerid' + CHAR(13) 
	+'	where groupingid != isnull(a.SSB_CRMSYSTEM_HOUSEHOLD_ID, '''')' + CHAR(13) + CHAR(13)   
	
	 +'UPDATE a' + CHAR(13) +'SET SSB_CRMSYSTEM_HOUSEHOLD_ID = GroupingId' + CHAR(13) 
	 +'FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13) 
	 +'INNER JOIN #tmp_forceHousehold c' + CHAR(13) 
	 +'ON a.SSB_CRMSYSTEM_CONTACT_ID = c.ssb_crmsystem_contact_id;' + CHAR(13) + CHAR(13)   


+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
+ 'values (current_timestamp, ''Force Unmerge/Merge Households'', ''Force Households'', @@ROWCOUNT);' + CHAR(13) 

 + 'DELETE a' + CHAR(13) + '---select distinct a.* ' + CHAR(13) 
 + 'FROM ' + @ClientDB + 'MDM.downstream_bucketting a' + CHAR(13)
  + 'INNER JOIN #tmp_forceHousehold b' + CHAR(13) + 'ON a.old = b.groupingID OR a.new = b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13) 
  + 'WHERE actiontype like ''Household%'' AND mdm_run_dt >= (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog ' + CHAR(13) 
  + '	WHERE mdm_process = ''SSB Household'' AND process_step = ''Full Refresh'')' + CHAR(13)   
  
  + 'INSERT INTO ' + @ClientDB + 'mdm.downstream_bucketting (new, old, actiontype, processed, mdm_run_dt, dimcustomerid)' + CHAR(13) 
  + 'SELECT GROUPINGID  AS new, ssb_crmsystem_HOUSEHOLD_id AS old, actiontype = ''Forced Household Grouping'',' + CHAR(13) 
  + '0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, dimcustomerid' + CHAR(13) 
  + 'FROM #tmp_forceHousehold' + CHAR(13) 
  + 'UNION ALL' + CHAR(13) 
  + 'SELECT a.ssb_crmsystem_HOUSEHOLD_id  AS new, b.ssb_crmsystem_HOUSEHOLD_id AS old, actiontype = ''Forced Household Grouping'',' 
  + CHAR(13) + '0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, a.dimcustomerid' + CHAR(13) 
  + 'FROM  #tmp_forceHousehold b' + CHAR(13)
   + 'inner join ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13)
    + 'ON  a.ssb_crmsystem_household_id = b.ssb_crmsystem_household_id and a.DimCustomerId != b.DimCustomerId' + CHAR(13) 
	+ 'ORDER BY old;' + CHAR(13)  
 
 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
+ 'update ' + @ClientDB + 'dbo.dimcustomerssbid ' + CHAR(13)  
		+ 'set SSB_CRMSYSTEM_HOUSEHOLD_ID = isnull(SSB_CRMSYSTEM_HOUSEHOLD_ID, ssb_crmsystem_contact_id)' + CHAR(13)  
		+ 'where isnull(SSB_CRMSYSTEM_HOUSEHOLD_ID, '''') != isnull(SSB_CRMSYSTEM_HOUSEHOLD_ID, ssb_crmsystem_contact_id);' + CHAR(13) + CHAR(13)  
  
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ 'values (current_timestamp, ''SSB HOUSEHOLD ID'', ''Update SSB_CRMSYSTEM_HOUSEHOLD_ID'', @@ROWCOUNT);'  
 

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

---Select @sql 
 
EXEC sp_executesql @sql 

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
 
END
GO
