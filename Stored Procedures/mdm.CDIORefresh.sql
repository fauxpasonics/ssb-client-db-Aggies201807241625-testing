SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [mdm].[CDIORefresh]  
( 
	@RefreshFrequency VARCHAR(10) = 'Weekly' -- Accepted values: Weekly, Daily ---- Weekly = 1/12th of stale data; Daily = 1/90th of stale data 
	,@CreateDefaultWeeklySchedules BIT = 1 
) 
AS 
BEGIN   
 
	DECLARE @sql NVARCHAR(MAX) = '', @MDM_DB VARCHAR(50) = '' --/**TESTING**/, @RefreshFrequency VARCHAR(10) = 'Weekly', @CreateDefaultWeeklySchedules BIT = 0 -- Accepted values: Weekly, Daily ---- Weekly = 1/12th of stale data; Daily = 1/90th of stale data 
 
	IF (SELECT @@VERSION) LIKE '%Azure%'     
		SET @MDM_DB = ''     
	ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'     
		SET @MDM_DB = DB_NAME() + '.'     
 
 
	IF OBJECT_ID('tempdb..#stale') IS NOT NULL  
		DROP TABLE #stale 
 
	CREATE TABLE #stale (DimCustomerId INT, UpdatedDate DATETIME NULL) 
 
	SET @sql = @sql 
		+ ' DECLARE @ID INT, @staleGroupingCnt INT = 0, @maxRefreshCutoff INT = 0, @rankingCutoff INT = 0' + CHAR(13) + CHAR(13) 
 
		-- Create default Weekly refresh schedule for client when no schedule has been defined 
		+ ' IF (''' + @RefreshFrequency + ''' = ''Weekly'' AND ' + CAST(@CreateDefaultWeeklySchedules AS VARCHAR(1)) + ' = 1)' + CHAR(13) 
		+ ' BEGIN' + CHAR(13) 
		+ ' 	INSERT INTO ' + @MDM_DB + 'mdm.ClientRefreshConfig (ClientName, RefreshFrequency, RefreshDay, RefreshStartDate, Active)' + CHAR(13) 
		+ ' 	SELECT a.ClientName, ''' + @RefreshFrequency + ''' AS RefreshFrequency, DATENAME(WEEKDAY,GETDATE()) AS RefreshDay, CAST(GETDATE() AS DATE) AS RefreshStartDate, CAST(1 AS BIT) AS Active' + CHAR(13) 
		+ ' 	FROM (' + CHAR(13) 
		+ ' 		SELECT DB_NAME() AS ClientName' + CHAR(13) 
		+ ' 	) a' + CHAR(13) 
		+ ' 	LEFT JOIN (' + CHAR(13) 
		+ ' 		SELECT *' + CHAR(13) 
		+ ' 		FROM ' + @MDM_DB + 'mdm.ClientRefreshConfig a' + CHAR(13) 
		+ ' 		WHERE ClientName = DB_NAME()' + CHAR(13) 
		+ ' 	) b ON a.ClientName = b.ClientName' + CHAR(13) 
		+ ' 	WHERE 1=1' + CHAR(13) 
		+ ' 	AND b.ID IS NULL' + CHAR(13) + CHAR(13) 
 
		+ '		IF @@ROWCOUNT > 0' + CHAR(13) 
		+ '			PRINT DB_NAME() + '' - Default weekly schedule created in ' + @MDM_DB + '.mdm.ClientRefreshConfig.''' + CHAR(13)  
		+ ' END' + CHAR(13) + CHAR(13) 
 
		-- If schedule has not previously run for today, and is not currently running, get its ID
		+ ' SELECT @ID = ID' + CHAR(13) 
		+ ' FROM ' + @MDM_DB + 'mdm.ClientRefreshConfig' + CHAR(13) 
		+ ' WHERE 1=1' + CHAR(13) 
		+ ' AND ClientName = DB_NAME()' + CHAR(13) 
		+ ' AND RefreshFrequency = ''' + @RefreshFrequency + '''' + CHAR(13) 
		+ ' AND Active = 1' + CHAR(13) 
		+ ' AND ISNULL(RefreshDay,'''') = CASE WHEN RefreshFrequency = ''Weekly'' THEN DATENAME(WEEKDAY,GETDATE()) ELSE ISNULL(RefreshDay,'''') END' + CHAR(13) 
		--+ ' AND DATEDIFF(HOUR,ISNULL(LastRefreshDate,''1/1/1900''),GETDATE()) > 24' + CHAR(13)  
		+ ' AND CAST(GETDATE() AS DATE) != ISNULL((SELECT MAX(logdate) FROM mdm.auditlog WITH (NOLOCK) WHERE mdm_process = ''CDIO Refresh''), ''1900-01-01'')' + CHAR(13) + CHAR(13) 
 
		+ ' IF ISNULL(@ID,0) = 0' + CHAR(13) 
		+ '		RETURN' + CHAR(13) 
		+ ' ELSE' + CHAR(13) 
		+ ' BEGIN' + CHAR(13) 
		+ '		INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ '		VALUES (current_timestamp, ''CDIO Refresh'', ''Start'', 0);' + CHAR(13) + CHAR(13)	 
 
		+ '		INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ '		VALUES (current_timestamp, ''CDIO Refresh'', ''RefreshFrequency: ' + @RefreshFrequency + ''', 0);' + CHAR(13) + CHAR(13)	 
		  
		+ '		TRUNCATE TABLE #stale' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT @maxRefreshCutoff = CEILING(COUNT(0)/CAST(CASE WHEN ''' + @RefreshFrequency + ''' = ''Weekly'' THEN 12 WHEN ''' + @RefreshFrequency + ''' = ''Daily'' THEN 90 END AS FLOAT))' + CHAR(13) 
		+ '		FROM dbo.DimCustomer WITH (NOLOCK)' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND ISNULL(IsDeleted,0) = 0' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get records that have not been sent to CD in the last 90 days' + CHAR(13) 
		+ '		INSERT INTO #stale' + CHAR(13) 
		+ '		SELECT a.DimCustomerId, a.UpdatedDate' + CHAR(13) 
		+ '		FROM dbo.vw_CD_DimCustomer a' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND DATEDIFF(DAY,a.UpdatedDate,GETDATE()) >= 90' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get records that have NEVER been sent to CD - OR - records that were cleansed/created prior to existence of dbo.CD_DimCustomer (these are OLDER than 90 days)' + CHAR(13) 
		+ '		INSERT INTO #stale (DimCustomerId)' + CHAR(13) 
		+ '		SELECT a.DimCustomerId' + CHAR(13) 
		+ '		FROM dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13) 
		+ '		LEFT JOIN dbo.vw_CD_DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND b.DimCustomerId IS NULL' + CHAR(13) + CHAR(13) 
 
		+ '		-- Delete stale records where IsDeleted is True' + CHAR(13) 
		+ '		DELETE a' + CHAR(13) 
		+ '		FROM #stale a' + CHAR(13) 
		+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND ISNULL(b.IsDeleted,0) = 1' + CHAR(13) + CHAR(13) 
 
		+ '		-- Delete stale records that are Dirty - these will go through MDM automatically' + CHAR(13) 
		+ '		DELETE a' + CHAR(13) 
		+ '		FROM #stale a' + CHAR(13) 
		+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND b.NameIsCleanStatus = ''Dirty''' + CHAR(13) + CHAR(13) 

		+ '		-- Delete stale records that have either a pending or completed privacy-related data deletion request - these should not run through CDIO' + CHAR(13) 

		+ '		DELETE a' + CHAR(13) 
		+ '		FROM #stale a' + CHAR(13) 
		+ '		INNER JOIN dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		INNER join dbo.dimcustomerssbid d'
		+ '		ON b.dimcustomerid = d.dimcustomerid ' + CHAR(13)
		+ '		INNER JOIN (Select ssb_crmsystem_contact_id, data_deletion_completed_ts from '
		+'					dbo.DimCustomerPrivacy p inner join '
		+'				 dbo.dimcustomerssbid ssb on p.dimcustomerid = ssb.dimcustomerid) c' + CHAR(13)
		+ '		on d.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id ' + CHAR(13)
		+ '		WHERE 1=1 and c.data_deletion_request_ts is not null ' + CHAR(13) 
 
		+ '		IF OBJECT_ID(''tempdb..#stale_ssbid'') IS NOT NULL' + CHAR(13) 
		+ '			DROP TABLE #stale_ssbid' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get the SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID, and SSB_CRMSYSTEM_CONTACT_ID for each stale record' + CHAR(13) 
		+ '		SELECT a.DimCustomerId, a.UpdatedDate, b.SSB_CRMSYSTEM_CONTACT_ID, b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13) 
		+ '		INTO #stale_ssbid' + CHAR(13) 
		+ '		FROM #stale a' + CHAR(13) 
		+ '		LEFT JOIN dbo.dimcustomerssbid b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) + CHAR(13) 
 
		+ '		CREATE NONCLUSTERED INDEX ix_contact_id ON #stale_ssbid (SSB_CRMSYSTEM_CONTACT_ID)' + CHAR(13) 
		+ '		CREATE NONCLUSTERED INDEX ix_acct_id ON #stale_ssbid (SSB_CRMSYSTEM_ACCT_ID)' + CHAR(13) 
		+ '		CREATE NONCLUSTERED INDEX ix_household_id ON #stale_ssbid (SSB_CRMSYSTEM_HOUSEHOLD_ID)' + CHAR(13) + CHAR(13) 
 
		+ '		IF OBJECT_ID(''tempdb..#stale_ssbid_grouping'') IS NOT NULL' + CHAR(13) 
		+ '			DROP TABLE #stale_ssbid_grouping' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get all records for an account group' + CHAR(13) 
		+ '		SELECT DISTINCT a.DimCustomerId AS GroupingId, b.DimCustomerId, a.UpdatedDate' + CHAR(13) 
		+ '		INTO #stale_ssbid_grouping' + CHAR(13) 
		+ '		FROM (SELECT a.SSB_CRMSYSTEM_ACCT_ID, MAX(a.DimCustomerId) AS DimCustomerId, MAX(a.UpdatedDate) AS UpdatedDate FROM #stale_ssbid a WHERE a.SSB_CRMSYSTEM_ACCT_ID IS NOT NULL GROUP BY a.SSB_CRMSYSTEM_ACCT_ID) a' + CHAR(13) 
		+ '		INNER JOIN dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_ACCT_ID = b.SSB_CRMSYSTEM_ACCT_ID' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT @staleGroupingCnt = @staleGroupingCnt + @@ROWCOUNT' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get all records for a household group' + CHAR(13) 
		+ '		INSERT INTO #stale_ssbid_grouping' + CHAR(13) 
		+ '		SELECT a.DimCustomerId AS GroupingId, b.DimCustomerId, a.UpdatedDate' + CHAR(13) 
		+ '		FROM (SELECT a.SSB_CRMSYSTEM_HOUSEHOLD_ID, MAX(a.DimCustomerId) AS DimCustomerId, MAX(a.UpdatedDate) AS UpdatedDate FROM #stale_ssbid a WHERE a.SSB_CRMSYSTEM_HOUSEHOLD_ID IS NOT NULL GROUP BY a.SSB_CRMSYSTEM_HOUSEHOLD_ID) a' + CHAR(13) 
		+ '		INNER JOIN dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_HOUSEHOLD_ID = b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13) 
		+ '		LEFT JOIN #stale_ssbid_grouping c ON b.DimCustomerId = c.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND c.DimCustomerId IS NULL' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT @staleGroupingCnt = @staleGroupingCnt + @@ROWCOUNT' + CHAR(13) + CHAR(13) 
 
		+ '		-- Get all records for a contact group' + CHAR(13) 
		+ '		INSERT INTO #stale_ssbid_grouping' + CHAR(13) 
		+ '		SELECT a.DimCustomerId AS GroupingId, b.DimCustomerId, a.UpdatedDate' + CHAR(13) 
		+ '		FROM (SELECT a.SSB_CRMSYSTEM_CONTACT_ID, MAX(a.DimCustomerId) AS DimCustomerId, MAX(a.UpdatedDate) AS UpdatedDate FROM #stale_ssbid a WHERE a.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL GROUP BY a.SSB_CRMSYSTEM_CONTACT_ID) a' + CHAR(13) 
		+ '		INNER JOIN dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) 
		+ '		LEFT JOIN #stale_ssbid_grouping c ON b.DimCustomerId = c.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND c.DimCustomerId IS NULL' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT @staleGroupingCnt = @staleGroupingCnt + @@ROWCOUNT' + CHAR(13) + CHAR(13) 
 
		+ '		INSERT INTO #stale_ssbid_grouping' + CHAR(13) 
		+ '		SELECT a.DimCustomerId, a.DimCustomerId, MAX(a.UpdatedDate) AS UpdatedDate' + CHAR(13) 
		+ '		FROM #stale_ssbid a' + CHAR(13) 
		+ '		LEFT JOIN #stale_ssbid_grouping b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) 
		+ '		AND a.SSB_CRMSYSTEM_CONTACT_ID IS NULL' + CHAR(13) 
		+ '		AND a.SSB_CRMSYSTEM_ACCT_ID IS NULL' + CHAR(13) 
		+ '		AND a.SSB_CRMSYSTEM_HOUSEHOLD_ID IS NULL' + CHAR(13) 
		+ '		AND b.GroupingId IS NULL' + CHAR(13) 
		+ '		GROUP BY a.DimCustomerId' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT @staleGroupingCnt = @staleGroupingCnt + @@ROWCOUNT' + CHAR(13) + CHAR(13) 
 
		+ '		INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ '		VALUES (current_timestamp, ''CDIO Refresh'', ''#stale_ssbid_grouping'', @staleGroupingCnt);' + CHAR(13) + CHAR(13)	 
 
		+ '		IF OBJECT_ID(''tempdb..#stale_ranked'') IS NOT NULL' + CHAR(13) 
		+ '			DROP TABLE #stale_ranked' + CHAR(13) + CHAR(13) 
 
		+ '		SELECT GroupingId, DimCustomerId, UpdatedDate, ROW_NUMBER() OVER (ORDER BY CASE WHEN UpdatedDate IS NULL THEN 0 ELSE 1 END, UpdatedDate, GroupingId) AS ranking' + CHAR(13) 
		+ '		INTO #stale_ranked' + CHAR(13) 
		+ '		FROM #stale_ssbid_grouping' + CHAR(13) + CHAR(13) 
 
		+ '		CREATE CLUSTERED INDEX ix_dimcustomerid ON #stale_ranked (DimCustomerId)' + CHAR(13) 
		+ '		CREATE NONCLUSTERED INDEX ix_ranking ON #stale_ranked (ranking)' + CHAR(13) + CHAR(13) 
 
		+ '		-- Ensure entire grouping is returned' + CHAR(13) 
		+ '		-- If the ranking cutoff occurs in the middle of a grouping, get the max ranking for that group' + CHAR(13) 
		+ '		SELECT @rankingCutoff = MAX(ranking)' + CHAR(13) 
		+ '		FROM #stale_ranked' + CHAR(13) 
		+ '		WHERE GroupingId = (' + CHAR(13) 
		+ '			SELECT GroupingId' + CHAR(13) 
		+ '			FROM #stale_ranked' + CHAR(13) 
		+ '			WHERE ranking = (SELECT CEILING(COUNT(0)/CAST(CASE WHEN ''' + @RefreshFrequency + ''' = ''Weekly'' THEN 12 WHEN ''' + @RefreshFrequency + ''' = ''Daily'' THEN 90 END AS FLOAT)) FROM #stale_ranked))' + CHAR(13) + CHAR(13) 
 
		+ '		IF @rankingCutoff <= @maxRefreshCutoff' + CHAR(13) 
		+ '			SET @rankingCutoff = @maxRefreshCutoff' + CHAR(13) + CHAR(13) 
 
		-- IF @rankingCutoff > 100,000 DISABLE INDEXES??? 
 		
		+ '		IF OBJECT_ID(''tempdb..#resetStale'') IS NOT NULL' + CHAR(13)
		+ '			DROP TABLE #resetStale' + CHAR(13) + CHAR(13)

		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		INTO #resetStale' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.NameIsCleanStatus != ''Dirty''' + CHAR(13)
		+ '		UNION' + CHAR(13)
		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.AddressPrimaryIsCleanStatus NOT IN (''Dirty'',''Bad'')' + CHAR(13)
		+ '		UNION' + CHAR(13)
		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.AddressOneIsCleanStatus NOT IN (''Dirty'',''Bad'')' + CHAR(13)
		+ '		UNION' + CHAR(13)
		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.AddressTwoIsCleanStatus NOT IN (''Dirty'',''Bad'')' + CHAR(13)
		+ '		UNION' + CHAR(13)
		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.AddressThreeIsCleanStatus NOT IN (''Dirty'',''Bad'')' + CHAR(13)
		+ '		UNION' + CHAR(13)
		+ '		SELECT a.DimCustomerId' + CHAR(13)
		+ '		FROM #stale_ranked a' + CHAR(13)
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)
		+ '		WHERE 1=1' + CHAR(13)
		+ '		AND ranking <= @rankingCutoff' + CHAR(13)
		+ '		AND b.AddressFourIsCleanStatus NOT IN (''Dirty'',''Bad'')' + CHAR(13) + CHAR(13)

		+ '		UPDATE b' + CHAR(13) 
		+ '		SET b.NameIsCleanStatus = ''Dirty''' + CHAR(13) 
		+ '			,b.AddressPrimaryIsCleanStatus = CASE WHEN b.AddressPrimaryIsCleanStatus != ''Bad'' THEN ''Dirty'' ELSE b.AddressPrimaryIsCleanStatus END' + CHAR(13) 
		+ '			,b.AddressOneIsCleanStatus = CASE WHEN b.AddressOneIsCleanStatus != ''Bad'' THEN ''Dirty'' ELSE b.AddressOneIsCleanStatus END' + CHAR(13) 
		+ '			,b.AddressTwoIsCleanStatus = CASE WHEN b.AddressTwoIsCleanStatus != ''Bad'' THEN ''Dirty'' ELSE b.AddressTwoIsCleanStatus END' + CHAR(13) 
		+ '			,b.AddressThreeIsCleanStatus = CASE WHEN b.AddressThreeIsCleanStatus != ''Bad'' THEN ''Dirty'' ELSE b.AddressThreeIsCleanStatus END' + CHAR(13) 
		+ '			,b.AddressFourIsCleanStatus = CASE WHEN b.AddressFourIsCleanStatus != ''Bad'' THEN ''Dirty'' ELSE b.AddressFourIsCleanStatus END' + CHAR(13) 
		--+ '		SELECT *' + CHAR(13) 
		+ '		FROM #resetStale a' + CHAR(13) 
		+ '		INNER JOIN dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13) + CHAR(13) 
 
		+ '		INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ '		VALUES (current_timestamp, ''CDIO Refresh'', ''Flag as Dirty'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	 
 
		+ '		UPDATE a' + CHAR(13) 
		+ '		SET a.LastRefreshDate = GETDATE()' + CHAR(13) 
		+ '		FROM ' + @MDM_DB + 'mdm.ClientRefreshConfig a' + CHAR(13) 
		+ '		WHERE ID = @ID' + CHAR(13) + CHAR(13) 
 
		+ '		INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ '		VALUES (current_timestamp, ''CDIO Refresh'', ''End'', 0);' + CHAR(13) + CHAR(13)	 
		+ ' END' + CHAR(13) 
 
	----SELECT @sql 
	 
	EXEC mdm.ExecuteSQL_ForEachClient @sql = @sql, @mdm_process = 'CDIO Refresh' 
	 
END
GO
