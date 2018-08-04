SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
     
     
CREATE PROCEDURE [mdm].[CreateCompositeRecord_CompleteRecord]      
(     
	@ClientDB VARCHAR(50),   
	@ExecutionMode INT = 0 -- 0 = composite record AND composite attribute | 1 = composite record only | 2 = composite attribute only   
)     
AS     
BEGIN     
     
     
/*[mdm].[CreateCompositeRecord]      
* created: 12/22/2014 - Kwyss - creates a composite (or "golden") record from all the account records for a contact     
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL     
*     
*     
*/     
---DECLARE @clientdb VARCHAR(50) = 'CAL', @ExecutionMode INT = 0
     
IF (SELECT @@VERSION) LIKE '%Azure%'     
BEGIN     
SET @ClientDB = ''     
END     
     
IF (SELECT @@VERSION) NOT LIKE '%Azure%'     
BEGIN     
SET @ClientDB = @ClientDB + '.'     
END     
   
IF @ExecutionMode IS NULL   
	SET @ExecutionMode = 0   
     
  
    
DECLARE   
	@DefaultSQL NVARCHAR(MAX) = ' '  
	,@DefaultFieldList nVARCHAR(MAX) = ''  
	,@DefaultJoinList nVARCHAR(MAX)  = ''  
	,@DefaultConditionList NVARCHAR(MAX) = ''  
	,@DefaultRankingList nVARCHAR(MAX) = ''  
	,@DefaultBusinessRuleIDList NVARCHAR(MAX) = ''  
  
DECLARE   
	@FieldList nVARCHAR(MAX) = ''  
	,@JoinList nVARCHAR(MAX)  = ''  
	,@ConditionList NVARCHAR(MAX) = ''  
	,@RankingList nVARCHAR(MAX) = ''  
	,@BusinessRuleIDList NVARCHAR(MAX) = ''  
  
DECLARE @GetPreSQL NVARCHAR(MAX) = '';     
DECLARE @PreSQLQuery NVARCHAR(MAX) = '';     
DECLARE @sql NVARCHAR(MAX) = '', @sql_tmp1 NVARCHAR(MAX) = '', @sql_tmp2 NVARCHAR(MAX) = '', @sql_apply_source NVARCHAR(MAX) = '', @sql_apply_overrides NVARCHAR(MAX) = '', @sql_final NVARCHAR(MAX) = ''  
	, @elemCounter INT = 1, @fieldCounter INT = 1, @Element VARCHAR(50), @ElementID INT, @Field VARCHAR(50), @Counter INT, @Counter2 INT  
  

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''

--- Get all criteria pre-sql and run it once.     
     
SET @GetPreSQl = @GetPreSQL     
+' SELECT  @PreSQLQuery = COALESCE(@PreSQLQuery + '' '', '''') + c.PreSQL ' + CHAR(13)     
+' FROM  ' + @clientDb + 'mdm.criteria c ' + CHAR(13)     
+' where c.criteriaID in (select distinct criteriaid from ' + CHAR(13)    
+ @clientDb + 'mdm.BusinessRules where RuleType IN (''Composite'',''Composite Source'')) and isnull(presql, '''') != ''''' + CHAR(13)     
     
EXEC sp_executesql @GetPreSQL     
        , N'@PreSQLQuery nvarchar(max) OUTPUT'     
       ,  @PreSQLQuery OUTPUT     
    
IF ISNULL(@PreSQLQuery,'') = ''
	SET @PreSQLQuery = 'RETURN'
		 
---select @PreSQLQuery     
     
-- Add TRY/CATCH block to force stoppage and log error      
SET @PreSQLQuery = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+ @PreSQLQuery
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

EXEC sp_executesql @PreSQLQuery     
  
  
DECLARE @ElementsSQL NVARCHAR(max);     
     
DECLARE @ElementsList TABLE (     
UID INT PRIMARY KEY     
, ElementID Int NULL    
, Element VARCHAR(50)     
, ElementFieldList nvarchar(max)     
, ElementUpdateStatement nvarchar(max)     
, ElementIsCleanField varchar(100)   
, IsAttribute BIT   
)     
     
     
     
SET @ElementsSQL = ''   
+ ' SELECT TOP 1 COALESCE(ElementID, NULL) AS UID, COALESCE(ElementID, NULL) AS ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField, 0 AS IsAttribute' + CHAR(13)   
+ ' INTO #element' + CHAR(13)   
+ ' FROM ' + @ClientDB + 'mdm.element' + CHAR(13) + CHAR(13)   
   
+ ' TRUNCATE TABLE #element' + CHAR(13) + CHAR(13)   
      
IF @ExecutionMode IN (0,1)   
BEGIN   
	SET @ElementsSQL = @ElementsSQL   
		+ ' INSERT INTO #element' + CHAR(13)   
		+ ' SELECT ROW_NUMBER() OVER (ORDER BY ElementID) as UID, COALESCE(ElementID, NULL) as ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField, 0 AS IsAttribute' + CHAR(13)   
		+ ' FROM ' + @ClientDB + 'mdm.element' + CHAR(13)   
		+ ' WHERE ElementType in (''Standard'') AND isnull(isdeleted, 0) = 0;' + CHAR(13) + CHAR(13)   
END   
   
IF @ExecutionMode IN (0,2)   
BEGIN   
	SET @ElementsSQL = @ElementsSQL   
		+ ' INSERT INTO #element (UID, ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField, IsAttribute)' + CHAR(13)   
		+ ' SELECT ROW_NUMBER() OVER (ORDER BY b.AttributeID) + ISNULL((SELECT MAX(UID) FROM #element),0) AS UID, c.ElementID, b.Attribute, c.ElementFieldList, c.ElementUpdateStatement, c.ElementIsCleanField, 1 AS IsAttribute' + CHAR(13)   
		+ ' FROM ' + @ClientDB + 'mdm.AttributeGroup a WITH (NOLOCK)' + CHAR(13)   
		+ ' INNER JOIN ' + @ClientDB + 'mdm.Attributes b WITH (NOLOCK) ON a.AttributeGroupID = b.AttributeGroupID' + CHAR(13)   
		+ ' LEFT JOIN ' + @ClientDB + 'mdm.Element c WITH (NOLOCK) ON b.Attribute = c.Element' + CHAR(13)   
		+ '		AND c.ElementType IN (''Attribute'') AND ISNULL(c.IsDeleted,0) = 0' + CHAR(13) + CHAR(13)   
		+ ' WHERE 1=1' + CHAR(13)   
END    
   
SET @ElementsSQL = @ElementsSQL   
	+ ' SELECT * FROM #element' + CHAR(13)   
   
----SELECT @ElementsSQL   
INSERT INTO @ElementsList (UID, ElementID, Element, ElementFieldList, ElementUpdateStatement, ElementIsCleanField, IsAttribute)     
EXEC sp_executesql @ElementsSQL     
           
----SELECT * FROM @ElementsList   
  
  
  
SET @Counter = 1  
WHILE (ISNULL(@DefaultFieldList,'') = '' AND @Counter <= 2)  
BEGIN  
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
		+ ' AND a.RuleType = ''' + CASE WHEN @Counter = 1 THEN 'Composite Source' ELSE 'DimCustomer Source' END + '''' + CHAR(13)      
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
      
	----SELECT @defaultsql, @DefaultFieldList, @DefaultJoinList, @DefaultConditionList, @DefaultRankingList  
  
	SET @Counter = @Counter + 1  
END  
  
DECLARE @ElementLoop INT  
DECLARE @ElementFieldList nVARCHAR(MAX), @ElementUpdateStatement NVARCHAR(MAX), @ElementIsCleanField VARCHAR(100)  
  
SET @ElementLoop = (SELECT MAX(UID) FROM @ElementsList WHERE IsAttribute = 0)     
SET @Counter = 1     
  
WHILE @ElementLoop >= @Counter     
BEGIN     
	SELECT    
		@ElementID = ElementID   
		,@Element = Element   
		,@ElementFieldList = ElementFieldList   
		,@ElementUpdateStatement = ElementUpdateStatement   
		,@ElementIsCleanField = ElementIsCleanField   
	FROM @ElementsList   
	WHERE UID = @Counter   
  
	SET @Counter2 = 1  
	WHILE (ISNULL(@DefaultFieldList,'') = '' AND @Counter2 <= 2)  
	BEGIN  
		SET @FieldList = '' 
		SET @JoinList = '' 
		SET @ConditionList = '' 
		SET @RankingList = '' 
		SET @BusinessRuleIDList = '' 
		SET @sql_tmp1 = '' 
 
		SET @sql_tmp1 = @sql_tmp1         
			+ ' SELECT @FieldList = COALESCE(@FieldList + '' '', '''') + c.CriteriaField + '' as ['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + '']''' + CHAR(13)      
			+ ' , @JoinList = COALESCE(@JoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)      
			+ ' , @ConditionList = LTRIM(RTRIM(COALESCE(@ConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + c.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, '''')))' + CHAR(13)      
			+ ' , @RankingList = COALESCE(@RankingList + '' '', '''') + ''['' + c.criteria + ''_'' + CAST(a.BusinessRuleID AS VARCHAR(5)) + ''] '' + Isnull(c.CriteriaOrder, ''ASC'') + '',''' + CHAR(13)   
			+ ' , @BusinessRuleIDList = COALESCE(@BusinessRuleIDList + '' '', '''') + CAST(a.BusinessRuleID AS VARCHAR(5)) + '',''' + CHAR(13)  
			+ ' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)      
			+ ' INNER JOIN ' + @clientDb + 'mdm.element b ON a.elementid = b.elementid ' + CHAR(13)      
			+ ' INNER JOIN ' + @clientDb + 'mdm.criteria c ON c.criteriaID = a.criteriaID ' + CHAR(13)      
			+ ' WHERE element = ''' + @Element + '''' + CHAR(13)      
			+ ' AND a.RuleType = ''' + CASE WHEN @Counter2 = 1 THEN 'DimCustomer Source' ELSE 'Composite Source' END + '''' + CHAR(13)      
			+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)     
			+ ' ORDER BY a.LogicalOperator, priority' + CHAR(13) + CHAR(13)    
      
			+ 'EXEC mdm.transformCriteriaConditionList @ConditionList, ''' + @ClientDB + ''', @ConditionList OUTPUT'      
      
		EXEC sp_executesql @sql_tmp1      
				, N'@FieldList nvarchar(max) OUTPUT, @JoinList nvarchar(max) OUTPUT, @ConditionList nvarchar(max) OUTPUT, @RankingList nvarchar(max) OUTPUT, @BusinessRuleIDList nvarchar(max) OUTPUT'      
			   , @FieldList OUTPUT      
			   , @JoinList OUTPUT      
			   , @ConditionList OUTPUT      
			   , @RankingList OUTPUT  
			   , @BusinessRuleIDList OUTPUT  
		  
		----SELECT @sql_tmp1, @FieldList, @JoinList, @ConditionList, @RankingList  
  
		SET @Counter2 = @Counter2 + 1  
	END  
      
	---If no element-specific criteria, set to default     
	IF (ISNULL(@DefaultFieldList,'') != '' AND (ISNULL(@FieldList,'') = '' ))     
	BEGIN    
		SET @sql_apply_source = @sql_apply_source  
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
		SET @sql_apply_source = @sql_apply_source  
			+ ' PRINT ''...............' + @Element + ' - Source''' + CHAR(13)  
			+ ' PRINT ''...........................................Using element-specific business rules''' + CHAR(13) + CHAR(13)  
	END  
     
	IF ISNULL(@FieldList,'') != ''  
	BEGIN  
		SET @sql_apply_source = @sql_apply_source  
			+ ' IF OBJECT_ID(''tempdb..#tmp_' + REPLACE(@Element, ' ', '') + ''') IS NOT NULL' + CHAR(13)  
			+ '		DROP TABLE #tmp_' + REPLACE(@Element, ' ', '') + CHAR(13) + CHAR(13)  
  
			+ ' SELECT dimcust.SSB_CRMSYSTEM_CONTACT_ID, dimcust.DimCustomerID, dimcust.SSID, dimcust.SourceSystem' + CHAR(13)  
			+ '		,' + @ElementFieldList + CHAR(13)  
			+ '		,' + @FieldList + CHAR(13)  
			+ ' INTO #tmp_' + REPLACE(@Element, ' ', '') + CHAR(13)  
			+ ' FROM ' + @ClientDB + 'mdm.tmp_composite_source dimcust' + CHAR(13)  
			+ @JoinList + CHAR(13)  
			+ ' WHERE 1=1' + CHAR(13)  
  
		IF ISNULL(@ConditionList,'') != ''      
			SET @sql_apply_source = @sql_apply_source + 'AND (' + CHAR(13) + @ConditionList + CHAR(13) + ')' + CHAR(13)      
  
		IF @Joinlist LIKE '%mdm.SourceSystemPriority%'       
			SET @sql_apply_source = @sql_apply_source + 'and  isnull(elementid, ' + @elementID  + ') =  case when (select count(0) from ' + @clientdb + 'mdm.sourcesystempriority where elementid = ' + @elementID  + ') > 0       
				then ' + @elementID  + ' else  (select elementid from ' + @clientdb + 'mdm.element where element = ''Default'') end' + CHAR(13)       
  
		SET @sql_apply_source = @sql_apply_source + CHAR(13)  
			+ ' IF OBJECT_ID(''tempdb..#tmp_ranking_' + REPLACE(@Element, ' ', '') + '_source'') IS NOT NULL' + CHAR(13)  
			+ '		DROP TABLE #tmp_ranking_' + REPLACE(@Element, ' ', '') + '_source' + CHAR(13) + CHAR(13)  
  
			+ ' SELECT dimcust.*' + CHAR(13)  
			+ '		,ROW_NUMBER() OVER (PARTITION BY dimcust.SSB_CRMSYSTEM_CONTACT_ID ORDER BY CASE WHEN dimcust.DimCustomerId = prmry.DimCustomerId THEN 1 ELSE 0 END DESC, ' + @RankingList + ' dimcust.dimcustomerid desc) AS ranking'  
			+ ' INTO #tmp_ranking_' + REPLACE(@Element, ' ', '') + '_source' + CHAR(13)  
			+ ' FROM #tmp_' + REPLACE(@Element, ' ', '') + ' dimcust' + CHAR(13) 
			+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_composite prmry (NOLOCK) ON dimcust.SSB_CRMSYSTEM_CONTACT_ID = prmry.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) + CHAR(13)
  
			+ ' DROP TABLE #tmp_' + REPLACE(@Element, ' ', '') + CHAR(13) + CHAR(13)  
  
			+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_source_ranking_compositerecord'') IS NULL' + CHAR(13)
			+ '		CREATE TABLE ' + @ClientDB + '[mdm].[tmp_source_ranking_compositerecord](' + CHAR(13)
			+ '			[SSB_CRMSYSTEM_CONTACT_ID] [varchar](50) NULL,' + CHAR(13)
			+ '			[DimCustomerID] [int] NULL,' + CHAR(13)
			+ '			[SSID] [varchar](100) NULL,' + CHAR(13)
			+ '			[SourceSystem] [varchar](50) NULL,' + CHAR(13)
			+ '			[Element] [varchar](50) NULL,' + CHAR(13)
			+ '			[BusinessRuleIDList] [varchar](250) NULL,' + CHAR(13)
			+ '			[rankingLogic] [varchar](max) NULL,' + CHAR(13)
			+ '			[ranking] [int] NULL,' + CHAR(13)
			+ '			[CreatedDate] [datetime] CONSTRAINT [DF_tmp_source_ranking_compositerecord_CreatedDate]  DEFAULT (getdate())' + CHAR(13)
			+ '		)' + CHAR(13) + CHAR(13)

			+ ' DELETE FROM b' + CHAR(13)  
			+ ' FROM #tmp_ranking_'+ REPLACE(@Element, ' ', '') + '_source a' + CHAR(13)  
			+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_source_ranking_compositerecord b ON (a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
			+ '		OR (a.SSID = b.SSID AND a.SourceSystem = b.SourceSystem))' + CHAR(13)  
			+ '		AND b.Element = ''' + @Element + '''' + CHAR(13)  
  
			+ ' INSERT INTO ' + @ClientDB + 'mdm.tmp_source_ranking_compositerecord (SSB_CRMSYSTEM_CONTACT_ID, DimCustomerID, SSID, SourceSystem, Element, BusinessRuleIDList, rankingLogic, ranking)' + CHAR(13)  
			+ ' SELECT a.SSB_CRMSYSTEM_CONTACT_ID, a.DimCustomerID, a.SSID, a.SourceSystem, ''' + @Element + ''' AS Element'  
			+ ' , ''' + @BusinessRuleIDList + ''' AS BusinessRuleIDList, ''ROW_NUMBER() OVER (PARTITION BY dimcust.SSB_CRMSYSTEM_CONTACT_ID ORDER BY CASE WHEN dimcust.DimCustomerId = prmry.DimCustomerId THEN 1 ELSE 0 END DESC, ' + @RankingList + ' dimcust.dimcustomerid desc)'' as rankingLogic, ranking' + CHAR(13)  
			+ ' FROM #tmp_ranking_'+ REPLACE(@Element, ' ', '') + '_source a' + CHAR(13) + CHAR(13)  

		SET @sql_apply_source = @sql_apply_source + CHAR(13)  
			+ ' UPDATE ' + @ClientDB + 'mdm.tmp_composite' + CHAR(13)  
			+ ' SET ' + @ElementUpdateStatement  
			+ ' FROM #tmp_ranking_' + REPLACE(@Element, ' ', '') + '_source data' + CHAR(13)  
			+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_composite dimcust ON data.SSB_CRMSYSTEM_CONTACT_ID = dimcust.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
			+ ' WHERE 1=1' + CHAR(13)  
			+ ' AND data.ranking = 1' + CHAR(13)  
			+ ' and (isnull(dimcust.' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ElementUpdateStatement, CHAR(9),''), CHAR(13),''), CHAR(10),''), ' ',''),',',','''') or isnull(dimcust.'),'=',','''') != isnull(') + ','''')' + ')' + CHAR(13) + CHAR(13)   
	      
			+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
			+ ' values (current_timestamp, ''create composite record'', ''apply source - ' + @Element + ''', @@ROWCOUNT);' + CHAR(13) + CHAR(13)   
  
			+ '	DROP TABLE #tmp_ranking_' + REPLACE(@Element, ' ', '') + '_source' + CHAR(13) + CHAR(13)  
	END  
	  
	SET @Counter = @Counter + 1  
  
	-- Reset variables 
	SET @sql_tmp1 = '' 
	SET @FieldList = ''  
	SET @JoinList = ''  
	SET @ConditionList = ''  
	SET @RankingList = ''  
	SET @BusinessRuleIDList = '' 
END  
  
SET @sql_apply_source = ''  
	+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_composite_source'') IS NOT NULL' + CHAR(13)  
	+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_composite_source' + CHAR(13) + CHAR(13)  
  
	+ ' SELECT b.SSB_CRMSYSTEM_CONTACT_ID, c.*' + CHAR(13)  
	+ ' INTO ' + @ClientDB + 'mdm.tmp_composite_source' + CHAR(13)  
	+ ' FROM ' + @ClientDB + 'mdm.tmp_composite a' + CHAR(13)  
	+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
	+ ' INNER JOIN ' + @ClientDB + 'dbo.vw_Source_DimCustomer c WITH (NOLOCK) ON b.DimCustomerId = c.DimCustomerId' + CHAR(13) + CHAR(13)  
  
	+ @sql_apply_source  
     
----SELECT @sql_apply_source  
  
IF OBJECT_ID('tempdb..#elemFields') IS NOT NULL  
	DROP TABLE #elemFields  
  
CREATE TABLE #elemFields (ID INT, Element VARCHAR(50), ElementID INT, FieldID INT, Field VARCHAR(50))  
  
DECLARE @masterCompositeID TABLE (ID INT)  
  
SET @sql_apply_overrides = ''  
	+ ' ;WITH elemFields AS (' + CHAR(13)  
	+ ' 	SELECT DISTINCT Element, ElementID, Field' + CHAR(13)  
	+ ' 	FROM ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord' + CHAR(13)  
	+ ' )' + CHAR(13)  
	+ ' INSERT INTO #elemfields' + CHAR(13)  
	+ ' SELECT DENSE_RANK() OVER (ORDER BY a.Element) AS ID, a.Element, a.ElementID, ROW_NUMBER() OVER (PARTITION BY a.ElementID ORDER BY a.Field) AS FieldID, a.Field' + CHAR(13)  
	+ ' FROM elemFields a' + CHAR(13)  
  
EXEC sp_executesql @sql_apply_overrides  
  
--SELECT * FROM #elemfields  
  
SET @sql_apply_overrides = ''  
SET @sql_tmp1 = ''  
SET @Counter = 1  
  
WHILE @elemCounter <= (SELECT MAX(ID) FROM #elemFields)  
BEGIN  
	SET @sql_tmp1 = ''  
	SET @fieldCounter = 1  
  
	WHILE @fieldCounter <= (SELECT MAX(FieldID) FROM #elemFields WHERE ID = @elemCounter)  
	BEGIN  
		SELECT @Element = Element, @ElementID = ElementID, @Field = Field  
		FROM #elemfields  
		WHERE ID = @elemCounter  
		AND FieldID = @fieldCounter  
		  
		SET @sql_tmp1 = @sql_tmp1  
			+ ' DELETE FROM @masterCompositeID' + CHAR(13) + CHAR(13)  
  
			+ ' UPDATE b' + CHAR(13)  
			+ ' SET b.' + @Field + ' = a.Value' + CHAR(13)  
			+ ' OUTPUT a.ID, a.DimCustomerID INTO @masterCompositeID (ID, DimCustomerID)' + CHAR(13)  
			+ ' --SELECT *' + CHAR(13)  
			+ ' FROM ' + @ClientDB + 'mdm.vw_tmp_override_dimcustomer_compositerecord a' + CHAR(13)  
			+ ' INNER JOIN ' + @ClientDB + 'mdm.compositerecord b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)  
			+ ' WHERE 1=1' + CHAR(13)  
			+ ' AND a.override_ranking = 1' + CHAR(13)  
			+ ' AND a.ElementID = ' + CAST(@ElementID AS VARCHAR(5)) + CHAR(13)  
			+ ' AND a.Field = ''' + @Field + '''' + CHAR(13) + CHAR(13)  
  
			+ ' UPDATE b' + CHAR(13)  
			+ ' SET b.AppliedToComposite_TS = GETDATE(), b.UpdatedDate = GETDATE()' + CHAR(13)  
			+ ' FROM @masterCompositeID a' + CHAR(13)  
			+ ' INNER JOIN ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord b ON a.ID = b.ID' + CHAR(13) + CHAR(13)  
  
			+ ' INSERT INTO @updates (DimCustomerID) SELECT DimCustomerID FROM @masterCompositeID' + CHAR(13) + CHAR(13)  
  
			+ ' UPDATE a' + CHAR(13) 			 
			+ ' SET a.AppliedToComposite_TS = NULL, a.UpdatedDate = GETDATE()' + CHAR(13) 			 
			+ ' FROM ' + @ClientDB + 'mdm.tmp_override_dimcustomer_compositerecord a' + CHAR(13) 			 
			+ ' LEFT JOIN  @masterCompositeID b ON a.ID = b.ID' + CHAR(13) 			 
			+ ' WHERE 1=1' + CHAR(13) 			 
			+ ' AND a.ElementID = ' + CAST(@ElementID AS VARCHAR(5)) + CHAR(13) 			 
			+ ' AND a.Field = ''' + @Field + '''' + CHAR(13) 			 
			+ ' AND b.ID IS NULL' + CHAR(13) 			 
			+ ' AND a.AppliedToComposite_TS IS NOT NULL' + CHAR(13) + CHAR(13)  
  
		SET @fieldCounter = @fieldCounter + 1  
	END  
 
	SET @sql_tmp2 = @sql_tmp2 + @sql_tmp1 
		+ ' SELECT @rowCount = COUNT(DISTINCT DimCustomerID) FROM @updates' + CHAR(13) + CHAR(13)  
  
		+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ ' values (current_timestamp, ''create composite record'', ''apply override - ' + @Element + ''', @rowCount);' + CHAR(13) + CHAR(13)   
  
		+ ' SET @rowCount = 0' + CHAR(13)  
		+ ' DELETE FROM @updates' + CHAR(13) + CHAR(13)  
 
	SET @elemCounter = @elemCounter + 1  
END  
 
SET @sql_apply_overrides = ''  
	+ ' DECLARE @rowCount INT = 0' + CHAR(13)  
	+ ' DECLARE @masterCompositeID TABLE (ID INT, DimCustomerID INT)' + CHAR(13)  
	+ ' DECLARE @updates TABLE (DimCustomerID INT)' + CHAR(13)   
	+ @sql_tmp2--@sql_apply_overrides     
  
----SELECT @sql_apply_overrides  
  
SET @sql_tmp2 = '' 
  
      
--- Get Criteria for Default     
SET @DefaultSQL = ''  
SET @DefaultFieldList = ''  
SET @DefaultJoinList = ''  
SET @DefaultConditionList = ''  
SET @DefaultRankingList = ''  
  
SET @DefaultSQL = @DefaultSQL     
     
+' SELECT  @DefaultFieldList = COALESCE(@DefaultFieldList + '', '', '''') + c.CriteriaField + '' as ['' + c.criteria + '']''' + CHAR(13)     
+' , @DefaultJoinList = COALESCE(@DefaultJoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)     
+' ,@DefaultRankingList = COALESCE(@DefaultRankingList + '' '', '''')  + c.criteriaField + '' '' + c.CriteriaOrder + '',''' + CHAR(13)     
+' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)     
+' ON a.elementid = b.elementid ' + CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.criteria c ' + CHAR(13)     
+' ON c.criteriaID = a.criteriaID ' + CHAR(13)     
+' Where element = ''Default''' + CHAR(13)   
+' AND a.RuleType = ''Composite''' + CHAR(13)  
+' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)  
+' ORDER BY priority; ' + CHAR(13)     
     
 --SELECT @DefaultSQL    
EXEC sp_executesql @DefaultSQL     
        , N'@DefaultFieldList nvarchar(max) OUTPUT, @DefaultJoinList nvarchar(max) OUTPUT, @DefaultRankingList nvarchar(max) OUTPUT'     
       , @DefaultFieldList OUTPUT     
       , @DefaultJoinList OUTPUT     
	   , @DefaultRankingLIST OUTPUT     
     
---PRINT @defaultsql     
     
     
     
     
  
   
DECLARE  
	@IsAttribute BIT   
	, @AttributeFieldList NVARCHAR(MAX) = 'attr.DimCustomerAttrValsID, attr.DimCustomerAttrID, attr.AttributeName'   
     
SET @ElementLoop = (SELECT MAX(UID) FROM @ElementsList)     
SET @Counter = 1     
     
     
DECLARE @SQL2 NVARCHAR(MAX) = '';     
DECLARE @Exclusion NVARCHAR(MAX) = '';     
DECLARE @maxStdUID INT = 0;   
DECLARE @maxAttrUID INT = 0;   
   
SELECT @maxStdUID = MAX(UID)   
FROM @ElementsList   
WHERE IsAttribute = 0   
   
SELECT @maxAttrUID = MAX(UID)   
FROM @ElementsList   
WHERE IsAttribute = 1   
   
WHILE @ElementLoop >= @Counter     
BEGIN     
SELECT    
	@ElementID = ElementID   
	,@Element = Element   
	,@ElementFieldList = ElementFieldList   
	,@ElementUpdateStatement = ElementUpdateStatement   
	,@ElementIsCleanField = ElementIsCleanField   
	,@IsAttribute = IsAttribute   
FROM @ElementsList   
WHERE UID = @Counter   
    
--- Get Criteria for Element     
SET @SQL2 = ' '     
+' SELECT @FieldList = COALESCE(@FieldList + '', '', '''') + c.CriteriaField + '' as ['' + c.criteria + '']''' + CHAR(13)     
+' , @JoinList = COALESCE(@JoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)     
+' ,@RankingList = COALESCE(@RankingList + '' '', '''')  + c.criteriaField + '' '' + c.CriteriaOrder + '',''' + CHAR(13)     
+' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)     
+' ON a.elementid = b.elementid ' + CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.criteria c ' + CHAR(13)     
+' ON c.criteriaID = a.criteriaID ' + CHAR(13)     
+' Where element = ''' + @Element + '''' + CHAR(13)     
+' AND a.RuleType = ''Composite''' + CHAR(13)     
+' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)  
+' ORDER BY priority; ' + CHAR(13)     
     
     
+' Select @Exclusion = c.ExclusionSQL '+ CHAR(13)     
+' FROM ' + @ClientDB + 'mdm.CompositeExclusions a '+ CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)     
+' ON a.elementid = b.elementid ' + CHAR(13)     
+' INNER JOIN ' + @clientDb + 'mdm.exclusions c ' + CHAR(13)     
+' ON c.exclusionID = a.exclusionID ' + CHAR(13)     
+' Where element = ''' + @Element + ''''     
     
---Select @SQL2     
     
     
EXEC sp_executesql @SQL2     
        , N'@FieldList nvarchar(max) OUTPUT, @JoinList nvarchar(max) OUTPUT, @Exclusion nvarchar(max) OUTPUT, @RankingList nvarchar(max) OUTPUT'     
       , @FieldList OUTPUT     
       , @JoinList OUTPUT     
	   , @Exclusion OUTPUT     
	   , @RankingList Output     
     
---PRINT @FieldList     
---PRINT @JoinList     
---PRINT @Exclusion     
     
SET @sql = ''  
	+ 'PRINT ''...............' + @Element + '''' + CHAR(13)  
  
---If No Criteria, set to default     
IF (ISNULL(@DefaultFieldList,'') != '' AND (ISNULL(@FieldList,'') = '' OR (@IsAttribute = 1 AND @ElementID IS NULL)))     
BEGIN    
	SET @sql = @sql  
		+ ' PRINT ''..............................Using Default''' + CHAR(13) + CHAR(13)  
		     
SET @FieldList = @DefaultFieldList     
SET @JoinList = @DefaultJoinList     
SET @RankingList = @DefaultRankingLIST     
END      
     
   
--Get Ranking     
     
SET @SQL = @sql     
	+ '---- ' + @Element + CHAR(13)     
	+ 'IF Object_ID(''tempdb..[#tmpInvalid_' + REPLACE(@Element, ' ', '') + ']'') Is NOT NULL '+ CHAR(13)     
	+ ' Drop table [#tmpInvalid_' + REPLACE(@Element, ' ', '') + ']' + CHAR(13) + CHAR(13)   
   
IF @IsAttribute = 0   
BEGIN   
	SET @sql = @sql     
		+ 'SELECT a.SSB_CRMSYSTEM_CONTACT_ID  '+ CHAR(13)     
END	   
ELSE   
BEGIN   
	SET @sql = @sql     
		+ 'SELECT attr.SSB_CRMSYSTEM_CONTACT_ID  '+ CHAR(13)    
END   
    
SET @SQL = @SQL +    
	+ 'INTO [#tmpinvalid_' + REPLACE(@Element, ' ', '')  + ']' + CHAR(13)     
   
IF @IsAttribute = 0   
BEGIN   
	SET @SQL = @SQL   
	+ 'FROM  ' + @ClientDB + 'mdm.tmp_composite a with (NOLOCK)' + CHAR(13)     
END   
ELSE   
BEGIN   
	SELECT @ElementID = ISNULL(@ElementID,-1)   
	SET @ElementFieldList = 'attr.AttributeValue'   
	SET @ElementUpdateStatement = 'DimCustomerAttrValsID = data.DimCustomerAttrValsID, DimCustomerAttrID = data.DimCustomerAttrID, AttributeValue = data.AttributeValue'   
   
	SET @SQL = @SQL   
		+ 'FROM  ' + @ClientDB + 'mdm.tmp_CompositeAttribute attr with (NOLOCK)' + CHAR(13)    
END   
   
SET @SQL = @SQL   
	+ 'WHERE 1=1 ' + CHAR(13)    
	    
IF @ELementIsCleanField != ''     
BEGIN     
    SET @SQL = @SQL     
		+ ' and a.' + @ElementIsCleanField +' not like ''Valid%'' ' + CHAR(13)     
END     
ELSE    
BEGIN      
	SET @SQL = @SQL     
		+ ' and isnull(LTRIM(RTRIM(cast(' + replace(@ElementFieldList, 'dimcust', 'a') + ' as varchar(MAX)))), '''') = '''' ' + CHAR(13)     
END     
   
IF @IsAttribute = 1   
BEGIN   
	SET @SQL = @SQL   
		+ '		AND attr.AttributeName = ''' + @Element + '''' + CHAR(13)   
END   
    
SET @sql = @sql + CHAR(13) + CHAR(13)     
SET @sql = @sql     
	+ ' CREATE INDEX ix_invalid ON [#tmpInvalid_' + REPLACE(@Element, ' ', '') + '](SSB_CRMSYSTEM_CONTACT_ID)'+ CHAR(13) + CHAR(13)    
   
	+ ' IF OBJECT_ID(''tempdb..[#dimcustomerid_' + REPLACE(@Element, ' ', '') + ']'') IS NOT NULL'+ CHAR(13)   
	+ ' 	DROP TABLE [#dimcustomerid_' + REPLACE(@Element, ' ', '') + ']' + CHAR(13) + CHAR(13)   
    
	+ ' SELECT dimcustomerid, b.SSB_CRMSYSTEM_CONTACT_ID'+ CHAR(13)    
	+ ' INTO [#dimcustomerid_' + REPLACE(@Element, ' ', '')  + ']'+ CHAR(13)   
	+ ' FROM  [#tmpInvalid_' + REPLACE(@Element, ' ', '') + '] b  WITH (NOLOCK)'+ CHAR(13)    
	+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid id ON id.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID'+ CHAR(13) + CHAR(13)   
   
	+ ' CREATE NONCLUSTERED INDEX ix_dimcustomerid ON [#dimcustomerid_' + REPLACE(@Element, ' ', '') + '](dimcustomerid)'+ CHAR(13) + CHAR(13)   
   
	+ 'IF Object_ID(''tempdb..[#tmpValid_' + REPLACE(@Element, ' ', '') + ']'') Is NOT NULL '+ CHAR(13)     
	+ ' Drop table [#tmpValid_' + REPLACE(@Element, ' ', '')  + ']' + CHAR(13) + CHAR(13)   
   
	+ 'SELECT dc.SSB_CRMSYSTEM_CONTACT_ID, dimcust.*'   
    
IF @IsAttribute = 1   
BEGIN   
	SET @SQL = @SQL   
		+ ' , attr.*'   
END    
	   
SET @SQL = @SQL + CHAR(13)   
	 + 'INTO [#TmpValid_' + REPLACE(@Element, ' ', '')  + ']'+ CHAR(13)     
	 + 'FROM  ' + @ClientDB + 'dbo.dimcustomer dimcust WITH (NOLOCK) '+ CHAR(13)     
	+ ' inner JOIN [#dimcustomerid_' + REPLACE(@Element, ' ', '') + '] dc '+ CHAR(13)     
	+ ' on dimcust.dimcustomerid = dc.dimcustomerid '+ CHAR(13)     
   
IF @IsAttribute = 1   
BEGIN   
	SET @SQL = @SQL   
		+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributes b WITH (NOLOCK) ON dc.DimCustomerId = b.DimCustomerId' + CHAR(13)   
		+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributeValues attr WITH (NOLOCK) ON b.DimCustomerAttrID = attr.DimCustomerAttrID' + CHAR(13)   
		+ '		AND attr.AttributeName = ''' + @Element + '''' + CHAR(13)   
END   
   
SET @SQL = @SQL   
+ ' WHERE dimcust.isdeleted = 0 '+ CHAR(13)     
IF @ELementIsCleanField != ''     
BEGIN     
	SET @SQL = @SQL     
		+ ' and dimcust.' + @ElementIsCleanField +' like ''Valid%''  ' + CHAR(13)     
END     
ELSE      
BEGIN      
	SET @SQL = @SQL     
		+ ' and isnull(ltrim(rtrim(cast(' + @ElementFieldList + ' as varchar(MAX)))), '''') != '''' ' + CHAR(13)     
END     
     
SET @sql = @sql + CHAR(13) + CHAR(13)     
SET @sql = @sql     
	+ ' IF OBJECT_ID(''tempdb..[#dimcustomerid_' + REPLACE(@Element, ' ', '') + ']'') IS NOT NULL'+ CHAR(13)   
	+ ' 	DROP TABLE [#dimcustomerid_' + REPLACE(@Element, ' ', '')  + ']' + CHAR(13) + CHAR(13)   
  
	+ ' CREATE CLUSTERED INDEX ix_tmpValid ON [#tmpValid_' + REPLACE(@Element, ' ', '') + '](sourcesystem, ssid)  '+ CHAR(13)     
	+ ' CREATE INDEX ix_valid ON [#tmpValid_' + REPLACE(@Element, ' ', '') + '](SSB_CRMSYSTEM_CONTACT_ID) '+ CHAR(13)     
SET @sql = @sql + CHAR(13) + CHAR(13)     
     
   
SET @sql =  @sql +	  'SELECT @elementidssp = 	CASE when (select count(0) from ' + @clientdb + 'mdm.sourcesystempriority where elementid = ' + CAST(@elementID AS VARCHAR(5)) + ') > 0      
	then ' + CAST(@elementID AS VARCHAR(5)) + ' else  (select elementid from ' + @clientdb + 'mdm.element where element = ''Default'') end'   + CHAR(13)    
SET @sql = @sql + CHAR(13) + CHAR(13)     
   
SET @sql = @sql     
	+ 'IF Object_ID(''tempdb..[#tmp_ranking_' + REPLACE(@Element, ' ', '') + ']'') Is NOT NULL '+ CHAR(13)     
	+ ' Drop table [#tmp_ranking_' + REPLACE(@Element, ' ', '')  + ']'+ CHAR(13)     
SET @sql = @sql + CHAR(13) + CHAR(13)     
SET @sql = @sql     
	+ ' SELECT dimcust.SSB_CRMSYSTEM_CONTACT_ID as ssb_crmsystem_contact_id, ' + CHAR(13)     
	+  REPLACE(@ElementFieldList, 'attr.', 'dimcust.')  + CASE WHEN @IsAttribute = 1 THEN + ',' + REPLACE(@AttributeFieldList, 'attr.', 'dimcust.') ELSE '' END     
	+  @FieldList     
	+ ' ,row_number() over (partition by dimcust.ssb_crmsystem_contact_id order by '+ @RankingList + ' dimcust.dimcustomerid desc) as ranking' + CHAR(13)     
	+ ' into [#tmp_ranking_' + REPLACE(@Element, ' ', '')  + ']'+ CHAR(13)     
	+ 'FROM [#tmpValid_' + REPLACE(@Element, ' ', '') + '] dimcust ' + CHAR(13)     
	+ @JoinList     
   
IF @Joinlist LIKE '%mdm.SourceSystemPriority%'      
BEGIN     
	set @sql = @sql + ' where  isnull(elementid,  @elementidssp  ) =   @elementidssp ;'   
   
---SET @SQL = @SQL + 'where isnull(elementid, ' + @elementID  + ') = ' + @elementID      
End     
     SET @sql = @sql + CHAR(13) + CHAR(13)     
		+ 'IF Object_ID(''tempdb..[#tmpValid_' + REPLACE(@Element, ' ', '') + ']'') Is NOT NULL '+ CHAR(13)     
		+ ' Drop table [#tmpValid_' + REPLACE(@Element, ' ', '')  + ']' + CHAR(13) + CHAR(13)   
  
     
	 IF LEN(@Exclusion) > 1     
	 BEGIN     
     SET @SQL = @SQL      
	 + 'IF Object_ID(''tempdb.dbo.#tmp_exclusions'', ''U'') Is NOT NULL '+ CHAR(13)     
	+ ' Drop table #tmp_exclusions;'+ CHAR(13)     
	SET @sql = @sql + CHAR(13) + CHAR(13)     
	     
	SET @sql = @sql     
+ ' SELECT ssb_crmsystem_CONTACT_ID  ' + CHAR(13)     
+ ' INTO #tmp_exclusions ' + CHAR(13)     
+ ' FROM ' + @clientdb + 'mdm.tmp_composite  ' + CHAR(13)     
+ ' WHERE 1=1 AND ' + @Exclusion     
	 END     
     
     
	 SET @sql = @sql + CHAR(13) + CHAR(13)     
---Update Element     
SET @sql = @sql     
	+ 'Update mdm' + CHAR(13)     
	+ ' SET '     
	+ @ElementUpdateStatement     
IF @IsAttribute = 0   
BEGIN   
	SET @SQL = @SQL   
		+ ', [UpdatedBy] = ''CI''' + CHAR(13)     
		+ ', [UpdatedDate] = current_timestamp ' + CHAR(13)   
END   
    
SET @SQL = @SQL   
	+ ' from [#tmp_ranking_' + REPLACE(@Element, ' ', '') + '] data ' + CHAR(13)     
	+ ' inner join  ' + @clientdb + 'mdm.tmp_composite' + CASE WHEN @IsAttribute = 0 THEN '' ELSE 'Attribute' END + ' mdm ' + CHAR(13)     
	+ ' on data.ssb_crmsystem_contact_id = mdm.SSB_CRMSYSTEM_CONTACT_ID ' + CHAR(13)    
   
	IF @IsAttribute = 1   
	BEGIN   
		SET @SQL = @SQL   
			+ ' AND data.AttributeName = mdm.AttributeName' + CHAR(13)   
	END   
					    
	 IF LEN(@Exclusion) > 1     
		BEGIN     
    SET @sql = @sql      
	+ ' LEFT JOIN #tmp_Exclusions excl ' + CHAR(13)     
	+ ' ON mdm.SSB_CRMSYSTEM_CONTACT_ID = excl.ssb_crmSystem_contact_id ' + CHAR(13)     
		END     
		 SET @sql = @sql      
	+ ' where ranking = 1  ' + CHAR(13)     
	     
	IF LEN(@Exclusion) > 1     
	BEGIN     
    SET @sql = @sql      
	+ ' and excl.ssb_crmsystem_contact_id IS NULL; ' + CHAR(13)     
	END     
         
SET @sql = @sql + CHAR(13) + CHAR(13)     
     
---Write Log Entry     
IF @IsAttribute = 0   
BEGIN   
	SET @sql = @sql     
		+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create composite record'', ''update composite record - '+ @Element + ''', @@ROWCOUNT);'      
END   
ELSE   
BEGIN   
    SET @sql = @sql     
		+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create composite attribute'', ''update composite attr - '+ @Element + ''', @@ROWCOUNT);'      
END	   
SET @sql = @sql + CHAR(13) + CHAR(13)     
	+ 'IF Object_ID(''tempdb..[#tmp_ranking_' + REPLACE(@Element, ' ', '') + ']'') Is NOT NULL '+ CHAR(13)     
		+ ' Drop table [#tmp_ranking_' + REPLACE(@Element, ' ', '') + ']' + CHAR(13) + CHAR(13)       
      
---Reset variables     
SET @FieldList = ''     
SET @JoinList = ''     
set @RankingList = ''     
     
IF (@Counter = @maxStdUID) OR (@Counter = @maxAttrUID)   
BEGIN   
	DECLARE    
		@compositeTmpTbl VARCHAR(50) = 'mdm.tmp_composite'    
		,@compositeTbl VARCHAR(50) = 'mdm.compositerecord'   
		,@mdmProcess VARCHAR(50) = 'composite record'   
   
	IF @Counter = @maxAttrUID   
	BEGIN   
		SELECT @compositeTmpTbl = 'mdm.tmp_CompositeAttribute'    
		,@compositeTbl = 'mdm.CompositeAttribute'   
		,@mdmProcess = 'composite attribute'   
	END   
		   
	SET @sql = @SQL   
		+ 'IF ((SELECT COUNT(0) FROM ' + @clientdb + @compositeTmpTbl + ') > 10000'   
		+ CASE WHEN @compositeTbl = 'mdm.compositerecord' THEN ' OR (SELECT COUNT(DISTINCT a.SSB_CRMSYSTEM_CONTACT_ID) FROM ' + @ClientDB + 'mdm.vw_tmp_override_dimcustomer_compositerecord a WHERE a.override_ranking = 1) > 100000' ELSE '' END + ')' + CHAR(13)     
		+ 'BEGIN' + CHAR(13)     
		+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''' + @compositeTbl + '''' + CHAR(13)     
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create ' + @mdmProcess + ''', ''Disable Indexes'', ''0'');' + CHAR(13)    
		+ 'END' + CHAR(13)     
	SET @sql = @sql + CHAR(13) + CHAR(13)     
 
	-- Apply source 
	IF @compositeTbl = 'mdm.compositerecord'  
	BEGIN  
		SET @sql = @sql + @sql_apply_source 
	END  
 
	SET @sql = @sql     
		+ ' DELETE b' + CHAR(13)   
		+ ' FROM ' + @clientdb + @compositeTmpTbl + ' a' + CHAR(13)   
		+ ' INNER JOIN ' + @ClientDB + @compositeTbl + ' b ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13) + CHAR(13)   
     
	SET @sql = @sql     
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create ' + @mdmProcess + ''', ''remove updated recs'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)     
     
     
	SET @sql = @sql      
		+ ' Insert into ' + @clientdb + @compositeTbl + CHAR(13)     
		+ ' Select *' + CASE WHEN @compositeTbl = 'mdm.CompositeAttribute' THEN ', SYSDATETIME()' ELSE '' END + CHAR(13)   
		+ ' from ' + @clientdb + @compositeTmpTbl + CHAR(13)     
     
	---Write Log Entry     
	SET @sql = @sql     
		+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create ' + @mdmProcess + ''', ''Insert Updated Records'', @@ROWCOUNT);'      
	SET @sql = @sql + CHAR(13) + CHAR(13)     
 
	-- Apply overrides 
	IF @compositeTbl = 'mdm.compositerecord'  
	BEGIN  
		SET @sql = @sql + @sql_apply_overrides  
	END  
     
	SET @sql = @sql + CHAR(13) + CHAR(13)     
	SET @sql = @sql     
		+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 1, ''' + @compositeTbl + '''' + CHAR(13)     
		SET @sql = @sql + CHAR(13) + CHAR(13)     
     
		SET @sql = @sql     
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
		+ 'values (current_timestamp, ''create ' + @mdmProcess + ''', ''Re-Enable Indexes'', ''0'');'      
	SET @sql = @sql + CHAR(13) + CHAR(13)   
   
END   
   
---Increment Counter     
SET @Counter = @Counter + 1     
   
----SELECT @SQL  
SET @sql_final = @sql_final + @sql   
--EXEC sp_executesql @sql    
END     
    
SET @sql_final = 'Declare @elementidssp int' + CHAR(13) + CHAR(13) + @sql_final  
  
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
   
---SELECT @sql_final  
EXEC sp_executesql @sql_final  

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
END
GO
