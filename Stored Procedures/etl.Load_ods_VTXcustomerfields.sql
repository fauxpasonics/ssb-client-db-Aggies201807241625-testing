SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_ods_VTXcustomerfields]
(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = null
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     svcETL
Date:     06/17/2016
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXcustomerfields),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, id, name, logchanges, customerfieldlistid, required, active, fieldtype, storagetype, readonly, visible, maxlength
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(10), [active])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [customerfieldlistid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [fieldtype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [logchanges])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [maxlength])),'DBNULL_NUMBER') + ISNULL(RTRIM( [name]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [readonly])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [required])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [storagetype])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [visible])),'DBNULL_INT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXcustomerfields

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXcustomerfields AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[name] = mySource.[name]
     ,myTarget.[logchanges] = mySource.[logchanges]
     ,myTarget.[customerfieldlistid] = mySource.[customerfieldlistid]
     ,myTarget.[required] = mySource.[required]
     ,myTarget.[active] = mySource.[active]
     ,myTarget.[fieldtype] = mySource.[fieldtype]
     ,myTarget.[storagetype] = mySource.[storagetype]
     ,myTarget.[readonly] = mySource.[readonly]
     ,myTarget.[visible] = mySource.[visible]
     ,myTarget.[maxlength] = mySource.[maxlength]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
     ,[ETL_DeltaHashKey]
     ,[id]
     ,[name]
     ,[logchanges]
     ,[customerfieldlistid]
     ,[required]
     ,[active]
     ,[fieldtype]
     ,[storagetype]
     ,[readonly]
     ,[visible]
     ,[maxlength]
     )
VALUES
     (mySource.[ETL_CreatedDate]
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[id]
     ,mySource.[name]
     ,mySource.[logchanges]
     ,mySource.[customerfieldlistid]
     ,mySource.[required]
     ,mySource.[active]
     ,mySource.[fieldtype]
     ,mySource.[storagetype]
     ,mySource.[readonly]
     ,mySource.[visible]
     ,mySource.[maxlength]
     )
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
