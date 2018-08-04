SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
   
CREATE PROCEDURE [etl].[UpdateDimCustomerFromCDIOOutput]    
(   
	@ClientDB VARCHAR(50)   
)   
AS    
BEGIN   
   
   
 -------------------------------------------------------------------------------

-- Author name:  Kristine Wyss

-- Created date: Long, long ago

-- Purpose: applies updates from CDIO

-- Copyright © 2018, SSB, All Rights Reserved

-------------------------------------------------------------------------------

-- Modification History --

-- modified:  12/11/2014 - Kwyss -- Moved the update of primary email and phone to the main contact record - related to changes to CleanDataWrite.     
-- modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL     
-- modified:  11/30/2015 - GHolder -- Added code to retrieve/update Plus4, Latitude, and Longitude     
-- modified:  12/02/2016 - GHolder -- Added support for Master/Source functionality by including code to load clean data output to CD_DimCustomer and update IsCleanStatus fields in Source_DimCustomer     

-- modified: 06/07/2018 - kwyss - company name update was triggering matchkey updatedate which caused all the records to go through MDM.  Moved to seperate update so only records that need to be updated are.

-- Peer reviewed by:  Ginger Holder

-- Peer review notes:

-- Peer review date: 6/7/2018

-- Deployed by:

-- Deployment date:

-- Deployment notes:

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------    
   
----DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV'   
   
IF (SELECT @@VERSION) LIKE '%Azure%'   
BEGIN   
SET @ClientDB = ''   
END   
ELSE   
BEGIN   
SET @ClientDB = @ClientDB + '.'   
END   
  
DECLARE    
	@sql NVARCHAR(MAX) = ' '    
   
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
   
SET @sql = @sql    
	+ 'BEGIN TRY' + CHAR(13)   
   
		+ '	INSERT INTO ' + @ClientDB + 'archive.[CleanDataOutput] (BatchId, ContactId, ContactStatusCode, ContactStatus, SourceContactId, Prefix, FirstName, MiddleName, LastName, Suffix, Gender, Salutation, Address, Address2, Suite, City, State, ZipCode, Plus4, AddressCounty, AddressCountry, AddressCountyFips, AddressType, AddressDeliveryPoint, ZipLatitude, ZipLongitude, AreaCode, Phone, PhoneExtension, EmailAddress, NameStatus, AddressStatus, PhoneStatus, EmailStatus, Input_Prefix, Input_FirstName, Input_MiddleName, Input_LastName, Input_Suffix, Input_FullName, Input_AddressType, Input_Address, Input_Address2, Input_City, Input_State, Input_ZipCode, Input_AddressCounty, Input_AddressCountry, Input_PhoneType, Input_Phone, Input_EmailType, Input_Email, Input_SourcePriorityRank, Input_SourceCreateDate, Input_Custom1, Input_Custom2, Input_Custom3, Input_Custom4, Input_Custom5, RunContactMatch, Input_SourceSystem, ncoaAddress, ncoaAddress2, ncoaSuite, ncoaCity, ncoaState, ncoaZipCode, ncoaPlus4, ncoaAddressCounty, ncoaAddressCountry, ncoaAddressCountyFips, ncoaAddressType, ncoaAddressDeliveryPoint, ncoaZipLatitude, ncoaZipLongitude, ncoaMoveEffectiveDate, ETL_CreatedDate, FuzzyNameId, RunNameMatch, RunNCOA, PhoneTypeCode, Input_CompanyName, CompanyName, CompanyNameStatus)' + CHAR(13)   
		+ '	SELECT BatchId, ContactId, ContactStatusCode, ContactStatus, SourceContactId, Prefix, FirstName, MiddleName, LastName, Suffix, Gender, Salutation, Address, Address2, Suite, City, State, ZipCode, Plus4, AddressCounty, AddressCountry, AddressCountyFips, AddressType, AddressDeliveryPoint, ZipLatitude, ZipLongitude, AreaCode, Phone, PhoneExtension, EmailAddress, NameStatus, AddressStatus, PhoneStatus, EmailStatus, Input_Prefix, Input_FirstName, Input_MiddleName, Input_LastName, Input_Suffix, Input_FullName, Input_AddressType, Input_Address, Input_Address2, Input_City, Input_State, Input_ZipCode, Input_AddressCounty, Input_AddressCountry, Input_PhoneType, Input_Phone, Input_EmailType, Input_Email, Input_SourcePriorityRank, Input_SourceCreateDate, Input_Custom1, Input_Custom2, Input_Custom3, Input_Custom4, Input_Custom5, RunContactMatch, Input_SourceSystem, ncoaAddress, ncoaAddress2, ncoaSuite, ncoaCity, ncoaState, ncoaZipCode, ncoaPlus4, ncoaAddressCounty, ncoaAddressCountry, ncoaAddressCountyFips, ncoaAddressType, ncoaAddressDeliveryPoint, ncoaZipLatitude, ncoaZipLongitude, ncoaMoveEffectiveDate, GETDATE() ETL_CreatedDate, FuzzyNameId, RunNameMatch, RunNCOA, PhoneTypeCode, Input_CompanyName, CompanyName, CompanyNameStatus' + CHAR(13)   
		+ '	FROM ' + @ClientDB + 'dbo.CleanDataOutput' + CHAR(13)   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Records Archived'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
+ 'END TRY' + CHAR(13)   
+ 'BEGIN CATCH' + CHAR(13)   
+ ' PRINT @@ERROR' + CHAR(13)   
+ 'END CATCH'   
SET @sql = @sql + CHAR(13) + CHAR(13)		 
 
  
SET @sql = @sql  
+ 'IF (SELECT COUNT(0) FROM ' + @clientdb + 'dbo.cleandataoutput) > 500000' + CHAR(13)   
	+ 'BEGIN' + CHAR(13)   
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''dbo.dimcustomer''' + CHAR(13)  
	+ ' IF exists (SELECT * FROM ' + @clientdb + 'sys.indexes WHERE name = ''ix_dimcustomer_ssid_sourcesystem'') '  + CHAR(13)  
		+ 'BEGIN' + CHAR(13)  
	+ 'ALTER INDEX ix_dimcustomer_ssid_sourcesystem ON ' + @clientdb + 'dbo.dimcustomer REBUILD;' + CHAR(13)  
		+ 'END' + CHAR(13) 
	+ 'ELSE'+ CHAR(13) 
		+ 'BEGIN' + CHAR(13)  
	+ 'CREATE NONCLUSTERED INDEX [ix_dimcustomer_ssid_sourcesystem] ON '+ @ClientDB + '[dbo].[DimCustomer] ([SourceSystem] ASC, [SSID] ASC) INCLUDE ( 	[DimCustomerId]); ' + CHAR(13) 
		+ 'END' + CHAR(13) 
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Disable Indexes'', ''0'');' + CHAR(13)    
	+ 'END' + CHAR(13)   
	SET @sql = @sql + CHAR(13) + CHAR(13)  											   
   
SET @sql = @sql    
	+ '--update the primary address including the CDIO customer key' + CHAR(13)   
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set[AddressPrimaryStreet] = cdio.address ' + CHAR(13)   
	+ '	,[AddressPrimarySuite]  = CASE WHEN isnull(cdio.Suite, '''') <> '''' THEN cdio.Suite ELSE LEFT(cdio.address2,25) END ' + CHAR(13)   
	+ '	,[AddressPrimaryCity]  = cdio.city' + CHAR(13)   
	+ '	,[AddressPrimaryState] = cdio.state' + CHAR(13)   
	+ '	,[AddressPrimaryZip] = CASE WHEN cdio.AddressStatus LIKE ''%Foreign Address%'' THEN cdio.Input_ZipCode else cdio.ZipCode END' + CHAR(13)   
	+ '	,[AddressPrimaryPlus4] = cdio.Plus4' + CHAR(13)   
	+ '	,[AddressPrimaryLatitude] = cdio.ZipLatitude' + CHAR(13)   
	+ '	,[AddressPrimaryLongitude] = cdio.ZipLongitude' + CHAR(13)   
	+ '	,[AddressPrimaryCounty] = cdio.addresscounty' + CHAR(13)   
	+ '	,[AddressPrimaryCountry] = cdio.addresscountry' + CHAR(13)   
	+ '	,[AddressPrimaryIsCleanStatus] = isnull(cast(AddressStatus as nvarchar(100)), ''notfound'')' + CHAR(13)   
	+ '	--,[AddressPrimaryMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	,[ContactGUID] = ContactId' + CHAR(13)   
	+ ' ,[FuzzyNameGUID] = case when isnull(FuzzyNameId,'''') = '''' then NULL else FuzzyNameId end' + CHAR(13) 
	+ '	,[Prefix]  = cdio.prefix ' + CHAR(13)   
	+ '	,[FirstName] = cdio.firstname' + CHAR(13)   
	+ '	,[MiddleName] = cdio.middlename' + CHAR(13)   
	+ '	,[LastName] = cdio.lastname' + CHAR(13)   
	+ '	,[Suffix] = cdio.suffix' + CHAR(13)   
	+ '	,CD_Gender = cdio.Gender' + CHAR(13)   
	+ '	,[NameIsCleanStatus] = isnull(cast(NameStatus as nvarchar(100)), ''notfound'')' + CHAR(13)   
---	+ ' ,CompanyName = cdio.CompanyName' + CHAR(13)
---	+ ' ,CompanyNameIsCleanStatus = isnull(cast(cdio.CompanyName as nvarchar(100)),''notfound'')' + CHAR(13)
	+ '	,[AddressPrimaryNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)   
	+ '	,[PhonePrimary] = cdio.phone' + CHAR(13)   
	+ '	,[PhonePrimaryIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	, [EmailPrimary] = cdio.emailaddress' + CHAR(13)   
	+ '	,[EmailPrimaryIsCleanStatus] = isnull(cdio.EmailStatus,''notfound'')' + CHAR(13)   
	+ '	---, [ExternalContactId] = case when isnull(ContactID, ''{00000000-0000-0000-0000-000000000000}'')  != ''{00000000-0000-0000-0000-000000000000}''  then ContactId else newID() end' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''contact'''   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Contact Records Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql      
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)     
	+ 'set' + CHAR(13)     
	+ '[CompanyName] = cdio.CompanyName' + CHAR(13)       
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)     
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)     
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)     
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)     
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)  
	+' and isnull(cdio.companyname, '''') != isnull(dimcust.companyname, '''')'   
	+ 'and Input_Custom2 in (''companyname'', ''contact'')'      
SET @sql = @sql + CHAR(13) + CHAR(13)   

SET @sql = @sql      
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Company Name Updated'', @@Rowcount);'     
SET @sql = @sql + CHAR(13) + CHAR(13)  

SET @sql = @sql      
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)     
	+ 'set' + CHAR(13)     
	+ '	[CompanyNameIsCleanStatus] = isnull(cdio.CompanyNameStatus, ''notfound'')  ' + CHAR(13)     
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)     
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)     
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)     
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)     
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)  
	+ 'and Input_Custom2 in (''companyname'', ''contact'')'      
SET @sql = @sql + CHAR(13) + CHAR(13)     
  
SET @sql = @sql      
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)     
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Company Name Status Updated'', @@Rowcount);'     
SET @sql = @sql + CHAR(13) + CHAR(13)     
  
   
SET @sql = @sql    
	+ '--update address one' + CHAR(13)   
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set [AddressOneStreet] = cdio.address ' + CHAR(13)   
	+ '	,[AddressOneSuite]  = CASE WHEN isnull(cdio.Suite, '''') <> '''' THEN cdio.Suite ELSE LEFT(cdio.address2,25) END ' + CHAR(13)   
	+ '	,[AddressOneCity] = cdio.city' + CHAR(13)   
	+ '	,[AddressOneState] = cdio.state' + CHAR(13)   
	+ '	,[AddressOneZip]  = CASE WHEN cdio.AddressStatus LIKE ''%Foreign Address%'' THEN cdio.Input_ZipCode else cdio.ZipCode END' + CHAR(13)   
	+ '	,[AddressOnePlus4] = cdio.Plus4' + CHAR(13)   
	+ '	,[AddressOneLatitude] = cdio.ZipLatitude' + CHAR(13)   
	+ '	,[AddressOneLongitude] = cdio.ZipLongitude' + CHAR(13)   
	+ '	,[AddressOneCounty] =  cdio.addresscounty' + CHAR(13)   
	+ '	,[AddressOneCountry]  = cdio.addresscountry' + CHAR(13)   
	+ '	,[AddressOneIsCleanStatus]  = isnull(AddressStatus, ''notfound'')' + CHAR(13)   
	+ '	--,[AddressOneMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	,[AddressOneStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''addressone'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Address One Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ '--update address two' + CHAR(13)   
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set[AddressTwoStreet] =  cdio.address ' + CHAR(13)   
	+ '	,[AddressTwoSuite]  = CASE WHEN isnull(cdio.Suite, '''') <> '''' THEN cdio.Suite ELSE LEFT(cdio.address2,25) END ' + CHAR(13)   
	+ '	,[AddressTwoCity] = cdio.city' + CHAR(13)   
	+ '	,[AddressTwoState] = cdio.state' + CHAR(13)   
	+ '	,[AddressTwoZip] = CASE WHEN cdio.AddressStatus LIKE ''%Foreign Address%'' THEN cdio.Input_ZipCode else cdio.ZipCode END' + CHAR(13)   
	+ '	,[AddressTwoPlus4] = cdio.Plus4' + CHAR(13)   
	+ '	,[AddressTwoLatitude] = cdio.ZipLatitude' + CHAR(13)   
	+ '	,[AddressTwoLongitude] = cdio.ZipLongitude' + CHAR(13)   
	+ '	,[AddressTwocounty] = cdio.addresscounty' + CHAR(13)   
	+ '	,[AddressTwoCountry] = cdio.AddressCountry' + CHAR(13)   
	+ '	,[AddressTwoIsCleanStatus] =isnull(AddressStatus, ''notfound'')' + CHAR(13)   
	+ '	--,[AddressTwoMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	,[AddressTwoStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem ' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''addresstwo'''   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Address Two Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ '--update address three' + CHAR(13)   
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '    [AddressThreeStreet] = cdio.address' + CHAR(13)   
	+ '	,[AddressThreeSuite]  = CASE WHEN isnull(cdio.Suite, '''') <> '''' THEN cdio.Suite ELSE LEFT(cdio.address2,25) END ' + CHAR(13)   
	+ '	,[AddressThreeCity] = cdio.city' + CHAR(13)   
	+ '	,[AddressThreeState] =cdio.state' + CHAR(13)   
	+ '	,[AddressThreeZip] = CASE WHEN cdio.AddressStatus LIKE ''%Foreign Address%'' THEN cdio.Input_ZipCode else cdio.ZipCode END' + CHAR(13)   
	+ '	,[AddressThreePlus4] = cdio.Plus4' + CHAR(13)   
	+ '	,[AddressThreeLatitude] = cdio.ZipLatitude' + CHAR(13)   
	+ '	,[AddressThreeLongitude] = cdio.ZipLongitude' + CHAR(13)   
	+ '	,[AddressThreeCounty] = cdio.addresscounty' + CHAR(13)   
	+ '	,[AddressThreeCountry]  = cdio.addresscountry' + CHAR(13)   
	+ '	,[AddressThreeIsCleanStatus] = isnull(AddressStatus, ''notfound'')' + CHAR(13)   
	+ '	--,[AddressThreeMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	,[AddressThreeStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem ' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''addressthree'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Address Three Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ '--update address four' + CHAR(13)   
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[AddressFourStreet] = cdio.address ' + CHAR(13)   
	+ '	,[AddressFourSuite]  = CASE WHEN isnull(cdio.Suite, '''') <> '''' THEN cdio.Suite ELSE LEFT(cdio.address2,25) END ' + CHAR(13)   
	+ '	,[AddressFourCity] = cdio.city' + CHAR(13)   
	+ '	,[AddressFourState] =cdio.state' + CHAR(13)   
	+ '	,[AddressFourZip] = CASE WHEN cdio.AddressStatus LIKE ''%Foreign Address%'' THEN cdio.Input_ZipCode else cdio.ZipCode END' + CHAR(13)   
	+ '	,[AddressFourPlus4] = cdio.Plus4' + CHAR(13)   
	+ '	,[AddressFourLatitude] = cdio.ZipLatitude' + CHAR(13)   
	+ '	,[AddressFourLongitude] = cdio.ZipLongitude' + CHAR(13)   
	+ '	,[AddressFourCounty] = cdio.addresscounty' + CHAR(13)   
	+ '	,[AddressFourCountry] = cdio.AddressCountry' + CHAR(13)   
	+ '	,[AddressFourIsCleanStatus] = isnull(AddressStatus, ''notfound'')' + CHAR(13)   
	+ '	--,[AddressFourMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	,[AddressFourStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''addressfour'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Address Four Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ '/*Standard Phone Entities*/' + CHAR(13)  

	+ ' IF OBJECT_ID(''tempdb..#dimCustomer'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #dimCustomer' + CHAR(13) + CHAR(13)

	+ ' ;WITH customer AS (' + CHAR(13)
	+ '		SELECT DISTINCT SourceContactId, Input_SourceSystem' + CHAR(13)
	+ '		FROM ' + @ClientDB + 'dbo.CleanDataOutput' + CHAR(13)
	+ '	)' + CHAR(13)	
	+ ' SELECT b.DimCustomerID, b.SSID, b.SourceSystem' + CHAR(13)
	+ ' INTO #dimCustomer'
	+ ' FROM customer a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b WITH (NOLOCK) ON a.SourceContactId = b.SSID' + CHAR(13)
	+ '		AND a.Input_SourceSystem = b.SourceSystem' + CHAR(13) + CHAR(13)

	+ ' CREATE CLUSTERED INDEX ix_dimcustomerid ON #dimCustomer (DimCustomerID)' + CHAR(13)
	+ ' CREATE NONCLUSTERED INDEX ix_ssid_sourcesystem ON #dimCustomer (SSID, SourceSystem)' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#cdoPhone'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #cdoPhone' + CHAR(13) + CHAR(13)

	+ ' SELECT DISTINCT b.DimCustomerID, a.SourceContactId, a.Input_SourceSystem, a.Phone, CASE WHEN ISNULL(a.PhoneTypeCode,'''') = '''' THEN NULL ELSE a.PhoneTypeCode END AS PhoneLineTypeCode, a.PhoneStatus, a.Input_PhoneType, a.Input_Custom2' + CHAR(13)
	+ ' 	, a.Input_Phone' + CHAR(13)
	+ ' 	, CAST(NULL AS BINARY(32)) AS PhoneCleanHash' + CHAR(13)
	+ ' 	, c.PhoneDirtyHash' + CHAR(13)
	+ ' 	, c.Source_DimPhoneID' + CHAR(13)
	+ ' 	, c.DimPhoneID' + CHAR(13)
	+ ' INTO #cdoPhone' + CHAR(13)
	+ ' FROM ' + @ClientDB + 'dbo.CleanDataOutput a WITH (NOLOCK)' + CHAR(13)
	+ ' INNER JOIN #dimCustomer b ON a.SourceContactId = b.SSID' + CHAR(13)
	+ '		AND a.Input_SourceSystem = b.SourceSystem' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.vw_DimCustomerPhone_prePivot c ON b.DimCustomerID = c.DimCustomerID' + CHAR(13)
	+ '		AND (a.Input_Custom2 = c.PhoneTypePivot OR a.Input_PhoneType = c.PhoneTypePivot)' + CHAR(13)
	+ ' WHERE ISNULL(a.Input_Phone,'''') != ''''' + CHAR(13) + CHAR(13)

	+ ' UPDATE #cdoPhone' + CHAR(13)
	+ ' SET PhoneCleanHash = CASE WHEN ISNULL(Phone,'''') != '''' THEN HASHBYTES(''SHA2_256'',ISNULL(RTRIM(Phone),''DBNULL_TEXT'')) ELSE PhoneDirtyHash END' + CHAR(13) + CHAR(13)

	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhonePrimary] = cdio.phone' + CHAR(13)   
	+ '	,[PhonePrimaryIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	--[PhonePrimaryMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and (Input_PhoneType = ''phoneprimary'' OR Input_Custom2 = ''phoneprimary'')'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Primary Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhoneHome] = cdio.phone' + CHAR(13)   
	+ '	,[PhoneHomeIsCleanStatus] =isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	--[PhoneHomeMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''phonehome'''   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Home Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhoneCell]= cdio.phone' + CHAR(13)   
	+ '	,[PhoneCellIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	--[PhoneCellMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''phonecell'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Cell Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhoneBusiness] = cdio.phone' + CHAR(13)   
	+ '	,[PhoneBusinessIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	--[PhoneBusinessMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''phonebusiness'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Business Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhoneFax] = cdio.phone' + CHAR(13)   
	+ '	,[PhoneFaxIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)   
	+ '	--[PhoneFaxMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''phonefax'''   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Fax Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[PhoneOther] = cdio.phone' + CHAR(13)   
	+ '	,[PhoneOtherIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')  ' + CHAR(13)   
	+ '	--[PhoneOtherMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoPhone cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''phoneother'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Phone Other Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   


	+ ' IF OBJECT_ID(''tempdb..#cdoEmail'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #cdoEmail' + CHAR(13) + CHAR(13)

	+ ' SELECT DISTINCT b.DimCustomerID, a.SourceContactId, a.Input_SourceSystem, a.EmailAddress,  a.EmailStatus, a.Input_EmailType, a.Input_Custom2' + CHAR(13)
	+ ' 	, a.Input_Email' + CHAR(13)
	+ ' 	, CAST(NULL AS BINARY(32)) AS EmailCleanHash' + CHAR(13)
	+ ' 	, c.EmailDirtyHash' + CHAR(13)
	+ ' 	, c.Source_DimEmailID' + CHAR(13)
	+ ' 	, c.DimEmailID' + CHAR(13)
	+ ' INTO #cdoEmail' + CHAR(13)
	+ ' FROM ' + @ClientDB + 'dbo.CleanDataOutput a WITH (NOLOCK)' + CHAR(13)
	+ ' INNER JOIN #dimCustomer b ON a.SourceContactId = b.SSID' + CHAR(13)
	+ '		AND a.Input_SourceSystem = b.SourceSystem' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'cust.vw_DimCustomerEmail_prePivot c ON b.DimCustomerID = c.DimCustomerID' + CHAR(13)
	+ '		AND (a.Input_Custom2 = c.EmailTypePivot OR a.Input_EmailType = c.EmailTypePivot)' + CHAR(13)
	+ ' WHERE ISNULL(a.Input_Email,'''') != ''''' + CHAR(13) + CHAR(13)

	+ ' UPDATE #cdoEmail' + CHAR(13)
	+ ' SET EmailCleanHash = CASE WHEN ISNULL(EmailAddress,'''') != '''' THEN HASHBYTES(''SHA2_256'',ISNULL(RTRIM(EmailAddress),''DBNULL_TEXT'')) ELSE EmailDirtyHash END' + CHAR(13) + CHAR(13)

   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[EmailPrimary] = cdio.emailaddress' + CHAR(13)   
	+ '	,[EmailPrimaryIsCleanStatus] =  isnull(cdio.EmailStatus,''notfound'')' + CHAR(13)   
	+ '	--[EmailPrimaryMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoEmail cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and (Input_EmailType = ''emailprimary'' OR Input_Custom2 = ''emailprimary'')'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Email One Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[EmailOne] = cdio.emailaddress' + CHAR(13)   
	+ '	,[EmailOneIsCleanStatus] =  isnull(cdio.EmailStatus,''notfound'')' + CHAR(13)   
	+ '	--[EmailOneMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoEmail cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''emailone'''    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Email One Updated'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'update ' + @ClientDB + 'dbo.DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '[EmailTwo] = cdio.emailaddress ' + CHAR(13)   
	+ '	,[EmailTwoIsCleanStatus] =  isnull(cdio.EmailStatus,''notfound'') ' + CHAR(13)   
	+ '	--[EmailTwoMasterId] [bigint] NULL,' + CHAR(13)   
	+ '	, [UpdatedBy] = ''CI''' + CHAR(13)   
	+ '	, [UpdatedDate] = current_timestamp' + CHAR(13)   
	+ 'from #cdoEmail cdio, ' + @ClientDB + 'dbo.DimCustomer dimcust' + CHAR(13)   
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)   
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)   
	+ 'and Input_Custom2 = ''emailtwo''' + CHAR(13) + CHAR(13)
	  
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Email Two Updated'', @@Rowcount);' + CHAR(13) + CHAR(13)

	
	---ZipCode
	+ ' IF OBJECT_ID(''tempdb..#tmp_zip'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #tmp_zip' + CHAR(13) + CHAR(13)

	+ ' SELECT DISTINCT ZipCode' + CHAR(13)
	+ ' INTO #tmp_zip' + CHAR(13)
	+ ' FROM ' + @ClientDB + 'dbo.CleanDataOutput' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND ISNULL(ZipCode,'''') != ''''' + CHAR(13)
	+ ' AND ISNULL(ZipLatitude,''0'') != ''0''' + CHAR(13) + CHAR(13)

	+ ' CREATE CLUSTERED INDEX ix_zip ON #tmp_zip (ZipCode)' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#zipCode'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #zipCode' + CHAR(13)

	+ ' SELECT b.ZipCode, b.CBSA_Name, b.MSA_Name, b.Latitude, b.Longitude' + CHAR(13)
	+ ' INTO #zipCode' + CHAR(13)
	+ ' FROM #tmp_zip a' + CHAR(13)
	+ ' INNER JOIN ' + CASE WHEN ISNULL(@ClientDB,'') = '' THEN '' ELSE 'CentralIntelligence.' END + 'dbo.zip_codes_database b ON a.ZipCode = b.ZipCode' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.PrimaryRecord = ''P''' + CHAR(13) + CHAR(13)

	+ ' CREATE CLUSTERED INDEX ix_zip ON #zipCode (ZipCode)' + CHAR(13) + CHAR(13)

	+ ' DELETE b' + CHAR(13)
	+ ' FROM #zipCode a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.ZipCode b ON a.ZipCode = b.ZipCode' + CHAR(13) + CHAR(13)

	+ ' INSERT INTO ' + @ClientDB + 'dbo.ZipCode' + CHAR(13)
	+ ' (' + CHAR(13)
	+ '     ZipCode,' + CHAR(13)
	+ '     CBSA_Name,' + CHAR(13)
	+ '     MSA_Name,' + CHAR(13)
	+ '     Latitude,' + CHAR(13)
	+ '     Longitude' + CHAR(13)
	+ ' )' + CHAR(13)
	+ ' SELECT ZipCode, CBSA_Name,MSA_Name, Latitude, Longitude' + CHAR(13)
	+ ' FROM #zipCode' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateZipCodeFromCDIOoutput'', ''Load ZipCode'', @@Rowcount);' + CHAR(13) + CHAR(13)

	
	----DimEmail
	
	+ ' IF OBJECT_ID(''tempdb..#email_ranked'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #email_ranked' + CHAR(13) + CHAR(13)
	
	+ ' ;WITH email AS (' + CHAR(13)
	+ '		SELECT *, ROW_NUMBER() OVER (PARTITION BY a.EmailCleanHash, a.EmailDirtyHash ORDER BY a.DimCustomerID DESC) ranking, ROW_NUMBER() OVER (PARTITION BY a.EmailDirtyHash ORDER BY a.DimCustomerID DESC) source_ranking' + CHAR(13)
	+ '		FROM #cdoEmail a' + CHAR(13)
	+ '		WHERE (a.Source_DimEmailID IS NULL OR a.DimEmailID IS NULL)' + CHAR(13)
	+ ' )' + CHAR(13)
	+ ' SELECT a.EmailAddress as email, a.EmailCleanHash, a.Input_Email, a.EmailDirtyHash,  a.EmailStatus, ranking, source_ranking' + CHAR(13)
	+ ' INTO #email_ranked' + CHAR(13)
	+ ' FROM email a' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#email_insert'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #email_insert' + CHAR(13) + CHAR(13)
	
	+ ' ;WITH email AS (' + CHAR(13)
	+ ' 	SELECT DISTINCT CASE WHEN ISNULL(a.Email,'''') != '''' THEN a.Email ELSE a.Input_Email END as Email, CASE WHEN ISNULL(a.Email,'''') != '''' THEN a.EmailCleanHash ELSE a.EmailDirtyHash END EmailCleanHash, a.EmailStatus' + CHAR(13)
	+ ' 	FROM #email_ranked a' + CHAR(13)
	+ ' 	WHERE a.ranking = 1' + CHAR(13)
	--+ '		AND ISNULL(a.Phone,'''') != ''''' + CHAR(13)
	+ ' )' + CHAR(13)
	+ ' SELECT a.Email, a.EmailCleanHash, es.DimEmailStatusID ' + CHAR(13)
	+ ' INTO #email_insert' + CHAR(13)
	+ ' FROM email a' + CHAR(13)
	+ ' Inner Join ' + @ClientDB + 'email.DimEmailStatus es  on a.EmailStatus = es.EmailStatus ' + Char(13)
	+ ' LEFT JOIN ' + @ClientDB + 'email.DimEmail b ON a.EmailCleanHash = b.EmailCleanHash' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimEmailID IS NULL' + CHAR(13) + CHAR(13)
	
	+ ' IF OBJECT_ID(''tempdb..#email_update'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #email_update' + CHAR(13) + CHAR(13)

	+ ' SELECT b.DimEmailID, es.DimEmailStatusID' + CHAR(13)
	+ ' INTO #email_update' + CHAR(13)
	+ ' FROM #email_ranked a' + CHAR(13)
	+ ' Inner Join ' + @ClientDB + 'email.DimEmailStatus es  on a.EmailStatus = es.EmailStatus ' + Char(13)
	+ ' INNER JOIN ' + @ClientDB + 'email.DimEmail b ON a.EmailCleanHash = b.EmailCleanHash' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND a.ranking = 1' + CHAR(13)

	+ ' IF ((SELECT COUNT(0) FROM #email_insert) + (SELECT COUNT(0) FROM #email_update)) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimEmailFromCDIOoutput'', ''DimEmail - Disable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
	+ ' 	                                 @TableName = ''email.DimEmail'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.DimEmailStatusID = a.DimEmailStatusID' + CHAR(13)
	+ ' 	,b.UpdatedDate = GETDATE()' + CHAR(13)
	+ ' FROM #email_update a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'email.DimEmail b ON a.DimemailID = b.DimemailID' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimEmailFromCDIOoutput'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13)

	+ ' INSERT INTO ' + @ClientDB + 'email.DimEmail (email, emailCleanHash, DimEmailStatusID)' + CHAR(13)
	+ ' SELECT email, emailCleanHash, DimEmailStatusID' + CHAR(13)
	+ ' FROM #email_insert' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimEmailFromCDIOoutput'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13)

	+ ' IF ((SELECT COUNT(0) FROM #email_insert) + (SELECT COUNT(0) FROM #email_update)) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimEmailFromCDIOoutput'', ''Dimemail - Enable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
	+ ' 	                                 @TableName = ''email.DimEmail'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	----Source_DimEmail
	+ ' IF OBJECT_ID(''tempdb..#source_email_insert'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #source_email_insert' + CHAR(13) + CHAR(13)

	+ ' UPDATE a' + CHAR(13)
	+ ' SET a.Source_DimEmailID = b.Source_DimEmailID' + CHAR(13)
	+ ' FROM #cdoEmail a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'email.Source_DimEmail b ON a.EmailDirtyHash = b.EmailDirtyHash' + CHAR(13) + CHAR(13)

	+ ' UPDATE a' + CHAR(13)
	+ ' SET a.DimEmailID = b.DimEmailID' + CHAR(13)
	+ ' FROM #cdoEmail a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'email.DimEmail b ON a.EmailCleanHash = b.EmailCleanHash' + CHAR(13) + CHAR(13)


	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.DimEmailID = a.DimEmailID' + CHAR(13)
	+ ' FROM #cdoEmail a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'email.Source_DimEmail b ON a.Source_DimEmailID = b.Source_DimEmailID' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimEmailID IS NULL' + CHAR(13) + CHAR(13)

	+ ' SELECT b.DimCustomerEmailID, a.DimEmailID' + CHAR(13)
	+ ' INTO #dce_update' + CHAR(13)
	+ ' FROM #cdoEmail a' + CHAR(13)
	+ ' Inner Join ' + @ClientDB + 'email.dimEmailType et on (a.Input_EmailType = et.EmailType OR a.Input_Custom2 = et.EmailType)' + Char(13)
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)
	+ '		AND et.DimEmailTypeID = b.dimEmailTypeID' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimEmailID IS NULL' + CHAR(13) + CHAR(13)
	
	----DimCustomerEmail
	+ ' IF (SELECT COUNT(0) FROM #dce_update) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerEmailFromCDIOoutput'', ''DimCustomerEmail - Disable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
	+ ' 	                                 @TableName = ''cust.DimCustomerEmail'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.DimEmailID = a.DimEmailID' + CHAR(13)
	+ '		,b.UpdatedDate = GETDATE()' + CHAR(13)
	+ ' FROM #dce_update a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'cust.DimCustomerEmail b ON a.DimCustomerEmailID = b.DimCustomerEmailID' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimCustomerEmailFromCDIOoutput'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13)



	+ ' IF (SELECT COUNT(0) FROM #dce_update) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerEmailFromCDIOoutput'', ''DimCustomerEmail - Enable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
	+ ' 	                                 @TableName = ''cust.DimCustomerEmail'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

 	+ ' IF OBJECT_ID(''tempdb..#cdoEmail'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #cdoEmail' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#Email_insert'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #Email_insert' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#Email_update'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #Email_update' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#dce_delete'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #dce_delete' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#dce_insert'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #dce_insert' + CHAR(13) + CHAR(13)
	


	------DimPhone
	+ ' IF OBJECT_ID(''tempdb..#phone_ranked'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #phone_ranked' + CHAR(13) + CHAR(13)
	
	+ ' ;WITH phone AS (' + CHAR(13)
	+ '		SELECT *, ROW_NUMBER() OVER (PARTITION BY a.PhoneCleanHash, a.PhoneDirtyHash ORDER BY a.DimCustomerID DESC) ranking, ROW_NUMBER() OVER (PARTITION BY a.PhoneDirtyHash ORDER BY a.DimCustomerID DESC) source_ranking' + CHAR(13)
	+ '		FROM #cdoPhone a' + CHAR(13)
	+ '		WHERE (a.Source_DimPhoneID IS NULL OR a.DimPhoneID IS NULL)' + CHAR(13)
	+ ' )' + CHAR(13)
	+ ' SELECT a.Phone, a.PhoneCleanHash, a.Input_Phone, a.PhoneDirtyHash, PhoneLineTypeCode, a.PhoneStatus, ranking, source_ranking' + CHAR(13)
	+ ' INTO #phone_ranked' + CHAR(13)
	+ ' FROM phone a' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#phone_insert'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #phone_insert' + CHAR(13) + CHAR(13)
	
	+ ' ;WITH phone AS (' + CHAR(13)
	+ ' 	SELECT DISTINCT CASE WHEN ISNULL(a.Phone,'''') != '''' THEN a.Phone ELSE a.Input_Phone END as Phone, CASE WHEN ISNULL(a.Phone,'''') != '''' THEN a.PhoneCleanHash ELSE a.PhoneDirtyHash END PhoneCleanHash, a.PhoneStatus, a.PhoneLineTypeCode' + CHAR(13)
	+ ' 	FROM #phone_ranked a' + CHAR(13)
	+ ' 	WHERE a.ranking = 1' + CHAR(13)
	--+ '		AND ISNULL(a.Phone,'''') != ''''' + CHAR(13)
	+ ' )' + CHAR(13)
	+ ' SELECT a.Phone, a.PhoneCleanHash, a.PhoneStatus, a.PhoneLineTypeCode' + CHAR(13)
	+ ' INTO #phone_insert' + CHAR(13)
	+ ' FROM phone a' + CHAR(13)
	+ ' LEFT JOIN ' + @ClientDB + 'dbo.DimPhone b ON a.PhoneCleanHash = b.PhoneCleanHash' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimPhoneID IS NULL' + CHAR(13) + CHAR(13)
	
	+ ' SELECT b.DimPhoneID, a.PhoneLineTypeCode, a.PhoneStatus' + CHAR(13)
	+ ' INTO #phone_update' + CHAR(13)
	+ ' FROM #phone_ranked a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimPhone b ON a.PhoneCleanHash = b.PhoneCleanHash' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND a.ranking = 1' + CHAR(13)
	--+ ' AND (ISNULL(a.PhoneLineTypeCode,'''') != ISNULL(b.PhoneLineTypeCode,'''')' + CHAR(13)
	--+ '		OR ISNULL(a.PhoneStatus,'''') != ISNULL(b.PhoneStatus,''''))' + CHAR(13) + CHAR(13)

	+ ' IF ((SELECT COUNT(0) FROM #phone_insert) + (SELECT COUNT(0) FROM #phone_update)) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimPhoneFromCDIOoutput'', ''DimPhone - Disable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
	+ ' 	                                 @TableName = ''dbo.DimPhone'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.PhoneLineTypeCode = a.PhoneLineTypeCode' + CHAR(13)
	+ '		,b.PhoneStatus = a.PhoneStatus' + CHAR(13)
	+ ' 	,b.UpdatedDate = GETDATE()' + CHAR(13)
	+ ' FROM #phone_update a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimPhone b ON a.DimPhoneID = b.DimPhoneID' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimPhoneFromCDIOoutput'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13)

	+ ' INSERT INTO ' + @ClientDB + 'dbo.DimPhone (Phone, PhoneCleanHash, PhoneLineTypeCode, PhoneStatus)' + CHAR(13)
	+ ' SELECT Phone, PhoneCleanHash, PhoneLineTypeCode, PhoneStatus' + CHAR(13)
	+ ' FROM #phone_insert' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimPhoneFromCDIOoutput'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13)

	+ ' IF ((SELECT COUNT(0) FROM #phone_insert) + (SELECT COUNT(0) FROM #phone_update)) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimPhoneFromCDIOoutput'', ''DimPhone - Enable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
	+ ' 	                                 @TableName = ''dbo.DimPhone'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	----Source_DimPhone
	+ ' IF OBJECT_ID(''tempdb..#source_phone_insert'') IS NOT NULL' + CHAR(13)
	+ '	DROP TABLE #source_phone_insert' + CHAR(13) + CHAR(13)
	
	--+ ' ;WITH source_phone AS (' + CHAR(13)
	--+ ' 	SELECT DISTINCT a.Phone, a.Source_Phone, a.PhoneDirtyHash' + CHAR(13)
	--+ ' 	FROM #phone_ranked a' + CHAR(13)
	--+ ' 	WHERE a.source_ranking = 1' + CHAR(13)
	--+ ' )' + CHAR(13)
	--+ ' SELECT NEWID() AS Source_DimPhoneID, b.DimPhoneID, a.Source_Phone AS Phone, a.PhoneDirtyHash' + CHAR(13)
	--+ ' INTO #source_phone_insert' + CHAR(13)
	--+ ' FROM source_phone a' + CHAR(13)
	--+ ' INNER JOIN ' + @ClientDB + 'dbo.DimPhone b ON a.PhoneCleanHash = b.PhoneCleanHash' + CHAR(13)
	--+ ' LEFT JOIN ' + @ClientDB + 'dbo.Source_DimPhone c ON a.PhoneDirtyHash = c.PhoneDirtyHash' + CHAR(13)
	--+ ' WHERE c.Source_DimPhoneID IS NULL' + CHAR(13) + CHAR(13)

	--+ ' IF (SELECT COUNT(0) FROM #source_phone_insert) >= 100000' + CHAR(13)
	--+ ' BEGIN' + CHAR(13)
	--+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	--+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Source_DimPhone - Disable indexes'', 0);' + CHAR(13) + CHAR(13)

	--+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
	--+ ' 	                                 @TableName = ''dbo.Source_DimPhone'',' + CHAR(13)
	--+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	--+ ' END' + CHAR(13) + CHAR(13)

	--+ ' INSERT INTO ' + @ClientDB + 'dbo.Source_DimPhone (Source_DimPhoneID, DimPhoneID, Phone, PhoneDirtyHash)' + CHAR(13)
	--+ ' SELECT Source_DimPhoneID, DimPhoneID, Phone, PhoneDirtyHash' + CHAR(13)
	--+ ' FROM #source_phone_insert' + CHAR(13) + CHAR(13)

	--+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	--+ ' values (current_timestamp, ''UpdateSource_DimPhoneFromCDIOoutput'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13)
	 
	--+ ' IF (SELECT COUNT(0) FROM #source_phone_insert) >= 100000' + CHAR(13)
	--+ ' BEGIN' + CHAR(13)
	--+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	--+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Source_DimPhone - Enable indexes'', 0);' + CHAR(13) + CHAR(13)

	--+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
	--+ ' 	                                 @TableName = ''dbo.Source_DimPhone'',' + CHAR(13)
	--+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	--+ ' END' + CHAR(13) + CHAR(13)


	+ ' UPDATE a' + CHAR(13)
	+ ' SET a.Source_DimPhoneID = b.Source_DimPhoneID' + CHAR(13)
	+ ' FROM #cdoPhone a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.Source_DimPhone b ON a.PhoneDirtyHash = b.PhoneDirtyHash' + CHAR(13) + CHAR(13)

	+ ' UPDATE a' + CHAR(13)
	+ ' SET a.DimPhoneID = b.DimPhoneID' + CHAR(13)
	+ ' FROM #cdoPhone a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimPhone b ON a.PhoneCleanHash = b.PhoneCleanHash' + CHAR(13) + CHAR(13)

	+ ' UPDATE a' + CHAR(13)
	+ ' SET a.Input_Custom2 = UPPER(LEFT(REPLACE(Input_Custom2,''phone'',''''),1)) + RIGHT(REPLACE(Input_Custom2,''phone'',''''),LEN(REPLACE(Input_Custom2,''phone'',''''))-1)' + CHAR(13)
	+ '		, a.Input_PhoneType = UPPER(LEFT(REPLACE(Input_PhoneType,''phone'',''''),1)) + RIGHT(REPLACE(Input_PhoneType,''phone'',''''),LEN(REPLACE(Input_PhoneType,''phone'',''''))-1)' + CHAR(13)
	+ ' FROM #cdoPhone a' + CHAR(13) + CHAR(13)

	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.DimPhoneID = a.DimPhoneID' + CHAR(13)
	+ ' FROM #cdoPhone a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.Source_DimPhone b ON a.Source_DimPhoneID = b.Source_DimPhoneID' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimPhoneID IS NULL' + CHAR(13) + CHAR(13)

	+ ' SELECT b.ID, a.DimPhoneID' + CHAR(13)
	+ ' INTO #dcp_update' + CHAR(13)
	+ ' FROM #cdoPhone a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)
	+ '		AND (a.Input_PhoneType = b.PhoneType OR a.Input_Custom2 = b.PhoneType)' + CHAR(13)
	+ ' WHERE 1=1' + CHAR(13)
	+ ' AND b.DimPhoneID IS NULL' + CHAR(13) + CHAR(13)
	
	--+ ' SELECT b.ID, b.DimCustomerID, b.PhoneType' + CHAR(13)
	--+ ' INTO #dcp_delete' + CHAR(13)
	--+ ' FROM #cdoPhone a' + CHAR(13)
	--+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.DimCustomerID = b.DimCustomerID' + CHAR(13)
	--+ '	AND a.Input_Custom2 = b.PhoneType' + CHAR(13) + CHAR(13)
	
	--+ ' SELECT a.DimCustomerID, a.Source_DimPhoneID, a.DimPhoneID, a.Input_Custom2 AS PhoneType' + CHAR(13)
	--+ ' INTO #dcp_insert' + CHAR(13)
	--+ ' FROM #cdoPhone a' + CHAR(13) + CHAR(13)

	----DimCustomerPhone
	+ ' IF (SELECT COUNT(0) FROM #dcp_update) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerPhoneFromCDIOoutput'', ''DimCustomerPhone - Disable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 0,' + CHAR(13)
	+ ' 	                                 @TableName = ''dbo.DimCustomerPhone'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.DimPhoneID = a.DimPhoneID' + CHAR(13)
	+ '		,b.UpdatedDate = GETDATE()' + CHAR(13)
	+ ' FROM #dcp_update a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.ID = b.ID' + CHAR(13) + CHAR(13)

	--+ ' DELETE b' + CHAR(13)
	--+ ' FROM #dcp_delete a' + CHAR(13)
	--+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerPhone b ON a.ID = b.ID' + CHAR(13) + CHAR(13)

	+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' values (current_timestamp, ''UpdateDimCustomerPhoneFromCDIOoutput'', ''Updated'', @@Rowcount);' + CHAR(13) + CHAR(13)

	--+ ' INSERT INTO ' + @ClientDB + 'dbo.DimCustomerPhone (DimCustomerID, Source_DimPhoneID, DimPhoneID, PhoneType)' + CHAR(13)
	--+ ' SELECT * FROM #dcp_insert' + CHAR(13) + CHAR(13)

	--+ ' Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	--+ ' values (current_timestamp, ''UpdateDimCustomerPhoneFromCDIOoutput'', ''Inserted'', @@Rowcount);' + CHAR(13) + CHAR(13)

	+ ' IF (SELECT COUNT(0) FROM #dcp_update) >= 100000' + CHAR(13)
	+ ' BEGIN' + CHAR(13)
	+ ' 	Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ ' 	VALUES (current_timestamp, ''UpdateDimCustomerPhoneFromCDIOoutput'', ''DimCustomerPhone - Enable indexes'', 0);' + CHAR(13) + CHAR(13)

	+ ' 	EXEC ' + @ClientDB + 'dbo.sp_EnableDisableIndexes @Enable = 1,' + CHAR(13)
	+ ' 	                                 @TableName = ''dbo.DimCustomerPhone'',' + CHAR(13)
	+ ' 	                                 @ViewCurrentIndexState = 0' + CHAR(13)
	+ ' END' + CHAR(13) + CHAR(13)

 	+ ' IF OBJECT_ID(''tempdb..#cdoPhone'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #cdoPhone' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#phone_insert'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #phone_insert' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#phone_update'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #phone_update' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#dcp_delete'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #dcp_delete' + CHAR(13) + CHAR(13)

	+ ' IF OBJECT_ID(''tempdb..#dcp_insert'') IS NOT NULL' + CHAR(13)
	+ ' 	DROP TABLE #dcp_insert' + CHAR(13) + CHAR(13)
	
   ----CD_DimCustomer
SET @sql = @sql    
	+ ' SELECT DISTINCT a.BatchId' + CHAR(13) 
	+ ' 	,b.SourceSystem' + CHAR(13) 
	+ ' 	,b.SSID' + CHAR(13) 
	+ ' 	,b.CompanyName' + CHAR(13) 
	+ ' 	,b.Gender' + CHAR(13) 
	+ ' 	,b.Prefix' + CHAR(13) 
	+ ' 	,b.FirstName' + CHAR(13) 
	+ ' 	,b.MiddleName' + CHAR(13) 
	+ ' 	,b.LastName' + CHAR(13) 
	+ ' 	,b.Suffix' + CHAR(13) 
	+ ' 	,b.FullName' + CHAR(13) 
	+ ' 	,b.NameIsCleanStatus' + CHAR(13) 
	+ ' 	,b.AddressPrimaryStreet' + CHAR(13) 
	+ ' 	,b.AddressPrimaryCity' + CHAR(13) 
	+ ' 	,b.AddressPrimaryState' + CHAR(13) 
	+ ' 	,b.AddressPrimaryZip' + CHAR(13) 
	+ ' 	,b.AddressPrimaryCounty' + CHAR(13) 
	+ ' 	,b.AddressPrimaryCountry' + CHAR(13) 
	+ ' 	,b.AddressPrimaryIsCleanStatus' + CHAR(13) 
	+ ' 	,b.ContactGUID' + CHAR(13) 
	+ ' 	,b.AddressOneStreet' + CHAR(13) 
	+ ' 	,b.AddressOneCity' + CHAR(13) 
	+ ' 	,b.AddressOneState' + CHAR(13) 
	+ ' 	,b.AddressOneZip' + CHAR(13) 
	+ ' 	,b.AddressOneCounty' + CHAR(13) 
	+ ' 	,b.AddressOneCountry' + CHAR(13) 
	+ ' 	,b.AddressOneIsCleanStatus' + CHAR(13) 
	+ ' 	,b.AddressTwoStreet' + CHAR(13) 
	+ ' 	,b.AddressTwoCity' + CHAR(13) 
	+ ' 	,b.AddressTwoState' + CHAR(13) 
	+ ' 	,b.AddressTwoZip' + CHAR(13) 
	+ ' 	,b.AddressTwoCounty' + CHAR(13) 
	+ ' 	,b.AddressTwoCountry' + CHAR(13) 
	+ ' 	,b.AddressTwoIsCleanStatus' + CHAR(13) 
	+ ' 	,b.AddressThreeStreet' + CHAR(13) 
	+ ' 	,b.AddressThreeCity' + CHAR(13) 
	+ ' 	,b.AddressThreeState' + CHAR(13) 
	+ ' 	,b.AddressThreeZip' + CHAR(13) 
	+ ' 	,b.AddressThreeCounty' + CHAR(13) 
	+ ' 	,b.AddressThreeCountry' + CHAR(13) 
	+ ' 	,b.AddressThreeIsCleanStatus' + CHAR(13) 
	+ ' 	,b.AddressFourStreet' + CHAR(13) 
	+ ' 	,b.AddressFourCity' + CHAR(13) 
	+ ' 	,b.AddressFourState' + CHAR(13) 
	+ ' 	,b.AddressFourZip' + CHAR(13) 
	+ ' 	,b.AddressFourCounty' + CHAR(13) 
	+ ' 	,b.AddressFourCountry' + CHAR(13) 
	+ ' 	,b.AddressFourIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhonePrimary' + CHAR(13) 
	+ ' 	,b.PhonePrimaryIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhoneHome' + CHAR(13) 
	+ ' 	,b.PhoneHomeIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhoneCell' + CHAR(13) 
	+ ' 	,b.PhoneCellIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhoneBusiness' + CHAR(13) 
	+ ' 	,b.PhoneBusinessIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhoneFax' + CHAR(13) 
	+ ' 	,b.PhoneFaxIsCleanStatus' + CHAR(13) 
	+ ' 	,b.PhoneOther' + CHAR(13) 
	+ ' 	,b.PhoneOtherIsCleanStatus' + CHAR(13) 
	+ ' 	,b.EmailPrimary' + CHAR(13) 
	+ ' 	,b.EmailPrimaryIsCleanStatus' + CHAR(13) 
	+ ' 	,b.EmailOne' + CHAR(13) 
	+ ' 	,b.EmailOneIsCleanStatus' + CHAR(13) 
	+ ' 	,b.EmailTwo' + CHAR(13) 
	+ ' 	,b.EmailTwoIsCleanStatus' + CHAR(13) 
	+ ' 	,b.AddressPrimaryNCOAStatus' + CHAR(13) 
	+ ' 	,b.AddressOneStreetNCOAStatus' + CHAR(13) 
	+ ' 	,b.AddressTwoStreetNCOAStatus' + CHAR(13) 
	+ ' 	,b.AddressThreeStreetNCOAStatus' + CHAR(13) 
	+ ' 	,b.AddressFourStreetNCOAStatus' + CHAR(13) 
	+ ' 	,b.AddressPrimarySuite' + CHAR(13) 
	+ ' 	,b.AddressOneSuite' + CHAR(13) 
	+ ' 	,b.AddressTwoSuite' + CHAR(13) 
	+ ' 	,b.AddressThreeSuite' + CHAR(13) 
	+ ' 	,b.AddressFourSuite' + CHAR(13) 
	+ ' 	,b.AddressPrimaryPlus4' + CHAR(13) 
	+ ' 	,b.AddressOnePlus4' + CHAR(13) 
	+ ' 	,b.AddressTwoPlus4' + CHAR(13) 
	+ ' 	,b.AddressThreePlus4' + CHAR(13) 
	+ ' 	,b.AddressFourPlus4' + CHAR(13) 
	+ ' 	,b.AddressPrimaryLatitude' + CHAR(13) 
	+ ' 	,b.AddressPrimaryLongitude' + CHAR(13) 
	+ ' 	,b.AddressOneLatitude' + CHAR(13) 
	+ ' 	,b.AddressOneLongitude' + CHAR(13) 
	+ ' 	,b.AddressTwoLatitude' + CHAR(13) 
	+ ' 	,b.AddressTwoLongitude' + CHAR(13) 
	+ ' 	,b.AddressThreeLatitude' + CHAR(13) 
	+ ' 	,b.AddressThreeLongitude' + CHAR(13) 
	+ ' 	,b.AddressFourLatitude' + CHAR(13) 
	+ ' 	,b.AddressFourLongitude' + CHAR(13) 
	+ ' 	,b.CreatedDate' + CHAR(13) 
	+ ' 	,b.UpdatedDate' + CHAR(13) 
	+ '		,b.FuzzyNameGUID' + CHAR(13) 
	+ '		,b.CompanyNameIsCleanStatus' + CHAR(13)
	+ ' INTO #batch' + CHAR(13) 
	+ ' FROM ' + @ClientDB + 'dbo.CleanDataOutput a' + CHAR(13) 
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SourceContactId = b.SSID' + CHAR(13) 
	+ ' 	AND a.Input_SourceSystem = b.SourceSystem' + CHAR(13) + CHAR(13) 
 
	+ ' CREATE CLUSTERED INDEX ix_batch_dimcustomerid_sourcecontactid_sourcesystem ON #batch (SourceSystem, SSID)' + CHAR(13) 
 
	+ ' Delete a ' + CHAR(13) 
	+ ' from ' + @ClientDB + 'dbo.CD_DimCustomer a ' + CHAR(13) 
	+ ' INNER JOIN #batch b ON b.SSID = a.SSID ' + CHAR(13) 
	+ ' 	AND b.SourceSystem = a.SourceSystem ' + CHAR(13) 
 
	+ ' INSERT INTO ' + @ClientDB + 'dbo.CD_DimCustomer' + CHAR(13)   
	+ ' SELECT *' + CHAR(13) 
	+ ' FROM #batch a' + CHAR(13)   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateCD_DimCustomerFromCDIOoutput'', ''Load CD_DimCustomer'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)	   
   
SET @sql = @sql   
	+ 'update ' + @ClientDB + 'dbo.Source_DimCustomer' + CHAR(13)   
	+ 'set' + CHAR(13)   
	+ '	NameIsCleanStatus = b.NameIsCleanStatus' + CHAR(13)   
	+ '	,AddressPrimaryIsCleanStatus = b.AddressPrimaryIsCleanStatus' + CHAR(13)   
	+ '	,AddressOneIsCleanStatus = b.AddressOneIsCleanStatus' + CHAR(13)   
	+ '	,AddressTwoIsCleanStatus = b.AddressTwoIsCleanStatus' + CHAR(13)   
	+ '	,AddressThreeIsCleanStatus = b.AddressThreeIsCleanStatus' + CHAR(13)   
	+ '	,AddressFourIsCleanStatus = b.AddressFourIsCleanStatus' + CHAR(13)   
	+ '	,PhonePrimaryIsCleanStatus = b.PhonePrimaryIsCleanStatus' + CHAR(13)   
	+ '	,PhoneHomeIsCleanStatus = b.PhoneHomeIsCleanStatus' + CHAR(13)   
	+ '	,PhoneCellIsCleanStatus = b.PhoneCellIsCleanStatus' + CHAR(13)   
	+ '	,PhoneBusinessIsCleanStatus = b.PhoneBusinessIsCleanStatus' + CHAR(13)   
	+ '	,PhoneFaxIsCleanStatus = b.PhoneFaxIsCleanStatus' + CHAR(13)   
	+ '	,PhoneOtherIsCleanStatus = b.PhoneOtherIsCleanStatus' + CHAR(13)   
	+ '	,EmailPrimaryIsCleanStatus = b.EmailPrimaryIsCleanStatus' + CHAR(13)   
	+ '	,EmailOneIsCleanStatus = b.EmailOneIsCleanStatus' + CHAR(13)   
	+ '	,EmailTwoIsCleanStatus = b.EmailTwoIsCleanStatus' + CHAR(13)   
	+ ' ,CompanyNameIsCleanStatus = b.CompanyNameIsCleanStatus' + CHAR(13)
	+ 'from #batch b ' + CHAR(13)  
	+ 'inner join ' + @ClientDB + 'dbo.Source_DimCustomer c on b.ssid = c.ssid' + CHAR(13)   
	+ '	and b.SourceSystem = c.SourceSystem' + CHAR(13)   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateSource_DimCustomerFromCDIOoutput'', ''update Source_DimCustomer - IsCleanStatus fields'', @@Rowcount);'   
SET @sql = @sql + CHAR(13) + CHAR(13)	   
 
SET @sql = @sql 
+ 'IF (SELECT COUNT(0) FROM ' + @clientdb + 'dbo.cleandataoutput) > 500000' + CHAR(13)   
	+ 'BEGIN' + CHAR(13)   
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 1, ''dbo.dimcustomer''' + CHAR(13)  
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''UpdateDimCustomerFromCDIOoutput'', ''Enable Indexes'', ''0'');'    
	+ 'END' + CHAR(13)   
	SET @sql = @sql + CHAR(13) + CHAR(13)   
   
	
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

	   
--SELECT @sql   
					   
EXEC sp_executesql @sql   
   
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
