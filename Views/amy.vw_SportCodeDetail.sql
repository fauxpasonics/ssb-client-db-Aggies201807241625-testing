SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [amy].[vw_SportCodeDetail]
AS 
SELECT sc.*, 
	sc.SportCode+CAST(sc.CurrentSeason_TwoDigit AS VARCHAR(2))+'-'+(CASE WHEN sc.GenderCode IS NULL THEN 'Season' ELSE sc.GenderCode+sc.SportCode END) AS CurSeason,
	sc.SportCode+CAST(sc.PriorSeason_TwoDigit AS VARCHAR(2))+'-'+(CASE WHEN sc.GenderCode IS NULL THEN 'Season' ELSE sc.GenderCode+sc.SportCode END) AS PriorSeason,
	sc.SportCode+CAST(sc.CurrentSeason_TwoDigit AS VARCHAR(2))+'-'+(CASE WHEN sc.GenderCode IS NULL THEN sc.SportCode ELSE sc.GenderCode+sc.SportCode END) AS CurSeasonGamePrefix,
	sc.SportCode+CAST(sc.PriorSeason_TwoDigit AS VARCHAR(2))+'-'+(CASE WHEN sc.GenderCode IS NULL THEN sc.SportCode ELSE sc.GenderCode+sc.SportCode END) AS PriorSeasonGamePrefix
FROM amy.SportCodes sc
GO
