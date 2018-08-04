SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [api].[sp_ContactSplit_GetAllSourceRecords]  
	@ClientDB varchar(50)  
	, @SSB_CRMSYSTEM_CONTACT_ID VARCHAR(50)  
AS  
BEGIN  
	--DECLARE @ClientDb VARCHAR(50) = 'MDM_CLIENT_DEV'  
  
	IF (SELECT @@VERSION) LIKE '%Azure%'  
		SET @ClientDB = ''  
	ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'  
		SET @ClientDB = @ClientDB + '.'  
  
	-- MESSAGES --  
	-- ~BR~ (Case Senstive) = FORCE LINE BREAK  
  
	-- Init  
	DECLARE   
		 @sql NVARCHAR(MAX) = ''  
		, @finalXml XML  
		--, @SSB_CRMSYSTEM_CONTACT_ID VARCHAR(50) = '00002008-501B-426D-AD77-831AFAD00DD2'  
  
	SET @sql = @sql  
		+ ' DECLARE @totalCount         INT' + CHAR(13)  
		+ ' DECLARE @xmlDataNode        XML' + CHAR(13)  
		+ ' DECLARE @rootNodeName       NVARCHAR(100)' + CHAR(13)  
		+ ' DECLARE @responseInfoNode   NVARCHAR(MAX)' + CHAR(13)  
		+ ' DECLARE @ErrorMessage       NVARCHAR(4000)' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' DECLARE @baseData TABLE(' + CHAR(13)  
		+ ' 	DimCustomerId  INT,' + CHAR(13)  
		+ ' 	Name           NVARCHAR(255),' + CHAR(13)  
		+ ' 	Address        NVARCHAR(2000),' + CHAR(13)  
		+ ' 	Email          NVARCHAR(500),' + CHAR(13)  
		+ ' 	Phone          NVARCHAR(255),' + CHAR(13)  
		+ '		SSID           NVARCHAR(100),' + CHAR(13)  
		+ '		SourceSystem   NVARCHAR(50)' + CHAR(13)  
		+ ' 	---HyperLink    NVARCHAR(255),' + CHAR(13)  
		+ ' 	---RecordOwner  NVARCHAR(255)' + CHAR(13)  
		+ ' )' + CHAR(13)  
		+ ' ' + CHAR(13)  
		  
	SET @sql = @sql   
		+ ' ' + CHAR(13)  
		+ ' BEGIN TRY'  
		+ ' 	INSERT INTO @baseData' + CHAR(13)  
		+ ' 	(DimCustomerId, Name, Address, Email, Phone, SSID, SourceSystem)' + CHAR(13)  
		+ ' 	SELECT d.DimCustomerId' + CHAR(13)  
		+ ' 		, ISNULL(d.FirstName, '''') + '' '' + ISNULL(d.LastName, '''') Name ' + CHAR(13)  
		+ ' 		, d.AddressPrimaryStreet + '' '' + d.AddressPrimaryCity + '', '' + d.AddressPrimaryState + '' '' + d.AddressPrimaryZip Address' + CHAR(13)  
		+ ' 		, d.EmailPrimary Email' + CHAR(13)  
		+ ' 		, d.PhonePrimary Phone' + CHAR(13)  
		+ '			, d.SSID' + CHAR(13)  
		+ '			, d.SourceSystem' + CHAR(13)  
		+ ' 		----, ''https://na3.salesforce.com/'' + b.Id HyperLink' + CHAR(13)  
		+ ' 		----, c.Name RecordOwner' + CHAR(13)  
		+ ' 	FROM ' + @ClientDB + 'dbo.dimcustomerssbid b' + CHAR(13)  
		+ ' 	LEFT JOIN ' + @ClientDB + 'dbo.DimCustomer d ' + CHAR(13)  
		+ ' 	ON b.DimCustomerId = d.DimCustomerId' + CHAR(13)  
		+ '		WHERE b.ssb_crmsystem_contact_id = ''' + @SSB_CRMSYSTEM_CONTACT_ID + '''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		IF (SELECT COUNT(0) FROM @baseData) = 0'  
		+ '		BEGIN' + CHAR(13)  
		+ '			RAISERROR (''Invalid SSB_CRMSYSTEM_CONTACT_ID provided.'', -- Message text.' + CHAR(13)  
        + '		       16, -- Severity.' + CHAR(13)  
        + '		       1 -- State.' + CHAR(13)  
        + '		       );' + CHAR(13)  
		+ '		END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		-- Set counts' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SELECT @totalCount = COUNT(*) FROM @baseData  -- If paging were enabled, you wouldn''t count here' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		-- Create XML response data node' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @xmlDataNode = (SELECT' + CHAR(13)  
		+ '			DimCustomerId,' + CHAR(13)  
		+ '			CASE WHEN Name = '' '' OR Name IS NULL THEN '''' ELSE Name END AS Name, ' + CHAR(13)  
		+ '			ISNULL(Address, '''') AS Address, ' + CHAR(13)  
		+ '			ISNULL(Email, '''') AS Email, ' + CHAR(13)  
		+ '			ISNULL(Phone, '''') AS Phone,' + CHAR(13)  
		+ '			ISNULL(SSID, '''') as SSID,' + CHAR(13)  
		+ '			ISNULL(SourceSYstem, '''') as SourceSystem' + CHAR(13)  
		+ '			---ISNULL(HyperLink, '''') AS HyperLink,' + CHAR(13)  
		+ '			---ISNULL(RecordOwner, '''') AS RecordOwner' + CHAR(13)  
		+ '			FROM @baseData' + CHAR(13)  
		+ '			FOR XML PATH (''Detail''), ROOT(''Details''))' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @rootNodeName = ''Details''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		-- Create response info node' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @responseInfoNode = (''<ResponseInfo>''' + CHAR(13)  
		+ '			+ ''<TotalCount>'' + CAST(@totalCount AS NVARCHAR(20)) + ''</TotalCount>''' + CHAR(13)  
		+ '			+ ''<RemainingCount>0</RemainingCount>''' + CHAR(13)  
		+ '			+ ''<RecordsInResponse>'' + CAST(@totalCount AS NVARCHAR(20)) + ''</RecordsInResponse>''' + CHAR(13)  
		+ '			+ ''<PagedResponse>false</PagedResponse>''' + CHAR(13)  
		+ '			+ ''<RowsPerPage></RowsPerPage>''' + CHAR(13)  
		+ '			+ ''<PageNumber></PageNumber>''' + CHAR(13)  
		+ '			+ ''<RootNodeName>'' + @rootNodeName + ''</RootNodeName>''' + CHAR(13)  
		+ '			+ ''</ResponseInfo>'')' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		-- Wrap response info and data, then return' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @finalXml = ''<Root>'' + @responseInfoNode + CAST(@xmlDataNode AS NVARCHAR(MAX)) + ''</Root>''' + CHAR(13)  
		+ ''	 + CHAR(13)  
		+ ' END TRY' + CHAR(13)  
		+ ' BEGIN CATCH' + CHAR(13)  
		+ '		SELECT @ErrorMessage = ERROR_MESSAGE()'  
		+ ' 	SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this request.'' + CASE WHEN ISNULL(@ErrorMessage,'''') != '''' THEN '' '' + @ErrorMessage ELSE '''' END + ''</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ ' END CATCH' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SELECT CAST(@finalXml AS XML)' + CHAR(13)  
	  
	 --SELECT @sql  
  
	EXEC sp_executesql @sql, N'@finalXml XML OUTPUT', @finalXml OUTPUT  
  
END
GO
