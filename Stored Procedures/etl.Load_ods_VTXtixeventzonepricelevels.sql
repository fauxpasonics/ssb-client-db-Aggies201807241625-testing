SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzonepricelevels]
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
Date:     08/20/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixeventzonepricelevels),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixeventid, tixeventzoneid, tixevtznpricelevelcode, tixevtznpriceleveldesc, tixevtznpricelevelinitdate, tixevtznpricelevellastupdwhen, tixevtznpricelevellastupdwho, tixevtznpricelevelcolors, tixevtznpriceleveltype, tixevtznpricelevelmodatnextlvl, tixevtznpriceleveldispord, tixevtznpricelevelprintdesc
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(25), [tixeventid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixeventzoneid]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznpricelevelcode])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixevtznpricelevelcolors]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznpriceleveldesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznpriceleveldispord]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznpricelevelinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznpricelevellastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixevtznpricelevellastupdwho]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznpricelevelmodatnextlvl]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznpricelevelprintdesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznpriceleveltype]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixeventzonepricelevels

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid, tixeventzoneid, tixevtznpricelevelcode)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixeventzonepricelevels AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixeventid = mySource.tixeventid AND myTarget.tixeventzoneid = mySource.tixeventzoneid AND myTarget.tixevtznpricelevelcode = mySource.tixevtznpricelevelcode 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventzoneid] = mySource.[tixeventzoneid]
     ,myTarget.[tixevtznpricelevelcode] = mySource.[tixevtznpricelevelcode]
     ,myTarget.[tixevtznpriceleveldesc] = mySource.[tixevtznpriceleveldesc]
     ,myTarget.[tixevtznpricelevelinitdate] = mySource.[tixevtznpricelevelinitdate]
     ,myTarget.[tixevtznpricelevellastupdwhen] = mySource.[tixevtznpricelevellastupdwhen]
     ,myTarget.[tixevtznpricelevellastupdwho] = mySource.[tixevtznpricelevellastupdwho]
     ,myTarget.[tixevtznpricelevelcolors] = mySource.[tixevtznpricelevelcolors]
     ,myTarget.[tixevtznpriceleveltype] = mySource.[tixevtznpriceleveltype]
     ,myTarget.[tixevtznpricelevelmodatnextlvl] = mySource.[tixevtznpricelevelmodatnextlvl]
     ,myTarget.[tixevtznpriceleveldispord] = mySource.[tixevtznpriceleveldispord]
     ,myTarget.[tixevtznpricelevelprintdesc] = mySource.[tixevtznpricelevelprintdesc]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixeventid]
     ,[tixeventzoneid]
     ,[tixevtznpricelevelcode]
     ,[tixevtznpriceleveldesc]
     ,[tixevtznpricelevelinitdate]
     ,[tixevtznpricelevellastupdwhen]
     ,[tixevtznpricelevellastupdwho]
     ,[tixevtznpricelevelcolors]
     ,[tixevtznpriceleveltype]
     ,[tixevtznpricelevelmodatnextlvl]
     ,[tixevtznpriceleveldispord]
     ,[tixevtznpricelevelprintdesc]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixeventid]
     ,mySource.[tixeventzoneid]
     ,mySource.[tixevtznpricelevelcode]
     ,mySource.[tixevtznpriceleveldesc]
     ,mySource.[tixevtznpricelevelinitdate]
     ,mySource.[tixevtznpricelevellastupdwhen]
     ,mySource.[tixevtznpricelevellastupdwho]
     ,mySource.[tixevtznpricelevelcolors]
     ,mySource.[tixevtznpriceleveltype]
     ,mySource.[tixevtznpricelevelmodatnextlvl]
     ,mySource.[tixevtznpriceleveldispord]
     ,mySource.[tixevtznpricelevelprintdesc]
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
