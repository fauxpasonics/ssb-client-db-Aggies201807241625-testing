SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXcustomeraddresses]
(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = NULL
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     svcETL
Date:     08/19/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXcustomeraddresses),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId



SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, addressid, shipto, description, address1, address2, city, state, zip, country, customerid, active
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(25), [active])),'DBNULL_NUMBER') + ISNULL(RTRIM( [address1]),'DBNULL_TEXT') + ISNULL(RTRIM( [address2]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [addressid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [city]),'DBNULL_TEXT') + ISNULL(RTRIM( [country]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [customerid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [description]),'DBNULL_TEXT') + ISNULL(RTRIM( [shipto]),'DBNULL_TEXT') + ISNULL(RTRIM( [state]),'DBNULL_TEXT') + ISNULL(RTRIM( [zip]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXcustomeraddresses

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (addressid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXcustomeraddresses AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.addressid = mySource.addressid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[addressid] = mySource.[addressid]
     ,myTarget.[shipto] = mySource.[shipto]
     ,myTarget.[description] = mySource.[description]
     ,myTarget.[address1] = mySource.[address1]
     ,myTarget.[address2] = mySource.[address2]
     ,myTarget.[city] = mySource.[city]
     ,myTarget.[state] = mySource.[state]
     ,myTarget.[zip] = mySource.[zip]
     ,myTarget.[country] = mySource.[country]
     ,myTarget.[customerid] = mySource.[customerid]
     ,myTarget.[active] = mySource.[active]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[addressid]
     ,[shipto]
     ,[description]
     ,[address1]
     ,[address2]
     ,[city]
     ,[state]
     ,[zip]
     ,[country]
     ,[customerid]
     ,[active]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[addressid]
     ,mySource.[shipto]
     ,mySource.[description]
     ,mySource.[address1]
     ,mySource.[address2]
     ,mySource.[city]
     ,mySource.[state]
     ,mySource.[zip]
     ,mySource.[country]
     ,mySource.[customerid]
     ,mySource.[active]
     )

WHEN NOT MATCHED BY SOURCE
THEN UPDATE SET
	myTarget.ETL_IsDeleted = 1,
	myTarget.ETL_DeletedDate = GETDATE()
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
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
