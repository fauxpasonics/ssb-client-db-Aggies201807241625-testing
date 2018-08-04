SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
  
CREATE PROCEDURE [api].[sp_API_PreMerge_Details]  
	@ClientDB varchar(50)  
	, @GUIDType VARCHAR(50) = 'Contact'  
	, @GUID AS VARCHAR(8000)  
as  
BEGIN  
  
	--DECLARE @ClientDb VARCHAR(50) = 'Raiders'  
  
	IF (SELECT @@VERSION) LIKE '%Azure%'  
		SET @ClientDB = ''  
	ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'  
		SET @ClientDB = @ClientDB + '.'  
  
	--DECLARE @GUIDType VARCHAR(50), @GUID AS VARCHAR(8000)  
	--SET @GUIDType = 'Contact'  
	--SET @GUID = '0139a1ab-8906-4662-b45b-816a5da8403d, ea86647e-94b5-42e9-932e-22a4707dec20, 8aa21d3d-b5cb-42ec-b1f2-9ddfcf2620e3'  
	----'273CCC80-80B5-4680-A065-A49D749FC463,35AA140C-4EE1-41B0-AEAD-56E38FB2FA70'  
  
	-- Init  
	DECLARE   
		 @sql NVARCHAR(MAX) = ''  
		, @finalXml XML  
  
	SET @sql = @sql  
		+ ' DECLARE @totalCount         INT' + CHAR(13)  
		+ ' DECLARE @xmlDataNode        XML' + CHAR(13)  
		+ ' DECLARE @rootNodeName       NVARCHAR(100)' + CHAR(13)  
		+ ' DECLARE @responseInfoNode   NVARCHAR(MAX)' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' DECLARE @baseData TABLE(' + CHAR(13)  
		+ ' 	GUIDType     VARCHAR(50),' + CHAR(13)  
		+ ' 	RecordType   VARCHAR(50),' + CHAR(13)  
		+ ' 	DataFound    BIT,' + CHAR(13)  
		+ ' 	GUID         UNIQUEIDENTIFIER,' + CHAR(13)  
		+ ' 	Name         NVARCHAR(255),' + CHAR(13)  
		+ ' 	Address      NVARCHAR(2000),' + CHAR(13)  
		+ ' 	Email        NVARCHAR(500),' + CHAR(13)  
		+ ' 	Phone        NVARCHAR(255)' + CHAR(13)  
		+ ' 	---HyperLink    NVARCHAR(255),' + CHAR(13)  
		+ ' 	---RecordOwner  NVARCHAR(255)' + CHAR(13)  
		+ ' )' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' --DECLARE @GUIDCurrent INT' + CHAR(13)  
		+ ' ' + CHAR(13)  
		  
	IF @GUIDType = 'Account'   
	BEGIN  
		SET @sql = @sql   
			+ ' ' + CHAR(13)  
			+ ' 	INSERT INTO @baseData' + CHAR(13)  
			+ ' 	(GUIDType, RecordType, DataFound, GUID, Name, Address, Email, Phone)' + CHAR(13)  
			+ ' 	SELECT ''' + @GUIDType + ''' GUIDType' + CHAR(13)  
			+ ' 		, CASE WHEN a.position = 1 THEN ''Master'' ELSE ''Slave'' END RecordType' + CHAR(13)  
			+ ' 		, CASE WHEN LEN(b.SSB_CRMSYSTEM_ContactACCT_ID) = 0 THEN 0 ELSE 1 END DataFound' + CHAR(13)  
			+ ' 		, value GUID' + CHAR(13)  
			+ ' 		, ISNULL(d.FirstName, '''') + '' '' + ISNULL(d.LastName, '''') Name ' + CHAR(13)  
			+ ' 		, d.AddressPrimaryStreet + '' '' + d.AddressPrimaryCity + '', '' + d.AddressPrimaryState + '' '' + d.AddressPrimaryZip Address' + CHAR(13)  
			+ ' 		, d.EmailPrimary Email' + CHAR(13)  
			+ ' 		, d.PhonePrimary Phone' + CHAR(13)  
			+ ' 		----, ''https://na3.salesforce.com/'' + b.Id HyperLink' + CHAR(13)  
			+ ' 		----, c.Name RecordOwner' + CHAR(13)  
			+ ' 	FROM dbo.fn_Split(''' + @GUID + ''','','') a' + CHAR(13)  
			+ ' 	left join ' + @ClientDB + 'dbo.dimcustomerssbid b' + CHAR(13)  
			+ ' 	on a.value = b.ssb_crmsystem_contactacct_id AND b.SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG = 1' + CHAR(13)  
			+ ' 	LEFT JOIN ' + @ClientDB + 'mdm.compositerecord d ' + CHAR(13)  
			+ ' 	ON b.ssb_crmsystem_contact_id = d.ssb_crmsystem_contact_id' + CHAR(13)  
			+ ' ' + CHAR(13)  
	END  
  
	IF @GUIDType = 'Contact'  
	BEGIN  
		SET @sql = @sql   
			+ ' ' + CHAR(13)  
			+ ' 	INSERT INTO @baseData' + CHAR(13)  
			+ ' 	(GUIDType, RecordType, DataFound, GUID, Name, Address, Email, Phone)' + CHAR(13)  
			+ ' 	SELECT ''' + @GUIDType + ''' GUIDType' + CHAR(13)  
			+ ' 		, CASE WHEN a.position = 1 THEN ''Master'' ELSE ''Slave'' END RecordType' + CHAR(13)  
			+ ' 		, CASE WHEN LEN(d.SSB_CRMSYSTEM_CONTACT_ID) = 0 THEN 0 ELSE 1 END DataFound' + CHAR(13)  
			+ ' 		, value GUID' + CHAR(13)  
			+ ' 		, ISNULL(d.FirstName,'''') + '' '' + ISNULL(d.LastName ,'''') Name ' + CHAR(13)  
			+ ' 		, d.AddressPrimaryStreet + '' '' + d.AddressPrimaryCity + '', '' + d.AddressPrimaryState + '' '' + d.AddressPrimaryZip Address' + CHAR(13)  
			+ ' 		, d.EmailPrimary Email' + CHAR(13)  
			+ ' 		, d.PhonePrimary Phone' + CHAR(13)  
			+ ' 		----, ''https://na3.salesforce.com/'' + b.Id HyperLink' + CHAR(13)  
			+ ' 		----, c.Name RecordOwner' + CHAR(13)  
			+ ' 	FROM dbo.fn_Split(''' + @GUID + ''','','') a' + CHAR(13)  
			+ ' 	LEFT JOIN ' + @ClientDB + 'mdm.compositerecord d ' + CHAR(13)  
			+ ' 	ON a.value = d.ssb_crmsystem_contact_id' + CHAR(13)  
			+ ' ' + CHAR(13)	  
	END  
  
	SET @sql = @sql   
		+ ' ' + CHAR(13)  
		+ ' -- Set counts' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SELECT @totalCount = COUNT(*) FROM @baseData  -- If paging were enabled, you wouldn''t count here' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' -- Create XML response data node' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SET @xmlDataNode = (SELECT' + CHAR(13)  
		+ ' 	GUIDType, RecordType, DataFound, GUID, ' + CHAR(13)  
		+ ' 	CASE WHEN Name = '' '' OR Name IS NULL THEN '''' ELSE Name END AS Name, ' + CHAR(13)  
		+ ' 	ISNULL(Address, '''') AS Address, ' + CHAR(13)  
		+ ' 	ISNULL(Email, '''') AS Email, ' + CHAR(13)  
		+ ' 	ISNULL(Phone, '''') AS Phone' + CHAR(13)  
		+ ' 	---ISNULL(HyperLink, '''') AS HyperLink,' + CHAR(13)  
		+ ' 	---ISNULL(RecordOwner, '''') AS RecordOwner' + CHAR(13)  
		+ ' 	FROM @baseData' + CHAR(13)  
		+ ' 	FOR XML PATH (''Detail''), ROOT(''Details''))' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SET @rootNodeName = ''Details''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' -- Create response info node' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SET @responseInfoNode = (''<ResponseInfo>''' + CHAR(13)  
		+ ' 	+ ''<TotalCount>'' + CAST(@totalCount AS NVARCHAR(20)) + ''</TotalCount>''' + CHAR(13)  
		+ ' 	+ ''<RemainingCount>0</RemainingCount>''' + CHAR(13)  
		+ ' 	+ ''<RecordsInResponse>'' + CAST(@totalCount AS NVARCHAR(20)) + ''</RecordsInResponse>''' + CHAR(13)  
		+ ' 	+ ''<PagedResponse>false</PagedResponse>''' + CHAR(13)  
		+ ' 	+ ''<RowsPerPage></RowsPerPage>''' + CHAR(13)  
		+ ' 	+ ''<PageNumber></PageNumber>''' + CHAR(13)  
		+ ' 	+ ''<RootNodeName>'' + @rootNodeName + ''</RootNodeName>''' + CHAR(13)  
		+ ' 	+ ''</ResponseInfo>'')' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' -- Wrap response info and data, then return' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' SET @finalXml = ''<Root>'' + @responseInfoNode + CAST(@xmlDataNode AS NVARCHAR(MAX)) + ''</Root>''' + CHAR(13)  
		+ '' + CHAR(13)  
		+ ' SELECT CAST(@finalXml AS XML)' + CHAR(13)  
	  
	-- SELECT @sql  
  
	EXEC sp_executesql @sql, N'@finalXml XML OUTPUT', @finalXml OUTPUT  
  
END
GO
