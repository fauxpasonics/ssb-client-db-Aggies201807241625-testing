SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure  [amy].[rpt_execdash_transyear] as
select   cast(reportyear as varchar) rpt, 
sum(  amount  ) Total,
sum(case when  v.reportmonth <= CONVERT(char(2),getdate(), 101) then  amount  else 0 end) TotalToDate
from amy.rpt_execdash_cash_by_month_transyear_vw  v
where --  v.reportmonth <= CONVERT(char(2),getdate(), 101)
--cast(reportyear as varchar) <> 'CAP' 
--and
(reportyear <= cast (year(getdate()) + 2 as varchar) or cast(reportyear as varchar) = 'CAP' )
group by cast(reportyear as varchar)
order by cast(reportyear as varchar)
GO
