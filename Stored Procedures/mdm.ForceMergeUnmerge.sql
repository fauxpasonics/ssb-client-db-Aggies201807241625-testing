SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [mdm].[ForceMergeUnmerge]  
( 
	@ClientDB VARCHAR(50) 
) 
AS 
Begin 
 
/* mdm.ForceMergeUnmerge - Merges/Unmerges Contact Records. 
* created: 12/11/2014 kwyss 
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL 
* modified: 09/17/2015 - GHolder -- Added Azure check for @ClientDB parameter 
* 
*/ 
 
 
 
 
---DECLARE @ClientDB VARCHAR(50) = 'RAIDERS' 
 
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
 
+ '---unmerge records' + CHAR(13) + CHAR(13) 
 
	+'IF OBJECT_ID(''tempdb..#tmp_forceunmerge'') IS NOT NULL' + CHAR(13) 
	+'DROP TABLE #tmp_forceunmerge;' + CHAR(13)+ CHAR(13) 
 
+' SELECT DISTINCT ssbid.dimcustomerid, ssb_crmsystem_contact_id, forced_contact_id' + CHAR(13) 
+' INTO #tmp_forceunmerge' + CHAR(13) 
+' FROM ' + @ClientDB + 'dbo.dimcustomerssbid ssbid' + CHAR(13) 
+' inner JOIN ' + @ClientDB + 'mdm.forceunmergeids f' + CHAR(13) 
+' on ssbid.dimcustomerID = f.dimcustomerid' + CHAR(13) 
+' WHERE ssb_crmsystem_contact_id !=  forced_contact_id;' + CHAR(13) + CHAR(13) 
 
+' Update ssbid' + CHAR(13) 
+' set ssbid.SSB_CRMSYSTEM_CONTACT_ID = forced_contact_id' + CHAR(13) 
+' from ' + @ClientDB + 'dbo.dimcustomerssbid ssbid' + CHAR(13) 
+' inner join #tmp_forceunmerge f' + CHAR(13) 
+' on ssbid.dimcustomerID = f.dimcustomerid;' + CHAR(13) + CHAR(13) 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt) values (current_timestamp, ''Force Merge Contacts'', ''Force UnMerge Source Records'', @@rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' UPDATE b' + CHAR(13) 
	+ ' SET b.SSB_CRMSYSTEM_CONTACT_ID = a.forced_contact_id' 
	+ ' FROM #tmp_forceunmerge a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_ssbid_Contact b ON a.dimcustomerid = b.dimcustomerid' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
+' DELETE a ' + CHAR(13) 
+' FROM ' + @ClientDB + 'MDM.downstream_bucketting a ' + CHAR(13) 
+' INNER JOIN #tmp_forceunmerge b ' + CHAR(13)  
+' ON a.old = b.forced_contact_id OR a.new = b.SSB_CRMSYSTEM_CONTACT_ID ' + CHAR(13) 
+' WHERE actiontype = ''Contact Merge'' AND mdm_run_dt >= (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog  ' + CHAR(13) 
+' 	WHERE mdm_process = ''SSB Contact'' AND process_step = ''Full Refresh'') ' + CHAR(13) + CHAR(13) 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
+' INSERT INTO ' + @ClientDB + 'mdm.downstream_bucketting (new, old, actiontype, processed, mdm_run_dt, dimcustomerid)' + CHAR(13) 
+' SELECT forced_contact_id  AS new, ssb_crmsystem_contact_id AS old, actiontype = ''Forced Contact Split'',' + CHAR(13) 
+' 0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, dimcustomerid' + CHAR(13) 
+' FROM #tmp_forceunmerge' + CHAR(13) 
+' UNION ALL' + CHAR(13) 
+' SELECT a.ssb_crmsystem_contact_id AS new, a.ssb_crmsystem_contact_id AS old, actiontype = ''Forced Contact Split'',' + CHAR(13) 
+' 0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, a.dimcustomerid' + CHAR(13) 
+' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13) 
+' INNER JOIN #tmp_forceunmerge b' + CHAR(13) 
+' ON a.ssb_crmsystem_contact_id = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) 
+' ORDER BY old;' + CHAR(13) 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
 
SET @sql = @sql 
	+ '---merge records' + CHAR(13) 
	 
	+'IF OBJECT_ID(''tempdb..#tmp_forcemerge'') IS NOT NULL' + CHAR(13) 
	+'DROP TABLE #tmp_forcemerge;' + CHAR(13)+ CHAR(13) 
 
+'SELECT DISTINCT ssbid.dimcustomerid, ssb_crmsystem_contact_id,  w.winner_contact_id' + CHAR(13) 
+'INTO #tmp_forcemerge' + CHAR(13) 
+'FROM ' + @ClientDB + 'dbo.dimcustomerssbid ssbid' + CHAR(13) 
+'inner join (' + CHAR(13) 
+'select winning_dimcustomerid, losing_dimcustomerid, ssbid.dimcustomerid, ssbid.SSB_CRMSYSTEM_CONTACT_ID as loser' + CHAR(13) 
+'from ' + @ClientDB + 'mdm.forcemergeids f' + CHAR(13) 
+'inner join ' + @ClientDB + 'dbo.dimcustomerssbid ssbid ' + CHAR(13) 
+'on f.losing_dimcustomerid = ssbid.dimcustomerid' + CHAR(13) 
+') l' + CHAR(13) 
+'on ssbid.SSB_CRMSYSTEM_CONTACT_ID = l.loser' + CHAR(13) 
+'inner join (' + CHAR(13) 
+'select winning_dimcustomerid, losing_dimcustomerid, ssbid.dimcustomerid, ssbid.SSB_CRMSYSTEM_CONTACT_ID as winner_contact_id ' + CHAR(13) 
+'from ' + @ClientDB + 'mdm.forcemergeids f' + CHAR(13) 
+'inner join ' + @ClientDB + 'dbo.dimcustomerssbid ssbid ' + CHAR(13) 
+'on f.winning_dimcustomerid = ssbid.dimcustomerid' + CHAR(13) 
+') w' + CHAR(13) 
+'on l.winning_dimcustomerid = w.winning_dimcustomerid' + CHAR(13) 
+'where w.winner_contact_id != SSB_CRMSYSTEM_CONTACT_ID;' + CHAR(13)  + CHAR(13) 
 
 
 
+'UPDATE ssbid' + CHAR(13) 
+'set ssbid.SSB_CRMSYSTEM_CONTACT_ID = w.winner_contact_id' + CHAR(13) 
+'from ' + @ClientDB + 'dbo.dimcustomerssbid ssbid' + CHAR(13) 
+'inner join #tmp_forcemerge w' + CHAR(13) 
+'on ssbid.dimcustomerid = w.dimcustomerid' + CHAR(13)  + CHAR(13) 
 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt) values (current_timestamp, ''Force Merge Contacts'', ''Force Merge Contacts'', @@rowcount);' + CHAR(13) + CHAR(13) 
 
	+ ' UPDATE b' + CHAR(13) 
	+ ' SET b.SSB_CRMSYSTEM_CONTACT_ID = a.winner_contact_id' + CHAR(13) 
	+ ' FROM #tmp_forcemerge a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_ssbid_Contact b ON a.dimcustomerid = b.dimcustomerid' 
SET @sql = @sql + CHAR(13) + CHAR(13) 
 
 
+'DELETE a ' + CHAR(13) 
+'FROM ' + @ClientDB + 'MDM.downstream_bucketting a' + CHAR(13) 
+'INNER JOIN #tmp_forcemerge b' + CHAR(13) 
+'ON a.old = b.winner_contact_id OR a.new = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) 
+'WHERE actiontype = ''Contact Split'' AND mdm_run_dt >= (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog ' + CHAR(13) 
+'	WHERE mdm_process = ''SSB Contact'' AND process_step = ''Full Refresh'')' + CHAR(13)  + CHAR(13) 
 
 
+'INSERT INTO ' + @ClientDB + 'mdm.downstream_bucketting (new, old, actiontype, processed, mdm_run_dt, dimcustomerid)' + CHAR(13) 
+'SELECT DISTINCT winner_contact_id  AS new, ssb_crmsystem_contact_id AS old, actiontype = ''Forced Contact Merge'',' + CHAR(13) 
+'0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, dimcustomerid' + CHAR(13) 
+'FROM #tmp_forcemerge' + CHAR(13) 
+'UNION ' + CHAR(13) 
+'SELECT DISTINCT winner_contact_id  AS new, a.ssb_crmsystem_contact_id AS old, actiontype = ''Forced Contact Merge'',' + CHAR(13) 
+'0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, a.dimcustomerid' + CHAR(13) 
+'FROM  #tmp_forcemerge b' + CHAR(13) 
+'inner join ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13) 
+'ON  a.ssb_crmsystem_contact_id = b.winner_contact_id and a.DimCustomerId != b.DimCustomerId' + CHAR(13) 
+'ORDER BY old;' + CHAR(13) + CHAR(13) 
 
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
GO
