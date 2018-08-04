SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [mdm].[PostOverrideMasterDimCustomerDeltas]
(
	@PostData   NVARCHAR(MAX)
)
AS

BEGIN

	 DECLARE 
		@ClientDB VARCHAR(50) = ''
		, @sql NVARCHAR(MAX) = '' 
		, @responseXml XML
		, @ErrorMessage NVARCHAR(4000);

	--DECLARE @PostData NVARCHAR(MAX) = '[{ "ClientDB": "MDM_CLIENT_DEV", "DimCustomerId": "2937636", "ElementId": "3", "Field":"AddressPrimaryStreet", "OverrideValue": "overrideSampleValue", "UserName":"ssbadmin", "OverrideDate":"Sep 12 2016 12:23:13" }
	--									{ "ClientDB": "MDM_CLIENT_DEV", "DimCustomerId": "2937636", "ElementId": "18", "Field":"FirstName", "OverrideValue":"AnotherOverride value 999", "UserName":"ssbadmin", "OverrideDate":"Sep 11 2016 12:23:13" }]'

	SET NOCOUNT ON

	BEGIN TRY
	--parse table
		SELECT element_id, sequenceNo, parent_ID, [Object_ID], NAME, StringValue, ValueType
		INTO #baseData
		FROM dbo.parseJSON(@PostData)

		--show results of json parse
		--select * from #baseData

		--build rows from parse		
		SELECT
			CAST(ClientDB AS VARCHAR(50)) AS ClientDB 
			, CAST(DimCustomerID AS INT) AS DimCustomerID
			, CAST(ElementId AS INT) AS ElementID
			, CAST(Field AS NVARCHAR(50)) AS Field
			, CAST(OverrideValue AS NVARCHAR(MAX)) AS OverrideValue
			, CAST(Username AS NVARCHAR(255)) AS OverrideBy
			, CAST(CASE WHEN ISNULL(OverrideDate,'') = '' THEN NULL ELSE OverrideDate END AS DATETIME) AS OverrideDate
			, parent_ID
		INTO #override
		FROM (
				SELECT Name
					, StringValue
					, parent_ID
				FROM #baseData
				WHERE ValueType = 'string'
			) z
		PIVOT
			( Max(StringValue) for Name in (
				[ClientDB]
				, [DimCustomerID]
				, [ElementId]
				, [Field]
				, [OverrideValue]
				, [Username]
				, [OverrideDate])
			) as PVT

		IF ((SELECT COUNT(0) FROM #override WHERE ISNULL(ClientDB,'') = '') > 0
			OR (SELECT COUNT(0) FROM #override WHERE ISNULL(DimCustomerID,0) = 0) > 0
			OR (SELECT COUNT(0) FROM #override WHERE ISNULL(ElementID,0) = 0) > 0
			OR (SELECT COUNT(0) FROM #override WHERE ISNULL(Field,'') = '') > 0
			--OR (SELECT COUNT(0) FROM #override WHERE ISNULL(OverrideValue,'') = '') > 0
			OR (SELECT COUNT(0) FROM #override WHERE ISNULL(OverrideBy,'') = '') > 0
			OR (SELECT COUNT(0) FROM #override WHERE ISNULL(CAST(OverrideDate AS VARCHAR(50)),'') = '') > 0
		)
		BEGIN
			RAISERROR ('One or more required values are missing.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
		END

		SELECT TOP 1 @ClientDB = 
			CASE WHEN @@VERSION LIKE '%Azure%' THEN '' ELSE ClientDB + '.' END
		FROM #override
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE()
		SET @responseXml = '<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data.' + CASE WHEN ISNULL(@ErrorMessage,'') != '' THEN ' ' + @ErrorMessage ELSE '' END + ' </ErrorMessage></ResponseInfo></Root>'
	END CATCH

	IF @responseXml IS NULL 
	BEGIN
		SET @sql = @sql
			+ ' BEGIN TRY' + CHAR(13)
			+ '		DECLARE @SummaryOfChanges TABLE(Change VARCHAR(20));' + CHAR(13)
			+ '' + CHAR(13)
			+ '		MERGE ' + @ClientDB + 'mdm.overrides AS t' + CHAR(13)
			+ '		USING (SELECT a.*, b.SSID, b.SourceSystem FROM #override a INNER JOIN ' + @ClientDB + '.dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerID) AS s' + CHAR(13)
			+ '		ON t.DimCustomerID = s.DimCustomerID' + CHAR(13)
			+ '			AND t.ElementID = s.ElementID' + CHAR(13)
			+ '			AND t.Field = s.Field' + CHAR(13)
			+ '		WHEN MATCHED AND ISNULL(t.Value,'''') != ISNULL(s.OverrideValue,'''') THEN' + CHAR(13)
			+ '			UPDATE' + CHAR(13)
			+ '			SET t.Value = s.OverrideValue' + CHAR(13)
			+ '				,t.UpdatedBy = s.OverrideBy' + CHAR(13)
			+ '				,t.UpdatedDate = GETDATE()' + CHAR(13)
			+ '				,t.StatusID = 1' + CHAR(13)
			+ '				,t.ActivateDate = GETDATE()' + CHAR(13)
			+ '		WHEN NOT MATCHED THEN' + CHAR(13)
			+ '			INSERT (DimCustomerID, SSID, SourceSystem, ElementID, Field, Value, CreatedBy, CreatedDate, UpdatedDate)' + CHAR(13)
			+ '			VALUES (s.DimCustomerID, s.SSID, s.SourceSystem, s.ElementID, s.Field, s.OverrideValue, s.OverrideBy, GETDATE(), NULL)' + CHAR(13)
			+ '		OUTPUT $action INTO @SummaryOfChanges' + CHAR(13)
			+ '		;' + CHAR(13)
		SET @sql = @sql + CHAR(13)

		SET @sql = @sql
			+ '		UPDATE b' + CHAR(13)
			+ '		SET b.ProcessedDate = GETDATE()' + CHAR(13)
			+ '		--SELECT *' + CHAR(13)
			+ '		FROM #override a' + CHAR(13)
			+ '		INNER JOIN ' + @ClientDB + 'dbo.Master_DimCustomer_Deltas b ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)
			+ '			AND a.ElementID = b.ElementID' + CHAR(13)
			+ '			AND a.Field = b.Field' + CHAR(13)
			+ '		WHERE 1=1' + CHAR(13)
			+ '		AND b.ProcessedDate IS NULL' + CHAR(13)
		SET @sql = @sql + CHAR(13)

		SET @sql = @sql
			+ '' + CHAR(13)
			+ '		Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
			+ '		values (current_timestamp, ''Master Source'', ''Override (insert)'', (SELECT COUNT(0) from @SummaryOfChanges WHERE Change = ''INSERT''));' + CHAR(13)
			+ ''	 + CHAR(13)
			+ '		Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
			+ '		values (current_timestamp, ''Master Source'', ''Override (update)'', (SELECT COUNT(0) from @SummaryOfChanges WHERE Change = ''UPDATE''));' + CHAR(13)
			+ ' END TRY' + CHAR(13)
			+ ' BEGIN CATCH' + CHAR(13)
			+ ' 	SET @responseXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data.</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)
			+ ' END CATCH' + CHAR(13)			
		SET @sql = @sql + CHAR(13)

		SET @sql = @sql 
			+ ' SET @responseXml = ''<Root><ResponseInfo><Success>true</Success></ResponseInfo></Root>''' + CHAR(13)
	
	END

	SET @sql = @sql
		+ ' -- Return response' + CHAR(13)
		+ ' SELECT CAST(@responseXml AS XML)' + CHAR(13)

	--SELECT @sql, @responseXml

	EXEC sp_executesql @sql, N'@responseXml XML OUTPUT', @responseXml OUTPUT

END
GO
