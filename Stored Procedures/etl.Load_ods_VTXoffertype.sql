SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXoffertype]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXoffertype),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, offertypeid, description, typeclass, eventoutletid, packageoutletid, nofeesoutletid, aetypeids
, HASHBYTES('sha2_256', ISNULL(RTRIM( [aetypeids]),'DBNULL_TEXT') + ISNULL(RTRIM( [description]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [eventoutletid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [nofeesoutletid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [offertypeid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [packageoutletid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [typeclass])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXoffertype

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (offertypeid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXoffertype AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.offertypeid = mySource.offertypeid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[offertypeid] = mySource.[offertypeid]
     ,myTarget.[description] = mySource.[description]
     ,myTarget.[typeclass] = mySource.[typeclass]
     ,myTarget.[eventoutletid] = mySource.[eventoutletid]
     ,myTarget.[packageoutletid] = mySource.[packageoutletid]
     ,myTarget.[nofeesoutletid] = mySource.[nofeesoutletid]
     ,myTarget.[aetypeids] = mySource.[aetypeids]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[offertypeid]
     ,[description]
     ,[typeclass]
     ,[eventoutletid]
     ,[packageoutletid]
     ,[nofeesoutletid]
     ,[aetypeids]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[offertypeid]
     ,mySource.[description]
     ,mySource.[typeclass]
     ,mySource.[eventoutletid]
     ,mySource.[packageoutletid]
     ,mySource.[nofeesoutletid]
     ,mySource.[aetypeids]
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
