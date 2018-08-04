SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXpayments]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXpayments),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, paymentid, paymentccbatchid, paymenttranstype, paymentusercckey, paymentamount, paymentauthcode, paymentrefnumber, paymentdate, paymentsetup, paymentsetdown, paymentmerchid, paymentname, paymentaddress1, paymentaddress2, paymentcity, paymentst, paymentcountry, paymentzip, paymentstatecode, paymentrelatedpaymentid, paymentsetdownperforminguser, paymenttransactiondate, paymentuserccvalidcoderesponse, paymentcardentryindicator, paymentproviderresponsecode, paymenthostresponsemessage, paymenthostresponsecode, paymentavsresultcode, paymentuserccname, paymentuserccexp, paymentusercctype, paymentsetupperforminguser, paymentstatus, paymentresult, paymentoutletid, paymentchannel, paymentsetupoutletid, customerid, ordergroupid, client_id, paymentusercclastfour, cctransactiontype, provider_response_details, cc_token_id, cc_first_six, application_id, paymentprocessorresponsecode, cc_hash_info_id
, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(10), [application_id])),'DBNULL_INT') + ISNULL(RTRIM( [cc_first_six]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [cc_hash_info_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [cc_token_id]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [cctransactiontype])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [customerid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [paymentaddress1]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentaddress2]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentamount])),'DBNULL_NUMBER') + ISNULL(RTRIM( [paymentauthcode]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentavsresultcode]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentcardentryindicator])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentccbatchid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentchannel])),'DBNULL_INT') + ISNULL(RTRIM( [paymentcity]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentcountry]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [paymentdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [paymenthostresponsecode]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymenthostresponsemessage]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentmerchid])),'DBNULL_INT') + ISNULL(RTRIM( [paymentname]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentoutletid])),'DBNULL_INT') + ISNULL(RTRIM( [paymentprocessorresponsecode]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentproviderresponsecode])),'DBNULL_INT') + ISNULL(RTRIM( [paymentrefnumber]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentrelatedpaymentid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentresult])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [paymentsetdown])),'DBNULL_DATETIME') + ISNULL(RTRIM( [paymentsetdownperforminguser]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [paymentsetup])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentsetupoutletid])),'DBNULL_INT') + ISNULL(RTRIM( [paymentsetupperforminguser]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentst]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentstatecode])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [paymentstatus])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(30), [paymenttransactiondate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [paymenttranstype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [paymentuserccexp])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(10), [paymentusercckey])),'DBNULL_INT') + ISNULL(RTRIM( [paymentusercclastfour]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentuserccname]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentusercctype]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentuserccvalidcoderesponse]),'DBNULL_TEXT') + ISNULL(RTRIM( [paymentzip]),'DBNULL_TEXT') + ISNULL(RTRIM( [provider_response_details]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXpayments

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (paymentid)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXpayments AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.paymentid = mySource.paymentid 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[paymentid] = mySource.[paymentid]
     ,myTarget.[paymentccbatchid] = mySource.[paymentccbatchid]
     ,myTarget.[paymenttranstype] = mySource.[paymenttranstype]
     ,myTarget.[paymentusercckey] = mySource.[paymentusercckey]
     ,myTarget.[paymentamount] = mySource.[paymentamount]
     ,myTarget.[paymentauthcode] = mySource.[paymentauthcode]
     ,myTarget.[paymentrefnumber] = mySource.[paymentrefnumber]
     ,myTarget.[paymentdate] = mySource.[paymentdate]
     ,myTarget.[paymentsetup] = mySource.[paymentsetup]
     ,myTarget.[paymentsetdown] = mySource.[paymentsetdown]
     ,myTarget.[paymentmerchid] = mySource.[paymentmerchid]
     ,myTarget.[paymentname] = mySource.[paymentname]
     ,myTarget.[paymentaddress1] = mySource.[paymentaddress1]
     ,myTarget.[paymentaddress2] = mySource.[paymentaddress2]
     ,myTarget.[paymentcity] = mySource.[paymentcity]
     ,myTarget.[paymentst] = mySource.[paymentst]
     ,myTarget.[paymentcountry] = mySource.[paymentcountry]
     ,myTarget.[paymentzip] = mySource.[paymentzip]
     ,myTarget.[paymentstatecode] = mySource.[paymentstatecode]
     ,myTarget.[paymentrelatedpaymentid] = mySource.[paymentrelatedpaymentid]
     ,myTarget.[paymentsetdownperforminguser] = mySource.[paymentsetdownperforminguser]
     ,myTarget.[paymenttransactiondate] = mySource.[paymenttransactiondate]
     ,myTarget.[paymentuserccvalidcoderesponse] = mySource.[paymentuserccvalidcoderesponse]
     ,myTarget.[paymentcardentryindicator] = mySource.[paymentcardentryindicator]
     ,myTarget.[paymentproviderresponsecode] = mySource.[paymentproviderresponsecode]
     ,myTarget.[paymenthostresponsemessage] = mySource.[paymenthostresponsemessage]
     ,myTarget.[paymenthostresponsecode] = mySource.[paymenthostresponsecode]
     ,myTarget.[paymentavsresultcode] = mySource.[paymentavsresultcode]
     ,myTarget.[paymentuserccname] = mySource.[paymentuserccname]
     ,myTarget.[paymentuserccexp] = mySource.[paymentuserccexp]
     ,myTarget.[paymentusercctype] = mySource.[paymentusercctype]
     ,myTarget.[paymentsetupperforminguser] = mySource.[paymentsetupperforminguser]
     ,myTarget.[paymentstatus] = mySource.[paymentstatus]
     ,myTarget.[paymentresult] = mySource.[paymentresult]
     ,myTarget.[paymentoutletid] = mySource.[paymentoutletid]
     ,myTarget.[paymentchannel] = mySource.[paymentchannel]
     ,myTarget.[paymentsetupoutletid] = mySource.[paymentsetupoutletid]
     ,myTarget.[customerid] = mySource.[customerid]
     ,myTarget.[ordergroupid] = mySource.[ordergroupid]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[paymentusercclastfour] = mySource.[paymentusercclastfour]
     ,myTarget.[cctransactiontype] = mySource.[cctransactiontype]
     ,myTarget.[provider_response_details] = mySource.[provider_response_details]
     ,myTarget.[cc_token_id] = mySource.[cc_token_id]
     ,myTarget.[cc_first_six] = mySource.[cc_first_six]
     ,myTarget.[application_id] = mySource.[application_id]
     ,myTarget.[paymentprocessorresponsecode] = mySource.[paymentprocessorresponsecode]
     ,myTarget.[cc_hash_info_id] = mySource.[cc_hash_info_id]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[paymentid]
     ,[paymentccbatchid]
     ,[paymenttranstype]
     ,[paymentusercckey]
     ,[paymentamount]
     ,[paymentauthcode]
     ,[paymentrefnumber]
     ,[paymentdate]
     ,[paymentsetup]
     ,[paymentsetdown]
     ,[paymentmerchid]
     ,[paymentname]
     ,[paymentaddress1]
     ,[paymentaddress2]
     ,[paymentcity]
     ,[paymentst]
     ,[paymentcountry]
     ,[paymentzip]
     ,[paymentstatecode]
     ,[paymentrelatedpaymentid]
     ,[paymentsetdownperforminguser]
     ,[paymenttransactiondate]
     ,[paymentuserccvalidcoderesponse]
     ,[paymentcardentryindicator]
     ,[paymentproviderresponsecode]
     ,[paymenthostresponsemessage]
     ,[paymenthostresponsecode]
     ,[paymentavsresultcode]
     ,[paymentuserccname]
     ,[paymentuserccexp]
     ,[paymentusercctype]
     ,[paymentsetupperforminguser]
     ,[paymentstatus]
     ,[paymentresult]
     ,[paymentoutletid]
     ,[paymentchannel]
     ,[paymentsetupoutletid]
     ,[customerid]
     ,[ordergroupid]
     ,[client_id]
     ,[paymentusercclastfour]
     ,[cctransactiontype]
     ,[provider_response_details]
     ,[cc_token_id]
     ,[cc_first_six]
     ,[application_id]
     ,[paymentprocessorresponsecode]
     ,[cc_hash_info_id]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[paymentid]
     ,mySource.[paymentccbatchid]
     ,mySource.[paymenttranstype]
     ,mySource.[paymentusercckey]
     ,mySource.[paymentamount]
     ,mySource.[paymentauthcode]
     ,mySource.[paymentrefnumber]
     ,mySource.[paymentdate]
     ,mySource.[paymentsetup]
     ,mySource.[paymentsetdown]
     ,mySource.[paymentmerchid]
     ,mySource.[paymentname]
     ,mySource.[paymentaddress1]
     ,mySource.[paymentaddress2]
     ,mySource.[paymentcity]
     ,mySource.[paymentst]
     ,mySource.[paymentcountry]
     ,mySource.[paymentzip]
     ,mySource.[paymentstatecode]
     ,mySource.[paymentrelatedpaymentid]
     ,mySource.[paymentsetdownperforminguser]
     ,mySource.[paymenttransactiondate]
     ,mySource.[paymentuserccvalidcoderesponse]
     ,mySource.[paymentcardentryindicator]
     ,mySource.[paymentproviderresponsecode]
     ,mySource.[paymenthostresponsemessage]
     ,mySource.[paymenthostresponsecode]
     ,mySource.[paymentavsresultcode]
     ,mySource.[paymentuserccname]
     ,mySource.[paymentuserccexp]
     ,mySource.[paymentusercctype]
     ,mySource.[paymentsetupperforminguser]
     ,mySource.[paymentstatus]
     ,mySource.[paymentresult]
     ,mySource.[paymentoutletid]
     ,mySource.[paymentchannel]
     ,mySource.[paymentsetupoutletid]
     ,mySource.[customerid]
     ,mySource.[ordergroupid]
     ,mySource.[client_id]
     ,mySource.[paymentusercclastfour]
     ,mySource.[cctransactiontype]
     ,mySource.[provider_response_details]
     ,mySource.[cc_token_id]
     ,mySource.[cc_first_six]
     ,mySource.[application_id]
     ,mySource.[paymentprocessorresponsecode]
     ,mySource.[cc_hash_info_id]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXpayments
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXpayments o
LEFT JOIN src.VTXpayments_UK s ON s.paymentid = o.paymentid
WHERE s.paymentid IS NULL

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Delete Process', 'Soft Deletes Process', 'Complete', @ExecutionId


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
