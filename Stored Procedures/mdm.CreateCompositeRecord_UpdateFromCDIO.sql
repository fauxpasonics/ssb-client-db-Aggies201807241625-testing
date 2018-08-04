SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [mdm].[CreateCompositeRecord_UpdateFromCDIO] 
(
	@ClientDB VARCHAR(50)
)
AS
BEGIN


/*[mdm].[CreateCompositeRecord] 
* created: 12/22/2014 - Kwyss - creates a composite (or "golden") record from all the account records for a contact
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL
*
*
*/

IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

IF (SELECT @@VERSION) NOT LIKE '%Azure%'
BEGIN
SET @ClientDB = @ClientDB + '.'
END


DECLARE 
	@sql NVARCHAR(MAX) = ' '  + CHAR(13)


SET @sql = @sql
	+ '---Update from clean data'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord ' + CHAR(13)
	+ 'set[AddressPrimaryStreet] = cdio.address  + '' ''+ cdio.Address2' + CHAR(13)
	+ ',[AddressPrimarySuite]  = cdio.Suite' + CHAR(13)
	+ ',[AddressPrimaryCity]  = cdio.city' + CHAR(13)
	+ ',[AddressPrimaryState] = cdio.state' + CHAR(13)
	+ ',[AddressPrimaryZip] = cdio.zipcode' + CHAR(13)
	+ ',[AddressPrimaryPlus4] = cdio.Plus4' + CHAR(13)
	+ ',[AddressPrimaryLatitude] = cdio.ZipLatitude' + CHAR(13)
	+ ',[AddressPrimaryLongitude] = cdio.ZipLongitude' + CHAR(13)
	+ ',[AddressPrimaryCounty] = cdio.addresscounty' + CHAR(13)
	+ ',[AddressPrimaryCountry] = cdio.addresscountry' + CHAR(13)
	+ ',[AddressPrimaryIsCleanStatus] = isnull(cast(AddressStatus as nvarchar(100)), ''notfound'')' + CHAR(13)
	+ '--,[AddressPrimaryMasterId] [bigint] NULL,' + CHAR(13)
	+ ',[ContactGUID] = ContactId' + CHAR(13)
	+ ',[Prefix]  = cdio.prefix ' + CHAR(13)
	+ ',[FirstName] = cdio.firstname' + CHAR(13)
	+ ',[MiddleName] = cdio.middlename' + CHAR(13)
	+ ',[LastName] = cdio.lastname' + CHAR(13)
	+ ',[Suffix] = cdio.suffix' + CHAR(13)
	+ ', Gender = cdio.Gender' + CHAR(13)
	+ ',[NameIsCleanStatus] = isnull(cast(NameStatus as nvarchar(100)), ''notfound'')' + CHAR(13)
	+ ',[AddressPrimaryNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)
	+ ',[PhonePrimary] = cdio.phone' + CHAR(13)
	+ ',[PhonePrimaryIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)
	+ ', [EmailPrimary] = cdio.emailaddress' + CHAR(13)
	+ ',[EmailPrimaryIsCleanStatus] = isnull(cdio.EmailStatus,''notfound'')' + CHAR(13)
	+ '---, [ExternalContactId] = case when isnull(ContactID, ''{00000000-0000-0000-0000-000000000000}'')  != ''{00000000-0000-0000-0000-000000000000}''  then ContactId else newID() end' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ 'and Input_Custom2 = ''contact'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update primary contact info from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set [AddressOneStreet] = cdio.address + '' ''+ cdio.Address2' + CHAR(13)
	+ ',[AddressOneSuite]  = cdio.Suite' + CHAR(13)
	+ ',[AddressOneCity] = cdio.city' + CHAR(13)
	+ ',[AddressOneState] = cdio.state' + CHAR(13)
	+ ',[AddressOneZip]  = cdio.zipcode' + CHAR(13)
	+ ',[AddressOnePlus4] = cdio.Plus4' + CHAR(13)
	+ ',[AddressOneLatitude] = cdio.ZipLatitude' + CHAR(13)
	+ ',[AddressOneLongitude] = cdio.ZipLongitude' + CHAR(13)
	+ ',[AddressOneCounty] =  cdio.addresscounty' + CHAR(13)
	+ ',[AddressOneCountry]  = cdio.addresscountry' + CHAR(13)
	+ ',[AddressOneIsCleanStatus]  = isnull(AddressStatus, ''notfound'')' + CHAR(13)
	+ '--,[AddressOneMasterId] [bigint] NULL,' + CHAR(13)
	+ ',[AddressOneStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''addressone'';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update address one from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ '--udpate address two' + CHAR(13)
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set[AddressTwoStreet] =  cdio.address + '' ''+ cdio.Address2' + CHAR(13)
	+ ',[AddressTwoSuite]  = cdio.Suite' + CHAR(13)
	+ ',[AddressTwoCity] = cdio.city' + CHAR(13)
	+ ',[AddressTwoState] = cdio.state' + CHAR(13)
	+ ',[AddressTwoZip] = cdio.zipcode' + CHAR(13)
	+ ',[AddressTwoPlus4] = cdio.Plus4' + CHAR(13)
	+ ',[AddressTwoLatitude] = cdio.ZipLatitude' + CHAR(13)
	+ ',[AddressTwoLongitude] = cdio.ZipLongitude' + CHAR(13)
	+ ',[AddressTwocounty] = cdio.addresscounty' + CHAR(13)
	+ ',[AddressTwoCountry] = cdio.AddressCountry' + CHAR(13)
	+ ',[AddressTwoIsCleanStatus] =isnull(AddressStatus, ''notfound'')' + CHAR(13)
	+ '--,[AddressTwoMasterId] [bigint] NULL,' + CHAR(13)
	+ ',[AddressTwoStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem ' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''addresstwo'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update address two from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ '--udpate address three' + CHAR(13)
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '    [AddressThreeStreet] = cdio.address + '' ''+ cdio.Address2' + CHAR(13)
	+ ',[AddressThreeSuite]  = cdio.Suite' + CHAR(13)
	+ ',[AddressThreeCity] = cdio.city' + CHAR(13)
	+ ',[AddressThreeState] =cdio.state' + CHAR(13)
	+ ',[AddressThreeZip] = cdio.zipcode' + CHAR(13)
	+ ',[AddressThreePlus4] = cdio.Plus4' + CHAR(13)
	+ ',[AddressThreeLatitude] = cdio.ZipLatitude' + CHAR(13)
	+ ',[AddressThreeLongitude] = cdio.ZipLongitude' + CHAR(13)
	+ ',[AddressThreeCounty] = cdio.addresscounty' + CHAR(13)
	+ ',[AddressThreeCountry]  = cdio.addresscountry' + CHAR(13)
	+ ',[AddressThreeIsCleanStatus] = isnull(AddressStatus, ''notfound'')' + CHAR(13)
	+ '--,[AddressThreeMasterId] [bigint] NULL,' + CHAR(13)
	+ ',[AddressThreeStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem ' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''addressthree'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update address three from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ '--udpate address four' + CHAR(13)
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[AddressFourStreet] = cdio.address + '' ''+ cdio.Address2' + CHAR(13)
	+ ',[AddressFourSuite]  = cdio.Suite' + CHAR(13)
	+ ',[AddressFourCity] = cdio.city' + CHAR(13)
	+ ',[AddressFourState] =cdio.state' + CHAR(13)
	+ ',[AddressFourZip] = cdio.zipcode' + CHAR(13)
	+ ',[AddressFourPlus4] = cdio.Plus4' + CHAR(13)
	+ ',[AddressFourLatitude] = cdio.ZipLatitude' + CHAR(13)
	+ ',[AddressFourLongitude] = cdio.ZipLongitude' + CHAR(13)
	+ ',[AddressFourCounty] = cdio.addresscounty' + CHAR(13)
	+ ',[AddressFourCountry] = cdio.AddressCountry' + CHAR(13)
	+ ',[AddressFourIsCleanStatus] = isnull(AddressStatus, ''notfound'')' + CHAR(13)
	+ '--,[AddressFourMasterId] [bigint] NULL,' + CHAR(13)
	+ ',[AddressFourStreetNCOAStatus] = CASE WHEN ISNULL(cdio.ncoaMoveEffectiveDate,'''') = '''' THEN 0 ELSE 1 END' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''addressfour'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update address four from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql
	+ '/*Standard Phone Entities*/'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[PhoneHome] = cdio.phone' + CHAR(13)
	+ ',[PhoneHomeIsCleanStatus] =isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)
	+ '--[PhoneHomeMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''phonehome'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update home phone from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[PhoneCell]= cdio.phone' + CHAR(13)
	+ ',[PhoneCellIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)
	+ '--[PhoneCellMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''phonecell'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update cell phone from cleandata'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[PhoneBusiness] = cdio.phone' + CHAR(13)
	+ ',[PhoneBusinessIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)
	+ '--[PhoneBusinessMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''phonebusiness'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update business phone from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[PhoneFax] = cdio.phone' + CHAR(13)
	+ ',[PhoneFaxIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')' + CHAR(13)
	+ '--[PhoneFaxMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''phonefax'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update fax phone from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[PhoneOther] = cdio.phone' + CHAR(13)
	+ ',[PhoneOtherIsCleanStatus] = isnull(cdio.PhoneStatus, ''notfound'')  ' + CHAR(13)
	+ '--[PhoneOtherMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''phoneother'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update other phone from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql
	+ '/*Standard Email Entities*/'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[EmailOne] = cdio.emailaddress' + CHAR(13)
	+ ',[EmailOneIsCleanStatus] =  isnull(cdio.EmailStatus,''notfound'')' + CHAR(13)
	+ '--[EmailOneMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''emailone'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
+ 'values (current_timestamp, ''create composite record'', ''update email one from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'update ' + @ClientDB + 'mdm.compositerecord' + CHAR(13)
	+ 'set' + CHAR(13)
	+ '[EmailTwo] = cdio.emailaddress ' + CHAR(13)
	+ ',[EmailTwoIsCleanStatus] =  isnull(cdio.EmailStatus,''notfound'') ' + CHAR(13)
	+ '--[EmailTwoMasterId] [bigint] NULL,' + CHAR(13)
	+ ', [UpdatedBy] = ''CI''' + CHAR(13)
	+ ', [UpdatedDate] = current_timestamp' + CHAR(13)
	+ 'from ' + @ClientDB + 'dbo.CleanDataOutput cdio, ' + @ClientDB + 'mdm.compositerecord dimcust' + CHAR(13)
	+ 'where cdio.sourcecontactid = dimcust.ssid AND cdio.Input_SourceSystem = dimcust.SourceSystem' + CHAR(13)
	+ '-- and cdio.Id BETWEEN @RowId AND @RowIdLoop' + CHAR(13)
	+ 'and Input_Custom2 = ''emailtwo'';' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''create composite record'', ''update email two from cleandata'', @@ROWCOUNT);' 
SET @sql = @sql + CHAR(13) + CHAR(13)




EXEC sp_executesql @sql

END
GO
