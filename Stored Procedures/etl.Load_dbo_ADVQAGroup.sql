SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVQAGroup]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVQAGroup),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  GroupID, GroupName, Active, AutoAddYear, ProgramID, DonorCategoryID, CreateUser, CreateDate, UpdateUser, UpdateDate, LifetimeDonorCategoryid
INTO #SrcData
FROM ods.ADVQAGroup

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (GroupID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVQAGroup AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.GroupID = mySource.GroupID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[GroupID] = mySource.[GroupID]
     ,myTarget.[GroupName] = mySource.[GroupName]
     ,myTarget.[Active] = mySource.[Active]
     ,myTarget.[AutoAddYear] = mySource.[AutoAddYear]
     ,myTarget.[ProgramID] = mySource.[ProgramID]
     ,myTarget.[DonorCategoryID] = mySource.[DonorCategoryID]
     ,myTarget.[CreateUser] = mySource.[CreateUser]
     ,myTarget.[CreateDate] = mySource.[CreateDate]
     ,myTarget.[UpdateUser] = mySource.[UpdateUser]
     ,myTarget.[UpdateDate] = mySource.[UpdateDate]
     ,myTarget.[LifetimeDonorCategoryid] = mySource.[LifetimeDonorCategoryid]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([GroupID]
     ,[GroupName]
     ,[Active]
     ,[AutoAddYear]
     ,[ProgramID]
     ,[DonorCategoryID]
     ,[CreateUser]
     ,[CreateDate]
     ,[UpdateUser]
     ,[UpdateDate]
     ,[LifetimeDonorCategoryid]
     )
VALUES
     (mySource.[GroupID]
     ,mySource.[GroupName]
     ,mySource.[Active]
     ,mySource.[AutoAddYear]
     ,mySource.[ProgramID]
     ,mySource.[DonorCategoryID]
     ,mySource.[CreateUser]
     ,mySource.[CreateDate]
     ,mySource.[UpdateUser]
     ,mySource.[UpdateDate]
     ,mySource.[LifetimeDonorCategoryid]
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
