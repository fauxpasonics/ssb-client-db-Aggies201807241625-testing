SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVEvents_tbl_trans]
(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = null
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     svcETL
Date:     07/10/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVEvents_tbl_trans),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  id, contactid, create_date, trans_date, pmt_descr, pmt_amount, auth_code, resp_code, resp_text, trans_id, pmt_method, cc_name, cc_addr, cc_zip, cc_phone, bank_acct, bank_rout, bank_acct_type, programid, cust_ip, cc_city, cc_state, cc_email, bank_name, company, acct_number, recur, trans_profile_id, note, misc, transyear, order_id, monthly, adv_post_date, receiptbyid
INTO #SrcData
FROM ods.ADVEvents_tbl_trans

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVEvents_tbl_trans AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id

WHEN MATCHED

THEN UPDATE SET
      myTarget.[id] = mySource.[id]
     ,myTarget.[contactid] = mySource.[contactid]
     ,myTarget.[create_date] = mySource.[create_date]
     ,myTarget.[trans_date] = mySource.[trans_date]
     ,myTarget.[pmt_descr] = mySource.[pmt_descr]
     ,myTarget.[pmt_amount] = mySource.[pmt_amount]
     ,myTarget.[auth_code] = mySource.[auth_code]
     ,myTarget.[resp_code] = mySource.[resp_code]
     ,myTarget.[resp_text] = mySource.[resp_text]
     ,myTarget.[trans_id] = mySource.[trans_id]
     ,myTarget.[pmt_method] = mySource.[pmt_method]
     ,myTarget.[cc_name] = mySource.[cc_name]
     ,myTarget.[cc_addr] = mySource.[cc_addr]
     ,myTarget.[cc_zip] = mySource.[cc_zip]
     ,myTarget.[cc_phone] = mySource.[cc_phone]
     ,myTarget.[bank_acct] = mySource.[bank_acct]
     ,myTarget.[bank_rout] = mySource.[bank_rout]
     ,myTarget.[bank_acct_type] = mySource.[bank_acct_type]
     ,myTarget.[programid] = mySource.[programid]
     ,myTarget.[cust_ip] = mySource.[cust_ip]
     ,myTarget.[cc_city] = mySource.[cc_city]
     ,myTarget.[cc_state] = mySource.[cc_state]
     ,myTarget.[cc_email] = mySource.[cc_email]
     ,myTarget.[bank_name] = mySource.[bank_name]
     ,myTarget.[company] = mySource.[company]
     ,myTarget.[acct_number] = mySource.[acct_number]
     ,myTarget.[recur] = mySource.[recur]
     ,myTarget.[trans_profile_id] = mySource.[trans_profile_id]
     ,myTarget.[note] = mySource.[note]
     ,myTarget.[misc] = mySource.[misc]
     ,myTarget.[transyear] = mySource.[transyear]
     ,myTarget.[order_id] = mySource.[order_id]
     ,myTarget.[monthly] = mySource.[monthly]
     ,myTarget.[adv_post_date] = mySource.[adv_post_date]
     ,myTarget.[receiptbyid] = mySource.[receiptbyid]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([id]
     ,[contactid]
     ,[create_date]
     ,[trans_date]
     ,[pmt_descr]
     ,[pmt_amount]
     ,[auth_code]
     ,[resp_code]
     ,[resp_text]
     ,[trans_id]
     ,[pmt_method]
     ,[cc_name]
     ,[cc_addr]
     ,[cc_zip]
     ,[cc_phone]
     ,[bank_acct]
     ,[bank_rout]
     ,[bank_acct_type]
     ,[programid]
     ,[cust_ip]
     ,[cc_city]
     ,[cc_state]
     ,[cc_email]
     ,[bank_name]
     ,[company]
     ,[acct_number]
     ,[recur]
     ,[trans_profile_id]
     ,[note]
     ,[misc]
     ,[transyear]
     ,[order_id]
     ,[monthly]
     ,[adv_post_date]
     ,[receiptbyid]
     )
VALUES
     (mySource.[id]
     ,mySource.[contactid]
     ,mySource.[create_date]
     ,mySource.[trans_date]
     ,mySource.[pmt_descr]
     ,mySource.[pmt_amount]
     ,mySource.[auth_code]
     ,mySource.[resp_code]
     ,mySource.[resp_text]
     ,mySource.[trans_id]
     ,mySource.[pmt_method]
     ,mySource.[cc_name]
     ,mySource.[cc_addr]
     ,mySource.[cc_zip]
     ,mySource.[cc_phone]
     ,mySource.[bank_acct]
     ,mySource.[bank_rout]
     ,mySource.[bank_acct_type]
     ,mySource.[programid]
     ,mySource.[cust_ip]
     ,mySource.[cc_city]
     ,mySource.[cc_state]
     ,mySource.[cc_email]
     ,mySource.[bank_name]
     ,mySource.[company]
     ,mySource.[acct_number]
     ,mySource.[recur]
     ,mySource.[trans_profile_id]
     ,mySource.[note]
     ,mySource.[misc]
     ,mySource.[transyear]
     ,mySource.[order_id]
     ,mySource.[monthly]
     ,mySource.[adv_post_date]
     ,mySource.[receiptbyid]
     )

WHEN NOT MATCHED BY SOURCE

THEN DELETE
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
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
