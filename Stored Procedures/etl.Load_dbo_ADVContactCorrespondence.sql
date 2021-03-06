SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVContactCorrespondence]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVContactCorrespondence),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  PK, ContactID, ContactedBy, CorrDate, Contact, Type, Subject, Notes, Status, Private, SentToTixOffice, DateTimeSentToTixOffice, ProposedDonation, NegotiatedDonation
INTO #SrcData
FROM ods.ADVContactCorrespondence

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (PK)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVContactCorrespondence AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.PK = mySource.PK

WHEN MATCHED

THEN UPDATE SET
      myTarget.[PK] = mySource.[PK]
     ,myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[ContactedBy] = mySource.[ContactedBy]
     ,myTarget.[CorrDate] = mySource.[CorrDate]
     ,myTarget.[Contact] = mySource.[Contact]
     ,myTarget.[Type] = mySource.[Type]
     ,myTarget.[Subject] = mySource.[Subject]
     ,myTarget.[Notes] = mySource.[Notes]
     ,myTarget.[Status] = mySource.[Status]
     ,myTarget.[Private] = mySource.[Private]
     ,myTarget.[SentToTixOffice] = mySource.[SentToTixOffice]
     ,myTarget.[DateTimeSentToTixOffice] = mySource.[DateTimeSentToTixOffice]
     ,myTarget.[ProposedDonation] = mySource.[ProposedDonation]
     ,myTarget.[NegotiatedDonation] = mySource.[NegotiatedDonation]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([PK]
     ,[ContactID]
     ,[ContactedBy]
     ,[CorrDate]
     ,[Contact]
     ,[Type]
     ,[Subject]
     ,[Notes]
     ,[Status]
     ,[Private]
     ,[SentToTixOffice]
     ,[DateTimeSentToTixOffice]
     ,[ProposedDonation]
     ,[NegotiatedDonation]
     )
VALUES
     (mySource.[PK]
     ,mySource.[ContactID]
     ,mySource.[ContactedBy]
     ,mySource.[CorrDate]
     ,mySource.[Contact]
     ,mySource.[Type]
     ,mySource.[Subject]
     ,mySource.[Notes]
     ,mySource.[Status]
     ,mySource.[Private]
     ,mySource.[SentToTixOffice]
     ,mySource.[DateTimeSentToTixOffice]
     ,mySource.[ProposedDonation]
     ,mySource.[NegotiatedDonation]
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
