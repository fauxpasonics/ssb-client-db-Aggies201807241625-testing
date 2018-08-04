SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVReps]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVReps),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  RepID, FullName, Status, NULL Password, SecurityLevel, EmailProgram, LogOnProfile, LogOnPassword, LogOnProxy
INTO #SrcData
FROM ods.ADVReps

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (RepID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVReps AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.RepID = mySource.RepID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[RepID] = mySource.[RepID]
     ,myTarget.[FullName] = mySource.[FullName]
     ,myTarget.[Status] = mySource.[Status]
     ,myTarget.[Password] = NULL
     ,myTarget.[SecurityLevel] = mySource.[SecurityLevel]
     ,myTarget.[EmailProgram] = mySource.[EmailProgram]
     ,myTarget.[LogOnProfile] = mySource.[LogOnProfile]
     ,myTarget.[LogOnPassword] = mySource.[LogOnPassword]
     ,myTarget.[LogOnProxy] = mySource.[LogOnProxy]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([RepID]
     ,[FullName]
     ,[Status]
     ,[Password]
     ,[SecurityLevel]
     ,[EmailProgram]
     ,[LogOnProfile]
     ,[LogOnPassword]
     ,[LogOnProxy]
     )
VALUES
     (mySource.[RepID]
     ,mySource.[FullName]
     ,mySource.[Status]
     ,NULL
     ,mySource.[SecurityLevel]
     ,mySource.[EmailProgram]
     ,mySource.[LogOnProfile]
     ,mySource.[LogOnPassword]
     ,mySource.[LogOnProxy]
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
