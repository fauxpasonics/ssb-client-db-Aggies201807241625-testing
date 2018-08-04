SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [mdm].[CreateCompositeRecord] 
(
	@ClientDB VARCHAR(50),
	@CreateComposite INT
)
AS
BEGIN


/*[mdm].[CreateCompositeRecord] 
* created: 12/22/2014 - Kwyss - creates a composite (or "golden") record from all the account records for a contact
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL
*
*
*/

IF (SELECT @@VERSION) LIKE '%Azure%'   
BEGIN   
SET @ClientDB = ''   
END   
   
DECLARE @sql NVARCHAR(MAX) = ''


SET @SQL = ''
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @SQL
SET @SQL = ''

EXEC mdm.CreateCompositeRecord_AddPrimary @ClientDB;
----EXEC mdm.CreateCompositeRecord_UpdateFromCDIO @ClientDB;

IF @CreateComposite = 1
Begin
EXEC mdm.CreateCompositeRecord_CompleteRecord @ClientDB;
End


SET @SQL = ''
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @SQL

END
GO
