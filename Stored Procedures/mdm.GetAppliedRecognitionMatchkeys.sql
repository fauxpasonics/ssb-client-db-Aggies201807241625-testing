SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [mdm].[GetAppliedRecognitionMatchkeys]  
(	  
	@ClientDB VARCHAR(50)  
	,@IDList VARCHAR(MAX) -- Comma-separated list of contact, account or household IDs  
	,@IDType VARCHAR(25) = 'Contact' -- Type of ID's supplied in @IDList. Accepted values: Contact, Account, or Household. 
	,@MatchkeyType VARCHAR(25) = NULL -- Contact, Account, or Household. If supplied the results will be limited to the specified type. 
)  
AS  
BEGIN  
 
/********************************************************************************************************************************************  
----------------------------------------------------------------------------------------- 
-- USAGE EXAMPLE 
----------------------------------------------------------------------------------------- 
 
DECLARE  
	@ClientDB VARCHAR(50) = 'Missouri' 
	,@IDList VARCHAR(MAX) = '0017CD68-A5E8-4B7A-BC56-E6429042C317' 
	,@IDType VARCHAR(25) = 'Contact' 
	,@MatchkeyType VARCHAR(25) = '' 
 
IF OBJECT_ID('tempdb..#data') IS NOT NULL 
	DROP TABLE #data 
 
CREATE TABLE #data ( 
	SSB_CRMSYSTEM_PRIMARY_FLAG VARCHAR(50) 
	,SSB_CRMSYSTEM_CONTACT_ID UNIQUEIDENTIFIER 
	,SSB_CRMSYSTEM_ACCT_ID UNIQUEIDENTIFIER 
	,SSB_CRMSYSTEM_HOUSEHOLD_ID UNIQUEIDENTIFIER 
	,SSID NVARCHAR(100) 
	,SourceSystem NVARCHAR(50) 
	,DimCustomerID INT 
	,MatchkeyType VARCHAR(50) 
	,MatchkeyID INT 
	,MatchkeyName VARCHAR(255) 
	,MatchkeyValue VARCHAR(50) 
	,MatchkeyHashPlainText VARCHAR(MAX) 
	,MatchkeyHash VARBINARY(32) 
	,InsertDate DATETIME 
	,UpdateDate DATETIME 
	,[mdm.ForceMergeID] VARCHAR(50) 
	,[mdm.ForceUnmergeId] VARCHAR(50) 
	,[mdm.ForceAcctGrouping] VARCHAR(50) 
	,[mdm.ForceHouseholdGrouping] VARCHAR(50) 
) 
 
INSERT INTO #data 
EXEC MDM.mdm.GetAppliedRecognitionMatchkeys @ClientDB = @ClientDB, 
                                            @IDList = @IDList, 
                                            @IDType = @IDType, 
                                            @MatchkeyType = @MatchkeyType 
 
SELECT * 
FROM #data 
********************************************************************************************************************************************/ 
  
	-- DEBUG -- 
	-- DECLARE @ClientDB VARCHAR(50) = 'Falcons', @IDList VARCHAR(MAX) = 'A799A7EB-1EAA-424F-B9AB-367073E95CD6,F59CC1AA-FB97-4AD5-9391-E218DC005BF6', @IDType VARCHAR(25) = 'Contact', @MatchkeyType VARCHAR(25) = 'Contact' 
 
	IF (SELECT @@VERSION) LIKE '%Azure%'       
		SET @ClientDB = ''       
  
	DECLARE @sql NVARCHAR(MAX) = ''   
 
	SET @IDList = REPLACE(REPLACE(REPLACE(REPLACE(@IDList,' ',''),CHAR(13),''),CHAR(10),''),CHAR(9),'') 
	  
	SET @sql = ''  
		+ ' ;WITH dimcustomerMatchkey AS (' + CHAR(13)  
		+ '		SELECT a.DimCustomerID' + CHAR(13) 
 		+ '			, c.MatchKeyType' + CHAR(13) 
 		+ '			, c.MatchkeyID' + CHAR(13) 
 		+ '			, c.MatchkeyName' + CHAR(13) 
 		+ '			, b.MatchkeyValue' + CHAR(13) 
 		+ '			, c.MatchkeyHashPlainText' + CHAR(13) 
		+ '			, c.MatchkeyHash' + CHAR(13) 
		+ '			, b.InsertDate' + CHAR(13) 
		+ '			, b.UpdateDate' + CHAR(13) 
		+ '		FROM ' + @ClientDB + '.dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13) 
		+ '		INNER JOIN ' + @ClientDB + '.dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerID' + CHAR(13) 
		+ '		INNER JOIN (' + CHAR(13) 
		+ '			SELECT a.MatchKeyType, a.MatchkeyID, a.MatchkeyName, b.MatchkeyHashID, b.MatchkeyHashPlainText, b.MatchkeyHash' + CHAR(13) 
		+ '			FROM ' + @ClientDB + '.mdm.MatchkeyConfig a WITH (NOLOCK)' + CHAR(13) 
		+ '			INNER JOIN ' + @ClientDB + '.mdm.MatchkeyHash b WITH (NOLOCK) ON a.MatchkeyHashIdentifier = b.MatchkeyHashIDName' + CHAR(13) 
		+ '			WHERE 1=1' + CHAR(13) 
		+ '			AND a.Active = 1' + CHAR(13) 
		+ '		) c ON b.MatchkeyValue = c.MatchkeyHashID' + CHAR(13) 
		+ '			AND b.MatchkeyID = c.MatchkeyID' + CHAR(13) 
		+ '		WHERE 1=1' + CHAR(13)  
		+ '		AND a.' + CASE  
							WHEN @IDType = 'Contact' THEN 'SSB_CRMSYSTEM_CONTACT_ID'  
							WHEN @IDType = 'Account' THEN 'SSB_CRMSYSTEM_ACCT_ID'  
							WHEN @IDType = 'Household' THEN 'SSB_CRMSYSTEM_HOUSEHOLD_ID'   
							ELSE ''  
						  END + ' IN (''' + REPLACE(@IDList,',',''',''') + ''')' + CHAR(13)  
		+ CASE WHEN ISNULL(@MatchkeyType,'') != '' THEN '		AND c.MatchkeyType = ''' + @MatchkeyType + '''' ELSE '' END + CHAR(13)  
		+ ' )' + CHAR(13)  
		+ ' SELECT a.SSB_CRMSYSTEM_PRIMARY_FLAG, a.SSB_CRMSYSTEM_CONTACT_ID, a.SSB_CRMSYSTEM_ACCT_ID, a.SSB_CRMSYSTEM_HOUSEHOLD_ID, b.SSID, b.SourceSystem, b.DimCustomerID' + CHAR(13) 
		+ '		, c.MatchkeyType, c.MatchkeyID, c.MatchkeyName, c.MatchkeyValue, c.MatchkeyHashPlainText, c.MatchkeyHash, c.InsertDate, c.UpdateDate' + CHAR(13)  
		+ '		, CASE WHEN d.ForceMergeID IS NULL THEN CAST('''' AS VARCHAR(50)) ELSE CAST(d.winning_dimcustomerid AS VARCHAR(50)) END AS [mdm.ForceMergeID]' + CHAR(13) 
		+ '		, CASE WHEN e.dimcustomerid IS NULL THEN CAST('''' AS VARCHAR(50)) ELSE e.forced_contact_id END AS [mdm.ForceUnmergeId]' + CHAR(13) 
		+ '		, CASE WHEN f.DimCustomerid IS NULL THEN CAST('''' AS VARCHAR(50)) ELSE f.GroupingID END AS [mdm.ForceAcctGrouping]' + CHAR(13) 
		+ '		, CASE WHEN g.DimCustomerId IS NULL THEN CAST('''' AS VARCHAR(50)) ELSE g.GroupingID END AS [mdm.ForceHouseholdGrouping]' + CHAR(13) 
		+ ' FROM ' + @ClientDB + '.dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)  
		+ ' INNER JOIN ' + @ClientDB + '.dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
		+ ' LEFT JOIN dimcustomerMatchkey c WITH (NOLOCK) ON a.DimCustomerId = c.DimCustomerID' + CHAR(13)  
		+ ' LEFT JOIN ' + @ClientDB + '.mdm.ForceMergeIDs d WITH (NOLOCK) ON a.DimCustomerId = d.winning_dimcustomerid OR a.DimCustomerId = d.losing_dimcustomerid' + CHAR(13) 
		+ ' LEFT JOIN ' + @ClientDB + '.mdm.ForceUnMergeIds e WITH (NOLOCK) ON a.DimCustomerId = e.dimcustomerid' + CHAR(13) 
		+ ' LEFT JOIN ' + @ClientDB + '.mdm.ForceAcctGrouping f WITH (NOLOCK) ON a.dimcustomerid = f.DimCustomerid' + CHAR(13) 
		+ ' LEFT JOIN ' + @ClientDB + '.mdm.ForceHouseholdGrouping g WITH (NOLOCK) ON a.DimCustomerId = g.DimCustomerId' + CHAR(13) 
		+ ' WHERE 1=1' + CHAR(13)  
		+ ' AND a.' + CASE  
							WHEN @IDType = 'Contact' THEN 'SSB_CRMSYSTEM_CONTACT_ID'  
							WHEN @IDType = 'Account' THEN 'SSB_CRMSYSTEM_ACCT_ID'  
							WHEN @IDType = 'Household' THEN 'SSB_CRMSYSTEM_HOUSEHOLD_ID'   
							ELSE ''  
						  END + ' IN (''' + REPLACE(@IDList,',',''',''') + ''')' + CHAR(13)  
		+ ' ORDER BY b.DimCustomerId, c.MatchKeyType, c.MatchkeyName' + CHAR(13)  
  
	----SELECT @sql  
	EXEC sp_executesql @sql  
  
END
GO
