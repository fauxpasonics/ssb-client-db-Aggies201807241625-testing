SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [audit].[MDM_CLIENT_DATA] @clientdb varchar(50) 
as
/* USE THIS AGAINST MDM_CLIENT_TEMPLATE TO GENERATE CODE

use mdm_client_template



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
and not Exists(select * from ' + @ClientDB + 'mdm.businessrules where ruletype = ''NCOA Activation'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''BusinessRules'', ''NCOA Activation Rule Missing''
 End
 
 If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Primary Record'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Primary Record Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Default'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Default Element Missing''
 End
 

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Primary Address'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Primary Address Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Address One'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Address One Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Address Two'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Address Two Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Address Three'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Address Three Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Address Four'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Address Four Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Primary Email'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Primary Email''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Email One'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Email One Element Missing''
 End

  If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Email Two'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Email Two Element Missing''
 End

   If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Primary Phone'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Primary Phone Element Missing''
 End

   If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Phone Home'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Phone Home Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Phone Cell'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Phone Cell Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Phone Business'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Phone Business Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Phone Fax'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Phone Fax Element Missing''
 End


    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Phone Other''  and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Phone Other Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Company Name''  and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Company Name Element Missing''
 End


    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Name'' and ElementType = ''Standard'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Name Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Master Source VIP'' and ElementType = ''Master Source VIP'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Master Source VIP Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''NCOA Activation'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''NCOA Activation Element Missing''
 End

    If Exists(Select * from ' + @ClientDB + 'INFORMATION_SCHEMA.TABLES where table_name = ''Auditlog'' AND table_schema= ''mdm'') 
and not Exists(select * from ' + @ClientDB + 'mdm.Element where Element = ''Primary Address'' and ElementType = ''NCOA'')

 Begin 
 Insert into audit.mdm_System_Audit
 Select current_timestamp, ''' + Replace(@clientdb, '.', '') + ''', ''mdm'' , ''Element'', ''Primary Address Element for NCOA Missing''
 End


 ' + CHAR(13) + CHAR(13)

 +'END' + Char(13)

--- Select @SQL;

EXEC sp_executesql @SQL;
GO
