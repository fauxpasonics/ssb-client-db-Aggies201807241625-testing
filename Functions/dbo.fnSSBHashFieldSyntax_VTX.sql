SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE FUNCTION [dbo].[fnSSBHashFieldSyntax_VTX] 
(
	@schemaName VARCHAR(50),
	@tblName AS VARCHAR(50), 
	@fldToExclude AS VARCHAR(50) = '', 
	@fldToExclude2 AS VARCHAR(50) = '',
	@fldToExclude3 AS VARCHAR(50) = '',
	@fldToExclude4 AS VARCHAR(50) = '',
	@fldToExclude5 AS VARCHAR(50) = '',
	@fldToExclude6 AS VARCHAR(50) = ''
)
RETURNS @HashTable TABLE
	(
		DeltaHashKeyString NVARCHAR(MAX)
	)

AS 
BEGIN

DECLARE @sqlString AS VARCHAR(MAX)
DECLARE @p_schema_name  AS VARCHAR(100)
DECLARE @p_table_name AS VARCHAR(100)
DECLARE @ColumnCount INT = 0


SET @sqlString = ''
SET @p_schema_name = @schemaName
SET @p_table_name = @tblName


SELECT @sqlString = @sqlString +
CASE DATA_TYPE 
WHEN 'int' THEN 'ISNULL(RTRIM(CONVERT(varchar(10), [' + COLUMN_NAME +		'])),''DBNULL_INT'')'
WHEN 'smallint' THEN 'ISNULL(RTRIM(CONVERT(varchar(10), [' + COLUMN_NAME +		'])),''DBNULL_INT'')'
WHEN 'bigint' THEN 'ISNULL(RTRIM(CONVERT(varchar(17), [' + COLUMN_NAME +    '])),''DBNULL_BIGINT'')'
WHEN 'datetime' THEN 'ISNULL(RTRIM(CONVERT(varchar(30), [' + COLUMN_NAME +  '])),''DBNULL_DATETIME'')'  
WHEN 'datetime2' THEN 'ISNULL(RTRIM(CONVERT(varchar(30), [' + COLUMN_NAME + '])),''DBNULL_DATETIME'')'
WHEN 'date' THEN 'ISNULL(RTRIM(CONVERT(varchar(11), [' + COLUMN_NAME +      '],112)),''DBNULL_DATE'')' 
WHEN 'bit' THEN 'ISNULL(RTRIM(CONVERT(varchar(10), [' + COLUMN_NAME +       '])),''DBNULL_BIT'')'  
WHEN 'decimal' THEN 'ISNULL(RTRIM(CONVERT(varchar(50), ['+ COLUMN_NAME +    '])),''DBNULL_NUMBER'')' 
WHEN 'numeric' THEN 'ISNULL(RTRIM(CONVERT(varchar(50), ['+ COLUMN_NAME +    '])),''DBNULL_NUMBER'')' 
ELSE 'ISNULL(RTRIM( [' + COLUMN_NAME + ']),''DBNULL_TEXT'')'
END + ' + '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @p_schema_name AND TABLE_NAME = @p_table_name
AND COLUMN_NAME NOT IN (@fldToExclude,@fldToExclude2,@fldToExclude3,@fldToExclude4,@fldToExclude5,@fldToExclude6)
AND COLUMN_NAME NOT IN ('CreatedDate', 'UpdatedDate','CreatedBy', 'UpdatedBy', 'DeltaHashKey', 'IsDeleted', 'DeleteDate', 'SSCreatedBy', 'SSCreatedDate', 'LoadControlId')
AND COLUMN_NAME <> TABLE_NAME + 'Id'
ORDER BY COLUMN_NAME

SELECT @ColumnCount = COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @p_schema_name AND TABLE_NAME = @p_table_name
AND COLUMN_NAME NOT IN (@fldToExclude,@fldToExclude2,@fldToExclude3,@fldToExclude4,@fldToExclude5,@fldToExclude6)
AND COLUMN_NAME NOT IN ('CreatedDate', 'UpdatedDate','CreatedBy', 'UpdatedBy', 'DeltaHashKey', 'IsDeleted', 'DeleteDate', 'LoadControlId')
AND COLUMN_NAME <> TABLE_NAME + 'Id'

--select @sqlString
INSERT INTO @HashTable
        ( DeltaHashKeyString )
SELECT 'HASHBYTES(''sha2_256'', ' + LEFT(@sqlString, (LEN(@sqlString) - 2)) + ') ETL_DeltaHashKey' ETL_DeltaHashKey

RETURN
END
GO
