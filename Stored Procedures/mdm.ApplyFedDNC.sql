SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [mdm].[ApplyFedDNC]  
(  
	@ClientDB VARCHAR(50)  
)  
 as  
Begin  
  
/* mdm.ApplyFedDNC - Flags Phones that are on the Fed DNC List.  
* created: 4/1/2015 kwyss  
* modified: 09/17/2015 - GHolder -- Added Azure check for @ClientDB parameter per KWyss  
* modified: 11/22/2016 - GHolder -- refactored sproc to optimize for the possibility of large DNC list (e.g. PSP)  
*  
*  
*/  
  
--DECLARE @ClientDB VARCHAR(50) = 'PSP'  
  
IF (SELECT @@VERSION) LIKE '%Azure%'  
BEGIN  
SET @ClientDB = ''  
END  
  
IF (SELECT @@VERSION) NOT LIKE '%Azure%'  
BEGIN  
SET @ClientDB = @ClientDB + '.'  
END  
  
  
  
DECLARE   
	@sql NVARCHAR(MAX) = ' ' + CHAR(13)  
	, @ClientDBLocal NVARCHAR(50) = @ClientDB  
  
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''START'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql
SET @sql = ''
  
SET @sql = @sql  
	+ ' IF OBJECT_ID(''tempdb..#phone'') IS NOT NULL DROP TABLE #phone' + CHAR(13)  
	+ '	' + CHAR(13)  
  
	+ ' CREATE TABLE #phone (' + CHAR(13)  
	+ ' 	DimCustomerId	INT' + CHAR(13)  
	+ ' 	,phonefull		NVARCHAR(25)' + CHAR(13)  
	+ ' 	,areacode		VARCHAR(3)' + CHAR(13)  
	+ ' 	,phone			VARCHAR(7)' + CHAR(13)  
	+ ' 	,dnc			BIT' + CHAR(13)  
	+ ' )' + CHAR(13)  
	+ ' ' + CHAR(13)  
  
	+ ' IF EXISTS (SELECT TOP 1 * FROM ' + @ClientDBLocal + 'mdm.FedDNCList WHERE areacode IS NOT NULL)' + CHAR(13)  
	+ ' BEGIN' + CHAR(13)  
	+ '		INSERT INTO #phone' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhonePrimary as phonefull, CAST(SUBSTRING(a.PhonePrimary,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(PhonePrimary,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhonePrimary,'''') != ''''' + CHAR(13)  
	+ '		UNION' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhoneHome as phonefull, CAST(SUBSTRING(a.PhoneHome,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(PhoneHome,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhoneHome,'''') != ''''' + CHAR(13)  
	+ '		UNION' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhoneCell as phonefull,  CAST(SUBSTRING(a.PhoneCell,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(PhoneCell,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhoneCell,'''') != ''''' + CHAR(13)  
	+ '		UNION' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhoneBusiness as phonefull,  CAST(SUBSTRING(a.PhoneBusiness,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(a.PhoneBusiness,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhoneBusiness,'''') != ''''' + CHAR(13)  
	+ '		UNION' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhoneFax as phonefull,  CAST(SUBSTRING(a.PhoneFax,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(a.PhoneFax,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhoneFax,'''') != ''''' + CHAR(13)  
	+ '		UNION' + CHAR(13)  
	+ '		SELECT a.DimCustomerId, a.PhoneOther as phonefull,  CAST(SUBSTRING(a.PhoneOther,2,3) AS VARCHAR(3)) AS areacode, CAST(REPLACE(SUBSTRING(a.PhoneOther,7,8),''-'','''') AS VARCHAR(7)) AS phone, CAST(NULL AS BIT) AS dnc' + CHAR(13)  
	+ '		FROM ' + @ClientDBLocal + 'dbo.DimCustomer a WITH (NOLOCK)' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND ISNULL(a.PhoneOther,'''') != ''''' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		CREATE CLUSTERED INDEX ix_dimcustomer ON #phone (DimCustomerId)' + CHAR(13)  
	+ '		CREATE NONCLUSTERED INDEX ix_areacode ON #phone (areacode)' + CHAR(13)  
	+ '		CREATE NONCLUSTERED INDEX ix_areacode_phone ON #phone (areacode, phone)' + CHAR(13)  
	+ '		CREATE NONCLUSTERED INDEX ix_phonefull ON #phone (phonefull)' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		IF OBJECT_ID(''tempdb..#distinctphone'') IS NOT NULL DROP TABLE #distinctphone' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		SELECT DISTINCT areacode, phone, dnc' + CHAR(13)  
	+ '		INTO #distinctphone' + CHAR(13)  
	+ '		FROM #phone' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		CREATE CLUSTERED INDEX ix_areacode ON #distinctphone (areacode)' + CHAR(13)  
	+ '		CREATE NONCLUSTERED INDEX ix_areacode_phone ON #distinctphone (areacode, phone)' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		UPDATE a' + CHAR(13)  
	+ '		SET a.dnc = 1' + CHAR(13)  
	+ '		--SELECT COUNT(0)' + CHAR(13)  
	+ '		FROM #distinctphone a' + CHAR(13)  
	+ '		INNER JOIN ' + @ClientDBLocal + 'mdm.FedDNCList b ON a.areacode = b.areacode' + CHAR(13)  
	+ '			AND a.phone = b.phone' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		CREATE NONCLUSTERED INDEX ix_dnc ON #distinctphone (dnc) WHERE dnc = 1' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		UPDATE a' + CHAR(13)  
	+ '		SET a.dnc = b.dnc' + CHAR(13)  
	+ '		--SELECT COUNT(0)' + CHAR(13)  
	+ '		FROM #phone a' + CHAR(13)  
	+ '		INNER JOIN #distinctphone b ON a.areacode = b.areacode' + CHAR(13)  
	+ '			AND a.phone = b.phone' + CHAR(13)  
	+ '		WHERE 1=1' + CHAR(13)  
	+ '		AND b.dnc = 1' + CHAR(13)  
	+ '		' + CHAR(13)  
  
	+ '		CREATE NONCLUSTERED INDEX ix_dnc_include_dimcustomerid_phonefull ON #phone (dnc) INCLUDE (DimCustomerId, phonefull)' + CHAR(13)  
	+ '		' + CHAR(13)  
	+ ' END' + CHAR(13)  
	+ ' ' + CHAR(13)  
  
	---------------------------------  
	-- dbo.DimCustomer  
	---------------------------------  
	-- PhonePrimary  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhonePrimaryDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhonePrimary' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhonePrimaryDNC,0)' + CHAR(13)  
	+ ' ' + CHAR(13)  
  
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Primary Phone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	    
	-- PhoneHome  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneHomeDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneHome' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneHomeDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
  
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Home Phone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	     
	-- PhoneCell   
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneCellDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneCell' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneCellDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Cell Phone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneBusiness  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneBusinessDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneBusiness' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneBusinessDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''BusinessPhone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneFax  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneFaxDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneFax' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneFaxDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Fax Phone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneOther  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneOtherDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'dbo.DimCustomer b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneOther' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneOtherDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Other Phone - Dimcustomer'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	  
	  
	---------------------------------  
	-- mdm.compositerecord  
	---------------------------------  
	+ ' ALTER INDEX [IDX_mdmCompositeRecords_UpdatedDate_ACCTCONTACTIDs] ON ' + @ClientDBLocal + 'mdm.compositerecord DISABLE' + CHAR(13)  
	+ ' ' + CHAR(13)  
	-- PhonePrimary  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhonePrimaryDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhonePrimary' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhonePrimaryDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
  
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Primary Phone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	    
	-- PhoneHome  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneHomeDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneHome' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneHomeDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
  
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Home Phone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	     
	-- PhoneCell   
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneCellDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneCell' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneCellDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Cell Phone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneBusiness  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneBusinessDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneBusiness' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneBusinessDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''BusinessPhone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneFax  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneFaxDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneFax' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneFaxDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Fax Phone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	      
	-- PhoneOther  
	+ '	UPDATE b' + CHAR(13)  
	+ '	SET b.PhoneOtherDNC = ISNULL(a.dnc,0), ' + CHAR(13)  
	+ '		b.UpdatedBy = ''CI'', ' + CHAR(13)  
	+ '		b.UpdatedDate = current_timestamp ' + CHAR(13)  
	+ '	--SELECT COUNT(0)' + CHAR(13)  
	+ '	FROM #phone a' + CHAR(13)  
	+ '	INNER JOIN ' + @ClientDBLocal + 'mdm.compositerecord b ON a.DimCustomerId = b.DimCustomerId' + CHAR(13)  
	+ '	WHERE 1=1' + CHAR(13)  
	+ '	AND a.phonefull = b.PhoneOther' + CHAR(13)  
	+ '	AND ISNULL(a.dnc,0) != ISNULL(b.PhoneOtherDNC,0)' + CHAR(13)  
	+ '	' + CHAR(13)  
	      
	+ ' Insert into ' + @ClientDBLocal + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13)  
	+ ' values (current_timestamp, ''Apply Fed DNC'', ''Other Phone - CompositeRecord'', @@ROWCOUNT);' + CHAR(13)  
	+ ' ' + CHAR(13)  
	+ ' ALTER INDEX [IDX_mdmCompositeRecords_UpdatedDate_ACCTCONTACTIDs] ON ' + @ClientDBLocal + 'mdm.compositerecord REBUILD' + CHAR(13)  
	+ ' ' + CHAR(13)  
  

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

----SELECT @sql  
  
EXEC sp_executesql @sql  
  
SET @sql = ''
	+ 'Insert into '+ @ClientDB + 'mdm.auditlog (logdate, mdm_process, process_step, cnt)' + CHAR(13) 
	+ 'values (current_timestamp, ''' + CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)),'.',QUOTENAME(OBJECT_NAME(@@PROCID))) + ''', ''END'', 0);' + CHAR(13) + CHAR(13)

EXEC sp_executesql @sql

END
GO
