SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [mdm].[PrivacyDataDeletion] @clientdb varchar(50)
as 
Begin

----declare @clientdb varchar(50) = 'USC'

     
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
	,@sql NVARCHAR(MAX) = '' 
	,@MDM_DB VARCHAR(50) = '' 
	,@searchsql nvarchar(max) = ''
	,@ExcludeSQL nvarchar(max) = ''
	,@TableColumnsSQL nvarchar(max) = ''
	, @TableJoinSQL nvarchar(max) = ''
	,@UpdateSQL nvarchar(max) = ''
		,@Counter INT = 1 
--- Get all criteria pre-sql and run it once. 

 DECLARE  
@elementFieldList nVARCHAR(MAX) = '' 
,@elementJoinList nVARCHAR(MAX)  = '' 
,@elementConditionList NVARCHAR(MAX) = '' 
, @ExcludeColumnList varchar(max) = ''
,@SearchColumnList varchar(max) = ''   
,@UpdateColumnList varchar(max)  = ''
,@SelectMaskList varchar(max) = ''
,@TableJoinList varchar(max) = ''
, @KeyFieldsList varchar(max) = ''
, @UpdateJoinList varchar(max) = ''
, @TableJoinColumnList varchar(max) = ''

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

SET @GetPreSQl = @GetPreSQL   
+' SELECT  @PreSQLQuery = COALESCE(@PreSQLQuery + '' '', '''') + c.PreSQL ' + CHAR(13)     
+' FROM  ' + @clientDb + 'mdm.criteria c ' + CHAR(13)     
+' where c.criteriaID in (select distinct criteriaid from '      
+ @clientDb + 'mdm.BusinessRules WHERE RuleType = ''Data Retention'') and isnull(presql, '''') != '''' AND ISNULL(IsDeleted,0) = 0' + CHAR(13)     
    
     
EXEC sp_executesql @GetPreSQL     
        , N'@PreSQLQuery nvarchar(max) OUTPUT'     
       ,  @PreSQLQuery OUTPUT     
     
IF ISNULL(@PreSQLQuery,'') = ''
	SET @PreSQLQuery = 'RETURN'

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

----SELECT @PreSQLQuery     
     
EXEC sp_executesql @PreSQLQuery    

 
IF OBJECT_ID('tempdb..#DataRetentionRules') IS NOT NULL 
	DROP TABLE #DataRetentionRules 
 
CREATE TABLE #DataRetentionRules ( BusinessRuleID INT NOT NULL, RuleType VARCHAR(50),Criteria VARCHAR(100),CriteriaField VARCHAR(100) 
	, CriteriaJoin VARCHAR(MAX), CriteriaCondition VARCHAR(MAX), LogicalOperator VARCHAR(5), GroupID INT) 
 
    
SET @sql = '' 
	+ ' INSERT INTO #DataRetentionRules' 
	+ ' SELECT a.BusinessRuleID' + CHAR(13) 
	+ ' 	,a.RuleType' + CHAR(13) 
	+ ' 	,c.Criteria' + CHAR(13) 
	+ ' 	,c.CriteriaField' + CHAR(13) 
	+ ' 	,c.CriteriaJoin' + CHAR(13) 
	+ ' 	,c.CriteriaCondition' + CHAR(13) 
	+ ' 	,a.LogicalOperator' + CHAR(13) 
	+ ' 	,a.GroupID' + CHAR(13) 
	+ ' FROM ' + @clientDb + 'mdm.BusinessRules a' + CHAR(13) 
	+ ' INNER JOIN ' + @clientDb + 'mdm.Element b ON a.ElementID = b.ElementID' + CHAR(13) 
	+ ' INNER JOIN ' + @clientDb + 'mdm.Criteria c ON a.CriteriaID = c.CriteriaID' + CHAR(13) 
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' AND a.RuleType = ''Data Retention''' + CHAR(13) 
	+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13) + CHAR(13) 
 
EXEC sp_executesql @sql 
  
 ---select * from #DataRetentionRules


SET @sql = '' 
	+ ' SELECT @elementFieldList = COALESCE(@elementFieldList + '' '', '''') + a.CriteriaField + '',''' + CHAR(13)     
	+ ' , @elementJoinList = COALESCE(@elementJoinList + '' '', '''') + ISNULL(a.CriteriaJoin, '''') ' + CHAR(13)     
	+ ' , @elementConditionList = LTRIM(RTRIM(COALESCE(@elementConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + a.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, ''''))) ' + CHAR(13)     
	--+ ' , @elementConditionList = LTRIM(RTRIM(COALESCE(@elementConditionList + '' '', '''') + CASE WHEN ISNULL(a.LogicalOperator,'''') = '''' THEN ''AND '' ELSE a.LogicalOperator + '' '' END + ISNULL(CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''START'' END + a.CriteriaCondition + CASE WHEN ISNULL(a.GroupID,0) = 0 THEN '''' ELSE ''GROUP'' + CAST(a.GroupID AS VARCHAR(5)) + ''END'' END, ''''))) ' + CHAR(13)     
	+ ' FROM #DataRetentionRules a' + CHAR(13)  
	+ ' WHERE 1=1' + CHAR(13) 
	+ ' ORDER BY a.LogicalOperator' + CHAR(13) + CHAR(13)   
     
	+ 'EXEC ' + @MDM_DB + '.mdm.transformCriteriaConditionList @elementConditionList, ''' + @ClientDB + ''', @elementConditionList OUTPUT' + CHAR(13) + CHAR(13) 
 
 	SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '.' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''' + CHAR(13) 
		+ ', N''@elementFieldList nvarchar(max) OUTPUT, @elementJoinList nvarchar(max) OUTPUT, @elementConditionList nvarchar(max) OUTPUT''' + CHAR(13) 
		+ ', @elementFieldList = @elementFieldList OUTPUT' + CHAR(13) 
		+ ', @elementJoinList = @elementJoinList OUTPUT' + CHAR(13)  
		+ ', @elementConditionList = @elementConditionList OUTPUT' + CHAR(13) 

			EXEC sp_executesql @sql, N'@elementFieldList nvarchar(max) OUTPUT, @elementJoinList nvarchar(max) OUTPUT, @elementConditionList nvarchar(max) OUTPUT'     
		   , @elementFieldList = @elementFieldList OUTPUT 
		   , @elementJoinList = @elementJoinList OUTPUT  
		   , @elementConditionList = @elementConditionList OUTPUT; 
 

 --- select @elementConditionList
 --- Select @elementjoinlist

  IF OBJECT_ID('tempdb..#DataRetentionCustomers') IS NOT NULL 
	DROP TABLE #DataRetentionCustomers

Create table  #DataRetentionCustomers (SSB_CRMSYSTEM_CONTACT_ID varchar(50))

IF OBJECT_ID('tempdb..#ToBeDeleted') IS NOT NULL 
	DROP TABLE #ToBeDeleted

Create Table #ToBeDeleted (dimcustomerid int, SSID nvarchar(100), Sourcesystem nvarchar(50), ssb_crmsystem_contact_id varchar(50), contactguid varchar(50), fullname nvarchar(500), emailprimary nvarchar(256), data_deletion_request_ts datetime)

  set @sql = '' 

	 + 'Insert into #ToBeDeleted' + CHAR(13)
	 + 'select a.dimcustomerid, b.ssid, b.sourcesystem, b.ssb_crmsystem_contact_id, d.contactguid, isnull(d.fullname, d.firstname + '' '' + d.middlename + '' '' + d.lastname + '' '' + d.suffix), d.emailprimary, a.data_deletion_request_TS ' + CHAR(13)
	 + 'from ' + @clientDb + 'dbo.dimcustomerprivacy a' + CHAR(13)
	 + 'inner join ' + @clientDb + 'dbo.dimcustomer d' + Char(13)
	 + 'on a.dimcustomerid = d.dimcustomerid ' + Char(13)
	 + 'inner join ' + @clientDb + 'dbo.dimcustomerssbid b' + Char(13)
	 + 'on a.dimcustomerid = b.dimcustomerid ' + Char(13)
	 + 'where Data_Deletion_Request_TS is not null and (Data_Deletion_Completed_TS is null OR Data_Deletion_Completed_TS < d.UpdatedDate)' + CHAR(13)
	 + CHAR(13)+ CHAR(13)


	 + 'Insert into #ToBeDeleted' + CHAR(13)
	 + 'Select a.dimcustomerid, a.ssid, a.sourcesystem, a.ssb_crmsystem_contact_id,  d.contactguid, isnull(d.fullname, d.firstname + '' '' + d.middlename + '' '' + d.lastname + '' '' + d.suffix), d.emailprimary, b.data_deletion_request_TS ' + CHAR(13)
	 + 'from ' + @clientDb + 'dbo.dimcustomerssbid a' + CHAR(13)
	  + 'inner join ' + @clientDb + 'dbo.dimcustomer d' + Char(13)
	 + 'on a.dimcustomerid = d.dimcustomerid ' + Char(13)
	 + 'inner join #ToBeDeleted b' + CHAR(13)
	 + 'on a.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id' + CHAR(13)
	 + 'and a.dimcustomerid != b.dimcustomerid' + CHAR(13)

	  + 'Create clustered index ix_delete on #ToBeDeleted(dimcustomerid);' + CHAR(13) + CHAR(13) 
	   + 'Create  index ix_delete2 on #ToBeDeleted(ssb_crmsystem_contact_id);' + CHAR(13) + CHAR(13) 

IF len(@elementConditionList) > 0
Begin
Set @sql = @sql 
  + 'Insert into #DataRetentionCustomers' + CHAR(13)
	 + 'select distinct a.ssb_crmsystem_contact_id' + CHAR(13)   
	 + 'from #ToBeDeleted a' + CHAR(13) 
	 + 'inner join ' + @clientDb + 'dbo.dimcustomer dimcust' + CHAR(13) 
	 + 'on a.dimcustomerid = dimcust.dimcustomerid' + CHAR(13) 
	 + 'inner join ' + @clientDB + 'dbo.dimcustomerssbid ssbid' + CHAR(13)
	 + 'on dimcust.dimcustomerid = ssbid.dimcustomerid' + CHAR(13)
	 + ISNULL(@elementJoinList,'') 
	 + ' where 1=1 and (' + @elementConditionList + ')' + CHAR(13) + CHAR(13) 

	 + 'Create clustered index ix_retain on #DataRetentionCustomers(ssb_crmsystem_contact_id);' + CHAR(13) + CHAR(13) 

	 + 'Delete a ' + CHAR(13)
	 + 'from #ToBeDeleted a' + CHAR(13)
	 + 'Inner Join #DataRetentionCustomers b' + CHAR(13)
	 + 'on a.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id'  + CHAR(13) + CHAR(13) 
END

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

---select @sql;

EXEC sp_executesql @sql;
SET @sql = '' -- reset variable

---	select * from #ToBeDeleted
--- select * from #DataRetentionCustomers

IF (Select count(0) from #ToBeDeleted) > 0 
BEGIN
  
Set @SearchSQL = @SearchSQL
+'Select @SearchColumnList = Coalesce(@SearchColumnList + '' '', '''') + ''c.COLUMN_NAME LIKE '' + REplace(SearchString, ''OR '', ''OR c.COLUMN_NAME LIKE '') + '' OR '' '+ CHAR(13)
+'from mdm.PII_DataFields'+ CHAR(13)
+'where exclude = 0'+ CHAR(13)

	EXEC sp_executesql @Searchsql, N'@SearchColumnList nvarchar(max) OUTPUT'     
		   , @SearchColumnList = @SearchColumnList OUTPUT 
		 
		--- SElect @SearchColumnList;

	
Set @ExcludeSQL = @ExcludeSQL
+'Select @ExcludeColumnList = Coalesce(@ExcludeColumnList + '' '', '''')  + ''c.COLUMN_NAME NOT LIKE '' + REplace(SearchString, ''OR '', ''AND c.COLUMN_NAME NOT LIKE '') + '' AND '' '+ CHAR(13)
+'from mdm.PII_DataFields'+ CHAR(13)
+'where exclude =1'+ CHAR(13)

	EXEC sp_executesql @Excludesql, N'@ExcludeColumnList nvarchar(max) OUTPUT'     
		   , @ExcludeColumnList = @ExcludeColumnList OUTPUT 


---declare @TableJoinSQL nvarchar(max) = '', @TableJoinColumnList varchar(max) = ''
Set @TableJoinSQL = @TableJoinSQL
+'Select @TableJoinColumnList = Coalesce(@TableJoinColumnList + '' '', '''')  + ''c.COLUMN_NAME = '''''' + KeyField + '''''' OR '' '+ CHAR(13)
+'from mdm.TableJoins'+ CHAR(13)


	EXEC sp_executesql @TableJoinSQL, N'@TableJoinColumnList nvarchar(max) OUTPUT'     
		   , @TableJoinColumnList = @TableJoinColumnList OUTPUT 

--- Select @TableJoinColumnList


IF OBJECT_ID('tempdb..#TableColumns') IS NOT NULL 
	DROP TABLE #TableColumns
---get Table/ Fields to be masked 

Create table #TableColumns(Table_Schema varchar(50), Table_Name varchar(100), Column_Name varchar(100), Data_Type varchar(30), TableNum int )

  set @TableColumnsSQL = @TableColumnsSQL
  + 'Insert into #TableColumns ' + CHAR(13)
+ 'SELECT c.TABLE_SCHEMA, c.Table_Name, COLUMN_NAME, DATA_TYPE, Dense_rank() over ( order by  c.table_schema, c.table_name)' + CHAR(13)
+ 'from ' + @ClientDB + 'INFORMATION_SCHEMA.COLUMNS c' + CHAR(13)
+ 'left join ' + @ClientDB + 'INFORMATION_SCHEMA.Views v' + CHAR(13)
+ 'on c.TABLE_NAME = v.TABLE_NAME and c.TABLE_SCHEMA = v.TABLE_schema' + CHAR(13)
+ 'where v.TABLE_NAME is null' + CHAR(13)
+ 'AND ( ' +  @SearchColumnList + CHAR(13)
+ @TableJoinColumnList + 'c.column_name = ''A'')' + CHAR(13)
+ ' AND ' + @ExcludeColumnList  + CHAR(13)
+ ' 1 = 1 and data_type != ''uniqueidentifier'''+ CHAR(13)+ CHAR(13)

-- Add TRY/CATCH block to force stoppage and log error      
SET @TableColumnsSQL = ''     
	+ ' BEGIN TRY' + CHAR(13)      
	+ @TableColumnsSQL
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

---SElect @TableColumnsSQL
EXEC sp_executesql @TableColumnsSQL

---select * from #TableColumns --- where data_type = 'uniqueidentifier'

Declare @TableName  varchar(50) = ''
Declare @TableSchema varchar(25) = ''


WHILE @counter <= (SELECT MAX(TableNum) FROM #TableColumns) 
BEGIN  

SEt @TableName = (Select Distinct Table_Name from #tableColumns where TableNum = @Counter)
SEt @TableSchema = (Select Distinct Table_Schema from #tableColumns where TableNum = @Counter)

SET @UpdateSQL = @UpdateSQL 
+'select @UpdateColumnList = COALESCE(@UpdateColumnList + '' '', '''') + ''a.['' + a.column_name + ''] = b.[''+ column_name +''],'', '+ CHAR(13)
+'@SelectMaskList = Coalesce(@SelectMaskList + '' '', '''') + '' dbo.fn_Mask(a.[''+ a.column_name +''], '''''' + a.data_type + '''''') as ['' + a.column_name + ''],'' '+ CHAR(13)
+'from #TableColumns a' + CHAR(13)
+'Left Join mdm.TableJoins b '
+'on a.column_name = b.KeyField '
+'where Table_Schema = ''' + @TableSchema + ''' and table_name = '''+ replace(@TableName, '''', '''''') + ''' and b.KEYFIELD IS NULL'+ CHAR(13)

---SELECT @UpdateSQL 

	EXEC sp_executesql @UpdateSQL, N' @SelectMaskList nvarchar(max) OUTPUT, @UpdateColumnList nvarchar(max) OUTPUT'     
		   , @SelectMaskList = @SelectMaskList OUTPUT
		   , @UpdateColumnList = @UpdateColumnList OUTPUT
		

---Select @TableName, @UpdateSQL , @SelectMaskList, @UpdateColumnList

SET @TableJoinSQL =  
+'select @TableJoinList = Coalesce(@TableJoinList + '' and a.'', '''') + b.keyField + '' = b.'' + b.JoinField '+ CHar(13)
+ ', @KeyFieldsList = Coalesce(@KeyFieldsList + '' a.'', '''') + b.KeyField ' + char(13)
+ ', @UpdateJoinList = Coalesce(@UpdateJoinList + '' and a.'', '''') + b.keyfield + '' = b.'' + b.keyfield ' + char(13)
+'from #TableColumns a' + CHAR(13)
+'Inner Join mdm.TableJoins b '
+'on a.column_name = b.KeyField '
+'where Table_Schema = ''' + @TableSchema + ''' and table_name = '''+ replace(@TableName, '''', '''''') + ''' and b.GroupID IS NULL'+ CHAR(13)




---SELECT @UpdateSQL 

	EXEC sp_executesql @TableJoinSQL, N' @TableJoinList nvarchar(max) OUTPUT, @KeyFieldsList nvarchar(max) OUTPUT, @UpdateJoinList nvarchar(max) OUTPUT'     
		   , @TableJoinList = @TableJoinList OUTPUT
		   , @KeyFieldsList = @KeyFieldsList Output
		   , @UpdateJoinList = @UpdateJoinList Output

----Select @TableName, @TableJoinSQL , @SelectMaskList, @UpdateColumnList, @TableJoinList

Declare @RecordCount int = 0
	
If @TableJoinList like '%DimCustomerID%'
Begin
Set @TableJoinSQL = 'Select @RecordCount =  count(0) from ' + @clientdb + @TableSchema +'.' + @Tablename + ' where DimcustomerID is not null'

	EXEC sp_executesql @TableJoinSQL, N' @RecordCount INT OUTPUT'     
		   , @RecordCount = @RecordCount OUTPUT
END

---Select @RecordCount

IF @TableJoinList = ''  OR @RecordCount = 0
Begin
SET @TableJoinLIst = ''
SET @KeyFieldsLIst = ''
SET @UpdateJoinList = ''

SET @TableJoinSQL = 
+'select @TableJoinList = Coalesce(@TableJoinList + '' and a.'', '''') + b.keyField + '' = b.'' + b.JoinField '+ CHar(13)
+ ', @KeyFieldsList = Coalesce(@KeyFieldsList + '' a.'', '''') + b.KeyField ' + char(13)
+ ', @UpdateJoinList = Coalesce(@UpdateJoinList + '' and a.'', '''') + b.keyfield + '' = b.'' + b.keyfield ' + char(13)
+'from #TableColumns a' + CHAR(13)
+'Inner Join mdm.TableJoins b '
+'on a.column_name = b.KeyField '
+'where b.groupid is not null and Table_Schema = ''' + @TableSchema + ''' and table_name = '''+ replace(@TableName, '''', '''''') + '''' + CHAR(13)

---SELECT @TableJoinSQL


	
	EXEC sp_executesql @TableJoinSQL, N' @TableJoinList nvarchar(max) OUTPUT, @KeyFieldsList nvarchar(max) OUTPUT, @UpdateJoinList nvarchar(max) OUTPUT'     
		   , @TableJoinList = @TableJoinList OUTPUT
		   , @KeyFieldsList = @KeyFieldsList Output
		   , @UpdateJoinList = @UpdateJoinList Output
END

---Select @TableName, @TableJoinSQL , @SelectMaskList, @UpdateColumnList, @TableJoinList



IF OBJECT_ID('tempdb..#MaskData') IS NOT NULL 
	DROP TABLE #MaskData

IF len(ltrim(rtrim(@SelectMaskList))) > 0 AND Len(ltrim(rtrim(@TableJoinList))) > 0
Begin
set @sql = ''
+'Select '+  @SelectMaskList + Replace(rtrim(ltrim(@KeyFieldsList)), ' ', ',') + CHAR(13)
+' into #MaskData '+ CHAR(13)
+'from '+ @ClientDB  + '[' + @TableSchema +'].[' + @TableName + '] a'+ CHAR(13)
+'inner join #ToBeDeleted b'+ CHAR(13)
+'	 on 1 = 1  ' + @TableJoinList + ';'+ CHAR(13) + CHAR(13)

+' IF @@RowCount > 0 '+ CHAR(13)
+'Begin'+ CHAR(13)
+'Update a ' + CHAR(13)
+'set 	' + SubString(@UpdateColumnList, 1, Len(rtrim(@UpdateColumnList)) - 1)  + CHAR(13)

IF @TableName = 'DimCustomer' and @TableSchema = 'dbo'
	Begin

	set @sql = @sql 
	+'	, nameiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, addressprimaryiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, addressoneiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, addresstwoiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, addressthreeiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, addressfouriscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, EmailPrimaryiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, EmailOneiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, EmailTwoiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, PhonePrimaryiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, PhoneHomeiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, PhoneCelliscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, PhoneOtheriscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)
	+'	, PhoneBusinessiscleanstatus = ''PRIVACY MASKED'''+ CHAR(13)

	End

set @sql = @sql 
+'from '+ @ClientDB  + '[' + @TableSchema +'].[' + @TableName + '] a'+ CHAR(13)
+'inner join #MaskData  b ' + CHAR(13)
+'on 1 = 1  ' + @UpdateJoinList + ';'+ CHAR(13) + CHAR(13)

	+ ' Insert into '+ @ClientDB  +'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ ' values (current_timestamp, ''Privacy Data Deletion'', ''Table MASK:' + @TableSchema +'.' + @TableName + ''', @@RowCount);' + CHAR(13) + CHAR(13) 

+'End'+ CHAR(13)

END



IF Exists(Select * from mdm.PII_TableDeletes where Tableschema = @TableSchema and TableName = @TableName)
BEGIN

Set @SQL = 'Delete a from '  + @ClientDB  + @TableSchema +'.' + @TableName + ' a'+ CHAR(13)
+' inner join #ToBeDeleted b'+ CHAR(13)
+' on 1= 1 ' + @TableJoinList + ';'+ CHAR(13) + CHAR(13) 

	+ ' Insert into '+ @ClientDB  +'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ ' values (current_timestamp, ''Privacy Data Deletion'', ''Table DELETE:' + @TableSchema +'.' + @TableName + ''', @@RowCount);' + CHAR(13) + CHAR(13) 

END

--print @Tableschema
--Print @TableName

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

---select @Tableschema, @TableName,  @sql
EXEC sp_executesql @SQL


SET @UpdateSQL = ''
SET @TableJoinSQL = ''
Set @SelectMaskList = ''
Set @UpdateColumnList = ''
Set @TableJoinList = ''
SEt @Counter = @Counter + 1
Set @SQL = ''
Set @KeyFieldsList = ''
Set @UpdateJoinList = ''
ENd


END

Set @SQL = 
+' Update a'+ CHAR(13)
+' 	 set Data_Deletion_Completed_TS = getdate(), '+ CHAR(13)
+' 	 Data_Deletion_Incomplete_Reason = null'+ CHAR(13)
+' 	 from '+ @ClientDB  +'dbo.DimCustomerPrivacy a'+ CHAR(13)
+' 	 inner join #ToBeDeleted b'+ CHAR(13)
+' 	 on a.dimcustomerid = b.dimcustomerid'+ CHAR(13)+ CHAR(13)

+ ' Insert into '+ @ClientDB  +'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ ' values (current_timestamp, ''Privacy Data Deletion'', ''Update Completion TS'', @@RowCount);' + CHAR(13) + CHAR(13) 

+' 	 Update a '+ CHAR(13)
+' 	 Set Data_Deletion_Incomplete_Reason = ''Data Retention Business Rules'''+ CHAR(13)
+' 	  from '+ @ClientDB  +'dbo.DimCustomerPrivacy a'+ CHAR(13)
+ ' inner join '+ @ClientDB  +'dbo.dimcustomerssbid ssbid ' + CHAR(13)
+ ' on a.dimcustomerid = ssbid.dimcustomerid ' + Char(13)
+' 	 inner join #DataRetentionCustomers b'+ CHAR(13)
+' 	 on ssbid.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id'+ CHAR(13)+ CHAR(13)


+ ' Insert into '+ @ClientDB  +'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ ' values (current_timestamp, ''Privacy Data Deletion'', ''Update Data Retention'', @@RowCount);' + CHAR(13) + CHAR(13) 

----LOG deletion
+' 	Insert into mdm.PrivacyLog (ClientName, dimcustomerid, SSID, SourceSystem, ssb_crmsystem_contact_id, contactguid, fullname, emailprimary, Data_Deletion_Request_TS, Data_Deletion_TS)'+ CHAR(13)
+' 	Select ''' + @Clientdb + ''' as ClientName, dimcustomerid, SSID, SourceSystem, ssb_crmsystem_contact_id, contactguid, fullname, emailprimary, Data_Deletion_Request_TS, current_timestamp as Data_Deletion_TS'+ CHAR(13)
+' 	from #ToBeDeleted'+ CHAR(13) + CHAR(13)


+ ' Insert into '+ @ClientDB  +'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ ' values (current_timestamp, ''Privacy Data Deletion'', ''Privacy Log'', @@RowCount);' + CHAR(13) + CHAR(13) 

  
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

---select @sql;

EXEC sp_executesql @sql

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql


END
GO
