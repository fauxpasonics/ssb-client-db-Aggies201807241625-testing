SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [apietl].[ApiEtlTruncateStagingTables]
	@Schema       NVARCHAR(200),
    @TablePrefix  NVARCHAR(60)

AS
BEGIN
   
    SET NOCOUNT ON
	
	DECLARE @cmd VARCHAR(MAX)
	
	DECLARE cmds CURSOR FOR 
	SELECT CONCAT('TRUNCATE TABLE [', @Schema, '].[', Table_Name, '];')
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME LIKE CONCAT(@TablePrefix, '_%')
	AND TABLE_SCHEMA = @Schema
	AND TABLE_NAME NOT LIKE '%_audit_trail_source_object_log'

	OPEN cmds
	WHILE 1=1
	BEGIN
		FETCH cmds INTO @cmd
		IF @@fetch_status != 0 BREAK
		EXEC(@cmd)
	END
	CLOSE cmds;
	DEALLOCATE cmds

END
GO
