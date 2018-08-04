SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [etl].[SSBMergeGenerator_v2]
     @Target NVARCHAR(256),
     @Source NVARCHAR(256),
     @Target_Key NVARCHAR(256),
     @Source_Key NVARCHAR(256),
     @Proc_Name NVARCHAR(256)
AS
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     ssbcloud\dschaller
Date:     01/19/2015
Comments: This sproc creates merge logic dynamically based on values passed into sproc.
*************************************************************************************/
--Variables that will need to be passed into the sproc
--DECLARE
--     @Target NVARCHAR(256),
--     @Source NVARCHAR(256),
--     @Target_Key NVARCHAR(256),
--     @Source_Key NVARCHAR(256),
--     @Proc_Name NVARCHAR(256)

--SET @Target = 'ods.TI_PatronMDM_Athletics'
--SET @Source = 'etl.vw_src_TI_PatronMDM_Athletics'
--SET @Target_Key = 'Patron'
--SET @Source_Key = 'Patron'
--SET @Proc_Name = 'ETL.ods_Load_TI_PatronMDM_Athletics'

--Variables that will stay in sproc contents
DECLARE
     @SQL NVARCHAR(MAX)

DECLARE
	 @ColString NVARCHAR(MAX)
SET
	 @ColString = 
	 ( SELECT STUFF ((
                    SELECT ', ' + name 
                    FROM sys.columns
                    WHERE object_id = OBJECT_ID(@Source) --AND name NOT LIKE 'ETL%'
					order by column_id		
                    FOR XML PATH('')), 1, 1, '') 
	 )




DECLARE
	 @JoinString NVARCHAR(MAX)
SET @JoinString = 
	(
		SELECT STUFF ((
        SELECT ' and ' + match  
        FROM
		(
			select a.id, 'myTarget.' + a.Item + ' = mySource.' + b.Item as match
			from dbo.Split_DS (@Target_Key, ',') a inner join
			dbo.Split_DS (@Source_Key, ',') b on a.ID = b.ID
		)	x	
		order by id		
        FOR XML PATH('')), 1, 5, '')
	)

	DECLARE @SqlStringMax AS NVARCHAR(MAX) = ''
	DECLARE @SchemaName  AS NVARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@Source, '.' ,1)
	DECLARE @Table AS NVARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@Source, '.' ,2)

	
	SELECT @SqlStringMax = @sqlStringMax + 'OR ISNULL(mySource.' + COLUMN_NAME + ','''') <> ' + 'ISNULL(myTarget.' + COLUMN_NAME + ','''') '
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @Table
	AND ISNULL(CHARACTER_MAXIMUM_LENGTH, 0) < 0
	AND COLUMN_NAME NOT IN ('ETL_ID', 'ETL_CreatedDate', 'ETL_UpdatedDate', 'ETL_IsDeleted', 'ETL_DeletedDate', 'ETL_SourceFileName')

DECLARE @DeltaHashKeyString NVARCHAR(max)
SET @DeltaHashKeyString = 
(SELECT DeltaHashKeyString FROM dbo.fnSSBHashFieldSyntax_VTX('src',RIGHT(@Source,LEN(@Source)-4),'ETL_ID', 'ETL_CreatedDate', 'ETL_UpdatedDate', 'ETL_IsDeleted', 'ETL_DeletedDate', 'ETL_SourceFileName'))
	
SELECT @SQL = 
'CREATE PROCEDURE ' + @Proc_Name + CHAR(10) + 
'(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = null
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     ' + CURRENT_USER + '
Date:     ' + CONVERT(NVARCHAR, GETDATE(), 101) + '
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + ''.'' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM ' + @Source + '),''0'');	
DECLARE @SrcDataSize NVARCHAR(255) = ''0''

BEGIN TRY 

PRINT ''Execution Id: '' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''PROCEDURE Processing'', ''START'', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''Src ROW COUNT'', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''Src DataSize'', @SrcDataSize, @ExecutionId

SELECT ' + @ColString + '
, ' + @DeltaHashKeyString + '
INTO #SrcData
FROM ' + @Source + '

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''Src TABLE Setup'', ''Temp TABLE Loaded'', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (' + @Source_Key + ')

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''Src TABLE Setup'', ''Temp TABLE Indexes Created'', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''MERGE Load'', ''MERGE Statement Execution'', ''START'', @ExecutionId

MERGE ' + @Target + ' AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON ' + @JoinString + ' 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      ' +
          STUFF ((
                    SELECT ',myTarget.[' + name + '] = mySource.[' + name + ']' + CHAR(10) + '     '
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target) 
						AND name NOT IN ('ETL_ID', 'ETL_CreatedDate', 'ETL_IsDeleted', 'ETL_DeletedDate', 'ETL_SourceFileName')
						ORDER BY column_id
                    FOR XML PATH('')), 1, 1, '')  +
'
WHEN NOT MATCHED BY TARGET
THEN INSERT
     (' + 
          STUFF ((
                    SELECT ',[' + name + ']' + CHAR(10) + '     '
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target)
						AND NAME NOT IN ('ETL_ID', 'ETL_UpdatedDate', 'ETL_IsDeleted', 'ETL_DeletedDate', 'ETL_SourceFileName')
					ORDER BY column_id
                    FOR XML PATH('')), 1, 1, '') + ')
VALUES
     (' +
          STUFF ((
                    SELECT ',mySource.[' + name + ']' + CHAR(10) + '     '
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target)
						AND NAME NOT IN ('ETL_ID', 'ETL_UpdatedDate', 'ETL_IsDeleted', 'ETL_DeletedDate', 'ETL_SourceFileName')
					ORDER BY column_id
                    FOR XML PATH('')), 1, 1, '') + ')
;

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''Merge Load'', ''Merge Statement Execution'', ''Complete'', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
	DECLARE @ErrorState INT = ERROR_STATE();
			
	PRINT @ErrorMessage
	EXEC etl.LogEventRecordDB @Batchid, ''Error'', @ProcedureName, ''Merge Load'', ''Merge Error'', @ErrorMessage, @ExecutionId
	EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''Merge Load'', ''Procedure Processing'', ''Complete'', @ExecutionId

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH

EXEC etl.LogEventRecordDB @Batchid, ''Info'', @ProcedureName, ''Merge Load'', ''Procedure Processing'', ''Complete'', @ExecutionId


END

'

SET @SQL = (SELECT REPLACE(@SQL,'mySource.[ETL_UpdatedDate]','mySource.[ETL_CreatedDate]'))


EXEC sp_executesql @SQL
GO
