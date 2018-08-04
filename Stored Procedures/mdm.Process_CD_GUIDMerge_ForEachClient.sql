SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[Process_CD_GUIDMerge_ForEachClient]   
AS    
BEGIN   
   
	DECLARE 
		@sql NVARCHAR(MAX) = ''   
		,@mdm_process VARCHAR(50) = ''
			
	IF OBJECT_ID('tempdb..##staleContactGUID') IS NOT NULL   
		DROP TABLE ##staleContactGUID   
   
	SELECT DISTINCT ContactGUID_Loser   
	INTO ##staleContactGUID   
	FROM mdm.CD_ContactGUIDMerge   
   
	CREATE CLUSTERED INDEX ix_contactguid ON ##staleContactGUID (ContactGUID_Loser)   

	IF OBJECT_ID('tempdb..##staleFuzzyNameGUID') IS NOT NULL   
		DROP TABLE ##staleFuzzyNameGUID   
   
	SELECT DISTINCT FuzzyNameGUID_Loser   
	INTO ##staleFuzzyNameGUID   
	FROM mdm.CD_FuzzyNameGUIDMerge   
   
	CREATE CLUSTERED INDEX ix_fuzzynameguid ON ##staleFuzzyNameGUID (FuzzyNameGUID_Loser)  
   
	SET @mdm_process = 'Process CD ContactGUID Merge'
	SET @sql = ''   
		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''Start'', 0);' + CHAR(13) + CHAR(13)	   

		+ '	-- Exclude records that have been deleted or have either a pending or completed privacy-related data deletion request - these should not run through CDIO' + CHAR(13) 
		+ ' UPDATE b' + CHAR(13)   
		+ ' SET b.NameIsCleanStatus = ''Dirty''' + CHAR(13)   
		+ ' FROM ##staleContactGUID a' + CHAR(13)   
		+ ' INNER JOIN dbo.DimCustomer b ON a.ContactGUID_Loser = b.ContactGUID' + CHAR(13)   
		+ ' LEFT join dbo.dimcustomerssbid d'
		+ ' ON b.dimcustomerid = d.dimcustomerid ' + CHAR(13)
		+ ' LEFT JOIN (Select ssb_crmsystem_contact_id, data_deletion_completed_ts from '
		 + 'dbo.DimCustomerPrivacy p inner join dbo.dimcustomerssbid ssb on p.dimcustomerid = ssb.dimcustomerid) c' + CHAR(13)
		+ ' on d.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id ' + CHAR(13)
		+ 'WHERE 1=1 and c.data_deletion_completed_ts is null ' + CHAR(13) 
		+ ' AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13) + CHAR(13) 

		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''Set NameIsCleanStatus to Dirty'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	   
   
		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''End'', 0);' + CHAR(13) + CHAR(13)	 
		
	SET @mdm_process = 'Process CD FuzzyNameGUID Merge'
	SET @sql = @sql + ''   
		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''Start'', 0);' + CHAR(13) + CHAR(13)	   
   
		+ '	-- Exclude records that have been deleted or have either a pending or completed privacy-related data deletion request - these should not run through CDIO' + CHAR(13) 
		+ ' UPDATE b' + CHAR(13)   
		+ ' SET b.NameIsCleanStatus = ''Dirty''' + CHAR(13)   
		+ ' FROM ##staleFuzzyNameGUID a' + CHAR(13)   
		+ ' INNER JOIN dbo.DimCustomer b ON a.FuzzyNameGUID_Loser = b.FuzzyNameGUID' + CHAR(13)   
		+ ' LEFT join dbo.dimcustomerssbid d'
		+ ' ON b.dimcustomerid = d.dimcustomerid ' + CHAR(13)
		+ ' LEFT JOIN (Select ssb_crmsystem_contact_id, data_deletion_completed_ts from '
		 +'dbo.DimCustomerPrivacy p inner join dbo.dimcustomerssbid ssb on p.dimcustomerid = ssb.dimcustomerid) c' + CHAR(13)
		+ ' on d.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id ' + CHAR(13)
		+ 'WHERE 1=1 and c.data_deletion_completed_ts is null ' + CHAR(13) 
		+ ' AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13)   + CHAR(13) 

		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''Set NameIsCleanStatus to Dirty'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	   
   
		+ '	INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
		+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''End'', 0);' + CHAR(13) + CHAR(13)	 

	----SELECT @sql   
	EXEC mdm.ExecuteSQL_ForEachClient @sql = @sql,
		                                @mdm_process = 'Process CD GUID Merge'
		  
END
GO
