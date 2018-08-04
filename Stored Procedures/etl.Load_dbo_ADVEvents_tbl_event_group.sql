SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVEvents_tbl_event_group]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVEvents_tbl_event_group),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  id, title, descr, register_deadline, programid, confirm_info, sort_order, accept_payment_plan, total_due_on, terms_and_conditions, confirm_thank, summary_info, active, regrets, regrets_info
INTO #SrcData
FROM ods.ADVEvents_tbl_event_group

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVEvents_tbl_event_group AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id

WHEN MATCHED

THEN UPDATE SET
      myTarget.[id] = mySource.[id]
     ,myTarget.[title] = mySource.[title]
     ,myTarget.[descr] = mySource.[descr]
     ,myTarget.[register_deadline] = mySource.[register_deadline]
     ,myTarget.[programid] = mySource.[programid]
     ,myTarget.[confirm_info] = mySource.[confirm_info]
     ,myTarget.[sort_order] = mySource.[sort_order]
     ,myTarget.[accept_payment_plan] = mySource.[accept_payment_plan]
     ,myTarget.[total_due_on] = mySource.[total_due_on]
     ,myTarget.[terms_and_conditions] = mySource.[terms_and_conditions]
     ,myTarget.[confirm_thank] = mySource.[confirm_thank]
     ,myTarget.[summary_info] = mySource.[summary_info]
     ,myTarget.[active] = mySource.[active]
     ,myTarget.[regrets] = mySource.[regrets]
     ,myTarget.[regrets_info] = mySource.[regrets_info]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([id]
     ,[title]
     ,[descr]
     ,[register_deadline]
     ,[programid]
     ,[confirm_info]
     ,[sort_order]
     ,[accept_payment_plan]
     ,[total_due_on]
     ,[terms_and_conditions]
     ,[confirm_thank]
     ,[summary_info]
     ,[active]
     ,[regrets]
     ,[regrets_info]
     )
VALUES
     (mySource.[id]
     ,mySource.[title]
     ,mySource.[descr]
     ,mySource.[register_deadline]
     ,mySource.[programid]
     ,mySource.[confirm_info]
     ,mySource.[sort_order]
     ,mySource.[accept_payment_plan]
     ,mySource.[total_due_on]
     ,mySource.[terms_and_conditions]
     ,mySource.[confirm_thank]
     ,mySource.[summary_info]
     ,mySource.[active]
     ,mySource.[regrets]
     ,mySource.[regrets_info]
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
