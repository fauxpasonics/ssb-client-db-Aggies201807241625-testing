SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [api].[sp_SubmitUnmerge]   
	@PostData NVARCHAR(MAX)  
AS  
BEGIN  
	-- For Response  
	DECLARE  
		@ClientDB VARCHAR(50) = ''   
		, @sql NVARCHAR(MAX) = ''  
		, @finalXml XML  
  
	-- For Final Data' + CHAR(13)  
	CREATE TABLE #DataTable (  
		[ClientDB]  [NVARCHAR](50)  NOT NULL,  
		[Type]      [NVARCHAR](50)  NOT NULL,  
		[ParentID]  [NVARCHAR](50)  NOT NULL,  
		[ChildID]   [NVARCHAR](50)  NOT NULL,  
		[New]       [BIT]           NOT NULL,  
		[LoadDate]  [DATETIME]      NOT NULL DEFAULT GETDATE()  
	)  
  
	SET @sql = @sql  
	+ ' -- For Parsing' + CHAR(13)  
	+ ' DECLARE @ParentObjectId INT' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' -- For JSON' + CHAR(13)  
	+ ' DECLARE @baseData  TABLE (' + CHAR(13)  
	+ ' 	ElementId      INT NOT NULL,' + CHAR(13)  
	+ ' 	SequenceNum    INT NULL,' + CHAR(13)  
	+ ' 	ParentId       INT NULL,' + CHAR(13)  
	+ ' 	ObjectId       INT NULL,' + CHAR(13)  
	+ ' 	Name           NVARCHAR(2000),' + CHAR(13)  
	+ ' 	StringValue    NVARCHAR(MAX) NOT NULL,' + CHAR(13)  
	+ ' 	ValueType      VARCHAR(10) NOT NULL' + CHAR(13)  
	+ ' )' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' BEGIN TRY' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' 	-- Parse JSON data into JSON staging table' + CHAR(13)  
	+ ' 	INSERT INTO @baseData' + CHAR(13)  
	+ ' 		(ElementId, SequenceNum, ParentId, ObjectId, Name, StringValue, ValueType)' + CHAR(13)  
	+ ' 	SELECT element_id, sequenceNo, parent_ID, Object_ID, NAME, StringValue, ValueType' + CHAR(13)  
	+ ' 	FROM parseJSON(''' + @PostData + ''')' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' 	-- Pull Parent object id - needed to know what data to retrieve for individual records from the staging table' + CHAR(13)  
	+ ' 	SELECT @ParentObjectId = ObjectId ' + CHAR(13)  
	+ ' 	FROM @baseData' + CHAR(13)  
	+ ' 	WHERE Name = ''UpdateObjects''' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ' + CHAR(13)	  
	+ ' 	-- Transpose and filter needed data into DataTable object for further processing' + CHAR(13)  
	+ ' 	INSERT INTO #DataTable' + CHAR(13)  
	+ ' 		(ClientDB, Type, ParentID, ChildID, New)' + CHAR(13)  
	+ ' 	SELECT d.ClientDB, d.Type, d.ParentID, d.ChildID,' + CHAR(13)  
	+ ' 		CASE WHEN LOWER(d.New) = ''true'' THEN 1 ELSE 0 END' + CHAR(13)  
	+ ' 	FROM' + CHAR(13)  
	+ ' 	(' + CHAR(13)  
	+ ' 	SELECT ParentId JsonId,' + CHAR(13)  
	+ ' 		MAX(CASE WHEN Name = ''ClientDB'' THEN StringValue END) ClientDB,' + CHAR(13)  
	+ ' 		MAX(CASE WHEN Name = ''Type'' THEN StringValue END) Type,' + CHAR(13)  
	+ ' 		MAX(CASE WHEN Name = ''ParentID'' THEN StringValue END) ParentID,' + CHAR(13)  
	+ ' 		MAX(CASE WHEN Name = ''ChildID'' THEN StringValue END) ChildID,' + CHAR(13)  
	+ ' 		MAX(CASE WHEN Name = ''New'' THEN StringValue END) New' + CHAR(13)  
	+ ' 	FROM @baseData' + CHAR(13)  
	+ ' 	WHERE ParentId IN (SELECT ObjectId FROM @baseData WHERE ParentId = @ParentObjectId)' + CHAR(13)  
	+ ' 	GROUP BY ParentId' + CHAR(13)  
	+ ' 	) d' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ '		SELECT TOP 1 @ClientDB = ' + CHAR(13)  
	+ '			CASE WHEN @@VERSION LIKE ''%Azure%'' THEN '''' ELSE ClientDB + ''.'' END' + CHAR(13)  
	+ '		FROM #DataTable' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' END TRY' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' BEGIN CATCH' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' 	SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data.  '' + ERROR_MESSAGE() + ''</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' END CATCH' + CHAR(13)  
	  
	EXEC sp_executesql @sql, N'@ClientDB VARCHAR(50) OUTPUT, @finalXml XML OUTPUT', @ClientDB OUTPUT, @finalXml OUTPUT  
	--SELECT @ClientDB, @finalXml  
	  
	SET @sql = '' -- reset sql  
  
	IF @finalXml IS NULL  
	BEGIN  
		SET @sql = @sql  
		+ ' BEGIN TRY' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' 	INSERT INTO ' + @ClientDB + 'api.Incoming_Unmerge' + CHAR(13)  
		+ ' 		(Type, ParentID, ChildID, New, LoadDate)' + CHAR(13)  
		+ ' 	SELECT Type, ParentID, ChildID, New, LoadDate ' + CHAR(13)  
		+ ' 	FROM #DataTable' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' 	SET @finalXml = ''<Root><ResponseInfo><Success>true</Success></ResponseInfo></Root>''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' END TRY' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' BEGIN CATCH' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' 	SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data. '' + ERROR_MESSAGE() + ''</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' END CATCH' + CHAR(13)  
	END  
		  
	SET @sql = @sql  
		+ ' -- Return response' + CHAR(13)  
		+ ' SELECT CAST(@finalXml AS XML)' + CHAR(13)  
  
	--SELECT @sql, @finalXml  
  
	EXEC sp_executesql @sql, N'@finalXml XML OUTPUT', @finalXml OUTPUT  
  
END
GO
