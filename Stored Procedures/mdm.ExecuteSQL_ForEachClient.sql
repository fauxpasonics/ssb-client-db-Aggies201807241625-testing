SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[ExecuteSQL_ForEachClient]
(
	@sql NVARCHAR(MAX)
	,@mdm_process VARCHAR(50) = NULL
	,@clientList NVARCHAR(MAX) = ''
	,@excludeClientList BIT = 0
)
AS
BEGIN
	DECLARE 
		@preSql NVARCHAR(MAX) = ''
		, @finalSql NVARCHAR(MAX) = ''
		, @ClientDB VARCHAR(50) = '' 
		, @mdmClient BIT = 0
		, @counter INT = 1 
		, @errorMsg NVARCHAR(MAX) = ''
 
	IF OBJECT_ID('tempdb..#database') IS NOT NULL 
		DROP TABLE #database 
 
	CREATE TABLE #database (ID INT IDENTITY(1,1), ClientDB VARCHAR(50)) 
 
	INSERT INTO #database (ClientDB) 
	SELECT name AS ClientDB 
	FROM sys.databases 

	WHILE @counter <= (SELECT MAX(ID) FROM #database) 
	BEGIN 
		BEGIN TRY 
			SET @preSql = ''
			SET @mdmClient = 0 
			SET @errorMsg = ''
		
			IF (SELECT @@VERSION) LIKE '%Azure%' 
			BEGIN
				SET @ClientDB = '' 
				SELECT @counter = MAX(ID) + 1 FROM #database
			END
			ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%' 
			BEGIN
				SELECT @ClientDB = ClientDB 
				FROM #database 
				WHERE ID = @counter 
			END

			IF (@excludeClientList = 0 AND CHARINDEX(@ClientDB,@clientList) > 0)
				OR (@excludeClientList = 1 AND CHARINDEX(@ClientDB,@clientList) = 0)
				OR (ISNULL(@excludeClientList,0) = 0 AND ISNULL(@clientList,'') = '')
			BEGIN
			IF ISNULL(@ClientDB,'') != ''
				BEGIN
					PRINT @ClientDB + ' - ' + CAST(GETDATE() AS VARCHAR(20))
					SET @preSql = ''
						+ ' USE [' + @ClientDB + ']' + CHAR(13) + CHAR(13)
				END

				EXEC sp_executesql @preSql 

				SET @preSql = @preSql + CHAR(13)
					+ ' IF OBJECT_ID(''mdm.auditlog'') IS NOT NULL' + CHAR(13)
					+ ' 	SET @mdmClient = 1' + CHAR(13)

				EXEC sp_executesql @preSql, N'@mdmClient BIT OUTPUT', @mdmClient OUTPUT

				--SELECT @ClientDB, @mdmClient

				IF @mdmClient = 1
				BEGIN 
					BEGIN TRY	
						--PRINT DB_NAME()
				
						SET @finalSql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''';
				
						--SELECT @finalSql 
						EXEC sp_executesql @finalSql 
					END TRY
					BEGIN CATCH
						SET @errorMsg = ERROR_MESSAGE()
						IF ISNULL(@mdm_process, '') != ''
						BEGIN
							SET @finalSql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END 
							+ 'sp_executesql N'''+ REPLACE('INSERT INTO mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
							+ '	VALUES (current_timestamp, ''' + @mdm_process + ''', ''ERROR - ' + REPLACE(LEFT(@errorMsg, 92),'''','''''') + ''', 0)', '''', '''''') + ''''; 

							--SELECT @finalSql
							EXEC sp_executesql @finalSql
						END 

						PRINT 'ERROR - ' + @errorMsg
					END CATCH
				END
			END
			ELSE
			BEGIN
				PRINT @ClientDB + ' - ' + CAST(GETDATE() AS VARCHAR(20)) + ' - SKIPPING'
			END

			SET @counter = @counter + 1 
		END TRY 
		BEGIN CATCH  
			SET @errorMsg = ERROR_MESSAGE()
			IF @errorMsg LIKE '%syntax%'
				RAISERROR (@errorMsg, 16, 1)
			ELSE  
			BEGIN
				PRINT 'ERROR - ' + @errorMsg
			END
			-- Go to the next ClientDB 
			SET @counter = @counter + 1 
		END CATCH 
	END 
END
GO
