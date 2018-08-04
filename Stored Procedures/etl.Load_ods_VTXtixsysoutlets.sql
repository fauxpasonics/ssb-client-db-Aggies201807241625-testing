SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixsysoutlets]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixsysoutlets),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixoutletid, tixoutletdesc, tixoutletinitdate, tixoutletlastupdwho, tixoutletlastupdwhen, tixoutletdisplayorder, tixoutletcontrol, tixoutletestablishmenttype, tixoutletestablishmentkey, tixoutlettype, tixoutletmerchid, tixoutletmaxticket, tixoutletonsaledate, tixoutletoffsaledate, tixoutletsubnetrootip, tixoutletsubnetrootmask, tixoutletzipcode, tixoutletautocloseouttime, client_id
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(25), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletautocloseouttime])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixoutletcontrol]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixoutletdesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixoutletdisplayorder])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletestablishmentkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixoutletestablishmenttype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixoutletid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletlastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixoutletlastupdwho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletmaxticket])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixoutletmerchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletoffsaledate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletonsaledate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletsubnetrootip])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixoutletsubnetrootmask])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixoutlettype]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixoutletzipcode]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixsysoutlets

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixoutletid)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixsysoutlets AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixoutletid = mySource.tixoutletid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixoutletid] = mySource.[tixoutletid]
     ,myTarget.[tixoutletdesc] = mySource.[tixoutletdesc]
     ,myTarget.[tixoutletinitdate] = mySource.[tixoutletinitdate]
     ,myTarget.[tixoutletlastupdwho] = mySource.[tixoutletlastupdwho]
     ,myTarget.[tixoutletlastupdwhen] = mySource.[tixoutletlastupdwhen]
     ,myTarget.[tixoutletdisplayorder] = mySource.[tixoutletdisplayorder]
     ,myTarget.[tixoutletcontrol] = mySource.[tixoutletcontrol]
     ,myTarget.[tixoutletestablishmenttype] = mySource.[tixoutletestablishmenttype]
     ,myTarget.[tixoutletestablishmentkey] = mySource.[tixoutletestablishmentkey]
     ,myTarget.[tixoutlettype] = mySource.[tixoutlettype]
     ,myTarget.[tixoutletmerchid] = mySource.[tixoutletmerchid]
     ,myTarget.[tixoutletmaxticket] = mySource.[tixoutletmaxticket]
     ,myTarget.[tixoutletonsaledate] = mySource.[tixoutletonsaledate]
     ,myTarget.[tixoutletoffsaledate] = mySource.[tixoutletoffsaledate]
     ,myTarget.[tixoutletsubnetrootip] = mySource.[tixoutletsubnetrootip]
     ,myTarget.[tixoutletsubnetrootmask] = mySource.[tixoutletsubnetrootmask]
     ,myTarget.[tixoutletzipcode] = mySource.[tixoutletzipcode]
     ,myTarget.[tixoutletautocloseouttime] = mySource.[tixoutletautocloseouttime]
     ,myTarget.[client_id] = mySource.[client_id]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixoutletid]
     ,[tixoutletdesc]
     ,[tixoutletinitdate]
     ,[tixoutletlastupdwho]
     ,[tixoutletlastupdwhen]
     ,[tixoutletdisplayorder]
     ,[tixoutletcontrol]
     ,[tixoutletestablishmenttype]
     ,[tixoutletestablishmentkey]
     ,[tixoutlettype]
     ,[tixoutletmerchid]
     ,[tixoutletmaxticket]
     ,[tixoutletonsaledate]
     ,[tixoutletoffsaledate]
     ,[tixoutletsubnetrootip]
     ,[tixoutletsubnetrootmask]
     ,[tixoutletzipcode]
     ,[tixoutletautocloseouttime]
     ,[client_id]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixoutletid]
     ,mySource.[tixoutletdesc]
     ,mySource.[tixoutletinitdate]
     ,mySource.[tixoutletlastupdwho]
     ,mySource.[tixoutletlastupdwhen]
     ,mySource.[tixoutletdisplayorder]
     ,mySource.[tixoutletcontrol]
     ,mySource.[tixoutletestablishmenttype]
     ,mySource.[tixoutletestablishmentkey]
     ,mySource.[tixoutlettype]
     ,mySource.[tixoutletmerchid]
     ,mySource.[tixoutletmaxticket]
     ,mySource.[tixoutletonsaledate]
     ,mySource.[tixoutletoffsaledate]
     ,mySource.[tixoutletsubnetrootip]
     ,mySource.[tixoutletsubnetrootmask]
     ,mySource.[tixoutletzipcode]
     ,mySource.[tixoutletautocloseouttime]
     ,mySource.[client_id]
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
