SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_ods_VTXoffers]
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
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXoffers),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, id, lookup, name, description, type, display_date, sort_date, promotion_code, on_sale_date, off_sale_date, ae_user_id, ae_role_id, use_user_ssc, min_qty, max_qty, customer_list_id, pref_fee_target, published, list_online, is_draft, image, client_id, allow_public_seat_change, require_contiguous_seats, allow_empty_single_seats, additional_info1, additional_info2, customer_restriction_count, has_account_restriction, has_pass_code_restriction, has_sign_in_restriction, system_type, timer_profile_id, default_restrict_transfer, default_restrict_resale, default_waive_first_seller_fee, osearch, fs_redirect, offerlabel, version, tags, offer_image_id, mobile_image_id, allow_additional_donation_ots
, HASHBYTES('sha2_256', ISNULL(RTRIM( [additional_info1]),'DBNULL_TEXT') + ISNULL(RTRIM( [additional_info2]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [ae_role_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [ae_user_id]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [allow_additional_donation_ots])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [allow_empty_single_seats])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [allow_public_seat_change])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [client_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [customer_list_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [customer_restriction_count])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [default_restrict_resale])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [default_restrict_transfer])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [default_waive_first_seller_fee])),'DBNULL_INT') + ISNULL(RTRIM( [description]),'DBNULL_TEXT') + ISNULL(RTRIM( [display_date]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [fs_redirect])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [has_account_restriction])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [has_pass_code_restriction])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [has_sign_in_restriction])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [id])),'DBNULL_NUMBER') 
+ /*ISNULL(RTRIM( [image]),'DBNULL_TEXT') +*/ ISNULL(RTRIM(CONVERT(varchar(10), [is_draft])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [list_online])),'DBNULL_INT') + ISNULL(RTRIM( [lookup]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [max_qty])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [min_qty])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(50), [mobile_image_id])),'DBNULL_NUMBER') + ISNULL(RTRIM( [name]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(30), [off_sale_date])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(50), [offer_image_id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(10), [offerlabel])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(30), [on_sale_date])),'DBNULL_DATETIME') + ISNULL(RTRIM( [osearch]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(50), [pref_fee_target])),'DBNULL_NUMBER') + ISNULL(RTRIM( [promotion_code]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [published])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(10), [require_contiguous_seats])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(30), [sort_date])),'DBNULL_DATETIME') + ISNULL(RTRIM(CONVERT(varchar(10), [system_type])),'DBNULL_INT') 
+ /*ISNULL(RTRIM( [tags]),'DBNULL_TEXT') +*/ ISNULL(RTRIM(CONVERT(varchar(10), [timer_profile_id])),'DBNULL_INT') + ISNULL(RTRIM( [type]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(10), [use_user_ssc])),'DBNULL_INT') + ISNULL(RTRIM(CONVERT(varchar(50), [version])),'DBNULL_NUMBER')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXoffers

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXoffers AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND (myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey OR myTarget.[image] <> mySource.[image] OR myTarget.tags <> mySource.tags)

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[lookup] = mySource.[lookup]
     ,myTarget.[name] = mySource.[name]
     ,myTarget.[description] = mySource.[description]
     ,myTarget.[type] = mySource.[type]
     ,myTarget.[display_date] = mySource.[display_date]
     ,myTarget.[sort_date] = mySource.[sort_date]
     ,myTarget.[promotion_code] = mySource.[promotion_code]
     ,myTarget.[on_sale_date] = mySource.[on_sale_date]
     ,myTarget.[off_sale_date] = mySource.[off_sale_date]
     ,myTarget.[ae_user_id] = mySource.[ae_user_id]
     ,myTarget.[ae_role_id] = mySource.[ae_role_id]
     ,myTarget.[use_user_ssc] = mySource.[use_user_ssc]
     ,myTarget.[min_qty] = mySource.[min_qty]
     ,myTarget.[max_qty] = mySource.[max_qty]
     ,myTarget.[customer_list_id] = mySource.[customer_list_id]
     ,myTarget.[pref_fee_target] = mySource.[pref_fee_target]
     ,myTarget.[published] = mySource.[published]
     ,myTarget.[list_online] = mySource.[list_online]
     ,myTarget.[is_draft] = mySource.[is_draft]
     ,myTarget.[image] = mySource.[image]
     ,myTarget.[client_id] = mySource.[client_id]
     ,myTarget.[allow_public_seat_change] = mySource.[allow_public_seat_change]
     ,myTarget.[require_contiguous_seats] = mySource.[require_contiguous_seats]
     ,myTarget.[allow_empty_single_seats] = mySource.[allow_empty_single_seats]
     ,myTarget.[additional_info1] = mySource.[additional_info1]
     ,myTarget.[additional_info2] = mySource.[additional_info2]
     ,myTarget.[customer_restriction_count] = mySource.[customer_restriction_count]
     ,myTarget.[has_account_restriction] = mySource.[has_account_restriction]
     ,myTarget.[has_pass_code_restriction] = mySource.[has_pass_code_restriction]
     ,myTarget.[has_sign_in_restriction] = mySource.[has_sign_in_restriction]
     ,myTarget.[system_type] = mySource.[system_type]
     ,myTarget.[timer_profile_id] = mySource.[timer_profile_id]
     ,myTarget.[default_restrict_transfer] = mySource.[default_restrict_transfer]
     ,myTarget.[default_restrict_resale] = mySource.[default_restrict_resale]
     ,myTarget.[default_waive_first_seller_fee] = mySource.[default_waive_first_seller_fee]
     ,myTarget.[osearch] = mySource.[osearch]
     ,myTarget.[fs_redirect] = mySource.[fs_redirect]
     ,myTarget.[offerlabel] = mySource.[offerlabel]
     ,myTarget.[version] = mySource.[version]
     ,myTarget.[tags] = mySource.[tags]
     ,myTarget.[offer_image_id] = mySource.[offer_image_id]
     ,myTarget.[mobile_image_id] = mySource.[mobile_image_id]
     ,myTarget.[allow_additional_donation_ots] = mySource.[allow_additional_donation_ots]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[id]
     ,[lookup]
     ,[name]
     ,[description]
     ,[type]
     ,[display_date]
     ,[sort_date]
     ,[promotion_code]
     ,[on_sale_date]
     ,[off_sale_date]
     ,[ae_user_id]
     ,[ae_role_id]
     ,[use_user_ssc]
     ,[min_qty]
     ,[max_qty]
     ,[customer_list_id]
     ,[pref_fee_target]
     ,[published]
     ,[list_online]
     ,[is_draft]
     ,[image]
     ,[client_id]
     ,[allow_public_seat_change]
     ,[require_contiguous_seats]
     ,[allow_empty_single_seats]
     ,[additional_info1]
     ,[additional_info2]
     ,[customer_restriction_count]
     ,[has_account_restriction]
     ,[has_pass_code_restriction]
     ,[has_sign_in_restriction]
     ,[system_type]
     ,[timer_profile_id]
     ,[default_restrict_transfer]
     ,[default_restrict_resale]
     ,[default_waive_first_seller_fee]
     ,[osearch]
     ,[fs_redirect]
     ,[offerlabel]
     ,[version]
     ,[tags]
     ,[offer_image_id]
     ,[mobile_image_id]
     ,[allow_additional_donation_ots]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[id]
     ,mySource.[lookup]
     ,mySource.[name]
     ,mySource.[description]
     ,mySource.[type]
     ,mySource.[display_date]
     ,mySource.[sort_date]
     ,mySource.[promotion_code]
     ,mySource.[on_sale_date]
     ,mySource.[off_sale_date]
     ,mySource.[ae_user_id]
     ,mySource.[ae_role_id]
     ,mySource.[use_user_ssc]
     ,mySource.[min_qty]
     ,mySource.[max_qty]
     ,mySource.[customer_list_id]
     ,mySource.[pref_fee_target]
     ,mySource.[published]
     ,mySource.[list_online]
     ,mySource.[is_draft]
     ,mySource.[image]
     ,mySource.[client_id]
     ,mySource.[allow_public_seat_change]
     ,mySource.[require_contiguous_seats]
     ,mySource.[allow_empty_single_seats]
     ,mySource.[additional_info1]
     ,mySource.[additional_info2]
     ,mySource.[customer_restriction_count]
     ,mySource.[has_account_restriction]
     ,mySource.[has_pass_code_restriction]
     ,mySource.[has_sign_in_restriction]
     ,mySource.[system_type]
     ,mySource.[timer_profile_id]
     ,mySource.[default_restrict_transfer]
     ,mySource.[default_restrict_resale]
     ,mySource.[default_waive_first_seller_fee]
     ,mySource.[osearch]
     ,mySource.[fs_redirect]
     ,mySource.[offerlabel]
     ,mySource.[version]
     ,mySource.[tags]
     ,mySource.[offer_image_id]
     ,mySource.[mobile_image_id]
     ,mySource.[allow_additional_donation_ots]
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
