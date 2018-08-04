SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVContactAddresses]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVContactAddresses),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  PK, ContactID, Code, AttnName, Company, Address1, Address2, Address3, City, State, Zip, County, Country, StartDate, EndDate, Region, PrimaryAddress, Salutation, TicketAddress
INTO #SrcData
FROM ods.ADVContactAddresses

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (PK)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVContactAddresses AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.PK = mySource.PK

WHEN MATCHED

THEN UPDATE SET
      myTarget.[PK] = mySource.[PK]
     ,myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[Code] = mySource.[Code]
     ,myTarget.[AttnName] = mySource.[AttnName]
     ,myTarget.[Company] = mySource.[Company]
     ,myTarget.[Address1] = mySource.[Address1]
     ,myTarget.[Address2] = mySource.[Address2]
     ,myTarget.[Address3] = mySource.[Address3]
     ,myTarget.[City] = mySource.[City]
     ,myTarget.[State] = mySource.[State]
     ,myTarget.[Zip] = mySource.[Zip]
     ,myTarget.[County] = mySource.[County]
     ,myTarget.[Country] = mySource.[Country]
     ,myTarget.[StartDate] = mySource.[StartDate]
     ,myTarget.[EndDate] = mySource.[EndDate]
     ,myTarget.[Region] = mySource.[Region]
     ,myTarget.[PrimaryAddress] = mySource.[PrimaryAddress]
     ,myTarget.[Salutation] = mySource.[Salutation]
     ,myTarget.[TicketAddress] = mySource.[TicketAddress]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([PK]
     ,[ContactID]
     ,[Code]
     ,[AttnName]
     ,[Company]
     ,[Address1]
     ,[Address2]
     ,[Address3]
     ,[City]
     ,[State]
     ,[Zip]
     ,[County]
     ,[Country]
     ,[StartDate]
     ,[EndDate]
     ,[Region]
     ,[PrimaryAddress]
     ,[Salutation]
     ,[TicketAddress]
     )
VALUES
     (mySource.[PK]
     ,mySource.[ContactID]
     ,mySource.[Code]
     ,mySource.[AttnName]
     ,mySource.[Company]
     ,mySource.[Address1]
     ,mySource.[Address2]
     ,mySource.[Address3]
     ,mySource.[City]
     ,mySource.[State]
     ,mySource.[Zip]
     ,mySource.[County]
     ,mySource.[Country]
     ,mySource.[StartDate]
     ,mySource.[EndDate]
     ,mySource.[Region]
     ,mySource.[PrimaryAddress]
     ,mySource.[Salutation]
     ,mySource.[TicketAddress]
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
