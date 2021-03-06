SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Basketball_Women_Season_CY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid = (select pp.tixeventlookupid from PriorityEvents  pp
where ticketyear = 
(select  max(ticketyear) maxyear from PriorityEvents where sporttype = 'BB-WB')
and  sporttype = 'BB-WB')
GO
