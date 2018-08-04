SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
   
   
   
   
CREATE PROCEDURE [mdm].[CreateCompositeRecord_AddPrimary]    
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
   
---DECLARE @clientdb VARCHAR(50) = 'Steelers'   
   
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
   
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
   
SET @sql = @sql   
+ 'SELECT distinct a.dimcustomerid  ' + CHAR(13)   
+ 'INTO #tmpA ' + CHAR(13)   
+ 'FROM ' + @ClientDB + 'mdm.compositerecord a ' + CHAR(13)   
+ 'INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c ' + CHAR(13)   
+ 'ON a.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id ' + CHAR(13)   
+ 'INNER JOIN ' + @ClientDB + 'dbo.dimcustomer b ' + CHAR(13)   
+ 'ON c.dimcustomerid = b.DimCustomerId ' + CHAR(13)   
+ 'WHERE a.updateddate < b.UpdatedDate  OR b.isdeleted = 1 OR b.DimCustomerId IS null; ' + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''tmp - updated or deleted'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
+ 'INSERT INTO #tmpA ' + CHAR(13)   
+ 'Select a.dimcustomerid from ' + @ClientDB + 'mdm.compositerecord a ' + CHAR(13)   
+ 'left join ' + @ClientDB + 'dbo.dimcustomerssbid b ' + CHAR(13)   
+ 'on a.dimcustomerid = b.dimcustomerid ' + CHAR(13)   
+ 'where b.SSB_CRMSYSTEM_PRIMARY_FLAG != 1 OR b.dimcustomerid IS null;  ' + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''tmp - no longer primary'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql   
+ 'INSERT INTO #tmpA ' + CHAR(13)   
+ 'SELECT a.dimcustomerid FROM ' + @ClientDB + 'mdm.compositerecord a ' + CHAR(13)   
+ 'INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b ' + CHAR(13)   
+ 'ON a.DimCustomerId = b.DimCustomerId ' + CHAR(13)   
+ 'WHERE ISNULL(a.SSB_CRMSYSTEM_ACCT_ID, a.SSB_CRMSYSTEM_CONTACT_ID) != b.SSB_CRMSYSTEM_contactACCT_ID' + CHAR(13)   
+ 'OR a.SSB_CRMSYSTEM_CONTACT_ID != b.SSB_CRMSYSTEM_CONTACT_ID ' + CHAR(13)   
+ 'OR a.SSB_CRMSYSTEM_HOUSEHOLD_ID != b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13) + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''TmpAdd - changed contact id'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
SET @sql = @sql   
+ ' INSERT INTO #tmpA ' + CHAR(13)   
+ ' SELECT a.dimcustomerid ' + CHAR(13)   
+ ' FROM ' + @ClientDB + 'dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)   
+ ' INNER JOIN ' + @ClientDB + 'mdm.compositerecord b ' + CHAR(13)   
+ ' ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID ' + CHAR(13)   
+ ' WHERE a.updateddate > b.UpdatedDate' + CHAR(13)   
+ ' UNION' + CHAR(13)   
+ ' SELECT b.dimcustomerid' + CHAR(13)   
+ ' FROM ' + @ClientDB + 'mdm.CompositeAttribute a WITH (NOLOCK)' + CHAR(13)   
+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b WITH (NOLOCK) ON a.SSB_CRMSYSTEM_CONTACT_ID = b.SSB_CRMSYSTEM_CONTACT_ID' + CHAR(13)   
+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributes c WITH (NOLOCK) ON b.DimCustomerId = c.DimCustomerID' + CHAR(13)   
+ ' WHERE 1=1' + CHAR(13)   
+ ' AND c.UpdatedDate >= a.InsertDate; ' + CHAR(13) + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''TmpAdd - more updated'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
 SET @sql = @sql
 + 'Insert into #tmpA' + CHAR(13)
 + 'Select a.dimcustomerid from ' + @ClientDB + 'dbo.dimcustomerssbid a with (nolock)'
 + CHAR(13)  	+ 'left join ' + @ClientDB + 'mdm.compositerecord b' + CHAR(13)
 + 'on a.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id' + CHAR(13)
 + 'left join #tmpA c' + CHAR(13)  	+ 'on a.dimcustomerid = c.dimcustomerid' + CHAR(13)
 + 'where b.ssb_crmsystem_contact_id is null and c.dimcustomerid is null;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
+ 'CREATE CLUSTERED INDEX ixc_temp_dimcustomerid ON #tmpA(dimcustomerid); ' + CHAR(13)   
  
 SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
+ 'IF (SELECT COUNT(0) FROM #tmpA) > 20000' + CHAR(13)   
	+ 'BEGIN' + CHAR(13)   
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''mdm.compositeAttribute''' + CHAR(13)   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''Disable Indexes - CompositeAttribute'', ''0'');'    
	+ 'END' + CHAR(13)   
	SET @sql = @sql + CHAR(13) + CHAR(13)   
  
SET @sql = @sql   
+ 'delete a from '+ @ClientDB + 'mdm.CompositeAttribute a '+ CHAR(13)  
+ 'inner join #tmpA b '+ CHAR(13)  
+ 'ON a.dimcustomerid = b.dimcustomerid; '+ CHAR(13) + CHAR(13)

SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''remove updated recs - compositeattribute'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)

 SET @sql = @sql
 + 'delete a from '+ @ClientDB + 'mdm.CompositeAttribute a '+ CHAR(13)  
 + 'INNER JOIN '+ @ClientDB + 'dbo.dimcustomerssbid b '+ CHAR(13)  
 + 'on a.ssb_crmsystem_contact_id = b.ssb_crmsystem_contact_id '+ CHAR(13)  
 + 'inner join #tmpA c '+ CHAR(13)  
 + 'ON b.dimcustomerid = c.dimcustomerid;'
SET @sql = @sql + CHAR(13) + CHAR(13)   
  
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''remove updated recs - compositeattribute'', @@ROWCOUNT);'      
SET @sql = @sql + CHAR(13) + CHAR(13)   

SET @sql = @sql   
+ 'IF (SELECT COUNT(0) FROM #tmpA) > 20000' + CHAR(13)   
	+ 'BEGIN' + CHAR(13)   
	+ 'EXEC '+ @ClientDB + 'dbo.sp_EnableDisableIndexes 0, ''mdm.compositerecord''' + CHAR(13)   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''Disable Indexes'', ''0'');'    
	+ 'END' + CHAR(13)   
	SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
	+ '---Remove records that are no longer primary' + CHAR(13)   
SET @sql = @sql   
+ 'delete from ' + @ClientDB + 'mdm.compositerecord where ssb_crmsystem_contact_id in  '+ CHAR(13)   
+ '(select b.SSB_CRMSYSTEM_CONTACT_ID from #tmpA a '+ CHAR(13)   
+ '	INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid b '+ CHAR(13)   
+ '	ON a.dimcustomerid = b.dimcustomerid) OR dimcustomerid IN (SELECT dimcustomerid FROM #tmpA); '+ CHAR(13)   
   
   
   
	SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''remove updated recs - compositerecord'', @@ROWCOUNT);'   
   
  
   
SET @sql = @sql   
+ 'SELECT distinct b.dimcustomerid, b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_HOUSEHOLD_ID, b.SSB_CRMSYSTEM_CONTACT_ID  ' + CHAR(13)   
+ 'INTO #tmpAdd ' + CHAR(13)   
+ 'FROM  ' + @ClientDB + 'dbo.dimcustomerssbid b ' + CHAR(13)   
+ 'left join ' + @ClientDB + 'mdm.compositerecord c ' + CHAR(13)   
+ 'on b.dimcustomerid = c.dimcustomerid ' + CHAR(13)   
+ 'where b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1  and c.dimcustomerid is NULL ' + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''TmpAdd'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
   
   
SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
+ 'CREATE CLUSTERED INDEX ix_tmpadd ON #tmpAdd(DimCustomerId); ' + CHAR(13)   
   
   
SET @sql = @sql    
+ 'IF Object_ID(''' + @ClientDB + 'mdm.tmp_composite'', ''U'') Is NOT NULL '   
+ ' DROP TABLE '+ @ClientDB +'mdm.tmp_composite;'   
   
SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql   
	+ '--- Insert new primary records' + CHAR(13)   
	   
	+ 'SELECT a.DimCustomerId' + CHAR(13)   
	+ '      ,a.BatchId' + CHAR(13)   
	+ '      ,a.ODSRowLastUpdated' + CHAR(13)   
	+ '      ,a.SourceDB' + CHAR(13)   
	+ '      ,a.SourceSystem' + CHAR(13)   
	+ '      ,a.SourceSystemPriority' + CHAR(13)   
	+ '      ,a.SSID' + CHAR(13)   
	+ '      ,a.CustomerType' + CHAR(13)   
	+ '      ,a.CustomerStatus' + CHAR(13)   
	+ '      ,a.AccountType' + CHAR(13)   
	+ '      ,a.AccountRep' + CHAR(13)   
	+ '      ,a.CompanyName' + CHAR(13)   
	+ '      ,a.SalutationName' + CHAR(13)   
	+ '      ,a.DonorMailName' + CHAR(13)   
	+ '      ,a.DonorFormalName' + CHAR(13)   
	+ '      ,a.Birthday' + CHAR(13)   
	+ '      ,a.Gender' + CHAR(13)   
	+ '      ,a.MergedRecordFlag' + CHAR(13)   
	+ '      ,a.MergedIntoSSID' + CHAR(13)   
	+ '      ,a.Prefix' + CHAR(13)   
	+ '      ,a.FirstName' + CHAR(13)   
	+ '      ,a.MiddleName' + CHAR(13)   
	+ '      ,a.LastName' + CHAR(13)   
	+ '      ,a.Suffix' + CHAR(13)   
	+ '      ,a.NameDirtyHash' + CHAR(13)   
	+ '      ,a.NameIsCleanStatus' + CHAR(13)   
	+ '      ,a.NameMasterId' + CHAR(13)   
	+ '      ,a.AddressPrimaryStreet' + CHAR(13)   
	+ '      ,a.AddressPrimaryCity' + CHAR(13)   
	+ '      ,a.AddressPrimaryState' + CHAR(13)   
	+ '      ,a.AddressPrimaryZip' + CHAR(13)   
	+ '      ,a.AddressPrimaryCounty' + CHAR(13)   
	+ '      ,a.AddressPrimaryCountry' + CHAR(13)   
	+ '      ,a.AddressPrimaryDirtyHash' + CHAR(13)   
	+ '      ,a.AddressPrimaryIsCleanStatus' + CHAR(13)   
	+ '      ,a.AddressPrimaryMasterId' + CHAR(13)   
	+ '      ,a.ContactDirtyHash' + CHAR(13)   
	+ '      ,a.ContactGUID' + CHAR(13)   
	+ '      ,a.AddressOneStreet' + CHAR(13)   
	+ '      ,a.AddressOneCity' + CHAR(13)   
	+ '      ,a.AddressOneState' + CHAR(13)   
	+ '      ,a.AddressOneZip' + CHAR(13)   
	+ '      ,a.AddressOneCounty' + CHAR(13)   
	+ '      ,a.AddressOneCountry' + CHAR(13)   
	+ '      ,a.AddressOneDirtyHash' + CHAR(13)   
	+ '      ,a.AddressOneIsCleanStatus' + CHAR(13)   
	+ '      ,a.AddressOneMasterId' + CHAR(13)   
	+ '      ,a.AddressTwoStreet' + CHAR(13)   
	+ '      ,a.AddressTwoCity' + CHAR(13)   
	+ '      ,a.AddressTwoState' + CHAR(13)   
	+ '      ,a.AddressTwoZip' + CHAR(13)   
	+ '      ,a.AddressTwoCounty' + CHAR(13)   
	+ '      ,a.AddressTwoCountry' + CHAR(13)   
	+ '      ,a.AddressTwoDirtyHash' + CHAR(13)   
	+ '      ,a.AddressTwoIsCleanStatus' + CHAR(13)   
	+ '      ,a.AddressTwoMasterId' + CHAR(13)   
	+ '      ,a.AddressThreeStreet' + CHAR(13)   
	+ '      ,a.AddressThreeCity' + CHAR(13)   
	+ '      ,a.AddressThreeState' + CHAR(13)   
	+ '      ,a.AddressThreeZip' + CHAR(13)   
	+ '      ,a.AddressThreeCounty' + CHAR(13)   
	+ '      ,a.AddressThreeCountry' + CHAR(13)   
	+ '      ,a.AddressThreeDirtyHash' + CHAR(13)   
	+ '      ,a.AddressThreeIsCleanStatus' + CHAR(13)   
	+ '      ,a.AddressThreeMasterId' + CHAR(13)   
	+ '      ,a.AddressFourStreet' + CHAR(13)   
	+ '      ,a.AddressFourCity' + CHAR(13)   
	+ '      ,a.AddressFourState' + CHAR(13)   
	+ '      ,a.AddressFourZip' + CHAR(13)   
	+ '      ,a.AddressFourCounty' + CHAR(13)   
	+ '      ,a.AddressFourCountry' + CHAR(13)   
	+ '      ,a.AddressFourDirtyHash' + CHAR(13)   
	+ '      ,a.AddressFourIsCleanStatus' + CHAR(13)   
	+ '      ,a.AddressFourMasterId' + CHAR(13)   
	+ '      ,a.PhonePrimary' + CHAR(13)   
	+ '      ,a.PhonePrimaryDirtyHash' + CHAR(13)   
	+ '      ,a.PhonePrimaryIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhonePrimaryMasterId' + CHAR(13)   
	+ '      ,a.PhoneHome' + CHAR(13)   
	+ '      ,a.PhoneHomeDirtyHash' + CHAR(13)   
	+ '      ,a.PhoneHomeIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhoneHomeMasterId' + CHAR(13)   
	+ '      ,a.PhoneCell' + CHAR(13)   
	+ '      ,a.PhoneCellDirtyHash' + CHAR(13)   
	+ '      ,a.PhoneCellIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhoneCellMasterId' + CHAR(13)   
	+ '      ,a.PhoneBusiness' + CHAR(13)   
	+ '      ,a.PhoneBusinessDirtyHash' + CHAR(13)   
	+ '      ,a.PhoneBusinessIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhoneBusinessMasterId' + CHAR(13)   
	+ '      ,a.PhoneFax' + CHAR(13)   
	+ '      ,a.PhoneFaxDirtyHash' + CHAR(13)   
	+ '      ,a.PhoneFaxIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhoneFaxMasterId' + CHAR(13)   
	+ '      ,a.PhoneOther' + CHAR(13)   
	+ '      ,a.PhoneOtherDirtyHash' + CHAR(13)   
	+ '      ,a.PhoneOtherIsCleanStatus' + CHAR(13)   
	+ '      ,a.PhoneOtherMasterId' + CHAR(13)   
	+ '      ,a.EmailPrimary' + CHAR(13)   
	+ '      ,a.EmailPrimaryDirtyHash' + CHAR(13)   
	+ '      ,a.EmailPrimaryIsCleanStatus' + CHAR(13)   
	+ '      ,a.EmailPrimaryMasterId' + CHAR(13)   
	+ '      ,a.EmailOne' + CHAR(13)   
	+ '      ,a.EmailOneDirtyHash' + CHAR(13)   
	+ '      ,a.EmailOneIsCleanStatus' + CHAR(13)   
	+ '      ,a.EmailOneMasterId' + CHAR(13)   
	+ '      ,a.EmailTwo' + CHAR(13)   
	+ '      ,a.EmailTwoDirtyHash' + CHAR(13)   
	+ '      ,a.EmailTwoIsCleanStatus' + CHAR(13)   
	+ '      ,a.EmailTwoMasterId' + CHAR(13)   
	+ '      ,a.ExtAttribute1' + CHAR(13)   
	+ '      ,a.ExtAttribute2' + CHAR(13)   
	+ '      ,a.ExtAttribute3' + CHAR(13)   
	+ '      ,a.ExtAttribute4' + CHAR(13)   
	+ '      ,a.ExtAttribute5' + CHAR(13)   
	+ '      ,a.ExtAttribute6' + CHAR(13)   
	+ '      ,a.ExtAttribute7' + CHAR(13)   
	+ '      ,a.ExtAttribute8' + CHAR(13)   
	+ '      ,a.ExtAttribute9' + CHAR(13)   
	+ '      ,a.ExtAttribute10' + CHAR(13)   
	+ '      ,a.ExtAttribute11' + CHAR(13)   
	+ '      ,a.ExtAttribute12' + CHAR(13)   
	+ '      ,a.ExtAttribute13' + CHAR(13)   
	+ '      ,a.ExtAttribute14' + CHAR(13)   
	+ '      ,a.ExtAttribute15' + CHAR(13)   
	+ '      ,a.ExtAttribute16' + CHAR(13)   
	+ '      ,a.ExtAttribute17' + CHAR(13)   
	+ '      ,a.ExtAttribute18' + CHAR(13)   
	+ '      ,a.ExtAttribute19' + CHAR(13)   
	+ '      ,a.ExtAttribute20' + CHAR(13)   
	+ '      ,a.ExtAttribute21' + CHAR(13)   
	+ '      ,a.ExtAttribute22' + CHAR(13)   
	+ '      ,a.ExtAttribute23' + CHAR(13)   
	+ '      ,a.ExtAttribute24' + CHAR(13)   
	+ '      ,a.ExtAttribute25' + CHAR(13)   
	+ '      ,a.ExtAttribute26' + CHAR(13)   
	+ '      ,a.ExtAttribute27' + CHAR(13)   
	+ '      ,a.ExtAttribute28' + CHAR(13)   
	+ '      ,a.ExtAttribute29' + CHAR(13)   
	+ '      ,a.ExtAttribute30' + CHAR(13)   
	+ '      ,a.SSCreatedBy' + CHAR(13)   
	+ '      ,a.SSUpdatedBy' + CHAR(13)   
	+ '      ,a.SSCreatedDate' + CHAR(13)   
	+ '      ,a.SSUpdatedDate' + CHAR(13)   
	+ '      ,a.CreatedBy' + CHAR(13)   
	+ '      ,a.UpdatedBy' + CHAR(13)   
	+ '      ,a.CreatedDate' + CHAR(13)   
	+ '      , current_timestamp as UpdatedDate' + CHAR(13)   
	+ '      ,a.AccountId' + CHAR(13)   
	+ '      ,a.AddressPrimaryNCOAStatus' + CHAR(13)   
	+ '      ,a.AddressOneStreetNCOAStatus' + CHAR(13)   
	+ '      ,a.AddressTwoStreetNCOAStatus' + CHAR(13)   
	+ '      ,a.AddressThreeStreetNCOAStatus' + CHAR(13)   
	+ '      ,a.AddressFourStreetNCOAStatus' + CHAR(13)   
	+ '      ,a.IsDeleted' + CHAR(13)   
	+ '      ,a.DeleteDate' + CHAR(13)   
	+ '      ,a.IsBusiness' + CHAR(13)   
	+ '      ,a.FullName' + CHAR(13)   
	+ '      ,a.ExtAttribute31' + CHAR(13)   
	+ '      ,a.ExtAttribute32' + CHAR(13)   
	+ '      ,a.ExtAttribute33' + CHAR(13)   
	+ '      ,a.ExtAttribute34' + CHAR(13)   
	+ '      ,a.ExtAttribute35' + CHAR(13)   
	+ '      ,a.AddressPrimarySuite' + CHAR(13)   
	+ '      ,a.AddressOneSuite' + CHAR(13)   
	+ '      ,a.AddressTwoSuite' + CHAR(13)   
	+ '      ,a.AddressThreeSuite' + CHAR(13)   
	+ '      ,a.AddressFourSuite' + CHAR(13)   
	+ ', b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID ' + CHAR(13)   
	+ '      ,a.PhonePrimaryDNC' + CHAR(13)   
	+ '      ,a.PhoneHomeDNC' + CHAR(13)   
	+ '      ,a.PhoneCellDNC' + CHAR(13)   
	+ '      ,a.PhoneBusinessDNC' + CHAR(13)   
	+ '      ,a.PhoneFaxDNC' + CHAR(13)   
	+ '      ,a.PhoneOtherDNC' + CHAR(13)   
	+ '      ,a.AddressPrimaryPlus4' + CHAR(13)   
	+ '      ,a.AddressOnePlus4' + CHAR(13)   
	+ '      ,a.AddressTwoPlus4' + CHAR(13)   
	+ '      ,a.AddressThreePlus4' + CHAR(13)   
	+ '      ,a.AddressFourPlus4' + CHAR(13)   
	+ '      ,a.AddressPrimaryLatitude' + CHAR(13)   
	+ '      ,a.AddressPrimaryLongitude' + CHAR(13)   
	+ '      ,a.AddressOneLatitude' + CHAR(13)   
	+ '      ,a.AddressOneLongitude' + CHAR(13)   
	+ '      ,a.AddressTwoLatitude' + CHAR(13)   
	+ '      ,a.AddressTwoLongitude' + CHAR(13)   
	+ '      ,a.AddressThreeLatitude' + CHAR(13)   
	+ '      ,a.AddressThreeLongitude' + CHAR(13)   
	+ '      ,a.AddressFourLatitude' + CHAR(13)   
	+ '      ,a.AddressFourLongitude' + CHAR(13)   
	+ '		 ,a.CD_Gender' + CHAR(13)   
	+ '		 ,b.SSB_CRMSYSTEM_HOUSEHOLD_ID' + CHAR(13)   
	+ '		 ,a.CompanyNameIsCleanStatus' + CHAR(13)
	+ ' into ' + @ClientDB + 'mdm.tmp_composite ' + CHAR(13)   
	+ 'from ' + @ClientDB + 'dbo.dimcustomer a' + CHAR(13)   
	+ 'inner join #tmpAdd b' + CHAR(13)   
	+ 'on a.dimcustomerid = b.dimcustomerid ' + CHAR(13)   
	+ 'where a.isdeleted = 0;'   
SET @sql = @sql + CHAR(13) + CHAR(13)   
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''insert new primaries - mdm.tmp_composite'', @@ROWCOUNT);'    
SET @sql = @sql + CHAR(13) + CHAR(13)   
   
SET @sql = @sql    
	+ 'CREATE NONCLUSTERED INDEX IX_tmp_composite ON  ' + @ClientDB + 'mdm.tmp_composite ([SSB_CRMSYSTEM_CONTACT_ID])' + CHAR(13)   
   
	+ ' CREATE NONCLUSTERED INDEX ix_dimcustomerid ON ' + @ClientDB + 'mdm.tmp_composite (DimCustomerId) INCLUDE (SSB_CRMSYSTEM_CONTACT_ID)' + CHAR(13) + CHAR(13)   
   
	+ ' IF OBJECT_ID(''' + @ClientDB + 'mdm.tmp_CompositeAttribute'') IS NOT NULL' + CHAR(13)   
	+ '		DROP TABLE ' + @ClientDB + 'mdm.tmp_CompositeAttribute' + CHAR(13) + CHAR(13)   
   
	+ ' SELECT a.DimCustomerID, a.SSB_CRMSYSTEM_CONTACT_ID, c.*' + CHAR(13)   
	+ ' INTO ' + @ClientDB + 'mdm.tmp_CompositeAttribute' + CHAR(13)   
	+ ' FROM ' + @ClientDB + 'mdm.tmp_composite a WITH (NOLOCK)' + CHAR(13)   
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributes b WITH (NOLOCK) ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)   
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomerAttributeValues c WITH (NOLOCK) ON b.DimCustomerAttrID = c.DimCustomerAttrID' + CHAR(13)   
	+ ' INNER JOIN (SELECT b.Attribute FROM ' + @ClientDB + 'mdm.AttributeGroup a WITH (NOLOCK) INNER JOIN ' + @ClientDB + 'mdm.Attributes b WITH (NOLOCK) ON a.AttributeGroupID = b.AttributeGroupID) d ON c.AttributeName = d.Attribute' + CHAR(13)   
	+ ' WHERE 1=1' + CHAR(13) + CHAR(13)   
   
	+ 'Insert into ' + @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)   
	+ 'values (current_timestamp, ''create composite record'', ''insert new primaries - mdm.tmp_CompositeAttribute'', @@ROWCOUNT);' + CHAR(13) + CHAR(13)    
   
	+ 'CREATE NONCLUSTERED INDEX IX_tmp_CompositeAttribute ON  ' + @ClientDB + 'mdm.tmp_CompositeAttribute ([SSB_CRMSYSTEM_CONTACT_ID], AttributeName)' + CHAR(13)   
  

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

----SELECT @SQL;   
   
EXEC sp_executesql @sql   

SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
   
END
GO
