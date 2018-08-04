SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVDonorPayUsers]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVDonorPayUsers),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  UserID, Username, PasswordHash, ADNumber, ContactID, Email, ConfirmSent, Confirmed, NewMember, NewMemberID
INTO #SrcData
FROM ods.ADVDonorPayUsers

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (UserID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVDonorPayUsers AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.UserID = mySource.UserID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[UserID] = mySource.[UserID]
     ,myTarget.[Username] = mySource.[Username]
     ,myTarget.[PasswordHash] = mySource.[PasswordHash]
     ,myTarget.[ADNumber] = mySource.[ADNumber]
     ,myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[Email] = mySource.[Email]
     ,myTarget.[ConfirmSent] = mySource.[ConfirmSent]
     ,myTarget.[Confirmed] = mySource.[Confirmed]
     ,myTarget.[NewMember] = mySource.[NewMember]
     ,myTarget.[NewMemberID] = mySource.[NewMemberID]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([UserID]
     ,[Username]
     ,[PasswordHash]
     ,[ADNumber]
     ,[ContactID]
     ,[Email]
     ,[ConfirmSent]
     ,[Confirmed]
     ,[NewMember]
     ,[NewMemberID]
     )
VALUES
     (mySource.[UserID]
     ,mySource.[Username]
     ,mySource.[PasswordHash]
     ,mySource.[ADNumber]
     ,mySource.[ContactID]
     ,mySource.[Email]
     ,mySource.[ConfirmSent]
     ,mySource.[Confirmed]
     ,mySource.[NewMember]
     ,mySource.[NewMemberID]
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
