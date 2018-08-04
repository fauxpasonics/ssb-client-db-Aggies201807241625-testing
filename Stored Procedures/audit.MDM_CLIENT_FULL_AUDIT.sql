SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [audit].[MDM_CLIENT_FULL_AUDIT] @Clientdb varchar(50) = null
as
IF isnull(@clientdb, '') = ''
Begin
DECLARE @command VARCHAR(4000)

SELECT @command = 'Exec Audit.MDM_CLIENT_TABLES @Clientdb = [?];
Exec Audit.MDM_CLIENT_INDEXES @Clientdb = [?];
Exec Audit.MDM_CLIENT_CONSTRAINTS_TRIGGERS @Clientdb =  [?];
Exec Audit.MDM_CLIENT_Data @Clientdb =  [?]'
 EXEC sys.sp_MSforeachdb @command

 Select * from audit.MDM_SYSTEM_Audit where cast(auditdate as date)= cast(getdate() as date)  order by clientdb, auditdate;

 END

 Else 
 BEGIN

Exec Audit.MDM_CLIENT_TABLES @Clientdb;
Exec Audit.MDM_CLIENT_INDEXES @Clientdb;
Exec Audit.MDM_CLIENT_CONSTRAINTS_TRIGGERS @Clientdb;
Exec Audit.MDM_CLIENT_Data @Clientdb

Select * from audit.MDM_SYSTEM_Audit where clientdb = @clientDB and cast(auditdate as date)= cast(getdate() as date);

END
GO
