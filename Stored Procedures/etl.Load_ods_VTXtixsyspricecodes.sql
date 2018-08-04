SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixsyspricecodes]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixsyspricecodes),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixsyspricecodecode, tixsyspricecodedesc, tixsyspricecodeinitdate, tixsyspricecodelastupdwhen, tixsyspricecodelastupdatewho, tixsyspricecodecolors, tixsyspricecodetype, tixsyspricecodemodatnextlevel, tixsyspricecodetextdesc, tixsyspricecodedispord, tixsyspricecodesalesmodes, tixsyscompseatstatuscode, tixsyspricecodealtprintdesc, printable, is_comp, tixsyspricecodepaypri, tixsyspricecodepricingmode, restrict_transfer, restrict_resale, waive_first_seller_fee, stadis_active, hidden_status, restrict_transfer_to_fs
, HASHBYTES('sha2_256', ISNULL(RTRIM( [hidden_status]),'DBNULL_TEXT') + ISNULL(RTRIM( [is_comp]),'DBNULL_TEXT') + ISNULL(RTRIM( [printable]),'DBNULL_TEXT') + ISNULL(RTRIM( [restrict_resale]),'DBNULL_TEXT') + ISNULL(RTRIM( [restrict_transfer]),'DBNULL_TEXT') + ISNULL(RTRIM( [restrict_transfer_to_fs]),'DBNULL_TEXT') + ISNULL(RTRIM( [stadis_active]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyscompseatstatuscode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspricecodealtprintdesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricecodecode])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixsyspricecodecolors]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspricecodedesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspricecodedispord]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricecodeinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixsyspricecodelastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricecodelastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixsyspricecodemodatnextlevel]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixsyspricecodepaypri])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixsyspricecodepricingmode])),'DBNULL_INT') + ISNULL(RTRIM( [tixsyspricecodesalesmodes]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspricecodetextdesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricecodetype])),'DBNULL_NUMBER') + ISNULL(RTRIM( [waive_first_seller_fee]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixsyspricecodes

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixsyspricecodecode)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixsyspricecodes AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixsyspricecodecode = mySource.tixsyspricecodecode 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixsyspricecodecode] = mySource.[tixsyspricecodecode]
     ,myTarget.[tixsyspricecodedesc] = mySource.[tixsyspricecodedesc]
     ,myTarget.[tixsyspricecodeinitdate] = mySource.[tixsyspricecodeinitdate]
     ,myTarget.[tixsyspricecodelastupdwhen] = mySource.[tixsyspricecodelastupdwhen]
     ,myTarget.[tixsyspricecodelastupdatewho] = mySource.[tixsyspricecodelastupdatewho]
     ,myTarget.[tixsyspricecodecolors] = mySource.[tixsyspricecodecolors]
     ,myTarget.[tixsyspricecodetype] = mySource.[tixsyspricecodetype]
     ,myTarget.[tixsyspricecodemodatnextlevel] = mySource.[tixsyspricecodemodatnextlevel]
     ,myTarget.[tixsyspricecodetextdesc] = mySource.[tixsyspricecodetextdesc]
     ,myTarget.[tixsyspricecodedispord] = mySource.[tixsyspricecodedispord]
     ,myTarget.[tixsyspricecodesalesmodes] = mySource.[tixsyspricecodesalesmodes]
     ,myTarget.[tixsyscompseatstatuscode] = mySource.[tixsyscompseatstatuscode]
     ,myTarget.[tixsyspricecodealtprintdesc] = mySource.[tixsyspricecodealtprintdesc]
     ,myTarget.[printable] = mySource.[printable]
     ,myTarget.[is_comp] = mySource.[is_comp]
     ,myTarget.[tixsyspricecodepaypri] = mySource.[tixsyspricecodepaypri]
     ,myTarget.[tixsyspricecodepricingmode] = mySource.[tixsyspricecodepricingmode]
     ,myTarget.[restrict_transfer] = mySource.[restrict_transfer]
     ,myTarget.[restrict_resale] = mySource.[restrict_resale]
     ,myTarget.[waive_first_seller_fee] = mySource.[waive_first_seller_fee]
     ,myTarget.[stadis_active] = mySource.[stadis_active]
     ,myTarget.[hidden_status] = mySource.[hidden_status]
     ,myTarget.[restrict_transfer_to_fs] = mySource.[restrict_transfer_to_fs]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixsyspricecodecode]
     ,[tixsyspricecodedesc]
     ,[tixsyspricecodeinitdate]
     ,[tixsyspricecodelastupdwhen]
     ,[tixsyspricecodelastupdatewho]
     ,[tixsyspricecodecolors]
     ,[tixsyspricecodetype]
     ,[tixsyspricecodemodatnextlevel]
     ,[tixsyspricecodetextdesc]
     ,[tixsyspricecodedispord]
     ,[tixsyspricecodesalesmodes]
     ,[tixsyscompseatstatuscode]
     ,[tixsyspricecodealtprintdesc]
     ,[printable]
     ,[is_comp]
     ,[tixsyspricecodepaypri]
     ,[tixsyspricecodepricingmode]
     ,[restrict_transfer]
     ,[restrict_resale]
     ,[waive_first_seller_fee]
     ,[stadis_active]
     ,[hidden_status]
     ,[restrict_transfer_to_fs]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixsyspricecodecode]
     ,mySource.[tixsyspricecodedesc]
     ,mySource.[tixsyspricecodeinitdate]
     ,mySource.[tixsyspricecodelastupdwhen]
     ,mySource.[tixsyspricecodelastupdatewho]
     ,mySource.[tixsyspricecodecolors]
     ,mySource.[tixsyspricecodetype]
     ,mySource.[tixsyspricecodemodatnextlevel]
     ,mySource.[tixsyspricecodetextdesc]
     ,mySource.[tixsyspricecodedispord]
     ,mySource.[tixsyspricecodesalesmodes]
     ,mySource.[tixsyscompseatstatuscode]
     ,mySource.[tixsyspricecodealtprintdesc]
     ,mySource.[printable]
     ,mySource.[is_comp]
     ,mySource.[tixsyspricecodepaypri]
     ,mySource.[tixsyspricecodepricingmode]
     ,mySource.[restrict_transfer]
     ,mySource.[restrict_resale]
     ,mySource.[waive_first_seller_fee]
     ,mySource.[stadis_active]
     ,mySource.[hidden_status]
     ,mySource.[restrict_transfer_to_fs]
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
