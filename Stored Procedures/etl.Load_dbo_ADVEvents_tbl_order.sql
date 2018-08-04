SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_dbo_ADVEvents_tbl_order]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVEvents_tbl_order),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  id, sessionid, category, create_date, submit_date, processor, va_date, va_order_id, acct, name, addr, addr2, addr3, city, state, zip, phone, email, mail_name, mail_addr, mail_addr2, mail_city, mail_state, mail_zip, pmt_schedule, card_number, card_expire, don_name, don_addr, don_addr2, don_city, don_state, don_zip, don_phone, don_email, don_pmt_schedule, don_card_number, don_card_expire, comments, faculty_info, mail_care_of, alumni_info, home_phone, work_phone, cell_phone, employer, title, check_number, check_name, trans_profile_id, don_post_date, lettermen_info, delivery_method, trans_post_date, pmt_method, va_rg_date, va_rg_order_id, uin
INTO #SrcData
FROM ods.ADVEvents_tbl_order

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVEvents_tbl_order AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id

WHEN MATCHED

THEN UPDATE SET
      myTarget.[id] = mySource.[id]
     ,myTarget.[sessionid] = mySource.[sessionid]
     ,myTarget.[category] = mySource.[category]
     ,myTarget.[create_date] = mySource.[create_date]
     ,myTarget.[submit_date] = mySource.[submit_date]
     ,myTarget.[processor] = mySource.[processor]
     ,myTarget.[va_date] = mySource.[va_date]
     ,myTarget.[va_order_id] = mySource.[va_order_id]
     ,myTarget.[acct] = mySource.[acct]
     ,myTarget.[name] = mySource.[name]
     ,myTarget.[addr] = mySource.[addr]
     ,myTarget.[addr2] = mySource.[addr2]
     ,myTarget.[addr3] = mySource.[addr3]
     ,myTarget.[city] = mySource.[city]
     ,myTarget.[state] = mySource.[state]
     ,myTarget.[zip] = mySource.[zip]
     ,myTarget.[phone] = mySource.[phone]
     ,myTarget.[email] = mySource.[email]
     ,myTarget.[mail_name] = mySource.[mail_name]
     ,myTarget.[mail_addr] = mySource.[mail_addr]
     ,myTarget.[mail_addr2] = mySource.[mail_addr2]
     ,myTarget.[mail_city] = mySource.[mail_city]
     ,myTarget.[mail_state] = mySource.[mail_state]
     ,myTarget.[mail_zip] = mySource.[mail_zip]
     ,myTarget.[pmt_schedule] = mySource.[pmt_schedule]
     ,myTarget.[card_number] = mySource.[card_number]
     ,myTarget.[card_expire] = mySource.[card_expire]
     ,myTarget.[don_name] = mySource.[don_name]
     ,myTarget.[don_addr] = mySource.[don_addr]
     ,myTarget.[don_addr2] = mySource.[don_addr2]
     ,myTarget.[don_city] = mySource.[don_city]
     ,myTarget.[don_state] = mySource.[don_state]
     ,myTarget.[don_zip] = mySource.[don_zip]
     ,myTarget.[don_phone] = mySource.[don_phone]
     ,myTarget.[don_email] = mySource.[don_email]
     ,myTarget.[don_pmt_schedule] = mySource.[don_pmt_schedule]
     ,myTarget.[don_card_number] = mySource.[don_card_number]
     ,myTarget.[don_card_expire] = mySource.[don_card_expire]
     ,myTarget.[comments] = mySource.[comments]
     ,myTarget.[faculty_info] = mySource.[faculty_info]
     ,myTarget.[mail_care_of] = mySource.[mail_care_of]
     ,myTarget.[alumni_info] = mySource.[alumni_info]
     ,myTarget.[home_phone] = mySource.[home_phone]
     ,myTarget.[work_phone] = mySource.[work_phone]
     ,myTarget.[cell_phone] = mySource.[cell_phone]
     ,myTarget.[employer] = mySource.[employer]
     ,myTarget.[title] = mySource.[title]
     ,myTarget.[check_number] = mySource.[check_number]
     ,myTarget.[check_name] = mySource.[check_name]
     ,myTarget.[trans_profile_id] = mySource.[trans_profile_id]
     ,myTarget.[don_post_date] = mySource.[don_post_date]
     ,myTarget.[lettermen_info] = mySource.[lettermen_info]
     ,myTarget.[delivery_method] = mySource.[delivery_method]
     ,myTarget.[trans_post_date] = mySource.[trans_post_date]
     ,myTarget.[pmt_method] = mySource.[pmt_method]
     ,myTarget.[va_rg_date] = mySource.[va_rg_date]
     ,myTarget.[va_rg_order_id] = mySource.[va_rg_order_id]
     ,myTarget.[uin] = mySource.[uin]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([id]
     ,[sessionid]
     ,[category]
     ,[create_date]
     ,[submit_date]
     ,[processor]
     ,[va_date]
     ,[va_order_id]
     ,[acct]
     ,[name]
     ,[addr]
     ,[addr2]
     ,[addr3]
     ,[city]
     ,[state]
     ,[zip]
     ,[phone]
     ,[email]
     ,[mail_name]
     ,[mail_addr]
     ,[mail_addr2]
     ,[mail_city]
     ,[mail_state]
     ,[mail_zip]
     ,[pmt_schedule]
     ,[card_number]
     ,[card_expire]
     ,[don_name]
     ,[don_addr]
     ,[don_addr2]
     ,[don_city]
     ,[don_state]
     ,[don_zip]
     ,[don_phone]
     ,[don_email]
     ,[don_pmt_schedule]
     ,[don_card_number]
     ,[don_card_expire]
     ,[comments]
     ,[faculty_info]
     ,[mail_care_of]
     ,[alumni_info]
     ,[home_phone]
     ,[work_phone]
     ,[cell_phone]
     ,[employer]
     ,[title]
     ,[check_number]
     ,[check_name]
     ,[trans_profile_id]
     ,[don_post_date]
     ,[lettermen_info]
     ,[delivery_method]
     ,[trans_post_date]
     ,[pmt_method]
     ,[va_rg_date]
     ,[va_rg_order_id]
     ,[uin]
     )
VALUES
     (mySource.[id]
     ,mySource.[sessionid]
     ,mySource.[category]
     ,mySource.[create_date]
     ,mySource.[submit_date]
     ,mySource.[processor]
     ,mySource.[va_date]
     ,mySource.[va_order_id]
     ,mySource.[acct]
     ,mySource.[name]
     ,mySource.[addr]
     ,mySource.[addr2]
     ,mySource.[addr3]
     ,mySource.[city]
     ,mySource.[state]
     ,mySource.[zip]
     ,mySource.[phone]
     ,mySource.[email]
     ,mySource.[mail_name]
     ,mySource.[mail_addr]
     ,mySource.[mail_addr2]
     ,mySource.[mail_city]
     ,mySource.[mail_state]
     ,mySource.[mail_zip]
     ,mySource.[pmt_schedule]
     ,mySource.[card_number]
     ,mySource.[card_expire]
     ,mySource.[don_name]
     ,mySource.[don_addr]
     ,mySource.[don_addr2]
     ,mySource.[don_city]
     ,mySource.[don_state]
     ,mySource.[don_zip]
     ,mySource.[don_phone]
     ,mySource.[don_email]
     ,mySource.[don_pmt_schedule]
     ,mySource.[don_card_number]
     ,mySource.[don_card_expire]
     ,mySource.[comments]
     ,mySource.[faculty_info]
     ,mySource.[mail_care_of]
     ,mySource.[alumni_info]
     ,mySource.[home_phone]
     ,mySource.[work_phone]
     ,mySource.[cell_phone]
     ,mySource.[employer]
     ,mySource.[title]
     ,mySource.[check_number]
     ,mySource.[check_name]
     ,mySource.[trans_profile_id]
     ,mySource.[don_post_date]
     ,mySource.[lettermen_info]
     ,mySource.[delivery_method]
     ,mySource.[trans_post_date]
     ,mySource.[pmt_method]
     ,mySource.[va_rg_date]
     ,mySource.[va_rg_order_id]
     ,mySource.[uin]
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
