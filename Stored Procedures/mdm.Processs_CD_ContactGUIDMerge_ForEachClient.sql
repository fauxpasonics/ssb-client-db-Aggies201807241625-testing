SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[Processs_CD_ContactGUIDMerge_ForEachClient]   
AS    
BEGIN   
   
	DECLARE @sql NVARCHAR(MAX) = ''   
	DECLARE @ClientDB VARCHAR(50) = ''   
	DECLARE @counter INT = 1   
   
	IF OBJECT_ID('tempdb..#database') IS NOT NULL   
		DROP TABLE #database   
   
	CREATE TABLE #database (ID INT IDENTITY(1,1), ClientDB VARCHAR(50))   
   
	INSERT INTO #database (ClientDB)   
	SELECT name AS ClientDB   
	FROM sys.databases   
   
	IF OBJECT_ID('tempdb..#staleGUID') IS NOT NULL   
		DROP TABLE #staleGUID   
   
	SELECT DISTINCT ContactGUID_Loser   
	INTO #staleGUID   
	FROM mdm.CD_ContactGUIDMerge   
   
	CREATE CLUSTERED INDEX ix_contactguid ON #staleGUID (ContactGUID_Loser)   
   
	WHILE @counter <= (SELECT MAX(ID) FROM #database)   
	BEGIN   
	BEGIN TRY   
		SET @sql = ''   
   
		IF (SELECT @@VERSION) LIKE '%Azure%'   
		BEGIN  
			SET @ClientDB = ''   
			SELECT @counter = MAX(ID) FROM #database  
		END  
		ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'   
			SELECT @ClientDB = ClientDB + '.'   
			FROM #database   
			WHERE ID = @counter   
   
		SET @sql = ''   
			+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.auditlog'') IS NOT NULL' + CHAR(13)   
			+ ' BEGIN' + CHAR(13)   
			+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
			+ '		VALUES (current_timestamp, ''Process CD ContactGUID Merge'', ''Start'', 0);' + CHAR(13) + CHAR(13)	   
   
			+ ' 	UPDATE b' + CHAR(13)   
			+ ' 	SET b.NameIsCleanStatus = ''Dirty''' + CHAR(13)   
			+ ' 	FROM #staleGUID a' + CHAR(13)   
			+ ' 	INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.ContactGUID_Loser = b.ContactGUID' + CHAR(13)   
			+ ' 	WHERE 1=1' + CHAR(13)   
			+ ' 	AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13) + CHAR(13)   
   
			+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
			+ '		VALUES (current_timestamp, ''Process CD ContactGUID Merge'', ''Set NameIsCleanStatus to Dirty'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	   
   
			+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
			+ '		VALUES (current_timestamp, ''Process CD ContactGUID Merge'', ''End'', 0);' + CHAR(13) + CHAR(13)	   
			+ ' END' + CHAR(13) + CHAR(13)   
   
		--SELECT @sql   
		EXEC sp_executesql @sql   
   
		SET @counter = @counter + 1   
	END TRY   
	BEGIN CATCH    
		-- Go to the next ClientDB   
		SET @counter = @counter + 1   
	END CATCH   
	END   
   
END
GO
