SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
EXEC etl.LoadDimCustomer_AttributeChanges_new @ClientDB = 'PSP', -- varchar(50)
    @LoadView = 'psp.ods.vw_devils_datacom_loaddimcustomer', -- varchar(100)
    @LogLevel = 0 -- int

	select * from psp.mdm.auditlog order by logdate desc;
	*/


CREATE PROCEDURE [etl].[LoadDimCustomerAttributes] 
(
	@ClientDB VARCHAR(50),
	@LoadView VARCHAR(100),
	@LogLevel INT,
	@IsDataUploaderSource VARCHAR(10)
)
AS
BEGIN

--- TESTING
--DECLARE @clientdb VARCHAR(50) = 'MDM_CLIENT_TEST', @Loadview VARCHAR(100) = 'etl.tmp_changes_F96E4FF101624EF28309DB07203C0477', @IsDataUploaderSource VARCHAR(10) = '1';

-- Remove square brackets
SELECT @ClientDB = REPLACE(REPLACE(@ClientDB,'[',''),']','')
SELECT @LoadView = REPLACE(REPLACE(@LoadView,'[',''),']','')

-- Remove database name from @LoadView
SELECT @LoadView = CASE WHEN LEFT(@LoadView,LEN(@ClientDB + '.')) = @ClientDB + '.' THEN REPLACE(@LoadView, @ClientDB + '.', '') ELSE @LoadView END	

IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

IF (SELECT @@VERSION) NOT LIKE '%Azure%'
BEGIN
SET @ClientDB = @ClientDB + '.'
END

DECLARE @SQL NVARCHAR(MAX) = '',  @SessionCounter INT = 1

SET @SQL = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @SQL
SET @SQL = ''

IF OBJECT_ID('tempdb..#AttributeGroupList') IS NOT NULL
	DROP TABLE #AttributeGroupList

CREATE TABLE #AttributeGroupList (
UID INT IDENTITY(1,1) PRIMARY KEY
, AttributeGroupID Int
)

IF OBJECT_ID('tempdb..#SessionList') IS NOT NULL
	DROP TABLE #SessionList

CREATE TABLE #SessionList (
	ID INT
	,SessionId UNIQUEIDENTIFIER
)

INSERT INTO #SessionList (ID, SessionId) VALUES  (1, NEWID())

SET @SQL = @SQL
+ ' INSERT INTO #AttributeGroupList (AttributeGroupID)' + CHAR(13)
+ ' SELECT AttributeGroupID FROM ' + @ClientDB + 'mdm.AttributeGroup' + CHAR(13)

EXEC sp_executesql @SQL
--SELECT * FROM #AttributeGroupList

DECLARE @AttributeLoop INT, @Counter INT, @AttributeGroupID VARCHAR(10)

SET @AttributeLoop = (SELECT MAX(AttributeGroupID) FROM #AttributeGroupList)
SET @Counter = 1


declare @sessionsql NVARCHAR(MAX) = ''
		IF @IsDataUploaderSource = '1'
		Begin
				TRUNCATE TABLE #SessionList

				SET @sessionsql = @sessionsql
				+ ' INSERT INTO #sessionList (ID, SessionId)'
				+ ' SELECT ROW_NUMBER() OVER (ORDER BY RecordCreateDate DESC) as ID, a.SessionId' + CHAR(13)
				+ ' FROM (' + CHAR(13)
				+ ' 	SELECT DISTINCT SessionId, MAX(RecordCreateDate) RecordCreateDate' + CHAR(13)
				+ ' 	from ' + @ClientDB + @LoadView + CHAR(13)
				+ ' where processed = 0 ' + CHAR(13)
				+ ' 	GROUP BY SessionId' + CHAR(13)
				+ ' ) a' + CHAR(13)				
		
	EXEC sp_executesql @sessionsql
	
	----select * from #sessionlist;	
		END

WHILE @SessionCounter <= (SELECT MAX(ID) FROM #SessionList)
BEGIN

print 'SessionCounter = ' + cast(@sessioncounter as varchar)
	
	
	WHILE @AttributeLoop >= @Counter
	BEGIN

	SET @AttributeGroupID = (SELECT CAST(AttributeGroupID AS VARCHAR) FROM #AttributeGroupList WHERE UID = @Counter)

	print 'AttributeGroupID = ' + cast(@attributegroupID as varchar)
	
		DECLARE @SQL2 NVARCHAR(MAX) = '';
		DECLARE @FieldList VARCHAR(MAX) = '';
		DECLARE @FieldList2 VARCHAR(MAX) = '';
		SET @SQL = '';


		---DECLARE  @AttributeGroupID VARCHAR(5) = '5'
		---DECLARE @clientdb VARCHAR(50) = 'PSP', @Loadview VARCHAR(100) = '.dbo.tmp_dataupload', @IsDataUploaderSource VARCHAR(10) = '1';

		IF @IsDataUploaderSource = '0'
		Begin
		SET @sql2 = @sql2 
		+' SELECT  @FieldList = COALESCE(@FieldList + '' '', '''') + lower(a.COLUMN_Name) + '',''' + CHAR(13)
		+ ', @FieldList2 = null '
		+' FROM '+@clientdb+'INFORMATION_SCHEMA.COLUMNS A ' + CHAR(13)
		+' INNER JOIN ' + @ClientDB + 'mdm.attributes b ' + CHAR(13)
		+' ON a.column_name = b.attribute ' + CHAR(13)
		+' WHERE Table_Catalog + ''.'' + Table_Schema + ''.'' +TABLE_NAME = N'''+ @ClientDB + @LoadView + ''' AND b.AttributeGroupId = '+ @AttributeGroupID  + CHAR(13)
		END
		else
		BEGIN
			
			-- Select a single row of dynamic data from whatever session we're processing
			SET @sql2 = @sql2  
			+ ' DECLARE @xml xml' + CHAR(13)
			+ ' SELECT top 1 @xml = DynamicData ' + CHAR(13)
			+ ' from ' + @ClientDB + @LoadView + ' a' + CHAR(13)
			+ ' inner join #SessionList b on a.SessionId = b.SessionId' + CHAR(13)
			+ ' where b.ID = ' + CAST(@SessionCounter AS VARCHAR(10)) + CHAR(13)



			SET @sql2 = @sql2 
				+' SELECT   @FieldList = COALESCE(@FieldList + '' '', '''') + Col.value(''local-name(.)'', ''nvarchar(100)'') + '',''' + CHAR(13)
				+ ', @FieldList2 = COALESCE(@FieldList2 + '' '', '''') + ''attr.value(''''('' + Col.value(''local-name(.)'', ''nvarchar(100)'')  + ''/text())[1]'''',  ''''varchar(max)'''') as '' + lower(attribute)  + '',''' + CHAR(13)  
				+ ' from @xml.nodes(''//DynamicData/*'') as Tbl(Col) ' + CHAR(13)
				+ ' inner join ' + @ClientDB + 'mdm.attributes b' + CHAR(13)
				+ 'ON Col.value(''local-name(.)'', ''nvarchar(100)'') = b.attribute ' + CHAR(13)
				+ ' where AttributeGroupId = '+ @AttributeGroupID  + CHAR(13)

		End

		EXEC sp_executesql @SQL2
				, N'@FieldList nvarchar(max) OUTPUT, @FieldList2 nvarchar(max) OUTPUT'
			   , @FieldList OUTPUT
			   , @FieldList2 OUTPUT
       
		----SELECT @FieldList
		----SELECT @FieldLIst2

	IF ISNULL(@FieldList,'') != ''
	BEGIN

		IF @IsDataUploaderSource = '0'
		begin
			SET @SQL = @SQL
		--+' SELECT *  ' + CHAR(13)
		--+' INTO #tmpCustomerAttributes ' + CHAR(13)
		--+' From '+ @ClientDB + @LoadView  + CHAR(13)
		--+ 'WHERE RecordRank = 1' + CHAR(13)

		+ ' SELECT a.*, cast(Replace((SELECT ' + LEFT(@FieldList,LEN(@FieldList)-1) + CHAR(13)
		+ ' FROM '+ @ClientDB + @LoadView + ' as dimcustomerattributes  ' + CHAR(13)
		+ ' WHERE ssid = a.ssid AND sourcesystem = a.sourcesystem and RecordRank = 1' + CHAR(13)
		+ ' FOR XML AUTO, ELEMENTS XSINIL), ''&'', ''&amp;'') as XML) AS attributes  ' + CHAR(13)
		+ ' INTO #tmpCustomerAttributes' + CHAR(13)
		+ ' FROM '+ @ClientDB + @LoadView + ' a' + CHAR(13)
		+ ' WHERE RecordRank = 1' + CHAR(13) + CHAR(13)

		+ ' SELECT SSID, SOURCESYSTEM' + CHAR(13)
		+ '		,attr.value(''local-name(.)'', ''varchar(500)'') AS AttributeName' + CHAR(13)
		+ '		,attr.value(''(.)[1]'', ''varchar(max)'') AS AttributeValue' + CHAR(13)
		+ ' INTO #tmpAttributeValues' + CHAR(13)
		+ ' From #tmpCustomerAttributes a' + CHAR(13)
		+' CROSS APPLY attributes.nodes(''dimcustomerattributes/*'') AS attributes(attr)' + CHAR(13)
		+ 'WHERE RecordRank = 1' + CHAR(13) + CHAR(13)
		end
		ELSE
		Begin
		SET @sql = @sql 
		
		+' SELECT ' + @fieldlist2 + ' SSID, SOURCESYSTEM  '
		 +' INTO #tmpCustomerAttributes ' + CHAR(13)
		+' From '+ @ClientDB + @LoadView + ' a' + CHAR(13)
		+ ' inner join #SessionList b on a.SessionId = b.SessionId' + CHAR(13)
			+ ' and b.ID = ' + CAST(@SessionCounter AS VARCHAR(10)) + CHAR(13)
		+' CROSS APPLY DynamicData.nodes(''DynamicData'') AS DynamicData(attr)'
		+ 'WHERE RecordRank = 1' + CHAR(13) + CHAR(13)

		+ ' SELECT SSID, SOURCESYSTEM' + CHAR(13)
		+ '		,attr.value(''local-name(.)'', ''varchar(500)'') AS AttributeName' + CHAR(13)
		+ '		,attr.value(''(.)[1]'', ''varchar(max)'') AS AttributeValue' + CHAR(13)
		+ ' INTO #tmpAttributeValues ' + CHAR(13)
		+ ' From '+ @ClientDB + @LoadView + ' a' + CHAR(13)
		+ ' inner join #SessionList b on a.SessionId = b.SessionId' + CHAR(13)
			+ ' and b.ID = ' + CAST(@SessionCounter AS VARCHAR(10)) + CHAR(13)
		+' CROSS APPLY DynamicData.nodes(''DynamicData/*'') AS DynamicData(attr)' + CHAR(13)
		+ 'WHERE RecordRank = 1' + CHAR(13) + CHAR(13)

		END

		SET @SQL = @SQL
		+'ALTER TABLE #tmpCustomerAttributes' + CHAR(13)
		+'ALTER COLUMN SSID NVARCHAR(100)' + CHAR(13)
		+ CHAR(13)
		+'ALTER TABLE #tmpCustomerAttributes' + CHAR(13)
		+'ALTER COLUMN SourceSystem NVARCHAR(100)' + CHAR(13)
		+ CHAR(13)

		+ ' CREATE INDEX ix_ssid ON #tmpCustomerAttributes (SSID, SOURCESYSTEM); ' + CHAR(13)
		+ ' CREATE INDEX ix_ssid ON #tmpAttributeValues (SSID, SOURCESYSTEM); ' + CHAR(13)

		--+ ' Select * from #tmpCustomerAttributes ' + CHAR(13)
		--+ ' SELECT * FROM #tmpAttributeValues' + CHAR(13)

		+' Declare @output Table(DimCustomerAttrID INT, SSID varchar(100), SourceSystem varchar(50), change varchar(20))'+ CHAR(13)+ CHAR(13)

		+ ' MERGE ' + @ClientDB +'dbo.DimCustomerAttributes AS myTarget ' + CHAR(13)
		+ ' USING ( Select distinct b.dimcustomerid, b.SSID, b.SourceSystem, ' + @AttributeGroupID +' as AttributeGroupID,  ' + CHAR(13)
		+ ' Replace((SELECT '+ @FieldList + ' SSID, SourceSystem  ' + CHAR(13)
		+ ' FROM  #tmpCustomerAttributes as dimcustomerattributes  ' + CHAR(13)
		+ ' WHERE ssid = a.ssid AND sourcesystem = a.sourcesystem  ' + CHAR(13)
		+ ' FOR XML AUTO, ELEMENTS XSINIL), ''&'', ''&amp;'') AS attributes  ' + CHAR(13)
		+ ' FROM  #tmpCustomerAttributes a  ' + CHAR(13)
		+ ' INNER JOIN '+ @ClientDB + 'dbo.dimcustomer b  ' + CHAR(13)
		+ ' ON a.ssid = b.ssid AND a.sourcesystem = b.sourcesystem) as mySource ' + CHAR(13)
		+ '     ON ' + CHAR(13)
		+ ' 	 myTarget.dimcustomerid = mySource.dimcustomerid ' + CHAR(13)
		+ ' 	and myTarget.AttributeGroupID = mySource.AttributeGroupID ' + CHAR(13)
		+ ' WHEN MATCHED AND (CAST(myTarget.Attributes AS VARCHAR(MAX)) != CAST(mySource.Attributes AS VARCHAR(MAX)))' + CHAR(13)
		+ ' THEN UPDATE SET myTarget.Attributes =  mySource.attributes' + CHAR(13) 
		+ '		, myTarget.UpdatedDate = SYSDATETIME()' + CHAR(13)
		+' WHEN NOT MATCHED  ' + CHAR(13)
		+' Then Insert (dimcustomerid, attributegroupid, attributes)  ' + CHAR(13)
		+' values(mySource.Dimcustomerid, mySource.AttributeGroupID, mySource.Attributes) ' + CHAR(13)
		+' OUTPUT inserted.DimCUstomerAttrID, mySource.SSID, mySource.SourceSystem, $action into @output;' + CHAR(13) + CHAR(13)

		----+ ' SELECT * FROM @output' + CHAR(13)
		
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ 'values (current_timestamp, ''Load DimCustomerAttributes'', ''Attribute Changes - INSERT'',  (Select count(0) from @output where change = ''INSERT''));' + CHAR(13) + CHAR(13)
	
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ 'values (current_timestamp, ''Load DimCustomerAttributes'', ''Attribute Changes - Update'',  (Select count(0) from @output where change = ''UPDATE''));' + CHAR(13) + CHAR(13)
	
		+ ' DECLARE @indexesDisabled BIT = 0' + CHAR(13) + CHAR(13)

		+ ' IF (' + CHAR(13)
		+ '		SELECT COUNT(0)' + CHAR(13)
		+ '		FROM @output a' + CHAR(13)
		+ '		INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributeValues b ON a.DimCustomerAttrID = b.DimCustomerAttrID) > 100000' + CHAR(13)
		+ ' OR (' + CHAR(13)
		+ '		SELECT COUNT(0)' + CHAR(13)
		+ '		FROM #tmpAttributeValues a) > 100000' + CHAR(13)
		+ ' BEGIN' + CHAR(13)
		+ '		EXEC dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
		+ ' 									 @TableName = ''dbo.DimCustomerAttributeValues'',' + CHAR(13)
		+ ' 									 @ViewCurrentIndexState = 0' + CHAR(13) + CHAR(13)

		+ '		Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ '		values (current_timestamp, ''Load DimCustomerAttributeValues'', ''Disable Indexes'',  0);' + CHAR(13) + CHAR(13)
		
		+ '		SET @indexesDisabled = 1' + CHAR(13)
		+ ' END' + CHAR(13) + CHAR(13)

		+ ' DELETE b' + CHAR(13)
		+ ' FROM @output a' + CHAR(13)
		+ '	INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributeValues b ON a.DimCustomerAttrID = b.DimCustomerAttrID' + CHAR(13) + CHAR(13)

		+ ' INSERT INTO ' + @ClientDB + 'dbo.DimCustomerAttributeValues (DimCustomerAttrID, AttributeName, AttributeValue)' + CHAR(13)
		+ ' SELECT a.DimCustomerAttrID, c.Attribute, b.AttributeValue' + CHAR(13)
		+ ' FROM @output a' + CHAR(13)
		+ '	INNER JOIN #tmpAttributeValues b ON a.SSID = b.SSID' + CHAR(13)
		+ '		AND a.SourceSystem = b.SourceSystem' + CHAR(13)
		+ ' INNER JOIN ' + @ClientDB + 'mdm.Attributes c ON c.AttributeGroupID = ' + @AttributeGroupID + CHAR(13) 
		+ '		AND b.AttributeName = c.Attribute' + CHAR(13)
		+ ' INNER JOIN ' + @ClientDB + 'mdm.AttributeGroup d ON c.AttributeGroupID = d.AttributeGroupID' + CHAR(13)+ CHAR(13)
		
		
		+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ ' values (current_timestamp, ''Load DimCustomerAttributeValues'', ''Insert records'',  @@ROWCOUNT);' + CHAR(13) + CHAR(13)
	
		+ ' IF @indexesDisabled = 1' + CHAR(13)
		+ ' BEGIN'
		+ '		EXEC dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
		+ '										 @TableName = ''dbo.DimCustomerAttributeValues'',' + CHAR(13)
		+ '										 @ViewCurrentIndexState = 0' + CHAR(13) + CHAR(13)
		 
		+ '		Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ '		values (current_timestamp, ''Load DimCustomerAttributeValues'', ''Enable Indexes'',  0);' + CHAR(13)
		+ ' END' + CHAR(13) + CHAR(13)

 		-- Add TRY/CATCH block to force stoppage and log error      
		SET @sql = ''     
			+ ' BEGIN TRY' + CHAR(13)      
			+ @SQL
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

		----SELECT @SQL
		EXEC sp_executesql @sql

		END

		SET @Counter = @counter + 1
	
	END

	SET @SessionCounter = @SessionCounter + 1
	Set @Counter = 1
END

SET @SQL = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @SQL

END
GO
