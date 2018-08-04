SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [api].[sp_API_Merge]  
	@ClientDB varchar(50)  
	, @GUIDType VARCHAR(50) = 'Contact'  
	, @GUID AS VARCHAR(8000)  
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
		, @winner varchar(50)  
		, @losers as varchar(8000)  
		, @MergeType AS VARCHAR(50)  
		--, @GUIDType AS varchar(50) = 'Contact'  
		--, @Guid as varchar(8000) = '00004FA0-7FB5-4DF1-94BB-0A6D302856BC,000088DD-87BD-4895-8E31-F5A9EFBC883E';  
  
	--SET @MergeType = 'Merge'  
	--SET @GUIDType = 'Contact'  
	--set @guid = '273CCC80-80B5-4680-A065-A49D749FC463,35AA140C-4EE1-41B0-AEAD-56E38FB2FA70';  
	--SET @GUID = '0139a1ab-8906-4662-b45b-816a5da8403d, ea86647e-94b5-42e9-932e-22a4707dec20, 8aa21d3d-b5cb-42ec-b1f2-9ddfcf2620e3'  
	  
	SET @winner =  left(@guid,charindex(',',@guid)-1);  
	set @losers =  substring(@guid,charindex(',',@guid)+1,len(@guid)-charindex(',',@guid));   
  
  
	SET @sql = @sql  
		+ 'DECLARE @LoserCount AS INT, @LoserValidCount int, @LoserNotRecognized INT, @AlreadyAttempted INT' + CHAR(13)  
		+ '' + CHAR(13)  
		+ ' DECLARE @WinnerTbl TABLE (' + CHAR(13)  
		+ ' MergeType VARCHAR(50)' + CHAR(13)  
		+ ' , GUIDType VARCHAR(50)' + CHAR(13)  
		+ ' , Winner VARCHAR(50)' + CHAR(13)  
		+ ' , Winner_DimCustomerID INT' + CHAR(13)  
		+ ' ) ' + CHAR(13)  
		+ '' + CHAR(13)  
		+ ' DECLARE @FullTable TABLE (' + CHAR(13)  
		+ ' MergeType VARCHAR(50)' + CHAR(13)  
		+ ' , GUIDType VARCHAR(50)' + CHAR(13)  
		+ ' , Winner VARCHAR(50)' + CHAR(13)  
		+ ' , Loser VARCHAR(50)' + CHAR(13)  
		+ ' , Winner_DimCustomerID INT' + CHAR(13)  
		+ ' , Loser_DimCustomerID INT' + CHAR(13)  
		+ ' , ValidLosers INT' + CHAR(13)  
		+ ' , HistoryFoundLosers INT' + CHAR(13)  
		+ ' , HistorySSIDMatchesMaster int' + CHAR(13)  
		+ ' )' + CHAR(13)  
		+ '' + CHAR(13)  
		  
		+ ' BEGIN TRY' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		INSERT into @WinnerTbl (MergeType, GUIDType, Winner, Winner_DimCustomerID)' + CHAR(13)  
		+ '		SELECT ''' + ISNULL(@MergeType,'') + ''',''' + @GUIDType + ''',''' + @winner + ''', dimcustomerid' + CHAR(13)  
		+ '		from ' + @ClientDB + 'mdm.compositerecord winner' + CHAR(13)  
		+ '		where SSB_CRMSYSTEM_CONTACT_ID = ''' + @winner + ''';' + CHAR(13)   
		+ ''	 + CHAR(13)  
		+ '		IF @@RowCount = 0  -- If you have an error, return something like this:' + CHAR(13)  
		+ '			BEGIN' + CHAR(13)  
		+ '				SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage> Winning SSB ID Not Found </ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ '				SELECT CAST(@finalXml AS XML)' + CHAR(13)  
		+ '				RETURN' + CHAR(13)  
		+ '			END' + CHAR(13)  
		+ ''	 + CHAR(13)  
		+ '		INSERT INTO @FullTable' + CHAR(13)  
		+ '		        ( MergeType' + CHAR(13)  
		+ '		        , GUIDType' + CHAR(13)  
		+ '		        , Winner' + CHAR(13)  
		+ '		        , Winner_DimCustomerID' + CHAR(13)  
		+ '				, Loser' + CHAR(13)  
		+ '				, ValidLosers' + CHAR(13)  
		+ '		        )' + CHAR(13)  
		+ '		SELECT a.*, b.value, 0' + CHAR(13)  
		+ '		FROM @WinnerTbl a ' + CHAR(13)  
		+ '		, dbo.fn_Split(''' + @losers + ''','','') b' + CHAR(13)  
		+ ''	 + CHAR(13)  
		+ '		SET @loserCount = @@ROWCOUNT' + CHAR(13)  
		+ '		--PRINT @LoserCount' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @AlreadyAttempted = CASE WHEN (SELECT COUNT(*) FROM @FullTable a INNER JOIN API.Incoming_Merge b ON b.Loser_GUID = a.Loser AND a.Winner = b.Winning_GUID) > 0 THEN 1 ELSE 0 END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		IF @AlreadyAttempted > 0  -- If you have an error, return something like this:' + CHAR(13)  
		+ '			BEGIN' + CHAR(13)  
		+ '				DECLARE @DupWinner VARCHAR(50), @DupLoser VARCHAR(50), @MsgReturn VARCHAR(1000), @LoopedMsg VARCHAR(1000)' + CHAR(13)  
		+ '				DECLARE @LoopCounter INT' + CHAR(13)  
		+ '				SET @MsgReturn = ''Merging request already submitted for: ''' + CHAR(13)  
		+ '				SET @LoopCounter = 1' + CHAR(13)  
		+ '				SET @LoopedMsg = ''''' + CHAR(13)  
		+ '				SET @DupWinner = ''' + @winner + '''' + CHAR(13)  
		+ ' ' + CHAR(13)		  
		+ '				DECLARE @ReturnTable TABLE (' + CHAR(13)  
		+ '				UID int IDENTITY(1,1)' + CHAR(13)  
		+ '				, Loser varchar(50)' + CHAR(13)  
		+ '				)' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '				INSERT INTO @ReturnTable ( Loser )' + CHAR(13)  
		+ '				SELECT Loser FROM @FullTable a INNER JOIN API.Incoming_Merge b ON b.Loser_GUID = a.Loser AND a.Winner = b.Winning_GUID' + CHAR(13)  
		+ '				GROUP BY Loser HAVING COUNT(*) > 0' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '				WHILE @AlreadyAttempted >= @LoopCounter' + CHAR(13)  
		+ '				BEGIN' + CHAR(13)  
		+ '					PRINT @LoopCounter' + CHAR(13)  
		+ '					SET @DupLoser = (SELECT Loser FROM @ReturnTable WHERE UID = @LoopCounter)' + CHAR(13)  
		+ '					SET @LoopedMsg = @LoopedMsg + ''~BR~Winner - '' + @DupWinner + '', Loser - '' + @DupLoser' + CHAR(13)  
		+ '					SET @Loopcounter = @LoopCounter + 1' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '				END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '				SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage> '' + @MsgReturn + @LoopedMsg + '' </ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ '				SELECT CAST(@finalXml AS XML)' + CHAR(13)  
		+ '				RETURN' + CHAR(13)  
		+ '			END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		UPDATE a' + CHAR(13)  
		+ '		SET Loser_DimCustomerID = b.DimCustomerId, ValidLosers = CASE WHEN b.DimCustomerId IS NOT NULL THEN 1 ELSE 0 END' + CHAR(13)  
		+ '		FROM @FullTable a ' + CHAR(13)  
		+ '		INNER JOIN ' + @ClientDB + 'mdm.compositerecord b ON a.Loser = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @LoserValidCount = @@ROWCOUNT' + CHAR(13)  
		+ '		--PRINT @LoserValidCount' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		IF @LoserCount <> @LoserValidCount' + CHAR(13)  
		+ '		BEGIN' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		UPDATE a' + CHAR(13)  
		+ '		SET Loser_DimCustomerID = c.DimCustomerId' + CHAR(13)  
		+ '		, HistoryFoundLosers = 1' + CHAR(13)  
		+ '		--, HistorySSIDMatchesMaster = CASE WHEN c.SSB_CRMSYSTEM_CONTACT_ID = a.Winner THEN 1 ELSE 0 END' + CHAR(13)  
		+ '		--SELECT * ' + CHAR(13)  
		+ '		FROM @FullTable a ' + CHAR(13)  
		+ '		INNER JOIN (SELECT DISTINCT SSB_CRMSYSTEM_CONTACT_ID, SSID FROM ' + @ClientDB + 'mdm.SSB_ID_History WHERE ssb_crmsystem_primary_flag = 1) b ON a.Loser = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
		+ '		INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c ON b.SSID = c.SSID' + CHAR(13)  
		+ '		WHERE ValidLosers = 0' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		SET @LoserNotRecognized = CASE WHEN (SELECT COUNT(*) FROM @FullTable WHERE HistoryFoundLosers = 0 AND ValidLosers = 0) > 0 THEN 1 ELSE 0 END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		IF @LoserNotRecognized = 1 -- If you have an error, return something like this:' + CHAR(13)  
		+ '			BEGIN' + CHAR(13)  
		+ '				SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage> Losing SSB ID Not Found </ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ '				SELECT CAST(@finalXml AS XML)' + CHAR(13)  
		+ '				RETURN' + CHAR(13)  
		+ '			END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '			IF @@Error = 1  -- If you have an error, return something like this:' + CHAR(13)  
		+ '			BEGIN' + CHAR(13)  
		+ '				SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>An error has occured.</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ '				SELECT CAST(@finalXml AS XML)' + CHAR(13)  
		+ '				RETURN' + CHAR(13)  
		+ '			END' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		--SET @AlreadyAttempted = 1	' + CHAR(13)  
		+ '		MERGE ' + @ClientDB + 'API.Incoming_Merge TARGET ' + CHAR(13)  
		+ '		USING @FULLTable SOURCE' + CHAR(13)  
		+ '		ON SOURCE.Winner = TARGET.Winning_GUID AND SOURCE.Loser = TARGET.Loser_GUID' + CHAR(13)  
		+ '		WHEN MATCHED THEN ' + CHAR(13)  
		+ '		UPDATE SET LastAttemptedDate = GETDATE()' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ '		WHEN NOT MATCHED THEN' + CHAR(13)  
		+ '		INSERT ( ' + CHAR(13)  
		+ '				Winning_GUID' + CHAR(13)  
		+ '				, Loser_GUID' + CHAR(13)  
		+ '		        , GUIDType' + CHAR(13)  
		+ '		        , Winning_DimCustomerID' + CHAR(13)  
		+ '				, Loser_DimCustomerID' + CHAR(13)  
		+ '		        , CreatedDate' + CHAR(13)  
		+ '		        , LastAttemptedDate' + CHAR(13)  
		+ '		        )' + CHAR(13)  
		+ '		VALUES ( SOURCE.Winner' + CHAR(13)  
		+ '				, SOURCE.Loser' + CHAR(13)  
		+ '				, SOURCE.GUIDType' + CHAR(13)  
		+ '				, SOURCE.Winner_DimCustomerID' + CHAR(13)  
		+ '				, SOURCE.Loser_DimCustomerID' + CHAR(13)  
		+ '				, GETDATE() --CreatedDate' + CHAR(13)  
		+ '				, GETDATE() --LastAttemptedDate' + CHAR(13)  
		+ '				) ;' + CHAR(13)  
		+ ' END TRY' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' BEGIN CATCH' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' 	SET @finalXml = ''<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data. '' + ERROR_MESSAGE() + ''</ErrorMessage></ResponseInfo></Root>''' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' END CATCH' + CHAR(13)  
		+ ' ' + CHAR(13)  
		+ ' -- If all''s well, return this:	' + CHAR(13)  
		+ ' SET @finalXml = ''<Root><ResponseInfo><Success>true</Success></ResponseInfo></Root>''' + CHAR(13)  
		+ ' SELECT CAST(@finalXml AS XML)' + CHAR(13)  
  
	----SELECT @sql  
	EXEC sp_executesql @sql, N'@finalXml XML OUTPUT', @finalXml OUTPUT  
  
END
GO
