SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[LoadDimCustomer_CreateTempTables] 
(
	@ClientDB VARCHAR(50),
	@LoadView VARCHAR(100),
	@LoadGuid VARCHAR(50),
	@LogLevel INT,
	@IsDataUploaderSource varchar(10)
)
AS
BEGIN


/*[etl].[LoadDimCustomer] 
* created: 7/2/2015 - Kwyss - dynamic sql procedure to load data to dimcustomer.   Pass in client db name and view to load from.
* Log Levels - 0 = none; 1 = record; 2 = detail
*
*/
/*
DECLARE @LoadView VARCHAR(100)
DECLARE @ClientDB VARCHAR(50)
Declare @IsDataUploaderSource bit = 0


SET @LoadView  = 'ods.vw_SEL_LoadDimCustomer'
SET @clientdb = 'nascarprod'

DECLARE @LoadGuid VARCHAR(50) = REPLACE(NEWID(), '-', '');

*/

	-- Remove square brackets
	SELECT @ClientDB = REPLACE(REPLACE(@ClientDB,'[',''),']','')
	SELECT @LoadView = REPLACE(REPLACE(@LoadView,'[',''),']','')

	-- Remove database name from @LoadView
	SELECT @LoadView = CASE WHEN LEFT(@LoadView,LEN(@ClientDB + '.')) = @ClientDB + '.' THEN REPLACE(@LoadView, @ClientDB + '.', '') ELSE @LoadView END	

	IF (SELECT @@VERSION) LIKE '%Azure%'
	BEGIN
	SET @ClientDB = ''
	END

	IF (SELECT @@VERSION) NOT LIKE '%Azure%'
	BEGIN
	SET @ClientDB = @ClientDB + '.'
	END

	DECLARE 
		@sql NVARCHAR(MAX) = '  '

	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql
	SET @sql = ''

	-- Create client-side temp table for records loaded via Data Uploader that have not yet been processed
	---- rank data to remove any potential duplicates, which would result in failure
	SELECT @sql = @sql 
	+' SELECT a.*' + CHAR(13)
	+ ', a.NameIsCleanStatus AS CompanyNameIsCleanStatus' + CHAR(13) /***** Special case. CompanyName is part of the NameDirtyHash so we are defaulting to the NameIsCleanStatus as opposed to requiring it as an additional field from the source load. *****/
	+ ', ROW_NUMBER() OVER (PARTITION BY SSID, SourceSystem ORDER BY ' + CASE WHEN @IsDataUploaderSource = 1 THEN 'RecordCreateDate' ELSE 'createdDate' END + ' DESC) as RecordRank' + CHAR(13)
	+' INTO ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + CHAR(13)
	+' FROM ' + @ClientDB + @LoadView  + ' a ' + CHAR(13)
	--+' INNER JOIN ' + @ClientDB + 'dbo.dimcustomer b ' + CHAR(13)
	--+' ON a.ssid = b.SSID ' + CHAR(13)
	--+' AND a.sourcesystem = b.SourceSystem; ' + CHAR(13)
	---+' AND a.sourcedb = b.sourcedb; ' + CHAR(13)
 	+' WHERE 1=1' + CHAR(13)
	+' AND ISNULL(a.SSID,'''') != ''''' + CHAR(13)
	+' AND ISNULL(a.SourceSystem,'''') != ''''' + CHAR(13)

	IF @IsDataUploaderSource = '1'
	BEGIN
		SET @sql = @sql +' AND a.Processed = 0' + CHAR(13) + CHAR(13)
		
		---- Set DirtyHashes
		SET @sql = @sql 
			+ 'UPDATE ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + CHAR(13)
			+ 'SET' + CHAR(13)

			---- NameDirtyHash
			+ 'NameDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(Prefix),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(FirstName),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(MiddleName),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(LastName),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(Suffix),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(FullName),''DBNULL_TEXT''))' + CHAR(13)

			---- ContactDirtyHash
			+ ',ContactDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(Prefix),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(FirstName),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(MiddleName),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(LastName),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(Suffix),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(CompanyName),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimaryStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressPrimaryCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimaryState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressPrimaryZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressPrimaryCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimaryCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimarySuite),''DBNULL_TEXT''))' + CHAR(13)

			---- AddressPrimaryDirtyHash
			+ ',AddressPrimaryDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(AddressPrimaryStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressPrimaryCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimaryState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressPrimaryZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressPrimaryCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimaryCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressPrimarySuite),''DBNULL_TEXT''))' + CHAR(13)

			---- AddressOneDirtyHash
			+ ',AddressOneDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(AddressOneStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressOneCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressOneState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressOneZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressOneCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressOneCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressOneSuite),''DBNULL_TEXT''))' + CHAR(13)

			---- AddressTwoDirtyHash
			+ ',AddressTwoDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(AddressTwoStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressTwoCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressTwoState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressTwoZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressTwoCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressTwoCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressTwoSuite),''DBNULL_TEXT''))' + CHAR(13)

			---- AddressThreeDirtyHash
			+ ',AddressThreeDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(AddressThreeStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressThreeCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressThreeState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressThreeZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressThreeCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressThreeCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressThreeSuite),''DBNULL_TEXT''))' + CHAR(13)

			---- AddressFourDirtyHash
			+ ',AddressFourDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(AddressFourStreet),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressFourCity),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressFourState),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AddressFourZip),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AddressFourCounty),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressFourCountry),''DBNULL_TEXT'')' + CHAR(13)
			+ '+ ISNULL(RTRIM(AddressFourSuite),''DBNULL_TEXT''))' + CHAR(13)

			---- PhonePrimaryDirtyHash
			+ ',PhonePrimaryDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(PhonePrimary),''DBNULL_TEXT''))' + CHAR(13) 

			---- PhoneHomeDirtyHash
			+ ',PhoneHomeDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(PhoneHome),''DBNULL_TEXT''))' + CHAR(13) 

			---- PhoneCellDirtyHash
			+ ',PhoneCellDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(PhoneCell),''DBNULL_TEXT''))' + CHAR(13) 

			---- PhoneBusinessDirtyHash
			+ ',PhoneBusinessDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(PhoneBusiness),''DBNULL_TEXT''))' + CHAR(13) 

			---- PhoneFaxDirtyHash
			+ ',PhoneFaxDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(PhoneFax),''DBNULL_TEXT''))' + CHAR(13) 

			---- PhoneOtherDirtyHash
			+ ',PhoneOtherDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(PhoneOther),''DBNULL_TEXT''))' + CHAR(13) 

			---- EmailPrimaryDirtyHash
			+ ',EmailPrimaryDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(EmailPrimary),''DBNULL_TEXT''))' + CHAR(13) 

			---- EmailOneDirtyHash
			+ ',EmailOneDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(EmailOne),''DBNULL_TEXT''))' + CHAR(13) 

			---- EmailTwoDirtyHash
			+ ',EmailTwoDirtyHash = HASHBYTES(''sha2_256'',	ISNULL(RTRIM(EmailTwo),''DBNULL_TEXT''))' + CHAR(13) 

			---- contactattrDirtyHash
			+ ',contactattrDirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(customerType),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(CustomerStatus),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(AccountType),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AccountRep),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(CompanyName),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(SalutationName),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(DonorMailName),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(DonorFormalName),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(Birthday),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(Gender),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(AccountId),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(MergedRecordFlag),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(MergedIntoSSID),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(IsBusiness),''DBNULL_TEXT''))' + CHAR(13) 

			---- extattr1_10DirtyHash
			+ ',extattr1_10DirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(ExtAttribute1),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute2),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute3),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute4),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute5),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute6),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute7),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute8),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute9),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute10),''DBNULL_TEXT''))' + CHAR(13) 
			
			---- extattr11_20DirtyHash
			+ ',extattr11_20DirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(ExtAttribute11),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute12),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute13),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute14),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute15),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute16),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute17),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute18),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute19),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute20),''DBNULL_TEXT''))' + CHAR(13) 
			
			---- extattr21_30DirtyHash
			+ ',extattr21_30DirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(ExtAttribute21),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute22),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute23),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute24),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute25),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute26),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute27),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute28),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute29),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute30),''DBNULL_TEXT''))' + CHAR(13) 
	
			---- extattr31_35DirtyHash
			+ ',extattr31_35DirtyHash = HASHBYTES(''sha2_256'', ISNULL(RTRIM(ExtAttribute31),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute32),''DBNULL_TEXT'')' + CHAR(13) 
			+ '+ ISNULL(RTRIM(ExtAttribute33),''DBNULL_TEXT'')' + CHAR(13)   
			+ '+ ISNULL(RTRIM(ExtAttribute34),''DBNULL_TEXT'')' + CHAR(13)  
			+ '+ ISNULL(RTRIM(ExtAttribute35),''DBNULL_TEXT''))' + CHAR(13) 
	END

	-- Set IsCleanStatusFields and IsDeleted
	SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + CHAR(13)
	+ 'SET' + CHAR(13)

	+ 'NameIsCleanStatus = ''Dirty''' + CHAR(13)

	+ ',CompanyNameIsCleanStatus = ''Dirty''' + CHAR(13)
			
	+ ',AddressPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',AddressOneIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',AddressTwoIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',AddressThreeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',AddressFourIsCleanStatus = ''Dirty''' + CHAR(13)
			
	+ ',EmailPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',EmailOneIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',EmailTwoIsCleanStatus = ''Dirty''' + CHAR(13)

	+ ',PhonePrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',PhoneHomeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',PhoneCellIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',PhoneBusinessIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',PhoneFaxIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',PhoneOtherIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ',IsDeleted = CASE WHEN IsDeleted IS NULL THEN 0 ELSE IsDeleted END' + CHAR(13)

	SET @sql = @sql + + CHAR(13) + CHAR(13) + 'PRINT ''Data loaded to ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + '''' + CHAR(13) + CHAR(13)	

	set @sql = @sql 
	+ 'create index ix_load_' + @LoadGuid + '_ss on ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + '(sourcesystem, ssid);'+ CHAR(13)

	SET @sql = @sql
		+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
		+ 'values (current_timestamp, ''Load DimCustomer'', ''Get Record Count'', (SELECT COUNT(0) FROM ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + ' a) );'
	SET @sql = @sql + CHAR(13) + CHAR(13)

	SET @sql = @sql
		+ ' SELECT DISTINCT b.*' + CHAR(13)
		+ ' INTO ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + CHAR(13)
		+ ' FROM ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + ' a' + CHAR(13)
		+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)
		+ '		AND a.SourceSystem = b.SourceSystem' + CHAR(13) + CHAR(13)

		+ ' PRINT ''Pre-change dbo.DimCustomer data loaded to ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + '''' + CHAR(13) + CHAR(13)	

		+ ' SELECT TOP 1 DimCustomerId, SSID, SourceSystem, CAST(NULL AS DATETIME) AS ChangedOn' + CHAR(13)
		+ ' INTO ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + CHAR(13)
		+ ' FROM ' + @ClientDB + 'etl.tmp_dimcustomer_' + @LoadGuid + CHAR(13)

		+ ' TRUNCATE TABLE ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + CHAR(13) + CHAR(13)

		+ ' PRINT ''Created ' + @ClientDB + 'etl.tmp_changes_' + @LoadGuid + '''' + CHAR(13) + CHAR(13)


	--SET @sql = @sql 
	--+' Alter table ' + @ClientDB + 'etl.tmp_load_' + @LoadGuid + ' Add constraint pk_dimcust_' + @LoadGuid + ' Primary Key Clustered (dimcustomerid); '+ CHAR(13)

 	-- Add TRY/CATCH block to force stoppage and log error      
	SET @sql = ''     
		+ ' BEGIN TRY' + CHAR(13)      
			+ @sql  
		+ ' END TRY' + CHAR(13)     
		+ ' BEGIN CATCH' + CHAR(13)     
		+ '		DECLARE @ErrorMessage NVARCHAR(92)' + CHAR(13)     
		+ '			, @ErrorSeverity INT' + CHAR(13)     
		+ '			, @ErrorState INT' + CHAR(13) + CHAR(13)     
     
		+ '		SELECT @ErrorMessage = LEFT(ERROR_MESSAGE(), 92)' + CHAR(13)      
		+ '			, @ErrorSeverity = ERROR_SEVERITY()' + CHAR(13)      
		+ '			, @ErrorState = ERROR_STATE()' + CHAR(13) + CHAR(13)     
     
		+ '		INSERT INTO ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
		+ '		VALUES (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)     
     
		+ '		RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)     
		+ '             @ErrorSeverity, -- Severity.' + CHAR(13)     
		+ '             @ErrorState -- State.' + CHAR(13)     
		+ '             );' + CHAR(13)     
		+ ' END CATCH' + CHAR(13) + CHAR(13) 

----	select @sql
	EXEC sp_executesql @sql;

	SET @sql = ''
		+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
		+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

	EXEC sp_executesql @sql

END
GO
