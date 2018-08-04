SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixevents]
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
Date:     08/24/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixevents),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixeventid, tixeventtitleshort, tixeventtitlelong, tixeventonsale, tixeventstartdate, tixeventenddate, tixeventgatesopen, tixeventtourid, tixeventlookupid, tixeventinitdate, tixeventlastupdwhen, tixeventlastupdatewho, tixeventtype, tixeventemailnotifydate, tixeventcategoryid, establishmenttype, tixrenewalid, tixeventcurrentuntil, display_in_reports, tixeventdisplaydate, tixeventimagepath, tixeventsoundfilepath, tixeventvisible, eticketschedule, allowcontinueshopping, venueestablishmenttype, venueestablishmentkey, ac_exportevent, client_id, flashseats_schedule, tixeventversion, tixeventkeywords, tixeventinternalinformation, web_tracking_profile_id, default_offer_id, visible_to_web, image_id, flasheventid
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(10), [ac_exportevent])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [allowcontinueshopping])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [default_offer_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [display_in_reports])),'DBNULL_INT') + ISNULL(RTRIM( [establishmenttype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [eticketschedule])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [flasheventid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [flashseats_schedule])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [image_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixeventcategoryid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventcurrentuntil])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventdisplaydate]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventemailnotifydate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventenddate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventgatesopen])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [tixeventid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixeventimagepath]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventinternalinformation]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventkeywords]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventlastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventlastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventlookupid]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventonsale])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventsoundfilepath]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventstartdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventtitlelong]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventtitleshort]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventtourid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventtype])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixeventversion])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventvisible])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixrenewalid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [venueestablishmentkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [venueestablishmenttype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [visible_to_web])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [web_tracking_profile_id])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixevents

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixevents AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixeventid = mySource.tixeventid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventtitleshort] = mySource.[tixeventtitleshort]
     ,myTarget.[tixeventtitlelong] = mySource.[tixeventtitlelong]
     ,myTarget.[tixeventonsale] = mySource.[tixeventonsale]
     ,myTarget.[tixeventstartdate] = mySource.[tixeventstartdate]
     ,myTarget.[tixeventenddate] = mySource.[tixeventenddate]
     ,myTarget.[tixeventgatesopen] = mySource.[tixeventgatesopen]
     ,myTarget.[tixeventtourid] = mySource.[tixeventtourid]
     ,myTarget.[tixeventlookupid] = mySource.[tixeventlookupid]
     ,myTarget.[tixeventinitdate] = mySource.[tixeventinitdate]
     ,myTarget.[tixeventlastupdwhen] = mySource.[tixeventlastupdwhen]
     ,myTarget.[tixeventlastupdatewho] = mySource.[tixeventlastupdatewho]
     ,myTarget.[tixeventtype] = mySource.[tixeventtype]
     ,myTarget.[tixeventemailnotifydate] = mySource.[tixeventemailnotifydate]
     ,myTarget.[tixeventcategoryid] = mySource.[tixeventcategoryid]
     ,myTarget.[establishmenttype] = mySource.[establishmenttype]
     ,myTarget.[tixrenewalid] = mySource.[tixrenewalid]
     ,myTarget.[tixeventcurrentuntil] = mySource.[tixeventcurrentuntil]
     ,myTarget.[display_in_reports] = mySource.[display_in_reports]
     ,myTarget.[tixeventdisplaydate] = mySource.[tixeventdisplaydate]
     ,myTarget.[tixeventimagepath] = mySource.[tixeventimagepath]
     ,myTarget.[tixeventsoundfilepath] = mySource.[tixeventsoundfilepath]
     ,myTarget.[tixeventvisible] = mySource.[tixeventvisible]
     ,myTarget.[eticketschedule] = mySource.[eticketschedule]
     ,myTarget.[allowcontinueshopping] = mySource.[allowcontinueshopping]
     ,myTarget.[venueestablishmenttype] = mySource.[venueestablishmenttype]
     ,myTarget.[venueestablishmentkey] = mySource.[venueestablishmentkey]
     ,myTarget.[ac_exportevent] = mySource.[ac_exportevent]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[flashseats_schedule] = mySource.[flashseats_schedule]
     ,myTarget.[tixeventversion] = mySource.[tixeventversion]
     ,myTarget.[tixeventkeywords] = mySource.[tixeventkeywords]
     ,myTarget.[tixeventinternalinformation] = mySource.[tixeventinternalinformation]
     ,myTarget.[web_tracking_profile_id] = mySource.[web_tracking_profile_id]
     ,myTarget.[default_offer_id] = mySource.[default_offer_id]
     ,myTarget.[visible_to_web] = mySource.[visible_to_web]
     ,myTarget.[image_id] = mySource.[image_id]
     ,myTarget.[flasheventid] = mySource.[flasheventid]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixeventid]
     ,[tixeventtitleshort]
     ,[tixeventtitlelong]
     ,[tixeventonsale]
     ,[tixeventstartdate]
     ,[tixeventenddate]
     ,[tixeventgatesopen]
     ,[tixeventtourid]
     ,[tixeventlookupid]
     ,[tixeventinitdate]
     ,[tixeventlastupdwhen]
     ,[tixeventlastupdatewho]
     ,[tixeventtype]
     ,[tixeventemailnotifydate]
     ,[tixeventcategoryid]
     ,[establishmenttype]
     ,[tixrenewalid]
     ,[tixeventcurrentuntil]
     ,[display_in_reports]
     ,[tixeventdisplaydate]
     ,[tixeventimagepath]
     ,[tixeventsoundfilepath]
     ,[tixeventvisible]
     ,[eticketschedule]
     ,[allowcontinueshopping]
     ,[venueestablishmenttype]
     ,[venueestablishmentkey]
     ,[ac_exportevent]
     ,[client_id]
     ,[flashseats_schedule]
     ,[tixeventversion]
     ,[tixeventkeywords]
     ,[tixeventinternalinformation]
     ,[web_tracking_profile_id]
     ,[default_offer_id]
     ,[visible_to_web]
     ,[image_id]
     ,[flasheventid]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixeventid]
     ,mySource.[tixeventtitleshort]
     ,mySource.[tixeventtitlelong]
     ,mySource.[tixeventonsale]
     ,mySource.[tixeventstartdate]
     ,mySource.[tixeventenddate]
     ,mySource.[tixeventgatesopen]
     ,mySource.[tixeventtourid]
     ,mySource.[tixeventlookupid]
     ,mySource.[tixeventinitdate]
     ,mySource.[tixeventlastupdwhen]
     ,mySource.[tixeventlastupdatewho]
     ,mySource.[tixeventtype]
     ,mySource.[tixeventemailnotifydate]
     ,mySource.[tixeventcategoryid]
     ,mySource.[establishmenttype]
     ,mySource.[tixrenewalid]
     ,mySource.[tixeventcurrentuntil]
     ,mySource.[display_in_reports]
     ,mySource.[tixeventdisplaydate]
     ,mySource.[tixeventimagepath]
     ,mySource.[tixeventsoundfilepath]
     ,mySource.[tixeventvisible]
     ,mySource.[eticketschedule]
     ,mySource.[allowcontinueshopping]
     ,mySource.[venueestablishmenttype]
     ,mySource.[venueestablishmentkey]
     ,mySource.[ac_exportevent]
     ,mySource.[client_id]
     ,mySource.[flashseats_schedule]
     ,mySource.[tixeventversion]
     ,mySource.[tixeventkeywords]
     ,mySource.[tixeventinternalinformation]
     ,mySource.[web_tracking_profile_id]
     ,mySource.[default_offer_id]
     ,mySource.[visible_to_web]
     ,mySource.[image_id]
     ,mySource.[flasheventid]
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
