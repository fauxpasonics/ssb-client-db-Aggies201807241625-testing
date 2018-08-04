SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXorder_items]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXorder_items),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, id, order_id, sale_date, sale_user, sale_outlet, sale_channel, value, paid_amount, product_id, inventory_type, primary_product_id, number1, number2, number3, number4, number5, number6, number7, number8, number9, number10, number11, number12, number13, number14, number15, string1, string2, string3, string4, string5, canceled, cancel_date, cancel_user, cancel_outlet, cancel_channel, offer_restriction_id, customer_restriction_id
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(25), [cancel_channel])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [cancel_date])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [cancel_outlet])),'DBNULL_NUMBER') + ISNULL(RTRIM( [cancel_user]),'DBNULL_TEXT') + ISNULL(RTRIM( [canceled]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [customer_restriction_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [inventory_type]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [number1])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number10])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number11])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number12])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number13])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number14])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number15])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number2])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number3])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number4])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number5])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number6])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number7])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number8])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [number9])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [offer_restriction_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [order_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [paid_amount])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [primary_product_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [product_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [sale_channel])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [sale_date])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [sale_outlet])),'DBNULL_NUMBER') + ISNULL(RTRIM( [sale_user]),'DBNULL_TEXT') + ISNULL(RTRIM( [string1]),'DBNULL_TEXT') + ISNULL(RTRIM( [string2]),'DBNULL_TEXT') + ISNULL(RTRIM( [string3]),'DBNULL_TEXT') + ISNULL(RTRIM( [string4]),'DBNULL_TEXT') + ISNULL(RTRIM( [string5]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [value])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXorder_items

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXorder_items AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[order_id] = mySource.[order_id]
     ,myTarget.[sale_date] = mySource.[sale_date]
     ,myTarget.[sale_user] = mySource.[sale_user]
     ,myTarget.[sale_outlet] = mySource.[sale_outlet]
     ,myTarget.[sale_channel] = mySource.[sale_channel]
     ,myTarget.[value] = mySource.[value]
     ,myTarget.[paid_amount] = mySource.[paid_amount]
     ,myTarget.[product_id] = mySource.[product_id]
     ,myTarget.[inventory_type] = mySource.[inventory_type]
     ,myTarget.[primary_product_id] = mySource.[primary_product_id]
     ,myTarget.[number1] = mySource.[number1]
     ,myTarget.[number2] = mySource.[number2]
     ,myTarget.[number3] = mySource.[number3]
     ,myTarget.[number4] = mySource.[number4]
     ,myTarget.[number5] = mySource.[number5]
     ,myTarget.[number6] = mySource.[number6]
     ,myTarget.[number7] = mySource.[number7]
     ,myTarget.[number8] = mySource.[number8]
     ,myTarget.[number9] = mySource.[number9]
     ,myTarget.[number10] = mySource.[number10]
     ,myTarget.[number11] = mySource.[number11]
     ,myTarget.[number12] = mySource.[number12]
     ,myTarget.[number13] = mySource.[number13]
     ,myTarget.[number14] = mySource.[number14]
     ,myTarget.[number15] = mySource.[number15]
     ,myTarget.[string1] = mySource.[string1]
     ,myTarget.[string2] = mySource.[string2]
     ,myTarget.[string3] = mySource.[string3]
     ,myTarget.[string4] = mySource.[string4]
     ,myTarget.[string5] = mySource.[string5]
     ,myTarget.[canceled] = mySource.[canceled]
     ,myTarget.[cancel_date] = mySource.[cancel_date]
     ,myTarget.[cancel_user] = mySource.[cancel_user]
     ,myTarget.[cancel_outlet] = mySource.[cancel_outlet]
     ,myTarget.[cancel_channel] = mySource.[cancel_channel]
     ,myTarget.[offer_restriction_id] = mySource.[offer_restriction_id]
     ,myTarget.[customer_restriction_id] = mySource.[customer_restriction_id]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[id]
     ,[order_id]
     ,[sale_date]
     ,[sale_user]
     ,[sale_outlet]
     ,[sale_channel]
     ,[value]
     ,[paid_amount]
     ,[product_id]
     ,[inventory_type]
     ,[primary_product_id]
     ,[number1]
     ,[number2]
     ,[number3]
     ,[number4]
     ,[number5]
     ,[number6]
     ,[number7]
     ,[number8]
     ,[number9]
     ,[number10]
     ,[number11]
     ,[number12]
     ,[number13]
     ,[number14]
     ,[number15]
     ,[string1]
     ,[string2]
     ,[string3]
     ,[string4]
     ,[string5]
     ,[canceled]
     ,[cancel_date]
     ,[cancel_user]
     ,[cancel_outlet]
     ,[cancel_channel]
     ,[offer_restriction_id]
     ,[customer_restriction_id]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[id]
     ,mySource.[order_id]
     ,mySource.[sale_date]
     ,mySource.[sale_user]
     ,mySource.[sale_outlet]
     ,mySource.[sale_channel]
     ,mySource.[value]
     ,mySource.[paid_amount]
     ,mySource.[product_id]
     ,mySource.[inventory_type]
     ,mySource.[primary_product_id]
     ,mySource.[number1]
     ,mySource.[number2]
     ,mySource.[number3]
     ,mySource.[number4]
     ,mySource.[number5]
     ,mySource.[number6]
     ,mySource.[number7]
     ,mySource.[number8]
     ,mySource.[number9]
     ,mySource.[number10]
     ,mySource.[number11]
     ,mySource.[number12]
     ,mySource.[number13]
     ,mySource.[number14]
     ,mySource.[number15]
     ,mySource.[string1]
     ,mySource.[string2]
     ,mySource.[string3]
     ,mySource.[string4]
     ,mySource.[string5]
     ,mySource.[canceled]
     ,mySource.[cancel_date]
     ,mySource.[cancel_user]
     ,mySource.[cancel_outlet]
     ,mySource.[cancel_channel]
     ,mySource.[offer_restriction_id]
     ,mySource.[customer_restriction_id]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXorder_items
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXorder_items o
LEFT JOIN src.VTXorder_items_UK s ON s.id = o.id
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
