SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXproducts]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXproducts),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, productvendortype, productvendorkey, productid, producttype, productdescription, productdetails2, productdetails3, productdefaultmerchid, productvendorstocknumber, productvendorcostmethod, productvendorcosttable, productvendorcost, productvendorcostrate2, productvendorcostrate3, productusercostmethod, productusercosttable, productusercost, productqty, productunits, productshipinitzip, productavailable, productdisplaytousers, productdisplayorder, producttimeoutdays, productsearchgroups, producttaxtable, productsplittable, productinitdate, productlastupdatewhen, productlastupdatewho, producttaxpoint, productspecialprocessing, productteaserstoryid, productinfostoryid, productvolumediscountcategory, prodvolumediscountsubcategory, prodvolumediscountdiscntcode, prodvolumediscountdiscntentry, prodoutofstockfullfillprocess, prodinstockfullfillmentprocess, prodcustomvolumediscountinplay, prodsubscriptfreetimedatepart, prodsubscripfreetimeincrement, prodincrementloyaltypntprogram, prodloyaltypntprogramincrement, productcustomshipserveinplay, productdetails4, productonsalediscount, productshipinitstate, productshipinitcounty, productcurrentstockquantity, productlowstocklevelquantity, productdetails, productvalidshippingoptions, productaddadvsecroles, productadduserretrcodes, productglcode, productinactive, refundaltpaymenttype, productentityid, productdisplaydescription, channel1merchid, channel2merchid, channel3merchid, channel4merchid, channel5merchid, id, client_id, settlement_code_id
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(10), [channel1merchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [channel2merchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [channel3merchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [channel4merchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [channel5merchid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [prodcustomvolumediscountinplay]),'DBNULL_TEXT') + ISNULL(RTRIM( [prodincrementloyaltypntprogram]),'DBNULL_TEXT') + ISNULL(RTRIM( [prodinstockfullfillmentprocess]),'DBNULL_TEXT') + ISNULL(RTRIM( [prodloyaltypntprogramincrement]),'DBNULL_TEXT') + ISNULL(RTRIM( [prodoutofstockfullfillprocess]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [prodsubscripfreetimeincrement])),'DBNULL_INT') + ISNULL(RTRIM( [prodsubscriptfreetimedatepart]),'DBNULL_TEXT') + ISNULL(RTRIM( [productaddadvsecroles]),'DBNULL_TEXT') + ISNULL(RTRIM( [productadduserretrcodes]),'DBNULL_TEXT') + ISNULL(RTRIM( [productavailable]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productcurrentstockquantity])),'DBNULL_NUMBER') + ISNULL(RTRIM( [productcustomshipserveinplay]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [productdefaultmerchid])),'DBNULL_INT') + ISNULL(RTRIM( [productdescription]),'DBNULL_TEXT') + ISNULL(RTRIM( [productdetails]),'DBNULL_TEXT') + ISNULL(RTRIM( [productdetails2]),'DBNULL_TEXT') + ISNULL(RTRIM( [productdetails3]),'DBNULL_TEXT') + ISNULL(RTRIM( [productdetails4]),'DBNULL_TEXT') + ISNULL(RTRIM( [productdisplaydescription]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [productdisplayorder])),'DBNULL_INT') + ISNULL(RTRIM( [productdisplaytousers]),'DBNULL_TEXT') + ISNULL(RTRIM( [productentityid]),'DBNULL_TEXT') + ISNULL(RTRIM( [productglcode]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [productinactive]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productinfostoryid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [productinitdate])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(25), [productlastupdatewhen])),'DBNULL_DATETIME') + ISNULL(RTRIM( [productlastupdatewho]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productlowstocklevelquantity])),'DBNULL_NUMBER') + ISNULL(RTRIM( [productonsalediscount]),'DBNULL_TEXT') + ISNULL(RTRIM( [productqty]),'DBNULL_TEXT') + ISNULL(RTRIM( [productsearchgroups]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [productshipinitcounty])),'DBNULL_INT') + ISNULL(RTRIM( [productshipinitstate]),'DBNULL_TEXT') + ISNULL(RTRIM( [productshipinitzip]),'DBNULL_TEXT') + ISNULL(RTRIM( [productspecialprocessing]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [productsplittable])),'DBNULL_INT') + ISNULL(RTRIM( [producttaxpoint]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [producttaxtable])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [productteaserstoryid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [producttimeoutdays]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [producttype])),'DBNULL_INT') + ISNULL(RTRIM( [productunits]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productusercost])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [productusercostmethod])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [productusercosttable])),'DBNULL_INT') + ISNULL(RTRIM( [productvalidshippingoptions]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [productvendorcost])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [productvendorcostmethod])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [productvendorcostrate2])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [productvendorcostrate3])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [productvendorcosttable])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(25), [productvendorkey])),'DBNULL_NUMBER') + ISNULL(RTRIM( [productvendorstocknumber]),'DBNULL_TEXT') + ISNULL(RTRIM( [productvendortype]),'DBNULL_TEXT') + ISNULL(RTRIM( [productvolumediscountcategory]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [prodvolumediscountdiscntcode])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [prodvolumediscountdiscntentry])),'DBNULL_INT') + ISNULL(RTRIM( [prodvolumediscountsubcategory]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [refundaltpaymenttype])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [settlement_code_id])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXproducts

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN	
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXproducts AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[productvendortype] = mySource.[productvendortype]
     ,myTarget.[productvendorkey] = mySource.[productvendorkey]
     ,myTarget.[productid] = mySource.[productid]
     ,myTarget.[producttype] = mySource.[producttype]
     ,myTarget.[productdescription] = mySource.[productdescription]
     ,myTarget.[productdetails2] = mySource.[productdetails2]
     ,myTarget.[productdetails3] = mySource.[productdetails3]
     ,myTarget.[productdefaultmerchid] = mySource.[productdefaultmerchid]
     ,myTarget.[productvendorstocknumber] = mySource.[productvendorstocknumber]
     ,myTarget.[productvendorcostmethod] = mySource.[productvendorcostmethod]
     ,myTarget.[productvendorcosttable] = mySource.[productvendorcosttable]
     ,myTarget.[productvendorcost] = mySource.[productvendorcost]
     ,myTarget.[productvendorcostrate2] = mySource.[productvendorcostrate2]
     ,myTarget.[productvendorcostrate3] = mySource.[productvendorcostrate3]
     ,myTarget.[productusercostmethod] = mySource.[productusercostmethod]
     ,myTarget.[productusercosttable] = mySource.[productusercosttable]
     ,myTarget.[productusercost] = mySource.[productusercost]
     ,myTarget.[productqty] = mySource.[productqty]
     ,myTarget.[productunits] = mySource.[productunits]
     ,myTarget.[productshipinitzip] = mySource.[productshipinitzip]
     ,myTarget.[productavailable] = mySource.[productavailable]
     ,myTarget.[productdisplaytousers] = mySource.[productdisplaytousers]
     ,myTarget.[productdisplayorder] = mySource.[productdisplayorder]
     ,myTarget.[producttimeoutdays] = mySource.[producttimeoutdays]
     ,myTarget.[productsearchgroups] = mySource.[productsearchgroups]
     ,myTarget.[producttaxtable] = mySource.[producttaxtable]
     ,myTarget.[productsplittable] = mySource.[productsplittable]
     ,myTarget.[productinitdate] = mySource.[productinitdate]
     ,myTarget.[productlastupdatewhen] = mySource.[productlastupdatewhen]
     ,myTarget.[productlastupdatewho] = mySource.[productlastupdatewho]
     ,myTarget.[producttaxpoint] = mySource.[producttaxpoint]
     ,myTarget.[productspecialprocessing] = mySource.[productspecialprocessing]
     ,myTarget.[productteaserstoryid] = mySource.[productteaserstoryid]
     ,myTarget.[productinfostoryid] = mySource.[productinfostoryid]
     ,myTarget.[productvolumediscountcategory] = mySource.[productvolumediscountcategory]
     ,myTarget.[prodvolumediscountsubcategory] = mySource.[prodvolumediscountsubcategory]
     ,myTarget.[prodvolumediscountdiscntcode] = mySource.[prodvolumediscountdiscntcode]
     ,myTarget.[prodvolumediscountdiscntentry] = mySource.[prodvolumediscountdiscntentry]
     ,myTarget.[prodoutofstockfullfillprocess] = mySource.[prodoutofstockfullfillprocess]
     ,myTarget.[prodinstockfullfillmentprocess] = mySource.[prodinstockfullfillmentprocess]
     ,myTarget.[prodcustomvolumediscountinplay] = mySource.[prodcustomvolumediscountinplay]
     ,myTarget.[prodsubscriptfreetimedatepart] = mySource.[prodsubscriptfreetimedatepart]
     ,myTarget.[prodsubscripfreetimeincrement] = mySource.[prodsubscripfreetimeincrement]
     ,myTarget.[prodincrementloyaltypntprogram] = mySource.[prodincrementloyaltypntprogram]
     ,myTarget.[prodloyaltypntprogramincrement] = mySource.[prodloyaltypntprogramincrement]
     ,myTarget.[productcustomshipserveinplay] = mySource.[productcustomshipserveinplay]
     ,myTarget.[productdetails4] = mySource.[productdetails4]
     ,myTarget.[productonsalediscount] = mySource.[productonsalediscount]
     ,myTarget.[productshipinitstate] = mySource.[productshipinitstate]
     ,myTarget.[productshipinitcounty] = mySource.[productshipinitcounty]
     ,myTarget.[productcurrentstockquantity] = mySource.[productcurrentstockquantity]
     ,myTarget.[productlowstocklevelquantity] = mySource.[productlowstocklevelquantity]
     ,myTarget.[productdetails] = mySource.[productdetails]
     ,myTarget.[productvalidshippingoptions] = mySource.[productvalidshippingoptions]
     ,myTarget.[productaddadvsecroles] = mySource.[productaddadvsecroles]
     ,myTarget.[productadduserretrcodes] = mySource.[productadduserretrcodes]
     ,myTarget.[productglcode] = mySource.[productglcode]
     ,myTarget.[productinactive] = mySource.[productinactive]
     ,myTarget.[refundaltpaymenttype] = mySource.[refundaltpaymenttype]
     ,myTarget.[productentityid] = mySource.[productentityid]
     ,myTarget.[productdisplaydescription] = mySource.[productdisplaydescription]
     ,myTarget.[channel1merchid] = mySource.[channel1merchid]
     ,myTarget.[channel2merchid] = mySource.[channel2merchid]
     ,myTarget.[channel3merchid] = mySource.[channel3merchid]
     ,myTarget.[channel4merchid] = mySource.[channel4merchid]
     ,myTarget.[channel5merchid] = mySource.[channel5merchid]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[settlement_code_id] = mySource.[settlement_code_id]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[productvendortype]
     ,[productvendorkey]
     ,[productid]
     ,[producttype]
     ,[productdescription]
     ,[productdetails2]
     ,[productdetails3]
     ,[productdefaultmerchid]
     ,[productvendorstocknumber]
     ,[productvendorcostmethod]
     ,[productvendorcosttable]
     ,[productvendorcost]
     ,[productvendorcostrate2]
     ,[productvendorcostrate3]
     ,[productusercostmethod]
     ,[productusercosttable]
     ,[productusercost]
     ,[productqty]
     ,[productunits]
     ,[productshipinitzip]
     ,[productavailable]
     ,[productdisplaytousers]
     ,[productdisplayorder]
     ,[producttimeoutdays]
     ,[productsearchgroups]
     ,[producttaxtable]
     ,[productsplittable]
     ,[productinitdate]
     ,[productlastupdatewhen]
     ,[productlastupdatewho]
     ,[producttaxpoint]
     ,[productspecialprocessing]
     ,[productteaserstoryid]
     ,[productinfostoryid]
     ,[productvolumediscountcategory]
     ,[prodvolumediscountsubcategory]
     ,[prodvolumediscountdiscntcode]
     ,[prodvolumediscountdiscntentry]
     ,[prodoutofstockfullfillprocess]
     ,[prodinstockfullfillmentprocess]
     ,[prodcustomvolumediscountinplay]
     ,[prodsubscriptfreetimedatepart]
     ,[prodsubscripfreetimeincrement]
     ,[prodincrementloyaltypntprogram]
     ,[prodloyaltypntprogramincrement]
     ,[productcustomshipserveinplay]
     ,[productdetails4]
     ,[productonsalediscount]
     ,[productshipinitstate]
     ,[productshipinitcounty]
     ,[productcurrentstockquantity]
     ,[productlowstocklevelquantity]
     ,[productdetails]
     ,[productvalidshippingoptions]
     ,[productaddadvsecroles]
     ,[productadduserretrcodes]
     ,[productglcode]
     ,[productinactive]
     ,[refundaltpaymenttype]
     ,[productentityid]
     ,[productdisplaydescription]
     ,[channel1merchid]
     ,[channel2merchid]
     ,[channel3merchid]
     ,[channel4merchid]
     ,[channel5merchid]
     ,[id]
     ,[client_id]
     ,[settlement_code_id]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[productvendortype]
     ,mySource.[productvendorkey]
     ,mySource.[productid]
     ,mySource.[producttype]
     ,mySource.[productdescription]
     ,mySource.[productdetails2]
     ,mySource.[productdetails3]
     ,mySource.[productdefaultmerchid]
     ,mySource.[productvendorstocknumber]
     ,mySource.[productvendorcostmethod]
     ,mySource.[productvendorcosttable]
     ,mySource.[productvendorcost]
     ,mySource.[productvendorcostrate2]
     ,mySource.[productvendorcostrate3]
     ,mySource.[productusercostmethod]
     ,mySource.[productusercosttable]
     ,mySource.[productusercost]
     ,mySource.[productqty]
     ,mySource.[productunits]
     ,mySource.[productshipinitzip]
     ,mySource.[productavailable]
     ,mySource.[productdisplaytousers]
     ,mySource.[productdisplayorder]
     ,mySource.[producttimeoutdays]
     ,mySource.[productsearchgroups]
     ,mySource.[producttaxtable]
     ,mySource.[productsplittable]
     ,mySource.[productinitdate]
     ,mySource.[productlastupdatewhen]
     ,mySource.[productlastupdatewho]
     ,mySource.[producttaxpoint]
     ,mySource.[productspecialprocessing]
     ,mySource.[productteaserstoryid]
     ,mySource.[productinfostoryid]
     ,mySource.[productvolumediscountcategory]
     ,mySource.[prodvolumediscountsubcategory]
     ,mySource.[prodvolumediscountdiscntcode]
     ,mySource.[prodvolumediscountdiscntentry]
     ,mySource.[prodoutofstockfullfillprocess]
     ,mySource.[prodinstockfullfillmentprocess]
     ,mySource.[prodcustomvolumediscountinplay]
     ,mySource.[prodsubscriptfreetimedatepart]
     ,mySource.[prodsubscripfreetimeincrement]
     ,mySource.[prodincrementloyaltypntprogram]
     ,mySource.[prodloyaltypntprogramincrement]
     ,mySource.[productcustomshipserveinplay]
     ,mySource.[productdetails4]
     ,mySource.[productonsalediscount]
     ,mySource.[productshipinitstate]
     ,mySource.[productshipinitcounty]
     ,mySource.[productcurrentstockquantity]
     ,mySource.[productlowstocklevelquantity]
     ,mySource.[productdetails]
     ,mySource.[productvalidshippingoptions]
     ,mySource.[productaddadvsecroles]
     ,mySource.[productadduserretrcodes]
     ,mySource.[productglcode]
     ,mySource.[productinactive]
     ,mySource.[refundaltpaymenttype]
     ,mySource.[productentityid]
     ,mySource.[productdisplaydescription]
     ,mySource.[channel1merchid]
     ,mySource.[channel2merchid]
     ,mySource.[channel3merchid]
     ,mySource.[channel4merchid]
     ,mySource.[channel5merchid]
     ,mySource.[id]
     ,mySource.[client_id]
     ,mySource.[settlement_code_id]
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
