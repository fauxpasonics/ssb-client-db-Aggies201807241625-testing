SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_execdash_pledge_by_month_actualyear] as
select year(transdate) reportyear, CONVERT(char(2), transdate, 101) reportmonth, case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end GivingType,   sum(transamount + matchamount) amount
from advcontacttransheader h, advcontacttranslineitems li, advprogram p where h.transid = li.transid and li.programid = p.programid
and (li.MatchingGift is null or li.matchinggift = 0)
and transtype like '%Pledge%'
and case when transyear = 'CAP' then cast(year(transdate)as varchar)  else transyear end > cast(year(getdate()) - 5 as varchar)
group by  year(transdate) , CONVERT(char(2), transdate, 101), case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end
GO
