SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVHistoricalPriorityPoints]
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
Date:     07/09/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVHistoricalPriorityPoints),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ContactID, EntryDate, Rank, curr_yr_credits, curr_yr_pledges, curr_yr_receipts, prev_yr_credits, prev_yr_pledges, prev_yr_receipts, curr_yr_cash_pts, prev_yr_cash_pts, accrual_pts, linked_ppts, linked_ppts_given_up, accrual_basis_ppts, cash_basis_ppts
INTO #SrcData
FROM ods.ADVHistoricalPriorityPoints

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ContactID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVHistoricalPriorityPoints AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ContactID = mySource.ContactID
	AND myTarget.EntryDate = mySource.EntryDate

WHEN MATCHED

THEN UPDATE SET
      myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[EntryDate] = mySource.[EntryDate]
     ,myTarget.[Rank] = mySource.[Rank]
     ,myTarget.[curr_yr_credits] = mySource.[curr_yr_credits]
     ,myTarget.[curr_yr_pledges] = mySource.[curr_yr_pledges]
     ,myTarget.[curr_yr_receipts] = mySource.[curr_yr_receipts]
     ,myTarget.[prev_yr_credits] = mySource.[prev_yr_credits]
     ,myTarget.[prev_yr_pledges] = mySource.[prev_yr_pledges]
     ,myTarget.[prev_yr_receipts] = mySource.[prev_yr_receipts]
     ,myTarget.[curr_yr_cash_pts] = mySource.[curr_yr_cash_pts]
     ,myTarget.[prev_yr_cash_pts] = mySource.[prev_yr_cash_pts]
     ,myTarget.[accrual_pts] = mySource.[accrual_pts]
     ,myTarget.[linked_ppts] = mySource.[linked_ppts]
     ,myTarget.[linked_ppts_given_up] = mySource.[linked_ppts_given_up]
     ,myTarget.[accrual_basis_ppts] = mySource.[accrual_basis_ppts]
     ,myTarget.[cash_basis_ppts] = mySource.[cash_basis_ppts]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ContactID]
     ,[EntryDate]
     ,[Rank]
     ,[curr_yr_credits]
     ,[curr_yr_pledges]
     ,[curr_yr_receipts]
     ,[prev_yr_credits]
     ,[prev_yr_pledges]
     ,[prev_yr_receipts]
     ,[curr_yr_cash_pts]
     ,[prev_yr_cash_pts]
     ,[accrual_pts]
     ,[linked_ppts]
     ,[linked_ppts_given_up]
     ,[accrual_basis_ppts]
     ,[cash_basis_ppts]
     )
VALUES
     (mySource.[ContactID]
     ,mySource.[EntryDate]
     ,mySource.[Rank]
     ,mySource.[curr_yr_credits]
     ,mySource.[curr_yr_pledges]
     ,mySource.[curr_yr_receipts]
     ,mySource.[prev_yr_credits]
     ,mySource.[prev_yr_pledges]
     ,mySource.[prev_yr_receipts]
     ,mySource.[curr_yr_cash_pts]
     ,mySource.[prev_yr_cash_pts]
     ,mySource.[accrual_pts]
     ,mySource.[linked_ppts]
     ,mySource.[linked_ppts_given_up]
     ,mySource.[accrual_basis_ppts]
     ,mySource.[cash_basis_ppts]
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
