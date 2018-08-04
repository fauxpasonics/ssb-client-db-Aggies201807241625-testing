SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixsysseatgrouptypes]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixsysseatgrouptypes),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixsysseatgrouptypecode, tixsysseatgrouptypedesc, tixsysseatgrouptypedisplayordr, tixsysseatgrptypenextleveldown, tixsysseatgrouptypeshortdesc, tixsysseatgrouptypeprocessctrl, tixsysseatgrouptypeinvntryctrl, tixsysseatgrouptypefieldscode, tixsysvalidtopseatgrouptype
, HASHBYTES('sha2_256', ISNULL(RTRIM( [tixsysseatgrouptypecode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypedesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypedisplayordr]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypefieldscode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypeinvntryctrl]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypeprocessctrl]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrouptypeshortdesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysseatgrptypenextleveldown]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsysvalidtopseatgrouptype]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixsysseatgrouptypes

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixsysseatgrouptypecode)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixsysseatgrouptypes AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixsysseatgrouptypecode = mySource.tixsysseatgrouptypecode 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixsysseatgrouptypecode] = mySource.[tixsysseatgrouptypecode]
     ,myTarget.[tixsysseatgrouptypedesc] = mySource.[tixsysseatgrouptypedesc]
     ,myTarget.[tixsysseatgrouptypedisplayordr] = mySource.[tixsysseatgrouptypedisplayordr]
     ,myTarget.[tixsysseatgrptypenextleveldown] = mySource.[tixsysseatgrptypenextleveldown]
     ,myTarget.[tixsysseatgrouptypeshortdesc] = mySource.[tixsysseatgrouptypeshortdesc]
     ,myTarget.[tixsysseatgrouptypeprocessctrl] = mySource.[tixsysseatgrouptypeprocessctrl]
     ,myTarget.[tixsysseatgrouptypeinvntryctrl] = mySource.[tixsysseatgrouptypeinvntryctrl]
     ,myTarget.[tixsysseatgrouptypefieldscode] = mySource.[tixsysseatgrouptypefieldscode]
     ,myTarget.[tixsysvalidtopseatgrouptype] = mySource.[tixsysvalidtopseatgrouptype]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixsysseatgrouptypecode]
     ,[tixsysseatgrouptypedesc]
     ,[tixsysseatgrouptypedisplayordr]
     ,[tixsysseatgrptypenextleveldown]
     ,[tixsysseatgrouptypeshortdesc]
     ,[tixsysseatgrouptypeprocessctrl]
     ,[tixsysseatgrouptypeinvntryctrl]
     ,[tixsysseatgrouptypefieldscode]
     ,[tixsysvalidtopseatgrouptype]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixsysseatgrouptypecode]
     ,mySource.[tixsysseatgrouptypedesc]
     ,mySource.[tixsysseatgrouptypedisplayordr]
     ,mySource.[tixsysseatgrptypenextleveldown]
     ,mySource.[tixsysseatgrouptypeshortdesc]
     ,mySource.[tixsysseatgrouptypeprocessctrl]
     ,mySource.[tixsysseatgrouptypeinvntryctrl]
     ,mySource.[tixsysseatgrouptypefieldscode]
     ,mySource.[tixsysvalidtopseatgrouptype]
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
