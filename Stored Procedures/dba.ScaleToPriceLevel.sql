SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--EXEC dba.ScaleToPriceLevel 'S1'
CREATE PROCEDURE [dba].[ScaleToPriceLevel]
(
	@PriceLevel NVARCHAR(25)
)

AS
BEGIN


DECLARE @CurrentPriceLevel NVARCHAR(25), @PriceLevelEdition NVARCHAR(25)

SELECT @CurrentPriceLevel = CONVERT(NVARCHAR(25),DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective'))

PRINT 'Current Price Level: ' + @CurrentPriceLevel

IF (@PriceLevel <> @CurrentPriceLevel)
BEGIN

	SET @PriceLevelEdition = CASE WHEN @PriceLevel like 'P%' THEN 'PREMIUM' ELSE 'STANDARD' END

	PRINT 'Scaling to ' + @PriceLevel

	DECLARE @SQL NVARCHAR(MAX) = ''
	SET @SQL = 'ALTER DATABASE ' + DB_NAME() + ' MODIFY (EDITION = ''' + @PriceLevelEdition + ''',	SERVICE_OBJECTIVE = ''' + @PriceLevel + ''')'

	PRINT @SQL

	EXEC (@SQL)

	PRINT 'Scale Command Successfully Submitted'

	INSERT INTO dba.PriceLevelOverridePeriod
	VALUES (@PriceLevel, GETUTCDATE(), DATEADD(MINUTE, 360, GETUTCDATE()))
	
END


END
GO
