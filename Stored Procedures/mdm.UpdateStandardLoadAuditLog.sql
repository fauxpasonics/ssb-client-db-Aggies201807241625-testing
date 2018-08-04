SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [mdm].[UpdateStandardLoadAuditLog] (
	@ClientDB VARCHAR(50)
	,@startDate DATETIME = NULL
)
AS
BEGIN

-- DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_TEST', @startDate DATETIME = NULL

DECLARE @sql NVARCHAR(MAX) = ''

SET @ClientDB = QUOTENAME(REPLACE(LTRIM(RTRIM(@ClientDB)),'.',''))

IF @startDate IS NULL
	SET @startDate = '1/1/1900'

SET @sql = 
	';WITH stdLoadAudit AS (
		SELECT *
			, CASE WHEN process_step IN (''Get Record Count'',''No Records to Load'') THEN 0 WHEN process_step LIKE ''Load Guid%'' THEN 1 ELSE 2 END AS ranking
			, ROW_NUMBER() OVER (ORDER BY logdate DESC, CASE WHEN process_step IN (''Get Record Count'',''No Records to Load'') THEN 0 WHEN process_step LIKE ''Load Guid%'' THEN 1 ELSE 2 END) AS ID
		FROM mdm.auditlog WITH (NOLOCK)
		WHERE (mdm_process = ''Load Dimcustomer''
		AND process_step like ''Load view%'' OR process_step IN (''Get Record Count'',''No Records to Load'') OR process_step LIKE ''Load Guid%'')
		AND logdate >= ''' + CONVERT(VARCHAR, @startDate, 20) + '''
	)
	SELECT a.logdate AS LoadDate, REPLACE(a.process_step,''Load view -'','''') AS LoadView, REPLACE(c.process_step,''Load Guid -'','''') AS LoadGuid, b.cnt AS RecordCount
	INTO #stdLoadAuditLog
	FROM stdLoadAudit a
	INNER JOIN (
		SELECT *
		FROM stdLoadAudit a
		WHERE ranking = 0) b ON b.ID = a.ID - 2
	INNER JOIN (
		SELECT *
		FROM stdLoadAudit a
		WHERE ranking = 1) c ON c.ID = a.ID - 1
	ORDER BY a.logdate ASC

	INSERT INTO audit.StandardLoadAuditLog (LoadDate, LoadView, LoadGuid, RecordCount)
	SELECT a.*
	FROM #stdLoadAuditLog a
	LEFT JOIN audit.StandardLoadAuditLog b ON a.LoadView = b.LoadView
		AND a.LoadGuid = b.LoadGuid
	WHERE b.StandardLoadAuditLogID IS NULL
	ORDER BY a.LoadDate ASC'

SET @sql = 'EXEC ' + CASE WHEN ISNULL(@ClientDB,'') != '' THEN @ClientDB + '..' ELSE '' END + 'sp_executesql N'''+ REPLACE(@sql, '''', '''''') + '''' + CHAR(13)  

--SELECT @sql

EXEC sp_executesql @sql  

END
GO
