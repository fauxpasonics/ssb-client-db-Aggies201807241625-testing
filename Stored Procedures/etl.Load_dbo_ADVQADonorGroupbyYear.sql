SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVQADonorGroupbyYear]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVQADonorGroupbyYear),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  DonorGroupbyYearID, DonorGroupSummaryID, ContactId, GroupID, MemberYear, ProgramId, CategoryId, Lifetime, TerritoryCode, EstimatedYear, Notes, ComplimentaryMembership, CreateDate, CreateUser, UpdateDate, UpdateUser, DonorCount, ComplimentaryMembershipReason
INTO #SrcData
FROM ods.ADVQADonorGroupbyYear

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (DonorGroupbyYearID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVQADonorGroupbyYear AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.DonorGroupbyYearID = mySource.DonorGroupbyYearID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[DonorGroupbyYearID] = mySource.[DonorGroupbyYearID]
     ,myTarget.[DonorGroupSummaryID] = mySource.[DonorGroupSummaryID]
     ,myTarget.[ContactId] = mySource.[ContactId]
     ,myTarget.[GroupID] = mySource.[GroupID]
     ,myTarget.[MemberYear] = mySource.[MemberYear]
     ,myTarget.[ProgramId] = mySource.[ProgramId]
     ,myTarget.[CategoryId] = mySource.[CategoryId]
     ,myTarget.[Lifetime] = mySource.[Lifetime]
     ,myTarget.[TerritoryCode] = mySource.[TerritoryCode]
     ,myTarget.[EstimatedYear] = mySource.[EstimatedYear]
     ,myTarget.[Notes] = mySource.[Notes]
     ,myTarget.[ComplimentaryMembership] = mySource.[ComplimentaryMembership]
     ,myTarget.[CreateDate] = mySource.[CreateDate]
     ,myTarget.[CreateUser] = mySource.[CreateUser]
     ,myTarget.[UpdateDate] = mySource.[UpdateDate]
     ,myTarget.[UpdateUser] = mySource.[UpdateUser]
     ,myTarget.[DonorCount] = mySource.[DonorCount]
     ,myTarget.[ComplimentaryMembershipReason] = mySource.[ComplimentaryMembershipReason]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([DonorGroupbyYearID]
     ,[DonorGroupSummaryID]
     ,[ContactId]
     ,[GroupID]
     ,[MemberYear]
     ,[ProgramId]
     ,[CategoryId]
     ,[Lifetime]
     ,[TerritoryCode]
     ,[EstimatedYear]
     ,[Notes]
     ,[ComplimentaryMembership]
     ,[CreateDate]
     ,[CreateUser]
     ,[UpdateDate]
     ,[UpdateUser]
     ,[DonorCount]
     ,[ComplimentaryMembershipReason]
     )
VALUES
     (mySource.[DonorGroupbyYearID]
     ,mySource.[DonorGroupSummaryID]
     ,mySource.[ContactId]
     ,mySource.[GroupID]
     ,mySource.[MemberYear]
     ,mySource.[ProgramId]
     ,mySource.[CategoryId]
     ,mySource.[Lifetime]
     ,mySource.[TerritoryCode]
     ,mySource.[EstimatedYear]
     ,mySource.[Notes]
     ,mySource.[ComplimentaryMembership]
     ,mySource.[CreateDate]
     ,mySource.[CreateUser]
     ,mySource.[UpdateDate]
     ,mySource.[UpdateUser]
     ,mySource.[DonorCount]
     ,mySource.[ComplimentaryMembershipReason]
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
