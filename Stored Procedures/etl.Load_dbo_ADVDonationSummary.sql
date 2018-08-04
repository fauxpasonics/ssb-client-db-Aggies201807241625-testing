SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVDonationSummary]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVDonationSummary),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ContactID, TransYear, ProgramID, CashPledges, CashReceipts, GIKPledges, GIKReceipts, MatchPledges, MatchReceipts, Credits
INTO #SrcData
FROM ods.ADVDonationSummary

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ContactID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVDonationSummary AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ContactID = mySource.ContactID
	AND myTarget.TransYear = mySource.TransYear
	AND myTarget.ProgramID = mySource.ProgramID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[TransYear] = mySource.[TransYear]
     ,myTarget.[ProgramID] = mySource.[ProgramID]
     ,myTarget.[CashPledges] = mySource.[CashPledges]
     ,myTarget.[CashReceipts] = mySource.[CashReceipts]
     ,myTarget.[GIKPledges] = mySource.[GIKPledges]
     ,myTarget.[GIKReceipts] = mySource.[GIKReceipts]
     ,myTarget.[MatchPledges] = mySource.[MatchPledges]
     ,myTarget.[MatchReceipts] = mySource.[MatchReceipts]
     ,myTarget.[Credits] = mySource.[Credits]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ContactID]
     ,[TransYear]
     ,[ProgramID]
     ,[CashPledges]
     ,[CashReceipts]
     ,[GIKPledges]
     ,[GIKReceipts]
     ,[MatchPledges]
     ,[MatchReceipts]
     ,[Credits]
     )
VALUES
     (mySource.[ContactID]
     ,mySource.[TransYear]
     ,mySource.[ProgramID]
     ,mySource.[CashPledges]
     ,mySource.[CashReceipts]
     ,mySource.[GIKPledges]
     ,mySource.[GIKReceipts]
     ,mySource.[MatchPledges]
     ,mySource.[MatchReceipts]
     ,mySource.[Credits]
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
