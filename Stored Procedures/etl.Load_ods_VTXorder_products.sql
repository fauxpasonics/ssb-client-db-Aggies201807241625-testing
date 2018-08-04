SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXorder_products]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXorder_products),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, order_id, product_id, status, quantity, value, payments_cleared, payments_scheduled, payment_balance
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(50), [order_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [payment_balance])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [payments_cleared])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [payments_scheduled])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [product_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [quantity])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [status])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [value])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXorder_products

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (order_id, product_id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXorder_products AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.order_id = mySource.order_id AND myTarget.product_id = mySource.product_id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[order_id] = mySource.[order_id]
     ,myTarget.[product_id] = mySource.[product_id]
     ,myTarget.[status] = mySource.[status]
     ,myTarget.[quantity] = mySource.[quantity]
     ,myTarget.[value] = mySource.[value]
     ,myTarget.[payments_cleared] = mySource.[payments_cleared]
     ,myTarget.[payments_scheduled] = mySource.[payments_scheduled]
     ,myTarget.[payment_balance] = mySource.[payment_balance]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[order_id]
     ,[product_id]
     ,[status]
     ,[quantity]
     ,[value]
     ,[payments_cleared]
     ,[payments_scheduled]
     ,[payment_balance]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[order_id]
     ,mySource.[product_id]
     ,mySource.[status]
     ,mySource.[quantity]
     ,mySource.[value]
     ,mySource.[payments_cleared]
     ,mySource.[payments_scheduled]
     ,mySource.[payment_balance]
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
