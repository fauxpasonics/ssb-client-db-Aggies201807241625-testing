SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVPaymentSchedule]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVPaymentSchedule),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  SchedID, SecondaryID, ContactID, ProgramID, TransYear, TransGroup, TransAmount, DateOfPayment, MethodOfPayment, PaymentInstrumentId, AuthorizationCode, CardNo, CardType, CardExpire, BankAccount, BankRoute, BankName, BankAcctType, BankAcctHolder, BillingName, BillingAddress, BillingCity, BillingState, BillingZip, TransactionCompleted, ReceiptID, Notes_Header, Comments_LineItem, SetupBy, RolledOver, DropPaymentInstrument, datetimecreated, username, hostname
INTO #SrcData
FROM ods.ADVPaymentSchedule

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (SchedID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVPaymentSchedule AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.SchedID = mySource.SchedID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[SchedID] = mySource.[SchedID]
     ,myTarget.[SecondaryID] = mySource.[SecondaryID]
     ,myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[ProgramID] = mySource.[ProgramID]
     ,myTarget.[TransYear] = mySource.[TransYear]
     ,myTarget.[TransGroup] = mySource.[TransGroup]
     ,myTarget.[TransAmount] = mySource.[TransAmount]
     ,myTarget.[DateOfPayment] = mySource.[DateOfPayment]
     ,myTarget.[MethodOfPayment] = mySource.[MethodOfPayment]
     ,myTarget.[PaymentInstrumentId] = mySource.[PaymentInstrumentId]
     ,myTarget.[AuthorizationCode] = mySource.[AuthorizationCode]
     ,myTarget.[CardNo] = mySource.[CardNo]
     ,myTarget.[CardType] = mySource.[CardType]
     ,myTarget.[CardExpire] = mySource.[CardExpire]
     ,myTarget.[BankAccount] = mySource.[BankAccount]
     ,myTarget.[BankRoute] = mySource.[BankRoute]
     ,myTarget.[BankName] = mySource.[BankName]
     ,myTarget.[BankAcctType] = mySource.[BankAcctType]
     ,myTarget.[BankAcctHolder] = mySource.[BankAcctHolder]
     ,myTarget.[BillingName] = mySource.[BillingName]
     ,myTarget.[BillingAddress] = mySource.[BillingAddress]
     ,myTarget.[BillingCity] = mySource.[BillingCity]
     ,myTarget.[BillingState] = mySource.[BillingState]
     ,myTarget.[BillingZip] = mySource.[BillingZip]
     ,myTarget.[TransactionCompleted] = mySource.[TransactionCompleted]
     ,myTarget.[ReceiptID] = mySource.[ReceiptID]
     ,myTarget.[Notes_Header] = mySource.[Notes_Header]
     ,myTarget.[Comments_LineItem] = mySource.[Comments_LineItem]
     ,myTarget.[SetupBy] = mySource.[SetupBy]
     ,myTarget.[RolledOver] = mySource.[RolledOver]
     ,myTarget.[DropPaymentInstrument] = mySource.[DropPaymentInstrument]
     ,myTarget.[datetimecreated] = mySource.[datetimecreated]
     ,myTarget.[username] = mySource.[username]
     ,myTarget.[hostname] = mySource.[hostname]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([SchedID]
     ,[SecondaryID]
     ,[ContactID]
     ,[ProgramID]
     ,[TransYear]
     ,[TransGroup]
     ,[TransAmount]
     ,[DateOfPayment]
     ,[MethodOfPayment]
     ,[PaymentInstrumentId]
     ,[AuthorizationCode]
     ,[CardNo]
     ,[CardType]
     ,[CardExpire]
     ,[BankAccount]
     ,[BankRoute]
     ,[BankName]
     ,[BankAcctType]
     ,[BankAcctHolder]
     ,[BillingName]
     ,[BillingAddress]
     ,[BillingCity]
     ,[BillingState]
     ,[BillingZip]
     ,[TransactionCompleted]
     ,[ReceiptID]
     ,[Notes_Header]
     ,[Comments_LineItem]
     ,[SetupBy]
     ,[RolledOver]
     ,[DropPaymentInstrument]
     ,[datetimecreated]
     ,[username]
     ,[hostname]
     )
VALUES
     (mySource.[SchedID]
     ,mySource.[SecondaryID]
     ,mySource.[ContactID]
     ,mySource.[ProgramID]
     ,mySource.[TransYear]
     ,mySource.[TransGroup]
     ,mySource.[TransAmount]
     ,mySource.[DateOfPayment]
     ,mySource.[MethodOfPayment]
     ,mySource.[PaymentInstrumentId]
     ,mySource.[AuthorizationCode]
     ,mySource.[CardNo]
     ,mySource.[CardType]
     ,mySource.[CardExpire]
     ,mySource.[BankAccount]
     ,mySource.[BankRoute]
     ,mySource.[BankName]
     ,mySource.[BankAcctType]
     ,mySource.[BankAcctHolder]
     ,mySource.[BillingName]
     ,mySource.[BillingAddress]
     ,mySource.[BillingCity]
     ,mySource.[BillingState]
     ,mySource.[BillingZip]
     ,mySource.[TransactionCompleted]
     ,mySource.[ReceiptID]
     ,mySource.[Notes_Header]
     ,mySource.[Comments_LineItem]
     ,mySource.[SetupBy]
     ,mySource.[RolledOver]
     ,mySource.[DropPaymentInstrument]
     ,mySource.[datetimecreated]
     ,mySource.[username]
     ,mySource.[hostname]
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
