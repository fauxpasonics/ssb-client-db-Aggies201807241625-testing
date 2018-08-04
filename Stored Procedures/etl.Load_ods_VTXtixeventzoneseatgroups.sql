SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzoneseatgroups]
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
Date:     08/25/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXtixeventzoneseatgroups),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId


SELECT ROW_NUMBER() OVER(ORDER BY ETL_ID) RowIndex
, * 
INTO #data
FROM src.VTXtixeventzoneseatgroups

CREATE NONCLUSTERED INDEX IDX_RowIndex ON #data (RowIndex)

DECLARE @RecordCount INT = (SELECT COUNT(*) FROM #data)
DECLARE @StartIndex INT = 1, @PageCount INT = 25000
DECLARE @EndIndex INT = (@StartIndex + @PageCount - 1)

WHILE @StartIndex <= @RecordCount
BEGIN

	DECLARE @Message NVARCHAR(500) = ('Start:' + CONVERT(NVARCHAR(25), @StartIndex) + ', End:' + CONVERT(NVARCHAR(25), @EndIndex))
	RAISERROR(@Message,0,1) WITH NOWAIT

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, tixeventid, tixeventzoneid, tixseatgroupid, tixseatgroupdesc, tixseatgrouptype, tixseatgroupdisplayorder, tixseatgroupparentgroup, tixseatgroupgrandparent, tixseatgroupgreatgrandparent, tixseatgrouplevelsfromevent, tixseatgrouptotalingroup, tixseatgrouptotalonsale, tixseatgrouptotalremaining, tixseatgrouptotalkills, tixseatgrouptotalcomps, tixseatgrouptotalonhold, tixseatgrouptotalsold, tixseatgrouptotalnonallocsold, tixseatgrouptotalprinted, tixseatgrouppricelevel, tixseatgroupsalepriority, tixseatgroupmultiavailstatflag, tixseatgroupprimaryspeccode, tixseatgrouptotalnonallocpaid, tixseatgrouptotalpaid, tixseatgroupnonallocpaidbucks, tixseatgroupnonallocsoldbucks, tixseatgrouppaidbucks, tixseatgroupsoldbucks, tixseatgroupnonallocpaidvalue, tixseatgroupnonallocsoldvalue, tixseatgrouppaidvalue, tixseatgroupsoldvalue, tixseatgroupsoldtod8, tixseatgroupnonallocsoldtod8, tixseatgroupcompsvalue, tixseatgroupflashmovieframeid, tixseatgroupcompassright, tixseatgroupcompassleft, tixseatgroupcompassup, tixseatgroupcompassdown, tixseatgrouplevelstoseats, tixeventzoneseatgrouplastupd, tixseatgroupseatrequestgroup, tixseatgrouptotalnonalloccomp, tixseatgroupnonalloccompsvalue, tixseatgroupsaleorder, tixseatgrouptotalingroup_nona, tixseatgrouptotalonsale_nona, tixseatgrouptotalremain_nona, tixseatgrouptotalonhold_nona, tixseatgrouptotalkills_nona, tixseatgrouptotalallocations, tixseatgrouptotalconsign, tixseatgroupconsignprice, tixseatgroupprintdesc, tixseatgroupflashmovietype, tixseatgroupavailableforweb, tixseatgroupcenterindicator, tixseatgroupdisplayasga, tixseatgroupaddlinfo, tixseatgroupgaseatdescription
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(50), [tixeventid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixeventzoneid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(30), [tixeventzoneseatgrouplastupd])),'DBNULL_DATETIME') + ISNULL(RTRIM( [tixseatgroupaddlinfo]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupavailableforweb])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupcenterindicator])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupcompassdown])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupcompassleft])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupcompassright])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupcompassup])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupcompsvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupconsignprice])),'DBNULL_NUMBER') + ISNULL(RTRIM( [tixseatgroupdesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupdisplayasga])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupdisplayorder])),'DBNULL_INT') + ISNULL(RTRIM( [tixseatgroupflashmovieframeid]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupflashmovietype])),'DBNULL_INT') + ISNULL(RTRIM( [tixseatgroupgaseatdescription]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupgrandparent])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupgreatgrandparent])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgrouplevelsfromevent])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgrouplevelstoseats])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupmultiavailstatflag])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonalloccompsvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonallocpaidbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonallocpaidvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonallocsoldbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonallocsoldtod8])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupnonallocsoldvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouppaidbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouppaidvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupparentgroup])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouppricelevel])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupprimaryspeccode])),'DBNULL_INT') + ISNULL(RTRIM( [tixseatgroupprintdesc]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupsaleorder])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupsalepriority])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgroupseatrequestgroup])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupsoldbucks])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupsoldtod8])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgroupsoldvalue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalallocations])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalcomps])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalconsign])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalingroup])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalingroup_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalkills])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalkills_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalnonalloccomp])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalnonallocpaid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalnonallocsold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalonhold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalonhold_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalonsale])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalonsale_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalpaid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalprinted])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalremain_nona])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalremaining])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [tixseatgrouptotalsold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [tixseatgrouptype])),'DBNULL_INT')) ETL_DeltaHashKey
INTO #SrcData
FROM #data
WHERE RowIndex BETWEEN @StartIndex AND @EndIndex

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid, tixeventzoneid, tixseatgroupid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXtixeventzoneseatgroups AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.tixeventid = mySource.tixeventid AND myTarget.tixeventzoneid = mySource.tixeventzoneid AND myTarget.tixseatgroupid = mySource.tixseatgroupid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[tixeventid] = mySource.[tixeventid]
     ,myTarget.[tixeventzoneid] = mySource.[tixeventzoneid]
     ,myTarget.[tixseatgroupid] = mySource.[tixseatgroupid]
     ,myTarget.[tixseatgroupdesc] = mySource.[tixseatgroupdesc]
     ,myTarget.[tixseatgrouptype] = mySource.[tixseatgrouptype]
     ,myTarget.[tixseatgroupdisplayorder] = mySource.[tixseatgroupdisplayorder]
     ,myTarget.[tixseatgroupparentgroup] = mySource.[tixseatgroupparentgroup]
     ,myTarget.[tixseatgroupgrandparent] = mySource.[tixseatgroupgrandparent]
     ,myTarget.[tixseatgroupgreatgrandparent] = mySource.[tixseatgroupgreatgrandparent]
     ,myTarget.[tixseatgrouplevelsfromevent] = mySource.[tixseatgrouplevelsfromevent]
     ,myTarget.[tixseatgrouptotalingroup] = mySource.[tixseatgrouptotalingroup]
     ,myTarget.[tixseatgrouptotalonsale] = mySource.[tixseatgrouptotalonsale]
     ,myTarget.[tixseatgrouptotalremaining] = mySource.[tixseatgrouptotalremaining]
     ,myTarget.[tixseatgrouptotalkills] = mySource.[tixseatgrouptotalkills]
     ,myTarget.[tixseatgrouptotalcomps] = mySource.[tixseatgrouptotalcomps]
     ,myTarget.[tixseatgrouptotalonhold] = mySource.[tixseatgrouptotalonhold]
     ,myTarget.[tixseatgrouptotalsold] = mySource.[tixseatgrouptotalsold]
     ,myTarget.[tixseatgrouptotalnonallocsold] = mySource.[tixseatgrouptotalnonallocsold]
     ,myTarget.[tixseatgrouptotalprinted] = mySource.[tixseatgrouptotalprinted]
     ,myTarget.[tixseatgrouppricelevel] = mySource.[tixseatgrouppricelevel]
     ,myTarget.[tixseatgroupsalepriority] = mySource.[tixseatgroupsalepriority]
     ,myTarget.[tixseatgroupmultiavailstatflag] = mySource.[tixseatgroupmultiavailstatflag]
     ,myTarget.[tixseatgroupprimaryspeccode] = mySource.[tixseatgroupprimaryspeccode]
     ,myTarget.[tixseatgrouptotalnonallocpaid] = mySource.[tixseatgrouptotalnonallocpaid]
     ,myTarget.[tixseatgrouptotalpaid] = mySource.[tixseatgrouptotalpaid]
     ,myTarget.[tixseatgroupnonallocpaidbucks] = mySource.[tixseatgroupnonallocpaidbucks]
     ,myTarget.[tixseatgroupnonallocsoldbucks] = mySource.[tixseatgroupnonallocsoldbucks]
     ,myTarget.[tixseatgrouppaidbucks] = mySource.[tixseatgrouppaidbucks]
     ,myTarget.[tixseatgroupsoldbucks] = mySource.[tixseatgroupsoldbucks]
     ,myTarget.[tixseatgroupnonallocpaidvalue] = mySource.[tixseatgroupnonallocpaidvalue]
     ,myTarget.[tixseatgroupnonallocsoldvalue] = mySource.[tixseatgroupnonallocsoldvalue]
     ,myTarget.[tixseatgrouppaidvalue] = mySource.[tixseatgrouppaidvalue]
     ,myTarget.[tixseatgroupsoldvalue] = mySource.[tixseatgroupsoldvalue]
     ,myTarget.[tixseatgroupsoldtod8] = mySource.[tixseatgroupsoldtod8]
     ,myTarget.[tixseatgroupnonallocsoldtod8] = mySource.[tixseatgroupnonallocsoldtod8]
     ,myTarget.[tixseatgroupcompsvalue] = mySource.[tixseatgroupcompsvalue]
     ,myTarget.[tixseatgroupflashmovieframeid] = mySource.[tixseatgroupflashmovieframeid]
     ,myTarget.[tixseatgroupcompassright] = mySource.[tixseatgroupcompassright]
     ,myTarget.[tixseatgroupcompassleft] = mySource.[tixseatgroupcompassleft]
     ,myTarget.[tixseatgroupcompassup] = mySource.[tixseatgroupcompassup]
     ,myTarget.[tixseatgroupcompassdown] = mySource.[tixseatgroupcompassdown]
     ,myTarget.[tixseatgrouplevelstoseats] = mySource.[tixseatgrouplevelstoseats]
     ,myTarget.[tixeventzoneseatgrouplastupd] = mySource.[tixeventzoneseatgrouplastupd]
     ,myTarget.[tixseatgroupseatrequestgroup] = mySource.[tixseatgroupseatrequestgroup]
     ,myTarget.[tixseatgrouptotalnonalloccomp] = mySource.[tixseatgrouptotalnonalloccomp]
     ,myTarget.[tixseatgroupnonalloccompsvalue] = mySource.[tixseatgroupnonalloccompsvalue]
     ,myTarget.[tixseatgroupsaleorder] = mySource.[tixseatgroupsaleorder]
     ,myTarget.[tixseatgrouptotalingroup_nona] = mySource.[tixseatgrouptotalingroup_nona]
     ,myTarget.[tixseatgrouptotalonsale_nona] = mySource.[tixseatgrouptotalonsale_nona]
     ,myTarget.[tixseatgrouptotalremain_nona] = mySource.[tixseatgrouptotalremain_nona]
     ,myTarget.[tixseatgrouptotalonhold_nona] = mySource.[tixseatgrouptotalonhold_nona]
     ,myTarget.[tixseatgrouptotalkills_nona] = mySource.[tixseatgrouptotalkills_nona]
     ,myTarget.[tixseatgrouptotalallocations] = mySource.[tixseatgrouptotalallocations]
     ,myTarget.[tixseatgrouptotalconsign] = mySource.[tixseatgrouptotalconsign]
     ,myTarget.[tixseatgroupconsignprice] = mySource.[tixseatgroupconsignprice]
     ,myTarget.[tixseatgroupprintdesc] = mySource.[tixseatgroupprintdesc]
     ,myTarget.[tixseatgroupflashmovietype] = mySource.[tixseatgroupflashmovietype]
     ,myTarget.[tixseatgroupavailableforweb] = mySource.[tixseatgroupavailableforweb]
     ,myTarget.[tixseatgroupcenterindicator] = mySource.[tixseatgroupcenterindicator]
     ,myTarget.[tixseatgroupdisplayasga] = mySource.[tixseatgroupdisplayasga]
     ,myTarget.[tixseatgroupaddlinfo] = mySource.[tixseatgroupaddlinfo]
     ,myTarget.[tixseatgroupgaseatdescription] = mySource.[tixseatgroupgaseatdescription]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[tixeventid]
     ,[tixeventzoneid]
     ,[tixseatgroupid]
     ,[tixseatgroupdesc]
     ,[tixseatgrouptype]
     ,[tixseatgroupdisplayorder]
     ,[tixseatgroupparentgroup]
     ,[tixseatgroupgrandparent]
     ,[tixseatgroupgreatgrandparent]
     ,[tixseatgrouplevelsfromevent]
     ,[tixseatgrouptotalingroup]
     ,[tixseatgrouptotalonsale]
     ,[tixseatgrouptotalremaining]
     ,[tixseatgrouptotalkills]
     ,[tixseatgrouptotalcomps]
     ,[tixseatgrouptotalonhold]
     ,[tixseatgrouptotalsold]
     ,[tixseatgrouptotalnonallocsold]
     ,[tixseatgrouptotalprinted]
     ,[tixseatgrouppricelevel]
     ,[tixseatgroupsalepriority]
     ,[tixseatgroupmultiavailstatflag]
     ,[tixseatgroupprimaryspeccode]
     ,[tixseatgrouptotalnonallocpaid]
     ,[tixseatgrouptotalpaid]
     ,[tixseatgroupnonallocpaidbucks]
     ,[tixseatgroupnonallocsoldbucks]
     ,[tixseatgrouppaidbucks]
     ,[tixseatgroupsoldbucks]
     ,[tixseatgroupnonallocpaidvalue]
     ,[tixseatgroupnonallocsoldvalue]
     ,[tixseatgrouppaidvalue]
     ,[tixseatgroupsoldvalue]
     ,[tixseatgroupsoldtod8]
     ,[tixseatgroupnonallocsoldtod8]
     ,[tixseatgroupcompsvalue]
     ,[tixseatgroupflashmovieframeid]
     ,[tixseatgroupcompassright]
     ,[tixseatgroupcompassleft]
     ,[tixseatgroupcompassup]
     ,[tixseatgroupcompassdown]
     ,[tixseatgrouplevelstoseats]
     ,[tixeventzoneseatgrouplastupd]
     ,[tixseatgroupseatrequestgroup]
     ,[tixseatgrouptotalnonalloccomp]
     ,[tixseatgroupnonalloccompsvalue]
     ,[tixseatgroupsaleorder]
     ,[tixseatgrouptotalingroup_nona]
     ,[tixseatgrouptotalonsale_nona]
     ,[tixseatgrouptotalremain_nona]
     ,[tixseatgrouptotalonhold_nona]
     ,[tixseatgrouptotalkills_nona]
     ,[tixseatgrouptotalallocations]
     ,[tixseatgrouptotalconsign]
     ,[tixseatgroupconsignprice]
     ,[tixseatgroupprintdesc]
     ,[tixseatgroupflashmovietype]
     ,[tixseatgroupavailableforweb]
     ,[tixseatgroupcenterindicator]
     ,[tixseatgroupdisplayasga]
     ,[tixseatgroupaddlinfo]
     ,[tixseatgroupgaseatdescription]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[tixeventid]
     ,mySource.[tixeventzoneid]
     ,mySource.[tixseatgroupid]
     ,mySource.[tixseatgroupdesc]
     ,mySource.[tixseatgrouptype]
     ,mySource.[tixseatgroupdisplayorder]
     ,mySource.[tixseatgroupparentgroup]
     ,mySource.[tixseatgroupgrandparent]
     ,mySource.[tixseatgroupgreatgrandparent]
     ,mySource.[tixseatgrouplevelsfromevent]
     ,mySource.[tixseatgrouptotalingroup]
     ,mySource.[tixseatgrouptotalonsale]
     ,mySource.[tixseatgrouptotalremaining]
     ,mySource.[tixseatgrouptotalkills]
     ,mySource.[tixseatgrouptotalcomps]
     ,mySource.[tixseatgrouptotalonhold]
     ,mySource.[tixseatgrouptotalsold]
     ,mySource.[tixseatgrouptotalnonallocsold]
     ,mySource.[tixseatgrouptotalprinted]
     ,mySource.[tixseatgrouppricelevel]
     ,mySource.[tixseatgroupsalepriority]
     ,mySource.[tixseatgroupmultiavailstatflag]
     ,mySource.[tixseatgroupprimaryspeccode]
     ,mySource.[tixseatgrouptotalnonallocpaid]
     ,mySource.[tixseatgrouptotalpaid]
     ,mySource.[tixseatgroupnonallocpaidbucks]
     ,mySource.[tixseatgroupnonallocsoldbucks]
     ,mySource.[tixseatgrouppaidbucks]
     ,mySource.[tixseatgroupsoldbucks]
     ,mySource.[tixseatgroupnonallocpaidvalue]
     ,mySource.[tixseatgroupnonallocsoldvalue]
     ,mySource.[tixseatgrouppaidvalue]
     ,mySource.[tixseatgroupsoldvalue]
     ,mySource.[tixseatgroupsoldtod8]
     ,mySource.[tixseatgroupnonallocsoldtod8]
     ,mySource.[tixseatgroupcompsvalue]
     ,mySource.[tixseatgroupflashmovieframeid]
     ,mySource.[tixseatgroupcompassright]
     ,mySource.[tixseatgroupcompassleft]
     ,mySource.[tixseatgroupcompassup]
     ,mySource.[tixseatgroupcompassdown]
     ,mySource.[tixseatgrouplevelstoseats]
     ,mySource.[tixeventzoneseatgrouplastupd]
     ,mySource.[tixseatgroupseatrequestgroup]
     ,mySource.[tixseatgrouptotalnonalloccomp]
     ,mySource.[tixseatgroupnonalloccompsvalue]
     ,mySource.[tixseatgroupsaleorder]
     ,mySource.[tixseatgrouptotalingroup_nona]
     ,mySource.[tixseatgrouptotalonsale_nona]
     ,mySource.[tixseatgrouptotalremain_nona]
     ,mySource.[tixseatgrouptotalonhold_nona]
     ,mySource.[tixseatgrouptotalkills_nona]
     ,mySource.[tixseatgrouptotalallocations]
     ,mySource.[tixseatgrouptotalconsign]
     ,mySource.[tixseatgroupconsignprice]
     ,mySource.[tixseatgroupprintdesc]
     ,mySource.[tixseatgroupflashmovietype]
     ,mySource.[tixseatgroupavailableforweb]
     ,mySource.[tixseatgroupcenterindicator]
     ,mySource.[tixseatgroupdisplayasga]
     ,mySource.[tixseatgroupaddlinfo]
     ,mySource.[tixseatgroupgaseatdescription]
     )

--WHEN NOT MATCHED BY SOURCE
--THEN UPDATE SET
--	myTarget.ETL_IsDeleted = 1,
--	myTarget.ETL_DeletedDate = GETDATE()
;

DROP TABLE #SrcData

SET @StartIndex = @EndIndex + 1
SET @EndIndex = @EndIndex + @PageCount

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

END --End Of Paging Loop

DELETE t
FROM ods.VTXtixeventzoneseatgroups t
LEFT OUTER JOIN src.VTXtixeventzoneseatgroups s ON s.tixeventid = t.tixeventid AND s.tixeventzoneid = t.tixeventzoneid AND s.tixseatgroupid = t.tixseatgroupid
WHERE s.ETL_ID IS NULL


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
