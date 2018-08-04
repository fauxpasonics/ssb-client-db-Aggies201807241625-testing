SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[SSB_ProcessStandardMerge_RS]
(
	@BatchId NVARCHAR(50),
	@Target VARCHAR(256),
	@Source VARCHAR(256),
	@BusinessKey VARCHAR(256),
	@Options NVARCHAR(MAX)
)

AS
BEGIN

/**************************************Comments***************************************
**************************************************************************************
Mod #:		1
Name:		ssbcloud\zfrick
Date:		04/17/2016
Comments:	Dynamically generates and executes standard SSB Merge from source table to destination table.

*************************************************************************************/

DECLARE
     @SQL VARCHAR(MAX) = '',
	 @SQL2 VARCHAR(MAX) = '',
	 @SQL3 VARCHAR(MAX) = '',
	 @SQL4 VARCHAR(MAX) = '',
	 @SQL5 VARCHAR(MAX) = ''

DECLARE @IsFullLoad bit = 0
DECLARE @IsDeleteEnabled bit = 0
DECLARE @OptionsXML XML = TRY_CAST(@Options AS XML)

SELECT @IsFullLoad = CAST(CASE WHEN t.x.value('IsFullLoad[1]','nvarchar(50)') = 'true' THEN 1 ELSE 0 END AS BIT)
, @IsDeleteEnabled = CAST(CASE WHEN t.x.value('IsDeleteEnabled[1]','nvarchar(50)') = 'true' THEN 1 ELSE 0 END AS BIT)
FROM @OptionsXML.nodes('options') t(x)

DECLARE
	 @ColString VARCHAR(MAX)
SET
	 @ColString = 
	 ( SELECT STUFF ((
                    SELECT ', [' + name + ']'
                    FROM sys.columns
                    WHERE object_id = OBJECT_ID(@Source) and name not LIKE ('ETL_Sync_%')
					ORDER BY column_id		
                    FOR XML PATH('')), 1, 1, '') 
	 )

	 DECLARE
	 @ColStringWithAlias VARCHAR(MAX)
SET
	 @ColStringWithAlias = 
	 ( SELECT STUFF ((
                    SELECT ', s.[' + name + ']'
                    FROM sys.columns
                    WHERE object_id = OBJECT_ID(@Source) and name not LIKE ('ETL_Sync_%')
					ORDER BY column_id		
                    FOR XML PATH('')), 1, 1, '') 
	 )

DECLARE
	 @HashSyntax VARCHAR(MAX)

DECLARE	 @HashTbl TABLE (HashSyntax VARCHAR(MAX))
INSERT @HashTbl (HashSyntax)
EXEC  etl.SSB_MergeHashFieldSyntax @TableName = @Source, @ColumnList = 'ETL_Sync_Id'

SET @HashSyntax = (SELECT TOP 1 HashSyntax FROM @HashTbl)

DECLARE
	 @JoinString varchar(MAX)
SET @JoinString = 
	(
		SELECT STUFF ((
        SELECT ' and ' + match  
        FROM
		(
			select 'myTarget.' + a.Item + ' = mySource.' + a.Item as match
			from dbo.Split (@BusinessKey, ',') a 
		)	x	
        FOR XML PATH('')), 1, 5, '')
	)

	DECLARE @SqlStringMax AS VARCHAR(MAX) = ''
	DECLARE @SchemaName  AS VARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@Source, '.' ,1)
	DECLARE @Table AS VARCHAR(255) = [dbo].[fnGetValueFromDelimitedString](@Source, '.' ,2)

	
	SELECT @SqlStringMax = @sqlStringMax + 'OR ISNULL(mySource.' + COLUMN_NAME + ','''') <> ' + 'ISNULL(myTarget.' + COLUMN_NAME + ','''') '
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @Table
	AND ISNULL(CHARACTER_MAXIMUM_LENGTH, 0) < 0
--	AND COLUMN_NAME NOT IN ('ETL_ID')	DCH 2016-01-14

	
SELECT @SQL = 
'
DECLARE @RunTime DATETIME = GETDATE()

DECLARE @BatchId NVARCHAR(50) = ''' + @BatchId + ''';
DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @EventSource nvarchar(255) = ''ProcessStandardMerge_' + @Target + '''
DECLARE @SrcRowCount int = ISNULL((SELECT CONVERT(varchar, COUNT(*)) FROM ' + @Source + '),''0'');	
DECLARE @SrcDataSize NVARCHAR(255) = ''0'';
DECLARE @Client NVARCHAR(255) = (SELECT ISNULL(etl.fnGetClientSetting(''ClientName''), DB_NAME()));
DECLARE @BusinessKey nvarchar(255) = ''' + @BusinessKey + '''

/*Load Options into a temp table*/
--SELECT Col1 AS OptionKey, Col2 as OptionValue INTO #Options FROM [dbo].[SplitMultiColumn](@Options, ''='', '';'')

BEGIN TRY 

PRINT ''Execution Id: '' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Procedure Processing'', ''Start'', @ExecutionId
EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Src Row Count'', @SrcRowCount, @ExecutionId
EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Src DataSize'', @SrcDataSize, @ExecutionId

' +
CASE 
	WHEN @IsDeleteEnabled = 1 AND @IsFullLoad = 1 AND ISNULL(@BusinessKey,'') <> '' THEN '
DELETE myTarget
FROM ' + @Target + ' myTarget
LEFT OUTER JOIN (
	SELECT CAST(1 AS BIT) ForceExists, ' + @BusinessKey + '
	FROM ' + @Source + '
) mySource ON ' + @JoinString + '
WHERE mySource.ForceExists IS null
' ELSE '' END + 

CASE WHEN ISNULL(@BusinessKey, '') <> '' THEN '
IF EXISTS (
	SELECT COUNT(*)
	FROM ' + @Source + '
	GROUP BY ' + @BusinessKey + '
	HAVING COUNT(*) > 1
)
BEGIN 
	DELETE a
	FROM ' + @Source + ' a
	INNER JOIN (
		SELECT ETL_Sync_Id
		, ROW_NUMBER() OVER(PARTITION BY ' + @BusinessKey + ' ORDER BY ETL_Sync_Id) RowRank
		FROM ' + @Source + '
	) b ON a.ETL_Sync_Id = b.ETL_Sync_Id
	WHERE b.RowRank > 1
END
' ELSE '' END + '

SELECT ROW_NUMBER() OVER(ORDER BY ETL_Sync_Id) RowIndex
, * 
INTO #data
FROM ' + @Source + '

CREATE NONCLUSTERED INDEX IDX_RowIndex ON #data (RowIndex)

DECLARE @RecordCount INT = (SELECT COUNT(*) FROM #data)
DECLARE @StartIndex INT = 1, @PageCount INT = 1000000

' + CASE WHEN ISNULL(@BusinessKey, '') = '' then 'SET @PageCount = 1000000000' ELSE '' END + '

DECLARE @EndIndex INT = (@StartIndex + @PageCount - 1)

WHILE @StartIndex <= @RecordCount
BEGIN

SELECT CAST(NULL AS BINARY(32)) ETL_Sync_DeltaHashKey
, ' + @ColString + '
INTO #SrcData
FROM #data
WHERE RowIndex BETWEEN @StartIndex AND @EndIndex

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Src Table Setup'', ''Temp Table Loaded'', @ExecutionId
'
SELECT @SQL2 = '

UPDATE #SrcData
SET ETL_Sync_DeltaHashKey = ' + @HashSyntax + '

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Src Table Setup'', ''ETL_Sync_DeltaHashKey Set'', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_ETL_Sync_DeltaHashKey ON #SrcData (ETL_Sync_DeltaHashKey)

' + CASE WHEN ISNULL(@BusinessKey, '') = '' THEN '' ELSE 'CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (' + @BusinessKey + ')' END + '

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Src Table Setup'', ''Temp Table Indexes Created'', @ExecutionId

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Merge Statement Execution'', ''Start'', @ExecutionId
';

-------------------------------------------------------------------------------------------------

if ( isnull(@BusinessKey,'') = '' )
begin

SET @SQL3 = '

' +
CASE 
	WHEN @IsDeleteEnabled = 1 AND @IsFullLoad = 1 THEN '
DELETE t
FROM ' + @Target + ' t
LEFT OUTER JOIN #SrcData s ON s.ETL_Sync_DeltaHashKey = t.ETL_Sync_DeltaHashKey
WHERE s.ETL_Sync_DeltaHashKey IS null
' ELSE '' END + '


INSERT INTO ' + @Target + '
( 
	[ETL_Sync_UpdatedDate]
	, [ETL_Sync_DeltaHashKey]
	, ' + ISNULL(@ColString,'') + '
	 
)
SELECT 
		GETDATE() --[ETL_Sync_UpdatedDate]
		, s.[ETL_Sync_DeltaHashKey]
		, ' + ISNULL(@ColStringWithAlias,'') + '
FROM #SrcData s
LEFT OUTER JOIN ' + @Target + ' t ON s.ETL_Sync_DeltaHashKey = t.ETL_Sync_DeltaHashKey
WHERE t.ETL_Sync_DeltaHashKey IS null	
'
END
ELSE 
BEGIN

SET @SQL3 = '

MERGE ' + @Target + ' AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON ' + @JoinString + '

WHEN MATCHED AND (
     ISNULL(mySource.ETL_Sync_DeltaHashKey,-1) <> ISNULL(myTarget.ETL_Sync_DeltaHashKey, -1)
	 ' + @SqlStringMax + '
)
THEN UPDATE SET
      myTarget.[ETL_Sync_UpdatedDate] = getdate()
	  ' 
	  +
          STUFF ((
                    SELECT ',myTarget.[' + name + '] = mySource.[' + name + ']' + CHAR(10) + '     '
                           
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target)
                        AND name NOT IN ('ETL_Sync_UpdatedDate')
						ORDER BY column_id
                    FOR XML PATH('')), 1, 0, '')  +
'

';

-------------------------------------------------------------------------------------------------

SET @SQL4 = 
'WHEN NOT MATCHED BY Target
THEN INSERT
     (
	 [ETL_Sync_UpdatedDate]
	 ' + 
          STUFF ((
                    SELECT ',[' + name + ']' + CHAR(10) + '     '
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target)
                        AND name NOT IN ('ETL_Sync_UpdatedDate')
					ORDER BY column_id
                    FOR XML PATH('')), 1, 0, '') + ')
VALUES
     (
	 getdate() --[ETL_Sync_UpdatedDate]
	 ' +
          STUFF ((
                    SELECT ',mySource.[' + name + ']' + CHAR(10) + '     '
						FROM sys.columns
						WHERE object_id = OBJECT_ID(@Target)
                        AND name NOT IN ('ETL_Sync_UpdatedDate')
					ORDER BY column_id
                    FOR XML PATH('')), 1, 0, '') + ')
;'

END

SET @SQL5 = '

DROP TABLE #SrcData

SET @StartIndex = @EndIndex + 1
SET @EndIndex = @EndIndex + @PageCount

--EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Merge Statement Execution'', ''Complete'', @ExecutionId

END --End Of Paging Loop


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
	DECLARE @ErrorState INT = ERROR_STATE();
			
	PRINT @ErrorMessage
	EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Error'', @EventSource, ''Merge Load'', ''Merge Error'', @ErrorMessage, @ExecutionId
	EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Procedure Processing'', ''Complete'', @ExecutionId

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH

EXEC etl.CreateEventLogRecord @Batchid, @Client, ''Info'', @EventSource, ''Merge Load'', ''Procedure Processing'', ''Complete'', @ExecutionId
'


PRINT @SQL
PRINT @SQL2 
PRINT @SQL3
PRINT @SQL4
PRINT @SQL5

DECLARE @Full_SQL VARCHAR(MAX) = @SQL + @SQL2 + @SQL3 + @SQL4 + @SQL5;


EXEC (@Full_SQL)

END
GO
