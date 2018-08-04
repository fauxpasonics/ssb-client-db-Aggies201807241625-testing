SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure  [amy].[rpt_execdash_calendar_year] as
select   cast(reportyear as varchar) rpt, 
sum(case when givingtype ='Annual' then  amount  else 0 end) Annual,
sum(case when givingtype ='CAP' then  amount  else 0 end) CAP,
sum(case when givingtype ='Annual' and  v.reportmonth <= CONVERT(char(2),getdate(), 101) then  amount  else 0 end) AnnualToDate,
sum(case when givingtype ='CAP'  and  v.reportmonth <= CONVERT(char(2),getdate(), 101)then  amount  else 0 end) CAPToDate, 
sum(  amount  ) Total,
sum(case when  v.reportmonth <= CONVERT(char(2),getdate(), 101) then  amount  else 0 end) TotalToDate
from amy.rpt_execdash_cash_by_month_actualyear_vw v
group by cast(reportyear as varchar)
order by cast(reportyear as varchar)
GO
