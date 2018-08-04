SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [audit].[MDM_CLIENT_TABLES] @clientdb varchar(50) 
as
/* USE THIS AGAINST MDM_CLIENT_TEMPLATE TO GENERATE CODE

use mdm_client_template

Select '
If Exists(Select * from '' + @ClientDB + ''INFORMATION_SCHEMA.TABLES where table_name = ''''Auditlog'''' AND table_schema= ''''mdm'''') 
and not Exists(select * from '' + @ClientDB + ''INFORMATION_SCHEMA.TABLES where table_name = ''''' + table_name + ''''' and table_schema = ''''' + table_schema + ''''')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, '''''' + Replace(@clientdb, ''.'', '''') + '''''', ''''' + TABLE_SCHEMA + ''''' , ''''' + table_name + ''''', ''''Table Missing''''
 End
 '

FROM INFORMATION_SCHEMA.TABLES
ORDER BY table_name;

*/

IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END
Else 
Begin
Set @clientDB = @ClientDB + '.'
End

Declare @SQL nvarchar(max) = ''


Set @SQL = @SQL + 

+'Declare @NotMDMClient int = 0' + Char(13)

+'If NOT Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') ' + Char(13)
+'Begin ' + Char(13)
+'Set @NotMDMClient = 1 ' + Char(13)
+' Print '''+ @Clientdb + '''+ '':Skipping - Not MDM Client'' ' + Char(13)
+'End ' + Char(13)

+'IF @NotMDMClient = 0' + Char(13)
+'Begin' + Char(13)

+'Print '''+ @Clientdb + '''+ '': Creating MDM Table Audit Report'' ' + Char(13) + Char(13)
+'

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''AttributeGroup'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''AttributeGroup'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Attributes'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Attributes'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''auditlog'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''auditlog'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''BusinessRules'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CD_DimCustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CD_DimCustomer'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CD_OUTPUT_ERRORS'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CD_OUTPUT_ERRORS'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ChangeLog'' and table_schema = ''AUDIT'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''AUDIT'' , ''ChangeLog'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ChangeLogDetail'' and table_schema = ''AUDIT'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''AUDIT'' , ''ChangeLogDetail'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CleanDataOutput'' and table_schema = ''archive'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''archive'' , ''CleanDataOutput'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CleanDataOutput'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CleanDataOutput'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CompositeAccounts'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeAccounts'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CompositeAttribute'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeAttribute'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CompositeContacts'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeContacts'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CompositeExclusions'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeExclusions'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''CompositeHouseholds'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeHouseholds'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''compositerecord'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Criteria'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Criteria'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''DimCustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''DimCustomer_INVALID'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer_INVALID'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''DimCustomerAttributes'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributes'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''DimCustomerAttributeValues'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributeValues'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''DimCustomerMatchkey'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''dimcustomerssbid'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''downstream_bucketting'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''downstream_bucketting'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Element'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Exclusions'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Exclusions'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''FedDNCList'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''FedDNCList'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ForceAcctGrouping'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceAcctGrouping'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ForceHouseholdGrouping'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceHouseholdGrouping'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ForceMergeIDs'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''ForceUnMergeIds'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceUnMergeIds'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Incoming_Merge'' and table_schema = ''api'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''api'' , ''Incoming_Merge'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Incoming_UNMERGE'' and table_schema = ''api'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''api'' , ''Incoming_UNMERGE'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Master_DimCustomer_Deltas'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Master_DimCustomer_Deltas'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''MatchkeyConfig'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyConfig'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''MatchkeyHash'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyHash'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Metadata'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Metadata'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''overrides'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''overrides'', ''Table Missing''
 End
 



If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''RecognitionAuditFailure'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''RecognitionAuditFailure'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Source_DimCustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Source_DimCustomer'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''SourceSystemPriority'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SourceSystemPriority'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''SourceSystems'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SourceSystems'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''SSB_ID_History'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''Table Missing''
 End
 



If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''UploadDimCustomerStaging'' and table_schema = ''api'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''api'' , ''UploadDimCustomerStaging'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''version'' and table_schema = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''version'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''vw_CD_DimCustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''vw_CD_DimCustomer'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''vw_dimcustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''vw_dimcustomer'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''vw_Master_DimCustomer_Deltas'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''vw_Master_DimCustomer_Deltas'', ''Table Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''vw_Source_DimCustomer'' and table_schema = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''vw_Source_DimCustomer'', ''Table Missing''
 End
 


 
 ' + CHAR(13) + CHAR(13)

 +'END' + Char(13)

--- Select @SQL;

EXEC sp_executesql @SQL;
GO
