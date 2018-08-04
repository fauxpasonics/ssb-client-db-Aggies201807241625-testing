SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[Load_dbo_ADVQAContactExtendedInfo]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVQAContactExtendedInfo),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  contactid, ADNumber, AlumniInfo, ContactType, PrefClassYear, SpousePrefClassYear, AdvanceID, AdvancePrefName, AdvanceSpouseName, AdvanceEmail, Gender, PreferredSchool, SpouseAdvanceID, AdvanceLifetimegiving, AdvanceOrgname, CreateDate, UpdateDate
INTO #SrcData
FROM ods.ADVQAContactExtendedInfo

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ContactID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVQAContactExtendedInfo AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ContactID = mySource.ContactID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[contactid] = mySource.[contactid]
     ,myTarget.[ADNumber] = mySource.[ADNumber]
     ,myTarget.[AlumniInfo] = mySource.[AlumniInfo]
     ,myTarget.[ContactType] = mySource.[ContactType]
     ,myTarget.[PrefClassYear] = mySource.[PrefClassYear]
     ,myTarget.[SpousePrefClassYear] = mySource.[SpousePrefClassYear]
     ,myTarget.[AdvanceID] = mySource.[AdvanceID]
     ,myTarget.[AdvancePrefName] = mySource.[AdvancePrefName]
     ,myTarget.[AdvanceSpouseName] = mySource.[AdvanceSpouseName]
     ,myTarget.[AdvanceEmail] = mySource.[AdvanceEmail]
	 ,myTarget.[Gender] = mySource.[Gender]
	 ,myTarget.[PreferredSchool] = mySource.[PreferredSchool]
	 ,myTarget.[SpouseAdvanceID] = mySource.[SpouseAdvanceID]
	 ,myTarget.[AdvanceLifetimegiving] = mySource.[AdvanceLifetimegiving]
	 ,myTarget.[AdvanceOrgName] = mySource.[AdvanceOrgName]
     ,myTarget.[CreateDate] = mySource.[CreateDate]
     ,myTarget.[UpdateDate] = mySource.[UpdateDate]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([contactid]
     ,[ADNumber]
     ,[AlumniInfo]
     ,[ContactType]
     ,[PrefClassYear]
     ,[SpousePrefClassYear]
     ,[AdvanceID]
     ,[AdvancePrefName]
     ,[AdvanceSpouseName]
     ,[AdvanceEmail]
	 ,Gender
	 ,PreferredSchool
	 ,SpouseAdvanceID
	 ,AdvanceLifetimegiving
	 ,AdvanceOrgName
     ,[CreateDate]
     ,[UpdateDate]
     )
VALUES
     (mySource.[contactid]
     ,mySource.[ADNumber]
     ,mySource.[AlumniInfo]
     ,mySource.[ContactType]
     ,mySource.[PrefClassYear]
     ,mySource.[SpousePrefClassYear]
     ,mySource.[AdvanceID]
     ,mySource.[AdvancePrefName]
     ,mySource.[AdvanceSpouseName]
     ,mySource.[AdvanceEmail]
	 ,Gender
	 ,PreferredSchool
	 ,SpouseAdvanceID
	 ,AdvanceLifetimegiving
	 ,AdvanceOrgName
     ,mySource.[CreateDate]
     ,mySource.[UpdateDate]
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
