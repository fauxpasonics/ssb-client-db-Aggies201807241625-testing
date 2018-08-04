SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[rpt_execdash_summary_vw] as 
select * from (
select case when transyear = 'CAP' then year(transdate) else transyear end reportyear, 
case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end GivingType, 
sum(case when transtype like '%Receipt%'  then transamount + matchamount else 0 end ) ReceiptAmount, 
  sum(case when transtype like '%Receipt%' and 
     transdate <=  cast (cast( month(getdate()) as varchar) + '/'+ cast( day(getdate()) as varchar) + '/' +  case when transyear = 'CAP' then cast(year(transdate) as varchar) else transyear end  as date)  
     then transamount + matchamount else 0 end) YTDReceiptAmount ,
  sum(case when transtype like '%Pledge%' then transamount + matchamount else 0 end ) PledgeAmount, 
  sum(case when transtype like '%Pledge%' and 
  transdate <=  cast (cast( month(getdate()) as varchar) + '/'+ cast( day(getdate()) as varchar) + '/' +  case when transyear = 'CAP' then cast(year(transdate) as varchar) else transyear end  as date) 
  then transamount + matchamount else 0 end) YTDPledgeAmount 
from advcontacttransheader h, advcontacttranslineitems li, advprogram p where h.transid = li.transid and li.programid = p.programid
and (li.MatchingGift is null or li.matchinggift = 0)
and case when transyear = 'CAP' then cast(year(transdate)as varchar)  else transyear end > cast(year(getdate()) - 5 as varchar)
group by  case when transyear = 'CAP' then year(transdate) else transyear end ,  case when p.CapDriveYear = 1 then 'CAP' else 'Annual' end ) y
GO
