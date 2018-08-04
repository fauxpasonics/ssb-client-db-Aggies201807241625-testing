SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXordergroups]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXordergroups),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT 
	ETL_ID, ETL_CreatedDate, ETL_SourceFileName, ordergroup, ordergroupsegregationcode, ordergrouppaymentmode, ordergroupshipservechargemode, ordergroupmasterorderid, ordergroupinituser, ordergroupenteredby, ordergrouporiginaltotal, ordergroupgrandtotal, ordergrouptotaldiscounts, ordergrouptotaltax, ordergroupshippingtotal, ordergroupshippingdiscounts, ordergroupshippingtax, ordergroupservicechgtotal, ordergroupservicechgdiscount, ordergroupservicechgtax, ordergrouptotalpaymentsreq, ordergrouptotalaltpayments, ordergrouprelatedestabtype, ordergrouprelatedestabkey, ordergroupordertype, ordergroupsingleormultiuser, ordergroupshippingdestmode, ordergrouprelatedestabrelation, ordergroupshipname, ordergroupshipaddress1, ordergroupshipaddress2, ordergroupshipcity, ordergroupshipst, ordergroupshipcountry, ordergroupshipzip, ordergroupshipstatecode, ordergroupshippingzone, ordergroupshippingzoneinvalid, usercountycode, ordergroupinitialep, ordergroupcheckoutep, ordergroupshipcountycode, ordergroupuserid, ordergroupconfirmationnumber, ordergrouptimetoplaceorder, ordergroupbottomlineorigtotal, ordergroupbottomlinegrandtotal, ordergroupbottomlineactivtotal, ordergroupbottomlinetotaltax, ordergroupbottomlinetotaldisc, ordergroupactivetotal, ordergroupshippingactivetotal, ordergroupservicechgactivtotal, ordergrouptotalpaymentscleared, ordergrouptotalpaymentsonhold, ordergrouptotalpaymentsinqueue, ordergrouppaymentbalance, ordergroupdate, ordergroupclosedondate, ordergroupstatus, ordergrouptimetocompleteorder, ordergroupclosed, ordergrouplastupdated, ordergroupinvoicenumber, commentid, ordergroupoutletid, ordergrouppaymentstatus, eticketemail, customerid, willcallcode, addressid, willcallname, client_id, tickets_ever_in_fs, convertfsunpaid, tags, ordergrouppaymentbypass
	, HASHBYTES('sha2_256', ISNULL(RTRIM(CONVERT(varchar(50), [addressid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [commentid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [convertfsunpaid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [customerid])),'DBNULL_NUMBER') + ISNULL(RTRIM( [eticketemail]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroup])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupactivetotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupbottomlineactivtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupbottomlinegrandtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupbottomlineorigtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupbottomlinetotaldisc])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupbottomlinetotaltax])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupcheckoutep])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupclosed])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(30), [ordergroupclosedondate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [ordergroupconfirmationnumber]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [ordergroupdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [ordergroupenteredby]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupgrandtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupinitialep])),'DBNULL_INT') + ISNULL(RTRIM( [ordergroupinituser]),'DBNULL_TEXT') + ISNULL(RTRIM( [ordergroupinvoicenumber]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [ordergrouplastupdated])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupmasterorderid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupordertype])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouporiginaltotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupoutletid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouppaymentbalance])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergrouppaymentbypass])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergrouppaymentmode])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergrouppaymentstatus])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouprelatedestabkey])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergrouprelatedestabrelation])),'DBNULL_INT') + ISNULL(RTRIM( [ordergrouprelatedestabtype]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupsegregationcode])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupservicechgactivtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupservicechgdiscount])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupservicechgtax])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupservicechgtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM( [ordergroupshipaddress1]),'DBNULL_TEXT') + ISNULL(RTRIM( [ordergroupshipaddress2]),'DBNULL_TEXT') + ISNULL(RTRIM( [ordergroupshipcity]),'DBNULL_TEXT') + ISNULL(RTRIM( [ordergroupshipcountry]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshipcountycode])),'DBNULL_INT') + ISNULL(RTRIM( [ordergroupshipname]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupshippingactivetotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshippingdestmode])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupshippingdiscounts])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupshippingtax])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergroupshippingtotal])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshippingzone])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshippingzoneinvalid])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshipservechargemode])),'DBNULL_INT') + ISNULL(RTRIM( [ordergroupshipst]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupshipstatecode])),'DBNULL_INT') + ISNULL(RTRIM( [ordergroupshipzip]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupsingleormultiuser])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [ordergroupstatus])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptimetocompleteorder])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptimetoplaceorder])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotalaltpayments])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotaldiscounts])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotalpaymentscleared])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotalpaymentsinqueue])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotalpaymentsonhold])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotalpaymentsreq])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [ordergrouptotaltax])),'DBNULL_NUMBER') + ISNULL(RTRIM( [ordergroupuserid]),'DBNULL_TEXT') + ISNULL(RTRIM( [tags]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [tickets_ever_in_fs])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [usercountycode])),'DBNULL_INT') + ISNULL(RTRIM( [willcallcode]),'DBNULL_TEXT') + ISNULL(RTRIM( [willcallname]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM (
	SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, ordergroup, ordergroupsegregationcode, ordergrouppaymentmode, ordergroupshipservechargemode, ordergroupmasterorderid, ordergroupinituser, ordergroupenteredby, ordergrouporiginaltotal, ordergroupgrandtotal, ordergrouptotaldiscounts, ordergrouptotaltax, ordergroupshippingtotal, ordergroupshippingdiscounts, ordergroupshippingtax, ordergroupservicechgtotal, ordergroupservicechgdiscount, ordergroupservicechgtax, ordergrouptotalpaymentsreq, ordergrouptotalaltpayments, ordergrouprelatedestabtype, ordergrouprelatedestabkey, ordergroupordertype, ordergroupsingleormultiuser, ordergroupshippingdestmode, ordergrouprelatedestabrelation, ordergroupshipname, ordergroupshipaddress1, ordergroupshipaddress2, ordergroupshipcity, ordergroupshipst, ordergroupshipcountry, ordergroupshipzip, ordergroupshipstatecode, ordergroupshippingzone, ordergroupshippingzoneinvalid, usercountycode, ordergroupinitialep, ordergroupcheckoutep, ordergroupshipcountycode, ordergroupuserid, ordergroupconfirmationnumber, ordergrouptimetoplaceorder, ordergroupbottomlineorigtotal, ordergroupbottomlinegrandtotal, ordergroupbottomlineactivtotal, ordergroupbottomlinetotaltax, ordergroupbottomlinetotaldisc, ordergroupactivetotal, ordergroupshippingactivetotal, ordergroupservicechgactivtotal, ordergrouptotalpaymentscleared, ordergrouptotalpaymentsonhold, ordergrouptotalpaymentsinqueue, ordergrouppaymentbalance, ordergroupdate, ordergroupclosedondate, ordergroupstatus, ordergrouptimetocompleteorder, ordergroupclosed, ordergrouplastupdated, ordergroupinvoicenumber, commentid, ordergroupoutletid, ordergrouppaymentstatus, eticketemail, customerid, willcallcode, addressid, willcallname, client_id, tickets_ever_in_fs, convertfsunpaid, tags, ordergrouppaymentbypass	
	, ROW_NUMBER() OVER(PARTITION BY ordergroup ORDER BY ETL_ID DESC) RowRank
	FROM src.VTXordergroups
) a 
WHERE a.RowRank = 1

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ordergroup)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXordergroups AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ordergroup = mySource.ordergroup 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[ordergroup] = mySource.[ordergroup]
     ,myTarget.[ordergroupsegregationcode] = mySource.[ordergroupsegregationcode]
     ,myTarget.[ordergrouppaymentmode] = mySource.[ordergrouppaymentmode]
     ,myTarget.[ordergroupshipservechargemode] = mySource.[ordergroupshipservechargemode]
     ,myTarget.[ordergroupmasterorderid] = mySource.[ordergroupmasterorderid]
     ,myTarget.[ordergroupinituser] = mySource.[ordergroupinituser]
     ,myTarget.[ordergroupenteredby] = mySource.[ordergroupenteredby]
     ,myTarget.[ordergrouporiginaltotal] = mySource.[ordergrouporiginaltotal]
     ,myTarget.[ordergroupgrandtotal] = mySource.[ordergroupgrandtotal]
     ,myTarget.[ordergrouptotaldiscounts] = mySource.[ordergrouptotaldiscounts]
     ,myTarget.[ordergrouptotaltax] = mySource.[ordergrouptotaltax]
     ,myTarget.[ordergroupshippingtotal] = mySource.[ordergroupshippingtotal]
     ,myTarget.[ordergroupshippingdiscounts] = mySource.[ordergroupshippingdiscounts]
     ,myTarget.[ordergroupshippingtax] = mySource.[ordergroupshippingtax]
     ,myTarget.[ordergroupservicechgtotal] = mySource.[ordergroupservicechgtotal]
     ,myTarget.[ordergroupservicechgdiscount] = mySource.[ordergroupservicechgdiscount]
     ,myTarget.[ordergroupservicechgtax] = mySource.[ordergroupservicechgtax]
     ,myTarget.[ordergrouptotalpaymentsreq] = mySource.[ordergrouptotalpaymentsreq]
     ,myTarget.[ordergrouptotalaltpayments] = mySource.[ordergrouptotalaltpayments]
     ,myTarget.[ordergrouprelatedestabtype] = mySource.[ordergrouprelatedestabtype]
     ,myTarget.[ordergrouprelatedestabkey] = mySource.[ordergrouprelatedestabkey]
     ,myTarget.[ordergroupordertype] = mySource.[ordergroupordertype]
     ,myTarget.[ordergroupsingleormultiuser] = mySource.[ordergroupsingleormultiuser]
     ,myTarget.[ordergroupshippingdestmode] = mySource.[ordergroupshippingdestmode]
     ,myTarget.[ordergrouprelatedestabrelation] = mySource.[ordergrouprelatedestabrelation]
     ,myTarget.[ordergroupshipname] = mySource.[ordergroupshipname]
     ,myTarget.[ordergroupshipaddress1] = mySource.[ordergroupshipaddress1]
     ,myTarget.[ordergroupshipaddress2] = mySource.[ordergroupshipaddress2]
     ,myTarget.[ordergroupshipcity] = mySource.[ordergroupshipcity]
     ,myTarget.[ordergroupshipst] = mySource.[ordergroupshipst]
     ,myTarget.[ordergroupshipcountry] = mySource.[ordergroupshipcountry]
     ,myTarget.[ordergroupshipzip] = mySource.[ordergroupshipzip]
     ,myTarget.[ordergroupshipstatecode] = mySource.[ordergroupshipstatecode]
     ,myTarget.[ordergroupshippingzone] = mySource.[ordergroupshippingzone]
     ,myTarget.[ordergroupshippingzoneinvalid] = mySource.[ordergroupshippingzoneinvalid]
     ,myTarget.[usercountycode] = mySource.[usercountycode]
     ,myTarget.[ordergroupinitialep] = mySource.[ordergroupinitialep]
     ,myTarget.[ordergroupcheckoutep] = mySource.[ordergroupcheckoutep]
     ,myTarget.[ordergroupshipcountycode] = mySource.[ordergroupshipcountycode]
     ,myTarget.[ordergroupuserid] = mySource.[ordergroupuserid]
     ,myTarget.[ordergroupconfirmationnumber] = mySource.[ordergroupconfirmationnumber]
     ,myTarget.[ordergrouptimetoplaceorder] = mySource.[ordergrouptimetoplaceorder]
     ,myTarget.[ordergroupbottomlineorigtotal] = mySource.[ordergroupbottomlineorigtotal]
     ,myTarget.[ordergroupbottomlinegrandtotal] = mySource.[ordergroupbottomlinegrandtotal]
     ,myTarget.[ordergroupbottomlineactivtotal] = mySource.[ordergroupbottomlineactivtotal]
     ,myTarget.[ordergroupbottomlinetotaltax] = mySource.[ordergroupbottomlinetotaltax]
     ,myTarget.[ordergroupbottomlinetotaldisc] = mySource.[ordergroupbottomlinetotaldisc]
     ,myTarget.[ordergroupactivetotal] = mySource.[ordergroupactivetotal]
     ,myTarget.[ordergroupshippingactivetotal] = mySource.[ordergroupshippingactivetotal]
     ,myTarget.[ordergroupservicechgactivtotal] = mySource.[ordergroupservicechgactivtotal]
     ,myTarget.[ordergrouptotalpaymentscleared] = mySource.[ordergrouptotalpaymentscleared]
     ,myTarget.[ordergrouptotalpaymentsonhold] = mySource.[ordergrouptotalpaymentsonhold]
     ,myTarget.[ordergrouptotalpaymentsinqueue] = mySource.[ordergrouptotalpaymentsinqueue]
     ,myTarget.[ordergrouppaymentbalance] = mySource.[ordergrouppaymentbalance]
     ,myTarget.[ordergroupdate] = mySource.[ordergroupdate]
     ,myTarget.[ordergroupclosedondate] = mySource.[ordergroupclosedondate]
     ,myTarget.[ordergroupstatus] = mySource.[ordergroupstatus]
     ,myTarget.[ordergrouptimetocompleteorder] = mySource.[ordergrouptimetocompleteorder]
     ,myTarget.[ordergroupclosed] = mySource.[ordergroupclosed]
     ,myTarget.[ordergrouplastupdated] = mySource.[ordergrouplastupdated]
     ,myTarget.[ordergroupinvoicenumber] = mySource.[ordergroupinvoicenumber]
     ,myTarget.[commentid] = mySource.[commentid]
     ,myTarget.[ordergroupoutletid] = mySource.[ordergroupoutletid]
     ,myTarget.[ordergrouppaymentstatus] = mySource.[ordergrouppaymentstatus]
     ,myTarget.[eticketemail] = mySource.[eticketemail]
     ,myTarget.[customerid] = mySource.[customerid]
     ,myTarget.[willcallcode] = mySource.[willcallcode]
     ,myTarget.[addressid] = mySource.[addressid]
     ,myTarget.[willcallname] = mySource.[willcallname]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[tickets_ever_in_fs] = mySource.[tickets_ever_in_fs]
     ,myTarget.[convertfsunpaid] = mySource.[convertfsunpaid]
     ,myTarget.[tags] = mySource.[tags]
     ,myTarget.[ordergrouppaymentbypass] = mySource.[ordergrouppaymentbypass]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[ordergroup]
     ,[ordergroupsegregationcode]
     ,[ordergrouppaymentmode]
     ,[ordergroupshipservechargemode]
     ,[ordergroupmasterorderid]
     ,[ordergroupinituser]
     ,[ordergroupenteredby]
     ,[ordergrouporiginaltotal]
     ,[ordergroupgrandtotal]
     ,[ordergrouptotaldiscounts]
     ,[ordergrouptotaltax]
     ,[ordergroupshippingtotal]
     ,[ordergroupshippingdiscounts]
     ,[ordergroupshippingtax]
     ,[ordergroupservicechgtotal]
     ,[ordergroupservicechgdiscount]
     ,[ordergroupservicechgtax]
     ,[ordergrouptotalpaymentsreq]
     ,[ordergrouptotalaltpayments]
     ,[ordergrouprelatedestabtype]
     ,[ordergrouprelatedestabkey]
     ,[ordergroupordertype]
     ,[ordergroupsingleormultiuser]
     ,[ordergroupshippingdestmode]
     ,[ordergrouprelatedestabrelation]
     ,[ordergroupshipname]
     ,[ordergroupshipaddress1]
     ,[ordergroupshipaddress2]
     ,[ordergroupshipcity]
     ,[ordergroupshipst]
     ,[ordergroupshipcountry]
     ,[ordergroupshipzip]
     ,[ordergroupshipstatecode]
     ,[ordergroupshippingzone]
     ,[ordergroupshippingzoneinvalid]
     ,[usercountycode]
     ,[ordergroupinitialep]
     ,[ordergroupcheckoutep]
     ,[ordergroupshipcountycode]
     ,[ordergroupuserid]
     ,[ordergroupconfirmationnumber]
     ,[ordergrouptimetoplaceorder]
     ,[ordergroupbottomlineorigtotal]
     ,[ordergroupbottomlinegrandtotal]
     ,[ordergroupbottomlineactivtotal]
     ,[ordergroupbottomlinetotaltax]
     ,[ordergroupbottomlinetotaldisc]
     ,[ordergroupactivetotal]
     ,[ordergroupshippingactivetotal]
     ,[ordergroupservicechgactivtotal]
     ,[ordergrouptotalpaymentscleared]
     ,[ordergrouptotalpaymentsonhold]
     ,[ordergrouptotalpaymentsinqueue]
     ,[ordergrouppaymentbalance]
     ,[ordergroupdate]
     ,[ordergroupclosedondate]
     ,[ordergroupstatus]
     ,[ordergrouptimetocompleteorder]
     ,[ordergroupclosed]
     ,[ordergrouplastupdated]
     ,[ordergroupinvoicenumber]
     ,[commentid]
     ,[ordergroupoutletid]
     ,[ordergrouppaymentstatus]
     ,[eticketemail]
     ,[customerid]
     ,[willcallcode]
     ,[addressid]
     ,[willcallname]
     ,[client_id]
     ,[tickets_ever_in_fs]
     ,[convertfsunpaid]
     ,[tags]
     ,[ordergrouppaymentbypass]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[ordergroup]
     ,mySource.[ordergroupsegregationcode]
     ,mySource.[ordergrouppaymentmode]
     ,mySource.[ordergroupshipservechargemode]
     ,mySource.[ordergroupmasterorderid]
     ,mySource.[ordergroupinituser]
     ,mySource.[ordergroupenteredby]
     ,mySource.[ordergrouporiginaltotal]
     ,mySource.[ordergroupgrandtotal]
     ,mySource.[ordergrouptotaldiscounts]
     ,mySource.[ordergrouptotaltax]
     ,mySource.[ordergroupshippingtotal]
     ,mySource.[ordergroupshippingdiscounts]
     ,mySource.[ordergroupshippingtax]
     ,mySource.[ordergroupservicechgtotal]
     ,mySource.[ordergroupservicechgdiscount]
     ,mySource.[ordergroupservicechgtax]
     ,mySource.[ordergrouptotalpaymentsreq]
     ,mySource.[ordergrouptotalaltpayments]
     ,mySource.[ordergrouprelatedestabtype]
     ,mySource.[ordergrouprelatedestabkey]
     ,mySource.[ordergroupordertype]
     ,mySource.[ordergroupsingleormultiuser]
     ,mySource.[ordergroupshippingdestmode]
     ,mySource.[ordergrouprelatedestabrelation]
     ,mySource.[ordergroupshipname]
     ,mySource.[ordergroupshipaddress1]
     ,mySource.[ordergroupshipaddress2]
     ,mySource.[ordergroupshipcity]
     ,mySource.[ordergroupshipst]
     ,mySource.[ordergroupshipcountry]
     ,mySource.[ordergroupshipzip]
     ,mySource.[ordergroupshipstatecode]
     ,mySource.[ordergroupshippingzone]
     ,mySource.[ordergroupshippingzoneinvalid]
     ,mySource.[usercountycode]
     ,mySource.[ordergroupinitialep]
     ,mySource.[ordergroupcheckoutep]
     ,mySource.[ordergroupshipcountycode]
     ,mySource.[ordergroupuserid]
     ,mySource.[ordergroupconfirmationnumber]
     ,mySource.[ordergrouptimetoplaceorder]
     ,mySource.[ordergroupbottomlineorigtotal]
     ,mySource.[ordergroupbottomlinegrandtotal]
     ,mySource.[ordergroupbottomlineactivtotal]
     ,mySource.[ordergroupbottomlinetotaltax]
     ,mySource.[ordergroupbottomlinetotaldisc]
     ,mySource.[ordergroupactivetotal]
     ,mySource.[ordergroupshippingactivetotal]
     ,mySource.[ordergroupservicechgactivtotal]
     ,mySource.[ordergrouptotalpaymentscleared]
     ,mySource.[ordergrouptotalpaymentsonhold]
     ,mySource.[ordergrouptotalpaymentsinqueue]
     ,mySource.[ordergrouppaymentbalance]
     ,mySource.[ordergroupdate]
     ,mySource.[ordergroupclosedondate]
     ,mySource.[ordergroupstatus]
     ,mySource.[ordergrouptimetocompleteorder]
     ,mySource.[ordergroupclosed]
     ,mySource.[ordergrouplastupdated]
     ,mySource.[ordergroupinvoicenumber]
     ,mySource.[commentid]
     ,mySource.[ordergroupoutletid]
     ,mySource.[ordergrouppaymentstatus]
     ,mySource.[eticketemail]
     ,mySource.[customerid]
     ,mySource.[willcallcode]
     ,mySource.[addressid]
     ,mySource.[willcallname]
     ,mySource.[client_id]
     ,mySource.[tickets_ever_in_fs]
     ,mySource.[convertfsunpaid]
     ,mySource.[tags]
     ,mySource.[ordergrouppaymentbypass]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXordergroups
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXordergroups o
LEFT JOIN src.VTXordergroups_UK s ON s.ordergroup = o.ordergroup
WHERE s.ordergroup IS NULL

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
