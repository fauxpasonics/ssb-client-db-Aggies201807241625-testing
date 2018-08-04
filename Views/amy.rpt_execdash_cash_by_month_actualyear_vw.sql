SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[rpt_execdash_cash_by_month_actualyear_vw] as
--alter procedure amy.rpt_execdash_cash_by_month_actualyear as
select year(transdate) reportyear,-- format(month(transdate),'00') reportmonth, 
CONVERT(char(2), transdate, 101) reportmonth,
CONVERT(char(2), transdate, 101) + '/' +cast(year(transdate) as varchar) rptdt,
case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end GivingType,   sum(transamount + matchamount) amount
from advcontacttransheader h, advcontacttranslineitems li, advprogram p where h.transid = li.transid and li.programid = p.programid
and (li.MatchingGift is null or li.matchinggift = 0)
and transtype like '%Receipt%'
and year(transdate) > year(getdate()) -5
group by  year(transdate) ,CONVERT(char(2), transdate, 101),  
--format(month(transdate),'00')  , 
case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end , 
CONVERT(char(2), transdate, 101) + '/' +cast(year(transdate) as varchar)
GO
