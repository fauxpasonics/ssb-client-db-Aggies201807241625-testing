SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [audit].[MDM_CLIENT_INDEXES] @clientdb varchar(50) 
as
/* USE THIS AGAINST MDM_CLIENT_TEMPLATE TO GENERATE CODE

use mdm_client_template

Select '
If Exists(Select * from '' + @ClientDB + ''INFORMATION_SCHEMA.TABLES where table_name = ''''Auditlog'''' AND table_schema= ''''mdm'''') 
and not Exists(select * from '' + @ClientDB + ''sys.tables as T inner join '' + @ClientDB + ''sys.indexes as I on T.[object_id] = I.[object_id]  
inner join '' + @ClientDB + ''sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''''' + T.Name + ''''' and I.Name = ''''' + I.Name + ''''' and S.Name = ''''' + S.Name + ''''')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, '''''' + Replace(@clientdb, ''.'', '''') + '''''', ''''' + S.Name + ''''' , ''''' + T.Name + ''''', ''''' + I.Name + ' INDEX Missing''''
 End
 '

from sys.tables as T 
inner join sys.indexes as I on T.[object_id] = I.[object_id] 
inner join sys.schemas S on t.schema_id = S.schema_id
   where I.type_desc!= 'HEAP' and t.name not in ('CompositeAccounts', 'CompositeContacts', 'CompositeHouseholds', 'PrimaryFlagRanking_Contact',
   'PrimaryFlagRanking_Account', 'PrimaryFlagRanking_Household', 'tmpPrimaryFlagRanking')
order by T.name, I.name;

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
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''AttributeGroup'' and I.Name = ''PK_AttributeGroup'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''AttributeGroup'', ''PK_AttributeGroup INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Attributes'' and I.Name = ''PK_Attributes'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Attributes'', ''PK_Attributes INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''PK_BusinessRuleID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''PK_BusinessRuleID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''UQ_BusinessRule1'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''UQ_BusinessRule1 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''BusinessRules'' and I.Name = ''UQ_BusinessRule2'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''UQ_BusinessRule2 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CD_DimCustomer'' and I.Name = ''PK_CD_Dimcustomer'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CD_DimCustomer'', ''PK_CD_Dimcustomer INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CleanDataOutput'' and I.Name = ''BUSINESS_CONTACT'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CleanDataOutput'', ''BUSINESS_CONTACT INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CleanDataOutput'' and I.Name = ''CDIO_Custom2_Phone'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CleanDataOutput'', ''CDIO_Custom2_Phone INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CleanDataOutput'' and I.Name = ''CDIO_Input_Custom2'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''CleanDataOutput'', ''CDIO_Input_Custom2 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CleanDataOutput'' and I.Name = ''IX_CleanDataOutput_Custom2'' and S.Name = ''archive'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''archive'' , ''CleanDataOutput'', ''IX_CleanDataOutput_Custom2 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''CompositeAttribute'' and I.Name = ''PK_CompositeAttribute'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''CompositeAttribute'', ''PK_CompositeAttribute INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IDX_mdmCompositeRecords_UpdatedDate_ACCTCONTACTIDs'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IDX_mdmCompositeRecords_UpdatedDate_ACCTCONTACTIDs INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_AddressFourIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_AddressFourIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_AddressOneIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_AddressOneIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_AddressPrimaryIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_AddressPrimaryIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_AddressThreeIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_AddressThreeIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_AddressTwoIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_AddressTwoIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_CompanyName'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_CompanyName INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_EmailOneIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_EmailOneIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_EmailPrimaryIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_EmailPrimaryIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_EmailTwoIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_EmailTwoIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhoneBusinessIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhoneBusinessIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhoneCellIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhoneCellIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhoneFaxIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhoneFaxIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhoneHomeIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhoneHomeIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhoneOtherIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhoneOtherIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''IX_CompositeRecords_PhonePrimaryIsCleanStatus'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''IX_CompositeRecords_PhonePrimaryIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''compositerecord'' and I.Name = ''PK_CompositeRecord'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''compositerecord'', ''PK_CompositeRecord INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AccountId'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AccountId INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AddressFour'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AddressFour INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_addressfourstatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_addressfourstatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AddressOne'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AddressOne INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_addressOnestatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_addressOnestatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AddressPrimary'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AddressPrimary INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_addressprimarystatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_addressprimarystatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AddressThree'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AddressThree INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_addressthreestatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_addressthreestatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_AddressTwo'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_AddressTwo INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_addresstwostatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_addresstwostatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_CompanyName'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_CompanyName INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_customer_matchkey'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_customer_matchkey INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_EmailOne'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_EmailOne INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_emailonestatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_emailonestatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_EmailPrimary'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_EmailPrimary INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_emailprimarystatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_emailprimarystatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_EmailTwo'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_EmailTwo INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_emailtwostatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_emailtwostatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_dimcustomer_IsBusiness'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_dimcustomer_IsBusiness INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_isdeleted'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_isdeleted INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_NameIsCleanStatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_NameIsCleanStatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhoneBusiness'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhoneBusiness INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phonebusinessstatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phonebusinessstatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhoneCell'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhoneCell INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phonecellstatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phonecellstatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhoneFax'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhoneFax INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phonefaxstatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phonefaxstatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhoneHome'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhoneHome INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phonehomestatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phonehomestatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhoneOther'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhoneOther INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phoneotherstatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phoneotherstatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''IX_DimCustomer_PhonePrimary'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''IX_DimCustomer_PhonePrimary INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''ix_dimcustomer_phoneprimarystatus'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''ix_dimcustomer_phoneprimarystatus INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''PK_DimcustomerID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''PK_DimcustomerID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomer'' and I.Name = ''UK_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomer'', ''UK_SSID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributes'' and I.Name = ''IXC_DimCustomerAttributes'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributes'', ''IXC_DimCustomerAttributes INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributes'' and I.Name = ''PK__DimCusto__ABC69402011C38EB'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributes'', ''PK__DimCusto__ABC69402011C38EB INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributeValues'' and I.Name = ''IX_DimCustomerAttrID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributeValues'', ''IX_DimCustomerAttrID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerAttributeValues'' and I.Name = ''PK_DimCustomerAttrValsID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerAttributeValues'', ''PK_DimCustomerAttrValsID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''IX_DimCustomerMatchkey_DimCustomerID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''IX_DimCustomerMatchkey_DimCustomerID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''IX_DimCustomerMatchkey_DimCustomerID_MatchkeyID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''IX_DimCustomerMatchkey_DimCustomerID_MatchkeyID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''IX_DimCustomerMatchkey_ID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''IX_DimCustomerMatchkey_ID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''IX_DimCustomerMatchkey_MatchkeyValue'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''IX_DimCustomerMatchkey_MatchkeyValue INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''DimCustomerMatchkey'' and I.Name = ''PK_DimCustomerMatchkey_ID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''DimCustomerMatchkey'', ''PK_DimCustomerMatchkey_ID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_DimCustomerSSBId__IsDeleted'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_DimCustomerSSBId__IsDeleted INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_dimcustomerssbid_contactid'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_dimcustomerssbid_contactid INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_dimcustomerssbid_ssid_contactid'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_dimcustomerssbid_ssid_contactid INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_DimCustSSBID_AcctPriFlag_AcctID_ContactID_PriFlag'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_DimCustSSBID_AcctPriFlag_AcctID_ContactID_PriFlag INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_DimCustSSBID_SourceSystem_ContactID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_DimCustSSBID_SourceSystem_ContactID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''IX_SSB_CRMSYSTEM_CONTACT_ID_ACCT_PRIMARY_FLAG'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''IX_SSB_CRMSYSTEM_CONTACT_ID_ACCT_PRIMARY_FLAG INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''PK_DimcustomerSSBID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''PK_DimcustomerSSBID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''dimcustomerssbid'' and I.Name = ''UK_DIMCUSTOMERSSBID_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''dimcustomerssbid'', ''UK_DIMCUSTOMERSSBID_SSID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Element'' and I.Name = ''UQ_Element1'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''UQ_Element1 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''PK_ForceMergeID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''PK_ForceMergeID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''UK_Loser'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''UK_Loser INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''ForceMergeIDs'' and I.Name = ''UK_Pair'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''ForceMergeIDs'', ''UK_Pair INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Incoming_Merge'' and I.Name = ''PK__Incoming__B61946E348DEC7E2'' and S.Name = ''api'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''api'' , ''Incoming_Merge'', ''PK__Incoming__B61946E348DEC7E2 INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Master_DimCustomer_Deltas'' and I.Name = ''IX_Master_DimCustomer_Deltas_DimCustomerId'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Master_DimCustomer_Deltas'', ''IX_Master_DimCustomer_Deltas_DimCustomerId INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Master_DimCustomer_Deltas'' and I.Name = ''IX_Master_DimCustomer_Deltas_InsertDate'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Master_DimCustomer_Deltas'', ''IX_Master_DimCustomer_Deltas_InsertDate INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Master_DimCustomer_Deltas'' and I.Name = ''IX_Master_DimCustomer_Deltas_ProcessedDate_DimCustomerId'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Master_DimCustomer_Deltas'', ''IX_Master_DimCustomer_Deltas_ProcessedDate_DimCustomerId INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyConfig'' and I.Name = ''IX_MatchkeyConfig_MatchkeyID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyConfig'', ''IX_MatchkeyConfig_MatchkeyID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyConfig'' and I.Name = ''PK_MatchkeyConfig_MatchkeyID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyConfig'', ''PK_MatchkeyConfig_MatchkeyID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyHash'' and I.Name = ''IX_MatchkeyHash_MatchkeyHashIdentifier'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyHash'', ''IX_MatchkeyHash_MatchkeyHashIdentifier INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''MatchkeyHash'' and I.Name = ''PK_MatchkeyHash_ID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''MatchkeyHash'', ''PK_MatchkeyHash_ID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''overrides'' and I.Name = ''ix_ElementID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''overrides'', ''ix_ElementID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''overrides'' and I.Name = ''pk_OverrideID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''overrides'', ''pk_OverrideID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''RecognitionAuditFailure'' and I.Name = ''IX_RecognitionAuditFailure_DimCustomerID_CreateDate'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''RecognitionAuditFailure'', ''IX_RecognitionAuditFailure_DimCustomerID_CreateDate INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Source_DimCustomer'' and I.Name = ''PK_Source_DimcustomerID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Source_DimCustomer'', ''PK_Source_DimcustomerID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''Source_DimCustomer'' and I.Name = ''UK_Source_SSID'' and S.Name = ''dbo'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''dbo'' , ''Source_DimCustomer'', ''UK_Source_SSID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''IDX_SSBIDHistory_AcctID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''IDX_SSBIDHistory_AcctID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''IDX_SSBIDHISTORY_ContactID_SSID_PriFlag'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''IDX_SSBIDHISTORY_ContactID_SSID_PriFlag INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''IDX_SSBIDHistory_HouseholdID'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''IDX_SSBIDHistory_HouseholdID INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''IDX_SSBIDHistory_Sourcesystem'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''IDX_SSBIDHistory_Sourcesystem INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''IDX_SSBIDHISTORY_SSID_SourceSystem_CreatedDate'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''IDX_SSBIDHISTORY_SSID_SourceSystem_CreatedDate INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''ixc_ssb_id_history'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''ixc_ssb_id_history INDEX Missing''
 End
 

If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'sys.tables as T inner join ' + @ClientDB + 'sys.indexes as I on T.[object_id] = I.[object_id]  
inner join ' + @ClientDB + 'sys.schemas S on t.schema_id = S.schema_id
where T.Name = ''SSB_ID_History'' and I.Name = ''PK_SSB_HISTORY_NEW'' and S.Name = ''mdm'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''SSB_ID_History'', ''PK_SSB_HISTORY_NEW INDEX Missing''
 End
 


 
 ' + CHAR(13) + CHAR(13)

 +'END' + Char(13)

--- Select @SQL;

EXEC sp_executesql @SQL;
GO
