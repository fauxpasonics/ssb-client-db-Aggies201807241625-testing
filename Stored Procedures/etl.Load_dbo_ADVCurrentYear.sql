SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVCurrentYear]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVCurrentYear),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  CurrentYear, CurrentSeason, TicketOfficeEmail, UDF1, UDF2, UDF3, UDF4, UDF5, FirstBillingMonth, SchoolID, EmailProgram, PriorityPointCalc, DonorNet, DonorNetYear, DonorNetSeason, PacXfer, AddressChangeEmail
INTO #SrcData
FROM ods.ADVCurrentYear

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (CurrentYear)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVCurrentYear AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.CurrentYear = mySource.CurrentYear

WHEN MATCHED

THEN UPDATE SET
      myTarget.[CurrentYear] = mySource.[CurrentYear]
     ,myTarget.[CurrentSeason] = mySource.[CurrentSeason]
     ,myTarget.[TicketOfficeEmail] = mySource.[TicketOfficeEmail]
     ,myTarget.[UDF1] = mySource.[UDF1]
     ,myTarget.[UDF2] = mySource.[UDF2]
     ,myTarget.[UDF3] = mySource.[UDF3]
     ,myTarget.[UDF4] = mySource.[UDF4]
     ,myTarget.[UDF5] = mySource.[UDF5]
     ,myTarget.[FirstBillingMonth] = mySource.[FirstBillingMonth]
     ,myTarget.[SchoolID] = mySource.[SchoolID]
     ,myTarget.[EmailProgram] = mySource.[EmailProgram]
     ,myTarget.[PriorityPointCalc] = mySource.[PriorityPointCalc]
     ,myTarget.[DonorNet] = mySource.[DonorNet]
     ,myTarget.[DonorNetYear] = mySource.[DonorNetYear]
     ,myTarget.[DonorNetSeason] = mySource.[DonorNetSeason]
     ,myTarget.[PacXfer] = mySource.[PacXfer]
     ,myTarget.[AddressChangeEmail] = mySource.[AddressChangeEmail]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([CurrentYear]
     ,[CurrentSeason]
     ,[TicketOfficeEmail]
     ,[UDF1]
     ,[UDF2]
     ,[UDF3]
     ,[UDF4]
     ,[UDF5]
     ,[FirstBillingMonth]
     ,[SchoolID]
     ,[EmailProgram]
     ,[PriorityPointCalc]
     ,[DonorNet]
     ,[DonorNetYear]
     ,[DonorNetSeason]
     ,[PacXfer]
     ,[AddressChangeEmail]
     )
VALUES
     (mySource.[CurrentYear]
     ,mySource.[CurrentSeason]
     ,mySource.[TicketOfficeEmail]
     ,mySource.[UDF1]
     ,mySource.[UDF2]
     ,mySource.[UDF3]
     ,mySource.[UDF4]
     ,mySource.[UDF5]
     ,mySource.[FirstBillingMonth]
     ,mySource.[SchoolID]
     ,mySource.[EmailProgram]
     ,mySource.[PriorityPointCalc]
     ,mySource.[DonorNet]
     ,mySource.[DonorNetYear]
     ,mySource.[DonorNetSeason]
     ,mySource.[PacXfer]
     ,mySource.[AddressChangeEmail]
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
