SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	CREATE PROCEDURE [etl].[Load_dbo_ADVContactTransHeader]
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
Date:     07/01/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVContactTransHeader),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  TransID, ContactID, TransYear, TransDate, TransGroup, TransType, MatchingAcct, MatchingTransID, PaymentType, CheckNo, CardType, CardNo, ExpireDate, CardHolderName, CardHolderAddress, CardHolderZip, AuthCode, AuthTransID, notes, renew, EnterDateTime, EnterByUser, BatchRefNo, ReceiptID
INTO #SrcData
FROM ods.ADVContactTransHeader

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (TransID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVContactTransHeader AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.TransID = mySource.TransID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[TransID] = mySource.[TransID]
     ,myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[TransYear] = mySource.[TransYear]
     ,myTarget.[TransDate] = mySource.[TransDate]
     ,myTarget.[TransGroup] = mySource.[TransGroup]
     ,myTarget.[TransType] = mySource.[TransType]
     ,myTarget.[MatchingAcct] = mySource.[MatchingAcct]
     ,myTarget.[MatchingTransID] = mySource.[MatchingTransID]
     ,myTarget.[PaymentType] = mySource.[PaymentType]
     ,myTarget.[CheckNo] = mySource.[CheckNo]
     ,myTarget.[CardType] = mySource.[CardType]
     ,myTarget.[CardNo] = mySource.[CardNo]
     ,myTarget.[ExpireDate] = mySource.[ExpireDate]
     ,myTarget.[CardHolderName] = mySource.[CardHolderName]
     ,myTarget.[CardHolderAddress] = mySource.[CardHolderAddress]
     ,myTarget.[CardHolderZip] = mySource.[CardHolderZip]
     ,myTarget.[AuthCode] = mySource.[AuthCode]
     ,myTarget.[AuthTransID] = mySource.[AuthTransID]
     ,myTarget.[notes] = mySource.[notes]
     ,myTarget.[renew] = mySource.[renew]
     ,myTarget.[EnterDateTime] = mySource.[EnterDateTime]
     ,myTarget.[EnterByUser] = mySource.[EnterByUser]
     ,myTarget.[BatchRefNo] = mySource.[BatchRefNo]
     ,myTarget.[ReceiptID] = mySource.[ReceiptID]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([TransID]
     ,[ContactID]
     ,[TransYear]
     ,[TransDate]
     ,[TransGroup]
     ,[TransType]
     ,[MatchingAcct]
     ,[MatchingTransID]
     ,[PaymentType]
     ,[CheckNo]
     ,[CardType]
     ,[CardNo]
     ,[ExpireDate]
     ,[CardHolderName]
     ,[CardHolderAddress]
     ,[CardHolderZip]
     ,[AuthCode]
     ,[AuthTransID]
     ,[notes]
     ,[renew]
     ,[EnterDateTime]
     ,[EnterByUser]
     ,[BatchRefNo]
     ,[ReceiptID]
     )
VALUES
     (mySource.[TransID]
     ,mySource.[ContactID]
     ,mySource.[TransYear]
     ,mySource.[TransDate]
     ,mySource.[TransGroup]
     ,mySource.[TransType]
     ,mySource.[MatchingAcct]
     ,mySource.[MatchingTransID]
     ,mySource.[PaymentType]
     ,mySource.[CheckNo]
     ,mySource.[CardType]
     ,mySource.[CardNo]
     ,mySource.[ExpireDate]
     ,mySource.[CardHolderName]
     ,mySource.[CardHolderAddress]
     ,mySource.[CardHolderZip]
     ,mySource.[AuthCode]
     ,mySource.[AuthTransID]
     ,mySource.[notes]
     ,mySource.[renew]
     ,mySource.[EnterDateTime]
     ,mySource.[EnterByUser]
     ,mySource.[BatchRefNo]
     ,mySource.[ReceiptID]
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
