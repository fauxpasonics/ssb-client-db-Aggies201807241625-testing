SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[CreateAttributes] 
(@clientdb VARCHAR(50), @Attribute varchar(50),  @AttributeGroupId int = 0)

AS
Begin
---DECLARE @clientdb VARCHAR(50)= 'MDM_CLIENT_DEV';
---DECLARE @attributegroupid int = 0;



IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

IF (SELECT @@VERSION) NOT LIKE '%Azure%'
BEGIN
SET @ClientDB = @ClientDB + '.'
END

-- For Response
DECLARE @finalXml XML
DECLARE @SQL NVARCHAR(MAX) = '';
DECLARE @SQL2 NVARCHAR(MAX) = '';
	
	BEGIN TRY

DECLARE @attributeCount INT

set @sql = @sql
+ 'Select @attributeCount = COUNT(*) from ' + @clientdb + 'mdm.attributes where attribute = ''' + @Attribute + ''''

EXEC sp_executesql @sql, N'@attributeCount INT OUT', @attributeCount OUT

If @attributeCount >= 1
Begin

SET @finalXml = '<Root><ResponseInfo><Success>false</Success><ErrorMessage>The attribute name you have entered already exists.</ErrorMessage></ResponseInfo></Root>'


	-- Return response
	SELECT CAST(@finalXml AS XML)

	Return
End

IF @AttributeGroupId = 0 
Begin


	
SET @sql2 = @sql2
	+ ' Insert into  ' + @clientdb + 'mdm.attributes (Attribute, AttributeGroupID) '+ Char(13)
	+ ' values ( ''' + @Attribute + ''', (select attributegroupid from ' + @clientdb + 'mdm.attributegroup where attributegroup = ''DataUploader''));' + Char(13)

End

Else
Begin

	SET @sql2 = @sql2
	+ ' Insert into  ' + @clientdb + 'mdm.attributes (Attribute, AttributeGroupID) '+ Char(13)
	+ ' values ( ' + @Attribute + ', ' + @AttributeGroupId + ');' + Char(13)

End

EXEC sp_executesql @sql2


		SET @finalXml = '<Root><ResponseInfo><Success>true</Success></ResponseInfo></Root>'
		
		

	END TRY


	BEGIN CATCH
	
		-- TODO: Better error messaging here
		DECLARE @errorMessage NVARCHAR(MAX)
		SELECT @errorMessage = ERROR_MESSAGE()

		SET @finalXml = '<Root><ResponseInfo><Success>false</Success><ErrorMessage>There was an error attempting to process this data. ' + @errorMessage + '</ErrorMessage></ResponseInfo></Root>'

	END CATCH


	-- Return response
	SELECT CAST(@finalXml AS XML)

END
GO
