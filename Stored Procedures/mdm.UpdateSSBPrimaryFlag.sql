SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
  
CREATE PROCEDURE [mdm].[UpdateSSBPrimaryFlag]  
(  
	@ClientDB VARCHAR(50),  
	@RecognitionType VARCHAR(50), 
	@Debug BIT = 0,  
	@ID varchar(50) = '' 
)  
AS  
BEGIN  
  
/* mdm.UpdateSSBPrimaryFlag - Creates/Updates SSB Primary Flag  
* created: 11/18/2014 kwyss  
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL  
* 7/27/2015 - Kwyss - modified to use configurable business rules  
* 4/28/2017 - GHolder - Added @RecognitionType parameter and adjusted code accordingly  
*  
*/  
  
---DECLARE @clientdb varchar(50) = 'Coyotes', @RecognitionType varchar(50) = 'contact', @Debug BIT = 0, @ID varchar(50) = ''
  
IF (SELECT @@VERSION) LIKE '%Azure%'  
BEGIN  
SET @ClientDB = ''  
END  
  
IF (SELECT @@VERSION) NOT LIKE '%Azure%'  
BEGIN  
SET @ClientDB = @ClientDB + '.'  
END  
  
 
DECLARE @SQL nvarchar(max) = ' ';  
DECLARE @SQL2 nvarchar(max) = ' ';  
DECLARE @FieldList nVARCHAR(MAX) = '';  
DECLARE @JoinList nVARCHAR(MAX)  = '';  
DECLARE @RankingLIST nVARCHAR(MAX) = '';  
DECLARE @ElementID VARCHAR(5) = '';  
DECLARE @GetPreSQL NVARCHAR(MAX) = '';  
DECLARE @PreSQLQuery NVARCHAR(MAX) = '';  
DECLARE @primaryFlagField VARCHAR(50) = CASE   
										WHEN @RecognitionType = 'Contact' THEN 'SSB_CRMSYSTEM_PRIMARY_FLAG'   
										WHEN @RecognitionType = 'Account' THEN 'SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG'  
										WHEN @RecognitionType = 'Household' THEN 'SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG'  
									END  
DECLARE @idField VARCHAR(50) = CASE   
										WHEN @RecognitionType = 'Contact' THEN 'SSB_CRMSYSTEM_CONTACT_ID'   
										WHEN @RecognitionType = 'Account' THEN 'SSB_CRMSYSTEM_ACCT_ID'  
										WHEN @RecognitionType = 'Household' THEN 'SSB_CRMSYSTEM_HOUSEHOLD_ID'  
									END  

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
  
--- Get all criteria pre-sql and run it once.  
  
SET @GetPreSQl = @GetPreSQL  
+' SELECT  @PreSQLQuery = COALESCE(@PreSQLQuery + '' '', '''') + c.PreSQL ' + CHAR(13)  
+' FROM  ' + @clientDb + 'mdm.criteria c ' + CHAR(13)  
+' where c.criteriaID in (select distinct criteriaid from '   
+ @clientDb + 'mdm.BusinessRules where RuleType = ''Primary Flag'' AND ISNULL(IsDeleted,0) = 0) and isnull(presql, '''') != ''''' + CHAR(13)  
  
  
EXEC sp_executesql @GetPreSQL  
        , N'@PreSQLQuery nvarchar(max) OUTPUT'  
       ,  @PreSQLQuery OUTPUT  
  
 IF ISNULL(@PreSQLQuery,'') = ''
	SET @PreSQLQuery = 'RETURN'

 IF @debug = 1 
 Begin 
	Select @PreSQLQuery as PreSQLQuery 
 End 
 
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
   
--- Get Criteria for Primary Record  
SET @SQL2 = @SQL2  
  
+' SELECT @FieldList = COALESCE(@FieldList + '', '', '''')' + 
	' + CASE ' + 
		'WHEN c.CriteriaField NOT LIKE ''%(%'' AND c.CriteriaField NOT LIKE ''% %'' AND c.CriteriaField NOT LIKE ''%.%'' AND c.CriteriaField NOT LIKE ''%[%'' AND c.CriteriaField NOT LIKE ''%]%'' THEN QUOTENAME(c.CriteriaField) ' + 
		'ELSE c.CriteriaField END + '' as '' + QUOTENAME(c.criteria)' + CHAR(13)  
+' , @JoinList = COALESCE(@JoinList + '' '', '''') + ISNULL(c.CriteriaJoin, '''') ' + CHAR(13)  
+' ,@RankingList = COALESCE(@RankingList + '' '', '''') + ''['' + c.criteria + ''] '' + Isnull(c.CriteriaOrder, ''ASC'') + '',''' + CHAR(13)  
+' ,@elementid = b.elementid'  
+' FROM ' + @clientDb + 'mdm.BusinessRules a ' + CHAR(13)  
+' INNER JOIN ' + @clientDb + 'mdm.element b ' + CHAR(13)  
+' ON a.elementid = b.elementid ' + CHAR(13)  
+' INNER JOIN ' + @clientDb + 'mdm.criteria c ' + CHAR(13)  
+' ON c.criteriaID = a.criteriaID ' + CHAR(13)  
+' WHERE element = ''Primary Record''' + CHAR(13)  
+' AND RuleType = ''Primary Flag''' + CHAR(13) 
+ ' AND ISNULL(a.IsDeleted,0) = 0' + CHAR(13)  
+' ORDER BY priority; ' + CHAR(13)  
  
  IF @debug = 1 
 Begin 
	Select @SQL2 as Criteria_Query 
 End 
 
  
EXEC sp_executesql @SQL2  
        , N'@FieldList nvarchar(max) OUTPUT, @JoinList nvarchar(max) OUTPUT, @RankingLIST nvarchar(max) OUTPUT, @ElementId varchar(5) OUTPUT'  
       , @FieldList OUTPUT  
       , @JoinList OUTPUT  
       , @RankingLIST OUTPUT  
	   , @ElementID OUTPUT  
  
  IF @debug = 1 
 Begin 
	Select @FieldList as Fieldlist 
	Select @JoinList as joinlist 
	Select @RankingList as rankinglist 
	Select @ElementID as elementid 
 End 
 
  
  
  
---Get Data  
SET @SQL = @SQL  
+ 'IF OBJECT_ID(''' + @clientDb + 'mdm.tmp_flag_data'') IS NOT NULL'+ CHAR(13)   
+ 'drop table ' + @clientDb + 'mdm.tmp_flag_data;'+ CHAR(13)   
  
EXEC sp_executesql @SQL  
  
SET @SQL = @SQL  
+ 'IF OBJECT_ID(''' + @clientDb + 'mdm.PrimaryFlagRanking_'  + @RecognitionType + ''') IS NOT NULL'+ CHAR(13)   
+ 'drop table ' + @clientDb + 'mdm.PrimaryFlagRanking_' + @RecognitionType + ';'+ CHAR(13)   
  
EXEC sp_executesql @SQL  
  
SET @SQL = @SQL  
+ 'IF OBJECT_ID(''' + @clientDb + 'mdm.tmpPrimaryFlagUpdate'') IS NOT NULL'+ CHAR(13)   
+ 'drop table ' + @clientDb + 'mdm.tmpPrimaryFlagUpdate;'+ CHAR(13)   
  
EXEC sp_executesql @SQL  
  
SET @SQL =  
'SELECT ssbid.dimcustomerid ' + CHAR(13)   
+ ',ssbid.sourcesystem ' + CHAR(13)   
+ ',ssbid.ssid ' + CHAR(13)   
+ ',ssbid.ssb_crmsystem_acct_id  ' + CHAR(13)  
+ ',ssbid.SSB_CRMSYSTEM_CONTACT_ID  ' + CHAR(13)  
+ ',ssbid.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)  
+ ',ssbid.SSB_CRMSYSTEM_PRIMARY_FLAG    ' + CHAR(13)  
+ ',ssbid.SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG ' + CHAR(13)  
+ ',ssbid.SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG ' + CHAR(13)  
+  @FieldList    
+ ' INTO ' + @clientDb + 'mdm.tmp_flag_data '  
+ ' FROM ' + @clientDb + 'dbo.dimcustomerssbid ssbid ' + CHAR(13)  
+ 'INNER JOIN ' + @clientDb + 'dbo.vw_dimcustomer dimcust ' + CHAR(13)  
+ 'ON ssbid.DimCustomerId = dimcust.dimcustomerid ' + CHAR(13)  
+   @JoinList   + CHAR(13)  
+ ' WHERE dimcust.isdeleted = 0 '  
IF @Joinlist LIKE '%mdm.SourceSystemPriority%'  
BEGIN  
SET @SQL = @SQL + 'and isnull(elementid, ' + @elementID  + ') = ' + @elementID   
End  
SET @SQL = @SQL + CHAR(13) + CHAR(13)  
  
  
  
SET @sql = @sql  
	+ 'Insert into ' + @clientDb + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ 'values (current_timestamp, ''Primary Flag'', ''tmp_flag_data'', @@ROWCOUNT);'   
SET @sql = @sql + CHAR(13) + CHAR(13)  
 
  
IF @RecognitionType = 'Contact'  
BEGIN  
	SET @sql = @sql  
		+ '---Update any deleted records to 0 (should not be primary)' + CHAR(13)  
		+ 'Update ssbid' + CHAR(13)  
		+ 'set ssb_crmsystem_primary_flag = 0, ssb_crmsystem_acct_primary_flag = 0, SSB_CRMSYSTEM_HOUSEHOLD_PRIMARY_FLAG = 0' + CHAR(13)  
		+ 'from ' + @clientDb + 'dbo.dimcustomerssbid ssbid' + CHAR(13)  
		+ 'inner join ' + @clientDb + 'dbo.vw_dimcustomer dimcust' + CHAR(13)  
		+ 'on ssbid.dimcustomerid = dimcust.dimcustomerid' + CHAR(13)  
		+ 'where dimcust.isdeleted = 1;'  
	SET @sql = @sql + CHAR(13) + CHAR(13)  
  
	SET @sql = @sql  
		+ 'Insert into ' + @clientDb + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
		+ 'values (current_timestamp, ''Primary Flag'', ''remove deleted records'', @@ROWCOUNT);'   
	SET @sql = @sql + CHAR(13) + CHAR(13)  
END  
  
SET @sql = @sql + ' select *,' + CHAR(13) 	+ CASE   
		WHEN @RecognitionType = 'Contact' THEN   
			'RANK() over (partition by ' + @idField + ' order by ' + @RankingList + @idField + ' desc, DimCustomerId) as ranking'  
			+ ', RANK() over (partition by ' + @idField + ', sourcesystem order by ' + @RankingList + @idField + ' desc, DimCustomerId) as ss_ranking'  
		WHEN @RecognitionType IN ('Account', 'Household') THEN  
			'rank() over (partition by isnull(' + @idField + ', ssb_crmsystem_contact_id) order by ' + @RankingList + ' ssb_crmsystem_primary_flag desc, ' + @primaryFlagField + ' desc,  DimCustomerId) as ranking'  
			+ ', rank() over (partition by isnull(' + @idField + ', ssb_crmsystem_contact_id), sourcesystem order by ' + @RankingList + ' ssb_crmsystem_primary_flag desc, ' + @primaryFlagField + ' desc,  DimCustomerId) as SS_ranking'  
	END + CHAR(13) 	+ ' INTO ' + @clientDb + 'mdm.PrimaryFlagRanking_' + @RecognitionType  + CHAR(13) + ' FROM ' + @clientDb + 'mdm.tmp_flag_data' + CHAR(13)   
		SET @sql = @sql + CHAR(13) + CHAR(13)  
 
SET @sql = @sql +  ' CREATE CLUSTERED INDEX ix_tmpRanking ON ' + @clientDb + 'mdm.PrimaryFlagRanking_' + @RecognitionType + '(dimcustomerid);' + CHAR(13)   
	SET @sql = @sql + CHAR(13) + CHAR(13)  
 
 IF @debug = 1 
 Begin 
	Set @sql = @sql + 'Select top 10000*  from ' + @clientDb + 'mdm.PrimaryFlagRanking_' + @RecognitionType 
	If @ID != '' 
	Begin 
	Set @sql = @sql + ' where ' + @idField + ' = ''' + @id + ''';' 
	end  
 End 
 	SET @sql = @sql + CHAR(13) + CHAR(13)  
SET @sql = @sql  + ' SELECT ssbid.dimcustomerid, case when ranking = 1 then 1 else 0 end AS new_flag' + CHAR(13) + ' INTO ' + @clientDb + 'mdm.tmpPrimaryFlagUpdate' + CHAR(13) + ' FROM ' + @clientDb + 'dbo.dimcustomerssbid ssbid' + CHAR(13) + ' LEFT JOIN ' + @clientDb + 'mdm.PrimaryFlagRanking_' + @RecognitionType + ' b' + CHAR(13) + ' ON ssbid.dimcustomerid = b.dimcustomerid ' + CHAR(13) + ' WHERE isnull(ssbid.' + @primaryFlagField + ', -1) != case when ranking = 1 then 1 else 0 end ' + CHAR(13)   
	 
		SET @sql = @sql + CHAR(13) + CHAR(13)  
	 IF @debug = 1 
 Begin 
	Set @sql = @sql + 'Select top 10000*  from ' + @clientDb + 'mdm.tmpPrimaryFlagUpdate a' 
	If @ID != '' 
	Begin 
	Set @sql = @sql + ' inner join ' + @clientDb + 'dbo.dimcustomerssbid b on a.dimcustomerid = b.dimcustomerid ' 
	+ ' where ' + @idField + ' = ''' + @id + ''';' 
	end  
 End 
		SET @sql = @sql + CHAR(13) + CHAR(13)  
	 IF @debug = 0 
	 Begin 
SET @sql = @sql  
	+ 'Update ssbid' + CHAR(13)  
	+ 'set ' + @primaryFlagField + ' = new_flag ' + CHAR(13)  
	+ 'from ' + @clientDb + 'dbo.dimcustomerssbid ssbid' + CHAR(13)  
	+ 'inner join ' + @clientDb + 'mdm.tmpPrimaryFlagUpdate b' + CHAR(13)  
	+ 'on ssbid.DimCustomerId = b.dimcustomerid;'  
SET @sql = @sql + CHAR(13) + CHAR(13)  
 
 	SET @sql = @sql + CHAR(13) + CHAR(13)  
  
SET @sql = @sql  
	+ 'Insert into ' + @clientDb + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ 'values (current_timestamp, ''Primary Flag'', ''set ' + LOWER(@RecognitionType) + ' primary'', @@ROWCOUNT);'   
SET @sql = @sql + CHAR(13) + CHAR(13)  
 End 
  
----SELECT @SQL

 IF @debug = 1 
 Begin 
	select @SQL as SQL 
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

EXEC sp_executesql @sql  
  
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
 
END
GO
