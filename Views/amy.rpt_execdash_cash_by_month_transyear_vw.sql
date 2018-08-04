SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  view [amy].[rpt_execdash_cash_by_month_transyear_vw] as
select transyear reportyear, case when transyear <> 'CAP' and transyear  > cast(year(transdate) as varchar)  then '00'
when transyear <> 'CAP' and transyear < cast(year(transdate) as varchar) then '13' else CONVERT(char(2), transdate, 101) end reportmonth, 
  sum(transamount + matchamount) amount
from advcontacttransheader h, advcontacttranslineitems li, advprogram p where h.transid = li.transid and li.programid = p.programid
and (li.MatchingGift is null or li.matchinggift = 0)
and transtype like '%Receipt%'
and (( transyear <> 'CAP' and transyear  >= cast(year(getdate()) -5 as varchar) ) or  transyear = 'CAP')
group by  transyear  , case when transyear <> 'CAP' and transyear  > cast(year(transdate) as varchar)  then '00'
when  transyear <> 'CAP' and transyear < cast(year(transdate) as varchar) then '13' else CONVERT(char(2), transdate, 101) end
GO
