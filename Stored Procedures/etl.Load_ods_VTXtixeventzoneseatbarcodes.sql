SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzoneseatbarcodes]
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
Date:     08/25/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixeventzoneseatbarcodes),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixseatbarcodeid, tixeventid, tixeventzoneid, tixseatgroupid, tixseatid, barcode, scandatetime, scanlocation, clustercode, gatenumber, validationresponse, initdate
, HASHBYTES('sha2_256', ISNULL(RTRIM( [barcode]),'DBNULL_TEXT') + ISNULL(RTRIM( [clustercode]),'DBNULL_TEXT') + ISNULL(RTRIM( [gatenumber]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [initdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(30), [scandatetime])),'DBNULL_DATETIME') + ISNULL(RTRIM( [scanlocation]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixeventid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventzoneid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatbarcodeid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [validationresponse])),'DBNULL_INT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixeventzoneseatbarcodes

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixseatbarcodeid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixeventzoneseatbarcodes AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixseatbarcodeid = mySource.tixseatbarcodeid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixseatbarcodeid] = mySource.[tixseatbarcodeid]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventzoneid] = mySource.[tixeventzoneid]
     ,myTarget.[tixseatgroupid] = mySource.[tixseatgroupid]
     ,myTarget.[tixseatid] = mySource.[tixseatid]
     ,myTarget.[barcode] = mySource.[barcode]
     ,myTarget.[scandatetime] = mySource.[scandatetime]
     ,myTarget.[scanlocation] = mySource.[scanlocation]
     ,myTarget.[clustercode] = mySource.[clustercode]
     ,myTarget.[gatenumber] = mySource.[gatenumber]
     ,myTarget.[validationresponse] = mySource.[validationresponse]
     ,myTarget.[initdate] = mySource.[initdate]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixseatbarcodeid]
     ,[tixeventid]
     ,[tixeventzoneid]
     ,[tixseatgroupid]
     ,[tixseatid]
     ,[barcode]
     ,[scandatetime]
     ,[scanlocation]
     ,[clustercode]
     ,[gatenumber]
     ,[validationresponse]
     ,[initdate]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixseatbarcodeid]
     ,mySource.[tixeventid]
     ,mySource.[tixeventzoneid]
     ,mySource.[tixseatgroupid]
     ,mySource.[tixseatid]
     ,mySource.[barcode]
     ,mySource.[scandatetime]
     ,mySource.[scanlocation]
     ,mySource.[clustercode]
     ,mySource.[gatenumber]
     ,mySource.[validationresponse]
     ,mySource.[initdate]
     )

WHEN NOT MATCHED BY SOURCE
THEN UPDATE SET
	myTarget.ETL_IsDeleted = 1,
	myTarget.ETL_DeletedDate = GETDATE()
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXtixeventzoneseatbarcodes
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXtixeventzoneseatbarcodes o
LEFT JOIN src.VTXtixeventzoneseatbarcodes_UK s ON s.tixseatbarcodeid = o.tixseatbarcodeid
WHERE s.tixseatbarcodeid IS NULL

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Delete Process', 'Soft Deletes Process', 'Complete', @ExecutionId

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
