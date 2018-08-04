SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXpayment_distribution]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXpayment_distribution),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, id, payment_id, order_item_id, product_id, settlement_code_id, dist_date, user_id, outlet_id, channel_id, amount, fully_paid_qty, fully_paid_amount
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(50), [amount])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [channel_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [dist_date])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [fully_paid_amount])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [fully_paid_qty])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [order_item_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [outlet_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [payment_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [product_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [settlement_code_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [user_id]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXpayment_distribution

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXpayment_distribution AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[payment_id] = mySource.[payment_id]
     ,myTarget.[order_item_id] = mySource.[order_item_id]
     ,myTarget.[product_id] = mySource.[product_id]
     ,myTarget.[settlement_code_id] = mySource.[settlement_code_id]
     ,myTarget.[dist_date] = mySource.[dist_date]
     ,myTarget.[user_id] = mySource.[user_id]
     ,myTarget.[outlet_id] = mySource.[outlet_id]
     ,myTarget.[channel_id] = mySource.[channel_id]
     ,myTarget.[amount] = mySource.[amount]
     ,myTarget.[fully_paid_qty] = mySource.[fully_paid_qty]
     ,myTarget.[fully_paid_amount] = mySource.[fully_paid_amount]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[id]
     ,[payment_id]
     ,[order_item_id]
     ,[product_id]
     ,[settlement_code_id]
     ,[dist_date]
     ,[user_id]
     ,[outlet_id]
     ,[channel_id]
     ,[amount]
     ,[fully_paid_qty]
     ,[fully_paid_amount]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[id]
     ,mySource.[payment_id]
     ,mySource.[order_item_id]
     ,mySource.[product_id]
     ,mySource.[settlement_code_id]
     ,mySource.[dist_date]
     ,mySource.[user_id]
     ,mySource.[outlet_id]
     ,mySource.[channel_id]
     ,mySource.[amount]
     ,mySource.[fully_paid_qty]
     ,mySource.[fully_paid_amount]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXpayment_distribution
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXpayment_distribution o
LEFT JOIN src.VTXpayment_distribution_UK s ON s.id = o.id
WHERE s.id IS NULL

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
