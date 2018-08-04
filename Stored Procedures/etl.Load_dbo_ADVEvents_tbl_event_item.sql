SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVEvents_tbl_event_item]
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
Date:     07/10/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVEvents_tbl_event_item),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  id, event_group_id, sort_order, title, start_date, end_date, descr, optional, unit, price, max_qty, category_id_list, max_capacity, sold_out_behavior, other_info, zero_qty, show_qty_avail
INTO #SrcData
FROM ods.ADVEvents_tbl_event_item

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVEvents_tbl_event_item AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id

WHEN MATCHED

THEN UPDATE SET
      myTarget.[id] = mySource.[id]
     ,myTarget.[event_group_id] = mySource.[event_group_id]
     ,myTarget.[sort_order] = mySource.[sort_order]
     ,myTarget.[title] = mySource.[title]
     ,myTarget.[start_date] = mySource.[start_date]
     ,myTarget.[end_date] = mySource.[end_date]
     ,myTarget.[descr] = mySource.[descr]
     ,myTarget.[optional] = mySource.[optional]
     ,myTarget.[unit] = mySource.[unit]
     ,myTarget.[price] = mySource.[price]
     ,myTarget.[max_qty] = mySource.[max_qty]
     ,myTarget.[category_id_list] = mySource.[category_id_list]
     ,myTarget.[max_capacity] = mySource.[max_capacity]
     ,myTarget.[sold_out_behavior] = mySource.[sold_out_behavior]
     ,myTarget.[other_info] = mySource.[other_info]
     ,myTarget.[zero_qty] = mySource.[zero_qty]
     ,myTarget.[show_qty_avail] = mySource.[show_qty_avail]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([id]
     ,[event_group_id]
     ,[sort_order]
     ,[title]
     ,[start_date]
     ,[end_date]
     ,[descr]
     ,[optional]
     ,[unit]
     ,[price]
     ,[max_qty]
     ,[category_id_list]
     ,[max_capacity]
     ,[sold_out_behavior]
     ,[other_info]
     ,[zero_qty]
     ,[show_qty_avail]
     )
VALUES
     (mySource.[id]
     ,mySource.[event_group_id]
     ,mySource.[sort_order]
     ,mySource.[title]
     ,mySource.[start_date]
     ,mySource.[end_date]
     ,mySource.[descr]
     ,mySource.[optional]
     ,mySource.[unit]
     ,mySource.[price]
     ,mySource.[max_qty]
     ,mySource.[category_id_list]
     ,mySource.[max_capacity]
     ,mySource.[sold_out_behavior]
     ,mySource.[other_info]
     ,mySource.[zero_qty]
     ,mySource.[show_qty_avail]
     )

WHEN NOT MATCHED BY SOURCE

THEN DELETE
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
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
