SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [mdm].[ApplyNameOverride]
(
	@ClientDB VARCHAR(50)
)
AS
BEGIN

	/* mdm.ApplyDimCustomerOverride - Overrides CleanData.io output where customer's name has been incorrectly parsed.
	* created: 9/2/2015 gholder
	* modified: 9/9/2015 gholder - Added suffix
	* modified: 09/17/2015 - Gholder -- Added Azure check for @ClientDB parameter per KWyss
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

	SET @sql = @sql
	+ ' --- update dbo.DimCustomer' + CHAR(13)
	+ ' UPDATE b' + CHAR(13)
	+ ' SET b.Prefix = CASE WHEN ISNULL(a.Prefix,'''') = '''' THEN b.Prefix ELSE a.Prefix END' + CHAR(13)
	+ ' 	, b.FirstName = CASE WHEN ISNULL(a.FirstName,'''') = '''' THEN b.FirstName ELSE a.FirstName END' + CHAR(13)
	+ ' 	, b.MiddleName = CASE WHEN ISNULL(a.MiddleName,'''') = '''' THEN b.MiddleName ELSE a.MiddleName END' + CHAR(13)
	+ ' 	, b.LastName = CASE WHEN ISNULL(a.LastName,'''') = '''' THEN b.LastName ELSE a.LastName END' + CHAR(13)
	+ ' 	, b.Suffix = CASE WHEN ISNULL(a.Suffix,'''') = '''' THEN b.Suffix ELSE a.Suffix END' + CHAR(13)
	+ ' 	, b.Fullname = CASE WHEN ISNULL(a.FullName,'''') = '''' THEN b.FullName ELSE a.FullName END' + CHAR(13)
	+ ' 	, b.CompanyName = CASE WHEN ISNULL(a.CompanyName,'''') = '''' THEN b.CompanyName ELSE a.CompanyName END' + CHAR(13)
	+ ' --SELECT' + CHAR(13)
	+ ' --	CASE WHEN ISNULL(a.Prefix,'''') = '''' THEN b.Prefix ELSE a.Prefix END AS Prefix' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.FirstName,'''') = '''' THEN b.FirstName ELSE a.FirstName END AS FirstName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.MiddleName,'''') = '''' THEN b.MiddleName ELSE a.MiddleName END AS MiddleName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.LastName,'''') = '''' THEN b.LastName ELSE a.LastName END AS LastName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.FullName,'''') = '''' THEN b.FullName ELSE a.FullName END AS FullName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.CompanyName,'''') = '''' THEN b.CompanyName ELSE a.CompanyName END AS CompanyName' + CHAR(13)
	+ ' FROM ' + @ClientDB + 'dbo.Name_Override a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)
	+ ' 	AND a.SourceSystem = b.SourceSystem'
	SET @sql = @sql + CHAR(13) + CHAR(13)

	SET @sql = @sql
	+ ' --- update mdm.compositerecord' + CHAR(13)
	+ ' UPDATE d' + CHAR(13)
	+ ' SET d.Prefix = CASE WHEN ISNULL(a.Prefix,'''') = '''' THEN d.Prefix ELSE a.Prefix END' + CHAR(13)
	+ ' 	, d.FirstName = CASE WHEN ISNULL(a.FirstName,'''') = '''' THEN d.FirstName ELSE a.FirstName END' + CHAR(13)
	+ ' 	, d.MiddleName = CASE WHEN ISNULL(a.MiddleName,'''') = '''' THEN d.MiddleName ELSE a.MiddleName END' + CHAR(13)
	+ ' 	, d.LastName = CASE WHEN ISNULL(a.LastName,'''') = '''' THEN d.LastName ELSE a.LastName END' + CHAR(13)
	+ ' 	, d.Suffix = CASE WHEN ISNULL(a.Suffix,'''') = '''' THEN d.Suffix ELSE a.Suffix END' + CHAR(13)
	+ ' 	, d.Fullname = CASE WHEN ISNULL(a.FullName,'''') = '''' THEN d.FullName ELSE a.FullName END' + CHAR(13)
	+ ' 	, d.CompanyName = CASE WHEN ISNULL(a.CompanyName,'''') = '''' THEN d.CompanyName ELSE a.CompanyName END' + CHAR(13)
	+ ' --SELECT' + CHAR(13)
	+ ' --	CASE WHEN ISNULL(a.Prefix,'''') = '''' THEN d.Prefix ELSE a.Prefix END AS Prefix' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.FirstName,'''') = '''' THEN d.FirstName ELSE a.FirstName END AS FirstName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.MiddleName,'''') = '''' THEN d.MiddleName ELSE a.MiddleName END AS MiddleName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.LastName,'''') = '''' THEN d.LastName ELSE a.LastName END AS LastName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.FullName,'''') = '''' THEN d.FullName ELSE a.FullName END AS FullName' + CHAR(13)
	+ ' --	, CASE WHEN ISNULL(a.CompanyName,'''') = '''' THEN d.CompanyName ELSE a.CompanyName END AS CompanyName' + CHAR(13)
	+ ' FROM ' + @ClientDB + 'dbo.Name_Override a' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.DimCustomer b ON a.SSID = b.SSID' + CHAR(13)
	+ ' 	AND a.SourceSystem = b.SourceSystem' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'dbo.dimcustomerssbid c ON b.DimCustomerId = c.DimCustomerId' + CHAR(13)
	+ ' INNER JOIN ' + @ClientDB + 'mdm.compositerecord d ON c.SSB_CRMSYSTEM_CONTACT_ID = d.SSB_CRMSYSTEM_CONTACT_ID;'

	--SELECT @sql

	EXEC sp_executesql @sql

END
GO
