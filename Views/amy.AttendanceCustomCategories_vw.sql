SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[AttendanceCustomCategories_vw] as
select tixeventid, tixeventlookupid, ticketyear, sporttype, categorytitle, categoryamount from 
amy.AttendanceCustomCategories
GO
