SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_CategoryAllocationList]
as
select 999000000+ s.sportid  categoryid, s.SportDesc categoryname --,  s.sporttype Cattype , salloc.ProgramCode  ProgramID,
--salloc.ProgramCode COLLATE DATABASE_DEFAULT ProgramCode, salloc.ProgramName 
from  sport s,   seatarea sa, SeatAllocation salloc where s.SportID = sa.sportid and
sa.SeatAreaID = salloc.SeatAreaID  and isnull(salloc.inactive_ind,0) = 0
GO
