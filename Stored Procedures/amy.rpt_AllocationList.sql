SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_AllocationList]
as
select a.allocationid programid, 
l.allocationid + ' - ' + l.[Name] COLLATE DATABASE_DEFAULT programname_long,
a.allocationid programcode,
l.[Name] programname 
from allocationlanguage l, allocation a where languagecode = 'en_US'  and l.allocationid = a.allocationid  -- COLLATE DATABASE_DEFAULT
order by l.[Name]
GO
