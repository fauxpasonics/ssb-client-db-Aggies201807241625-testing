SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[Load_ods_VTXac_location]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXac_location),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, locationid, description, location, server, email, active, lastupdated, current_status, suite_lock_enabled, remotepollenabled
, HASHBYTES('sha2_256', ISNULL(RTRIM( [active]),'DBNULL_TEXT') + ISNULL(RTRIM( [current_status]),'DBNULL_TEXT') + ISNULL(RTRIM( [description]),'DBNULL_TEXT') + ISNULL(RTRIM( [email]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [lastupdated])),'DBNULL_DATETIME') + ISNULL(RTRIM( [location]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [locationid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [remotepollenabled])),'DBNULL_NUMBER') + ISNULL(RTRIM( [server]),'DBNULL_TEXT') + ISNULL(RTRIM( [suite_lock_enabled]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXac_location

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN	
	CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (locationid)

	EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END	

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXac_location AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.locationid = mySource.locationid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[locationid] = mySource.[locationid]
     ,myTarget.[description] = mySource.[description]
     ,myTarget.[location] = mySource.[location]
     ,myTarget.[server] = mySource.[server]
     ,myTarget.[email] = mySource.[email]
     ,myTarget.[active] = mySource.[active]
     ,myTarget.[lastupdated] = mySource.[lastupdated]
     ,myTarget.[current_status] = mySource.[current_status]
     ,myTarget.[suite_lock_enabled] = mySource.[suite_lock_enabled]
     ,myTarget.[remotepollenabled] = mySource.[remotepollenabled]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[locationid]
     ,[description]
     ,[location]
     ,[server]
     ,[email]
     ,[active]
     ,[lastupdated]
     ,[current_status]
     ,[suite_lock_enabled]
     ,[remotepollenabled]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[locationid]
     ,mySource.[description]
     ,mySource.[location]
     ,mySource.[server]
     ,mySource.[email]
     ,mySource.[active]
     ,mySource.[lastupdated]
     ,mySource.[current_status]
     ,mySource.[suite_lock_enabled]
     ,mySource.[remotepollenabled]
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
