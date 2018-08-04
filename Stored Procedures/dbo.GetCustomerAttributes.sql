SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GetCustomerAttributes] 
(@clientdb VARCHAR(50), @dimcustomerid VARCHAR(20), @attributegroup VARCHAR(10))

AS
Begin
---DECLARE @clientdb VARCHAR(50)= 'psp';
---DECLARE @dimcustomerid VARCHAR(20) = '6418383';
---DECLARE @attributegroup VARCHAR(10) = '1';

IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

IF (SELECT @@VERSION) NOT LIKE '%Azure%'
BEGIN
SET @ClientDB = @ClientDB + '.'
END

DECLARE @SQL2 NVARCHAR(MAX) = '';
Declare @FieldList VARCHAR(MAX) = '';

SET @sql2 = @sql2
+ ' SELECT  @FieldList = COALESCE(@FieldList + '' '', '''') + '' attr.value(''''( '' + LOWER(attribute)  + ''/text())[1]'''',  ''''varchar(max)'''') as ''  + attribute + '','' '+ Char(13)
+ ' FROM mdm.attributes ' + Char(13)
+ ' where attributegroupid = ' + @AttributeGroup + Char(13)


EXEC sp_executesql @SQL2
        , N'@FieldList nvarchar(max) OUTPUT'
       , @FieldList OUTPUT	---PRINT @FieldList

DECLARE @SQL nVARCHAR(MAX) = ''

SET @SQL = @SQL

+ ' SELECT dimcustomerid, attributes, ' + CHAR(13)
+ @FieldList
+ '  1 AS attributeGroup '+ CHAR(13)
+ '  FROM '+ @clientdb + 'dbo.dimcustomerattributes '+ CHAR(13)
+ ' CROSS APPLY attributes.nodes(''dimcustomerattributes'') AS Attributes(attr) '+ CHAR(13)
+ ' WHERE dimcustomerid = ' + @dimcustomerid + ' and attributegroupid = ' + @attributegroup+ CHAR(13)

---SELECT @SQL

EXEC sp_executesql @sql

END
GO
