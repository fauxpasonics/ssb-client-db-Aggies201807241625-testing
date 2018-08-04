SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVEvents_tbl_order_line]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVEvents_tbl_order_line),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  id, order_id, product_id, qty, price, donation, comment, options, group_id, renewal_descr, renewal_programid, pos_ticket_id, price_code, va_update_date, va_offerid, va_groupid, va_price, va_pricecodeid, va_pricelevelid, va_statuscodeid, va_neighborhoodid, va_sectionid, va_rowid, va_seatid_list, va_eventid, va_seatgroupid, va_zoneid, kylefield_item_code, event_group, event_item_id, stsl_data, va_orderid, va_neighborhood, va_info
INTO #SrcData
FROM ods.ADVEvents_tbl_order_line

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVEvents_tbl_order_line AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id

WHEN MATCHED

THEN UPDATE SET
      myTarget.[id] = mySource.[id]
     ,myTarget.[order_id] = mySource.[order_id]
     ,myTarget.[product_id] = mySource.[product_id]
     ,myTarget.[qty] = mySource.[qty]
     ,myTarget.[price] = mySource.[price]
     ,myTarget.[donation] = mySource.[donation]
     ,myTarget.[comment] = mySource.[comment]
     ,myTarget.[options] = mySource.[options]
     ,myTarget.[group_id] = mySource.[group_id]
     ,myTarget.[renewal_descr] = mySource.[renewal_descr]
     ,myTarget.[renewal_programid] = mySource.[renewal_programid]
     ,myTarget.[pos_ticket_id] = mySource.[pos_ticket_id]
     ,myTarget.[price_code] = mySource.[price_code]
     ,myTarget.[va_update_date] = mySource.[va_update_date]
     ,myTarget.[va_offerid] = mySource.[va_offerid]
     ,myTarget.[va_groupid] = mySource.[va_groupid]
     ,myTarget.[va_price] = mySource.[va_price]
     ,myTarget.[va_pricecodeid] = mySource.[va_pricecodeid]
     ,myTarget.[va_pricelevelid] = mySource.[va_pricelevelid]
     ,myTarget.[va_statuscodeid] = mySource.[va_statuscodeid]
     ,myTarget.[va_neighborhoodid] = mySource.[va_neighborhoodid]
     ,myTarget.[va_sectionid] = mySource.[va_sectionid]
     ,myTarget.[va_rowid] = mySource.[va_rowid]
     ,myTarget.[va_seatid_list] = mySource.[va_seatid_list]
     ,myTarget.[va_eventid] = mySource.[va_eventid]
     ,myTarget.[va_seatgroupid] = mySource.[va_seatgroupid]
     ,myTarget.[va_zoneid] = mySource.[va_zoneid]
     ,myTarget.[kylefield_item_code] = mySource.[kylefield_item_code]
     ,myTarget.[event_group] = mySource.[event_group]
     ,myTarget.[event_item_id] = mySource.[event_item_id]
     ,myTarget.[stsl_data] = mySource.[stsl_data]
     ,myTarget.[va_orderid] = mySource.[va_orderid]
     ,myTarget.[va_neighborhood] = mySource.[va_neighborhood]
     ,myTarget.[va_info] = mySource.[va_info]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([id]
     ,[order_id]
     ,[product_id]
     ,[qty]
     ,[price]
     ,[donation]
     ,[comment]
     ,[options]
     ,[group_id]
     ,[renewal_descr]
     ,[renewal_programid]
     ,[pos_ticket_id]
     ,[price_code]
     ,[va_update_date]
     ,[va_offerid]
     ,[va_groupid]
     ,[va_price]
     ,[va_pricecodeid]
     ,[va_pricelevelid]
     ,[va_statuscodeid]
     ,[va_neighborhoodid]
     ,[va_sectionid]
     ,[va_rowid]
     ,[va_seatid_list]
     ,[va_eventid]
     ,[va_seatgroupid]
     ,[va_zoneid]
     ,[kylefield_item_code]
     ,[event_group]
     ,[event_item_id]
     ,[stsl_data]
     ,[va_orderid]
     ,[va_neighborhood]
     ,[va_info]
     )
VALUES
     (mySource.[id]
     ,mySource.[order_id]
     ,mySource.[product_id]
     ,mySource.[qty]
     ,mySource.[price]
     ,mySource.[donation]
     ,mySource.[comment]
     ,mySource.[options]
     ,mySource.[group_id]
     ,mySource.[renewal_descr]
     ,mySource.[renewal_programid]
     ,mySource.[pos_ticket_id]
     ,mySource.[price_code]
     ,mySource.[va_update_date]
     ,mySource.[va_offerid]
     ,mySource.[va_groupid]
     ,mySource.[va_price]
     ,mySource.[va_pricecodeid]
     ,mySource.[va_pricelevelid]
     ,mySource.[va_statuscodeid]
     ,mySource.[va_neighborhoodid]
     ,mySource.[va_sectionid]
     ,mySource.[va_rowid]
     ,mySource.[va_seatid_list]
     ,mySource.[va_eventid]
     ,mySource.[va_seatgroupid]
     ,mySource.[va_zoneid]
     ,mySource.[kylefield_item_code]
     ,mySource.[event_group]
     ,mySource.[event_item_id]
     ,mySource.[stsl_data]
     ,mySource.[va_orderid]
     ,mySource.[va_neighborhood]
     ,mySource.[va_info]
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
