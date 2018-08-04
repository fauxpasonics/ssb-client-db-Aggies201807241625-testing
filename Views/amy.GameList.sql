SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[GameList]
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
	SELECT tixeventid FROM amy.Tennis_Season_CY UNION

	SELECT tixeventid FROM amy.Football_GameList_PY UNION
	SELECT tixeventid FROM amy.Football_GameList_CY UNION
	SELECT tixeventid FROM amy.Baseball_GameList_PY UNION
	SELECT tixeventid FROM amy.Baseball_GameList_CY UNION
	SELECT tixeventid FROM amy.Basketball_Men_GameList_PY UNION
	SELECT tixeventid FROM amy.Basketball_Men_GameList_CY UNION
	SELECT tixeventid FROM amy.Basketball_Women_GameList_PY UNION
	SELECT tixeventid FROM amy.Basketball_Women_GameList_CY UNION
	SELECT tixeventid FROM amy.Tennis_GameList_PY UNION
	SELECT tixeventid FROM amy.Tennis_GameList_CY
GO
