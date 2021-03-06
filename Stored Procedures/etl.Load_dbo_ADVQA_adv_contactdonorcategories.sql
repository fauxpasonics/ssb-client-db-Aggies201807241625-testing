SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVQA_adv_contactdonorcategories]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVQA_adv_contactdonorcategories),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ContactID, CategoryID, Value, CreateDate, CreateUser, UpdateDate, UpdateUser
INTO #SrcData
FROM ods.ADVQA_adv_contactdonorcategories

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ContactID,CategoryID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVQA_adv_contactdonorcategories AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ContactID = mySource.ContactID and myTarget.CategoryID = mySource.CategoryID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[CategoryID] = mySource.[CategoryID]
     ,myTarget.[Value] = mySource.[Value]
     ,myTarget.[CreateDate] = mySource.[CreateDate]
     ,myTarget.[CreateUser] = mySource.[CreateUser]
     ,myTarget.[UpdateDate] = mySource.[UpdateDate]
     ,myTarget.[UpdateUser] = mySource.[UpdateUser]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ContactID]
     ,[CategoryID]
     ,[Value]
     ,[CreateDate]
     ,[CreateUser]
     ,[UpdateDate]
     ,[UpdateUser]
     )
VALUES
     (mySource.[ContactID]
     ,mySource.[CategoryID]
     ,mySource.[Value]
     ,mySource.[CreateDate]
     ,mySource.[CreateUser]
     ,mySource.[UpdateDate]
     ,mySource.[UpdateUser]
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
