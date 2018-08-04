SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[UpdateDimCustomerPrepForCD] 
(
	@ClientDB varchar(50),
	@runmdm int = 1,
	@runfullrefresh int = 0
)
WITH RECOMPILE
as
BEGIN

/*[etl].[UpdateDimCustomerPrepForCD] 
* created: 
* modified:  12/11/2014 - Kwyss -- Procedure was excluding records without a full name from running through clean data.  
*		Removed this exclusion as records without a name are still marketable
* modified:  04/20/2015 - GHolder -- Added @ClientDB parameter and updated sproc to use dynamic SQL
*
*/

----DECLARE @ClientDB VARCHAR(50) = 'Monumental', @runfullrefresh int = 0, @runmdm int = 1

IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

DECLARE 
	@sql NVARCHAR(MAX) = ' '
	,@sql_tmp NVARCHAR(MAX) = ''
	,@missing_override_cnt INT = 0

IF OBJECT_ID('tempdb..#tmpA') IS NOT NULL
	DROP TABLE #tmpA

IF OBJECT_ID('tempdb..#tmp_missing_overrides') IS NOT NULL
	DROP TABLE #tmp_missing_overrides

CREATE TABLE #tmp_missing_overrides (DimCustomerID INT, ElementID INT)

SET @sql = ''
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''

If @runfullrefresh = 1
Begin
set @sql = @sql 
+ ' Update ' + @ClientDB + '.dbo.dimcustomer ' + CHAR(13)
+ ' Set NameIsCleanStatus = ''dirty'' ' + CHAR(13)
+ ' Where isnull(isdeleted, 0) = 0 ' + CHAR(13)

	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Full Refresh - Set Records to Dirty'', @@ROWCOUNT);'
End


If @runmdm = 1 
Begin

set @sql = @sql 


	+'IF OBJECT_ID(''tempdb..#TmpA'') IS NOT NULL' + CHAR(13)
	+'DROP TABLE #TmpA;' + CHAR(13)

		+'IF OBJECT_ID(''tempdb..#TmpDelete1'') IS NOT NULL' + CHAR(13)
	+'DROP TABLE #TmpDelete1;' + CHAR(13)

+ 'SELECT a.dimcustomerid, a.ssid, a.sourcesystem, a.isdeleted, b.ssid AS b_ssid, b.sourcesystem AS b_sourcesystem' + CHAR(13)
+ ' INTO #TmpA' + CHAR(13)
+ ' FROM ' + @ClientDB + '.dbo.dimcustomer a WITH (NOLOCK) ' + CHAR(13)
+ ' INNER JOIN ' + @ClientDB + '.dbo.dimcustomerssbid b WITH (NOLOCK)' + CHAR(13) 
+ ' ON a.dimcustomerid = b.dimcustomerid;' + CHAR(13)
 
+ ' SELECT dimcustomerid' + CHAR(13)
+ ' INTO #tmpDelete1' + CHAR(13)
+ ' FROM #TmpA' + CHAR(13)
+ ' WHERE isdeleted = 1' + CHAR(13) 
+ ' OR ssid != b_ssid' + CHAR(13) 
+ ' OR sourcesystem != b_sourcesystem;' + CHAR(13)

+ ' CREATE CLUSTERED INDEX ix_tmpDelete1 ON #tmpDelete1(dimcustomerid);' + CHAR(13)

+ ' DELETE a' + CHAR(13)
+ ' FROM ' + @ClientDB + '.dbo.dimcustomerssbid a' + CHAR(13)
+ ' INNER JOIN #tmpDelete1 b' + CHAR(13)
+ ' ON a.dimcustomerid = b.dimcustomerid;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Remove deleted/out-sync records'', @@ROWCOUNT);' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)


	+'IF OBJECT_ID(''tempdb..#TmpB'') IS NOT NULL' + CHAR(13)
	+'DROP TABLE #TmpB;' + CHAR(13)

+ 'SELECT a.dimcustomerid ' + CHAR(13)
+ 'INTO #tmpB' + CHAR(13)
+ 'FROM ' + @ClientDB + '.dbo.dimcustomerssbid a WITH (NOLOCK)' + CHAR(13)
+ 'left join ' + @ClientDB + '.dbo.dimcustomer b WITH (NOLOCK)' + CHAR(13)
+ 'on a.dimcustomerid = b.dimcustomerid ' + CHAR(13)
+ 'where b.dimcustomerid is null ' + CHAR(13)

+ ' CREATE CLUSTERED INDEX ix_tmpB ON #tmpB(dimcustomerid);' + CHAR(13)

+ ' DELETE a' + CHAR(13)
+ ' FROM ' + @ClientDB + '.dbo.dimcustomerssbid a' + CHAR(13)
+ ' INNER JOIN #tmpB b' + CHAR(13)
+ ' ON a.dimcustomerid = b.dimcustomerid;' + CHAR(13) 

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Remove Hard-Delete records'', @@ROWCOUNT);'  + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)

/*Set Any Records NOT in DIMCUSTOMERSSBID to DIRTY*/
SET @sql = @sql 

	+'IF OBJECT_ID(''tempdb..#TmpC'') IS NOT NULL' + CHAR(13)
	+'DROP TABLE #TmpC;' + CHAR(13)


+ ' SELECT a.dimcustomerid' + CHAR(13)
+ 'INTO #tmpC' + CHAR(13)
+ 'FROM ' + @ClientDB + '.dbo.dimcustomer a' + CHAR(13)
+ '	LEFT JOIN ' + @ClientDB + '.dbo.dimcustomerssbid b' + CHAR(13)
+ '	ON a.dimcustomerid = b.DimCustomerId' + CHAR(13)
+ '	WHERE b.dimcustomerid IS NULL and a.isdeleted = 0;' + CHAR(13)

+ ' CREATE CLUSTERED INDEX ix_tmpC ON #tmpC(dimcustomerid);' + CHAR(13)

	+ 'UPDATE a' + CHAR(13)
	+ 'SET AddressPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ', NameIsCleanStatus = ''dirty''' + CHAR(13)
	+ ', CompanyNameIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ', EmailPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ ', PhonePrimaryISCleanStatus = ''Dirty''' + CHAR(13)
	+ '	FROM ' + @ClientDB + '.dbo.dimcustomer a' + CHAR(13)
	+ '	INNER JOIN #tmpC b' + CHAR(13)
	+ '	ON a.dimcustomerid = b.dimcustomerid;' + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Records not in dimcustomerssbid'', @@ROWCOUNT);' + CHAR(13)
SET @sql = @sql + CHAR(13) + CHAR(13)


/*reset records that went through clean data but not recognition*/
SET @SQL = @SQL 
	+'IF OBJECT_ID(''tempdb..#tmp_cdio'') IS NOT NULL' + CHAR(13)
	+'DROP TABLE #tmp_cdio' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'SELECT sourcecontactid, input_sourcesystem, MAX(etl_createddate) AS max_cdio_date' + CHAR(13)
+'INTO #Tmp_CDIO' + CHAR(13)
+'FROM ' + @ClientDB + '.archive.CleanDataOutput' + CHAR(13)
+'WHERE input_custom2 = ''contact''' + CHAR(13)
+'GROUP BY sourcecontactid, input_sourcesystem;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'CREATE CLUSTERED INDEX ix_tmp_cdio ON #tmp_cdio([sourcecontactid],[input_sourcesystem]);' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'CREATE NONCLUSTERED INDEX tmp_cdio_date ' + CHAR(13)
+'ON #Tmp_CDIO([max_cdio_date]) ' + CHAR(13)
+'INCLUDE ([sourcecontactid],[input_sourcesystem]) ' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'IF OBJECT_ID(''tempdb..#tmp_rec'') IS NOT NULL' + CHAR(13)
+'	DROP TABLE #tmp_rec' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'SELECT ssid, sourcesystem, MAX(updateddate) AS max_rec_date' + CHAR(13)
+'INTO #Tmp_Rec' + CHAR(13)
+'FROM ' + @ClientDB + '.dbo.dimcustomerssbid ' + CHAR(13)
+'GROUP BY ssid, sourcesystem;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'CREATE CLUSTERED INDEX ix_tmp_rec ON #tmp_rec(ssid, sourcesystem);' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'CREATE NONCLUSTERED INDEX tmp_rec_date ' + CHAR(13)
+'ON #Tmp_Rec([max_rec_date]) ' + CHAR(13)
+'INCLUDE ([ssid],[sourcesystem]) ' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'IF OBJECT_ID(''tempdb..#tmp_reset'') IS NOT NULL' + CHAR(13)
+'	DROP TABLE #tmp_reset' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'SELECT ssid, sourcesystem, max_cdio_date, max_rec_date' + CHAR(13)
+'INTO #Tmp_reset' + CHAR(13)
+'FROM #tmp_rec a' + CHAR(13)
+'INNER join #tmp_cdio b' + CHAR(13)
+'ON a.ssid = b.sourcecontactid AND a.sourcesystem = b.input_sourcesystem' + CHAR(13)
+'WHERE max_cdio_date > max_rec_date;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'CREATE CLUSTERED INDEX ix_tmp_reset ON #tmp_reset(ssid, sourcesystem);' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)
+'UPDATE a' + CHAR(13)
+'SET nameiscleanstatus = ''dirty''' + CHAR(13)
+'FROM ' + @ClientDB + '.dbo.dimcustomer a' + CHAR(13)
+'INNER JOIN #tmp_reset b' + CHAR(13)
+'ON a.ssid = b.ssid AND a.sourcesystem = b.sourcesystem;' + CHAR(13)

SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Records cleaned but no Rec'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

END

/* Missing Overrides*/
SET @sql_tmp = @sql_tmp
+ ' IF OBJECT_ID(''tempdb..#tmp_element'') IS NOT NULL' + CHAR(13)
+ ' 	DROP TABLE #tmp_element' + CHAR(13) + CHAR(13)

+ ' SELECT *' + CHAR(13)
+ ' INTO #tmp_element' + CHAR(13)
+ ' FROM ' + @ClientDB + '.mdm.Element' + CHAR(13)
+ ' WHERE 1=1' + CHAR(13)
+ ' AND ElementType = ''Standard''' + CHAR(13)
+ ' AND ElementIsCleanField IS NOT NULL' + CHAR(13) + CHAR(13)

+ ' INSERT INTO #tmp_missing_overrides' + CHAR(13)
+ ' SELECT DISTINCT a.DimCustomerID, a.ElementID--, b.ElementIsCleanField' + CHAR(13)
+ ' FROM (' + CHAR(13)
+ ' 	SELECT DISTINCT a.DimCustomerID, a.ElementID' + CHAR(13)
+ ' 	FROM ' + @ClientDB + '.mdm.overrides a' + CHAR(13)
+ ' 	INNER JOIN ' + @ClientDB + '.dbo.DimCustomer b ON a.DimCustomerID = b.DimCustomerId' + CHAR(13)
+ ' 	LEFT JOIN ' + @ClientDB + '.dbo.CD_DimCustomer c ON b.SSID = c.SSID' + CHAR(13)
+ ' 		AND b.SourceSystem = c.SourceSystem' + CHAR(13)
+ ' 	WHERE 1=1' + CHAR(13)
+ ' 	AND ISNULL(b.IsDeleted,0) = 0' + CHAR(13)
+ ' 	AND c.SSID IS NULL' + CHAR(13)
+ ' ) a, #tmp_element' + CHAR(13) + CHAR(13)

SET @sql_tmp = @sql_tmp
+ ' SET @sql_tmp = ''''' + CHAR(13)
+ ' SELECT @sql_tmp = @sql_tmp + CHAR(13) +''UPDATE b SET '' + b.ElementIsCleanField + '' = ''''Dirty'''' FROM #tmp_missing_overrides a INNER JOIN ' + @ClientDB + '.dbo.DimCustomer b on a.DimCustomerID = b.DimCustomerID WHERE a.ElementID = '' + CAST(b.ElementID AS VARCHAR(5)) + CHAR(13) + ''SET @missing_override_cnt = @missing_override_cnt + @@ROWCOUNT''' + CHAR(13)
+ ' FROM #tmp_missing_overrides a' + CHAR(13)
+ ' INNER JOIN #tmp_element b ON a.ElementID = b.ElementID' + CHAR(13) + CHAR(13)

+ ' SET @sql_tmp = @sql_tmp + CHAR(13) + CHAR(13)' + CHAR(13)
+ ' + ''Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
+ ' values (current_timestamp, ''''UpdateDimCustomerPrepForCD'''', ''''Overrides not in CD_DimCustomer'''', @missing_override_cnt);'''

EXEC sys.sp_executesql @sql_tmp, N'@sql_tmp NVARCHAR(MAX) OUTPUT', @sql_tmp = @sql_tmp OUTPUT

SELECT @sql = @sql + CHAR(13) + CHAR(13) + @sql_tmp + CHAR(13) + CHAR(13)

/*Set Any Records with null clean status to dirty*/
SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET NameIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and NameIsCleanStatus is null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''NameIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET CompanyNameIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and CompanyNameIsCleanStatus is null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''CompanyNameIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET AddressPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and AddressPrimaryIsCleanStatus is null and addressprimarycity is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''AddressPrimaryIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET AddressOneIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and AddressOneIsCleanStatus is null and addressOnecity is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''AddressOneIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET AddressTwoIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and AddressTwoIsCleanStatus is null and addresstwocity is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''AddressTwoIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET AddressThreeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and AddressThreeIsCleanStatus is null and addressthreecity is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''AddressthreeIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET AddressFourIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and AddressFourIsCleanStatus is null and addressfourcity is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''AddressFourIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET EmailPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and EmailPrimaryIsCleanStatus is null and EmailPrimary is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''EmailPrimaryIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET EmailOneIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and EmailOneIsCleanStatus is null and EmailOne is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''EmailOneIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET EmailTwoIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and EmailTwoIsCleanStatus is null and EmailTwo is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''EmailTwoIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhonePrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhonePrimaryIsCleanStatus is null and PhonePrimary is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhonePrimaryIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhoneHomeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhoneHomeIsCleanStatus is null and PhoneHome is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhoneHomeIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhoneCellIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhoneCellIsCleanStatus is null and PhoneCell is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhoneCellIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhoneBusinessIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhoneBusinessIsCleanStatus is null and PhoneBusiness is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhoneBusinessIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhoneFaxIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhoneFaxIsCleanStatus is null and PhoneFax is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhoneFaxIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer' + CHAR(13)
	+ 'SET PhoneOtherIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'WHERE isdeleted = 0 and PhoneOtherIsCleanStatus is null and PhoneOther is not null' + CHAR(13)
	+ ';'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''PhoneOtherIsCleanStatus is Null'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

/******************
** Address
*******************/
SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer ' + CHAR(13)
	+ 'SET AddressPrimaryIsCleanStatus = ''Bad''' + CHAR(13)
	+ 'WHERE AddressPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (AddressPrimaryStreet IS NULL OR RTRIM(AddressPrimaryStreet) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Bad Primary Address'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)


SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET AddressOneIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE AddressOneIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (AddressOneStreet IS NULL OR RTRIM(AddressOneStreet) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Address One'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET AddressTwoIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE AddressTwoIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (AddressTwoStreet IS NULL OR RTRIM(AddressTwoStreet) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Address Two'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET AddressThreeIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE AddressThreeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (AddressThreeStreet IS NULL OR RTRIM(AddressThreeStreet) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Address Three'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET AddressFourIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE AddressFourIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (AddressFourStreet IS NULL OR RTRIM(AddressFourStreet) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Address Four'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

/******************
** Phone
*******************/
SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhonePrimaryIsCleanStatus = ''Bad''' + CHAR(13)
	+ 'WHERE PhonePrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (PhonePrimary IS NULL OR RTRIM(PhonePrimary) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Bad Primary Phone'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhoneHomeIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE PhoneHomeIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (PhoneHome IS NULL OR RTRIM(PhoneHome) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Phone Home'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
	+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhoneCellIsCleanStatus = ''N/A''' + CHAR(13)
	+ 'WHERE PhoneCellIsCleanStatus = ''Dirty''' + CHAR(13)
	+ 'AND (PhoneCell IS NULL OR RTRIM(PhoneCell) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Phone Cell'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhoneBusinessIsCleanStatus = ''N/A''' + CHAR(13)
+ 'WHERE PhoneBusinessIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (PhoneBusiness IS NULL OR RTRIM(PhoneBusiness) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Phone Business'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhoneFaxIsCleanStatus = ''N/A''' + CHAR(13)
+ 'WHERE PhoneFaxIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (PhoneFax IS NULL OR RTRIM(PhoneFax) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Phone Fax'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET PhoneOtherIsCleanStatus = ''N/A''' + CHAR(13)
+ 'WHERE PhoneOtherIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (PhoneOther IS NULL OR RTRIM(PhoneOther) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Phone Other'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

/******************
** Email
*******************/
SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer ' + CHAR(13)
+ 'SET EmailPrimaryIsCleanStatus = ''Bad''' + CHAR(13)
+ 'WHERE EmailPrimaryIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (EmailPrimary IS NULL OR RTRIM(EmailPrimary) = '''');' 
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''Bad Email Primary'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET EmailOneIsCleanStatus = ''N/A''' + CHAR(13)
+ 'WHERE EmailOneIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (EmailOne IS NULL OR RTRIM(EmailOne) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Email One'', @@ROWCOUNT);'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql
+ 'UPDATE ' + @ClientDB + '.dbo.DimCustomer SET EmailTwoIsCleanStatus = ''N/A''' + CHAR(13)
+ 'WHERE EmailTwoIsCleanStatus = ''Dirty''' + CHAR(13)
+ 'AND (EmailTwo IS NULL OR RTRIM(EmailTwo) = '''');'
SET @sql = @sql + CHAR(13) + CHAR(13)

SET @sql = @sql 
	+ 'Insert into ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)
	+ 'values (current_timestamp, ''UpdateDimCustomerPrepForCD'', ''No Email Two'', @@ROWCOUNT);'
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
     
	+ '		INSERT INTO ' + @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)      
	+ '		VALUES (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''ERROR - '' + @ErrorMessage + '''', 0);' + CHAR(13) + CHAR(13)     
     
	+ '		RAISERROR (@ErrorMessage, -- Message text.' + CHAR(13)     
	+ '             @ErrorSeverity, -- Severity.' + CHAR(13)     
	+ '             @ErrorState -- State.' + CHAR(13)     
	+ '             );' + CHAR(13)     
	+ ' END CATCH' + CHAR(13) + CHAR(13) 

---SELECT @sql

EXEC sp_executesql @sql, N'@missing_override_cnt INT', @missing_override_cnt = @missing_override_cnt

SET @sql = ''
	+ 'Insert into '+ @ClientDB + '.mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
