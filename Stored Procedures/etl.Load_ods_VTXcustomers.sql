SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[Load_ods_VTXcustomers]
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
Date:     08/19/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(NVARCHAR, COUNT(*)) FROM src.VTXcustomers),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ETL_ID, ETL_CreatedDate, ETL_SourceFileName, id, accountnumber, lastname, firstname, middle, phone1, phone2, address1, address2, city, state, zip, email, initdate, lastupdate, companyname, birthday, fullname, prefix, suffix, phone3, phone1type, phone2type, phone3type, salutation, search, careof, stateid, sentwelcomemessage, optedin, addressid, fax, isfemale, country, usersearch, legacyid, convertfsunpaiddefault
, HASHBYTES('sha2_256', ISNULL(RTRIM( [accountnumber]),'DBNULL_TEXT') + ISNULL(RTRIM( [address1]),'DBNULL_TEXT') + ISNULL(RTRIM( [address2]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [addressid])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [birthday])),'DBNULL_DATETIME') + ISNULL(RTRIM( [careof]),'DBNULL_TEXT') + ISNULL(RTRIM( [city]),'DBNULL_TEXT') + ISNULL(RTRIM( [companyname]),'DBNULL_TEXT') + ISNULL(RTRIM( [convertfsunpaiddefault]),'DBNULL_TEXT') + ISNULL(RTRIM( [country]),'DBNULL_TEXT') + ISNULL(RTRIM( [email]),'DBNULL_TEXT') + ISNULL(RTRIM( [fax]),'DBNULL_TEXT') + ISNULL(RTRIM( [firstname]),'DBNULL_TEXT') + ISNULL(RTRIM( [fullname]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [id])),'DBNULL_NUMBER') + ISNULL(RTRIM(CONVERT(varchar(25), [initdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [isfemale]),'DBNULL_TEXT') + ISNULL(RTRIM( [lastname]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [lastupdate])),'DBNULL_DATETIME') + ISNULL(RTRIM( [legacyid]),'DBNULL_TEXT') + ISNULL(RTRIM( [middle]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [optedin])),'DBNULL_NUMBER') + ISNULL(RTRIM( [phone1]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [phone1type])),'DBNULL_NUMBER') + ISNULL(RTRIM( [phone2]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [phone2type])),'DBNULL_NUMBER') + ISNULL(RTRIM( [phone3]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [phone3type])),'DBNULL_NUMBER') + ISNULL(RTRIM( [prefix]),'DBNULL_TEXT') + ISNULL(RTRIM( [salutation]),'DBNULL_TEXT') + ISNULL(RTRIM( [search]),'DBNULL_TEXT') + ISNULL(RTRIM(CONVERT(varchar(25), [sentwelcomemessage])),'DBNULL_NUMBER') + ISNULL(RTRIM( [state]),'DBNULL_TEXT') + ISNULL(RTRIM( [stateid]),'DBNULL_TEXT') + ISNULL(RTRIM( [suffix]),'DBNULL_TEXT') + ISNULL(RTRIM( [usersearch]),'DBNULL_TEXT') + ISNULL(RTRIM( [zip]),'DBNULL_TEXT')) ETL_DeltaHashKey
INTO #SrcData
FROM src.VTXcustomers

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

	IF @SrcRowCount > 10000
	BEGIN
		CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (id)

		EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId
	END

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE ods.VTXcustomers AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.id = mySource.id 

WHEN MATCHED AND myTarget.ETL_DeltaHashKey <> mySource.ETL_DeltaHashKey

THEN UPDATE SET
      myTarget.[ETL_UpdatedDate] = mySource.[ETL_CreatedDate]
     ,myTarget.[ETL_DeltaHashKey] = mySource.[ETL_DeltaHashKey]
     ,myTarget.[id] = mySource.[id]
     ,myTarget.[accountnumber] = mySource.[accountnumber]
     ,myTarget.[lastname] = mySource.[lastname]
     ,myTarget.[firstname] = mySource.[firstname]
     ,myTarget.[middle] = mySource.[middle]
     ,myTarget.[phone1] = mySource.[phone1]
     ,myTarget.[phone2] = mySource.[phone2]
     ,myTarget.[address1] = mySource.[address1]
     ,myTarget.[address2] = mySource.[address2]
     ,myTarget.[city] = mySource.[city]
     ,myTarget.[state] = mySource.[state]
     ,myTarget.[zip] = mySource.[zip]
     ,myTarget.[email] = mySource.[email]
     ,myTarget.[initdate] = mySource.[initdate]
     ,myTarget.[lastupdate] = mySource.[lastupdate]
     ,myTarget.[companyname] = mySource.[companyname]
     ,myTarget.[birthday] = mySource.[birthday]
     ,myTarget.[fullname] = mySource.[fullname]
     ,myTarget.[prefix] = mySource.[prefix]
     ,myTarget.[suffix] = mySource.[suffix]
     ,myTarget.[phone3] = mySource.[phone3]
     ,myTarget.[phone1type] = mySource.[phone1type]
     ,myTarget.[phone2type] = mySource.[phone2type]
     ,myTarget.[phone3type] = mySource.[phone3type]
     ,myTarget.[salutation] = mySource.[salutation]
     ,myTarget.[search] = mySource.[search]
     ,myTarget.[careof] = mySource.[careof]
     ,myTarget.[stateid] = mySource.[stateid]
     ,myTarget.[sentwelcomemessage] = mySource.[sentwelcomemessage]
     ,myTarget.[optedin] = mySource.[optedin]
     ,myTarget.[addressid] = mySource.[addressid]
     ,myTarget.[fax] = mySource.[fax]
     ,myTarget.[isfemale] = mySource.[isfemale]
     ,myTarget.[country] = mySource.[country]
     ,myTarget.[usersearch] = mySource.[usersearch]
     ,myTarget.[legacyid] = mySource.[legacyid]
     ,myTarget.[convertfsunpaiddefault] = mySource.[convertfsunpaiddefault]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ETL_CreatedDate]
	 ,[ETL_UpdatedDate]
	 ,[ETL_IsDeleted]
     ,[ETL_DeltaHashKey]
     ,[id]
     ,[accountnumber]
     ,[lastname]
     ,[firstname]
     ,[middle]
     ,[phone1]
     ,[phone2]
     ,[address1]
     ,[address2]
     ,[city]
     ,[state]
     ,[zip]
     ,[email]
     ,[initdate]
     ,[lastupdate]
     ,[companyname]
     ,[birthday]
     ,[fullname]
     ,[prefix]
     ,[suffix]
     ,[phone3]
     ,[phone1type]
     ,[phone2type]
     ,[phone3type]
     ,[salutation]
     ,[search]
     ,[careof]
     ,[stateid]
     ,[sentwelcomemessage]
     ,[optedin]
     ,[addressid]
     ,[fax]
     ,[isfemale]
     ,[country]
     ,[usersearch]
     ,[legacyid]
     ,[convertfsunpaiddefault]
     )
VALUES
     (mySource.[ETL_CreatedDate]
	 ,mySource.[ETL_CreatedDate]
	 ,0
     ,mySource.[ETL_DeltaHashKey]
     ,mySource.[id]
     ,mySource.[accountnumber]
     ,mySource.[lastname]
     ,mySource.[firstname]
     ,mySource.[middle]
     ,mySource.[phone1]
     ,mySource.[phone2]
     ,mySource.[address1]
     ,mySource.[address2]
     ,mySource.[city]
     ,mySource.[state]
     ,mySource.[zip]
     ,mySource.[email]
     ,mySource.[initdate]
     ,mySource.[lastupdate]
     ,mySource.[companyname]
     ,mySource.[birthday]
     ,mySource.[fullname]
     ,mySource.[prefix]
     ,mySource.[suffix]
     ,mySource.[phone3]
     ,mySource.[phone1type]
     ,mySource.[phone2type]
     ,mySource.[phone3type]
     ,mySource.[salutation]
     ,mySource.[search]
     ,mySource.[careof]
     ,mySource.[stateid]
     ,mySource.[sentwelcomemessage]
     ,mySource.[optedin]
     ,mySource.[addressid]
     ,mySource.[fax]
     ,mySource.[isfemale]
     ,mySource.[country]
     ,mySource.[usersearch]
     ,mySource.[legacyid]
     ,mySource.[convertfsunpaiddefault]
     )
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId

UPDATE ods.VTXcustomers
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXcustomers o
LEFT JOIN src.VTXcustomers_UK s ON s.id = o.id
WHERE s.id IS NULL

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
