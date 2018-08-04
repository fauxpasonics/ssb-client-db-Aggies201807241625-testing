SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
      
CREATE PROCEDURE [mdm].[CreateMasterRecord]       
(      
	@ClientDB VARCHAR(50)      
)      
AS      
BEGIN      
      
      
/*[mdm].[CreateMasterRecord]       
* created: 08/11/2016- GHolder - creates a master record based on defined business rules for a contact. If none have been defined then the values in CD_DimCustomer are taken.      
* modified: 08/31/2016- GHolder - integrate overrides      
* modified: 12/14/2016 - GHolder - integrate NCOA      
* modified: 1/31/2017 - GHolder - replaced dbo.Source_DimCustomer with dbo.vw_Source_DimCustomer      
* modified: 4/12/2017 - GHolder - Added fix for overrides. When source data does not exist in dbo.vw_Source_DimCustomer, data in dbo.DimCustomer will be used instead.    
* modified: 3/21/2018 - GHolder - Added override housekeeping process to activate/deactivate overrides when appropriate. Also added logic to incorporate Override business rules.  
*/      
      
---DECLARE @clientdb VARCHAR(50) = 'MDM_CLIENT_TEST'  
      
IF (SELECT @@VERSION) LIKE '%Azure%'      
BEGIN      
SET @ClientDB = ''      
END      
      
IF (SELECT @@VERSION) NOT LIKE '%Azure%'      
BEGIN      
SET @ClientDB = @ClientDB + '.'      
END      
      
DECLARE @DefaultSQL nvarchar(max) = ''  
	,@DefaultFieldList nVARCHAR(MAX) = ''  
	,@DefaultJoinList nVARCHAR(MAX)  = ''  
	,@DefaultConditionList NVARCHAR(MAX) = ''  
	,@DefaultRankingList NVARCHAR(MAX) = ''  
	,@DefaultBusinessRuleIDList NVARCHAR(MAX) = ''  
	,@GetPreSQL NVARCHAR(MAX) = ''  
	,@PreSQLQuery NVARCHAR(MAX) = ''  
	,@applyNCOAClientLevel BIT = 0  
	,@applyNCOAElementLevel BIT = 0  
	,@Counter INT = 1  
	,@MDM_DB VARCHAR(50) = ''  
	,@sql NVARCHAR(MAX) = ''  
	,@sql_tmp1 NVARCHAR(MAX) = ''  
	,@sql_tmp2 NVARCHAR(MAX) = ''  
	,@sql_final NVARCHAR(MAX) = ''  
	,@tmpOverridesTblName NVARCHAR(250) = '##overrides_' + REPLACE(CAST(NEWID() AS VARCHAR(50)),'-','')  
   
 DECLARE   
	@elementFieldList nVARCHAR(MAX) = ''  
	,@elementJoinList nVARCHAR(MAX)  = ''  
	,@elementConditionList NVARCHAR(MAX) = ''  
      
IF @ClientDB != ''  
BEGIN  
	IF @@SERVERNAME = 'SSBDWDEV01' 
		SET @MDM_DB = 'SSB_MDM_TEST'  
	ELSE   
		SET @MDM_DB = 'MDM'  
END  

  
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
  
IF OBJECT_ID('tempdb..#overrideRules') IS NOT NULL  
	DROP TABLE #overrideRules  
  
CREATE TABLE #overrideRules (ranking INT, ElementID INT, BusinessRuleID INT NOT NULL, RuleType VARCHAR(50),Criteria VARCHAR(100),CriteriaField VARCHAR(100)  
	, CriteriaJoin VARCHAR(MAX), CriteriaCondition VARCHAR(MAX), LogicalOperator VARCHAR(5), GroupID INT)  
  
IF OBJECT_ID('tempdb..#overrides') IS NOT NULL  
	DROP TABLE #overrides  
  
CREATE TABLE #overrides (OverrideID INT, DimCustomerID INT, SourceSystem NVARCHAR(50), SSID NVARCHAR(100), StatusID INT, ElementID INT, Field VARCHAR(50)  
	, override_value NVARCHAR(500), dimcust_value NVARCHAR(500), composite_value NVARCHAR(500), source_value NVARCHAR(500), UpdatedDate DATETIME, OverrideRuleApplies BIT)  
  
IF OBJECT_ID('tempdb..#overrides_source') IS NOT NULL  
	DROP TABLE #overrides_source  
  
CREATE TABLE #overrides_source (OverrideID INT, DimCustomerID INT, SourceSystem NVARCHAR(50), SSID NVARCHAR(100), StatusID INT, ElementID INT, Field VARCHAR(50), dimcust_value NVARCHAR(500), composite_value NVARCHAR(500), source_value NVARCHAR(500))  
  
IF OBJECT_ID('tempdb..#stdElemFields') IS NOT NULL  
	DROP TABLE #stdElemFields  
  
CREATE TABLE #stdElemFields (ID INT, ElementGroupID INT, ElementID INT, Element VARCHAR(50), FieldID INT, FieldName VARCHAR(50))  
  
INSERT INTO #stdElemFields (ID, ElementGroupID, ElementID, Element, FieldID, FieldName)  
EXEC mdm.GetElementFields @ClientDB = @ClientDB,   -- varchar(50)  
	                        @ElementType = 'Standard', -- varchar(50)  
							@ElementIsCleanFieldFilter = 1 
  
----SELECT * FROM #stdElemFields  
  
IF OBJECT_ID('tempdb..#dimcust') IS NOT NULL  
	DROP TABLE #dimcust  
  
CREATE TABLE #dimcust (DimCustomerID INT, ElementID INT)  


--- Get all criteria pre-sql and run it once.      
      
SET @GetPreSQl = @GetPreSQL      
+' SELECT  @PreSQLQuery = COALESCE(@PreSQLQuery + '' '', '''') + c.PreSQL ' + CHAR(13)      
+' FROM  ' + @clientDb + 'mdm.criteria c ' + CHAR(13)      
+' where c.criteriaID in (select distinct criteriaid from '       
+ @clientDb + 'mdm.BusinessRules WHERE RuleType = ''DimCustomer Source'') and isnull(presql, '''') != '''' AND ISNULL(IsDeleted,0) = 0' + CHAR(13)      
     
      
EXEC sp_executesql @GetPreSQL      
        , N'@PreSQLQuery nvarchar(max) OUTPUT'      
       ,  @PreSQLQuery OUTPUT      
      
IF ISNULL(@PreSQLQuery,'') = ''
	SET @PreSQLQuery = 'RETURN'

--SELECT @PreSQLQuery

-- Add TRY/CATCH block to force stoppage and log error      
SET @PreSQLQuery = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+	@PreSQLQuery
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

--SELECT @PreSQLQuery      
      
EXEC sp_executesql @PreSQLQuery      
  
     
SET @sql = ''  
	+ ' INSERT INTO #overrideRules'  
	+ ' SELECT ROW_NUMBER() OVER (ORDER BY CASE WHEN b.ElementType = ''Default'' THEN 1 ELSE 0 END DESC, b.Element) AS ranking' + CHAR(13)  
	+ '		,b.ElementID' + CHAR(13) 
	+ ' 	,a.BusinessRuleID' + CHAR(13)  
	+ ' 	,a.RuleType' + CHAR(13)  
	+ ' 	,c.Criteria' + CHAR(13)  
	+ ' 	,c.CriteriaField' + CHAR(13)  
	+ ' 	,c.CriteriaJoin' + CHAR(13)  
	+ ' 	,c.CriteriaCondition' + CHAR(13)  
	+ ' 	,a.LogicalOperator' + CHAR(13)  
	+ ' 	,a.GroupID' + CHAR(13)  
	+ ' FROM mdm.BusinessRules a' + CHAR(13)  
	+ ' INNER JOIN mdm.Element b ON a.ElementID = b.ElementID' + CHAR(13)  
	+ ' INNER JOIN mdm.Criteria c ON a.CriteriaID = c.CriteriaID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND a.RuleType = ''Override''' + CHAR(13)  
	+ ' AND b.ElementType IN (''Default'',''Standard'')' + CHAR(13)  
	+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13) + CHAR(13)  
  
SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '.' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''' + CHAR(13)  
  
EXEC sp_executesql @sql  
  
WHILE @counter <= (SELECT MAX(ranking) FROM #overrideRules)  
BEGIN  
SET @sql = ''  
	+ ' SELECT @elementFieldList = COALESCE(@elementFieldList + '' '', '''') + a.CriteriaField + '',''' + CHAR(13)      
	+ ' , @elementJoinList = COALESCE(@elementJoinList + '' '', '''') + ISNULL(a.CriteriaJoin, '''') ' + CHAR(13)      
	+ ' , @elementConditionList = LTRIM(RTRIM(COALESCE(@elementConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + a.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, ''''))) ' + CHAR(13)      
	--+ ' , @elementConditionList = LTRIM(RTRIM(COALESCE(@elementConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + a.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, ''''))) ' + CHAR(13)      
	+ ' FROM #overrideRules a' + CHAR(13)   
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND a.ranking = ' + CAST(@counter AS VARCHAR(5)) + CHAR(13)  
	+ ' ORDER BY a.LogicalOperator' + CHAR(13) + CHAR(13)    
      
	+ 'EXEC ' + @MDM_DB + '.mdm.transformCriteriaConditionList @elementConditionList, ''' + @ClientDB + ''', @elementConditionList OUTPUT' + CHAR(13) + CHAR(13)  
   
	SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '.' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''' + CHAR(13)  
		+ ', N''@elementFieldList nvarchar(max) OUTPUT, @elementJoinList nvarchar(max) OUTPUT, @elementConditionList nvarchar(max) OUTPUT''' + CHAR(13)  
		+ ', @elementFieldList = @elementFieldList OUTPUT' + CHAR(13)  
		+ ', @elementJoinList = @elementJoinList OUTPUT' + CHAR(13)   
		+ ', @elementConditionList = @elementConditionList OUTPUT' + CHAR(13)  
  
	----SELECT @sql  
	EXEC sp_executesql @sql, N'@elementFieldList nvarchar(max) OUTPUT, @elementJoinList nvarchar(max) OUTPUT, @elementConditionList nvarchar(max) OUTPUT'      
		   , @elementFieldList = @elementFieldList OUTPUT  
		   , @elementJoinList = @elementJoinList OUTPUT   
		   , @elementConditionList = @elementConditionList OUTPUT;  
  
	----SELECT @elementConditionList  
  
	SET @sql_tmp1 = @sql_tmp1  
		+ ' INSERT INTO #overrides' + CHAR(13)  
		+ ' SELECT tmpa.OverrideID, tmpa.DimCustomerID, tmpa.SourceSystem, tmpa.SSID, 1 AS StatusID, tmpa.ElementID, tmpa.Field, tmpa.Value AS override_value, tmpc.dimcust_value, tmpc.composite_value, tmpc.source_value' + CHAR(13)  
		+ ' 	, tmpa.UpdatedDate, CAST(1 AS BIT) OverrideRuleApplies' + CHAR(13)  
		+ ' FROM ' + @tmpOverridesTblName + ' tmpa' + CHAR(13)  
		+ ' INNER JOIN #overrideRules rules ON tmpa.ElementID = rules.ElementID' + CHAR(13) 
		+ ' LEFT JOIN #overrides tmpb ON tmpa.OverrideID = tmpb.OverrideID' + CHAR(13)  
		+ ' INNER JOIN dbo.DimCustomer dimcust ON tmpa.DimCustomerID = dimcust.DimCustomerId' + CHAR(13)  
		+ ISNULL(@elementJoinList,'')  
		+ ' LEFT JOIN #overrides_source tmpc ON tmpa.OverrideID = tmpc.OverrideID' + CHAR(13)  
		+ ' WHERE 1=1' + CHAR(13)  
		+ ' AND tmpb.OverrideID IS NULL' + CHAR(13)  
		+ ' AND (' + @elementConditionList + ')' + CHAR(13) + CHAR(13)  
  
	-- reset variables 
	SET @elementFieldList = '' 
	SET @elementJoinList = '' 
	SET @elementConditionList = '' 
 
	SET @counter = @counter + 1  
END  
  
SET @sql = ''  
	--- Add sql to get source data for contacts that are currently being mastered      
	+ ' IF OBJECT_ID(''tempdb..#source'') IS NOT NULL' + CHAR(13)  
	+ '		DROP TABLE #source' + CHAR(13) + CHAR(13)  
	  
	+ ' SELECT DISTINCT SourceContactId AS SSID, Input_SourceSystem AS SourceSystem' + CHAR(13)  
	+ ' INTO #source' + CHAR(13)  
	+ ' FROM dbo.CleanDataOutput a WITH (NOLOCK)' + CHAR(13) + CHAR(13)  
	  
	+ ' CREATE CLUSTERED INDEX ix_source_ssid_sourcesystem ON #source (SSID, SourceSystem)' + CHAR(13) + CHAR(13)  
	  
	+ ' IF Object_ID(''mdm.tmp_source_DimCustomer'', ''U'') Is NOT NULL' + CHAR(13)  
	+ '		DROP TABLE mdm.tmp_source_DimCustomer;' + CHAR(13) + CHAR(13)      
  
	+ ' SELECT b.*' + CHAR(13)      
	+ ' INTO mdm.tmp_source_DimCustomer' + CHAR(13)      
	+ ' FROM #source a' + CHAR(13)      
	+ ' INNER JOIN dbo.vw_Source_DimCustomer b WITH (NOLOCK) ON a.SSID = b.SSID' + CHAR(13)      
	+ ' 	AND a.SourceSystem = b.SourceSystem' + CHAR(13) + CHAR(13)     
	  
	+ ' CREATE CLUSTERED INDEX ix_tmp_source_dimcustomer_dimcustomerid ON mdm.tmp_source_DimCustomer (DimCustomerId)' + CHAR(13)      
	+ ' CREATE NONCLUSTERED INDEX ix_tmp_source_dimcustomer_ssid_sourcesystem ON mdm.tmp_source_DimCustomer (SSID, SourceSystem)' + CHAR(13) + CHAR(13)     
      
	--- Add sql to get Clean Data output from CD_DimCustomer for contacts that are currently being mastered -- these serve as the default "Master" records      
	+ ' IF Object_ID(''mdm.tmp_Master_DimCustomer'', ''U'') Is NOT NULL' + CHAR(13)  
	+ '		DROP TABLE mdm.tmp_Master_DimCustomer;' + CHAR(13) + CHAR(13)      
  
	+ ' SELECT b.*, cast(0 as bit) as source_applied, cast(0 as bit) as override_applied, cast(0 as bit) as ncoa_applied, CAST(NULL AS VARCHAR(100)) AS ElementIDs' + CHAR(13)      
	+ ' INTO mdm.tmp_Master_DimCustomer' + CHAR(13)      
	+ ' FROM mdm.tmp_source_DimCustomer a' + CHAR(13)      
	+ ' INNER JOIN dbo.vw_CD_DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13) + CHAR(13)      
  
	+ ' CREATE CLUSTERED INDEX ix_tmp_master_dimcustomer ON mdm.tmp_Master_DimCustomer(ssid, sourcesystem)' + CHAR(13) + CHAR(13)  
      
	--- Add sql to get NCOA info from dbo.CleandDataOutput      
	+ ' IF Object_ID(''mdm.tmp_CleanDataOutput'', ''U'') Is NOT NULL' + CHAR(13)  
	+ '		DROP TABLE mdm.tmp_CleanDataOutput;' + CHAR(13) + CHAR(13)    
	    
	+ ' SELECT a.*' + CHAR(13)      
	+ ' INTO mdm.tmp_CleanDataOutput' + CHAR(13)      
	+ ' FROM dbo.CleanDataOutput a' + CHAR(13)   
    + ' WHERE ISNULL(a.ncoaAddress,'''') != ''''' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Start Override Housekeeping'', 0);' + CHAR(13) + CHAR(13)  
  
	+ ' SELECT a.OverrideID, a.DimCustomerId, a.SourceSystem, a.SSID, a.StatusID, a.ElementID, a.Field, a.Value, a.SourceValue as orig_source_value, a.UpdatedDate' + CHAR(13)  
	+ ' INTO ' + @tmpOverridesTblName + CHAR(13)  
	+ ' FROM mdm.Overrides a WITH (NOLOCK)' + CHAR(13)  
	+ ' INNER JOIN mdm.tmp_source_DimCustomer b ON a.DimCustomerId = b.DimCustomerID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND a.StatusID != 0' + CHAR(13) -- exclude manually deleted overrides  
	+ ' UNION' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerId, a.SourceSystem, a.SSID, a.StatusID, a.ElementID, a.Field, a.Value, a.SourceValue as orig_source_value, a.UpdatedDate' + CHAR(13)  
	+ ' FROM mdm.Overrides a WITH (NOLOCK)' + CHAR(13)  
	--+ ' INNER JOIN dbo.DimCustomer b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND a.StatusID != 0' + CHAR(13) + CHAR(13) -- exclude manually deleted overrides  
	--+ ' AND ( ISNULL(a.UpdatedDate, a.CreateDate) >= ISNULL(b.UpdatedDate, b.CreatedDate)' + CHAR(13)  
	--+ '		OR ISNULL(a.UpdatedDate, a.CreateDate) >= ISNULL((SELECT MAX(logdate) FROM mdm.auditlog WITH (NOLOCK) WHERE mdm_process = ''create master record'' and process_step = ''Start Override Housekeeping''),''1/1/1900'') )' + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Get overrides'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)  
  
	+ ' INSERT INTO #overrides_source' + CHAR(13)  
	+ ' EXEC ' + @MDM_DB + '.mdm.GetOverrideSourceValues @ClientDB = ''' + REPLACE(@ClientDB,'.','') + ''',' + CHAR(13)  
	+ '                                          @tmpOverridesTblName = ''' + @tmpOverridesTblName + ''',' + CHAR(13)  
	+ '											 @getCompositeValues = 0' + CHAR(13) + CHAR(13) 
  
	+ @sql_tmp1  
  
	+ ' DECLARE @rowCount INT = 0' + CHAR(13) + CHAR(13)  
  
	+ ' -- Missing from dbo.DimCustomer' + CHAR(13)  
	+ ' INSERT INTO #overrides' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, -2 AS StatusID, a.ElementID, a.Field, a.Value AS override_value, c.dimcust_value, c.composite_value, c.source_value' + CHAR(13)  
	+ ' 	, a.UpdatedDate, CAST(0 AS BIT) OverrideRuleApplies' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' LEFT JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN dbo.DimCustomer d WITH (NOLOCK) ON a.DimCustomerID = d.DimCustomerID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND b.OverrideID IS NULL' + CHAR(13)   
	+ ' AND d.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)  
  
	+ ' SELECT @rowCount = COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' INNER JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' WHERE a.StatusID != -2' + CHAR(13)  
	+ ' AND b.StatusID = -2' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Deactivate overrides missing from dbo.DimCustomer'', @rowCount);' + CHAR(13) + CHAR(13)  
  
	+ ' -- Missing from dbo.Source_DimCustomer' + CHAR(13)  
	+ ' INSERT INTO #overrides' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, -3 AS StatusID, a.ElementID, a.Field, a.Value AS override_value, c.dimcust_value, c.composite_value, c.source_value' + CHAR(13)  
	+ ' 	, a.UpdatedDate, CAST(0 AS BIT) OverrideRuleApplies' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' LEFT JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN dbo.vw_Source_DimCustomer d WITH (NOLOCK) ON a.DimCustomerID = d.DimCustomerID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND b.OverrideID IS NULL' + CHAR(13)   
	+ ' AND d.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)  
	  
	+ ' SELECT @rowCount = COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' INNER JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' WHERE a.StatusID != -3' + CHAR(13)  
	+ ' AND b.StatusID = -3' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Deactivate overrides missing from dbo.Source_DimCustomer'', @rowCount);' + CHAR(13) + CHAR(13)  
  
	+ ' -- Missing from dbo.CD_DimCustomer' + CHAR(13)  
	+ ' INSERT INTO #overrides' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, -4 AS StatusID, a.ElementID, a.Field, a.Value AS override_value, c.dimcust_value, c.composite_value, c.source_value' + CHAR(13)  
	+ ' 	, a.UpdatedDate, CAST(0 AS BIT) OverrideRuleApplies' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' LEFT JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN dbo.vw_CD_DimCustomer d WITH (NOLOCK) ON a.DimCustomerID = d.DimCustomerID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND b.OverrideID IS NULL' + CHAR(13)   
	+ ' AND d.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)  
  
	+ ' SELECT @rowCount = COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' INNER JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' WHERE a.StatusID != -4' + CHAR(13)  
	+ ' AND b.StatusID = -4' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Deactivate overrides missing from dbo.CD_DimCustomer'', @rowCount);' + CHAR(13) + CHAR(13)  
  
	+ ' INSERT INTO #overrides' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, 1 AS StatusID, a.ElementID, a.Field, a.Value AS override_value, c.dimcust_value, c.composite_value, c.source_value' + CHAR(13)  
	+ ' 	, a.UpdatedDate, CAST(0 AS BIT) OverrideRuleApplies' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' LEFT JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' INNER JOIN dbo.DimCustomer d WITH (NOLOCK) ON a.DimCustomerID = d.DimCustomerId' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND b.OverrideID IS NULL' + CHAR(13)  
	+ ' AND (ISNULL(a.orig_source_value,'''') = ISNULL(c.source_value,'''')' + CHAR(13)   
	+ ' 	OR a.UpdatedDate >= ISNULL(d.UpdatedDate, d.CreatedDate))' + CHAR(13) + CHAR(13)  
  
	+ ' -- Deactivated by incoming update to source' + CHAR(13)  
	+ ' INSERT INTO #overrides' + CHAR(13)  
	+ ' SELECT a.OverrideID, a.DimCustomerID, a.SourceSystem, a.SSID, -1 AS StatusID, a.ElementID, a.Field, a.Value AS override_value, c.dimcust_value, c.composite_value, c.source_value' + CHAR(13)  
	+ ' 	, a.UpdatedDate, CAST(0 AS BIT) OverrideRuleApplies' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' LEFT JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND b.OverrideID IS NULL' + CHAR(13) + CHAR(13)  
  
	+ ' SELECT @rowCount = COUNT(0)' + CHAR(13)  
	+ ' FROM ' + @tmpOverridesTblName + ' a' + CHAR(13)  
	+ ' INNER JOIN #overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' WHERE a.StatusID != -1' + CHAR(13)  
	+ ' AND b.StatusID = -1' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Deactivate overrides with newer, different source value'', @rowCount);' + CHAR(13) + CHAR(13)  
  
	+ ' SET CONTEXT_INFO 0x55555' + CHAR(13) + CHAR(13) -- Used to temporarily "disable" the trigger on mdm.Overrides  
  
	+ ' UPDATE b' + CHAR(13)  
	+ ' SET b.StatusID = a.StatusID' + CHAR(13)  
	+ ' 	, b.ActivatedDate = CASE WHEN a.StatusID > 0 THEN GETDATE() ELSE b.ActivatedDate END' + CHAR(13)  
	+ '		, b.DeactivatedDate = CASE WHEN a.StatusID < 0 THEN GETDATE() ELSE b.DeactivatedDate END' + CHAR(13)  
	+ '		, b.SourceValue = CASE WHEN a.StatusID > 0 AND b.StatusID < 0 THEN c.source_value ELSE b.SourceValue END' + CHAR(13)  
	+ '		, b.UpdatedDate = GETDATE()' + CHAR(13)  
	+ ' 	, b.UpdatedBy = SYSTEM_USER' + CHAR(13)  
	+ ' --SELECT *' + CHAR(13)  
	+ ' FROM #overrides a' + CHAR(13)  
	+ ' INNER JOIN mdm.Overrides b ON a.OverrideID = b.OverrideID' + CHAR(13)  
	+ ' LEFT JOIN #overrides_source c ON a.OverrideID = c.OverrideID' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13)  
	+ ' AND a.StatusID != b.StatusID' + CHAR(13) + CHAR(13)  
	  
	+ ' DELETE a' + CHAR(13)  
	+ ' FROM #overrides a' + CHAR(13)  
	+ ' WHERE a.StatusID < 1' + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Exclude deactivated overrides'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)  
  
	+ ' DROP TABLE ' + @tmpOverridesTblName + CHAR(13) + CHAR(13)  
  
	+ ' Insert into mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ ' values (current_timestamp, ''create master record'', ''Complete Override Housekeeping'', 0);' + CHAR(13) + CHAR(13)  
  
	-- Add sql to get applicable overrides for client      
	+ ' SELECT DISTINCT DimCustomerID, SSID, SourceSystem' + CHAR(13)  
	+ ' INTO #overridesToApply' + CHAR(13)   
	+ ' FROM #overrides' + CHAR(13) + CHAR(13)  
  
	----+ ' SELECT * FROM #overridesToApply' + CHAR(13) + CHAR(13)  
  
	+ ' CREATE CLUSTERED INDEX ix_overrides_dimcustomerid ON #overridesToApply (DimCustomerID)' + CHAR(13)      
	+ ' CREATE NONCLUSTERED INDEX ix_overrides_ssid_sourcesystem ON #overridesToApply (SSID, SourceSystem)' + CHAR(13) + CHAR(13)  
	  
	-- Pull applicable override records into mdm.tmp_source_DimCustomer where available     
	+ ' INSERT INTO mdm.tmp_source_DimCustomer' + CHAR(13)      
	+ ' SELECT b.*' + CHAR(13)      
	+ ' FROM #overridesToApply a' + CHAR(13)      
	+ ' INNER JOIN dbo.vw_Source_DimCustomer b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)      
	+ ' LEFT JOIN mdm.tmp_source_DimCustomer c ON b.DimCustomerID = c.DimCustomerID' + CHAR(13)      
	+ ' WHERE c.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)      
  
	+ ' INSERT INTO mdm.tmp_Master_DimCustomer' + CHAR(13)      
	+ ' SELECT b.*, cast(0 as bit) as source_applied, cast(0 as bit) as override_applied, cast(0 as bit) as ncoa_applied, CAST(NULL AS VARCHAR(100)) AS ElementIDs' + CHAR(13)      
	+ ' FROM #overridesToApply a' + CHAR(13)      
	+ ' INNER JOIN dbo.vw_CD_DimCustomer b ON a.SSID = b.SSID' + CHAR(13)      
	+ ' 	AND a.SourceSystem = b.SourceSystem' + CHAR(13)      
	+ ' LEFT JOIN mdm.tmp_Master_DimCustomer c ON b.SSID = c.SSID' + CHAR(13)      
	+ ' 	AND b.SourceSystem = c.SourceSystem' + CHAR(13)      
	+ ' WHERE c.SSID IS NULL' + CHAR(13)      
    
-- Add TRY/CATCH block to force stoppage and log error      
SET @sql_final = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+ @sql_final
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
		  
SET @sql_final = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '.' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''' + CHAR(13)  
  
----SELECT @sql_final  
EXEC sp_executesql @sql_final  
  
----SELECT * FROM #overrides  
      
--- Get Criteria for Default      
SET @DefaultSQL = @DefaultSQL      
      
+ ' SELECT @DefaultFieldList = COALESCE(@DefaultFieldList + '' '', '''') + c.CriteriaField + '' as ['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + '']''' + CHAR(13)   
+ ' , @DefaultJoinList = COALESCE(@DefaultJoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)      
+ ' , @DefaultConditionList = LTRIM(RTRIM(COALESCE(@DefaultConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + c.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, '''')))' + CHAR(13)      
+ ' , @DefaultRankingList = COALESCE(@DefaultRankingList + '' '', '''') + ''['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + ''] '' + Isnull(c.CriteriaOrder, ''ASC'') + '',''' + CHAR(13)   
+ ' , @DefaultBusinessRuleIDList = COALESCE(@DefaultBusinessRuleIDList + '' '', '''') + CAST(a.BusinessRuleID AS VARCHAR(5)) + '',''' + CHAR(13)  
+ ' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)      
+ ' INNER JOIN ' + @clientDb + 'mdm.element b ON a.elementid = b.elementid ' + CHAR(13)      
+ ' INNER JOIN ' + @clientDb + 'mdm.criteria c ON c.criteriaID = a.criteriaID ' + CHAR(13)      
+ ' WHERE element = ''Default''' + CHAR(13)      
+ ' AND a.RuleType = ''DimCustomer Source''' + CHAR(13)      
+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)     
+ ' ORDER BY a.LogicalOperator, priority' + CHAR(13) + CHAR(13)    
      
+ 'EXEC mdm.transformCriteriaConditionList @DefaultConditionList, ''' + @ClientDB + ''', @DefaultConditionList OUTPUT'      
      
EXEC sp_executesql @DefaultSQL      
        , N'@DefaultFieldList nvarchar(max) OUTPUT, @DefaultJoinList nvarchar(max) OUTPUT, @DefaultConditionList nvarchar(max) OUTPUT, @DefaultRankingList nvarchar(max) OUTPUT, @DefaultBusinessRuleIDList nvarchar(max) OUTPUT'      
	   , @DefaultFieldList OUTPUT      
       , @DefaultJoinList OUTPUT      
	   , @DefaultConditionList OUTPUT      
	   , @DefaultRankingList OUTPUT  
	   , @DefaultBusinessRuleIDList OUTPUT  
      
----SELECT @defaultsql, @DefaultFieldList, @DefaultJoinList, @DefaultConditionList      
      
DECLARE @ElementsSQL NVARCHAR(max);      
      
DECLARE @ElementsList TABLE (      
UID INT IDENTITY(1,1) PRIMARY KEY      
, ElementID Int      
, Element VARCHAR(50)      
, ElementFieldList nvarchar(max)      
, ElementUpdateStatement nvarchar(max)      
, ElementIsCleanField varchar(100)      
)      
      
SET @ElementsSQL = ' '       
+' SELECT ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField FROM ' + @ClientDB + 'mdm.element ' + CHAR(13)      
+ 'WHERE 1=1 AND ElementType in (''Standard'') AND isnull(isdeleted, 0) = 0;' + CHAR(13)      
      
----SELECT @ElementsSQL      
      
INSERT INTO @ElementsList (ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField)      
EXEC sp_executesql @ElementsSQL      
            
DECLARE @ElementLoop INT--, @SQL NVARCHAR(max) = ''      
DECLARE @ElementID VARCHAR(5), @Element VARCHAR(50)--, @ElementFieldList nVARCHAR(MAX)  
, @ElementUpdateStatement NVARCHAR(MAX)  
, @ElementIsCleanField VARCHAR(100)      
      
SET @ElementLoop = (SELECT MAX(UID) FROM @ElementsList)      
SET @Counter = 1      
      
      
DECLARE @SQL2 NVARCHAR(MAX) = '';      
DECLARE @FieldList nVARCHAR(MAX) = '';      
DECLARE @OverrideFieldList NVARCHAR(MAX) = '';      
DECLARE @JoinList nVARCHAR(MAX)  = '';      
DECLARE @ConditionList nVARCHAR(MAX)  = '';      
DECLARE @RankingList NVARCHAR(MAX) = '';  
DECLARE @BusinessRuleIDList NVARCHAR(MAX) = '';  
DECLARE @TableSuffix VARCHAR(100)      
      
DECLARE @ElementFieldTbl TABLE (ID INT, ElementID INT, Element VARCHAR(50), FieldID INT, Field VARCHAR(50))      
DECLARE @Field VARCHAR(50) = '', @RowCount INT = 0, @elemCounter INT = 1, @fieldCounter INT = 1    
      
--DECLARE fieldCur CURSOR FOR      
--SELECT Element, Field  
--FROM @ElementFieldTbl      
      
WHILE @ElementLoop >= @Counter      
BEGIN      
	--SELECT * FROM @ElementsList  
	SET @ElementID = (SELECT CAST(ElementID AS VARCHAR) FROM @ElementsList WHERE UID = @Counter)      
	SET @Element = (SELECT Element FROM @ElementsList WHERE UID = @Counter)      
	SET @ElementFieldList = (SELECT ElementFieldList FROM @ElementsList WHERE UID = @Counter)      
	SET @ElementIsCleanField = (SELECT ElementIsCleanField FROM @ElementsList WHERE UID = @Counter)      
  
	IF @ElementIsCleanField IS NOT NULL  
		SET @ElementUpdateStatement = REPLACE((SELECT ElementUpdateStatement FROM @ElementsList WHERE UID = @Counter), 'data.' + @ElementIsCleanField, '''Valid - Source''')      
	ELSE  
		SET @ElementUpdateStatement = (SELECT ElementUpdateStatement FROM @ElementsList WHERE UID = @Counter)  
  
	--SELECT @ElementUpdateStatement  
  
	SET @TableSuffix = REPLACE(@Element, ' ', '')         
      
	--- Get Criteria for Element      
	SET @SQL2 = ' '      
	+' SELECT @FieldList = COALESCE(@FieldList + '' '', '''') + c.CriteriaField + '' as ['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + '']'' + '',''' + CHAR(13)   
	+' , @JoinList = COALESCE(@JoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)      
	+' , @ConditionList = LTRIM(RTRIM(COALESCE(@ConditionList + '' '', '''') + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + c.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, ''''))) ' + CHAR(13)      
	+' , @RankingList = COALESCE(@RankingList + '' '', '''') + ''['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + ''] '' + Isnull(c.CriteriaOrder, ''ASC'') + '',''' + CHAR(13)   
	+' , @BusinessRuleIDList = COALESCE(@BusinessRuleIDList + '' '', '''') + CAST(a.BusinessRuleID AS VARCHAR(5)) + '',''' + CHAR(13)  
	+' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)      
	+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)      
	+' ON a.elementid = b.elementid ' + CHAR(13)      
	+' INNER JOIN ' + @clientDb + 'mdm.criteria c ' + CHAR(13)      
	+' ON c.criteriaID = a.criteriaID ' + CHAR(13)      
	+' Where a.elementID = ' + @ElementID + CHAR(13)      
	+' AND a.RuleType = ''DimCustomer Source''' + CHAR(13)      
	+' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)     
	+ ' ORDER BY a.LogicalOperator, priority' + CHAR(13) + CHAR(13)    
      
	+ 'EXEC mdm.transformCriteriaConditionList @ConditionList, ''' + @ClientDB + ''', @ConditionList OUTPUT'      
	      
	+ ' TRUNCATE TABLE #dimcust' + CHAR(13) + CHAR(13)  
      
	EXEC sp_executesql @SQL2      
			, N'@FieldList nvarchar(max) OUTPUT, @JoinList nvarchar(max) OUTPUT, @ConditionList nvarchar(max) OUTPUT, @RankingList nvarchar(max) OUTPUT, @BusinessRuleIDList nvarchar(max) OUTPUT'      
		   , @FieldList OUTPUT      
		   , @JoinList OUTPUT      
		   , @ConditionList OUTPUT      
		   , @RankingList OUTPUT  
		   , @BusinessRuleIDList OUTPUT  
      
	--PRINT @FieldList      
	--PRINT @JoinList       
      
	SET @SQL = ''     
	SET @sql_tmp1 = ''  
	SET @sql_tmp2 = ''   
      
	IF (ISNULL(@DefaultFieldList,'') != '' AND (ISNULL(@FieldList,'') = '' ))     
	BEGIN    
		SET @sql = @sql  
			+ 'PRINT ''...............' + @Element + ' - Source''' + CHAR(13)  
			+ 'PRINT ''...........................................Using Default''' + CHAR(13) + CHAR(13)  
  
		SET @FieldList = @DefaultFieldList     
		SET @JoinList = @DefaultJoinList     
		SET @ConditionList = @DefaultConditionList  
		SET @RankingList = @DefaultRankingList  
		SET @BusinessRuleIDList = @DefaultBusinessRuleIDList  
	END  
	ELSE IF (ISNULL(@FieldList,'') != '' )  
	BEGIN  
		SET @sql = @sql  
			+ ' PRINT ''...............' + @Element + ' - Source''' + CHAR(13)  
			+ ' PRINT ''...........................................Using element-specific business rules''' + CHAR(13) + CHAR(13)  
	END  
  
	-- Update Master record accordingly based on business rules     
	IF (ISNULL(@ConditionList,'') != '' OR ISNULL(@JoinList,'') != '') --OR ISNULL(@DefaultFieldList,'') != ''      
	BEGIN      
		--Get Ranking      
		SET @sql = @sql      
			--+ 'IF Object_ID(''tempdb.dbo.#tmp_ranking_default'', ''U'') Is NOT NULL '+ CHAR(13)      
			--+ ' Drop table #tmp_ranking_default;'+ CHAR(13)      
			--SET @sql = @sql + CHAR(13) + CHAR(13)      
			--SET @sql = @sql      
			+ ' SELECT dimcust.DimCustomerID, dimcust.SSID, dimcust.SourceSystem' + CHAR(13)      
			+ ' ,' + @ElementFieldList + CHAR(13)  
			+ ' ,' + @FieldList + CHAR(13)  
			+ ' CAST(NULL AS BIT) as dummy_col' + CHAR(13)
			+ ' into #tmp_'+ @TableSuffix + CHAR(13)      
			+ 'FROM ' + @ClientDB + 'mdm.tmp_source_DimCustomer dimcust ' + CHAR(13)      
			+ @JoinList + CHAR(13)      
			+ 'WHERE 1=1' + CHAR(13)      
		      
			IF ISNULL(@ConditionList,'') != ''      
				SET @SQL = @SQL + 'AND (' + CHAR(13) + @ConditionList + CHAR(13) + ')' + CHAR(13)      
			       
			IF @Joinlist LIKE '%mdm.SourceSystemPriority%'       
			BEGIN      
				SET @sql = @sql + 'and  isnull(elementid, ' + @elementID  + ') =  case when (select count(0) from ' + @clientdb + 'mdm.sourcesystempriority where elementid = ' + @elementID  + ') > 0       
					then ' + @elementID  + ' else  (select elementid from ' + @clientdb + 'mdm.element where element = ''Default'') end;'      
      
					---SET @SQL = @SQL + 'where isnull(elementid, ' + @elementID  + ') = ' + @elementID       
			END      
		      
		SET @sql = @sql + CHAR(13)   
			  
			+ ' SELECT *' + CHAR(13)  
			+ '		,row_number() over (partition by dimcust.ssid, dimcust.sourcesystem order by '+ @RankingList + ' dimcust.dimcustomerid desc) as ranking' + CHAR(13)      
			+ ' into #tmp_ranking_'+ @TableSuffix + CHAR(13)  
			+ ' FROM #tmp_'+ @TableSuffix + ' dimcust' + CHAR(13) + CHAR(13)  
  
			+ ' DROP TABLE #tmp_'+ @TableSuffix + CHAR(13)  
				  
			+ ' CREATE CLUSTERED INDEX ix_tmp_ranking ON #tmp_ranking_'+ @TableSuffix + '(SSID, SourceSystem)' + CHAR(13) + CHAR(13)   
			  
			+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_source_ranking_DimCustomer'') IS NULL' + CHAR(13)
			+ '		CREATE TABLE ' + @ClientDB + '[mdm].[tmp_source_ranking_DimCustomer](' + CHAR(13)
			+ '			[DimCustomerID] [int] NULL,' + CHAR(13)
			+ '			[SSID] [varchar](100) NULL,' + CHAR(13)
			+ '			[SourceSystem] [varchar](50) NULL,' + CHAR(13)
			+ '			[Element] [varchar](50) NULL,' + CHAR(13)
			+ '			[BusinessRuleIDList] [varchar](250) NULL,' + CHAR(13)
			+ '			[rankingLogic] [varchar](max) NULL,' + CHAR(13)
			+ '			[ranking] [int] NULL,' + CHAR(13)
			+ '			[CreatedDate] [DATETIME] CONSTRAINT [DF_tmp_source_ranking_DimCustomer_CreatedDate]  DEFAULT (getdate())' + CHAR(13)
			+ '		)' + CHAR(13) + CHAR(13)

			+ ' DELETE FROM b' + CHAR(13)  
			+ ' FROM #tmp_ranking_'+ @TableSuffix + ' a' + CHAR(13)  
			+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_source_ranking_DimCustomer b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)  
			+ '		AND b.Element = ''' + @Element + '''' + CHAR(13)  
  
			+ ' INSERT INTO ' + @ClientDB + 'mdm.tmp_source_ranking_DimCustomer (DimCustomerID, SSID, SourceSystem, Element, BusinessRuleIDList, rankingLogic, ranking)' + CHAR(13)  
			+ ' SELECT a.DimCustomerID, a.SSID, a.SourceSystem, ''' + @Element + ''' AS Element'  
			+ ' , ''' + @BusinessRuleIDList + ''' AS BusinessRuleIDList, ''row_number() over (partition by dimcust.ssid, dimcust.sourcesystem order by '+ @FieldList + ' dimcust.dimcustomerid desc)'' as rankingLogic, ranking' + CHAR(13)  
			+ ' FROM #tmp_ranking_'+ @TableSuffix + ' a' + CHAR(13) + CHAR(13)  
      
		  
		---Update Element     
		SET @sql = @sql      
			+ 'Update ' + @ClientDB + 'mdm.tmp_Master_DimCustomer ' + CHAR(13)      
			+ ' SET '      
			+ @ElementUpdateStatement      
			+ ', [UpdatedDate] = current_timestamp ' + CHAR(13)      
			+ ', source_applied = 1' + CHAR(13)      
			+ ', ElementIDs = ISNULL(ElementIDs,'''') + CASE WHEN ISNULL(ElementIDs,'''') != '''' THEN '','' ELSE '''' END + ''' + @ElementID + '''' + CHAR(13)      
			+ ' from #tmp_ranking_' + @TableSuffix + ' data ' + CHAR(13)      
			+ ' inner join  ' + @clientdb + 'mdm.tmp_Master_DimCustomer  mdm on data.DimCustomerID = mdm.DimCustomerID' + CHAR(13) --data.ssid = mdm.ssid' + CHAR(13)      
			+ ' where ranking = 1  ' + CHAR(13)      
			+ ' and (isnull(mdm.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ElementUpdateStatement, CHAR(9),''), CHAR(13),''), CHAR(10),''), ' ',''),',',','''') or isnull(mdm.'),'=',','''') != isnull(') + ','''')' + ')' + CHAR(13)      
  
		---Write Log Entry      
		SET @sql = @sql      
			+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
			+ 'values (current_timestamp, ''create master record'', ''update master record - '+ @Element + ''', @@ROWCOUNT);'       
		SET @sql = @sql + CHAR(13) + CHAR(13)      
      
  
		-- GET AFFECTED RECORDS - WILL BE USED LATER IN COMPOSITERECORD  
		SET @sql = @sql  
			+ ' INSERT INTO #dimcust' + CHAR(13)  
			+ ' SELECT DISTINCT a.DimCustomerID, CASE WHEN ElementIDs LIKE ''%' + @ElementID + '%'' THEN ' + @ElementID + ' ELSE NULL END' + CHAR(13)  
			+ ' FROM ' + @clientdb + 'mdm.tmp_Master_DimCustomer a ' + CHAR(13)   
			+ ' LEFT JOIN #dimcust b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)  
			+ '		AND b.ElementID = ' + @ElementID + CHAR(13)      
			+ ' where 1 = 1  ' + CHAR(13)    
			+ ' and b.DimCustomerID IS NULL' + CHAR(13)	   
  
		SET @SQL = @SQL      
		+ 'drop table #tmp_ranking_'+ @TableSuffix      
		SET @sql = @sql + CHAR(13) + CHAR(13)      
      
	END      
  
	-- Finally, apply any client-submitted overrides      
	---Override Element      
  
	SET @SQL2 = ''      
		+ ' SELECT DENSE_RANK() OVER (ORDER BY Element) AS ID, ElementID, Element, ROW_NUMBER() OVER (PARTITION BY Element ORDER BY FieldName) AS FieldID, FieldName' + CHAR(13)      
		+ ' FROM #stdElemFields a' + CHAR(13)      
		+ ' WHERE a.ElementID = ' + @ElementID + CHAR(13) + CHAR(13)  
  
	--SET @SQL2 = ''      
	--	+ ' SELECT DISTINCT a.Field' + CHAR(13)      
	--	+ ' FROM #overrides a' + CHAR(13)      
	--	+ ' INNER JOIN ' + @ClientDB + 'mdm.Element b on a.ElementID = b.ElementID' + CHAR(13)      
	--	+ ' Where a.elementID = ' + @ElementID + CHAR(13)      
	--	+ ' AND a.StatusID = 1' + CHAR(13) + CHAR(13)  
      
	DELETE FROM @ElementFieldTbl  
  
	INSERT INTO @ElementFieldTbl (ID, ElementID, Element, FieldID, Field)      
	EXEC sp_executesql @SQL2     
  
    SET @elemCounter = 1  
	WHILE @elemCounter <= (SELECT MAX(ID) FROM @ElementFieldTbl)  
	BEGIN  
		SET @sql_tmp1 = ''  
		SET @sql_tmp2 = ''  
		SET @fieldCounter = 1  
  
		WHILE @fieldCounter <= (SELECT MAX(FieldID) FROM @ElementFieldTbl WHERE ID = @elemCounter)  
		BEGIN  
			SELECT @Element = Element, @ElementID = ElementID, @Field = Field  
			FROM @ElementFieldTbl  
			WHERE ID = @elemCounter  
			AND FieldID = @fieldCounter  
		  
			SET @sql_tmp1 = @sql_tmp1   
				+ 'Update ' + @clientdb + 'mdm.tmp_Master_DimCustomer ' + CHAR(13)      
				+ ' SET ' + @Field + ' = data.override_value' + CHAR(13)      
				+ ', [UpdatedDate] = current_timestamp ' + CHAR(13)      
				--+ ', source_applied = 1' + CHAR(13)  
				+ ', override_applied = 1' + CHAR(13)      
				+ ', ElementIDs = ISNULL(ElementIDs,'''') + CASE WHEN ISNULL(ElementIDs,'''') != '''' THEN '','' ELSE '''' END + ''' + @ElementID + '''' + CHAR(13)    
				+ ' OUTPUT INSERTED.DimCustomerID INTO @updates (DimCustomerID)' + CHAR(13)  
				+ ' from #overrides data ' + CHAR(13)      
				+ ' inner join ' + @ClientDB + 'mdm.tmp_source_DimCustomer source on data.DimCustomerID = source.DimCustomerId' + CHAR(13)      
				+ ' inner join ' + @clientdb + 'mdm.tmp_Master_DimCustomer  master on source.ssid = master.ssid' + CHAR(13)      
					+ '		and source.sourcesystem = master.sourcesystem' + CHAR(13)      
				+ ' where 1 = 1  ' + CHAR(13)      
				+ ' and data.ElementID = ' + @ElementID + CHAR(13)      
				+ ' and data.Field = ''' + @Field + '''' + CHAR(13)      
				+ ' AND data.StatusID = 1' + CHAR(13) + CHAR(13)  
			      
				+ ' DELETE b' + CHAR(13)  
				+ ' FROM ' + @ClientDB + 'mdm.tmp_Master_DimCustomer a' + CHAR(13)  
				+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)  
				+ '		AND b.ElementID = ' + @ElementID + CHAR(13)      
				+ '		AND b.Field = ''' + @Field + '''' + CHAR(13)  
				+ '		AND b.Value != a.' + @Field + CHAR(13) + CHAR(13)  
				--+ ' WHERE 1=1' + CHAR(13)  
				--+ ' AND b.ProcessedDate IS NOT NULL' + CHAR(13)  
				--+ ' AND b.AppliedToCompositeDate IS NOT NULL' + CHAR(13) + CHAR(13)  
  
				+ ' INSERT INTO ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord (DimCustomerID, SSID, SourceSystem, ElementID, Element, Field, Value, OverrideID, AppliedToDimCustomer_TS)' + CHAR(13)  
				+ ' SELECT DISTINCT a.DimCustomerID, a.SSID, a.SourceSystem, ' + @ElementID + ', ''' + @Element + ''', ''' + @Field + ''', a.' + @Field + ', c.OverrideID, GETDATE()' + CHAR(13)  
				+ ' FROM ' + @ClientDB + 'mdm.tmp_Master_DimCustomer a' + CHAR(13)  
				+ ' LEFT JOIN #overrides c ON a.DimCustomerID = c.DimCustomerID' + CHAR(13)  
				+ '		AND c.ElementID = ' + @ElementID + CHAR(13)      
				+ '		AND c.Field = ''' + @Field + '''' + CHAR(13)      
				+ '		AND c.StatusID = 1' + CHAR(13)  
				+ ' LEFT JOIN ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord d ON a.DimCustomerID = d.DimCustomerID' + CHAR(13)  
				+ '		AND d.ElementID = ' + @ElementID + CHAR(13)      
				+ '		AND d.Field = ''' + @Field + '''' + CHAR(13)    
				+ ' WHERE 1=1' + CHAR(13)  
				+ ' AND c.OverrideID IS NOT NULL' + CHAR(13)  
				+ ' AND d.DimCustomerID IS NULL' + CHAR(13) + CHAR(13)  
  
				SET @fieldCounter = @fieldCounter + 1     
		END  
  
		---Write Log Entry      
		SET @sql_tmp2 = @sql_tmp2 + @sql_tmp1   
			+ ' SELECT @RowCount = COUNT(DISTINCT DimCustomerID) FROM @updates' + CHAR(13) + CHAR(13)  
  
			+ ' IF (@RowCount > 0)' + CHAR(13)  
			+ '		Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
			+ '		values (current_timestamp, ''create master record'', ''override master record - ' + @Element + ''', @RowCount);' + CHAR(13) + CHAR(13)  
			  
			+ ' SET @RowCount = 0' + CHAR(13)  
			+ ' DELETE FROM @updates' + CHAR(13) + CHAR(13)   
  
		SET @elemCounter = @elemCounter + 1  
  
		--SELECT @sql  
	       
	END  
 
	SET @sql = ''   
		+ @sql   
		+ ' DECLARE @updates TABLE (DimCustomerID INT)' + CHAR(13) + CHAR(13) 
		+ @sql_tmp2  
	  
 	-- Add TRY/CATCH block to force stoppage and log error      
	SET @sql = ''     
		+ ' BEGIN TRY' + CHAR(13)      
		+ @sql
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

	----SELECT @sql  
	EXEC sp_executesql @sql, N'@RowCount INT', @RowCount      
     
	---Reset variables      
	SET @FieldList = ''      
	SET @JoinList = ''      
	SET @ConditionList = ''      
    SET @RankingList = ''   
	SET @BusinessRuleIDList = '' 
	      
	---Increment Counter      
	SET @Counter = @Counter + 1      
END      
  
  
--------------------------------------------------------      
-- Apply NCOA (where applicable)      
--------------------------------------------------------      
      
DECLARE @ncoaElementsList TABLE (      
UID INT IDENTITY(1,1) PRIMARY KEY      
, ElementID Int      
, Element VARCHAR(50)      
, ElementFieldList nvarchar(max)      
, ElementUpdateStatement nvarchar(max)      
, ElementIsCleanField varchar(100)      
)      
      
-- Check to see if NCOA has been turned on at the client level      
SET @SQL = ''      
+ 'SELECT @applyNCOAClientLevel = CASE WHEN COUNT(0) > 0 THEN 1 ELSE 0 END' + CHAR(13)      
+ 'FROM ' + @ClientDB + 'mdm.BusinessRules' + CHAR(13)      
+ 'WHERE RuleType = ''NCOA Activation''' + CHAR(13)      
+ 'AND isnull(IsDeleted,0) = 0'      
      
EXEC sp_executesql @SQL, N'@applyNCOAClientLevel BIT OUTPUT', @applyNCOAClientLevel OUTPUT      
      
----SELECT @applyNCOAClientLevel      
      
IF @applyNCOAClientLevel = 1      
BEGIN      
	SET @ElementsSQL = ' '       
	+' SELECT ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField FROM ' + @ClientDB + 'mdm.element ' + CHAR(13)      
	+ 'WHERE 1=1 AND ElementType in (''NCOA'') AND isnull(isdeleted, 0) = 0;' + CHAR(13)      
      
	----SELECT @ElementsSQL      
      
	INSERT INTO @ncoaElementsList (ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField)      
	EXEC sp_executesql @ElementsSQL      
      
	SET @ElementLoop = (SELECT MAX(UID) FROM @ncoaElementsList)      
	SET @Counter = 1      
      
	----SELECT @ElementLoop, * FROM @ncoaElementsList      
      
	WHILE @ElementLoop >= @Counter      
	BEGIN      
		SET @ElementID = (SELECT CAST(ElementID AS VARCHAR) FROM @ncoaElementsList WHERE UID = @Counter)      
		SET @Element = (SELECT Element FROM @ncoaElementsList WHERE UID = @Counter)      
		SET @ElementFieldList = (SELECT ElementFieldList FROM @ncoaElementsList WHERE UID = @Counter)      
		SET @ElementIsCleanField = (SELECT ElementIsCleanField FROM @ncoaElementsList WHERE UID = @Counter)      
		SET @ElementUpdateStatement = (SELECT ElementUpdateStatement FROM @ncoaElementsList WHERE UID = @Counter)      
		SET @TableSuffix = REPLACE(@Element, ' ', '')      
      
		SET @sql = ' ' + CHAR(13)      
		+ ' SELECT cdio.SourceContactId as SSID, cdio.Input_SourceSystem as SourceSystem, ' + CHAR(13)      
		+  @ElementFieldList + CHAR(13)      
		+ ' into #tmp_NCOA_'+ @TableSuffix + CHAR(13)      
		+ 'FROM ' + @ClientDB + 'mdm.tmp_CleanDataOutput cdio ' + CHAR(13)      
		+ 'WHERE 1=1' + CHAR(13)      
		+ 'AND Input_AddressType = ''address'' + REPLACE(''' + @TableSuffix + ''',''Address'','''')' + CHAR(13)      
      
		SET @sql = @sql + ' CREATE CLUSTERED INDEX ix_tmp_NCOA ON #tmp_NCOA_'+ @TableSuffix + '(SSID, SourceSystem)' + CHAR(13) + CHAR(13) + CHAR(13)      
      
		---Update CD_DimCustomer with NCOA      
		SET @sql = @sql      
			+ 'Update ' + @ClientDB + 'dbo.CD_DimCustomer ' + CHAR(13)      
			+ ' SET '      
			+ @ElementUpdateStatement + CHAR(13)      
			+ ', [UpdatedDate] = current_timestamp ' + CHAR(13)      
			+ ' from #tmp_NCOA_'+ @TableSuffix + ' data ' + CHAR(13)      
			+ ' inner join  ' + @clientdb + 'dbo.CD_DimCustomer mdm on data.ssid = mdm.ssid' + CHAR(13)      
			+ '		and data.sourcesystem = mdm.sourcesystem' + CHAR(13)      
			+ ' where 1=1' + CHAR(13)      
			+ ' and (replace(isnull(mdm.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ElementUpdateStatement, CHAR(9),''), CHAR(13),''), CHAR(10),''), ' ',''),',',',''''), '' '', '''') or replace(isnull(mdm.'),'=',',''''), '' '', '''') != replace(isnull(') + ',''''), '' '', '''')' + ')' + CHAR(13)      
			+ '' + CHAR(13)      
      
		---Write Log Entry      
		SET @sql = @sql      
			+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
			+ 'values (current_timestamp, ''create master record'', ''apply ncoa to CD_DimCustomer - '+ @Element + ''', @@ROWCOUNT);'       
		SET @sql = @sql + CHAR(13) + CHAR(13)      
      
		--- Get Criteria for Element      
		SET @SQL2 = ' '      
		+' SELECT' + CHAR(13)      
		+ '@applyNCOAElementLevel = 1'      
		+ ', @FieldList = COALESCE(@FieldList + '' '', '''') + c.CriteriaField + '',''' + CHAR(13)      
		+' , @JoinList = COALESCE(@JoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)      
		+' , @ConditionList = COALESCE(@ConditionList + '' '', '''') + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + c.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, '''') ' + CHAR(13)      
		+' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)      
		+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)      
		+' ON a.elementid = b.elementid ' + CHAR(13)      
		+' LEFT JOIN ' + @clientDb + 'mdm.criteria c ' + CHAR(13)      
		+' ON a.criteriaID = c.criteriaID ' + CHAR(13)      
		+' Where a.elementID = ' + @ElementID + CHAR(13)      
		+' AND a.RuleType = ''NCOA''' + CHAR(13)       
		+' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)     
		+' ORDER BY a.priority' + CHAR(13)      
		+ '' + CHAR(13)      
      
		+ 'EXEC mdm.transformCriteriaConditionList @ConditionList, ''' + @ClientDB + ''', @ConditionList OUTPUT'      
      
		EXEC sp_executesql @SQL2      
				, N'@FieldList nvarchar(max) OUTPUT, @JoinList nvarchar(max) OUTPUT, @ConditionList nvarchar(max) OUTPUT, @applyNCOAElementLevel BIT OUTPUT'      
			   , @FieldList OUTPUT      
			   , @JoinList OUTPUT      
			   , @ConditionList OUTPUT      
			   , @applyNCOAElementLevel OUTPUT      
      
		----SELECT @applyNCOAElementLevel, @FieldList, @JoinList, @ConditionList      
      
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------      
		-- Drop/exclude records covered by overrides or "DimCustomer Source" business rules (Default and/or Standard Address), ignoring NCOA - these records need to retain source or override data for the master      
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------      
		SET @sql = @sql + CHAR(13)      
			+ 'DELETE data ' + CHAR(13)      
			+ 'FROM #tmp_NCOA_'+ @TableSuffix + ' data' + CHAR(13)      
			+ 'INNER JOIN ' + @ClientDB + 'mdm.tmp_Master_DimCustomer dimcust ON data.SSID = dimcust.SSID' + CHAR(13)      
			+ '	AND data.SourceSystem = dimcust.SourceSystem' + CHAR(13)      
			+ 'INNER JOIN (' + CHAR(13)      
			+ ' SELECT DISTINCT b.*' + CHAR(13)      
			+ ' FROM ' + @ClientDB + 'mdm.Element a' + CHAR(13)      
			+ ' INNER JOIN ' + @ClientDB + 'mdm.Element b ON a.Element = b.Element' + CHAR(13)      
			+ ' 	AND a.ElementType != b.ElementType ' + CHAR(13)      
			+ ' WHERE 1=1' + CHAR(13)      
			+ ' AND a.ElementType = ''NCOA''' + CHAR(13)       
			+ '	UNION ' + CHAR(13)      
			+ '	SELECT b.*' + CHAR(13)      
			+ '	FROM ' + @ClientDB + 'mdm.BusinessRules a' + CHAR(13)      
			+ '	INNER JOIN ' + @ClientDB + 'mdm.Element b ON a.ElementID = b.ElementID' + CHAR(13)      
			+ '	WHERE 1=1' + CHAR(13)      
			+ '	AND a.RuleType = ''DimCustomer Source''' + CHAR(13)      
			+ '	AND b.ElementType = ''Default''' + CHAR(13)      
			+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)     
			+ ') rules ON dimcust.ElementIDs LIKE ''%'' + CAST(rules.ElementID AS VARCHAR(5)) + ''%''' + CHAR(13)      
			+ 'WHERE 1=1' + CHAR(13)      
			+ 'AND (dimcust.source_applied = 1' + CHAR(13)    
			+ '		OR dimcust.override_applied = 1)' + CHAR(13) + CHAR(13)    
      
		IF (ISNULL(@JoinList,'') != '' OR ISNULL(@ConditionList,'') != '' OR @applyNCOAElementLevel = 1)      
		BEGIN      
			-- Update mdm.tmp_Master_DimCustomer with NCOA      
			SET @sql = @sql + CHAR(13)      
				+ 'Update ' + @ClientDB + 'mdm.tmp_Master_DimCustomer ' + CHAR(13)      
				+ ' SET '      
				+ @ElementUpdateStatement + CHAR(13)      
				+ ', [UpdatedDate] = current_timestamp ' + CHAR(13)      
				+ ', ncoa_applied = 1' + CHAR(13)      
				+ ' from #tmp_NCOA_'+ @TableSuffix + ' data ' + CHAR(13)      
				+ ' inner join  ' + @clientdb + 'mdm.tmp_Master_DimCustomer dimcust on data.ssid = dimcust.ssid' + CHAR(13)      
				+ '		and data.sourcesystem = dimcust.sourcesystem' + CHAR(13)      
				+ ' inner join  ' + @clientdb + 'dbo.DimCustomer dimc on dimcust.ssid = dimc.ssid' + CHAR(13)      
				+ '		and dimcust.sourcesystem = dimc.sourcesystem' + CHAR(13)      
      
			IF (ISNULL(@JoinList,'') != '')      
				SET @SQL = @SQL + @JoinList + CHAR(13)      
			      
			SET @SQL = @SQL	+ ' where 1=1' + CHAR(13)      
      
			IF ISNULL(@ConditionList,'') != ''      
			BEGIN      
				SET @SQL = @SQL      
					+ ' AND (' + CHAR(13)      
					+ @ConditionList + CHAR(13)      
					+ ')' +  CHAR(13)      
			END      
      
			IF @JoinList LIKE '%mdm.SourceSystemPriority%'       
			BEGIN      
				SET @sql = @sql + 'and  isnull(elementid, ' + @elementID  + ') =  case when (select count(0) from ' + @clientdb + 'mdm.sourcesystempriority where elementid = ' + @elementID  + ') > 0       
					then ' + @elementID  + ' else  (select elementid from ' + @clientdb + 'mdm.element where element = ''' + @Element +  ''') end;'      
			END	      
      
			SET @SQL = @SQL      
				--+ ' and dimcust.source_applied = 0' + CHAR(13)      
				+ ' and (replace(isnull(dimcust.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ElementUpdateStatement, CHAR(9),''), CHAR(13),''), CHAR(10),''), ' ',''),',',',''''), '' '', '''') or replace(isnull(dimcust.'),'=',',''''), '' '', '''') != replace(isnull(') + ',''''), '' '', '''')' + CHAR(13)      
				+ '  or replace(isnull(dimc.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ElementUpdateStatement, CHAR(9),''), CHAR(13),''), CHAR(10),''), ' ',''),',',',''''), '' '', '''') or replace(isnull(dimc.'),'=',',''''), '' '', '''') != replace(isnull(') + ',''''), '' '', '''')' + ')' + CHAR(13)      
				+ '' + CHAR(13)      
				      
			---Write Log Entry      
			SET @sql = @sql      
				+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
				+ 'values (current_timestamp, ''create master record'', ''apply ncoa to tmp_Master_DimCustomer - '+ @Element + ''', @@ROWCOUNT);'       
			SET @sql = @sql + CHAR(13) + CHAR(13)      
		END      
      
		SET @SQL = @SQL      
		+ 'drop table #tmp_NCOA_'+ @TableSuffix      
		SET @sql = @sql + CHAR(13) + CHAR(13)      
      

 	-- Add TRY/CATCH block to force stoppage and log error      
	SET @sql = ''     
		+ ' BEGIN TRY' + CHAR(13)      
		+ @sql
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
      
		---Reset variables      
		SET @applyNCOAElementLevel = 0      
		SET @FieldList = ''      
		SET @JoinList = ''      
		SET @ConditionList = ''      
      
		---Increment Counter      
		SET @Counter = @Counter + 1      
      
	END      
END   
  
  
      
      
SET @sql = ''      
+ 'IF (SELECT COUNT(0) FROM ' + @clientdb + 'mdm.tmp_Master_DimCustomer where source_applied = 1 or override_applied = 1 or ncoa_applied = 1) > 10000' + CHAR(13)      
	+ 'BEGIN' + CHAR(13)      
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''dbo.DimCustomer''' + CHAR(13)      
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ 'values (current_timestamp, ''create master record'', ''Disable Indexes - DimCustomer'', ''0'');'       
	+ 'END' + CHAR(13)      
SET @sql = @sql + CHAR(13) + CHAR(13)      
      
SET @sql = @sql      
	+ 'UPDATE b' + CHAR(13)      
	+ 'SET ' + CHAR(13)      
	+ '	b.CompanyName = a.CompanyName' + CHAR(13)      
	+ '	,b.Gender = a.Gender' + CHAR(13)      
	+ '	,b.Prefix = a.Prefix' + CHAR(13)      
	+ '	,b.FirstName = a.FirstName' + CHAR(13)      
	+ '	,b.MiddleName = a.MiddleName' + CHAR(13)      
	+ '	,b.LastName = a.LastName' + CHAR(13)      
	+ '	,b.Suffix = a.Suffix' + CHAR(13)      
	+ '	,b.FullName = a.FullName' + CHAR(13)      
	+ '	,b.AddressPrimaryStreet = a.AddressPrimaryStreet' + CHAR(13)      
	+ '	,b.AddressPrimaryCity = a.AddressPrimaryCity' + CHAR(13)      
	+ '	,b.AddressPrimaryState = a.AddressPrimaryState' + CHAR(13)      
	+ '	,b.AddressPrimaryZip = a.AddressPrimaryZip' + CHAR(13)      
	+ '	,b.AddressPrimaryCounty = a.AddressPrimaryCounty' + CHAR(13)      
	+ '	,b.AddressPrimaryCountry = a.AddressPrimaryCountry' + CHAR(13)      
	+ '	,b.AddressOneStreet = a.AddressOneStreet' + CHAR(13)      
	+ '	,b.AddressOneCity = a.AddressOneCity' + CHAR(13)      
	+ '	,b.AddressOneState = a.AddressOneState' + CHAR(13)      
	+ '	,b.AddressOneZip = a.AddressOneZip' + CHAR(13)      
	+ '	,b.AddressOneCounty = a.AddressOneCounty' + CHAR(13)      
	+ '	,b.AddressOneCountry = a.AddressOneCountry' + CHAR(13)      
	+ '	,b.AddressTwoStreet = a.AddressTwoStreet' + CHAR(13)      
	+ '	,b.AddressTwoCity = a.AddressTwoCity' + CHAR(13)      
	+ '	,b.AddressTwoState = a.AddressTwoState' + CHAR(13)      
	+ '	,b.AddressTwoZip = a.AddressTwoZip' + CHAR(13)      
	+ '	,b.AddressTwoCounty = a.AddressTwoCounty' + CHAR(13)      
	+ '	,b.AddressTwoCountry = a.AddressTwoCountry' + CHAR(13)      
	+ '	,b.AddressThreeStreet = a.AddressThreeStreet' + CHAR(13)      
	+ '	,b.AddressThreeCity = a.AddressThreeCity' + CHAR(13)      
	+ '	,b.AddressThreeState = a.AddressThreeState' + CHAR(13)      
	+ '	,b.AddressThreeZip = a.AddressThreeZip' + CHAR(13)      
	+ '	,b.AddressThreeCounty = a.AddressThreeCounty' + CHAR(13)      
	+ '	,b.AddressThreeCountry = a.AddressThreeCountry' + CHAR(13)      
	+ '	,b.AddressFourStreet = a.AddressFourStreet' + CHAR(13)      
	+ '	,b.AddressFourCity = a.AddressFourCity' + CHAR(13)      
	+ '	,b.AddressFourState = a.AddressFourState' + CHAR(13)      
	+ '	,b.AddressFourZip = a.AddressFourZip' + CHAR(13)      
	+ '	,b.AddressFourCounty = a.AddressFourCounty' + CHAR(13)      
	+ '	,b.AddressFourCountry = a.AddressFourCountry' + CHAR(13)      
	+ '	,b.PhonePrimary = a.PhonePrimary' + CHAR(13)      
	+ '	,b.PhoneHome = a.PhoneHome' + CHAR(13)      
	+ '	,b.PhoneCell = a.PhoneCell' + CHAR(13)      
	+ '	,b.PhoneBusiness = a.PhoneBusiness' + CHAR(13)      
	+ '	,b.PhoneFax = a.PhoneFax' + CHAR(13)      
	+ '	,b.PhoneOther = a.PhoneOther' + CHAR(13)      
	+ '	,b.EmailPrimary = a.EmailPrimary' + CHAR(13)      
	+ '	,b.EmailOne = a.EmailOne' + CHAR(13)      
	+ '	,b.EmailTwo = a.EmailTwo' + CHAR(13)      
	+ '	,b.AddressPrimarySuite = a.AddressPrimarySuite' + CHAR(13)      
	+ '	,b.AddressOneSuite = a.AddressOneSuite' + CHAR(13)      
	+ '	,b.AddressTwoSuite = a.AddressTwoSuite' + CHAR(13)      
	+ '	,b.AddressThreeSuite = a.AddressThreeSuite' + CHAR(13)      
	+ '	,b.AddressFourSuite = a.AddressFourSuite' + CHAR(13)      
	+ '	,b.AddressPrimaryPlus4 = a.AddressPrimaryPlus4' + CHAR(13)      
	+ '	,b.AddressOnePlus4 = a.AddressOnePlus4' + CHAR(13)      
	+ '	,b.AddressTwoPlus4 = a.AddressTwoPlus4' + CHAR(13)      
	+ '	,b.AddressThreePlus4 = a.AddressThreePlus4' + CHAR(13)      
	+ '	,b.AddressFourPlus4 = a.AddressFourPlus4' + CHAR(13)      
	+ '	,b.AddressPrimaryLatitude = a.AddressPrimaryLatitude' + CHAR(13)      
	+ '	,b.AddressPrimaryLongitude = a.AddressPrimaryLongitude' + CHAR(13)      
	+ '	,b.AddressOneLatitude = a.AddressOneLatitude' + CHAR(13)      
	+ '	,b.AddressOneLongitude = a.AddressOneLongitude' + CHAR(13)      
	+ '	,b.AddressTwoLatitude = a.AddressTwoLatitude' + CHAR(13)      
	+ '	,b.AddressTwoLongitude = a.AddressTwoLongitude' + CHAR(13)      
	+ '	,b.AddressThreeLatitude = a.AddressThreeLatitude' + CHAR(13)      
	+ '	,b.AddressThreeLongitude = a.AddressThreeLongitude' + CHAR(13)      
	+ '	,b.AddressFourLatitude = a.AddressFourLatitude' + CHAR(13)      
	+ '	,b.AddressFourLongitude = a.AddressFourLongitude' + CHAR(13)      
      
	+ ' ,b.AddressPrimaryIsCleanStatus = a.AddressPrimaryIsCleanStatus' + CHAR(13)      
	+ ' ,b.AddressOneIsCleanStatus = a.AddressOneIsCleanStatus' + CHAR(13)      
	+ ' ,b.AddressTwoIsCleanStatus = a.AddressTwoIsCleanStatus' + CHAR(13)      
	+ ' ,b.AddressThreeIsCleanStatus = a.AddressThreeIsCleanStatus' + CHAR(13)      
	+ ' ,b.AddressFourIsCleanStatus = a.AddressFourIsCleanStatus' + CHAR(13)      
      
	+ '	,b.UpdatedDate = a.UpdatedDate' + CHAR(13)      
	+ '--SELECT *' + CHAR(13)      
	+ 'FROM ' + @ClientDB + 'mdm.tmp_Master_DimCustomer a ' + CHAR(13)      
	+ 'INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)      
	+ '	AND a.SourceSystem = b.SourceSystem' + CHAR(13)      
	+ 'WHERE 1=1' + CHAR(13)      
	+ 'AND (a.source_applied = 1' + CHAR(13)     
	+ ' OR a.override_applied = 1' + CHAR(13)  
	+ ' OR a.ncoa_applied = 1)' + CHAR(13)   
SET @sql = @sql + CHAR(13) + CHAR(13)      
      
---Write Log Entry      
SET @sql = @sql      
	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ 'values (current_timestamp, ''create master record'', ''Update DimCustomer from tmp_Master_DimCustomer'', @@ROWCOUNT);'       
SET @sql = @sql + CHAR(13) + CHAR(13)      
      
SET @sql = @SQL      
	+ 'IF (SELECT COUNT(0) FROM ' + @clientdb + 'mdm.tmp_Master_DimCustomer where source_applied = 1 or override_applied = 1 or ncoa_applied = 1) > 10000' + CHAR(13)      
	+ 'BEGIN' + CHAR(13)      
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 1, ''dbo.DimCustomer''' + CHAR(13)      
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ 'values (current_timestamp, ''create master record'', ''Re-Enable Indexes - DimCustomer'', ''0'');'       
	+ 'END' + CHAR(13)      
SET @sql = @sql + CHAR(13) + CHAR(13)      
      
-- Add TRY/CATCH block to force stoppage and log error      
SET @sql = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+ @sql
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

----SELECT @sql      
      
EXEC sp_executesql @sql      
      
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql      

END
GO
