SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Tennis_GameList_CY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort,  e.tixeventstartdate
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid LIKE 'TN16-TN[0-9][0-9]'
GO
