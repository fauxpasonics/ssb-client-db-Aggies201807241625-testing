SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Baseball_GameList_PY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort,  e.tixeventstartdate
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid LIKE 'BS' + cast ((select substring(max(ticketyear),3,2)-1  from PriorityEvents where sporttype = 'BSB') as varchar)+  '-BS[0-9][0-9]'
AND e.venueestablishmentkey = 13
GO
