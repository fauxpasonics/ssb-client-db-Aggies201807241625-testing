SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_ods_VTXcategory]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXcategory),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, categoryid, categorytypeid, categoryname, categorydescription, categorystatus, establishmenttype, establishmentkey, parentid, grandparentid, greatgrandparentid, imagepath, lastupdated, lastupdatedby, createdate, displayorder, client_id
, HASHBYTES('sha2_256', ISNULL(RTRIM( [categorydescription]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [categoryid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [categoryname]),'DBNULL_TEXT') + ISNULL(RTRIM( [categorystatus]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [categorytypeid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [createdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [displayorder])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [establishmentkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [establishmenttype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [grandparentid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [greatgrandparentid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [imagepath]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [lastupdated])),'DBNULL_DATETIME') + ISNULL(RTRIM( [lastupdatedby]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [parentid])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXcategory

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (categoryid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXcategory AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.categoryid = mySource.categoryid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[categoryid] = mySource.[categoryid]
     ,myTarget.[categorytypeid] = mySource.[categorytypeid]
     ,myTarget.[categoryname] = mySource.[categoryname]
     ,myTarget.[categorydescription] = mySource.[categorydescription]
     ,myTarget.[categorystatus] = mySource.[categorystatus]
     ,myTarget.[establishmenttype] = mySource.[establishmenttype]
     ,myTarget.[establishmentkey] = mySource.[establishmentkey]
     ,myTarget.[parentid] = mySource.[parentid]
     ,myTarget.[grandparentid] = mySource.[grandparentid]
     ,myTarget.[greatgrandparentid] = mySource.[greatgrandparentid]
     ,myTarget.[imagepath] = mySource.[imagepath]
     ,myTarget.[lastupdated] = mySource.[lastupdated]
     ,myTarget.[lastupdatedby] = mySource.[lastupdatedby]
     ,myTarget.[createdate] = mySource.[createdate]
     ,myTarget.[displayorder] = mySource.[displayorder]
     ,myTarget.[client_id] = mySource.[client_id]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[categoryid]
     ,[categorytypeid]
     ,[categoryname]
     ,[categorydescription]
     ,[categorystatus]
     ,[establishmenttype]
     ,[establishmentkey]
     ,[parentid]
     ,[grandparentid]
     ,[greatgrandparentid]
     ,[imagepath]
     ,[lastupdated]
     ,[lastupdatedby]
     ,[createdate]
     ,[displayorder]
     ,[client_id]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[categoryid]
     ,mySource.[categorytypeid]
     ,mySource.[categoryname]
     ,mySource.[categorydescription]
     ,mySource.[categorystatus]
     ,mySource.[establishmenttype]
     ,mySource.[establishmentkey]
     ,mySource.[parentid]
     ,mySource.[grandparentid]
     ,mySource.[greatgrandparentid]
     ,mySource.[imagepath]
     ,mySource.[lastupdated]
     ,mySource.[lastupdatedby]
     ,mySource.[createdate]
     ,mySource.[displayorder]
     ,mySource.[client_id]
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
