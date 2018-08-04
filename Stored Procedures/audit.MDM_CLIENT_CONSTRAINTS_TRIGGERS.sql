SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [audit].[MDM_CLIENT_CONSTRAINTS_TRIGGERS] @clientdb varchar(50) 
as
/* USE THIS AGAINST MDM_CLIENT_TEMPLATE TO GENERATE CODE

use mdm_client_template

Select '
If Exists(Select * from '' + @ClientDB + ''INFORMATION_SCHEMA.TABLES where table_name = ''''Auditlog'''' AND table_schema= ''''mdm'''') 
and not Exists(select * from '' + @ClientDB + ''sys.tables as T inner join '' + @ClientDB + ''sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join '' + @ClientDB + ''sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''''' + T.Name + ''''' and I.Name = ''''' + I.Name + ''''' and S.Name = ''''' + S.Name + ''''')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, '''''' + Replace(@clientdb, ''.'', '''') + '''''', ''''' + S.Name + ''''' , ''''' + T.Name + ''''', ''''' + I.Name + ' Missing''''
 End
 '

from sys.tables as T 
inner join sys.objects as I on T.[object_id] = I.[parent_object_id] 
inner join sys.schemas S on t.schema_id = S.schema_id
where I.type_desc != 'Default_Constraint'
 ---and t.name not in ('CompositeAccounts', 'CompositeContacts', 'CompositeHouseholds', 'PrimaryFlagRanking_Contact',
  --- 'PrimaryFlagRanking_Account', 'PrimaryFlagRanking_Household', 'tmpPrimaryFlagRanking')
Order by I.Type_Desc;

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
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''CK_LogicalOperator'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''CK_LogicalOperator Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''overrides'' and I.Name = ''fk_DimCustomerID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''overrides'', ''fk_DimCustomerID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributeValues'' and I.Name = ''FK_DimCustomerAttrID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributeValues'', ''FK_DimCustomerAttrID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyHash'' and I.Name = ''PK_MatchkeyHash_ID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyHash'', ''PK_MatchkeyHash_ID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyConfig'' and I.Name = ''PK_MatchkeyConfig_MatchkeyID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyConfig'', ''PK_MatchkeyConfig_MatchkeyID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributeValues'' and I.Name = ''PK_DimCustomerAttrValsID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributeValues'', ''PK_DimCustomerAttrValsID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''PK_DimCustomerMatchkey_ID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''PK_DimCustomerMatchkey_ID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''PK_CompositeRecord'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''PK_CompositeRecord Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CompositeAttribute'' and I.Name = ''PK_CompositeAttribute'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeAttribute'', ''PK_CompositeAttribute Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''PK_DimcustomerID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''PK_DimcustomerID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CompositeHouseholds'' and I.Name = ''PK_CompositeHouseholds'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeHouseholds'', ''PK_CompositeHouseholds Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''PK_DimcustomerSSBID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''PK_DimcustomerSSBID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''PK_BusinessRuleID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''PK_BusinessRuleID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''overrides'' and I.Name = ''pk_OverrideID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''overrides'', ''pk_OverrideID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributes'' and I.Name = ''PK__DimCusto__ABC69402011C38EB'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributes'', ''PK__DimCusto__ABC69402011C38EB Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CompositeContacts'' and I.Name = ''PK_CompositeContacts'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeContacts'', ''PK_CompositeContacts Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Incoming_Merge'' and I.Name = ''PK__Incoming__B61946E348DEC7E2'' and S.Name = ''api'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''api'' , ''Incoming_Merge'', ''PK__Incoming__B61946E348DEC7E2 Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''AttributeGroup'' and I.Name = ''PK_AttributeGroup'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''AttributeGroup'', ''PK_AttributeGroup Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Attributes'' and I.Name = ''PK_Attributes'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Attributes'', ''PK_Attributes Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CompositeAccounts'' and I.Name = ''PK_CompositeAccounts'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeAccounts'', ''PK_CompositeAccounts Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''PK_ForceMergeID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''PK_ForceMergeID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Source_DimCustomer'' and I.Name = ''PK_Source_DimcustomerID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Source_DimCustomer'', ''PK_Source_DimcustomerID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CD_DimCustomer'' and I.Name = ''PK_CD_Dimcustomer'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CD_DimCustomer'', ''PK_CD_Dimcustomer Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''PK_SSB_HISTORY_NEW'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''PK_SSB_HISTORY_NEW Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''isdeleted_updated'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''isdeleted_updated Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''matchkey_updated'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''matchkey_updated Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyConfig'' and I.Name = ''trg_MatchkeyConfig_Update_Insert'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyConfig'', ''trg_MatchkeyConfig_Update_Insert Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Element'' and I.Name = ''UQ_Element1'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''UQ_Element1 Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''UQ_BusinessRule1'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''UQ_BusinessRule1 Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''UQ_BusinessRule2'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''UQ_BusinessRule2 Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''UK_DIMCUSTOMERSSBID_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''UK_DIMCUSTOMERSSBID_SSID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''UK_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''UK_SSID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Source_DimCustomer'' and I.Name = ''UK_Source_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Source_DimCustomer'', ''UK_Source_SSID Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''UK_Loser'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''UK_Loser Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.objects as I on T.[object_id] = I.[parent_object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''UK_Pair'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''UK_Pair Missing''
 End
 

 
 ' + CHAR(13) + CHAR(13)

 +'END' + Char(13)

--- Select @SQL;

EXEC sp_executesql @SQL;
GO
