SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[Load_ods_VTXcustomerfielddata]
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
Date:     04/29/2016
Comments: Initial creation
*************************************************************************************/


/*
DECLARE @BatchId INT = 0
DECLARE @Options NVARCHAR(MAX) = NULL
--*/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM ods.VTXcustomerfielddata),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

DECLARE @ETL_ID INT
DECLARE @ETL_CreatedDate DATETIME
DECLARE	@ETL_SourceFileName NVARCHAR(255)

SET @ETL_ID = (SELECT TOP 1  ETL_ID FROM src.VTXcustomerfielddata)
SET @ETL_CreatedDate = (SELECT TOP 1  ETL_CreatedDate FROM src.VTXcustomerfielddata)
SET @ETL_SourceFileName = (SELECT TOP 1  ETL_SourceFileName FROM src.VTXcustomerfielddata)

SELECT DISTINCT @ETL_ID ETL_ID, @ETL_CreatedDate ETL_CreatedDate, @ETL_SourceFileName ETL_SourceFileName, customerid, customerfieldid, stringvalue, datevalue, numericvalue
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(50), [customerfieldid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [customerid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [datevalue])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [numericvalue])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXcustomerfielddata

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (customerid,customerfieldid)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXcustomerfielddata AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.customerid = mySource.customerid AND myTarget.customerfieldid = mySource.customerfieldid 
	AND ISNULL(myTarget.stringvalue, '') = ISNULL(mySource.stringvalue, '')
	AND ISNULL(myTarget.datevalue, '1900-01-01') = ISNULL(mySource.datevalue, '1900-01-01')
	AND ISNULL(myTarget.numericvalue, 0.0) = ISNULL(mySource.numericvalue, 0.0)

WHEN MATCHED AND (myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey OR myTarget.stringvalue <> mySource.stringvalue)

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[customerid] = mySource.[customerid]
     ,myTarget.[customerfieldid] = mySource.[customerfieldid]
     ,myTarget.[stringvalue] = mySource.[stringvalue]
     ,myTarget.[datevalue] = mySource.[datevalue]
     ,myTarget.[numericvalue] = mySource.[numericvalue]

WHEN NOT MATCHED BY SOURCE THEN DELETE
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
     ,[ETL_DeltaHashKey]
     ,[customerid]
     ,[customerfieldid]
     ,[stringvalue]
     ,[datevalue]
     ,[numericvalue]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[customerid]
     ,mySource.[customerfieldid]
     ,mySource.[stringvalue]
     ,mySource.[datevalue]
     ,mySource.[numericvalue]
     )
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
