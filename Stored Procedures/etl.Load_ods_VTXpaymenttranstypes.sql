SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXpaymenttranstypes]
(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = NULL
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     svcETL
Date:     08/19/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXpaymenttranstypes),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, paymenttranstype, paymenttranstypedesc, paymenttypeprocessingmethod, paymenttypewarnonexchange, paymenttypefixedsystemvalue, paymenttypeactive, displayorder, paymenttypevalidationpattern, paymenttypecheckpattern
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(25), [displayorder])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [paymenttranstype])),'DBNULL_NUMBER') + ISNULL(RTRIM( [paymenttranstypedesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypeactive]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypecheckpattern]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypefixedsystemvalue]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypeprocessingmethod]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypevalidationpattern]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenttypewarnonexchange]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXpaymenttranstypes

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN
CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (paymenttranstype)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXpaymenttranstypes AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.paymenttranstype = mySource.paymenttranstype 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[paymenttranstype] = mySource.[paymenttranstype]
     ,myTarget.[paymenttranstypedesc] = mySource.[paymenttranstypedesc]
     ,myTarget.[paymenttypeprocessingmethod] = mySource.[paymenttypeprocessingmethod]
     ,myTarget.[paymenttypewarnonexchange] = mySource.[paymenttypewarnonexchange]
     ,myTarget.[paymenttypefixedsystemvalue] = mySource.[paymenttypefixedsystemvalue]
     ,myTarget.[paymenttypeactive] = mySource.[paymenttypeactive]
     ,myTarget.[displayorder] = mySource.[displayorder]
     ,myTarget.[paymenttypevalidationpattern] = mySource.[paymenttypevalidationpattern]
     ,myTarget.[paymenttypecheckpattern] = mySource.[paymenttypecheckpattern]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[paymenttranstype]
     ,[paymenttranstypedesc]
     ,[paymenttypeprocessingmethod]
     ,[paymenttypewarnonexchange]
     ,[paymenttypefixedsystemvalue]
     ,[paymenttypeactive]
     ,[displayorder]
     ,[paymenttypevalidationpattern]
     ,[paymenttypecheckpattern]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[paymenttranstype]
     ,mySource.[paymenttranstypedesc]
     ,mySource.[paymenttypeprocessingmethod]
     ,mySource.[paymenttypewarnonexchange]
     ,mySource.[paymenttypefixedsystemvalue]
     ,mySource.[paymenttypeactive]
     ,mySource.[displayorder]
     ,mySource.[paymenttypevalidationpattern]
     ,mySource.[paymenttypecheckpattern]
     )

WHEN NOT MATCHED BY SOURCE
THEN UPDATE SET
	myTarget.ETL_IsDeleted = 1,
	myTarget.ETL_DeletedDate = GETDATE()
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
	DECLARE @ErrorState INT = ERROR_STATE();
			
	PRINT @ErrorMessage
	EXEC etl.LogEventRecordDB @Batchid, 'Error', @ProcedureName, 'Merge Load', 'Merge Error', @ErrorMessage, @ExecutionId
	EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Procedure Processing', 'Complete', @ExecutionId

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Procedure Processing', 'Complete', @ExecutionId


END
GO
