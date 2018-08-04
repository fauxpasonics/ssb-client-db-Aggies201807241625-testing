SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixsyspricelevels]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixsyspricelevels),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixsyspricelevelcode, tixsyspriceleveldesc, tixsyspricelevelinitdate, tixsyspricelevellastupdwhen, tixsyspricelevellastupdatewho, tixsyspricelevelcolors, tixsyspriceleveltype, tixsyspricelevelmodatnextlevel, tissyspriceleveldispord, tixsyshiddenstatus
, HASHBYTES('sha2_256', ISNULL(RTRIM( [tissyspriceleveldispord]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyshiddenstatus]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricelevelcode])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixsyspricelevelcolors]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspriceleveldesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricelevelinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixsyspricelevellastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixsyspricelevellastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixsyspricelevelmodatnextlevel]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixsyspriceleveltype]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixsyspricelevels

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixsyspricelevelcode)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixsyspricelevels AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixsyspricelevelcode = mySource.tixsyspricelevelcode 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixsyspricelevelcode] = mySource.[tixsyspricelevelcode]
     ,myTarget.[tixsyspriceleveldesc] = mySource.[tixsyspriceleveldesc]
     ,myTarget.[tixsyspricelevelinitdate] = mySource.[tixsyspricelevelinitdate]
     ,myTarget.[tixsyspricelevellastupdwhen] = mySource.[tixsyspricelevellastupdwhen]
     ,myTarget.[tixsyspricelevellastupdatewho] = mySource.[tixsyspricelevellastupdatewho]
     ,myTarget.[tixsyspricelevelcolors] = mySource.[tixsyspricelevelcolors]
     ,myTarget.[tixsyspriceleveltype] = mySource.[tixsyspriceleveltype]
     ,myTarget.[tixsyspricelevelmodatnextlevel] = mySource.[tixsyspricelevelmodatnextlevel]
     ,myTarget.[tissyspriceleveldispord] = mySource.[tissyspriceleveldispord]
     ,myTarget.[tixsyshiddenstatus] = mySource.[tixsyshiddenstatus]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixsyspricelevelcode]
     ,[tixsyspriceleveldesc]
     ,[tixsyspricelevelinitdate]
     ,[tixsyspricelevellastupdwhen]
     ,[tixsyspricelevellastupdatewho]
     ,[tixsyspricelevelcolors]
     ,[tixsyspriceleveltype]
     ,[tixsyspricelevelmodatnextlevel]
     ,[tissyspriceleveldispord]
     ,[tixsyshiddenstatus]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixsyspricelevelcode]
     ,mySource.[tixsyspriceleveldesc]
     ,mySource.[tixsyspricelevelinitdate]
     ,mySource.[tixsyspricelevellastupdwhen]
     ,mySource.[tixsyspricelevellastupdatewho]
     ,mySource.[tixsyspricelevelcolors]
     ,mySource.[tixsyspriceleveltype]
     ,mySource.[tixsyspricelevelmodatnextlevel]
     ,mySource.[tissyspriceleveldispord]
     ,mySource.[tixsyshiddenstatus]
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
