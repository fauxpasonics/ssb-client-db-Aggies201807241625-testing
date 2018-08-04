SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_matching_aging_report_detail] as  
  select adnumber, accountname, transdate, transyear, programname, aginggroup, agedate, balance,  runningpledgetotal, runningreceipttotal, pledgetotal, receipttotal 
  from amy.rpt_matching_aging_vw t
order by aginggroup, transyear, adnumber, transdate, programid
GO
