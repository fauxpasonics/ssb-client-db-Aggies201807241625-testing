SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--EXEC dba.ScaleToDefaultPriceLevel 'P1'
CREATE PROCEDURE [dba].[ScaleToDefaultPriceLevel]
(
	@DefaultPriceLevel NVARCHAR(25)
)

AS
BEGIN


DECLARE @CurrentPriceLevel NVARCHAR(25), @DefaultEdition NVARCHAR(25), @IsInScaleUpPeriod BIT = 0, @OverrideExpirationDate DATETIME

SET @DefaultEdition = CASE WHEN @DefaultPriceLevel like 'PRS%' THEN 'PREMIUMRS' WHEN @DefaultPriceLevel like 'P%' THEN 'PREMIUM' ELSE 'STANDARD' END

SELECT @CurrentPriceLevel = CONVERT(NVARCHAR(25),DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective'))

PRINT 'Current Price Level: ' + @CurrentPriceLevel

SELECT @OverrideExpirationDate = ISNULL(MAX(ExpirationDateUTC),0) FROM dba.PriceLevelOverridePeriod

IF ( CAST(GETUTCDATE() AS TIME) BETWEEN '04:00' AND '08:00' OR GETUTCDATE() < @OverrideExpirationDate)
BEGIN
	SET @IsInScaleUpPeriod = 1
	PRINT 'During Set Scaled Up Period'
END

IF (@DefaultPriceLevel <> @CurrentPriceLevel AND @IsInScaleUpPeriod = 0)
BEGIN

	PRINT 'Scaling to ' + @DefaultPriceLevel

	DECLARE @SQL NVARCHAR(MAX) = ''
	SET @SQL = 'ALTER DATABASE ' + DB_NAME() + ' MODIFY (EDITION = ''' + @DefaultEdition + ''',	SERVICE_OBJECTIVE = ''' + @DefaultPriceLevel + ''')'

	PRINT @SQL

	EXEC (@SQL)

	PRINT 'Scale Command Successfully Submitted'

END
ELSE BEGIN
	
	PRINT 'Current Setting matches default'
	
END


END
GO
