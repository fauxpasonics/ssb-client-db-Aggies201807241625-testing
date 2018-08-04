SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXproducttypes]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXproducttypes),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, producttype, producttypedescription, producttypefullfillmentprocess, producttypeprocessoffline, producttypeinitdate, producttypelastupdatewhen, producttypelastupdatewho, producttypedisplayorder, producttyperecordextensions, producttypeinventorymethod
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(10), [producttype])),'DBNULL_INT') + ISNULL(RTRIM( [producttypedescription]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [producttypedisplayorder])),'DBNULL_INT') + ISNULL(RTRIM( [producttypefullfillmentprocess]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [producttypeinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [producttypeinventorymethod]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [producttypelastupdatewhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [producttypelastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM( [producttypeprocessoffline]),'DBNULL_TEXT') + ISNULL(RTRIM( [producttyperecordextensions]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXproducttypes

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (producttype)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXproducttypes AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.producttype = mySource.producttype 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[producttype] = mySource.[producttype]
     ,myTarget.[producttypedescription] = mySource.[producttypedescription]
     ,myTarget.[producttypefullfillmentprocess] = mySource.[producttypefullfillmentprocess]
     ,myTarget.[producttypeprocessoffline] = mySource.[producttypeprocessoffline]
     ,myTarget.[producttypeinitdate] = mySource.[producttypeinitdate]
     ,myTarget.[producttypelastupdatewhen] = mySource.[producttypelastupdatewhen]
     ,myTarget.[producttypelastupdatewho] = mySource.[producttypelastupdatewho]
     ,myTarget.[producttypedisplayorder] = mySource.[producttypedisplayorder]
     ,myTarget.[producttyperecordextensions] = mySource.[producttyperecordextensions]
     ,myTarget.[producttypeinventorymethod] = mySource.[producttypeinventorymethod]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[producttype]
     ,[producttypedescription]
     ,[producttypefullfillmentprocess]
     ,[producttypeprocessoffline]
     ,[producttypeinitdate]
     ,[producttypelastupdatewhen]
     ,[producttypelastupdatewho]
     ,[producttypedisplayorder]
     ,[producttyperecordextensions]
     ,[producttypeinventorymethod]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[producttype]
     ,mySource.[producttypedescription]
     ,mySource.[producttypefullfillmentprocess]
     ,mySource.[producttypeprocessoffline]
     ,mySource.[producttypeinitdate]
     ,mySource.[producttypelastupdatewhen]
     ,mySource.[producttypelastupdatewho]
     ,mySource.[producttypedisplayorder]
     ,mySource.[producttyperecordextensions]
     ,mySource.[producttypeinventorymethod]
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
