SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[vw_CategoryAllocationList]
as
select 999000000+ s.sportid  categoryid, s.SportDesc categoryname,  s.sporttype Cattype , salloc.ProgramCode  ProgramID,
salloc.ProgramCode COLLATE DATABASE_DEFAULT ProgramCode, salloc.ProgramName 
from  sport s,   seatarea sa, SeatAllocation salloc where s.SportID = sa.sportid and
sa.SeatAreaID = salloc.SeatAreaID  and isnull(salloc.inactive_ind,0) = 0
union 
select 888000001 categoryid, 'Travel' categoryname,  'Travel' Cattype , allocationid  COLLATE DATABASE_DEFAULT  ProgramID   , allocationid COLLATE DATABASE_DEFAULT ProgramCode , [Name] COLLATE DATABASE_DEFAULT  ProgramName 
from allocationlanguage where languagecode = 'en_US'  and [Name] like '%Travel%' COLLATE DATABASE_DEFAULT 
union 
select 777000001 categoryid, '1922 Fund' categoryname,  'CAP1922' Cattype , a.allocationid ProgramID, a.allocationid ProgramCode, [Name] ProgramName 
from allocationlanguage l, allocation a where languagecode = 'en_US'  and l.allocationid = a.allocationid and  allocationgroupid  in ('1922F')
union 
select  778000001 categoryid, '1922 Fund (Past Campaigns)' categoryname,  'CAP1922' Cattype, 
a.allocationid ProgramID, a.allocationid ProgramCode, [Name] ProgramName 
from allocationlanguage l, allocation a where languagecode = 'en_US'  and l.allocationid = a.allocationid and
 a.ALLOCATIONid in ('CAP2-DKCE','CAP2-EN','CAP2-JHE','CAP2-MFEE','CAP2-NYE','CAP2-S&DE','CAP2-S&DETM','CAP3-58JDC','CAP3-EN','CAP3-EQE','CAP3-JBH','CAP3-PTH','CAP3-S&DE','CAP3-TOE',
'CAP3-WE','CAP4-BAE','CAP4-EN','CAP4-HE','CAP4-LE','CAP4-LES','CAP4-NYE','CAP4-PME','CAP4-SD','CAP4-WJBE','CAP5-EN','CAP5-HE','CAP5-SDE','CAP6-ACADEND','CAP6-BPES','CAP6-EN','CAP6-SDE',
'ENDGLD','ENDMT','ENDMW','ENDOWPAULBRYANT','ENDPG')
--from advprogram where --programid in (58,64,66,78,126,128,139,144,153,156,177,178,180,185,186,188,196,200,208,214,216,219,230,234,265,286,294,370,372,399,407,447,500,518,523,524)
union 
select 666000001 categoryid, 'CAP (No PG)' categoryname,  'CAP' Cattype , a.allocationid ProgramID, a.allocationid ProgramCode, [Name] ProgramName 
from allocationlanguage l, allocation a where languagecode = 'en_US'  and l.allocationid = a.allocationid and [Name] not like '%Plan%' and  a.IsAnnualGift =0
union
select 666000002 categoryid, 'CAP (No KFC)' categoryname,  'CAP' Cattype ,  a.allocationid ProgramID, a.allocationid ProgramCode, [Name] ProgramName 
from allocationlanguage l, allocation a where languagecode = 'en_US'  and l.allocationid = a.allocationid and [Name]  like '%CAP%' and  a.IsAnnualGift =0
GO
