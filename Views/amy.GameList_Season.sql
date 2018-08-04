SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[GameList_Season]
AS


	SELECT tixeventid FROM amy.Football_Season_PY UNION
	SELECT tixeventid FROM amy.Football_Season_CY UNION
	SELECT tixeventid FROM amy.Baseball_Season_PY UNION
	SELECT tixeventid FROM amy.Baseball_Season_CY UNION
	SELECT tixeventid FROM amy.Basketball_Men_Season_PY UNION
	SELECT tixeventid FROM amy.Basketball_Men_Season_CY UNION
	SELECT tixeventid FROM amy.Basketball_Women_Season_PY UNION
	SELECT tixeventid FROM amy.Basketball_Women_Season_CY UNION
	SELECT tixeventid FROM amy.Tennis_Season_PY UNION
	SELECT tixeventid FROM amy.Tennis_Season_CY
GO
