SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROC [api].[sp_ContactSplit_PostSplit]  
(  
	@PostData   NVARCHAR(MAX)  
)  
AS  
BEGIN  
  
	--Drop table #baseData  
	--DROP TABLE #contact_split  
	--DECLARE @PostData NVARCHAR(MAX) = '[{ "ClientDB": "Raiders", "ContactGroupId": "1", "DimCustomerId": "291903" }  
	--									{ "ClientDB": "Raiders", "ContactGroupId": "1", "DimCustomerId": "1484686" }  
	--									{ "ClientDB": "Raiders", "ContactGroupId": "2", "DimCustomerId": "1684169" }]'  
  
	DECLARE   
		@ClientDB VARCHAR(50) = ''  
		, @sql NVARCHAR(MAX) = ''   
		, @responseXml XML  
		, @ErrorMessage NVARCHAR(4000);  
  
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
			, CAST(PVT.ContactGroupId AS INT) AS ContactGroupId  
			, CAST(DimCustomerID AS INT) AS DimCustomerID  
			, CAST(NULL AS UNIQUEIDENTIFIER) AS forced_contact_id  
		INTO #contact_split  
		--SELECT *  
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
				, [ContactGroupId]  
				, [DimCustomerId])  
			) as PVT  
  
  
		IF ((SELECT COUNT(0) FROM #contact_split WHERE ISNULL(ClientDB,'') = '') > 0  
			OR (SELECT COUNT(0) FROM #contact_split WHERE ISNULL(ContactGroupId,0) = 0) > 0  
			OR (SELECT COUNT(0) FROM #contact_split WHERE ISNULL(DimCustomerID,0) = 0) > 0  
		)  
		BEGIN  
			RAISERROR ('One or more required values are missing.', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
		END  
  
		SELECT TOP 1 @ClientDB =   
			CASE WHEN @@VERSION LIKE '%Azure%' THEN '' ELSE ClientDB + '.' END  
		FROM #contact_split  
  
  
		UPDATE a  
		SET a.forced_contact_id = b.forced_contact_id  
		--SELECT *   
		FROM #contact_split a  
		INNER JOIN (  
			SELECT a.ContactGroupId, NEWID() AS forced_contact_id  
			FROM (  
				SELECT DISTINCT ContactGroupId  
				FROM #contact_split  
			) a  
			UNION  
			SELECT NULL, NEWID() -- force subquery to materialize so that distinct values are created for forced_contact_id  
		) b ON a.ContactGroupId = b.ContactGroupId  
		WHERE 1=1  
	END TRY  
	BEGIN CATCH  
	    SELECT @ErrorMessage = ERROR_MESSAGE()  
		SET @responseXml = '<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data.' + CASE WHEN ISNULL(@ErrorMessage,'') != '' THEN ' ' + @ErrorMessage ELSE '' END + ' </ErrorMessage></ResponseInfo></Root>'  
	END CATCH	  
  
	IF @responseXml IS NULL   
	BEGIN  
		SET @sql = @sql  
			+ ' BEGIN TRY' + CHAR(13)  
			+ '		DELETE b' + CHAR(13)  
			+ '		FROM #contact_split a' + CHAR(13)  
			+ '		INNER JOIN ' + @ClientDB + 'mdm.ForceUnmergeIds b ON a.DimCustomerId = b.dimcustomerid' + CHAR(13)  
			+ '		WHERE 1=1' + CHAR(13)  
			+ '' + CHAR(13)  
			+ '		INSERT INTO ' + @ClientDB + 'mdm.ForceUnMergeIds (dimcustomerid, forced_contact_id)' + CHAR(13)  
			+ '		SELECT a.DimCustomerID, a.forced_contact_id' + CHAR(13)  
			+ '		FROM #contact_split a' + CHAR(13)  
			+ '		LEFT JOIN ' + @ClientDB + 'mdm.ForceUnmergeIds b ON a.DimCustomerId = b.dimcustomerid' + CHAR(13)  
			+ '		WHERE 1=1' + CHAR(13)  
			+ '		AND b.dimcustomerid IS NULL' + CHAR(13)  
			+ ' END TRY' + CHAR(13)  
			+ ' BEGIN CATCH' + CHAR(13)  
			+ ' 	SET @responseXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data.</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
			+ ' END CATCH' + CHAR(13)  
  
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
