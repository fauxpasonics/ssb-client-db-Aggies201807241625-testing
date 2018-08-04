SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Basketball_Men_GameList_CY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort,  e.tixeventstartdate
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid LIKE 'B' + cast ((select substring(max(ticketyear),3,2)   from PriorityEvents where sporttype = 'BB-MB') as varchar)+  '-MB[0-9][0-9]'
AND e.tixeventtitleshort NOT LIKE  '% at %'
AND e.tixeventtitleshort NOT LIKE  '% @ %'
AND e.venueestablishmentkey = 12
GO
