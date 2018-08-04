SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Football_Season_PY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid  = (select pp.tixeventlookupid from PriorityEvents  pp
where ticketyear = 
(select  max(ticketyear)-1 maxyear from PriorityEvents where sporttype = 'FB')
and  sporttype = 'FB')
AND e.venueestablishmentkey = 16
GO
