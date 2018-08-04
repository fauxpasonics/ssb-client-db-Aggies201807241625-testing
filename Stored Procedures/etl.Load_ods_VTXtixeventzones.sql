SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzones]
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
Date:     08/21/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixeventzones),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT distinct ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixeventid, tixeventzoneid, tixeventonsale, tixeventtourid, tixeventinitdate, tixeventlastupdwhen, tixeventbuiltfromseatmap, tixeventseatmaplocked, tixeventstatus, tixeventtopseatgrouptype, tixeventlastupdatewho, tixeventticketformat, tixeventtotalseats, tixeventtotalonsale, tixeventtotalremaining, tixeventtotalkills, tixeventtotalcomps, tixeventtotalonhold, tixeventtotalsold, tixeventtotalnonallocsold, tixeventtotalprinted, tixeventzonedesc, tixeventzonedispord, tixeventzonetype, tixeventinventorysecurityincl, tixeventinventorysearchinclude, tixeventzoneonsale, tixeventzonereadyforsale, tixeventzonenexteventid, tixeventzonepreveventid, tixeventzonenextzoneid, tixeventzoneprevzoneid, evtschedeventdb1estabtype, evtschedeventdb1estabkey, tixeventtotalpaid, tixeventtotalnonallocpaid, tixeventtotalsoldbucks, tixeventtotalnonallocsoldbucks, tixeventtotalpaidbucks, tixeventtotalnonallocpaidbucks, tixeventtotalsoldtod8, tixeventtotalnonallocsoldtod8, tixeventtotalsoldvalue, tixeventtotalpaidvalue, tixeventtotalnonallocsoldvalue, tixeventtotalnonallocpaidvalue, tixeventtotalcompsvalue, tixeventzonefullauditactive, tixeventflashmovieid, tixevtznproductvendortype, tixevtznproductvendorkey, tixevtznproductid, tixevtznavailabilitymsg, tixeventzoneallowsingles, tixevtznseatrequestseatgroup, tixeventtotalnonalloccomp, tixeventtotalnonalloccompvalue, tixevtznallowseatrequests, tixevtznseatrequestdate, tixeventzonenexthistoryid, tixeventpricechartlocked, tixeventeventlocked, tixeventzonenexterrorcheckid, tixeventzonerenewablefornextyr, tixeventoffsale, tixeventzonesectionpriormulti, tixevent_nba_rowsizefactor, tixevtznrunbackgroundintegchk, tixevtznseatrequestsonsale, tixevtznlastsccssfulintegchkd8, tixeventzonedisplay5nba1, tixeventzonedisplay5nba2, tixeventzonedisplay5nba3, tixeventzonedisplay5nba4, tixeventtotalseats_nona, tixeventtotalonsale_nona, tixeventtotalremaining_nona, tixeventtotalonhold_nona, tixeventtotalkills_nona, tixeventtotalallocations, tixevtznglcode, tixeventtotalconsign, tixeventconsignprice, tixeventzoneavailableforweb, tixeventzoneusestopcard, tixeventzoneiscanceled, tixeventzonecancellationdate, tixeventzonecancellationreason, display_in_reports, tixeventzoneeticketline1, tixeventzoneeticketline2, tixeventzoneeticketline3, tixeventzoneeticketline4, tixeventzoneeticketline5, tixeventzoneeticketline6, tixtransferfeeenabled, tixeventzoneallowtixforwarding, tixeventzoneallowonlinepayment, ac_lasthistoryptr, ac_exportzone, product_id, venue_map_id, is_published, client_id, event_owner_id, accesscontrolenddatetime, accesscontrolstartdatetime, enableaccesscontrol, tixeventzoneversion, tixeventzonemaxentry, tixeventzonemaxperday, tixeventzoneentryexit, stadis_active, stadis_exported, stadis_lasthistoryptr, sales_restrict, convertfsunpaid, seatmap_image_id, seatmap_image_mode, enable_paper_conversion, waive_paper_conversion_fee, salespricechartversion, printpricechartversion, textpricechartversion, single_forward
, HASHBYTES('sha2_256', ISNULL(RTRIM( [ac_exportzone]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [ac_lasthistoryptr])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [accesscontrolenddatetime])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [accesscontrolstartdatetime])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [convertfsunpaid]),'DBNULL_TEXT') + ISNULL(RTRIM( [display_in_reports]),'DBNULL_TEXT') + ISNULL(RTRIM( [enable_paper_conversion]),'DBNULL_TEXT') + ISNULL(RTRIM( [enableaccesscontrol]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [event_owner_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [evtschedeventdb1estabkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [evtschedeventdb1estabtype]),'DBNULL_TEXT') + ISNULL(RTRIM( [is_published]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [printpricechartversion])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [product_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [sales_restrict]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [salespricechartversion])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [seatmap_image_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [seatmap_image_mode]),'DBNULL_TEXT') + ISNULL(RTRIM( [stadis_active]),'DBNULL_TEXT') + ISNULL(RTRIM( [stadis_exported]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [stadis_lasthistoryptr])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [textpricechartversion])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixevent_nba_rowsizefactor]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventbuiltfromseatmap])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventconsignprice])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixeventeventlocked]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventflashmovieid]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventinventorysearchinclude]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventinventorysecurityincl]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventlastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventlastupdwhen])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventoffsale])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventonsale])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventpricechartlocked]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventseatmaplocked]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventstatus]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventticketformat]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventtopseatgrouptype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalallocations])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalcomps])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalcompsvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalconsign])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalkills])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalkills_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonalloccomp])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonalloccompvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocpaid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocpaidbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocpaidvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocsold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocsoldbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocsoldtod8])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalnonallocsoldvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalonhold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalonhold_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalonsale])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalonsale_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalpaid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalpaidbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalpaidvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalprinted])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalremaining])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalremaining_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalseats])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalseats_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalsold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalsoldbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalsoldtod8])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventtotalsoldvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventtourid])),'DBNULL_INT') + ISNULL(RTRIM( [tixeventzoneallowonlinepayment]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneallowsingles]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneallowtixforwarding]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneavailableforweb]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonecancellationdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixeventzonecancellationreason]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonedesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonedisplay5nba1])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonedisplay5nba2])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonedisplay5nba3])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonedisplay5nba4])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixeventzonedispord]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneentryexit]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline1]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline2]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline3]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline4]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline5]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneeticketline6]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonefullauditactive]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneiscanceled]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonemaxentry]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonemaxperday]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonenexterrorcheckid]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonenexteventid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventzonenexthistoryid])),'DBNULL_INT') + ISNULL(RTRIM( [tixeventzonenextzoneid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzoneonsale]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzonepreveventid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixeventzoneprevzoneid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonereadyforsale]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonerenewablefornextyr]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixeventzonesectionpriormulti]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventzonetype])),'DBNULL_INT') + ISNULL(RTRIM( [tixeventzoneusestopcard]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixeventzoneversion])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixevtznallowseatrequests]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznavailabilitymsg]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznglcode]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznlastsccssfulintegchkd8])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznproductid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznproductvendorkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixevtznproductvendortype]),'DBNULL_TEXT') + ISNULL(RTRIM( [tixevtznrunbackgroundintegchk]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixevtznseatrequestdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(10), [tixevtznseatrequestseatgroup])),'DBNULL_INT') + ISNULL(RTRIM( [tixevtznseatrequestsonsale]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [tixtransferfeeenabled])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [venue_map_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [waive_paper_conversion_fee]),'DBNULL_TEXT') + ISNULL(RTRIM( [single_forward]),'DBNULL_NUMBER') ) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXtixeventzones

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid, tixeventzoneid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixeventzones AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixeventid = mySource.tixeventid AND myTarget.tixeventzoneid = mySource.tixeventzoneid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventzoneid] = mySource.[tixeventzoneid]
     ,myTarget.[tixeventonsale] = mySource.[tixeventonsale]
     ,myTarget.[tixeventtourid] = mySource.[tixeventtourid]
     ,myTarget.[tixeventinitdate] = mySource.[tixeventinitdate]
     ,myTarget.[tixeventlastupdwhen] = mySource.[tixeventlastupdwhen]
     ,myTarget.[tixeventbuiltfromseatmap] = mySource.[tixeventbuiltfromseatmap]
     ,myTarget.[tixeventseatmaplocked] = mySource.[tixeventseatmaplocked]
     ,myTarget.[tixeventstatus] = mySource.[tixeventstatus]
     ,myTarget.[tixeventtopseatgrouptype] = mySource.[tixeventtopseatgrouptype]
     ,myTarget.[tixeventlastupdatewho] = mySource.[tixeventlastupdatewho]
     ,myTarget.[tixeventticketformat] = mySource.[tixeventticketformat]
     ,myTarget.[tixeventtotalseats] = mySource.[tixeventtotalseats]
     ,myTarget.[tixeventtotalonsale] = mySource.[tixeventtotalonsale]
     ,myTarget.[tixeventtotalremaining] = mySource.[tixeventtotalremaining]
     ,myTarget.[tixeventtotalkills] = mySource.[tixeventtotalkills]
     ,myTarget.[tixeventtotalcomps] = mySource.[tixeventtotalcomps]
     ,myTarget.[tixeventtotalonhold] = mySource.[tixeventtotalonhold]
     ,myTarget.[tixeventtotalsold] = mySource.[tixeventtotalsold]
     ,myTarget.[tixeventtotalnonallocsold] = mySource.[tixeventtotalnonallocsold]
     ,myTarget.[tixeventtotalprinted] = mySource.[tixeventtotalprinted]
     ,myTarget.[tixeventzonedesc] = mySource.[tixeventzonedesc]
     ,myTarget.[tixeventzonedispord] = mySource.[tixeventzonedispord]
     ,myTarget.[tixeventzonetype] = mySource.[tixeventzonetype]
     ,myTarget.[tixeventinventorysecurityincl] = mySource.[tixeventinventorysecurityincl]
     ,myTarget.[tixeventinventorysearchinclude] = mySource.[tixeventinventorysearchinclude]
     ,myTarget.[tixeventzoneonsale] = mySource.[tixeventzoneonsale]
     ,myTarget.[tixeventzonereadyforsale] = mySource.[tixeventzonereadyforsale]
     ,myTarget.[tixeventzonenexteventid] = mySource.[tixeventzonenexteventid]
     ,myTarget.[tixeventzonepreveventid] = mySource.[tixeventzonepreveventid]
     ,myTarget.[tixeventzonenextzoneid] = mySource.[tixeventzonenextzoneid]
     ,myTarget.[tixeventzoneprevzoneid] = mySource.[tixeventzoneprevzoneid]
     ,myTarget.[evtschedeventdb1estabtype] = mySource.[evtschedeventdb1estabtype]
     ,myTarget.[evtschedeventdb1estabkey] = mySource.[evtschedeventdb1estabkey]
     ,myTarget.[tixeventtotalpaid] = mySource.[tixeventtotalpaid]
     ,myTarget.[tixeventtotalnonallocpaid] = mySource.[tixeventtotalnonallocpaid]
     ,myTarget.[tixeventtotalsoldbucks] = mySource.[tixeventtotalsoldbucks]
     ,myTarget.[tixeventtotalnonallocsoldbucks] = mySource.[tixeventtotalnonallocsoldbucks]
     ,myTarget.[tixeventtotalpaidbucks] = mySource.[tixeventtotalpaidbucks]
     ,myTarget.[tixeventtotalnonallocpaidbucks] = mySource.[tixeventtotalnonallocpaidbucks]
     ,myTarget.[tixeventtotalsoldtod8] = mySource.[tixeventtotalsoldtod8]
     ,myTarget.[tixeventtotalnonallocsoldtod8] = mySource.[tixeventtotalnonallocsoldtod8]
     ,myTarget.[tixeventtotalsoldvalue] = mySource.[tixeventtotalsoldvalue]
     ,myTarget.[tixeventtotalpaidvalue] = mySource.[tixeventtotalpaidvalue]
     ,myTarget.[tixeventtotalnonallocsoldvalue] = mySource.[tixeventtotalnonallocsoldvalue]
     ,myTarget.[tixeventtotalnonallocpaidvalue] = mySource.[tixeventtotalnonallocpaidvalue]
     ,myTarget.[tixeventtotalcompsvalue] = mySource.[tixeventtotalcompsvalue]
     ,myTarget.[tixeventzonefullauditactive] = mySource.[tixeventzonefullauditactive]
     ,myTarget.[tixeventflashmovieid] = mySource.[tixeventflashmovieid]
     ,myTarget.[tixevtznproductvendortype] = mySource.[tixevtznproductvendortype]
     ,myTarget.[tixevtznproductvendorkey] = mySource.[tixevtznproductvendorkey]
     ,myTarget.[tixevtznproductid] = mySource.[tixevtznproductid]
     ,myTarget.[tixevtznavailabilitymsg] = mySource.[tixevtznavailabilitymsg]
     ,myTarget.[tixeventzoneallowsingles] = mySource.[tixeventzoneallowsingles]
     ,myTarget.[tixevtznseatrequestseatgroup] = mySource.[tixevtznseatrequestseatgroup]
     ,myTarget.[tixeventtotalnonalloccomp] = mySource.[tixeventtotalnonalloccomp]
     ,myTarget.[tixeventtotalnonalloccompvalue] = mySource.[tixeventtotalnonalloccompvalue]
     ,myTarget.[tixevtznallowseatrequests] = mySource.[tixevtznallowseatrequests]
     ,myTarget.[tixevtznseatrequestdate] = mySource.[tixevtznseatrequestdate]
     ,myTarget.[tixeventzonenexthistoryid] = mySource.[tixeventzonenexthistoryid]
     ,myTarget.[tixeventpricechartlocked] = mySource.[tixeventpricechartlocked]
     ,myTarget.[tixeventeventlocked] = mySource.[tixeventeventlocked]
     ,myTarget.[tixeventzonenexterrorcheckid] = mySource.[tixeventzonenexterrorcheckid]
     ,myTarget.[tixeventzonerenewablefornextyr] = mySource.[tixeventzonerenewablefornextyr]
     ,myTarget.[tixeventoffsale] = mySource.[tixeventoffsale]
     ,myTarget.[tixeventzonesectionpriormulti] = mySource.[tixeventzonesectionpriormulti]
     ,myTarget.[tixevent_nba_rowsizefactor] = mySource.[tixevent_nba_rowsizefactor]
     ,myTarget.[tixevtznrunbackgroundintegchk] = mySource.[tixevtznrunbackgroundintegchk]
     ,myTarget.[tixevtznseatrequestsonsale] = mySource.[tixevtznseatrequestsonsale]
     ,myTarget.[tixevtznlastsccssfulintegchkd8] = mySource.[tixevtznlastsccssfulintegchkd8]
     ,myTarget.[tixeventzonedisplay5nba1] = mySource.[tixeventzonedisplay5nba1]
     ,myTarget.[tixeventzonedisplay5nba2] = mySource.[tixeventzonedisplay5nba2]
     ,myTarget.[tixeventzonedisplay5nba3] = mySource.[tixeventzonedisplay5nba3]
     ,myTarget.[tixeventzonedisplay5nba4] = mySource.[tixeventzonedisplay5nba4]
     ,myTarget.[tixeventtotalseats_nona] = mySource.[tixeventtotalseats_nona]
     ,myTarget.[tixeventtotalonsale_nona] = mySource.[tixeventtotalonsale_nona]
     ,myTarget.[tixeventtotalremaining_nona] = mySource.[tixeventtotalremaining_nona]
     ,myTarget.[tixeventtotalonhold_nona] = mySource.[tixeventtotalonhold_nona]
     ,myTarget.[tixeventtotalkills_nona] = mySource.[tixeventtotalkills_nona]
     ,myTarget.[tixeventtotalallocations] = mySource.[tixeventtotalallocations]
     ,myTarget.[tixevtznglcode] = mySource.[tixevtznglcode]
     ,myTarget.[tixeventtotalconsign] = mySource.[tixeventtotalconsign]
     ,myTarget.[tixeventconsignprice] = mySource.[tixeventconsignprice]
     ,myTarget.[tixeventzoneavailableforweb] = mySource.[tixeventzoneavailableforweb]
     ,myTarget.[tixeventzoneusestopcard] = mySource.[tixeventzoneusestopcard]
     ,myTarget.[tixeventzoneiscanceled] = mySource.[tixeventzoneiscanceled]
     ,myTarget.[tixeventzonecancellationdate] = mySource.[tixeventzonecancellationdate]
     ,myTarget.[tixeventzonecancellationreason] = mySource.[tixeventzonecancellationreason]
     ,myTarget.[display_in_reports] = mySource.[display_in_reports]
     ,myTarget.[tixeventzoneeticketline1] = mySource.[tixeventzoneeticketline1]
     ,myTarget.[tixeventzoneeticketline2] = mySource.[tixeventzoneeticketline2]
     ,myTarget.[tixeventzoneeticketline3] = mySource.[tixeventzoneeticketline3]
     ,myTarget.[tixeventzoneeticketline4] = mySource.[tixeventzoneeticketline4]
     ,myTarget.[tixeventzoneeticketline5] = mySource.[tixeventzoneeticketline5]
     ,myTarget.[tixeventzoneeticketline6] = mySource.[tixeventzoneeticketline6]
     ,myTarget.[tixtransferfeeenabled] = mySource.[tixtransferfeeenabled]
     ,myTarget.[tixeventzoneallowtixforwarding] = mySource.[tixeventzoneallowtixforwarding]
     ,myTarget.[tixeventzoneallowonlinepayment] = mySource.[tixeventzoneallowonlinepayment]
     ,myTarget.[ac_lasthistoryptr] = mySource.[ac_lasthistoryptr]
     ,myTarget.[ac_exportzone] = mySource.[ac_exportzone]
     ,myTarget.[product_id] = mySource.[product_id]
     ,myTarget.[venue_map_id] = mySource.[venue_map_id]
     ,myTarget.[is_published] = mySource.[is_published]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[event_owner_id] = mySource.[event_owner_id]
     ,myTarget.[accesscontrolenddatetime] = mySource.[accesscontrolenddatetime]
     ,myTarget.[accesscontrolstartdatetime] = mySource.[accesscontrolstartdatetime]
     ,myTarget.[enableaccesscontrol] = mySource.[enableaccesscontrol]
     ,myTarget.[tixeventzoneversion] = mySource.[tixeventzoneversion]
     ,myTarget.[tixeventzonemaxentry] = mySource.[tixeventzonemaxentry]
     ,myTarget.[tixeventzonemaxperday] = mySource.[tixeventzonemaxperday]
     ,myTarget.[tixeventzoneentryexit] = mySource.[tixeventzoneentryexit]
     ,myTarget.[stadis_active] = mySource.[stadis_active]
     ,myTarget.[stadis_exported] = mySource.[stadis_exported]
     ,myTarget.[stadis_lasthistoryptr] = mySource.[stadis_lasthistoryptr]
     ,myTarget.[sales_restrict] = mySource.[sales_restrict]
     ,myTarget.[convertfsunpaid] = mySource.[convertfsunpaid]
     ,myTarget.[seatmap_image_id] = mySource.[seatmap_image_id]
     ,myTarget.[seatmap_image_mode] = mySource.[seatmap_image_mode]
     ,myTarget.[enable_paper_conversion] = mySource.[enable_paper_conversion]
     ,myTarget.[waive_paper_conversion_fee] = mySource.[waive_paper_conversion_fee]
     ,myTarget.[salespricechartversion] = mySource.[salespricechartversion]
     ,myTarget.[printpricechartversion] = mySource.[printpricechartversion]
     ,myTarget.[textpricechartversion] = mySource.[textpricechartversion]
	 ,myTarget.[single_forward] = mySource.[single_forward]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixeventid]
     ,[tixeventzoneid]
     ,[tixeventonsale]
     ,[tixeventtourid]
     ,[tixeventinitdate]
     ,[tixeventlastupdwhen]
     ,[tixeventbuiltfromseatmap]
     ,[tixeventseatmaplocked]
     ,[tixeventstatus]
     ,[tixeventtopseatgrouptype]
     ,[tixeventlastupdatewho]
     ,[tixeventticketformat]
     ,[tixeventtotalseats]
     ,[tixeventtotalonsale]
     ,[tixeventtotalremaining]
     ,[tixeventtotalkills]
     ,[tixeventtotalcomps]
     ,[tixeventtotalonhold]
     ,[tixeventtotalsold]
     ,[tixeventtotalnonallocsold]
     ,[tixeventtotalprinted]
     ,[tixeventzonedesc]
     ,[tixeventzonedispord]
     ,[tixeventzonetype]
     ,[tixeventinventorysecurityincl]
     ,[tixeventinventorysearchinclude]
     ,[tixeventzoneonsale]
     ,[tixeventzonereadyforsale]
     ,[tixeventzonenexteventid]
     ,[tixeventzonepreveventid]
     ,[tixeventzonenextzoneid]
     ,[tixeventzoneprevzoneid]
     ,[evtschedeventdb1estabtype]
     ,[evtschedeventdb1estabkey]
     ,[tixeventtotalpaid]
     ,[tixeventtotalnonallocpaid]
     ,[tixeventtotalsoldbucks]
     ,[tixeventtotalnonallocsoldbucks]
     ,[tixeventtotalpaidbucks]
     ,[tixeventtotalnonallocpaidbucks]
     ,[tixeventtotalsoldtod8]
     ,[tixeventtotalnonallocsoldtod8]
     ,[tixeventtotalsoldvalue]
     ,[tixeventtotalpaidvalue]
     ,[tixeventtotalnonallocsoldvalue]
     ,[tixeventtotalnonallocpaidvalue]
     ,[tixeventtotalcompsvalue]
     ,[tixeventzonefullauditactive]
     ,[tixeventflashmovieid]
     ,[tixevtznproductvendortype]
     ,[tixevtznproductvendorkey]
     ,[tixevtznproductid]
     ,[tixevtznavailabilitymsg]
     ,[tixeventzoneallowsingles]
     ,[tixevtznseatrequestseatgroup]
     ,[tixeventtotalnonalloccomp]
     ,[tixeventtotalnonalloccompvalue]
     ,[tixevtznallowseatrequests]
     ,[tixevtznseatrequestdate]
     ,[tixeventzonenexthistoryid]
     ,[tixeventpricechartlocked]
     ,[tixeventeventlocked]
     ,[tixeventzonenexterrorcheckid]
     ,[tixeventzonerenewablefornextyr]
     ,[tixeventoffsale]
     ,[tixeventzonesectionpriormulti]
     ,[tixevent_nba_rowsizefactor]
     ,[tixevtznrunbackgroundintegchk]
     ,[tixevtznseatrequestsonsale]
     ,[tixevtznlastsccssfulintegchkd8]
     ,[tixeventzonedisplay5nba1]
     ,[tixeventzonedisplay5nba2]
     ,[tixeventzonedisplay5nba3]
     ,[tixeventzonedisplay5nba4]
     ,[tixeventtotalseats_nona]
     ,[tixeventtotalonsale_nona]
     ,[tixeventtotalremaining_nona]
     ,[tixeventtotalonhold_nona]
     ,[tixeventtotalkills_nona]
     ,[tixeventtotalallocations]
     ,[tixevtznglcode]
     ,[tixeventtotalconsign]
     ,[tixeventconsignprice]
     ,[tixeventzoneavailableforweb]
     ,[tixeventzoneusestopcard]
     ,[tixeventzoneiscanceled]
     ,[tixeventzonecancellationdate]
     ,[tixeventzonecancellationreason]
     ,[display_in_reports]
     ,[tixeventzoneeticketline1]
     ,[tixeventzoneeticketline2]
     ,[tixeventzoneeticketline3]
     ,[tixeventzoneeticketline4]
     ,[tixeventzoneeticketline5]
     ,[tixeventzoneeticketline6]
     ,[tixtransferfeeenabled]
     ,[tixeventzoneallowtixforwarding]
     ,[tixeventzoneallowonlinepayment]
     ,[ac_lasthistoryptr]
     ,[ac_exportzone]
     ,[product_id]
     ,[venue_map_id]
     ,[is_published]
     ,[client_id]
     ,[event_owner_id]
     ,[accesscontrolenddatetime]
     ,[accesscontrolstartdatetime]
     ,[enableaccesscontrol]
     ,[tixeventzoneversion]
     ,[tixeventzonemaxentry]
     ,[tixeventzonemaxperday]
     ,[tixeventzoneentryexit]
     ,[stadis_active]
     ,[stadis_exported]
     ,[stadis_lasthistoryptr]
     ,[sales_restrict]
     ,[convertfsunpaid]
     ,[seatmap_image_id]
     ,[seatmap_image_mode]
     ,[enable_paper_conversion]
     ,[waive_paper_conversion_fee]
     ,[salespricechartversion]
     ,[printpricechartversion]
     ,[textpricechartversion]
	 ,[single_forward]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixeventid]
     ,mySource.[tixeventzoneid]
     ,mySource.[tixeventonsale]
     ,mySource.[tixeventtourid]
     ,mySource.[tixeventinitdate]
     ,mySource.[tixeventlastupdwhen]
     ,mySource.[tixeventbuiltfromseatmap]
     ,mySource.[tixeventseatmaplocked]
     ,mySource.[tixeventstatus]
     ,mySource.[tixeventtopseatgrouptype]
     ,mySource.[tixeventlastupdatewho]
     ,mySource.[tixeventticketformat]
     ,mySource.[tixeventtotalseats]
     ,mySource.[tixeventtotalonsale]
     ,mySource.[tixeventtotalremaining]
     ,mySource.[tixeventtotalkills]
     ,mySource.[tixeventtotalcomps]
     ,mySource.[tixeventtotalonhold]
     ,mySource.[tixeventtotalsold]
     ,mySource.[tixeventtotalnonallocsold]
     ,mySource.[tixeventtotalprinted]
     ,mySource.[tixeventzonedesc]
     ,mySource.[tixeventzonedispord]
     ,mySource.[tixeventzonetype]
     ,mySource.[tixeventinventorysecurityincl]
     ,mySource.[tixeventinventorysearchinclude]
     ,mySource.[tixeventzoneonsale]
     ,mySource.[tixeventzonereadyforsale]
     ,mySource.[tixeventzonenexteventid]
     ,mySource.[tixeventzonepreveventid]
     ,mySource.[tixeventzonenextzoneid]
     ,mySource.[tixeventzoneprevzoneid]
     ,mySource.[evtschedeventdb1estabtype]
     ,mySource.[evtschedeventdb1estabkey]
     ,mySource.[tixeventtotalpaid]
     ,mySource.[tixeventtotalnonallocpaid]
     ,mySource.[tixeventtotalsoldbucks]
     ,mySource.[tixeventtotalnonallocsoldbucks]
     ,mySource.[tixeventtotalpaidbucks]
     ,mySource.[tixeventtotalnonallocpaidbucks]
     ,mySource.[tixeventtotalsoldtod8]
     ,mySource.[tixeventtotalnonallocsoldtod8]
     ,mySource.[tixeventtotalsoldvalue]
     ,mySource.[tixeventtotalpaidvalue]
     ,mySource.[tixeventtotalnonallocsoldvalue]
     ,mySource.[tixeventtotalnonallocpaidvalue]
     ,mySource.[tixeventtotalcompsvalue]
     ,mySource.[tixeventzonefullauditactive]
     ,mySource.[tixeventflashmovieid]
     ,mySource.[tixevtznproductvendortype]
     ,mySource.[tixevtznproductvendorkey]
     ,mySource.[tixevtznproductid]
     ,mySource.[tixevtznavailabilitymsg]
     ,mySource.[tixeventzoneallowsingles]
     ,mySource.[tixevtznseatrequestseatgroup]
     ,mySource.[tixeventtotalnonalloccomp]
     ,mySource.[tixeventtotalnonalloccompvalue]
     ,mySource.[tixevtznallowseatrequests]
     ,mySource.[tixevtznseatrequestdate]
     ,mySource.[tixeventzonenexthistoryid]
     ,mySource.[tixeventpricechartlocked]
     ,mySource.[tixeventeventlocked]
     ,mySource.[tixeventzonenexterrorcheckid]
     ,mySource.[tixeventzonerenewablefornextyr]
     ,mySource.[tixeventoffsale]
     ,mySource.[tixeventzonesectionpriormulti]
     ,mySource.[tixevent_nba_rowsizefactor]
     ,mySource.[tixevtznrunbackgroundintegchk]
     ,mySource.[tixevtznseatrequestsonsale]
     ,mySource.[tixevtznlastsccssfulintegchkd8]
     ,mySource.[tixeventzonedisplay5nba1]
     ,mySource.[tixeventzonedisplay5nba2]
     ,mySource.[tixeventzonedisplay5nba3]
     ,mySource.[tixeventzonedisplay5nba4]
     ,mySource.[tixeventtotalseats_nona]
     ,mySource.[tixeventtotalonsale_nona]
     ,mySource.[tixeventtotalremaining_nona]
     ,mySource.[tixeventtotalonhold_nona]
     ,mySource.[tixeventtotalkills_nona]
     ,mySource.[tixeventtotalallocations]
     ,mySource.[tixevtznglcode]
     ,mySource.[tixeventtotalconsign]
     ,mySource.[tixeventconsignprice]
     ,mySource.[tixeventzoneavailableforweb]
     ,mySource.[tixeventzoneusestopcard]
     ,mySource.[tixeventzoneiscanceled]
     ,mySource.[tixeventzonecancellationdate]
     ,mySource.[tixeventzonecancellationreason]
     ,mySource.[display_in_reports]
     ,mySource.[tixeventzoneeticketline1]
     ,mySource.[tixeventzoneeticketline2]
     ,mySource.[tixeventzoneeticketline3]
     ,mySource.[tixeventzoneeticketline4]
     ,mySource.[tixeventzoneeticketline5]
     ,mySource.[tixeventzoneeticketline6]
     ,mySource.[tixtransferfeeenabled]
     ,mySource.[tixeventzoneallowtixforwarding]
     ,mySource.[tixeventzoneallowonlinepayment]
     ,mySource.[ac_lasthistoryptr]
     ,mySource.[ac_exportzone]
     ,mySource.[product_id]
     ,mySource.[venue_map_id]
     ,mySource.[is_published]
     ,mySource.[client_id]
     ,mySource.[event_owner_id]
     ,mySource.[accesscontrolenddatetime]
     ,mySource.[accesscontrolstartdatetime]
     ,mySource.[enableaccesscontrol]
     ,mySource.[tixeventzoneversion]
     ,mySource.[tixeventzonemaxentry]
     ,mySource.[tixeventzonemaxperday]
     ,mySource.[tixeventzoneentryexit]
     ,mySource.[stadis_active]
     ,mySource.[stadis_exported]
     ,mySource.[stadis_lasthistoryptr]
     ,mySource.[sales_restrict]
     ,mySource.[convertfsunpaid]
     ,mySource.[seatmap_image_id]
     ,mySource.[seatmap_image_mode]
     ,mySource.[enable_paper_conversion]
     ,mySource.[waive_paper_conversion_fee]
     ,mySource.[salespricechartversion]
     ,mySource.[printpricechartversion]
     ,mySource.[textpricechartversion]
	 ,mySource.[single_forward]
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
