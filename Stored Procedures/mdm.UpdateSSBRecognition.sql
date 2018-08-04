SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
            
CREATE PROCEDURE [mdm].[UpdateSSBRecognition]                
(               
	@ClientDB VARCHAR(50),               
	@RecognitionType VARCHAR(25) = 'Contact', -- Accepted values = Contact, Account, Household               
	@FullRefresh BIT = 0,               
	@LoopCnt INT = 0,        
	@PrimaryOnly INT = 0,       
	@Debug BIT = 0,  
	@DebugMatchkeyIDList VARCHAR(150) = NULL                      
)               
AS               
BEGIN               
               
--DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_TEST', @RecognitionType VARCHAR(25) = 'Contact', @FullRefresh BIT = 0, @LoopCnt INT = 0, @PrimaryOnly INT = 0, @Debug BIT = 1, @DebugMatchkeyIDList VARCHAR(150) = '1,2,3,9,11'  
       
/***************************************************************************************************************************************       
*       
*	To view/debug/run the generated SQL code in its entirety, please do the following:       
*		1) Execute sproc with the @Debug parameter set to 1		       
*		2) Right-click on the recognition_sql_debug output and choose "Save Results As..."      
		3) From the "Save as type:" dropdown select "All files (*.*)"      
*		4) Next, provide a filename with the ".sql" extension to save the output in the proper format      
*		5) Open the saved .sql file from SSMS and parse (Ctrl+F5) or execute (F5), as needed      
*       
***************************************************************************************************************************************/       
  
SET NOCOUNT ON   
   
IF @Debug = 1  
BEGIN  
	RAISERROR ('Execution mode: Debug', 0, 1) WITH NOWAIT;  
	RAISERROR ('Starting SQL syntax validation...', 0, 1) WITH NOWAIT;    
END   
ELSE   
	RAISERROR ('Execution mode: Normal', 0, 1) WITH NOWAIT;  
  
  
IF (SELECT @@VERSION) LIKE '%Azure%'               
	SET @ClientDB = ''               
ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'               
	SET @ClientDB = @ClientDB + '.'               
	           
IF @FullRefresh IS NULL               
	SET @FullRefresh = 0             
	       
IF @Debug IS NULL               
	SET @Debug = 0   	         
               
DECLARE @ssb_crmsystem_id_field VARCHAR(50) = CASE                
												WHEN @RecognitionType = 'Contact' THEN 'SSB_CRMSYSTEM_CONTACT_ID'                
												WHEN @RecognitionType = 'Account' THEN 'SSB_CRMSYSTEM_ACCT_ID'                
												WHEN @RecognitionType = 'Household' THEN 'SSB_CRMSYSTEM_HOUSEHOLD_ID'                
												ELSE ''               
											END               
DECLARE @compositeTbl VARCHAR(50) = 'mdm.Composite' + @RecognitionType + 's'               
DECLARE @compositeTblID VARCHAR(50) = CASE                
										WHEN @RecognitionType = 'Contact' THEN 'cc_id'                
										WHEN @RecognitionType = 'Account' THEN 'ca_id'                
										WHEN @RecognitionType = 'Household' THEN 'ch_id'               
										ELSE ''                
									END               
DECLARE @matcheyBaseTblCounter INT = 1               
DECLARE @matchkeyGroupIDCounter INT = 1               
DECLARE @ID INT = 0               
DECLARE @matchkeyID INT               
DECLARE @matchkeyName VARCHAR(255) = ''               
DECLARE @matchkeyBaseTblFieldList VARCHAR(MAX) = ''               
DECLARE @matchkeyBaseTblFieldListDistinct VARCHAR(MAX) = ''               
DECLARE @matchkeyBaseTblFieldListDistinct_NO_ALIAS VARCHAR(MAX) = ''               
DECLARE @matchkeyBaseTbl VARCHAR(255) = ''               
DECLARE @matchkeyBaseTblLookupFieldList VARCHAR(MAX) = ''               
DECLARE @matchkeyBaseTblLookupCondition VARCHAR(MAX) = ''               
DECLARE @matchkeyBaseTblHashSql VARCHAR(MAX) = ''               
DECLARE @matchkeyGroupID INT = 1               
DECLARE @matchkeyHashOutputTbl VARCHAR(255) = ''               
DECLARE @matchkeyHashIdentifier VARCHAR(50) = ''               
DECLARE @matchkeyHashName VARCHAR(50) = ''               
DECLARE @IsDeletedExists BIT = 0               
DECLARE @rowCount_cdioChanges INT = 0               
DECLARE @rowCount_matchkeyChanges INT = 0               
DECLARE @rowCount_workingset INT = 0               
DECLARE @rowCount_contactMatch_pre INT = 0               
DECLARE @rowCount_contactMatch_post INT = 0               
DECLARE @rowCount_compositeDelete INT = 0          
DECLARE @compositeAuditCount INT = 0          
DECLARE @preSql_part1 NVARCHAR(MAX) = ''               
DECLARE @preSql_part2 NVARCHAR(MAX) = ''               
DECLARE @preSql_part3 NVARCHAR(MAX) = ''               
DECLARE @sql NVARCHAR(MAX) = ''              
DECLARE @sql_debug NVARCHAR(MAX) = ''        
DECLARE @sql_tmp1 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp2 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp3 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp4 NVARCHAR(MAX) = ''           
DECLARE @sql_tmp5 NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_baseTbl NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_baseTbl_drop NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_baseTbl_fields NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_baseTbl_conditions NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_baseTbl_indexes NVARCHAR(MAX) = ''            
DECLARE @sql_tmp_cdio_changes NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_workingset NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_contactmatch_data_pre NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_contactmatch_data_post NVARCHAR(MAX) = ''               
DECLARE @sql_loop_1 NVARCHAR(MAX) = ''               
DECLARE @sql_loop_2 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_ssbid_fields NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_ssbid_join NVARCHAR(MAX) = ''               
DECLARE @sql_compositeTbl_insert NVARCHAR(MAX) = ''               
DECLARE @sql_dimcustomerMatchkey NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_ssbid_update_1 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_ssbid_update_2 NVARCHAR(MAX) = ''               
DECLARE @sql_tmp_ssbid_audit NVARCHAR(MAX) = ''               
DECLARE @sql_dimcustomerssbid_audit NVARCHAR(MAX) = ''               
DECLARE @sql_hashTbl_update NVARCHAR(MAX) = ''               
DECLARE @sql_wipe_ssbid NVARCHAR(MAX) = ''               
DECLARE @sql_potential_invalid_grouping NVARCHAR(MAX) = ''             
DECLARE @sql_remove_invalid_grouping NVARCHAR(MAX) = ''             
DECLARE @counter INT = 0               
DECLARE @return_code INT = 0              
DECLARE @errorMsg VARCHAR(250)           
    
          
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

IF @Debug = 0
BEGIN	
	EXEC sp_executesql @sql
	SET @sql = ''			  
END
ELSE 
	SET @sql_debug = @sql_debug + CHAR(13) + @sql
		   
IF OBJECT_ID('tempdb..#matchkeyConfig') IS NOT NULL               
	DROP TABLE #matchkeyConfig               
               
IF OBJECT_ID('tempdb..#matchkeyGroups') IS NOT NULL               
	DROP TABLE #matchkeyGroups               
               
IF OBJECT_ID('tempdb..#baseTblFieldsAll') IS NOT NULL               
	DROP TABLE #baseTblFieldsAll               
             
IF OBJECT_ID('tempdb..#baseTblFields') IS NOT NULL               
	DROP TABLE #baseTblFields             
	               
IF OBJECT_ID('tempdb..#baseTblLookupFields') IS NOT NULL               
	DROP TABLE #baseTblLookupFields               
               
IF OBJECT_ID('tempdb..#baseTblAllFields') IS NOT NULL               
	DROP TABLE #baseTblAllFields               
		           
IF OBJECT_ID('tempdb..#tmp_contactmatch_data') IS NOT NULL               
	DROP TABLE #tmp_contactmatch_data               
               
IF OBJECT_ID('tempdb..#tmp_contacts') IS NOT NULL               
	DROP TABLE #tmp_contacts               
               
IF OBJECT_ID('tempdb..#tmp_accounts') IS NOT NULL               
	DROP TABLE #tmp_accounts               
               
IF OBJECT_ID('tempdb..#tmp_households') IS NOT NULL               
	DROP TABLE #tmp_households               
               
IF OBJECT_ID('tempdb..#compositeTblFields') IS NOT NULL               
	DROP TABLE #compositeTblFields               
               
IF OBJECT_ID('tempdb..#tmp_cdio_changes') IS NOT NULL               
	DROP TABLE #tmp_cdio_changes               
               
IF OBJECT_ID('tempdb..#tmp_workingset') IS NOT NULL               
	DROP TABLE #tmp_workingset               
               
IF OBJECT_ID('tempdb..#dimcustomerMatchkey') IS NOT NULL               
	DROP TABLE #dimcustomerMatchkey               
               
IF OBJECT_ID('tempdb..#tmp_dimcustomerssbid_audit') IS NOT NULL               
	DROP TABLE #tmp_dimcustomerssbid_audit               
               
IF OBJECT_ID('tempdb..#invalid_matchkey') IS NOT NULL               
	DROP TABLE #invalid_matchkey               
             
IF OBJECT_ID('tempdb..#initFields') IS NOT NULL             
	DROP TABLE #initFields             
            
IF OBJECT_ID('tempdb..#recognitionAuditFailure') IS NOT NULL            
	DROP TABLE #recognitionAuditFailure            
               
CREATE TABLE #matchkeyConfig               
(               
	ID INT IDENTITY (1,1),               
	MatchkeyID int,               
	MatchkeyName VARCHAR(255),               
	MatchKeyType VARCHAR(50),               
	MatchkeyPreSql VARCHAR(MAX),               
	MatchkeyBaseTblFieldList VARCHAR(MAX),               
	MatchkeyBaseTbl VARCHAR(255),               
	MatchkeyBaseTblLookupFieldList VARCHAR(MAX),               
	MatchkeyBaseTblLookupCondition VARCHAR(MAX),               
	MatchkeyBaseTblHashSql VARCHAR(MAX),               
	MatchkeyHashIdentifier VARCHAR(50),               
	Active BIT,               
	InsertDate DATETIME,               
	IsDeletedExists BIT               
)               
               
CREATE TABLE #matchkeyGroups (MatchkeyBaseTblID INT, MatchkeyBaseTbl VARCHAR(255), MatchkeyGroupID INT, MatchkeyID INT)               
               
CREATE TABLE #baseTblFieldsAll (FieldName VARCHAR(100) NOT NULL)               
             
CREATE TABLE #baseTblFields (FieldName VARCHAR(100) NOT NULL)               
               
CREATE TABLE #baseTblLookupFields (ID INT IDENTITY (1,1), FieldName VARCHAR(100) NOT NULL, DATA_TYPE NVARCHAR(128) NULL)               
               
CREATE TABLE #baseTblAllFields (ID INT IDENTITY(1,1), MatchkeyName VARCHAR(255), MatchkeyID INT, MatchKeyType VARCHAR(50), MatchkeyBaseTblFieldList VARCHAR(MAX), MatchkeyBaseTbl VARCHAR(255)               
	, COLUMN_NAME sysname, DATA_TYPE NVARCHAR(128), CHARACTER_MAXIMUM_LENGTH INT, NUMERIC_PRECISION TINYINT, NUMERIC_SCALE INT)         
               
CREATE TABLE #tmp_contactmatch_data (DimCustomerId INT, SSID NVARCHAR(100), SourceSystem NVARCHAR(50))               
               
CREATE TABLE #tmp_contacts (SSB_CRMSYSTEM_CONTACT_ID VARCHAR(50))               
               
CREATE TABLE #tmp_accounts (SSB_CRMSYSTEM_ACCT_ID VARCHAR(50))               
               
CREATE TABLE #tmp_households (SSB_CRMSYSTEM_HOUSEHOLD_ID VARCHAR(50))               
               
CREATE TABLE #compositeTblFields (ID INT IDENTITY(1,1), MatchkeyID INT, COLUMN_NAME varchar(50), IsNew BIT DEFAULT(0))               
               
CREATE TABLE #tmp_cdio_changes (SSB_CRMSYSTEM_ACCT_ID varchar (50), SSB_CRMSYSTEM_CONTACT_ID varchar (50), SSB_CRMSYSTEM_HOUSEHOLD_ID VARCHAR(50))               
               
CREATE TABLE #tmp_workingset (DimCustomerId INT)               
               
CREATE TABLE #dimcustomerMatchkey (DimCustomerID INT, MatchkeyID INT, MatchkeyValue VARCHAR(50))               
               
CREATE TABLE #tmp_dimcustomerssbid_audit (DimCustomerID INT, MatchkeyValue VARCHAR(50))               
CREATE NONCLUSTERED INDEX ix_dimcustomerid ON #tmp_dimcustomerssbid_audit (DimCustomerID)               
CREATE NONCLUSTERED INDEX ix_matchkeyvalue ON #tmp_dimcustomerssbid_audit (MatchkeyValue)               
               
CREATE TABLE #invalid_matchkey (DimCustomerID INT, MatchkeyID INT, SSB_CRMSYSTEM_PRIMARY_FLAG BIT)               
             
CREATE TABLE #initFields (name VARCHAR(100))             
            
CREATE TABLE #recognitionAuditFailure (DimCustomerID INT, RecognitionType VARCHAR(50), FailureType VARCHAR(150))               
            
IF @Debug = 1       
BEGIN       
	SET @sql_debug = @sql_debug       
		+ ' DECLARE @rowCount_cdioChanges INT = 0' + CHAR(13)              
		+ ' DECLARE @rowCount_matchkeyChanges INT = 0' + CHAR(13)              
		+ ' DECLARE @rowCount_workingset INT = 0' + CHAR(13)              
		+ ' DECLARE @rowCount_contactMatch_pre INT = 0' + CHAR(13)              
		+ ' DECLARE @rowCount_contactMatch_post INT = 0' + CHAR(13)              
		+ ' DECLARE @rowCount_compositeDelete INT = 0' + CHAR(13)          
		+ ' DECLARE @compositeAuditCount INT = 0' + CHAR(13)         
		+ ' DECLARE @return_code INT = 0' + CHAR(13) + CHAR(13)            
		       
		+ ' IF OBJECT_ID(''tempdb..#matchkeyConfig'') IS NOT NULL' + CHAR(13)          
		+ ' 	DROP TABLE #matchkeyConfig' + CHAR(13) + CHAR(13)              
           
		+ ' IF OBJECT_ID(''tempdb..#matchkeyGroups'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #matchkeyGroups' + CHAR(13) + CHAR(13)             
       
		+ ' IF OBJECT_ID(''tempdb..#baseTblFieldsAll'') IS NOT NULL' + CHAR(13)       
		+ ' 	DROP TABLE #baseTblFieldsAll' + CHAR(13) + CHAR(13)       
       
		+ ' IF OBJECT_ID(''tempdb..#baseTblFields'') IS NOT NULL' + CHAR(13)       
		+ ' 	DROP TABLE #baseTblFields' + CHAR(13) + CHAR(13)       
 	              
		+ ' IF OBJECT_ID(''tempdb..#baseTblLookupFields'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #baseTblLookupFields' + CHAR(13) + CHAR(13)              
              
		+ ' IF OBJECT_ID(''tempdb..#baseTblAllFields'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #baseTblAllFields' + CHAR(13) + CHAR(13)              
	          
		+ ' IF OBJECT_ID(''tempdb..#tmp_contactmatch_data'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_contactmatch_data' + CHAR(13) + CHAR(13)              
          
		+ ' IF OBJECT_ID(''tempdb..#tmp_contacts'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_contacts' + CHAR(13) + CHAR(13)              
               
		+ ' IF OBJECT_ID(''tempdb..#tmp_accounts'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_accounts' + CHAR(13) + CHAR(13)              
            
		+ ' IF OBJECT_ID(''tempdb..#tmp_households'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_households' + CHAR(13) + CHAR(13)              
            
		+ ' IF OBJECT_ID(''tempdb..#compositeTblFields'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #compositeTblFields' + CHAR(13) + CHAR(13)              
		              
		+ ' IF OBJECT_ID(''tempdb..#tmp_cdio_changes'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_cdio_changes' + CHAR(13) + CHAR(13)              
		               
		+ ' IF OBJECT_ID(''tempdb..#tmp_workingset'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_workingset' + CHAR(13) + CHAR(13)              
	              
		+ ' IF OBJECT_ID(''tempdb..#dimcustomerMatchkey'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #dimcustomerMatchkey' + CHAR(13) + CHAR(13)              
		              
		+ ' IF OBJECT_ID(''tempdb..#tmp_dimcustomerssbid_audit'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #tmp_dimcustomerssbid_audit' + CHAR(13) + CHAR(13)              
	              
		+ ' IF OBJECT_ID(''tempdb..#invalid_matchkey'') IS NOT NULL' + CHAR(13)              
		+ ' 	DROP TABLE #invalid_matchkey' + CHAR(13) + CHAR(13)              
		             
		+ ' IF OBJECT_ID(''tempdb..#initFields'') IS NOT NULL' + CHAR(13)            
		+ ' 	DROP TABLE #initFields' + CHAR(13) + CHAR(13)            
		          
		+ ' IF OBJECT_ID(''tempdb..#recognitionAuditFailure'') IS NOT NULL' + CHAR(13)           
		+ ' 	DROP TABLE #recognitionAuditFailure' + CHAR(13) + CHAR(13)           
		              
		+ ' CREATE TABLE #matchkeyConfig' + CHAR(13)              
		+ ' (' + CHAR(13)              
		+ ' 	ID INT IDENTITY (1,1),' + CHAR(13)              
		+ ' 	MatchkeyID int,' + CHAR(13)              
		+ ' 	MatchkeyName VARCHAR(255),' + CHAR(13)              
		+ ' 	MatchKeyType VARCHAR(50),' + CHAR(13)              
		+ ' 	MatchkeyPreSql VARCHAR(MAX),' + CHAR(13)              
		+ ' 	MatchkeyBaseTblFieldList VARCHAR(MAX),' + CHAR(13)              
		+ ' 	MatchkeyBaseTbl VARCHAR(255),' + CHAR(13)              
		+ ' 	MatchkeyBaseTblLookupFieldList VARCHAR(MAX),' + CHAR(13)              
		+ ' 	MatchkeyBaseTblLookupCondition VARCHAR(MAX),' + CHAR(13)              
		+ ' 	MatchkeyBaseTblHashSql VARCHAR(MAX),' + CHAR(13)              
		+ ' 	MatchkeyHashIdentifier VARCHAR(50),' + CHAR(13)              
		+ ' 	Active BIT,' + CHAR(13)              
		+ ' 	InsertDate DATETIME,' + CHAR(13)              
		+ ' 	IsDeletedExists BIT' + CHAR(13)              
		+ ' )' + CHAR(13) + CHAR(13)              
		             
		+ ' CREATE TABLE #matchkeyGroups (MatchkeyBaseTblID INT, MatchkeyBaseTbl VARCHAR(255), MatchkeyGroupID INT, MatchkeyID INT)' + CHAR(13) + CHAR(13)              
	             
		+ ' CREATE TABLE #baseTblFieldsAll (FieldName VARCHAR(100) NOT NULL)' + CHAR(13) + CHAR(13)              
		           
		+ ' CREATE TABLE #baseTblFields (FieldName VARCHAR(100) NOT NULL)' + CHAR(13) + CHAR(13)              
		             
		+ ' CREATE TABLE #baseTblLookupFields (ID INT IDENTITY (1,1), FieldName VARCHAR(100) NOT NULL, DATA_TYPE NVARCHAR(128) NULL)' + CHAR(13) + CHAR(13)              
	              
		+ ' CREATE TABLE #baseTblAllFields (ID INT IDENTITY(1,1), MatchkeyName VARCHAR(255), MatchkeyID INT, MatchKeyType VARCHAR(50), MatchkeyBaseTblFieldList VARCHAR(MAX), MatchkeyBaseTbl VARCHAR(255)' + CHAR(13)              
		+ ' 	, COLUMN_NAME sysname, DATA_TYPE NVARCHAR(128), CHARACTER_MAXIMUM_LENGTH INT, NUMERIC_PRECISION TINYINT, NUMERIC_SCALE INT)' + CHAR(13) + CHAR(13)        
	               
		+ ' CREATE TABLE #tmp_contactmatch_data (DimCustomerId INT, SSID NVARCHAR(100), SourceSystem NVARCHAR(50))' + CHAR(13) + CHAR(13)              
	             
		+ ' CREATE TABLE #tmp_contacts (SSB_CRMSYSTEM_CONTACT_ID VARCHAR(50))' + CHAR(13) + CHAR(13)              
               
		+ ' CREATE TABLE #tmp_accounts (SSB_CRMSYSTEM_ACCT_ID VARCHAR(50))' + CHAR(13) + CHAR(13)              
		              
		+ ' CREATE TABLE #tmp_households (SSB_CRMSYSTEM_HOUSEHOLD_ID VARCHAR(50))' + CHAR(13) + CHAR(13)              
		             
		+ ' CREATE TABLE #compositeTblFields (ID INT IDENTITY(1,1), MatchkeyID INT, COLUMN_NAME varchar(50), IsNew BIT DEFAULT(0))' + CHAR(13) + CHAR(13)              
		           
		+ ' CREATE TABLE #tmp_cdio_changes (SSB_CRMSYSTEM_ACCT_ID varchar (50), SSB_CRMSYSTEM_CONTACT_ID varchar (50), SSB_CRMSYSTEM_HOUSEHOLD_ID VARCHAR(50))' + CHAR(13) + CHAR(13)              
		              
		+ ' CREATE TABLE #tmp_workingset (DimCustomerId INT)' + CHAR(13) + CHAR(13)              
		             
		+ ' CREATE TABLE #dimcustomerMatchkey (DimCustomerID INT, MatchkeyID INT, MatchkeyValue VARCHAR(50))' + CHAR(13) + CHAR(13)              
		               
		+ ' CREATE TABLE #tmp_dimcustomerssbid_audit (DimCustomerID INT, MatchkeyValue VARCHAR(50))' + CHAR(13)              
		+ ' CREATE NONCLUSTERED INDEX ix_dimcustomerid ON #tmp_dimcustomerssbid_audit (DimCustomerID)' + CHAR(13)              
		+ ' CREATE NONCLUSTERED INDEX ix_matchkeyvalue ON #tmp_dimcustomerssbid_audit (MatchkeyValue)' + CHAR(13) + CHAR(13)              
		         
		+ ' CREATE TABLE #invalid_matchkey (DimCustomerID INT, MatchkeyID INT, SSB_CRMSYSTEM_PRIMARY_FLAG BIT)' + CHAR(13) + CHAR(13)              
            
		+ ' CREATE TABLE #initFields (name VARCHAR(100))' + CHAR(13) + CHAR(13)            
          
		+ ' CREATE TABLE #recognitionAuditFailure (DimCustomerID INT, RecognitionType VARCHAR(50), FailureType VARCHAR(150))' + CHAR(13)        
END	       
       
SELECT @preSql_part1 = ''       
	+ ' INSERT INTO #matchkeyConfig (MatchkeyID, MatchkeyName, MatchKeyType, MatchkeyPreSql, MatchkeyBaseTblFieldList, MatchkeyBaseTbl, MatchkeyBaseTblLookupFieldList, MatchkeyBaseTblLookupCondition, MatchkeyBaseTblHashSql' + CHAR(13)               
	+ '		, MatchkeyHashIdentifier, Active, InsertDate, IsDeletedExists)' + CHAR(13)               
	+ ' SELECT MatchkeyID, MatchkeyName, MatchKeyType, MatchkeyPreSql, MatchkeyBaseTblFieldList, MatchkeyBaseTbl, MatchkeyBaseTblLookupFieldList, MatchkeyBaseTblLookupCondition, MatchkeyBaseTblHashSql' + CHAR(13)               
	+ '		, MatchkeyHashIdentifier, Active, InsertDate, CAST(CASE WHEN b.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsDeletedExists' + CHAR(13)               
	+ ' FROM ' + @ClientDB + 'mdm.MatchkeyConfig a' + CHAR(13)                
	+ ' LEFT JOIN ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS b ON a.MatchkeyBaseTbl = b.TABLE_SCHEMA + ''.'' + b.TABLE_NAME' + CHAR(13)               
	+ '		AND b.COLUMN_NAME = ''IsDeleted''' + CHAR(13)               
	+ ' where MatchkeyType = ''' + @RecognitionType + '''' + CHAR(13)    
	+ CASE WHEN @Debug = 1 AND ISNULL(@DebugMatchkeyIDList,'') != '' THEN ' AND a.MatchkeyID IN (' + @DebugMatchkeyIDList + ')' + CHAR(13) ELSE '' END + CHAR(13)         
      
	+ CASE WHEN @Debug = 1 AND ISNULL(@DebugMatchkeyIDList,'') != '' THEN  
		+ ' UPDATE #matchkeyConfig' + CHAR(13)  
		+ ' SET Active = 1' + CHAR(13)  
		+ ' WHERE MatchkeyID IN (' + @DebugMatchkeyIDList + ')' + CHAR(13) + CHAR(13)  
	  ELSE ''  
	  END  
	         
	+ ' UPDATE #matchkeyConfig' + CHAR(13)             
	+ ' SET MatchkeyBaseTbl = REPLACE(REPLACE(MatchkeyBaseTbl,''['',''''),'']'','''')' + CHAR(13) + CHAR(13)             
               
	+ ' ;WITH matchkeyBaseTbl_UNIQUE AS (' + CHAR(13)               
	+ ' 	SELECT MatchkeyBaseTbl, MatchkeyBaseTbl + ''_'' + REPLACE(CAST(NEWID() AS VARCHAR(50)),''-'','''') AS MatchkeyBaseTbl_UNIQUE' + CHAR(13)               
	+ ' 	FROM (' + CHAR(13)               
	+ ' 		SELECT DISTINCT MatchkeyBaseTbl' + CHAR(13)               
	+ ' 		FROM #matchkeyConfig' + CHAR(13)               
	+ ' 		WHERE 1=1' + CHAR(13)               
	+ ' 		AND MatchkeyBaseTbl LIKE ''#%''' + CHAR(13)               
	+ ' 	) a' + CHAR(13)               
	+ ' )' + CHAR(13)               
	+ ' UPDATE b' + CHAR(13)               
	+ ' SET b.MatchkeyPreSql = REPLACE(b.MatchkeyPreSql, a.MatchkeyBaseTbl, a.MatchkeyBaseTbl_UNIQUE)' + CHAR(13)               
	+ ' 	,b.MatchkeyBaseTbl = a.MatchkeyBaseTbl_UNIQUE' + CHAR(13)               
	+ ' FROM matchkeyBaseTbl_UNIQUE a' + CHAR(13)               
	+ ' INNER JOIN #matchkeyConfig b ON a.MatchkeyBaseTbl = b.MatchkeyBaseTbl' + CHAR(13) + CHAR(13)               
               
	+ ' IF NOT EXISTS (SELECT * FROM #matchkeyConfig WHERE ISNULL(Active,0) = 1)' + CHAR(13)               
	+ ' BEGIN' + CHAR(13)               
	+ '		SET @return_code = -1' + CHAR(13)               
	+ ' END' + CHAR(13)               
               
----SELECT @preSql_part1               
EXEC sp_executesql @preSql_part1, N'@return_code INT OUTPUT', @return_code = @return_code OUTPUT               
       
IF @Debug = 1            
	SET @sql_debug = @sql_debug + CHAR(13) + ISNULL(@preSql_part1,'')           
               
IF @return_code = -1               
BEGIN               
	IF @RecognitionType NOT IN ('Contact', 'Account')              
	BEGIN              
		PRINT 'Wiping ' + @ssb_crmsystem_id_field + ' and skipping ' + @RecognitionType + ' recognition - no active matchkeys.'               
		SET @preSql_part1 = ''              
			+ ' UPDATE a' + CHAR(13)              
			+ ' SET a.' + @ssb_crmsystem_id_field + ' = NULL' + CHAR(13)              
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13)              
			+ ' WHERE 1=1' + CHAR(13)              
			+ ' AND ISNULL(' + @ssb_crmsystem_id_field + ','''') != ''''' + CHAR(13)               
			+ ' AND ' + @ssb_crmsystem_id_field + ' != SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) + CHAR(13)              
              
			+ '	INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ '	VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''No matchkeys - Wipe ' + @ssb_crmsystem_id_field + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
			              
 		-- Add TRY/CATCH block to force stoppage and log error      
		SET @preSql_part1 = ''     
			+ ' BEGIN TRY' + CHAR(13)      
			+ @preSql_part1
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

		IF @Debug = 0             
			EXEC sp_executesql @preSql_part1		             
		ELSE        
			SET @sql_debug = @sql_debug + CHAR(13) + ISNULL(@preSql_part1,'')       
	END              
	ELSE                
	BEGIN              
		SET @errorMsg = 'At least one or more matchkeys for ' + @RecognitionType + 'recognition must be configured and active.'              
		RAISERROR (@errorMsg, 16, 1)               
	END              
              
	RETURN               
END               
               
SELECT @preSql_part1 =               
	+ ' INSERT INTO #compositeTblFields (MatchkeyID, COLUMN_NAME)' + CHAR(13)               
	+ ' SELECT b.MatchkeyID, a.COLUMN_NAME' + CHAR(13)               
	+ ' FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS a' + CHAR(13)               
	+ ' INNER JOIN #matchkeyConfig b ON a.COLUMN_NAME = b.MatchkeyHashIdentifier' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND TABLE_SCHEMA + ''.'' + TABLE_NAME = ''' + @compositeTbl + '''' + CHAR(13)               
	+ ' AND b.Active = 1' + CHAR(13)               
	+ ' ORDER BY b.MatchkeyID' + CHAR(13)               
       
-- Add TRY/CATCH block to force stoppage and log error      
SET @preSql_part1 = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+ @preSql_part1
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
			           
----SELECT @preSql_part1        
EXEC sp_executesql @preSql_part1              
       
IF @Debug = 1             
	SET @sql_debug = @sql_debug + CHAR(13) + ISNULL(@preSql_part1,'')       
               
----SELECT * FROM #matchkeyConfig               
----SELECT * FROM #compositeTblFields               
               
SELECT @preSql_part1 =                
	+ ' INSERT INTO #matchkeyGroups' + CHAR(13)               
	+ ' SELECT DENSE_RANK() OVER (ORDER BY a.MatchkeyGroup) AS MatchKeyBaseTblID, a.MatchkeyBaseTbl, ROW_NUMBER() OVER (PARTITION BY a.MatchkeyBaseTbl ORDER BY b.MatchkeyID) AS MatchkeyGroupID, b.MatchkeyID' + CHAR(13)               
	+ ' FROM (' + CHAR(13)               
	+ ' 	SELECT MIN(MatchkeyID) AS MatchkeyGroup, MatchkeyBaseTbl' + CHAR(13)               
	+ ' 	FROM #matchkeyConfig' + CHAR(13)               
	+ '		WHERE Active = 1' + CHAR(13)  
	+ ' 	GROUP BY MatchkeyBaseTbl' + CHAR(13)                
	+ ' ) a' + CHAR(13)               
	+ ' INNER JOIN #matchkeyConfig b ON a.MatchkeyBaseTbl = b.MatchkeyBaseTbl' + CHAR(13)               
	+ ' WHERE b.Active = 1' + CHAR(13) + CHAR(13)               
	+ ' ORDER BY b.MatchkeyID' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO #baseTblAllFields' + CHAR(13)               
	+ ' SELECT DISTINCT a.MatchkeyName, a.MatchkeyID, a.MatchKeyType, a.MatchkeyBaseTblFieldList, a.MatchkeyBaseTbl, b.COLUMN_NAME, b.DATA_TYPE, b.CHARACTER_MAXIMUM_LENGTH, b.NUMERIC_PRECISION, b.NUMERIC_SCALE' + CHAR(13)               
	+ ' FROM #matchkeyConfig a' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS b ON (a.MatchkeyBaseTbl = b.TABLE_SCHEMA + ''.'' + b.TABLE_NAME OR REPLACE(a.MatchkeyBaseTbl,''' + @ClientDB + ''','''') = b.TABLE_SCHEMA + ''.'' + b.TABLE_NAME)' + CHAR(13)               
		+ ' 	AND ''|'' + a.MatchkeyBaseTblFieldList + ''|'' LIKE ''%|'' + b.COLUMN_NAME + ''|%''' + CHAR(13)               
	+ '	WHERE a.Active = 1' + CHAR(13)               
	+ ' ORDER BY a.MatchkeyID' + CHAR(13) + CHAR(13)               
               
----SELECT @preSql_part1              
EXEC sp_executesql @preSql_part1              
       
IF @Debug = 1       
	SET @sql_debug = @sql_debug + CHAR(13) + ISNULL(@preSql_part1,'')       
             
--- Get all pre-sql and run it once.               
SET @preSql_part1 =                
	+ ' SET @preSql_part1 = ''''' + CHAR(13) + CHAR(13)               
	+ ' SELECT  @preSql_part1 = COALESCE(@preSql_part1 + '' '', '''') + a.MatchkeyPreSql ' + CHAR(13)               
	+ ' FROM  #matchkeyConfig a ' + CHAR(13)               
	+ ' WHERE Active = 1' + CHAR(13) + CHAR(13)               
               
EXEC sp_executesql @preSql_part1               
	, N'@preSql_part1 nvarchar(max) OUTPUT'               
	,  @preSql_part1 OUTPUT               
                 
IF ISNULL(@preSql_part1,'') = ''
	SET @preSql_part1 = 'RETURN'
ELSE
	SET @preSql_part1 =            
		+ '	INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ '	VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Running MatchkeyPreSql'', 0);' + CHAR(13) + CHAR(13)            
		+ @preSql_part1          

--SELECT @PreSQLQuery

-- Add TRY/CATCH block to force stoppage and log error      
SET @preSql_part1 = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+	@preSql_part1
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
		      
SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '.' ELSE '' END + 'sp_executesql N'''+ REPLACE(@preSql_part1, '''', '''''') + '''';          
       
IF @Debug = 0       
	EXEC sp_executesql @sql         
ELSE       
	SET @sql_debug = @sql_debug + CHAR(13) + CHAR(13) + ISNULL(@sql,'')       
	        
SET @sql = ''             
          
IF ISNULL(@ClientDB,'') != ''             
	INSERT INTO #initFields             
	SELECT name              
	FROM tempdb.sys.columns              
	WHERE object_id = OBJECT_ID('tempdb..#tmp_contactmatch_data')             
ELSE              
	INSERT INTO #initFields             
	SELECT name              
	FROM sys.columns              
	WHERE object_id = OBJECT_ID('tempdb..#tmp_contactmatch_data')               
             
SELECT @preSql_part2 = @preSql_part2 + CHAR(13) + CHAR(13)               
	+ ' ALTER TABLE #tmp_contactmatch_data ADD ' + a.COLUMN_NAME               
	+ ' ' + a.DATA_TYPE               
	+ CASE                
		WHEN a.DATA_TYPE LIKE '%CHAR%' OR a.DATA_TYPE LIKE '%BINARY%' THEN CASE WHEN a.CHARACTER_MAXIMUM_LENGTH > 0 THEN '(' + CAST(a.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) + ')' ELSE '(MAX)' END               
		WHEN a.DATA_TYPE IN ('DECIMAL','FLOAT','NUMERIC') THEN '(' + CAST(a.NUMERIC_PRECISION AS VARCHAR(5)) + ', ' + CAST(a.NUMERIC_SCALE AS VARCHAR(5)) + ')'               
		ELSE ''               
	END               
FROM (               
	SELECT *, DENSE_RANK() OVER (PARTITION BY COLUMN_NAME ORDER BY MatchkeyID) AS ColumnRanking               
	FROM #baseTblAllFields               
	WHERE COLUMN_NAME NOT IN (SELECT name FROM #initFields)             
) a               
WHERE 1=1               
AND a.ColumnRanking = 1               
ORDER BY a.MatchkeyID             
        
SELECT @preSql_part2 = @preSql_part2 + CHAR(13) + CHAR(13)               
	+ ' ALTER TABLE #tmp_contactmatch_data ADD hashplaintext_' + CAST(a.MatchkeyID AS VARCHAR(5)) + ' VARCHAR(MAX)' + CHAR(13)        
	+ ' ALTER TABLE #tmp_contactmatch_data ADD hash_' + CAST(a.MatchkeyID AS VARCHAR(5)) + ' VARBINARY(32)'       
FROM #matchkeyConfig a          
WHERE Active = 1        
ORDER BY MatchkeyID      
          
----SELECT @preSql_part2 + CHAR(13) + CHAR(13)              
        
IF @Debug = 0       
	EXEC sp_executesql @preSql_part2          
ELSE       
	SET @sql_debug = @sql_debug + CHAR(13) + CHAR(13) + ISNULL(@preSql_part2,'') + CHAR(13) + CHAR(13)       
                   
SET @preSql_part2 = '' -- RESET @preSql_part2               
        
WHILE @matcheyBaseTblCounter <= (SELECT MAX(MatchKeyBaseTblID) FROM #matchkeyGroups)               
BEGIN               
	SET @matchkeyGroupIDCounter = 1         
	SET @sql_tmp5 = ''          
    SET @sql_tmp_baseTbl_fields = ''      
	SET @sql_tmp_baseTbl_conditions = ''      
	SET @sql_tmp_baseTbl_indexes = ''      
			             
	TRUNCATE TABLE #baseTblFieldsAll              
	             
	INSERT INTO #baseTblFieldsAll (FieldName)               
	SELECT FieldName               
	FROM (               
		 SELECT DISTINCT               
			 Split.a.value('.', 'VARCHAR(100)') AS FieldName                 
		 FROM (	               
			 SELECT CAST ('<M>' + REPLACE(MatchkeyBaseTblFieldList, '||', '</M><M>') + '</M>' AS XML) AS Data                 
			 FROM #matchkeyConfig WHERE Active = 1               
		) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)               
	 ) a               
	 WHERE ISNULL(a.FieldName,'') != ''               
	 AND FieldName NOT IN (SELECT name FROM #initFields)             
               
	 ----SELECT * FROM #baseTblFieldsAll               
             
             
	SELECT DISTINCT @matchkeyBaseTbl = MatchkeyBaseTbl             
	--SELECT *              
	FROM #matchkeyGroups               
	WHERE 1=1               
	AND MatchKeyBaseTblID = @matcheyBaseTblCounter               
	AND MatchkeyGroupID = @matchkeyGroupIDCounter             
             
	--SELECT @matchkeyBaseTbl, @matcheyBaseTblCounter             
               
	WHILE @matchkeyGroupIDCounter <= (SELECT MAX(MatchkeyGroupID) FROM #matchkeyGroups WHERE 1=1 AND MatchKeyBaseTblID = @matcheyBaseTblCounter)               
	BEGIN	               
		SET @counter = 0               
		SET @sql_tmp1 = ''               
      
		SELECT @matchkeyGroupID = MatchkeyGroupID             
		--SELECT *              
		FROM #matchkeyGroups               
		WHERE 1=1               
		AND MatchKeyBaseTblID = @matcheyBaseTblCounter               
		AND MatchkeyGroupID = @matchkeyGroupIDCounter               
               
		SELECT               
			@ID = ID               
			, @matchkeyID = a.MatchkeyID             
			, @matchkeyName = MatchkeyName               
			, @matchkeyBaseTblFieldList = REPLACE(MatchkeyBaseTblFieldList,'||',',')               
			, @matchkeyBaseTblLookupFieldList = ISNULL(MatchkeyBaseTblLookupFieldList,'')              
			, @matchkeyBaseTblLookupCondition = ISNULL(MatchkeyBaseTblLookupCondition,'')               
			, @matchkeyBaseTblHashSql = CASE WHEN MatchkeyBaseTblHashSql LIKE '%VARCHAR%' THEN 'UPPER(' + MatchkeyBaseTblHashSql + ')' ELSE 'CAST(UPPER(' + MatchkeyBaseTblHashSql + ') AS VARCHAR(MAX))'  END               
			, @matchkeyHashOutputTbl = 'mdm.MatchkeyHash'               
			, @matchkeyHashIdentifier = MatchkeyHashIdentifier               
			, @matchkeyHashName = REPLACE(MatchkeyHashIdentifier,'ID','Hash')               
			, @IsDeletedExists = b.IsDeletedExists               
		FROM #matchkeyGroups a               
		INNER JOIN #matchkeyConfig b ON a.MatchkeyID = b.MatchkeyID               
		WHERE 1=1               
		AND a.MatchKeyBaseTblID = @matcheyBaseTblCounter               
		AND a.MatchkeyGroupID = @matchkeyGroupIDCounter              
		--AND b.MatchkeyBaseTbl = @matchkeyBaseTbl               
		             
		----SELECT @matchkeyBaseTbl, @matcheyBaseTblCounter, @matchkeyGroupIDCounter, @matchkeyID, @matchkeyName, @matchkeyBaseTblFieldList             
               
		TRUNCATE TABLE #baseTblFields              
               
  		INSERT INTO #baseTblFields (FieldName)               
		SELECT FieldName               
		FROM (               
			 SELECT DISTINCT               
				 Split.a.value('.', 'VARCHAR(100)') AS FieldName                 
			 FROM (	               
				 SELECT CAST ('<M>' + REPLACE(MatchkeyBaseTblFieldList, '||', '</M><M>') + '</M>' AS XML) AS Data                 
				 FROM #matchkeyConfig WHERE Active = 1 AND MatchkeyBaseTbl = @matchkeyBaseTbl              
			) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)               
		 ) a               
		 WHERE ISNULL(a.FieldName,'') != ''               
		 AND FieldName NOT IN (SELECT name FROM #initFields)             
             
		--------------------------------------------------------------------------------             
		-- @sql_tmp_cdio_changes             
		--------------------------------------------------------------------------------             
		SET @sql_tmp_cdio_changes = REPLACE(@sql_tmp_cdio_changes, @sql_tmp_cdio_changes,'') + CHAR(13) + CHAR(13)             
			+ CASE                
				WHEN @FullRefresh = 1 THEN               
					' INSERT INTO #tmp_cdio_changes' + CHAR(13)                
					+ ' SELECT DISTINCT a.SSB_CRMSYSTEM_ACCT_ID, a.SSB_CRMSYSTEM_CONTACT_ID, a.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
					+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)               
					+ ' INNER JOIN ' + @ClientDB + @matchkeyBaseTbl + ' b WITH (NOLOCK) ON b.DimCustomerId = a.DimCustomerId' + CHAR(13)               
					+ ' LEFT JOIN #tmp_cdio_changes c on ISNULL(a.SSB_CRMSYSTEM_ACCT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_ACCT_ID,'''')' + CHAR(13)               
					+ '		AND ISNULL(a.SSB_CRMSYSTEM_CONTACT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_CONTACT_ID,'''')' + CHAR(13)               
					+ ' WHERE 1=1' + CHAR(13)               
					--+ CASE                
					--	WHEN @RecognitionType = 'Account' THEN ' AND (' + REPLACE(@sql_tmp1, 'IsDeleted','b.IsDeleted')+ ')' + CHAR(13)                
					--	ELSE ''               
					--  END               
					--+ ' AND a.' + @ssb_crmsystem_id_field + ' IS NOT NULL' + CHAR(13) + CHAR(13)               
					+ ' AND c.' + @ssb_crmsystem_id_field + ' IS NULL'               
				ELSE  ''             
			END             
             
		TRUNCATE TABLE #baseTblLookupFields               
		               
		INSERT INTO #baseTblLookupFields (FieldName)               
		SELECT LTRIM(RTRIM(FieldName))               
		FROM (               
			 SELECT DISTINCT               
				 Split.a.value('.', 'VARCHAR(100)') AS FieldName                 
			 FROM                 
			 (               
				 SELECT CAST ('<M>' + REPLACE(@matchkeyBaseTblLookupFieldList, '||', '</M><M>') + '</M>' AS XML) AS Data                 
			 ) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)               
		 ) a               
		 WHERE ISNULL(a.FieldName,'') != ''           
		           
		 --SELECT *          
		 --FROM #baseTblLookupFields              
               
		UPDATE a               
		SET a.DATA_TYPE = b.DATA_TYPE               
		FROM #baseTblLookupFields a               
		LEFT JOIN #baseTblAllFields b ON a.FieldName = b.COLUMN_NAME               
			AND b.MatchkeyBaseTbl = @matchkeyBaseTbl               
		WHERE a.DATA_TYPE IS NULL	               
		               
		SET @sql_tmp1 = @matchkeyBaseTblLookupCondition             
		SET @counter = (SELECT MIN(ID) FROM #baseTblLookupFields)               
		WHILE @counter <= (SELECT MAX(ID) FROM #baseTblLookupFields)               
		BEGIN           
			IF CHARINDEX((SELECT LTRIM(RTRIM(FieldName)) FROM #baseTblLookupFields WHERE ID = @counter), @sql_tmp1) > 0          
				SET @sql_tmp1 = STUFF(@sql_tmp1, CHARINDEX((SELECT LTRIM(RTRIM(FieldName)) FROM #baseTblLookupFields WHERE ID = @counter), @sql_tmp1), LEN((SELECT LTRIM(RTRIM(FieldName)) FROM #baseTblLookupFields WHERE ID = @counter)), 'a.' + (SELECT LTRIM(RTRIM(FieldName)) FROM #baseTblLookupFields WHERE ID = @counter))            
			SET @counter = @counter + 1               
		END               
					               
		SET @preSql_part2 =                
			+ ' IF (SELECT COUNT(0) FROM ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA + ''.'' + TABLE_NAME = ''' + @compositeTbl + ''' AND COLUMN_NAME = ''' + @matchkeyHashIdentifier + ''') = 0' + CHAR(13)               
			+ ' BEGIN' + CHAR(13)               
			+ '		INSERT INTO #compositeTblFields (MatchkeyID, COLUMN_NAME, IsNew) VALUES (' + CAST(@matchkeyID AS VARCHAR(5)) + ',''' + @matchkeyHashIdentifier + ''', 1)' + CHAR(13) + CHAR(13)               
               
			+ '		ALTER TABLE ' + @ClientDB + @compositeTbl + ' ADD ' + @matchkeyHashIdentifier + ' VARCHAR(50)' + CHAR(13)               
			+ '		CREATE NONCLUSTERED INDEX IX_Composite' + @RecognitionType + 's_' + @matchkeyHashIdentifier + ' ON ' + @ClientDB + @compositeTbl + ' (' + @matchkeyHashIdentifier + ') INCLUDE (' + @ssb_crmsystem_id_field + ') WITH (FILLFACTOR=90) ON [PRIMARY]' + CHAR(13)               
               
			+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Add column ' + @matchkeyHashIdentifier + ' to ' + @compositeTbl + ''', 0);' + CHAR(13) + CHAR(13)               
			+ ' END'               
              
 	--	-- Add TRY/CATCH block to force stoppage and log error      
		--SET @preSql_part2 = ''     
		--	+ ' BEGIN TRY' + CHAR(13)      
		--	+ @preSql_part2
		--	+ ' END TRY' + CHAR(13)     
		--	+ ' BEGIN CATCH' + CHAR(13)     
		--	+ '		DECLARE @ErrorMessage NVARCHAR(92)' + CHAR(13)     
		--	+ '			, @ErrorSeverity INT' + CHAR(13)     
		--	+ '			, @ErrorState INT' + CHAR(13) + CHAR(13)     
     
		--	+ '		SELECT @ErrorMessage = LEFT(ERROR_MESSAGE(), 92)' + CHAR(13)      
		--	+ '			, @ErrorSeverity = ERROR_SEVERITY()' + CHAR(13)      
		--	+ '			, @ErrorState = ERROR_STATE()' + CHAR(13) + CHAR(13)     
     
		--	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
		--	+ '		VALUES (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)     
     
		--	+ '		RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)     
		--	+ '             @ErrorSeverity, -- Severity.' + CHAR(13)     
		--	+ '             @ErrorState -- State.' + CHAR(13)     
		--	+ '             );' + CHAR(13)     
		--	+ ' END CATCH' + CHAR(13) + CHAR(13) 		
				   
		----SELECT @preSql_part2              
       
		IF @Debug = 0       
			EXEC sp_executesql @preSql_part2          
		ELSE       
			SET @sql_debug = @sql_debug + CHAR(13) + ISNULL(@preSql_part2,'')       
	                 
		SET @sql_tmp4 = @matchkeyBaseTblHashSql                 
		SET @counter = 1                 
		WHILE @counter <= (SELECT MAX(ID) FROM #baseTblAllFields)                 
		BEGIN                 
			SELECT @sql_tmp4 = REPLACE(@sql_tmp4, a.COLUMN_NAME, 'b.' + a.COLUMN_NAME)                 
			FROM #baseTblAllFields a                  
			WHERE 1=1                 
			AND MatchkeyID = @matchkeyID                 
			AND a.ID = @counter                 
                 
			SET @counter = @counter + 1                 
		END                 
      
		IF (ISNULL(@matchkeyBaseTblHashSql,'') != '')                 
		BEGIN					                 
			SET @sql_tmp_ssbid_fields = @sql_tmp_ssbid_fields + ', CAST(hash' + CAST(@matcheyBaseTblCounter AS NVARCHAR(2)) + '_' + CAST(@matchkeyGroupIDCounter AS NVARCHAR(2)) + '.MatchkeyHashID AS VARCHAR(50)) AS ' + @matchkeyHashIdentifier + CHAR(13)                 
			SET @sql_tmp_ssbid_join = @sql_tmp_ssbid_join + 'LEFT JOIN ' + @ClientDB + @matchkeyHashOutputTbl + ' hash' + CAST(@matcheyBaseTblCounter AS NVARCHAR(2)) + '_' + CAST(@matchkeyGroupIDCounter AS NVARCHAR(2)) + ' ON cdio.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = hash' + CAST(@matcheyBaseTblCounter AS NVARCHAR(2)) + '_' + CAST(@matchkeyGroupIDCounter AS NVARCHAR(2)) + '.MatchkeyHash' + CHAR(13)            
				+ '		AND hash' + CAST(@matcheyBaseTblCounter AS NVARCHAR(2)) + '_' + CAST(@matchkeyGroupIDCounter AS NVARCHAR(2)) + '.MatchkeyHashIDName = ''' + @matchkeyHashIdentifier + '''' + CHAR(13)        
		END    		               
               
		IF @FullRefresh = 0      
		BEGIN      
			SET @sql_tmp2 = ''      
				+ ' SELECT b.*' + CHAR(13)           
				+ ' INTO #tmp_workingset_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13)        
				+ ' FROM #tmp_workingset a' + CHAR(13)             
				+ ' INNER JOIN ' + @ClientDB + @matchkeyBaseTbl + ' b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) + CHAR(13)      
      
				+ ' CREATE CLUSTERED INDEX ix_dimcustomerid ON #tmp_workingset_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + '(dimcustomerid)' + CHAR(13) + CHAR(13)      
		END      
		ELSE       
			SET @sql_tmp2 = ''      
		      
		SET @sql_tmp3 =  ''         
			+ @sql_tmp2       
			+ ' TRUNCATE TABLE #mergeOutput' + CHAR(13) + CHAR(13)          
			              
			 + ' MERGE #tmp_contactmatch_data as a' + CHAR(13)              
			 + ' USING '       
			 + CASE       
				WHEN @FullRefresh = 0 THEN '#tmp_workingset_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5))       
				ELSE @ClientDB + @matchkeyBaseTbl      
			  END + ' b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)             
			 + ' WHEN MATCHED THEN UPDATE' + CHAR(13)             
			 + ' SET '             
			              
		SELECT @sql_tmp3 = @sql_tmp3 + CASE WHEN a.rownum > 1 THEN ',' ELSE '' END + a.sql             
			 FROM (             
				 SELECT DISTINCT 'a.' + FieldName + ' = b.' + FieldName AS sql, ROW_NUMBER() OVER (ORDER BY FieldName) AS rownum             
				 FROM #baseTblFields             
			 ) a             
		             
		SET @sql_tmp3 = @sql_tmp3 + CHAR(13)              
			+ ' WHEN NOT MATCHED BY TARGET' + CASE WHEN @IsDeletedExists = 1 THEN ' AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13) ELSE '' END + CHAR(13) + ' THEN' + CHAR(13)             
			+ ' INSERT (dimcustomerid, ssid, sourcesystem, @matchkeyBaseTblFieldListDistinct_NO_ALIAS)' + CHAR(13)             
			+ ' VALUES (b.dimcustomerid, b.ssid, b.sourcesystem, @matchkeyBaseTblFieldListDistinct)' + CHAR(13)             
			+ ' OUTPUT $action INTO #mergeOutput;' + CHAR(13) + CHAR(13)             
             
			+ ' SELECT @rowCount_contactMatch_pre = @rowCount_contactMatch_pre + (SELECT COUNT(0) FROM #mergeOutput WHERE ActionType = ''INSERT'')' + CHAR(13) + CHAR(13)              
      
		SET @sql_tmp1 = REPLACE(@sql_tmp1, 'a.', 'b.')	      
				           
		SET @sql_tmp_baseTbl_fields = @sql_tmp_baseTbl_fields      
			+ '		,' + @sql_tmp4 + ' AS hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)      
			+ CASE       
				WHEN ISNULL(@sql_tmp1,'') != '' THEN '	,CASE WHEN ' + @sql_tmp1 + ' THEN CAST(HASHBYTES(''SHA2_256'',' + @sql_tmp4 + ') AS VARBINARY(32)) ELSE NULL END'      
				ELSE '	,CAST(HASHBYTES(''SHA2_256'',' + @sql_tmp4 + ') AS VARBINARY(32))'      
			END + ' AS hash_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)      
      
		SET @sql_tmp_baseTbl_conditions = @sql_tmp_baseTbl_conditions + CHAR(13)      
			+ CASE WHEN @matchkeyGroupID != 1 THEN '	OR' ELSE '	' END       
			+ CASE       
				WHEN ISNULL(@sql_tmp1,'') != '' THEN '(' + @sql_tmp1 + ')'      
				ELSE '(1=1)'      
			  END      
      
		SET @sql_tmp_baseTbl_indexes = @sql_tmp_baseTbl_indexes      
			+ ' CREATE NONCLUSTERED INDEX ix_hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' ON ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + '(hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ') INCLUDE (dimcustomerid)' + CHAR(13)      
             
		SET @sql_tmp5 = @sql_tmp5        
			+ ' UPDATE b' + CHAR(13)        
			+ ' SET b.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)        
			+ '		,b.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = a.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)      
			+ ' FROM ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ' a' + CHAR(13)        
			+ ' INNER JOIN #tmp_contactmatch_data b ON a.dimcustomerid = b.dimcustomerid' + CHAR(13)        
			+ ' WHERE 1=1' + CHAR(13)      
			+ ' AND b.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' IS NULL' + CHAR(13)       
			+ ' AND a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' IS NOT NULL' + CHAR(13) + CHAR(13)        
    
			--+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''') IS NOT NULL' + CHAR(13)       
			--+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13)  	    
		        
		SET @sql_tmp_contactmatch_data_pre = REPLACE(@sql_tmp_contactmatch_data_pre, @sql_tmp3, '') + @sql_tmp3      
               
		SELECT DISTINCT @sql_tmp1 = REPLACE(REPLACE(REPLACE(STUFF((SELECT DISTINCT ',' + LTRIM(RTRIM(a.FieldName))               
		FROM #baseTblFields a                
		FOR XML PATH('')),1,1,''),CHAR(13),''),CHAR(10),''),CHAR(9),'')                
             
	   SET @sql_tmp4 = 'CAST(HASHBYTES(''SHA2_256'',' + @sql_tmp4 + ') AS VARBINARY(32))'      
      
		SET @sql_tmp3 =  ''             
			+ '		IF OBJECT_ID(''tempdb..#tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''') IS NOT NULL' + CHAR(13)             
			+ '			DROP TABLE #tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13) + CHAR(13)             
             
			+ '		;WITH hashes AS (' + CHAR(13)             
			+ '			SELECT DISTINCT @matchkeyBaseTblFieldListDistinct' + CHAR(13)              
			+ '				,' + @sql_tmp4 + ' AS hash' + CHAR(13)                
			+ '			FROM #tmp_contactmatch_data b WITH (NOLOCK)' + CHAR(13)              
			+ '		)' + CHAR(13)             
			+ '		SELECT *' + CHAR(13)             
			+ '		INTO #tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13)             
			+ '		FROM (' + CHAR(13)             
			+ '			SELECT *, ROW_NUMBER() OVER (PARTITION BY h.hash ORDER BY h.hash) AS ranking' + CHAR(13)             
			+ '			FROM hashes h' + CHAR(13)             
			+ '		) a' + CHAR(13)             
			+ '		WHERE a.ranking = 1' + CHAR(13) + CHAR(13)             
             
			+ '		CREATE NONCLUSTERED INDEX ix_hash ON #tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + '(hash)' + CHAR(13) + CHAR(13)      
      
			+ '		TRUNCATE TABLE #mergeOutput;' + CHAR(13) + CHAR(13)             
			+ '		MERGE #tmp_contactmatch_data as a' + CHAR(13)              
			+ '		USING (' + CHAR(13)             
			+ '			SELECT DISTINCT a.dimcustomerid, a.ssid, a.sourcesystem, b.' + REPLACE(@sql_tmp1, ',',', b.') + ', a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ', a.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)                 
			+ '			FROM ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ' a WITH (NOLOCK)' + CHAR(13)                 
			+ '			INNER JOIN #tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ' b WITH (NOLOCK) ON a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = b.hash' + CHAR(13)             
			+ '			WHERE a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' IS NOT NULL' + CHAR(13)      
			+ '		) AS b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)	              
			+ '		WHEN MATCHED THEN UPDATE' + CHAR(13)             
			+ '		SET '             
			              
             
		SELECT @sql_tmp3 = @sql_tmp3 + CASE WHEN a.rownum > 1 THEN ',' ELSE '' END + a.sql             
			 FROM (             
				 SELECT DISTINCT 'a.' + FieldName + ' = b.' + FieldName AS sql, ROW_NUMBER() OVER (ORDER BY FieldName) AS rownum             
				 FROM #baseTblFields             
				 WHERE LEN(REPLACE(@matchkeyBaseTblFieldList, FieldName, '')) = LEN(@matchkeyBaseTblFieldList) - LEN(FieldName)             
			 ) a             
             
		SET @sql_tmp3 = @sql_tmp3 + ', a.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = b.hash_' + CAST(@matchkeyID AS VARCHAR(5))      
			+ ', a.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + ' = b.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)              
			+ '		WHEN NOT MATCHED BY TARGET THEN' + CHAR(13)             
			+ '		INSERT (dimcustomerid, ssid, sourcesystem, ' + @sql_tmp1 + ', ' + 'hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ', ' + 'hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + ')' + CHAR(13)             
			+ '		VALUES (b.dimcustomerid, b.ssid, b.sourcesystem, b.' + REPLACE(@sql_tmp1, ',',' ,b.') + ', b.hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ', b.hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + ')' + CHAR(13)             
			+ '		OUTPUT $action INTO #mergeOutput;' + CHAR(13) + CHAR(13)             
					             
			+ '		SET @results = (SELECT COUNT(0) FROM #mergeOutput WHERE ActionType = ''INSERT'')' + CHAR(13)               
			+ '		SET @Added_Count = @Added_Count + @results' + CHAR(13) + CHAR(13)			               
			               
			+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Contact Match Records - ' + @matchkeyName + ' - Loop'', @results);' + CHAR(13) + CHAR(13)	             
			             
			+ '		IF OBJECT_ID(''tempdb..#tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''') IS NOT NULL' + CHAR(13)             
			+ '			DROP TABLE #tmp_contactmatch_hashdata_' + @matchkeyHashIdentifier + '_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13) + CHAR(13)	   			               
               
		SET @sql_loop_1 = REPLACE(@sql_loop_1, @sql_tmp3, '') + @sql_tmp3                 
             
             
		IF (ISNULL(@matchkeyHashIdentifier,'') != '')               
		BEGIN               
               
			---------------------------------               
			-- @sql_compositeTbl_insert               
			---------------------------------               
			SET @sql_compositeTbl_insert = @sql_compositeTbl_insert               
				+ ' IF OBJECT_ID(''tempdb..#composite_insert_' + @matchkeyHashIdentifier + ''') IS NOT NULL' + CHAR(13)               
				+ ' 	DROP TABLE #composite_insert_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)               
               
				+ ' SELECT DISTINCT ' + CHAR(13)               
				+ ' a.' + @matchkeyHashIdentifier + ' as ' + @ssb_crmsystem_id_field + CHAR(13)               
               
			SELECT @sql_compositeTbl_insert = @sql_compositeTbl_insert               
				+ ' , a.' + a.MatchkeyHashIdentifier               
			--SELECT a.MatchkeyHashIdentifier               
			FROM #matchkeyConfig a               
			INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
			WHERE 1=1               
			AND MatchkeyHashIdentifier IS NOT NULL               
			AND a.Active = 1               
			ORDER BY a.MatchkeyID		               
               
			SET @sql_compositeTbl_insert = @sql_compositeTbl_insert + CHAR(13)               
				+ ' into #composite_insert_' + @matchkeyHashIdentifier + CHAR(13)               
				+ ' FROM #tmp_ssbid a' + CHAR(13)                
				+ ' WHERE 1=1' + CHAR(13)               
				+ ' AND a.' + @matchkeyHashIdentifier + ' IS NOT NULL' + CHAR(13) + CHAR(13)               
               
				+ ' CREATE CLUSTERED INDEX ix_id ON #composite_insert_' + @matchkeyHashIdentifier + ' (' + @matchkeyHashIdentifier + ')' + CHAR(13) + CHAR(13)          
				          
				+ ' BEGIN TRAN' + CHAR(13)          
				+ '		SELECT DISTINCT a.' + @matchkeyHashIdentifier + CHAR(13)          
				+ '		INTO #existing_' + @matchkeyHashIdentifier + CHAR(13)          
				+ '		FROM ' + @ClientDB + @compositeTbl + ' a WITH (NOLOCK)' + CHAR(13)          
				+ '		WHERE a.' + @matchkeyHashIdentifier + ' IS NOT NULL' + CHAR(13) + CHAR(13)          
          
				+ '		CREATE CLUSTERED INDEX ix_id ON #existing_' + @matchkeyHashIdentifier + ' (' + @matchkeyHashIdentifier + ')' + CHAR(13) + CHAR(13)          
          
				+ '		INSERT INTO ' + @ClientDB + @compositeTbl + ' (' + @ssb_crmsystem_id_field               
			               
			SELECT @sql_compositeTbl_insert = @sql_compositeTbl_insert               
				+ ' , ' + a.MatchkeyHashIdentifier               
			--SELECT a.MatchkeyHashIdentifier               
			FROM #matchkeyConfig a               
			INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
			WHERE 1=1     
			AND a.Active = 1             
			AND MatchkeyHashIdentifier IS NOT NULL               
			ORDER BY a.MatchkeyID               
               
			SET @sql_compositeTbl_insert = @sql_compositeTbl_insert               
				+ ' )' + CHAR(13)               
				+ '		SELECT a.* ' + CHAR(13)               
				+ '		FROM #composite_insert_' + @matchkeyHashIdentifier + ' a' + CHAR(13)                
				+ '		LEFT JOIN #existing_' + @matchkeyHashIdentifier + ' b ON a.' + @matchkeyHashIdentifier + ' = b.' + @matchkeyHashIdentifier + CHAR(13)               
				+ '		WHERE b.' + @matchkeyHashIdentifier + ' IS NULL' + CHAR(13) + CHAR(13)               
						           
				+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
				+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert Composite ' + @RecognitionType + 's - ' + @matchkeyName + ''', @@ROWCOUNT);' + CHAR(13)            
				          
				+ ' COMMIT' + CHAR(13) + CHAR(13)             
          
				+ ' DROP TABLE #composite_insert_' + @matchkeyHashIdentifier + CHAR(13)           
				+ ' DROP TABLE #existing_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)              
               
			-------------------------               
			-- @sql_tmp_ssbid_update_1               
			-------------------------               
			SET @sql_tmp_ssbid_update_1 = @sql_tmp_ssbid_update_1               
				+ ' ;WITH get_dups AS (' + CHAR(13)               
				+ ' 	SELECT DimCustomerId, composite_id, ' + @matchkeyHashIdentifier + ', DENSE_RANK() OVER (PARTITION BY composite_id ORDER BY ' + @matchkeyHashIdentifier + ') as duprank' + CHAR(13)               
				+ ' 	FROM #tmp_ssbid' + CHAR(13)               
				+ ' ),' + CHAR(13)               
				+ ' dups AS (' + CHAR(13)               
				+ ' 	SELECT b.DimCustomerId, duprank' + CHAR(13)               
				+ ' 	FROM get_dups a' + CHAR(13)               
				+ ' 	INNER JOIN #tmp_ssbid b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
				+ ' 	WHERE a.duprank > 1' + CHAR(13)               
				+ ' )' + CHAR(13)               
				+ ' UPDATE b' + CHAR(13)               
				+ ' SET b.composite_id = NULL' + CHAR(13)               
				+ ' --SELECT DISTINCT b.*' + CHAR(13)               
				+ ' FROM dups a' + CHAR(13)               
				+ ' INNER JOIN #tmp_ssbid b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) + CHAR(13)               
               
			-------------------------               
			-- @sql_tmp_ssbid_update_2               
			-------------------------               
			SET @sql_tmp_ssbid_update_2 = @sql_tmp_ssbid_update_2               
				+ ' IF OBJECT_ID(''tempdb..#composite_' + @matchkeyHashIdentifier + ''') IS NOT NULL' + CHAR(13)               
				+ ' 	DROP TABLE #composite_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)               
               
				+ ' SELECT DISTINCT CAST(b.' + @ssb_crmsystem_id_field + ' AS VARCHAR(50)) AS composite_id, a.matchkey_id' + CHAR(13)               
				+ '		, ROW_NUMBER() OVER (PARTITION BY a.matchkey_id ORDER BY b.' + @ssb_crmsystem_id_field + ') AS id' + CHAR(13)               
				+ ' INTO #composite_' + @matchkeyHashIdentifier + CHAR(13)               
				+ ' FROM (' + CHAR(13)               
				+ '		SELECT DISTINCT ' + @matchkeyHashIdentifier + ' AS matchkey_id' + CHAR(13)               
				+ '		FROM #tmp_ssbid' + CHAR(13)               
				+ '		WHERE 1=1' + CHAR(13)               
				+ '		AND ' + @matchkeyHashIdentifier + ' IS NOT NULL' + CHAR(13)                
				+ '		AND isnull(composite_id_assigned,0) = 0' + CHAR(13)                
				+ ' ) a' + CHAR(13)				               
				+ ' INNER JOIN ' + @ClientDB + @compositeTbl + ' b WITH (NOLOCK) ON a.matchkey_id = b.' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)               
				               
				+ +' DELETE a' + CHAR(13)               
				+ +' FROM #composite_' + @matchkeyHashIdentifier + ' a' + CHAR(13)               
				+ +' WHERE id > 1' + CHAR(13) + CHAR(13)               
               
				+ ' UPDATE a' + CHAR(13)               
				+ ' SET composite_id = b.composite_id' + CHAR(13)               
				+ '		,updateddate = current_timestamp' + CHAR(13)               
				+ '		,updatedby = ''CI''' + CHAR(13)               
				+ '		,composite_id_assigned = 1' + CHAR(13)               
				+ '		,ssbid_updated = CASE WHEN isnull(a.composite_id,'''') != b.composite_id THEN 1 ELSE 0 END' + CHAR(13)               
				+ ' FROM #tmp_ssbid a' + CHAR(13)               
				+ ' INNER JOIN #composite_' + @matchkeyHashIdentifier + ' b ON a.' + @matchkeyHashIdentifier + ' = b.matchkey_id' + CHAR(13)               
				+ ' WHERE 1=1' + CHAR(13)               
				--+ ' AND (a.composite_id is null or a.composite_id != b.' + @ssb_crmsystem_id_field + ')' + CHAR(13)               
				+ ' AND a.' + @matchkeyHashIdentifier + ' IS NOT NULL' + CHAR(13)                
				+ ' AND isnull(composite_id_assigned,0) = 0' + CHAR(13) + CHAR(13)               
               
				+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
				+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Assign Composite ID - ' + @matchkeyName + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
				+ ' DROP TABLE #composite_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)               
			-------------------------               
			-- @sql_hashTbl_update               
			-------------------------               
			IF ISNULL(@matchkeyBaseTblHashSql,'') != ''               
				SET @sql_hashTbl_update = @sql_hashTbl_update               
					+' INSERT INTO ' + @ClientDB + @matchkeyHashOutputTbl + '(MatchkeyHashID, MatchkeyHashIDName, MatchkeyHashPlainText, MatchkeyHash)' + CHAR(13)               
					+ ' SELECT ' + CHAR(13)               
					+ '		' + CASE WHEN (SELECT (STUFF((               
							SELECT DISTINCT ',' + LTRIM(RTRIM(DATA_TYPE))               
							FROM #baseTblAllFields               
							WHERE MatchkeyName = @matchkeyName               
							FOR XML PATH('')), 1, 1, '')) AS DATA_TYPE) = 'uniqueidentifier' THEN 'CAST(a.MatchkeyHashPlainText AS UNIQUEIDENTIFIER)' ELSE ' NEWID()' END + ' AS MatchkeyHashID' + CHAR(13)               
					+ '		, ''' + @matchkeyHashIdentifier + ''' AS MatchkeyHashIDName' + CHAR(13)               
					+ ' 	, a.MatchkeyHashPlainText' + CHAR(13)               
					+ '		, a.MatchkeyHash' + CHAR(13)               
					+ ' FROM (' + CHAR(13)               
					+ ' 	SELECT DISTINCT hashplaintext_' + CAST(@matchkeyID AS VARCHAR(5)) + ' AS MatchkeyHashPlainText' + CHAR(13)               
					+ '			, hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' AS MatchkeyHash' + CHAR(13)        
					+ ' 	FROM #tmp_contactmatch_data' + CHAR(13)               
					+ ' 	WHERE 1=1' + CHAR(13)            
					+ '		AND hash_' + CAST(@matchkeyID AS VARCHAR(5)) + ' IS NOT NULL' + CHAR(13)        
						          
			SET @sql_hashTbl_update = @sql_hashTbl_update		           
				+ ' ) a' + CHAR(13)               
				+ ' LEFT JOIN ' + @ClientDB + @matchkeyHashOutputTbl + ' b WITH (NOLOCK) ON a.MatchkeyHash = b.MatchkeyHash' + CHAR(13)               
				+ '		AND b.MatchkeyHashIDName = ''' + @matchkeyHashIdentifier + '''' + CHAR(13)               
				+ ' WHERE b.ID IS NULL;' + CHAR(13) + CHAR(13)               
               
				+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
				+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert ' + @matchkeyHashOutputTbl + ' - ' + @matchkeyHashIdentifier + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
             
             
			-----------------------------------------             
			-- @sql_potential_invalid_grouping             
			-----------------------------------------             
			SET @sql_potential_invalid_grouping = @sql_potential_invalid_grouping             
				+ CASE WHEN ISNULL(@sql_potential_invalid_grouping,'') != '' THEN 'UNION ALL' + CHAR(13) ELSE '' END             
				+ ' SELECT ' + @ssb_crmsystem_id_field + ', COUNT(DISTINCT ' + @matchkeyHashIdentifier + ') AS cnt, ' + CAST(@matchkeyID AS VARCHAR(5)) + ' AS MatchkeyID' + CHAR(13)             
				+ ' FROM ' + @ClientDB + @compositeTbl + ' WITH (NOLOCK)' + CHAR(13)             
				+ ' WHERE 1=1' + CHAR(13)             
				+ ' AND ' + @matchkeyHashIdentifier + ' IS NOT NULL' + CHAR(13)             
				+ ' GROUP BY ' + @ssb_crmsystem_id_field + CHAR(13)             
				+ ' HAVING COUNT(DISTINCT ' + @matchkeyHashIdentifier + ') > 1' + CHAR(13) + CHAR(13)             
             
			--------------------------------------------             
			-- @sql_remove_invalid_grouping             
			--------------------------------------------             
			SET @sql_remove_invalid_grouping = @sql_remove_invalid_grouping             
				+ ' IF OBJECT_ID(''tempdb..#invalid_grouping_' + @matchkeyHashIdentifier + ''') IS NOT NULL' + CHAR(13)             
				+ ' 	DROP TABLE #invalid_grouping_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)             
             
				+ ' SELECT a.' + @ssb_crmsystem_id_field + ', COUNT(DISTINCT a.MatchkeyID) AS cnt' + CHAR(13)             
				+ ' INTO #invalid_grouping_' + @matchkeyHashIdentifier + CHAR(13)             
				+ ' FROM #potential_invalid_grouping a' + CHAR(13)             
				+ ' GROUP BY a.' + @ssb_crmsystem_id_field + CHAR(13)	             
				+ ' HAVING COUNT(DISTINCT a.MatchkeyID) > (SELECT COUNT(0) FROM #matchkeyConfig WHERE Active = 1)-1' + CHAR(13) + CHAR(13)             
             
				+ ' IF OBJECT_ID(''tempdb..#remove_composite_grouping_' + @matchkeyHashIdentifier + ''') IS NOT NULL' + CHAR(13)             
				+ ' 	DROP TABLE #remove_composite_grouping_' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)             
             
				+ ' ;WITH remove_composite_grouping AS (' + CHAR(13)             
				+ ' 	SELECT a.' + @ssb_crmsystem_id_field + ', b.' + @matchkeyHashIdentifier + ', DENSE_RANK() OVER (PARTITION BY b.' + @ssb_crmsystem_id_field + ' ORDER BY CASE WHEN b.' + @matchkeyHashIdentifier + ' = b.' + @ssb_crmsystem_id_field + ' THEN 1 ELSE 2 END) AS ranking' + CHAR(13)             
				+ ' 	FROM #invalid_grouping_' + @matchkeyHashIdentifier + ' a' + CHAR(13)             
				+ ' 	INNER JOIN ' + @ClientDB + @compositeTbl + ' b ON a.' + @ssb_crmsystem_id_field + ' = b.' + @ssb_crmsystem_id_field + CHAR(13)             
				+ ' )' + CHAR(13)             
				+ ' SELECT DISTINCT a.' + @ssb_crmsystem_id_field + ', a.' + @matchkeyHashIdentifier + CHAR(13)             
				+ ' INTO #remove_composite_grouping_' + @matchkeyHashIdentifier + CHAR(13)             
				+ ' FROM remove_composite_grouping a' + CHAR(13)             
				+ ' WHERE a.ranking > 1' + CHAR(13) + CHAR(13)             
             
				+ ' DELETE b' + CHAR(13)             
				+ ' --SELECT *' + CHAR(13)             
				+ ' FROM (SELECT DISTINCT ' + @ssb_crmsystem_id_field + ', ' + @matchkeyHashIdentifier + ' FROM #remove_composite_grouping_' + @matchkeyHashIdentifier + ') a' + CHAR(13)             
				+ ' INNER JOIN ' + @ClientDB + @compositeTbl + ' b ON a.' + @ssb_crmsystem_id_field + ' = b.' + @ssb_crmsystem_id_field + CHAR(13)             
				+ ' 	AND a.' + @matchkeyHashIdentifier + ' = b.' + @matchkeyHashIdentifier + CHAR(13) + CHAR(13)             
             
				+ ' SELECT @rowCount_compositeDelete = @rowCount_compositeDelete + @@ROWCOUNT' + CHAR(13) + CHAR(13)               
		END               
               
               
		IF (ISNULL(@matchkeyHashIdentifier,'') != '' OR @matchkeyBaseTblFieldList NOT LIKE '%,%')               
		BEGIN               
               
			-------------------------               
			-- @sql_loop_2               
			-------------------------               
			SET @sql_loop_2 = @sql_loop_2               
				+ '		TRUNCATE TABLE #Tmp_Matchkey;' + CHAR(13)               
				+ '		TRUNCATE TABLE #Tmp_Match;' + CHAR(13)               
				+ '		TRUNCATE TABLE #tmp_Composite_cnt;' + CHAR(13)               
				+ '		TRUNCATE TABLE #Tmp_ranked;' + CHAR(13)               
				+ '		TRUNCATE TABLE #tmp_update;' + CHAR(13) + CHAR(13)               
               
				+ '		INSERT INTO #tmp_matchkey' + CHAR(13)               
				+ '		SELECT ' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ' AS matchkey' + CHAR(13)               
				+ '		FROM #tmp_ssbid' + CHAR(13)               
				+ '		WHERE ISNULL(' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ', '''') != ''''' + CHAR(13)               
				+ '		GROUP BY ' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + CHAR(13)               
				+ '		HAVING COUNT(DISTINCT composite_id) > 1' + CHAR(13) + CHAR(13)               
				               
				+ '		SET @Records = @Records + @@Rowcount' + CHAR(13) + CHAR(13)               
               
				+ '		INSERT INTO #Tmp_match' + CHAR(13)               
				+ '		SELECT DISTINCT a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ', composite_id, SUM(CAST(a.ssbid_updated AS INT)) AS ssbid_updated_cnt' + CHAR(13)               
				+ '		FROM #tmp_ssbid a' + CHAR(13)               
				+ '		INNER join #Tmp_matchkey b' + CHAR(13)               
				+ '		ON a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ' = b.matchkey' + CHAR(13)            
				+ '		GROUP BY a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ', composite_id' + CHAR(13) + CHAR(13)               
               
				+ '		INSERT INTO #tmp_composite_cnt' + CHAR(13)               
				+ '		SELECT a.composite_id, COUNT(0) AS composite_cnt' + CHAR(13)               
				+ '		FROM #tmp_ssbid a' + CHAR(13)               
				+ '		INNER JOIN (SELECT DISTINCT composite_id FROM #Tmp_match) b' + CHAR(13)               
				+ '		ON a.composite_id = b.composite_id' + CHAR(13)               
				+ '		GROUP BY a.composite_id;' + CHAR(13) + CHAR(13)               
               
				+ '		INSERT INTO #Tmp_ranked' + CHAR(13)          
				+ '		SELECT matchkey, a.composite_id, composite_cnt, a.ssbid_updated_cnt, ROW_NUMBER() OVER (PARTITION BY matchkey ORDER BY composite_cnt DESC, a.ssbid_updated_cnt, a.composite_id) AS composite_rank' + CHAR(13)          
				+ '		FROM #tmp_match a' + CHAR(13)          
				+ '		INNER JOIN #Tmp_composite_cnt b' + CHAR(13)          
				+ '		ON a.composite_id = b.composite_id' + CHAR(13) + CHAR(13)          
          
				+ '		;WITH new_ranking AS (' + CHAR(13)          
				+ '			SELECT a.matchkey, a.composite_id, ROW_NUMBER() OVER (PARTITION BY a.matchkey ORDER BY a.composite_id) AS composite_rank' + CHAR(13)          
				+ '			FROM #Tmp_ranked a' + CHAR(13)          
				+ '			INNER JOIN #Tmp_ranked b ON a.composite_id = b.composite_id' + CHAR(13)          
				+ '				AND a.matchkey != b.matchkey' + CHAR(13)          
				+ '				AND a.composite_rank != b.composite_rank' + CHAR(13)          
				+ '		)' + CHAR(13)          
				+ '		UPDATE b' + CHAR(13)          
				+ '		SET b.composite_rank = a.composite_rank' + CHAR(13)          
				+ '		FROM new_ranking a' + CHAR(13)          
				+ '		INNER JOIN #Tmp_ranked b ON a.matchkey = b.matchkey' + CHAR(13)          
				+ '			AND a.composite_id = b.composite_id' + CHAR(13)          
				+ '		WHERE 1=1' + CHAR(13)          
				+ '		AND a.composite_rank != b.composite_rank' + CHAR(13) + CHAR(13)          
          
				+ '		INSERT INTO #Tmp_Update' + CHAR(13)          
				+ '		SELECT matchkey, composite_id' + CHAR(13)          
				+ '		FROM #Tmp_ranked' + CHAR(13)          
				+ '		WHERE composite_rank = 1' + CHAR(13) + CHAR(13)               
               
				+ '		UPDATE a' + CHAR(13)               
				+ '		SET composite_id = b.composite_id' + CHAR(13)               
				+ '		,composite_id_assigned = 1' + CHAR(13)               
				+ '		,ssbid_updated = CASE WHEN a.composite_id != b.composite_id THEN 1 ELSE 0 END' + CHAR(13)               
				+ '		FROM #tmp_ssbid a' + CHAR(13)               
				+ '		INNER JOIN #tmp_update b' + CHAR(13)               
				+ '		ON a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ' = b.matchkey' + CHAR(13) + CHAR(13)               
               
               
			-----------------------------------               
			-- sql_tmp_ssbid_audit               
			-----------------------------------               
			SELECT @sql_tmp_ssbid_audit = @sql_tmp_ssbid_audit               
				+ ' SELECT @compositeAuditCount = COUNT(0)' + CHAR(13)               
				+ ' from #tmp_ssbid' + CHAR(13)               
				+ ' WHERE isnull(' + @matchkeyHashIdentifier + ', '''') != ''''' + CHAR(13)               
				+ ' GROUP BY ' + @matchkeyHashIdentifier + CHAR(13)               
				+ ' HAVING COUNT(DISTINCT ' + @ssb_crmsystem_id_field + ') > 1' + CHAR(13) + CHAR(13)               
               
				+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
				+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Audit ' + @matchkeyName + ' - Composite'', @compositeAuditCount);' + CHAR(13) + CHAR(13)	               
               
			-----------------------------------               
			-- sql_dimcustomerMatchkey_insert               
			-----------------------------------               
			SELECT  @sql_dimcustomerMatchkey = @sql_dimcustomerMatchkey               
				+ CASE WHEN @matchkeyGroupIDCounter > 1 OR @matcheyBaseTblCounter > 1 THEN 'UNION' + CHAR(13) ELSE '' END              
				+ ' SELECT DISTINCT' + CHAR(13)               
				+ '		a.DimCustomerID' + CHAR(13)               
				+ '		, ' + CAST(@matchkeyID AS VARCHAR(5)) + ' AS MatchkeyID' + CHAR(13)               
				+ '		, CAST(a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ' AS VARCHAR(50)) AS MatchkeyValue' + CHAR(13)               
				+ ' FROM #tmp_ssbid a' + CHAR(13)               
				+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
				+ ' WHERE 1=1' + CHAR(13)               
				+ ' AND ISNULL(a.' + CASE WHEN ISNULL(@matchkeyHashIdentifier,'') != '' THEN @matchkeyHashIdentifier ELSE @matchkeyBaseTblFieldList END + ','''') != ''''' + CHAR(13) + CHAR(13)               
		END               
               
		-------------------------------               
		-- @sql_dimcustomerssbid_audit               
		-------------------------------               
		SET @sql_dimcustomerssbid_audit = @sql_dimcustomerssbid_audit               
			+ ' TRUNCATE TABLE #tmp_dimcustomerssbid_audit' + CHAR(13) + CHAR(13)               
               
			+ ' ALTER INDEX ALL ON #tmp_dimcustomerssbid_audit DISABLE' + CHAR(13) + CHAR(13)               
		               
			+ ' ;WITH cte AS (' + CHAR(13)               
			+ ' 	SELECT *' + CHAR(13)               
			+ ' 	FROM ' + @ClientDB + 'dbo.DimCustomerMatchkey a WITH (NOLOCK)' + CHAR(13)               
			+ ' 	WHERE a.MatchKeyID = ' + CAST(@matchkeyID AS VARCHAR(5)) + CHAR(13)               
			+ ' )' + CHAR(13)               
			+ ' INSERT INTO #tmp_dimcustomerssbid_audit' + CHAR(13)               
			+ ' SELECT DISTINCT a.DimCustomerID, CAST(a.MatchkeyValue AS VARCHAR(50)) AS MatchkeyValue' + CHAR(13)               
			+ ' FROM cte a' + CHAR(13) + CHAR(13)               
               
			+ ' ALTER INDEX ALL ON #tmp_dimcustomerssbid_audit REBUILD' + CHAR(13) + CHAR(13)               
               
			+ ' ;WITH failed_audit AS (' + CHAR(13)               
			+ '		SELECT a.MatchkeyValue' + CHAR(13)               
			+ '		FROM #tmp_dimcustomerssbid_audit a' + CHAR(13)               
			+ '		INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
			+ CASE                
				WHEN @PrimaryOnly = 1 THEN                
					'AND b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)               
				ELSE ''               
			  END               
			+ '		LEFT JOIN (' + CHAR(13)               
			+ '			SELECT c.DimCustomerId' + CHAR(13)    
			+ '			FROM ' + @ClientDB + 'mdm.ForceMergeIDs a WITH (NOLOCK)' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.losing_dimcustomerid = b.DimCustomerId' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON b.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)    
			+ '			UNION' + CHAR(13)    
			+ '			SELECT c.DimCustomerId' + CHAR(13)    
			+ '			FROM ' + @ClientDB + 'mdm.ForceMergeIDs a WITH (NOLOCK)' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.winning_dimcustomerid = b.DimCustomerId' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON b.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)    
			+ '			UNION' + CHAR(13)    
			+ '			SELECT c.DimCustomerId' + CHAR(13)    
			+ '			FROM ' + @ClientDB + 'mdm.ForceUnMergeIds a WITH (NOLOCK)' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.dimcustomerid = b.DimCustomerId' + CHAR(13)    
			+ '			INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON b.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)    
			+ '		) c ON a.dimcustomerid = c.DimCustomerId' + CHAR(13)		  			           
			+ CASE             
				WHEN @RecognitionType != 'Contact' THEN             
					'		LEFT JOIN ' + @ClientDB + CASE WHEN @RecognitionType = 'Account' THEN 'mdm.ForceAcctGrouping' WHEN @RecognitionType = 'Household' THEN 'mdm.ForceHouseholdGrouping' END + ' d ON b.' + @ssb_crmsystem_id_field + ' = d.GroupingID' + CHAR(13)            
				ELSE ''            
			  END            
			+ '		WHERE 1=1' + CHAR(13)               
			+ '		AND c.dimcustomerid IS NULL' + CHAR(13)        
			+ CASE             
				WHEN @RecognitionType != 'Contact' THEN             
					'		AND d.DimCustomerid IS NULL' + CHAR(13)            
				ELSE ''            
			  END            
			+            
			+ '		GROUP BY a.MatchkeyValue' + CHAR(13)               
			+ '		HAVING COUNT(DISTINCT ' + @ssb_crmsystem_id_field + ') > 1' + CHAR(13)                
			+ ' )' + CHAR(13)               
			--+ ' DELETE c' + CHAR(13)               
			+ ' INSERT INTO #recognitionAuditFailure' + CHAR(13)            
			+ ' SELECT c.DimCustomerId, ''' + @RecognitionType + ''' AS RecognitionType, ''' + @matchkeyName + ''' AS FailureType' + CHAR(13)          
			+ ' FROM failed_audit a' + CHAR(13)               
			+ ' INNER JOIN #tmp_dimcustomerssbid_audit b ON a.MatchkeyValue = b.MatchkeyValue' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON b.DimCustomerID = c.DimCustomerId' + CHAR(13)           
			+ ' LEFT JOIN #tmp_ssbid d ON c.DimCustomerID = d.DimCustomerID' + CHAR(13)             
			+ ' WHERE d.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)            
               
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Audit ' + @matchkeyName + ' - DimCustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	               
	               
		SET @matchkeyGroupIDCounter = @matchkeyGroupIDCounter + 1               
	END               
	               
	SELECT DISTINCT @matchkeyBaseTblFieldListDistinct = REPLACE(REPLACE(REPLACE(STUFF((SELECT DISTINCT ',b.' + LTRIM(RTRIM(a.FieldName))               
	FROM #baseTblFields a                
	FOR XML PATH('')),1,1,''),CHAR(13),''),CHAR(10),''),CHAR(9),'')                
               
	SET @matchkeyBaseTblFieldListDistinct_NO_ALIAS = REPLACE(REPLACE(@matchkeyBaseTblFieldListDistinct, 'b.',''),' ','')               
               
	SET @sql_tmp_contactmatch_data_post = @sql_tmp_contactmatch_data_post             
		+ ' IF OBJECT_ID(''tempdb..#tmp_dimcustomer' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''') IS NOT NULL' + CHAR(13)               
		+ ' 	DROP TABLE #tmp_dimcustomer' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13) + CHAR(13)               
               
		+ ' SELECT DISTINCT a.dimcustomerid' + CHAR(13)               
		+ ' INTO #tmp_dimcustomer' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13)               
		+ ' FROM #Tmp_' + @RecognitionType + 's b' + CHAR(13)               
		+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON b.' + @ssb_crmsystem_id_field + ' = c.' + @ssb_crmsystem_id_field + CHAR(13)               
		+ CASE WHEN @PrimaryOnly = 1 THEN '		AND c.SSB_CRMSYSTEM_PRIMARY_FLAG = 1' ELSE '' END + CHAR(13)               
		+ ' INNER JOIN ' + @ClientDB + @matchkeyBaseTbl + ' a WITH (NOLOCK) ON c.DimCustomerId = a.DimCustomerId' + CHAR(13)               
		+ ' LEFT JOIN #tmp_contactmatch_data d ON a.dimcustomerid = d.dimcustomerid' + CHAR(13)               
		+ ' WHERE d.dimcustomerid is NULL' + CHAR(13)               
		+ CASE WHEN @IsDeletedExists = 1 THEN ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13) ELSE '' END + CHAR(13)               
               
		+ ' CREATE NONCLUSTERED INDEX ix_tmp_dimcustomer ON #tmp_dimcustomer' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ' (DimCustomerId)' + CHAR(13) + CHAR(13)               
               
		+ ' INSERT INTO #tmp_contactmatch_data (dimcustomerid, ssid, sourcesystem, ' + @matchkeyBaseTblFieldListDistinct_NO_ALIAS + ')' + CHAR(13)               
		+ ' SELECT a.dimcustomerid, a.ssid, a.sourcesystem, ' +  REPLACE(@matchkeyBaseTblFieldListDistinct, 'b.', 'a.') + CHAR(13)               
		+ ' FROM #tmp_dimcustomer' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ' b' + CHAR(13)               
		+ ' INNER JOIN ' + @ClientDB + @matchkeyBaseTbl + ' a WITH (NOLOCK) ON b.DimCustomerId = a.DimCustomerId' + CHAR(13) + CHAR(13)               
                         
		+ ' SELECT @rowCount_contactMatch_post = @rowCount_contactMatch_post + @@ROWCOUNT' + CHAR(13) + CHAR(13)               
        
	SET @sql_tmp_contactmatch_data_post = REPLACE(@sql_tmp_contactmatch_data_post, @sql_tmp5, '') + @sql_tmp5        
             
	SET @sql_tmp_baseTbl_drop = ''       
		+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''') IS NOT NULL' + CHAR(13)        
		+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13) + CHAR(13)       
      
	EXEC sp_executesql @sql_tmp_baseTbl_drop  
 
	SET @sql_tmp_baseTbl = @sql_tmp_baseTbl 
		+ ' SELECT DISTINCT ' + CASE WHEN @PrimaryOnly = 1 THEN 'd.' ELSE 'b.' END + 'dimcustomerid, b.ssid, b.sourcesystem' + CHAR(13)      
		+ @sql_tmp_baseTbl_fields      
		+ ' INTO ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + CHAR(13)      
		+ ' FROM ' + @ClientDB + @matchkeyBaseTbl + ' b WITH (NOLOCK)' + CHAR(13)      
		+ CASE WHEN @PrimaryOnly = 1 THEN              
			' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid d WITH (NOLOCK) ON b.DimCustomerId = d.DimCustomerId' + CHAR(13)                 
			+ ' AND d.SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)                 
		  ELSE ''                 
		  END       
		+ ' WHERE 1=1' + CHAR(13)      
		+ ' AND (' + @sql_tmp_baseTbl_conditions + ')' + CHAR(13)       
		+ CASE WHEN @IsDeletedExists = 1 THEN ' AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13) ELSE '' END + CHAR(13)      
		      
		+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)      
      
		+ ' CREATE CLUSTERED INDEX ix_dimcustomerid ON ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + '(dimcustomerid)' + CHAR(13)      
		+ @sql_tmp_baseTbl_indexes + CHAR(13) + CHAR(13)      
      
		+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Index mdm.tmp_' + @RecognitionType + '_baseTbl_' + CAST(@matcheyBaseTblCounter AS VARCHAR(5)) + ''', 0);' + CHAR(13) + CHAR(13)      
	      
	SET @sql_tmp_contactmatch_data_pre = REPLACE(@sql_tmp_contactmatch_data_pre, '@matchkeyBaseTblFieldListDistinct_NO_ALIAS', @matchkeyBaseTblFieldListDistinct_NO_ALIAS) + CHAR(13)               
  	SET @sql_tmp_contactmatch_data_pre = REPLACE(@sql_tmp_contactmatch_data_pre, '@matchkeyBaseTblFieldListDistinct', @matchkeyBaseTblFieldListDistinct) + CHAR(13)               
	SET @sql_tmp_contactmatch_data_post = REPLACE(@sql_tmp_contactmatch_data_post, '@matchkeyBaseTblFieldListDistinct_NO_ALIAS', @matchkeyBaseTblFieldListDistinct_NO_ALIAS) + CHAR(13)               
  	SET @sql_tmp_contactmatch_data_post = REPLACE(@sql_tmp_contactmatch_data_post, '@matchkeyBaseTblFieldListDistinct', @matchkeyBaseTblFieldListDistinct) + CHAR(13)               
	SET @sql_loop_1 = REPLACE(@sql_loop_1, '@matchkeyBaseTblFieldListDistinct_NO_ALIAS', @matchkeyBaseTblFieldListDistinct_NO_ALIAS) + CHAR(13)               
	SET @sql_loop_1 = REPLACE(@sql_loop_1, '@matchkeyBaseTblFieldListDistinct', @matchkeyBaseTblFieldListDistinct) + CHAR(13)               
	               
	SET @matcheyBaseTblCounter = @matcheyBaseTblCounter + 1               
               
END               
       
SET @sql_tmp_contactmatch_data_pre = @sql_tmp_baseTbl + @sql_tmp_contactmatch_data_pre      
         
----SELECT @preSql_part2, @preSql_part3                
SET @sql = @preSql_part3               
               
---------------------------------               
-- @sql_compositeTbl_insert               
---------------------------------               
               
IF ISNULL(@sql_compositeTbl_insert,'') != ''               
BEGIN               
	SET @preSql_part3 =                
		+ ' IF OBJECT_ID(''tempdb..#composite_insert_all'') IS NOT NULL' + CHAR(13)               
		+ ' 	DROP TABLE #composite_insert_all' + CHAR(13) + CHAR(13)               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' SELECT DISTINCT ' + CHAR(13)               
		+ ' a.' + a.MatchkeyHashIdentifier + ' as ' + @ssb_crmsystem_id_field + CHAR(13)               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND b.ID = 1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID	               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' , a.' + a.MatchkeyHashIdentifier               
	--SELECT a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13)               
		+ ' into #composite_insert_all' + CHAR(13)               
		+ ' FROM #tmp_ssbid a' + CHAR(13)                
		+ ' WHERE 1=1' + CHAR(13)               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' AND a.' + a.MatchkeyHashIdentifier + ' IS NOT NULL'               
	--SELECT a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13) + CHAR(13)               
		+ ' INSERT INTO ' + @ClientDB + @compositeTbl + ' (' + @ssb_crmsystem_id_field               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' , ' + a.MatchkeyHashIdentifier               
	--SELECT a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' )' + CHAR(13)               
		+ ' SELECT a.*' + CHAR(13)               
		+ ' FROM #composite_insert_all a' + CHAR(13)                
		+ ' LEFT JOIN ' + @ClientDB + @compositeTbl + ' b WITH (NOLOCK) ON'               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ CASE WHEN b.MatchkeyID != (SELECT MIN(MatchkeyID) FROM #compositeTblFields) THEN ' AND' ELSE '' END + ' a.' + a.MatchkeyHashIdentifier + ' = b.' + a.MatchkeyHashIdentifier               
	--SELECT *--a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13)               
		+ ' WHERE b.' + @ssb_crmsystem_id_field + ' IS NULL' + CHAR(13)	               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13) + CHAR(13)               
		+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert Composite ' + @RecognitionType + 's - ALL'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	               
               
		+ ' DROP TABLE #composite_insert_all' + CHAR(13) + CHAR(13)               
               
	SET @sql_compositeTbl_insert = @preSql_part3 + @sql_compositeTbl_insert               
END               
               
---------------------------------               
-- @sql_tmp_ssbid_update_2               
---------------------------------               
               
IF ISNULL(@sql_tmp_ssbid_update_2,'') != ''               
BEGIN               
	SET @preSql_part3 =               
		' IF OBJECT_ID(''tempdb..#composite_all'') IS NOT NULL' + CHAR(13)               
		+ ' 	DROP TABLE #composite_all' + CHAR(13) + CHAR(13)	               
               
		+ ' SELECT DISTINCT CAST(b.' + @ssb_crmsystem_id_field + ' AS VARCHAR(50)) AS composite_id' + CHAR(13)               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' , b.' + a.MatchkeyHashIdentifier               
	--SELECT *--a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID	               
               
	SET @preSql_part3 = @preSql_part3               
		+ ' INTO #composite_all'               
		+ ' FROM #tmp_ssbid a' + CHAR(13)               
		+ ' INNER JOIN ' + @ClientDB + @compositeTbl + ' b WITH (NOLOCK) ON'               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ CASE WHEN b.MatchkeyID != (SELECT MIN(MatchkeyID) FROM #compositeTblFields) THEN ' AND' ELSE '' END + ' a.' + a.MatchkeyHashIdentifier + ' = b.' + a.MatchkeyHashIdentifier               
	--SELECT *--a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13)               
		+ ' WHERE 1=1' + CHAR(13)               
		--+ ' AND (a.composite_id is null or a.composite_id != b.' + @ssb_crmsystem_id_field + ')' + CHAR(13)               
		+ ' AND isnull(composite_id_assigned,0) = 0' + CHAR(13)               
		               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' AND a.' + a.MatchkeyHashIdentifier + ' IS NOT NULL'               
	--SELECT a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13) + CHAR(13)               
		+ ' UPDATE a' + CHAR(13)               
		+ ' SET composite_id = b.composite_id' + CHAR(13)               
		+ '		,updateddate = current_timestamp' + CHAR(13)               
		+ '		,updatedby = ''CI''' + CHAR(13)               
		+ '		,composite_id_assigned = 1' + CHAR(13)               
		+ '		,ssbid_updated = CASE WHEN isnull(a.composite_id,'''') != b.composite_id THEN 1 ELSE 0 END' + CHAR(13)               
		+ ' FROM #tmp_ssbid a' + CHAR(13)               
		+ ' INNER JOIN #composite_all b ON'               
               
	SELECT @preSql_part3 = @preSql_part3               
		+ CASE WHEN b.MatchkeyID != (SELECT MIN(MatchkeyID) FROM #compositeTblFields) THEN ' AND' ELSE '' END + ' a.' + a.MatchkeyHashIdentifier + ' = b.' + a.MatchkeyHashIdentifier               
	--SELECT *--a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13)               
		+ ' WHERE 1=1' + CHAR(13)               
		--+ ' AND (a.composite_id is null or a.composite_id != b.' + @ssb_crmsystem_id_field + ')' + CHAR(13)               
		+ ' AND isnull(composite_id_assigned,0) = 0' + CHAR(13)               
		               
	SELECT @preSql_part3 = @preSql_part3               
		+ ' AND a.' + a.MatchkeyHashIdentifier + ' IS NOT NULL'               
	--SELECT a.MatchkeyHashIdentifier               
	FROM #matchkeyConfig a               
	INNER JOIN #compositeTblFields b ON a.MatchkeyHashIdentifier = b.COLUMN_NAME               
	WHERE 1=1               
	AND MatchkeyHashIdentifier IS NOT NULL               
	AND a.Active = 1               
	ORDER BY a.MatchkeyID		               
               
	SET @preSql_part3 = @preSql_part3 + CHAR(13) + CHAR(13)               
		+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Assign Composite ID - ALL'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	               
               
	SET @sql_tmp_ssbid_update_2 = @preSql_part3 + @sql_tmp_ssbid_update_2               
END               
               
               
TRUNCATE TABLE #baseTblFieldsAll               
               
INSERT INTO #baseTblFieldsAll (FieldName)               
SELECT FieldName               
FROM (               
		SELECT DISTINCT               
			Split.a.value('.', 'VARCHAR(100)') AS FieldName                 
		FROM (	               
			SELECT CAST ('<M>' + REPLACE(CASE WHEN ISNULL(MatchkeyHashIdentifier,'') != '' THEN MatchkeyHashIdentifier ELSE MatchkeyBaseTblFieldList END, '||', '</M><M>') + '</M>' AS XML) AS Data                 
			FROM #matchkeyConfig WHERE Active = 1               
	) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)               
) a               
WHERE ISNULL(a.FieldName,'') != ''               
               
SET @matchkeyBaseTblFieldListDistinct =  ''               
SELECT DISTINCT @matchkeyBaseTblFieldListDistinct = REPLACE(REPLACE(REPLACE(STUFF((SELECT ',' + a.FieldName               
FROM #baseTblFieldsAll a                
WHERE 1=1               
AND a.FieldName = FieldName               
FOR XML PATH('')),1,1,''),CHAR(13),''),CHAR(10),''),CHAR(9),'') --AS FieldList               
FROM #baseTblFieldsAll               
GROUP BY FieldName               
               
               
----SELECT @matchkeyBaseTblFieldListDistinct               
               
SET @sql_tmp_ssbid_update_2 = @sql_tmp_ssbid_update_2	               
	+ ' UPDATE #tmp_ssbid' + CHAR(13)               
	+ ' SET composite_id = NEWID()' + CHAR(13)               
	+ '		,composite_id_assigned = 1' + CHAR(13)               
	+ '		,ssbid_updated = 1' + CHAR(13)              
	+ ' WHERE Composite_ID IS NULL ' + CHAR(13)                
	+ ' AND isnull(composite_id_assigned,0) = 0' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Assign Composite ID - NO IDs'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	               
               
	+ ' IF OBJECT_ID(''tempdb..#resetCompositeId'') IS NOT NULL' + CHAR(13)        
	+ '		DROP TABLE #resetCompositeId' + CHAR(13) + CHAR(13)        
        
	+ ' SELECT composite_id, COUNT(DISTINCT dimcustomerid) AS invalid_id_cnt' + CHAR(13)        
	+ ' INTO #resetCompositeId' + CHAR(13)        
	+ ' FROM #tmp_ssbid' + CHAR(13)        
	+ ' WHERE 1=1' + CHAR(13)        
	+ ' AND composite_id_assigned = 0' + CHAR(13)        
	+ ' GROUP BY composite_id' + CHAR(13)        
	+ ' HAVING COUNT(DISTINCT dimcustomerid) > 1' + CHAR(13) + CHAR(13)               
                
	+ ' UPDATE b' + CHAR(13)        
	+ ' SET b.composite_id = NEWID()' + CHAR(13)        
	+ ' 	,b.composite_id_assigned = 1' + CHAR(13)        
	+ ' 	,b.ssbid_updated = 1' + CHAR(13)        
	+ ' FROM #resetCompositeId a' + CHAR(13)        
	+ ' INNER JOIN #tmp_ssbid b ON a.composite_id = b.composite_id' + CHAR(13) + CHAR(13)         
         
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)                
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Assign Composite ID - RESET IDs'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)	         
         
	+ ' DROP TABLE #resetCompositeId' + CHAR(13) + CHAR(13)         
	               
-----------------------------------               
-- @sql_dimcustomerMatchkey               
-----------------------------------               
SET @sql_dimcustomerMatchkey =                
	'INSERT INTO #dimcustomerMatchkey (DimCustomerID, MatchkeyID, MatchkeyValue)' + CHAR(13)               
	+ @sql_dimcustomerMatchkey + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#dimcustomerMatchkey'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
	+ CASE WHEN @FullRefresh != 1 THEN                
		' IF OBJECT_ID(''tempdb..#tmp_missing'') IS NOT NULL' + CHAR(13)         
		+ '		DROP TABLE #tmp_missing' + CHAR(13) + CHAR(13)         
         
		+ ' SELECT a.DimCustomerId, c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)              
		+ ' INTO #tmp_missing' + CHAR(13)         
		+ ' FROM #tmp_workingset a' + CHAR(13)              
		+ ' LEFT JOIN #tmp_ssbid b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)              
		+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c WITH (NOLOCK) ON a.DimCustomerId = c.DimCustomerId' + CHAR(13)              
		+ ' WHERE 1=1' + CHAR(13)              
		+ ' AND b.DimCustomerId IS NULL' + CHAR(13)            
			         
		+ ' IF OBJECT_ID(''tempdb..#missing'') IS NOT NULL' + CHAR(13)         
		+ '		DROP TABLE #missing' + CHAR(13) + CHAR(13)         
         
		+ ' ;WITH missing AS ('	+ CHAR(13)         
		+ '		SELECT DISTINCT '	          
		+ CASE WHEN @PrimaryOnly = 1        
			THEN 'SSB_CRMSYSTEM_CONTACT_ID'         
			ELSE 'DimCustomerId'         
		  END + CHAR(13)         
		+ '		FROM #tmp_missing' + CHAR(13)         
		+ ' )' + CHAR(13)         
		+ ' SELECT DISTINCT b.DimCustomerId, b.SSB_CRMSYSTEM_CONTACT_ID, b.SSB_CRMSYSTEM_PRIMARY_FLAG' + CHAR(13)              
		+ ' INTO #missing' + CHAR(13)              
		+ ' FROM missing a' + CHAR(13)              
		+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON '          
		+ CASE WHEN @PrimaryOnly = 1        
			THEN 'a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID'         
			ELSE 'a.DimCustomerId = b.DimCustomerId'         
		END + CHAR(13) + CHAR(13)            
               
		+ CASE WHEN @PrimaryOnly = 1 THEN               
			' INSERT INTO #invalid_matchkey' + CHAR(13)               
			+ ' SELECT b.DimCustomerId, c.MatchkeyID, a.SSB_CRMSYSTEM_PRIMARY_FLAG' + CHAR(13)               
			+ ' FROM #missing a' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
			+ ' INNER JOIN #matchkeyConfig c ON b.MatchkeyID = c.MatchkeyID' + CHAR(13)          
			+ ' WHERE 1=1' + CHAR(13)               
			+ ' AND ISNULL(a.SSB_CRMSYSTEM_PRIMARY_FLAG,0) = 0' + CHAR(13)           
			+ ' UNION' + CHAR(13)          
			+ ' SELECT b.DimCustomerId, c.MatchkeyID, d.SSB_CRMSYSTEM_PRIMARY_FLAG' + CHAR(13)          
			+ ' FROM #tmp_ssbid a' + CHAR(13)          
			+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid d WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = d.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)          
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON d.DimCustomerId = b.DimCustomerId' + CHAR(13)          
			+ ' INNER JOIN #matchkeyConfig c ON b.MatchkeyID = c.MatchkeyID' + CHAR(13)          
			+ ' WHERE 1=1' + CHAR(13)          
			+ ' AND ISNULL(d.SSB_CRMSYSTEM_PRIMARY_FLAG,0) = 0' + CHAR(13) + CHAR(13)          
			ELSE ''               
		END               
               
		+ ' UPDATE b' + CHAR(13)               
		+ ' SET b.' + @ssb_crmsystem_id_field + ' = NULL' + CHAR(13)               
		+ ' FROM #missing a' + CHAR(13)               
		+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON '          
		+ CASE WHEN @PrimaryOnly = 1        
			THEN 'a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID'          
			ELSE 'a.DimCustomerId = b.DimCustomerId'          
		END               
		--+ ' WHERE ISNULL(b.SSB_CRMSYSTEM_PRIMARY_FLAG,0) != 0 ' + CHAR(13) + CHAR(13)               
               
		+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
		+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Update DimcustomerSSBID - wipe ' + @ssb_crmsystem_id_field + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
	ELSE ''               
	END               
               
-----------------------------------               
-- @sql_dimcustomerssbid_audit               
-----------------------------------               
SET @sql_dimcustomerssbid_audit =             
            
	@sql_dimcustomerssbid_audit               
            
	-- Multiple SSB_CRMSYSTEM_ACCT/HOUSEHOLD_ID Audit            
	+ CASE             
		WHEN @PrimaryOnly = 1 THEN            
			+ ' IF OBJECT_ID(''tempdb..#audit_failures'') IS NOT NULL' + CHAR(13)            
			+ ' 	DROP TABLE #audit_failures' + CHAR(13) + CHAR(13)            
            
			+ ' ;WITH contact AS (' + CHAR(13)            
			+ ' 	SELECT a.SSB_CRMSYSTEM_CONTACT_ID, COUNT(DISTINCT ISNULL(a.' + @ssb_crmsystem_id_field + ','''')) AS cnt' + CHAR(13)            
			+ ' 	FROM ' + @ClientDB + 'dbo.DimCustomerSSBID a WITH (NOLOCK)' + CHAR(13)            
			+ ' 	WHERE 1=1' + CHAR(13)            
			+ ' 	AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)            
			+ ' 	GROUP BY SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)            
			+ ' 	HAVING COUNT(DISTINCT ISNULL(a.' + @ssb_crmsystem_id_field + ','''')) > 1' + CHAR(13)            
			+ ' )' + CHAR(13)            
			+ ' SELECT a.*, b.DimCustomerId, b.' + @ssb_crmsystem_id_field + CHAR(13)            
			+ ' INTO #audit_failures' + CHAR(13)            
			+ ' FROM contact a' + CHAR(13)            
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerSSBID b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) + CHAR(13)            
            
			+ ' DELETE c' + CHAR(13)            
			+ ' FROM #audit_failures a' + CHAR(13)            
			+ ' INNER JOIN '  + @ClientDB + CASE WHEN @RecognitionType = 'Account' THEN 'mdm.ForceAcctGrouping' WHEN @RecognitionType = 'Household' THEN 'mdm.ForceHouseholdGrouping' END + ' b ON a.' + @ssb_crmsystem_id_field + ' = b.GroupingID' + CHAR(13)            
			+ ' INNER JOIN #audit_failures c ON a.' + @ssb_crmsystem_id_field + ' = c.' + @ssb_crmsystem_id_field + CHAR(13) + CHAR(13)        
			    
			--+ ' DELETE c' + CHAR(13)    
			--+ ' FROM #audit_failures a' + CHAR(13)    
			--+ ' INNER JOIN ' + @ClientDB + 'mdm.ForceMergeIDs b ON a.DimCustomerId = b.winning_dimcustomerid' + CHAR(13)    
			--+ ' 	OR a.DimCustomerId = b.losing_dimcustomerid' + CHAR(13)    
			--+ ' INNER JOIN #audit_failures c ON a.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) + CHAR(13)    
    
			--+ ' DELETE c' + CHAR(13)    
			--+ ' FROM #audit_failures a' + CHAR(13)    
			--+ ' INNER JOIN ' + @ClientDB + 'mdm.ForceUnMergeIds b ON a.DimCustomerId = b.dimcustomerid' + CHAR(13)    
			--+ ' INNER JOIN #audit_failures c ON a.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)	+ CHAR(13)        
            
			+ ' INSERT INTO #recognitionAuditFailure' + CHAR(13)            
			+ ' SELECT a.DimCustomerId, ''' + @RecognitionType + ''' AS RecognitionType, ''Multiple ' + @ssb_crmsystem_id_field + ''' AS FailureType' + CHAR(13)            
			+ ' FROM #audit_failures a' + CHAR(13)           
			+ ' LEFT JOIN #tmp_ssbid b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)             
			+ ' WHERE b.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)              
            
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Audit ' + @ssb_crmsystem_id_field + ' - DimCustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
		ELSE ''            
	END            
	+ CASE             
		WHEN @PrimaryOnly = 1 THEN            
			+ ' SELECT DISTINCT DimCustomerID' + CHAR(13)           
			+ ' INTO #mostRecent' + CHAR(13)           
			+ ' FROM ' + @ClientDB + 'mdm.RecognitionAuditFailure' + CHAR(13)           
			+ ' WHERE 1=1' + CHAR(13)           
			+ ' AND MostRecent = 1' + CHAR(13) + CHAR(13)           
		ELSE ''           
	END           
           
	+ ' INSERT INTO #recognitionAuditFailure' + CHAR(13)            
	+ ' SELECT a.DimCustomerId, ''' + @RecognitionType + ''' AS RecognitionType, ''Missing from DimCustomerSSBID'' AS FailureType'		            
	+ ' FROM ' + @ClientDB + 'dbo.dimcustomer a WITH (NOLOCK)' + CHAR(13)                
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.dimcustomerid = b.DimCustomerId' + CHAR(13)               
	+ CASE             
		WHEN @PrimaryOnly = 1 THEN            
			+ ' LEFT JOIN #mostRecent c ON a.DimCustomerId = c.DimCustomerId' + CHAR(13)           
		ELSE ''           
	END            
	+ ' WHERE ISNULL(a.IsDeleted,0) = 0' + CHAR(13)               
	+ CASE             
		WHEN @PrimaryOnly = 1 THEN            
			+ ' AND c.DimCustomerId IS NULL' + CHAR(13)           
		ELSE ''           
	END            
	+ ' AND b.DimCustomerId IS NULL AND a.NameIsCleanStatus != ''Dirty''' + CHAR(13) + CHAR(13)               
            
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Audit DimCustomer - DimCustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
            
	+ ' UPDATE ' + @ClientDB + 'mdm.RecognitionAuditFailure' + CHAR(13)            
	+ ' SET MostRecent = 0' + CHAR(13)            
	+ ' WHERE 1=1' + CHAR(13)            
	+ ' AND RecognitionType = ''' + @RecognitionType + ''''             
	+ ' AND MostRecent = 1' + CHAR(13) + CHAR(13)            
		               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.RecognitionAuditFailure (DimCustomerID, RecognitionType, FailureType)' + CHAR(13)            
	+ ' SELECT * FROM #recognitionAuditFailure' + CHAR(13) + CHAR(13)	            
            
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert mdm.RecognitionAuditFailure'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
		            
	--+ ' UPDATE b' + CHAR(13)            
	--+ ' SET b.NameIsCleanStatus = ''Dirty''' + CHAR(13)            
	+ ' DELETE b' + CHAR(13)            
	+ ' FROM (SELECT DISTINCT DimCustomerId FROM #recognitionAuditFailure) a' + CHAR(13)            
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerSSBID b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13) + CHAR(13)            
            
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Delete DimCustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
	               
--SELECT @sql_tmp_workingset, @sql_tmp_contactmatch_data_pre, @sql_loop_1, @sql_tmp_contactmatch_data_post               
--	, @sql_tmp_ssbid_fields, @sql_tmp_ssbid_join, @sql_compositeTbl_insert, @sql_dimcustomerMatchkey, @sql_tmp_ssbid_update_2               
--	, @sql_loop_2, @sql_tmp_ssbid_audit, @sql_dimcustomerssbid_audit               
               
SET @sql_tmp_cdio_changes = @sql_tmp_cdio_changes               
	+ CASE                
		WHEN @FullRefresh != 1 THEN                
			' INSERT INTO #tmp_cdio_changes' + CHAR(13)               
			+ ' SELECT SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer a WITH (NOLOCK) ON b.dimcustomerid = a.dimcustomerid' + CHAR(13)               
			+ ' WHERE a.matchkey_updatedate >= ISNULL(ISNULL((SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''customer_matchkey changes'' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''Audit DimCustomer - DimCustomerSSBID'')), (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE process_step = ''Audit DimCustomer - DimCustomerSSBID''))), a.matchkey_updatedate)' + CHAR(13) + CHAR(13)               
			               
			+ ' SELECT @rowCount_matchkeyChanges = @rowCount_matchkeyChanges + @@ROWCOUNT'               
		ELSE ''             
		END + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' values (current_timestamp, ''SSB ' + @RecognitionType + ''', ''customer_matchkey changes'', @rowCount_matchkeyChanges);' + CHAR(13) + CHAR(13)               
               
		+ ' Insert into #tmp_cdio_changes ' + CHAR(13)       
			+ ' SELECT SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'mdm.forcemergeids a WITH (NOLOCK)' + CHAR(13)       
			+ ' ON b.dimcustomerid = a.winning_dimcustomerid or b.dimcustomerid = a.losing_dimcustomerid' + CHAR(13)        
			+ ' WHERE a.updateddate >= ISNULL(ISNULL((SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''contact force merge changes'' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''Audit DimCustomer - DimCustomerSSBID'')), (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE process_step = ''Audit DimCustomer - DimCustomerSSBID''))), a.updateddate)' + CHAR(13) + CHAR(13)                    
       
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' values (current_timestamp, ''SSB ' + @RecognitionType + ''', ''contact force merge changes'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)             
       
			+ ' Insert into #tmp_cdio_changes ' + CHAR(13)       
			+ ' SELECT SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'mdm.forceunmergeids a WITH (NOLOCK)' + CHAR(13)       
			+ ' ON b.dimcustomerid = a.dimcustomerid' + CHAR(13)        
			+ ' WHERE a.updateddate >= ISNULL(ISNULL((SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''contact force unmerge changes'' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''Audit DimCustomer - DimCustomerSSBID'')), (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE process_step = ''Audit DimCustomer - DimCustomerSSBID''))), a.updateddate)' + CHAR(13) + CHAR(13)                    
       
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' values (current_timestamp, ''SSB ' + @RecognitionType + ''', ''contact force unmerge changes'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)             
       
			+ ' Insert into #tmp_cdio_changes ' + CHAR(13)       
			+ ' SELECT SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'mdm.forceAcctGrouping a WITH (NOLOCK)' + CHAR(13)       
			+ ' ON b.dimcustomerid = a.dimcustomerid ' + CHAR(13)        
			+ ' WHERE a.updateddate >= ISNULL(ISNULL((SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''force acct grouping changes'' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''Audit DimCustomer - DimCustomerSSBID'')), (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE process_step = ''Audit DimCustomer - DimCustomerSSBID''))), a.updateddate)' + CHAR(13) + CHAR(13)                    
       
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' values (current_timestamp, ''SSB ' + @RecognitionType + ''', ''force acct grouping changes'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)             
			+ ' Insert into #tmp_cdio_changes ' + CHAR(13)       
			+ ' SELECT SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'mdm.forceHouseholdGrouping a WITH (NOLOCK)' + CHAR(13)       
			+ ' ON b.dimcustomerid = a.dimcustomerid ' + CHAR(13)        
			+ ' WHERE a.updateddate >= ISNULL(ISNULL((SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''force household grouping changes'' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND process_step = ''Audit DimCustomer - DimCustomerSSBID'')), (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' AND logdate < (SELECT MAX(logdate) FROM ' + @ClientDB + 'mdm.auditlog WHERE process_step = ''Audit DimCustomer - DimCustomerSSBID''))), a.updateddate)' + CHAR(13) + CHAR(13)                    
       
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' values (current_timestamp, ''SSB ' + @RecognitionType + ''', ''force household grouping changes'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)             
       
       
IF @FullRefresh = 0               
BEGIN               
	SET @sql_tmp_workingset = @sql_tmp_workingset                
		+ ' INSERT INTO #tmp_workingset' + CHAR(13)                 
		+ ' SELECT DISTINCT a.DimCustomerId' + CHAR(13)                
		+ ' FROM ' + @ClientDB + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)                
		+ ' INNER JOIN ' + @ClientDB + 'dbo.CleanDataOutput cdio WITH (NOLOCK) on cdio.sourcecontactid = a.ssid' + CHAR(13)                 
		+ ' 	AND cdio.Input_SourceSystem = a.SourceSystem' + CHAR(13)                
		+ ' LEFT JOIN #tmp_workingset b on a.DimCustomerId = b.DimCustomerId' + CHAR(13)                
		+ CASE                 
			WHEN @PrimaryOnly = 1 THEN                 
			' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid ssbid WITH (NOLOCK) ON a.DimCustomerId = ssbid.DimCustomerId ' + CHAR(13)                
			+ '	AND SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)                
			ELSE ''                 
			END                
		+ ' WHERE 1=1' + CHAR(13)                
		+ ' AND b.DimCustomerId IS NULL' + CHAR(13) + CHAR(13)                
                
		+ ' SELECT @rowCount_workingset = @rowCount_workingset + @@ROWCOUNT' + CHAR(13) + CHAR(13)                
               
		IF @LoopCnt > 0               
		BEGIN               
		SET @sql_tmp_workingset = @sql_tmp_workingset                
               
               
		+ ' INSERT INTO #tmp_workingset' + CHAR(13)                 
		+ ' SELECT DISTINCT a.DimCustomerId' + CHAR(13)                
		+ ' FROM ' + @ClientDB + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)                
		+ ' LEFT JOIN #tmp_workingset b on a.DimCustomerId = b.DimCustomerId' + CHAR(13)                
		+ CASE                 
			WHEN @PrimaryOnly = 1 THEN                 
			' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid ssbid WITH (NOLOCK) ON a.DimCustomerId = ssbid.DimCustomerId ' + CHAR(13)                
			+ '	AND SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)                
			ELSE ''                 
		  END                
		+ ' WHERE 1=1' + CHAR(13)                
		+ ' and a.isdeleted = 0'               
		+ ' AND b.DimCustomerId IS NULL '               
		+ ' AND ' + case when @PrimaryOnly = 0 THEN 'a.' ELSE 'ssbid.' END + 'updateddate >= (SELECT MAX(logdate) FROM ' + @ClientDB  +'mdm.auditlog WHERE mdm_process = ''SSB ' + @RecognitionType + ''' and process_step = ''Audit DimCustomer - DimCustomerSSBID'')' + CHAR(13) + CHAR(13)               
               
		+ ' SELECT @rowCount_workingset = @rowCount_workingset + @@ROWCOUNT' + CHAR(13) + CHAR(13)                
		END               
END               
ELSE                
BEGIN               
	SET @sql_tmp_workingset = @sql_tmp_workingset                
		+ ' INSERT INTO #tmp_workingset' + CHAR(13)                 
		+ ' SELECT DISTINCT a.DimCustomerId' + CHAR(13)                
		+ ' FROM ' + @ClientDB + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)                
		+ ' LEFT JOIN #tmp_workingset b on a.DimCustomerId = b.DimCustomerId' + CHAR(13)                
		+ CASE                 
			WHEN @PrimaryOnly = 1 THEN                 
			' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid ssbid WITH (NOLOCK) ON a.DimCustomerId = ssbid.DimCustomerId ' + CHAR(13)                
			+ '	AND SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)                
			ELSE ''                 
		  END                
		+ ' WHERE 1=1' + CHAR(13)                
		+ ' and a.isdeleted = 0'               
		+ ' AND b.DimCustomerId IS NULL' + CHAR(13) + CHAR(13)                
                
		+ ' SELECT @rowCount_workingset = @rowCount_workingset + @@ROWCOUNT' + CHAR(13) + CHAR(13)                
               
		               
END               
SET @sql_tmp_workingset = @sql_tmp_workingset                
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)                
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#tmp_workingset - add new'', @rowCount_workingset);' + CHAR(13) + CHAR(13)                
               
             
-- RESET SSB_CRMSYSTEM_CONTACT_ID/SSB_CRMSYSTEM_ACCT_ID/SSB_CRMSYSTEM_HOUSEHOLD_ID TO NULL               
SET @sql_wipe_ssbid = @sql_wipe_ssbid               
	+ CASE                
		WHEN @FullRefresh = 1 THEN               
			' ;WITH wipe_ssbid AS (' + CHAR(13)               
			+ ' 	SELECT DISTINCT a.DimCustomerId, b.IsDeleted' + CHAR(13)               
			+ ' 	FROM ' + @ClientDB + 'dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)               
			+ '		INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b WITH (NOLOCK) on a.DimCustomerId = b.DimCustomerId'               
			+ ' 	LEFT JOIN #tmp_ssbid c ON b.DimCustomerId = c.DimCustomerId' + CHAR(13)               
			+ ' 	WHERE 1=1' + CHAR(13)               
			+ '		AND c.DimCustomerId IS NULL'               
			+ '		AND ISNULL(b.IsDeleted,0) = 0'               
			+ ' )' + CHAR(13)               
			+ ' UPDATE b' + CHAR(13)               
			+ ' SET b.' + @ssb_crmsystem_id_field + ' = CASE WHEN ISNULL(a.IsDeleted,0) = 1 THEN b.' + @ssb_crmsystem_id_field + ' ELSE NULL END' + CHAR(13)               
			--+ '		,b.IsDeleted = a.IsDeleted' + CHAR(13)               
			--+ '		,b.UpdatedDate = current_timestamp' + CHAR(13)               
			+ ' FROM wipe_ssbid a' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
		--	+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c ON b.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)               
			+ ' WHERE 1=1' + CHAR(13)               
			+ ' AND ISNULL(b.' + @ssb_crmsystem_id_field + ','''') != '''''               
	                 
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Update DimcustomerSSBID - wipe ' + @ssb_crmsystem_id_field + ' (Full Refresh)'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
		ELSE ''               
	  END + CHAR(13) + CHAR(13)               
               
             
             
             
-----------------------------------------------------------             
-- FINAL SQL             
-----------------------------------------------------------             
SET @sql = @sql               
	+ ' IF OBJECT_ID(''tempdb..#mergeOutput'') IS NOT NULL' + CHAR(13)       
	+ '		DROP TABLE #mergeOutput' + CHAR(13) + CHAR(13)       
		               
	+ ' CREATE TABLE #mergeOutput' + CHAR(13)               
	+ ' (' + CHAR(13)               
	+ '   ActionType NVARCHAR(10)' + CHAR(13)               
	+ ' );' + CHAR(13)               
             
	+ @sql_tmp_cdio_changes               
               
	+ ' INSERT INTO #tmp_cdio_changes' + CHAR(13)                
	+ ' SELECT DISTINCT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
	+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + 'dbo.CleanDataOutput cdio WITH (NOLOCK) on cdio.sourcecontactid = b.ssid' + CHAR(13)                
	+ ' 	AND cdio.Input_SourceSystem = b.SourceSystem' + CHAR(13)               
	+ ' LEFT JOIN #tmp_cdio_changes c on ISNULL(b.SSB_CRMSYSTEM_ACCT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_ACCT_ID,'''')' + CHAR(13)               
	+ '		AND ISNULL(b.SSB_CRMSYSTEM_CONTACT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_CONTACT_ID,'''')' + CHAR(13)               
	+ '		AND ISNULL(b.SSB_CRMSYSTEM_HOUSEHOLD_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_HOUSEHOLD_ID,'''')' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)                   
	+ ' AND c.SSB_CRMSYSTEM_CONTACT_ID IS NULL' + CHAR(13) + CHAR(13)               
               
	+ ' SELECT @rowCount_cdioChanges = @rowCount_cdioChanges + @@ROWCOUNT' + CHAR(13) + CHAR(13)               
	               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#tmp_cdio_changes'', @rowCount_cdioChanges);' + CHAR(13) + CHAR(13)               
          
          
	+ CASE                
		WHEN @PrimaryOnly = 1 THEN             
			+ ' SET @rowCount_cdioChanges = 0' + CHAR(13) + CHAR(13)          
          
			+ ' INSERT INTO #tmp_cdio_changes' + CHAR(13)                
			+ ' SELECT DISTINCT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'mdm.tmp_ssbid_Contact b WITH (NOLOCK)' + CHAR(13)               
			+ ' LEFT JOIN #tmp_cdio_changes c on ISNULL(b.SSB_CRMSYSTEM_ACCT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_ACCT_ID,'''')' + CHAR(13)               
			+ '		AND ISNULL(b.SSB_CRMSYSTEM_CONTACT_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_CONTACT_ID,'''')' + CHAR(13)               
			+ '		AND ISNULL(b.SSB_CRMSYSTEM_HOUSEHOLD_ID,'''') = ISNULL(c.SSB_CRMSYSTEM_HOUSEHOLD_ID,'''')' + CHAR(13)               
			+ ' WHERE 1=1' + CHAR(13)                
			+ ' AND c.SSB_CRMSYSTEM_CONTACT_ID IS NULL' + CHAR(13) + CHAR(13)               
               
			+ ' SELECT @rowCount_cdioChanges = @rowCount_cdioChanges + @@ROWCOUNT' + CHAR(13) + CHAR(13)               
	               
			+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
			+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''tmp_cdio_changes - add missing'', @rowCount_cdioChanges);' + CHAR(13) + CHAR(13)              
		ELSE ''          
	END          
               
	+ CASE                
		WHEN @PrimaryOnly = 0 THEN               
			+ ' INSERT INTO #tmp_workingset' + CHAR(13)               
			+ ' SELECT DISTINCT dimcustomerid' + CHAR(13)               
			+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)               
			+ ' INNER JOIN #tmp_cdio_changes b ON ISNULL(a.SSB_CRMSYSTEM_CONTACT_ID,'''') = ISNULL(b.SSB_CRMSYSTEM_CONTACT_ID,'''')' + CHAR(13)               
		 ELSE                
			+ ' INSERT INTO #tmp_workingset' + CHAR(13)               
			+ ' SELECT DISTINCT b.DimCustomerId' + CHAR(13)               
			+ ' FROM #tmp_cdio_changes a' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer c WITH (NOLOCK) ON b.DimCustomerId = c.DimCustomerId' + CHAR(13)               
			+ ' WHERE b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1' + CHAR(13)                 
	  END + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#tmp_workingset'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
	+ @sql_tmp_workingset               
              
	+ ' CREATE CLUSTERED INDEX ix_dimcustomerid ON #tmp_workingset (DimCustomerId)' + CHAR(13) + CHAR(13)          
	+ @sql_tmp_contactmatch_data_pre               
	             
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#tmp_contactmatch_data'', @rowCount_contactMatch_pre);' + CHAR(13) + CHAR(13)               
               
	+ ' CREATE NONCLUSTERED INDEX ix_tmp_contactmatch_data_dimcustomerid ON #tmp_contactmatch_data (DimCustomerId)' + CHAR(13)               
           
IF @FullRefresh = 0      
BEGIN            
	SET @sql = @sql      
		+ ' DECLARE @ADDED_COUNT INT = 1' + CHAR(13)               
		+ ' DECLARE @results INT = 0' + CHAR(13)               
		+ ' WHILE @Added_Count > 0' + CHAR(13)               
		+ ' BEGIN' + CHAR(13)               
		+ '		SET @Added_Count = 0' + CHAR(13) + CHAR(13)               
		+ @sql_loop_1               
		+ ' END' + CHAR(13) + CHAR(13)               
END      
      
SET @sql = @sql      
	+ ' INSERT INTO #tmp_' + @RecognitionType + 's' + CHAR(13)               
	+ ' SELECT DISTINCT b.' + @ssb_crmsystem_id_field + CHAR(13)               
	+ ' FROM #tmp_contactmatch_data a' + CHAR(13)               
	+ ' INNER JOIN '+ @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.dimcustomerid = b.DimCustomerId' + CHAR(13) + CHAR(13)               
	--+ ' AND a.IsPrimary = 1' + CHAR(13) + CHAR(13)               
          
	+ ' CREATE NONCLUSTERED INDEX ix_id ON #tmp_' + @RecognitionType + 's (' + @ssb_crmsystem_id_field + ')' + CHAR(13) + CHAR(13)    
    
	+ @sql_tmp_contactmatch_data_post               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Contact Match Records - get linked'', @rowCount_contactMatch_post);' + CHAR(13) + CHAR(13)               
               
	+ @sql_hashTbl_update               
               
	-- DEBUGGING --          
	--+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_contactmatch_data_' + @RecognitionType + ''') IS NOT NULL' + CHAR(13)               
	--+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_contactmatch_data_' + @RecognitionType + CHAR(13) + CHAR(13)               
               
	--+ ' SELECT a.*' + CHAR(13)              
	--+ CASE           
	--	WHEN (SELECT COUNT(0) FROM #matchkeyConfig WHERE MatchkeyHashIdentifier = 'NameAddr_ID' AND Active = 1) > 0 THEN           
	--		' ,b.ContactGUID as ContactGUID_DimCustomer' + CHAR(13)             
	--	ELSE ''          
	--  END           
	--+ ' INTO ' + @ClientDB + 'mdm.tmp_contactmatch_data_' + @RecognitionType + CHAR(13)             
	--+ ' FROM #tmp_contactmatch_data a' + CHAR(13)           
	--+ CASE           
	--	WHEN (SELECT COUNT(0) FROM #matchkeyConfig WHERE MatchkeyHashIdentifier = 'NameAddr_ID' AND Active = 1) > 0 THEN           
	--		' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId'          
	--	ELSE ''          
	--  END + CHAR(13) + CHAR(13)          
          
        
	-- Dump data to ease troubleshooting        
  	+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_' + @RecognitionType + 'match_data'') IS NOT NULL' + CHAR(13)               
	+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + 'match_data' + CHAR(13) + CHAR(13)               
               
	+ ' SELECT *' + CHAR(13)               
	+ ' INTO ' + @ClientDB + 'mdm.tmp_' + @RecognitionType + 'match_data' + CHAR(13)               
	+ ' FROM #tmp_Contactmatch_data' + CHAR(13) + CHAR(13)            
	        
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Data dump - mdm.tmp_' + @RecognitionType + 'match_data'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)                
        
	+ ' SELECT DISTINCT' + CHAR(13)               
	--+ '		cdio.IsPrimary'               
	+ ' 	cdio.dimcustomerid' + CHAR(13)               
	+ ' 	,cdio.ssid' + CHAR(13)               
	+ ' 	,cdio.sourcesystem' + CHAR(13)               
	+ '		' + @sql_tmp_ssbid_fields               
	+ ' 	, ssbid.' + @ssb_crmsystem_id_field + ' AS composite_id' + CHAR(13)               
	+ ' 	, ' + CASE WHEN @RecognitionType = 'Account' THEN 'CAST(NULL AS VARCHAR(50)) AS SSB_CRMSYSTEM_ACCT_ID' ELSE 'ssbid.SSB_CRMSYSTEM_ACCT_ID' END + CHAR(13)               
	+ ' 	, ' + CASE WHEN @RecognitionType = 'Contact' THEN 'CAST(NULL AS VARCHAR(50)) AS SSB_CRMSYSTEM_CONTACT_ID' ELSE 'ssbid.SSB_CRMSYSTEM_CONTACT_ID' END + CHAR(13)               
	+ '		, ' + CASE WHEN @RecognitionType = 'Household' THEN 'CAST(NULL AS VARCHAR(50)) AS SSB_CRMSYSTEM_HOUSEHOLD_ID' ELSE 'ssbid.SSB_CRMSYSTEM_HOUSEHOLD_ID' END + CHAR(13)               
	+ ' 	,''CI'' as createdby' + CHAR(13)               
	+ ' 	,''CI'' as updatedby' + CHAR(13)               
	+ ' 	,current_timestamp as createddate' + CHAR(13)               
	+ ' 	,current_timestamp as updateddate' + CHAR(13)               
	+ '		,cast(0 as bit) as composite_id_assigned' + CHAR(13)               
	+ '		,cast(0 as bit) as ssbid_updated' + CHAR(13)               
	+ ' INTO #tmp_ssbid' + CHAR(13)               
	+ ' from #Tmp_Contactmatch_data cdio' + CHAR(13)               
	+ CASE WHEN @PrimaryOnly = 0 THEN ' LEFT ' ELSE ' INNER ' END + 'JOIN ' + @ClientDB + 'dbo.dimcustomerssbid ssbid WITH (NOLOCK) ON cdio.dimcustomerid = ssbid.dimcustomerid' + CHAR(13)               
	+ @sql_tmp_ssbid_join + CHAR(13) + CHAR(13)               
	               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''#tmp_ssbid'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
	+ ' CREATE CLUSTERED INDEX ix_tmp_ssbid_dimcustomerid ON #tmp_ssbid (DimCustomerId)' + CHAR(13) + CHAR(13)               
               
	+ @sql_wipe_ssbid               
               
	---- Downstream bucketting               
        
	           
	+ ' Select cdio.dimcustomerid as cdio_dimcustomerid, ssbid.* ' + CHAR(13)                 
	+ ' INTO #tmp_db' + CHAR(13)               
	+ ' from #Tmp_Contactmatch_data cdio' + CHAR(13)               
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.dimcustomerssbid ssbid WITH (NOLOCK)' + CHAR(13)               
	+ ' ON cdio.dimcustomerid = ssbid.dimcustomerid;' + CHAR(13)                     
	               
	+ ' IF OBJECT_ID(''tempdb..#tmp_compositeid'') IS NOT NULL' + CHAR(13)               
	+ ' 	DROP TABLE #tmp_compositeid' + CHAR(13)               
               
	+ ' SELECT DISTINCT a.composite_id' + CHAR(13)               
	+ ' INTO #tmp_compositeid' + CHAR(13)               
	+ ' FROM #tmp_ssbid a' + CHAR(13) + CHAR(13)               
               
	+ ' CREATE CLUSTERED INDEX ix_compositeid ON #tmp_compositeid (composite_id)' + CHAR(13) + CHAR(13)               
               
	+ ' IF (SELECT COUNT(0) FROM #tmp_compositeid) > 100000' + CHAR(13)               
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0, -- int' + CHAR(13)               
	+ '			@TableName = ''' + @compositeTbl + ''', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Disable indexes - ' + @compositeTbl + ''', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)               
               
	+ ' DELETE b' + CHAR(13)               
	+ ' FROM #tmp_compositeid a' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + @compositeTbl + ' b WITH (NOLOCK) ON a.composite_id = CAST(b.' + @ssb_crmsystem_id_field + ' AS VARCHAR(50))' + CHAR(13) + CHAR(13)               
               
	+ ' SET @rowCount_compositeDelete = @rowCount_compositeDelete + @@ROWCOUNT' + CHAR(13) + CHAR(13)             
             
             
	+ ' IF OBJECT_ID(''tempdb..#potential_invalid_grouping'') IS NOT NULL' + CHAR(13)             
	+ ' DROP TABLE #potential_invalid_grouping' + CHAR(13)             
             
	+ ' ;WITH potential_invalid_grouping AS (' + CHAR(13)             
	+ @sql_potential_invalid_grouping             
	+ ' )' + CHAR(13)             
	+ ' SELECT *' + CHAR(13)             
	+ ' INTO #potential_invalid_grouping' + CHAR(13)             
	+ ' FROM potential_invalid_grouping' + CHAR(13) + CHAR(13)             
             
	+ ' CREATE NONCLUSTERED INDEX ix_potential_invalid_grouping ON #potential_invalid_grouping (' + @ssb_crmsystem_id_field + ')' + CHAR(13) + CHAR(13)             
               
	-- remove invalid groupings from composite table to ensure records are broken apart appropriately             
	+ @sql_remove_invalid_grouping             
             
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Delete Composite ' + @RecognitionType + 's'', @rowCount_compositeDelete);' + CHAR(13) + CHAR(13)               
             
	+ @sql_compositeTbl_insert               
	               
	+ ' IF (SELECT COUNT(0) FROM #tmp_compositeid) > 100000' + CHAR(13)               
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1, -- int' + CHAR(13)               
	+ '			@TableName = ''' + @compositeTbl + ''', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Enable indexes - ' + @compositeTbl + ''', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)               
               
	--+ @sql_tmp_ssbid_update_1               
               
	--+ ' UPDATE a' + CHAR(13)               
	--+ ' SET a.ssbid_updated = 1' + CHAR(13)               
	--+ ' FROM #tmp_ssbid a' + CHAR(13)               
	--+ ' WHERE composite_id IS NOT NULL' + CHAR(13) + CHAR(13)               
               
	+ @sql_tmp_ssbid_update_2               
               
	+ ' IF Object_ID(''tempdb.dbo.#Tmp_matchkey'', ''U'') Is NOT NULL' + CHAR(13)               
	+ '		DROP TABLE #Tmp_matchkey;' + CHAR(13)               
	+ ' IF Object_ID(''tempdb.dbo.#Tmp_match'', ''U'') Is NOT NULL' + CHAR(13)               
	+ '		DROP TABLE #Tmp_match;' + CHAR(13)               
	+ ' IF Object_ID(''tempdb.dbo.#Tmp_composite_cnt'', ''U'') Is NOT NULL' + CHAR(13)               
	+ '		DROP TABLE #tmp_composite_cnt;' + CHAR(13)               
	+ ' IF Object_ID(''tempdb.dbo.#Tmp_ranked'', ''U'') Is NOT NULL' + CHAR(13)          
	+ ' 		DROP TABLE #Tmp_ranked;' + CHAR(13)          
	+ ' IF Object_ID(''tempdb.dbo.#Tmp_Update'', ''U'') Is NOT NULL' + CHAR(13)               
	+ '		DROP TABLE #Tmp_Update;' + CHAR(13) + CHAR(13)               
               
	+ ' CREATE TABLE #Tmp_Matchkey (matchkey VARCHAR(50));' + CHAR(13)               
	+ ' CREATE TABLE #Tmp_Match (matchkey VARCHAR(50), composite_id VARCHAR(50), ssbid_updated_cnt INT);' + CHAR(13)               
	+ ' CREATE TABLE #tmp_Composite_cnt (composite_id varchar(50), composite_cnt int);' + CHAR(13)               
	+ ' CREATE TABLE #Tmp_ranked (matchkey VARCHAR(50), composite_id VARCHAR(50), composite_cnt INT, ssbid_updated_cnt INT, composite_rank INT);' + CHAR(13)          
	+ ' CREATE TABLE #tmp_Update (matchkey VARCHAR(50), composite_id VARCHAR(50));' + CHAR(13) + CHAR(13)               
               
	+ ' DECLARE @records INT = 1' + CHAR(13)               
	+ ' DECLARE @LoopCnt Int = 1' + CHAR(13)             
	+ ' WHILE @records >= 1 and @LoopCnt < 20' + CHAR(13)               
	+ ' BEGIN' + CHAR(13)               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Match Loop'', @records);' + CHAR(13) + CHAR(13)               
	+ '		SET @Records = 0' + CHAR(13)               
	+ @sql_loop_2               
	+ '		SET @LoopCnt = @LoopCnt + 1' + CHAR(13)            
	+ ' END' + CHAR(13) + CHAR(13)               
               
	-- Create new composite_id guid for records where one was previously assigned, but matchkeys for them no longer match               
	+ ' SELECT DISTINCT composite_id' + CHAR(13)               
	+ ' INTO #assigned_compositeid' + CHAR(13)               
	+ ' FROM #tmp_ssbid' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND composite_id_assigned = 1' + CHAR(13) + CHAR(13)               
               
	+ ' UPDATE b' + CHAR(13)               
	+ ' SET b.composite_id = NEWID()' + CHAR(13)               
	+ '	,composite_id_assigned = 1' + CHAR(13)               
	+ '	,ssbid_updated = 1'               
	+ ' FROM #assigned_compositeid a' + CHAR(13)               
	+ ' INNER JOIN #tmp_ssbid b ON a.composite_id = b.composite_id' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND b.composite_id_assigned = 0' + CHAR(13) + CHAR(13)               
               
	+ ' DROP INDEX ix_tmp_ssbid_dimcustomerid ON #tmp_ssbid' + CHAR(13) + CHAR(13)      
      
	+ ' UPDATE #tmp_ssbid' + CHAR(13)               
	+ ' SET ' + @ssb_crmsystem_id_field + ' = composite_id' + CHAR(13)               
	+ ' WHERE isnull(composite_id, '''') != isnull(' + @ssb_crmsystem_id_field + ', '''') ' + CHAR(13)               
	+ ' AND composite_id is not null' + CHAR(13) + CHAR(13)          
               
IF (@PrimaryOnly = 1)               
BEGIN               
	SET @sql = @sql               
		+ ' AND ('               
               
	SELECT @sql = @sql + a.Condition               
	FROM (               
		SELECT DISTINCT *, CASE WHEN ID != (SELECT MIN(ID) FROM #matchkeyConfig WHERE Active = 1) THEN ' OR ' ELSE '' END + a.MatchkeyHashIdentifier + ' IS NOT NULL' AS Condition               
		FROM #matchkeyConfig a               
		WHERE a.Active = 1               
	) a               
               
	SET @sql = @sql + ')' + CHAR(13) + CHAR(13)               
END               
               
SET @sql = ''       
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)              
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Full Refresh'', ' + CAST(@FullRefresh AS varchar) +');' + CHAR(13) + CHAR(13)              
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)              
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Loop Count'',' + CAST(@LoopCnt AS VARCHAR) +');' + CHAR(13) + CHAR(13)              
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)              
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Primary Only'',' + CAST(@PrimaryOnly AS VARCHAR) +');' + CHAR(13) + CHAR(13)        
       
	+ CASE WHEN @Debug = 1 THEN        
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)              
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Debug Mode'', 1);' + CHAR(13) + CHAR(13)        
	ELSE ''       
	END       
       
	+ @sql               
       
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Update SSB ' + @RecognitionType + ' ID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
	+ ' CREATE CLUSTERED INDEX ix_tmp_ssbid_dimcustomerid ON #tmp_ssbid (DimCustomerId)' + CHAR(13) + CHAR(13)      
      
	+ @sql_tmp_ssbid_audit + CHAR(13)               
            
	+ ' select a.dimcustomerid, isnull(a.' + @ssb_crmsystem_id_field + ', a.ssb_crmsystem_contact_id) as old, '         
	+ ' isnull(b.' + @ssb_crmsystem_id_field + ', b.ssb_crmsystem_contact_id) as new, b.ssb_crmsystem_contact_id,  '         
	+ ' isnull(a.ssb_crmsystem_primary_flag, 0) as old_primary_flag '         
	+ ' into #tmp_changes '         
	+ ' from #tmp_db a '         
	+ ' inner join #tmp_ssbid b '         
	+ ' on a.dimcustomerid = b.dimcustomerid '         
	/*IF  @RecognitionType != 'Contact'        
	Begin        
	SET @sql = @sql   + ' where isnull(a.' + @ssb_crmsystem_id_field + ', a.ssb_crmsystem_contact_id) != isnull(b.' + @ssb_crmsystem_id_field + ', b.ssb_crmsystem_contact_id) '         
	END*/       
        
----If Account or household, get the rest of the contact        
	IF  @RecognitionType != 'Contact'        
	Begin        
	SET @sql = @sql           
	+ ' Select b.dimcustomerid, old, new, a.ssb_crmsystem_contact_id, b.ssb_crmsystem_primary_flag as old_primary_flag '        
	+ '	into #tmp_all_change_records '        
	+ ' from #tmp_changes a '        
	+ ' inner join ' + @ClientDB + 'dbo.dimcustomerssbid b '        
	+ ' on a.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id '        
	End        
	Else        
	Begin        
	SET @sql = @sql           
	+ ' Select dimcustomerid, old, new, ssb_crmsystem_contact_id, old_primary_flag '        
	+ '	into #tmp_all_change_records '        
	+ ' from #tmp_changes '        
	End        
             
	SET @sql = @sql             
	+ ' -- splits' + CHAR(13)               
	+ ' select old, count(distinct new) as cnt '        
	+ ' into #tmp_splits '        
	+ ' from #tmp_all_change_records '        
	+ ' group by old '        
	+ ' having count(distinct new) > 1 '              
               
	+ ' -- merges' + CHAR(13)               
	+ ' select new, count(distinct old) as cnt '        
	+ ' into #tmp_merges '        
	+ ' from #tmp_all_change_records '        
	+ ' group by new '        
	+ ' having count(distinct old) > 1 '        
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.downstream_bucketting (new, old, actiontype, processed, mdm_run_dt, dimcustomerid, primaryflag, ssb_crmsystem_contact_id) ' + CHAR(13)           
	+ ' SELECT DISTINCT a.[new], old, ''' + @RecognitionType + ' merge'' AS actiontype, 0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, dimcustomerid, old_primary_flag, ssb_crmsystem_contact_id ' + CHAR(13)             
	+ ' FROM #tmp_merges a' + CHAR(13)             
	+ ' INNER JOIN #tmp_all_change_records b' + CHAR(13)             
	+ ' ON a.[new] = b.[new]' + CHAR(13)             
        
	SET @sql = @sql               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Downstream Bucketting Merges'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)              
        
             
	+ ' INSERT INTO ' + @ClientDB + 'mdm.downstream_bucketting (new, old, actiontype, processed, mdm_run_dt, dimcustomerid, primaryflag, ssb_crmsystem_contact_id)' + CHAR(13)            
	+ ' SELECT DISTINCT [new], a.old, ''' + @RecognitionType + ' split'' AS actiontype, 0 AS processed, CURRENT_TIMESTAMP AS mdm_run_dt, dimcustomerid, old_primary_flag, ssb_crmsystem_contact_id ' + CHAR(13)             
	+ ' FROM #tmp_splits a' + CHAR(13)             
	+ ' INNER JOIN #tmp_all_change_records b' + CHAR(13)             
	+ ' ON a.[old] = b.[old]' + CHAR(13) + CHAR(13)            
        
		SET @sql = @sql               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Downstream Bucketting Splits'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)          
        
               
	+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_ssbid_' + @RecognitionType + ''') IS NOT NULL' + CHAR(13)               
	+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_ssbid_' + @RecognitionType + CHAR(13) + CHAR(13)               
               
	+ ' SELECT *' + CHAR(13)               
	+ ' INTO ' + @ClientDB + 'mdm.tmp_ssbid_' + @RecognitionType + CHAR(13)               
	+ ' FROM #tmp_ssbid' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Data dump - mdm.tmp_ssbid_' + @RecognitionType + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)                
                       
	+ ' SELECT a.dimcustomerid, b.' + @ssb_crmsystem_id_field + CHAR(13)               
	+ ' INTO #tmp_ssbid_update' + CHAR(13)      
	+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13)      
	+ CASE       
		WHEN @PrimaryOnly = 0 THEN 'INNER JOIN #tmp_ssbid b ON a.dimcustomerid = b.dimcustomerid'      
		ELSE 'INNER JOIN (SELECT MAX(' + @ssb_crmsystem_id_field + ') AS ' + @ssb_crmsystem_id_field + ', SSB_CRMSYSTEM_CONTACT_ID FROM #tmp_ssbid GROUP BY SSB_CRMSYSTEM_CONTACT_ID) b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID'      
	END + CHAR(13)       
	--+ ' WHERE ISNULL(a.' + @ssb_crmsystem_id_field + ','''') != ISNULL(b.' + @ssb_crmsystem_id_field + ','''')' + CHAR(13) + CHAR(13)                      
      
	+ ' SELECT a.dimcustomerid, a.ssid, a.sourcesystem, a.SSB_CRMSYSTEM_ACCT_ID, a.SSB_CRMSYSTEM_CONTACT_ID, a.CreatedBy, a.UpdatedBy, a.CreatedDate, a.UpdatedDate, a.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)               
	+ ' INTO #tmp_ssbid_insert' + CHAR(13)               
	+ ' FROM #tmp_ssbid a' + CHAR(13)               
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.dimcustomerid = b.dimcustomerid' + CHAR(13)               
	+ ' WHERE b.dimcustomerid IS NULL;' + CHAR(13) + CHAR(13)               
            
	+ ' IF ((SELECT COUNT(0) FROM #tmp_ssbid_update) > 100000 OR (SELECT COUNT(0) FROM #tmp_ssbid_insert) > 100000)' + CHAR(13)      
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0, -- int' + CHAR(13)               
	+ '			@TableName = ''dbo.dimcustomerssbid'', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Disable indexes - dbo.dimcustomerssbid'', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)               
	            
	+ ' UPDATE a' + CHAR(13)               
	+ ' SET a.' + @ssb_crmsystem_id_field + ' = b.' + @ssb_crmsystem_id_field + ',' + CHAR(13)               
	+ ' 	UpdatedDate = current_timestamp' + CHAR(13)               
	+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a' + CHAR(13)      
	+ ' INNER JOIN #tmp_ssbid_update b ON a.dimcustomerid = b.dimcustomerid;' + CHAR(13) + CHAR(13)               
      
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Update DimcustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'dbo.dimcustomerssbid (dimcustomerid, ssid, sourcesystem, SSB_CRMSYSTEM_ACCT_ID, SSB_CRMSYSTEM_CONTACT_ID, CreatedBy, UpdatedBy, CreatedDate, UpdatedDate, SSB_CRMSYSTEM_HOUSEHOLD_ID)' + CHAR(13)               
	+ ' SELECT * FROM #tmp_ssbid_insert;' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert DimcustomerSSBID'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
      
	+ ' IF ((SELECT COUNT(0) FROM #tmp_ssbid_update) > 100000 OR (SELECT COUNT(0) FROM #tmp_ssbid_insert) > 100000)' + CHAR(13)      
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1, -- int' + CHAR(13)               
	+ '			@TableName = ''dbo.dimcustomerssbid'', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Enable indexes - dbo.dimcustomerssbid'', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)     	      
	           
	+ ' DROP TABLE #tmp_ssbid_update' + CHAR(13)      
	+ ' DROP TABLE #tmp_ssbid_insert' + CHAR(13) + CHAR(13)      
          
	+ @sql_dimcustomerMatchkey               
               
	+ ' CREATE CLUSTERED INDEX ix_dimcustomermatchkey_dimcustomerid_matchkeyid ON #dimcustomerMatchkey (DimCustomerID, MatchkeyID)' + CHAR(13)               
	+ ' CREATE NONCLUSTERED INDEX ix_dimcustomermatchkey_matchkeyvalue ON #dimcustomerMatchkey (MatchkeyValue)' + CHAR(13) + CHAR(13)               
               
	+ ' IF OBJECT_ID(''tempdb..#dimcustomermatchkey_update'') IS NOT NULL' + CHAR(13)               
	+ ' 	DROP TABLE #dimcustomermatchkey_update' + CHAR(13) + CHAR(13)               
               
	+ ' SELECT a.ID, b.*' + CHAR(13)               
	+ ' INTO #dimcustomermatchkey_update' + CHAR(13)                
	+ ' FROM ' + @ClientDB + 'dbo.DimCustomerMatchkey a WITH (NOLOCK)' + CHAR(13)               
	+ ' INNER JOIN #dimcustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)               
	+ ' 	AND a.MatchkeyID = b.MatchkeyID' + CHAR(13)               
	+ ' WHERE a.MatchkeyValue != b.MatchkeyValue' + CHAR(13) + CHAR(13)               
                      
	+ ' IF OBJECT_ID(''tempdb..#dimcustomermatchkey_insert'') IS NOT NULL' + CHAR(13)               
	+ ' 	DROP TABLE #dimcustomermatchkey_insert' + CHAR(13)               
               
	+ ' SELECT a.*' + CHAR(13)               
	+ ' INTO #dimcustomermatchkey_insert' + CHAR(13)               
	+ ' FROM #dimcustomerMatchkey a' + CHAR(13)               
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)               
	+ ' 	AND a.MatchkeyID = b.MatchkeyID' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND b.ID IS NULL' + CHAR(13) + CHAR(13)               
	               
	+ ' CREATE CLUSTERED INDEX ix_dimcustomermatchkey_insert ON #dimcustomermatchkey_insert (DimCustomerID, MatchkeyID)' + CHAR(13)               
	+ ' CREATE NONCLUSTERED INDEX ix_dimcustomermatchkey_insert_matchkeyvalue ON #dimcustomermatchkey_insert (MatchkeyValue)' + CHAR(13) + CHAR(13)               
                       
            
	-- DELETE defunct matchkeys from dbo.DimcustomerMatchkey               
	+ ' SELECT b.ID' + CHAR(13)               
	+ ' INTO #dimCustomerMatchkey_defunct' + CHAR(13)              
	+ ' FROM (' + CHAR(13)               
	+ '		SELECT DISTINCT b.DimCustomerId, b.MatchkeyID' + CHAR(13)               
	+ '		FROM #tmp_ssbid a' + CHAR(13)               
	+ '		INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
	+ '		INNER JOIN #matchkeyConfig c ON b.MatchkeyID = c.MatchkeyID' + CHAR(13)               
	+ '		AND c.Active = 0' + CHAR(13)                
	+ '		UNION' + CHAR(13)               
	+ '		SELECT DISTINCT a.DimCustomerId, a.MatchkeyID' + CHAR(13)               
	+ '		FROM ' + @ClientDB + 'dbo.DimCustomerMatchkey a WITH (NOLOCK)' + CHAR(13)               
	+ '		LEFT JOIN ' + @ClientDB + 'dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)               
	+ '		WHERE 1=1' + CHAR(13)               
	+ '		AND b.DimCustomerId IS NULL' + CHAR(13)                
	+ ' ) a' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
	+ '		AND a.MatchkeyID = b.MatchkeyID' + CHAR(13) + CHAR(13)               
               
	+ CASE                
		WHEN @FullRefresh = 1 THEN               
			' INSERT INTO #dimCustomerMatchkey_defunct' + CHAR(13)               
			+ ' SELECT b.ID' + CHAR(13)               
			+ ' FROM (' + CHAR(13)               
			+ '		SELECT DISTINCT b.DimCustomerId, b.MatchkeyID' + CHAR(13)               
			+ '		FROM #matchkeyConfig a' + CHAR(13)               
			+ '		INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.MatchkeyID = b.MatchkeyID' + CHAR(13)               
			+ '		WHERE 1=1' + CHAR(13)               
			+ '		AND a.Active = 0' + CHAR(13)                
			+ '		UNION' + CHAR(13)               
			+ '		SELECT DISTINCT a.DimCustomerId, a.MatchkeyID' + CHAR(13)               
			+ '		FROM ' + @ClientDB + 'dbo.DimCustomerMatchkey a WITH (NOLOCK)' + CHAR(13)               
			+ '		LEFT JOIN ' + @ClientDB + 'dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)               
			+ '		WHERE 1=1' + CHAR(13)               
			+ '		AND b.DimCustomerId IS NULL' + CHAR(13)                
			+ ' ) a' + CHAR(13)               
			+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)               
			+ '		AND a.MatchkeyID = b.MatchkeyID' + CHAR(13) + CHAR(13)                    
		ELSE ''               
	  END                
               
               
	-- DELETE invalid matchkeys from dbo.DimcustomerMatchkey               
	+ ' SELECT a.ID' + CHAR(13)               
	+ ' INTO #dimCustomerMatchkey_invalid' + CHAR(13)      
	+ ' FROM ' + @ClientDB + 'dbo.DimCustomerMatchkey a' + CHAR(13)               
	+ ' INNER JOIN (' + CHAR(13)               
	+ ' SELECT DISTINCT ' + CASE WHEN @RecognitionType = 'Contact' THEN 'a.DimCustomerId' ELSE 'ISNULL(a.DimCustomerId,b.DimCustomerId) AS DimCustomerId' END + ', b.MatchkeyID' + CHAR(13)               
	+ ' FROM #tmp_ssbid a' + CHAR(13)               
	+ CASE WHEN @PrimaryOnly = 0 THEN ' INNER ' ELSE CASE WHEN @FullRefresh = 1 THEN ' FULL ' ELSE ' INNER ' END END + 'JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerID' + CHAR(13)               
	+ ' INNER JOIN #matchkeyConfig c ON b.MatchkeyID = c.MatchkeyID' + CHAR(13)               
	+ ' 	AND c.Active = 1' + CHAR(13)               
	+ ' LEFT JOIN #dimcustomerMatchkey d WITH (NOLOCK) ON c.MatchkeyID = d.MatchkeyID' + CHAR(13)               
	+ ' 	AND b.DimCustomerId = d.DimCustomerId' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND (d.DimCustomerID IS NULL' + CASE WHEN @PrimaryOnly = 0 THEN '' ELSE ' OR a.DimCustomerId IS NULL' END + ')' + CHAR(13)               
	+ ' UNION' + CHAR(13)               
	+ ' SELECT DISTINCT a.DimCustomerID, a.MatchkeyID' + CHAR(13)               
	+ ' FROM #invalid_matchkey a' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b WITH (NOLOCK) ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)               
	+ ' AND a.MatchkeyID = b.MatchkeyID' + CHAR(13)               
	+ ' ) b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)               
	+ ' 	AND a.MatchkeyID = b.MatchkeyID' + CHAR(13)                 
      
	+ ' IF ((SELECT COUNT(0) FROM #dimcustomermatchkey_update) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_insert) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_defunct) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_invalid) > 100000)' + CHAR(13)               
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0, -- int' + CHAR(13)               
	+ '			@TableName = ''dbo.DimCustomerMatchkey'', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Disable indexes - dbo.DimCustomerMatchkey'', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)               
      
	-- UPDATE dbo.DimCustomerMatchkey               
	+ ' UPDATE b' + CHAR(13)               
	+ ' SET b.MatchkeyValue = a.MatchkeyValue' + CHAR(13)               
	+ '		, b.UpdateDate = CURRENT_TIMESTAMP' + CHAR(13)               
	+ ' FROM #dimcustomermatchkey_update a' + CHAR(13)               
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b ON a.ID = b.ID' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Update dbo.DimCustomerMatchkey'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)            
      
	-- INSERT dbo.DimCustomerMatchkey               
	+ ' INSERT INTO ' + @ClientDB + 'dbo.DimCustomerMatchkey (DimCustomerID, MatchkeyID, MatchkeyValue)' + CHAR(13)               
	+ ' SELECT a.DimCustomerID, a.MatchkeyID, a.MatchkeyValue' + CHAR(13)                
	+ ' FROM #dimcustomermatchkey_insert a' + CHAR(13)               
	+ ' WHERE 1=1' + CHAR(13)               
	+ ' AND a.MatchkeyValue IS NOT NULL' + CHAR(13) + CHAR(13)               
               
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Insert new dbo.DimCustomerMatchkey'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)               
         
	+ ' DELETE b' + CHAR(13)      
	+ ' FROM #dimCustomerMatchkey_defunct a' + CHAR(13)      
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b ON a.ID = b.ID' + CHAR(13) + CHAR(13)      
      
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Delete defunct dbo.DimCustomerMatchkey'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)                 
	       
	+ ' DELETE b' + CHAR(13)      
	+ ' FROM #dimCustomerMatchkey_invalid a' + CHAR(13)      
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerMatchkey b ON a.ID = b.ID' + CHAR(13) + CHAR(13)      
      
	+ ' INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ ' VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Delete invalid dbo.DimCustomerMatchkey'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)             
                  
	+ ' IF ((SELECT COUNT(0) FROM #dimcustomermatchkey_update) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_insert) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_defunct) > 100000' + CHAR(13)      
	+ '		OR (SELECT COUNT(0) FROM #dimcustomermatchkey_invalid) > 100000)' + CHAR(13)               
	+ ' BEGIN'               
	+ '		EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1, -- int' + CHAR(13)               
	+ '			@TableName = ''dbo.DimCustomerMatchkey'', -- varchar(500)' + CHAR(13)               
	+ '			@ViewCurrentIndexState = 0 -- bit' + CHAR(13) + CHAR(13)               
               
	+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
	+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''Enable indexes - dbo.DimCustomerMatchkey'', 0);' + CHAR(13) + CHAR(13)               
	+ ' END' + CHAR(13) + CHAR(13)               
               
	+ ' DROP TABLE #baseTblAllFields' + CHAR(13)               
	+ ' DROP TABLE #baseTblFieldsAll' + CHAR(13)               
	+ ' DROP TABLE #baseTblLookupFields' + CHAR(13)               
	+ ' DROP TABLE #compositeTblFields' + CHAR(13)               
	+ ' DROP TABLE #dimcustomerMatchkey' + CHAR(13)               
	+ ' DROP TABLE #matchkeyConfig' + CHAR(13)               
	+ ' DROP TABLE #matchkeyGroups' + CHAR(13)               
	+ ' DROP TABLE #tmp_cdio_changes' + CHAR(13)               
	+ ' DROP TABLE #tmp_Composite_cnt' + CHAR(13)               
	+ ' DROP TABLE #tmp_contactmatch_data' + CHAR(13)               
	+ ' DROP TABLE #tmp_contacts' + CHAR(13)               
	+ ' DROP TABLE #tmp_accounts' + CHAR(13)               
	+ ' DROP TABLE #Tmp_Match' + CHAR(13)               
	+ ' DROP TABLE #Tmp_Matchkey' + CHAR(13)               
	+ ' DROP TABLE #tmp_Update' + CHAR(13)               
	+ ' DROP TABLE #tmp_workingset' + CHAR(13) + CHAR(13)               
               
	+ @sql_dimcustomerssbid_audit               
          
	+ ' DROP TABLE #tmp_ssbid' + CHAR(13)               
	                           
----SELECT @sql            
         
IF ISNULL(LTRIM(RTRIM(@sql)),'') = ''         
BEGIN         
	SET @errorMsg = @RecognitionType + ' recognition: the @sql variable cannot be empty.'             
	RAISERROR (@errorMsg, 16, 1)              
END         
          
-- Add TRY/CATCH block to force stoppage and log error               
SET @sql = ''              
+ ' BEGIN TRY' + CHAR(13)               
+ @sql + CHAR(13)              
+ ' END TRY' + CHAR(13)              
+ ' BEGIN CATCH' + CHAR(13)              
+ '		DECLARE @ErrorMessage NVARCHAR(92)' + CHAR(13)              
+ '			, @ErrorSeverity INT' + CHAR(13)              
+ '			, @ErrorState INT' + CHAR(13) + CHAR(13)              
              
+ '		SELECT @ErrorMessage = LEFT(ERROR_MESSAGE(), 92)' + CHAR(13)               
+ '			, @ErrorSeverity = ERROR_SEVERITY()' + CHAR(13)               
+ '			, @ErrorState = ERROR_STATE()' + CHAR(13) + CHAR(13)              
              
+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)               
+ '		VALUES (current_timestamp, ''SSB ' + @RecognitionType + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)              
              
+ ' RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)              
+ '             @ErrorSeverity, -- Severity.' + CHAR(13)              
+ '             @ErrorState -- State.' + CHAR(13)              
+ '             );' + CHAR(13)              
+ ' END CATCH' + CHAR(13) + CHAR(13)       

IF @Debug = 0      
BEGIN   
	SET @sql = 'SET NOCOUNT OFF' + CHAR(13) + CHAR(13) + @sql  
 
	EXEC sp_executesql @sql              
	, N'@rowCount_cdioChanges INT, @rowCount_matchkeyChanges INT, @rowCount_workingset INT, @rowCount_contactMatch_pre INT, @rowCount_contactMatch_post INT, @rowCount_compositeDelete INT, @compositeAuditCount INT'              
	, @rowCount_cdioChanges, @rowCount_matchkeyChanges, @rowCount_workingset, @rowCount_contactMatch_pre, @rowCount_contactMatch_post, @rowCount_compositeDelete, @compositeAuditCount          
END  
ELSE       
BEGIN       
	SET @sql_debug = ''  
		+ ' SET PARSEONLY ON ---- @Debug = 1 so parse only mode is activated in order to validate SQL without execution' + CHAR(13) + CHAR(13)  
  
		+ @sql_debug + CHAR(13) + CHAR(13)  
  
		+ ISNULL(@sql,'')       
	  
	SELECT @sql_debug AS recognition_sql_debug       
  
	EXEC @return_code = sp_executesql @sql_debug  
  
	IF @return_code = 0  
		RAISERROR ('Syntax validation PASSED!', 0, 1) WITH NOWAIT;  
	ELSE   
		RAISERROR ('Syntax validation FAILED!', 0, 1) WITH NOWAIT;  
END 		              
              
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
