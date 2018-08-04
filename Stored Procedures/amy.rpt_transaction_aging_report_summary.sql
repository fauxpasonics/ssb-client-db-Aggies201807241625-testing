SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_transaction_aging_report_summary] as  
   select transyear, aginggroup, sum(balance) balance from amy.rpt_transaction_aging_vw
group by transyear, aginggroup 
order by aginggroup, transyear
GO
