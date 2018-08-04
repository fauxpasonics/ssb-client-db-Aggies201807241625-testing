SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	CREATE PROCEDURE [etl].[Load_dbo_ADVProgram]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVProgram),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ProgramID, ProgramCode, ProgramName, ProgramGroup, PriorityPercent, SpecialEvent, Inactive, GLAccount, MoneyPoints, LifetimeGiving, DonationValue, Percentage, AvailableOnline, OnlineDescription, BalanceOnline, CapDriveYear, PayInFullRequired, AllowPaySchedules, DeadlineDate
INTO #SrcData
FROM ods.ADVProgram

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ProgramID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVProgram AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ProgramID = mySource.ProgramID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[ProgramID] = mySource.[ProgramID]
     ,myTarget.[ProgramCode] = mySource.[ProgramCode]
     ,myTarget.[ProgramName] = mySource.[ProgramName]
     ,myTarget.[ProgramGroup] = mySource.[ProgramGroup]
     ,myTarget.[PriorityPercent] = mySource.[PriorityPercent]
     ,myTarget.[SpecialEvent] = mySource.[SpecialEvent]
     ,myTarget.[Inactive] = mySource.[Inactive]
     ,myTarget.[GLAccount] = mySource.[GLAccount]
     ,myTarget.[MoneyPoints] = mySource.[MoneyPoints]
     ,myTarget.[LifetimeGiving] = mySource.[LifetimeGiving]
     ,myTarget.[DonationValue] = mySource.[DonationValue]
     ,myTarget.[Percentage] = mySource.[Percentage]
     ,myTarget.[AvailableOnline] = mySource.[AvailableOnline]
     ,myTarget.[OnlineDescription] = mySource.[OnlineDescription]
     ,myTarget.[BalanceOnline] = mySource.[BalanceOnline]
     ,myTarget.[CapDriveYear] = mySource.[CapDriveYear]
     ,myTarget.[PayInFullRequired] = mySource.[PayInFullRequired]
     ,myTarget.[AllowPaySchedules] = mySource.[AllowPaySchedules]
     ,myTarget.[DeadlineDate] = mySource.[DeadlineDate]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ProgramID]
     ,[ProgramCode]
     ,[ProgramName]
     ,[ProgramGroup]
     ,[PriorityPercent]
     ,[SpecialEvent]
     ,[Inactive]
     ,[GLAccount]
     ,[MoneyPoints]
     ,[LifetimeGiving]
     ,[DonationValue]
     ,[Percentage]
     ,[AvailableOnline]
     ,[OnlineDescription]
     ,[BalanceOnline]
     ,[CapDriveYear]
     ,[PayInFullRequired]
     ,[AllowPaySchedules]
     ,[DeadlineDate]
     )
VALUES
     (mySource.[ProgramID]
     ,mySource.[ProgramCode]
     ,mySource.[ProgramName]
     ,mySource.[ProgramGroup]
     ,mySource.[PriorityPercent]
     ,mySource.[SpecialEvent]
     ,mySource.[Inactive]
     ,mySource.[GLAccount]
     ,mySource.[MoneyPoints]
     ,mySource.[LifetimeGiving]
     ,mySource.[DonationValue]
     ,mySource.[Percentage]
     ,mySource.[AvailableOnline]
     ,mySource.[OnlineDescription]
     ,mySource.[BalanceOnline]
     ,mySource.[CapDriveYear]
     ,mySource.[PayInFullRequired]
     ,mySource.[AllowPaySchedules]
     ,mySource.[DeadlineDate]
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
