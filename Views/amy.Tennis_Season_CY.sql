SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [amy].[Tennis_Season_CY]
AS

SELECT e.tixeventid, e.tixeventlookupid, e.tixeventtitleshort
FROM ods.VTXtixevents e
WHERE e.tixeventlookupid = 'TN16-Season'
GO
