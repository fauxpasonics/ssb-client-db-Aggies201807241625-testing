SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzoneseats]
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
Date:     08/31/2015
Comments: Initial creation
*************************************************************************************/



DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixeventzoneseats),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixeventid, tixeventzoneid, tixseatgroupid, tixseatid, tixseatdesc, tixseatcurrentstatus, tixseatecommercehdrlink, tixseatecommercedtllink, tixseatseasonticket, tixseatbarcode, tixseatdefltavailstatus, tixseatprintcount, tixseatnexthistoryptr, tixseatprimaryspeccode, tixseatpricecode, tixseatvaluebeforediscounts, tixseatpriceafterdiscounts, tixseatpaidtodate, tixseatpricetoprintonticket, tixseatsold, tixseatpaid, tixseatrenewable, tixseatthiseventownersuserid, tixseatnexteventownersuserid, tixseatholdexpiration, tixseatsoldfromoutlet, tixseatprintbatchid, tixseatpackageon, tixseatpackage, tixseatpackageid, tixseatspecialtycode_ctrlreqd, tixseatspecialtycode_ctrlopt, tixseatlastupdate, tixseatprintable, tixseatprinted, tixseatshipdate, tixseatshipservecharge, tixseatrenewalexpiredate, tixseatprojectedprice, tixseateventtype, tixseatprintfilename, tixseatpkgpricecode, tixseatmod, tixseatshippingoption, tixseattrackingnumber, tixseatofferid, tixseatlastscandate, tixseatoffergroupid, tixseatordergroupid, tixseatinfo1, tixseatinfo2, tixseatlocked, change_group_id, seat_bit_flags, tixhandheldmessage_id, tixseatdisplayorder, paper_converted
, HASHBYTES('sha2_256', ISNULL(RTRIM( [change_group_id]),'DBNULL_TEXT') + ISNULL(RTRIM( [paper_converted]),'DBNULL_TEXT') + ISNULL(RTRIM( [seat_bit_flags]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixhandheldmessage_id]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatbarcode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatcurrentstatus]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatdefltavailstatus]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatdesc]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatdisplayorder]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatecommercedtllink]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatecommercehdrlink]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseateventtype]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatgroupid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatholdexpiration]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatinfo1]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatinfo2]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatlastscandate]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatlastupdate]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatlocked]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatmod]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatnexteventownersuserid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatnexthistoryptr]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatoffergroupid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatofferid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatordergroupid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpackage]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpackageid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpackageon]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpaid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpaidtodate]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpkgpricecode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpriceafterdiscounts]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpricecode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatpricetoprintonticket]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprimaryspeccode]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprintable]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprintbatchid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprintcount]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprinted]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprintfilename]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatprojectedprice]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatrenewable]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatrenewalexpiredate]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatseasonticket]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatshipdate]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatshippingoption]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatshipservecharge]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatsold]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatsoldfromoutlet]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatspecialtycode_ctrlopt]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatspecialtycode_ctrlreqd]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatthiseventownersuserid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseattrackingnumber]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixseatvaluebeforediscounts]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixeventzoneseats

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid, tixeventzoneid, tixseatgroupid, tixseatid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId


DECLARE @RunTime DATETIME = GETDATE()

MERGE ods.VTXtixeventzoneseats AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixeventid = mySource.tixeventid AND myTarget.tixeventzoneid = mySource.tixeventzoneid AND myTarget.tixseatid = mySource.tixseatid AND mySource.tixseatgroupid = myTarget.tixseatgroupid

WHEN MATCHED AND ISNULL(myTarget.ETL_DeltaHashKey, 0) <> ISNULL(mySource.ETL_DeltaHashKey,0)

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventzoneid] = mySource.[tixeventzoneid]
     ,myTarget.[tixseatgroupid] = mySource.[tixseatgroupid]
     ,myTarget.[tixseatid] = mySource.[tixseatid]
     ,myTarget.[tixseatdesc] = mySource.[tixseatdesc]
     ,myTarget.[tixseatcurrentstatus] = mySource.[tixseatcurrentstatus]
     ,myTarget.[tixseatecommercehdrlink] = mySource.[tixseatecommercehdrlink]
     ,myTarget.[tixseatecommercedtllink] = mySource.[tixseatecommercedtllink]
     ,myTarget.[tixseatseasonticket] = mySource.[tixseatseasonticket]
     ,myTarget.[tixseatbarcode] = mySource.[tixseatbarcode]
     ,myTarget.[tixseatdefltavailstatus] = mySource.[tixseatdefltavailstatus]
     ,myTarget.[tixseatprintcount] = mySource.[tixseatprintcount]
     ,myTarget.[tixseatnexthistoryptr] = mySource.[tixseatnexthistoryptr]
     ,myTarget.[tixseatprimaryspeccode] = mySource.[tixseatprimaryspeccode]
     ,myTarget.[tixseatpricecode] = mySource.[tixseatpricecode]
     ,myTarget.[tixseatvaluebeforediscounts] = mySource.[tixseatvaluebeforediscounts]
     ,myTarget.[tixseatpriceafterdiscounts] = mySource.[tixseatpriceafterdiscounts]
     ,myTarget.[tixseatpaidtodate] = mySource.[tixseatpaidtodate]
     ,myTarget.[tixseatpricetoprintonticket] = mySource.[tixseatpricetoprintonticket]
     ,myTarget.[tixseatsold] = mySource.[tixseatsold]
     ,myTarget.[tixseatpaid] = mySource.[tixseatpaid]
     ,myTarget.[tixseatrenewable] = mySource.[tixseatrenewable]
     ,myTarget.[tixseatthiseventownersuserid] = mySource.[tixseatthiseventownersuserid]
     ,myTarget.[tixseatnexteventownersuserid] = mySource.[tixseatnexteventownersuserid]
     ,myTarget.[tixseatholdexpiration] = mySource.[tixseatholdexpiration]
     ,myTarget.[tixseatsoldfromoutlet] = mySource.[tixseatsoldfromoutlet]
     ,myTarget.[tixseatprintbatchid] = mySource.[tixseatprintbatchid]
     ,myTarget.[tixseatpackageon] = mySource.[tixseatpackageon]
     ,myTarget.[tixseatpackage] = mySource.[tixseatpackage]
     ,myTarget.[tixseatpackageid] = mySource.[tixseatpackageid]
     ,myTarget.[tixseatspecialtycode_ctrlreqd] = mySource.[tixseatspecialtycode_ctrlreqd]
     ,myTarget.[tixseatspecialtycode_ctrlopt] = mySource.[tixseatspecialtycode_ctrlopt]
     ,myTarget.[tixseatlastupdate] = mySource.[tixseatlastupdate]
     ,myTarget.[tixseatprintable] = mySource.[tixseatprintable]
     ,myTarget.[tixseatprinted] = mySource.[tixseatprinted]
     ,myTarget.[tixseatshipdate] = mySource.[tixseatshipdate]
     ,myTarget.[tixseatshipservecharge] = mySource.[tixseatshipservecharge]
     ,myTarget.[tixseatrenewalexpiredate] = mySource.[tixseatrenewalexpiredate]
     ,myTarget.[tixseatprojectedprice] = mySource.[tixseatprojectedprice]
     ,myTarget.[tixseateventtype] = mySource.[tixseateventtype]
     ,myTarget.[tixseatprintfilename] = mySource.[tixseatprintfilename]
     ,myTarget.[tixseatpkgpricecode] = mySource.[tixseatpkgpricecode]
     ,myTarget.[tixseatmod] = mySource.[tixseatmod]
     ,myTarget.[tixseatshippingoption] = mySource.[tixseatshippingoption]
     ,myTarget.[tixseattrackingnumber] = mySource.[tixseattrackingnumber]
     ,myTarget.[tixseatofferid] = mySource.[tixseatofferid]
     ,myTarget.[tixseatlastscandate] = mySource.[tixseatlastscandate]
     ,myTarget.[tixseatoffergroupid] = mySource.[tixseatoffergroupid]
     ,myTarget.[tixseatordergroupid] = mySource.[tixseatordergroupid]
     ,myTarget.[tixseatinfo1] = mySource.[tixseatinfo1]
     ,myTarget.[tixseatinfo2] = mySource.[tixseatinfo2]
     ,myTarget.[tixseatlocked] = mySource.[tixseatlocked]
     ,myTarget.[change_group_id] = mySource.[change_group_id]
     ,myTarget.[seat_bit_flags] = mySource.[seat_bit_flags]
     ,myTarget.[tixhandheldmessage_id] = mySource.[tixhandheldmessage_id]
     ,myTarget.[tixseatdisplayorder] = mySource.[tixseatdisplayorder]
     ,myTarget.[paper_converted] = mySource.[paper_converted]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixeventid]
     ,[tixeventzoneid]
     ,[tixseatgroupid]
     ,[tixseatid]
     ,[tixseatdesc]
     ,[tixseatcurrentstatus]
     ,[tixseatecommercehdrlink]
     ,[tixseatecommercedtllink]
     ,[tixseatseasonticket]
     ,[tixseatbarcode]
     ,[tixseatdefltavailstatus]
     ,[tixseatprintcount]
     ,[tixseatnexthistoryptr]
     ,[tixseatprimaryspeccode]
     ,[tixseatpricecode]
     ,[tixseatvaluebeforediscounts]
     ,[tixseatpriceafterdiscounts]
     ,[tixseatpaidtodate]
     ,[tixseatpricetoprintonticket]
     ,[tixseatsold]
     ,[tixseatpaid]
     ,[tixseatrenewable]
     ,[tixseatthiseventownersuserid]
     ,[tixseatnexteventownersuserid]
     ,[tixseatholdexpiration]
     ,[tixseatsoldfromoutlet]
     ,[tixseatprintbatchid]
     ,[tixseatpackageon]
     ,[tixseatpackage]
     ,[tixseatpackageid]
     ,[tixseatspecialtycode_ctrlreqd]
     ,[tixseatspecialtycode_ctrlopt]
     ,[tixseatlastupdate]
     ,[tixseatprintable]
     ,[tixseatprinted]
     ,[tixseatshipdate]
     ,[tixseatshipservecharge]
     ,[tixseatrenewalexpiredate]
     ,[tixseatprojectedprice]
     ,[tixseateventtype]
     ,[tixseatprintfilename]
     ,[tixseatpkgpricecode]
     ,[tixseatmod]
     ,[tixseatshippingoption]
     ,[tixseattrackingnumber]
     ,[tixseatofferid]
     ,[tixseatlastscandate]
     ,[tixseatoffergroupid]
     ,[tixseatordergroupid]
     ,[tixseatinfo1]
     ,[tixseatinfo2]
     ,[tixseatlocked]
     ,[change_group_id]
     ,[seat_bit_flags]
     ,[tixhandheldmessage_id]
     ,[tixseatdisplayorder]
     ,[paper_converted]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixeventid]
     ,mySource.[tixeventzoneid]
     ,mySource.[tixseatgroupid]
     ,mySource.[tixseatid]
     ,mySource.[tixseatdesc]
     ,mySource.[tixseatcurrentstatus]
     ,mySource.[tixseatecommercehdrlink]
     ,mySource.[tixseatecommercedtllink]
     ,mySource.[tixseatseasonticket]
     ,mySource.[tixseatbarcode]
     ,mySource.[tixseatdefltavailstatus]
     ,mySource.[tixseatprintcount]
     ,mySource.[tixseatnexthistoryptr]
     ,mySource.[tixseatprimaryspeccode]
     ,mySource.[tixseatpricecode]
     ,mySource.[tixseatvaluebeforediscounts]
     ,mySource.[tixseatpriceafterdiscounts]
     ,mySource.[tixseatpaidtodate]
     ,mySource.[tixseatpricetoprintonticket]
     ,mySource.[tixseatsold]
     ,mySource.[tixseatpaid]
     ,mySource.[tixseatrenewable]
     ,mySource.[tixseatthiseventownersuserid]
     ,mySource.[tixseatnexteventownersuserid]
     ,mySource.[tixseatholdexpiration]
     ,mySource.[tixseatsoldfromoutlet]
     ,mySource.[tixseatprintbatchid]
     ,mySource.[tixseatpackageon]
     ,mySource.[tixseatpackage]
     ,mySource.[tixseatpackageid]
     ,mySource.[tixseatspecialtycode_ctrlreqd]
     ,mySource.[tixseatspecialtycode_ctrlopt]
     ,mySource.[tixseatlastupdate]
     ,mySource.[tixseatprintable]
     ,mySource.[tixseatprinted]
     ,mySource.[tixseatshipdate]
     ,mySource.[tixseatshipservecharge]
     ,mySource.[tixseatrenewalexpiredate]
     ,mySource.[tixseatprojectedprice]
     ,mySource.[tixseateventtype]
     ,mySource.[tixseatprintfilename]
     ,mySource.[tixseatpkgpricecode]
     ,mySource.[tixseatmod]
     ,mySource.[tixseatshippingoption]
     ,mySource.[tixseattrackingnumber]
     ,mySource.[tixseatofferid]
     ,mySource.[tixseatlastscandate]
     ,mySource.[tixseatoffergroupid]
     ,mySource.[tixseatordergroupid]
     ,mySource.[tixseatinfo1]
     ,mySource.[tixseatinfo2]
     ,mySource.[tixseatlocked]
     ,mySource.[change_group_id]
     ,mySource.[seat_bit_flags]
     ,mySource.[tixhandheldmessage_id]
     ,mySource.[tixseatdisplayorder]
     ,mySource.[paper_converted]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

--UPDATE ods.VTXtixeventzoneseats
--SET ETL_IsDeleted = 1,
--	ETL_DeletedDate = GETDATE()
--FROM ods.VTXtixeventzoneseats o
--LEFT JOIN src.VTXtixeventzoneseats_UK s ON s.tixeventid = o.tixeventid AND s.tixeventzoneid = o.tixeventzoneid AND s.tixseatid = o.tixseatid AND s.tixseatgroupid = o.tixseatgroupid 
--WHERE s.tixeventid IS null AND s.tixeventzoneid IS null AND s.tixseatid IS null AND s.tixseatgroupid IS null 

--EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Delete Process', 'Soft Deletes Process', 'Complete', @ExecutionId


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
