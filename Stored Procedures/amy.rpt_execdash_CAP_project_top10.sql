SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_CAP_project_top10] as 
select * from 
(select top 10   rank() OVER (ORDER BY s1.receiptamount desc) as rank,  s1.programname, s1.receiptamount 
from rpt_execdash_proj_summary_vw s1 where s1.GivingType = 'CAP' and s1.reportyear = cast( year(getdate()) as varchar) ) a, 
(select top 10   rank() OVER (ORDER BY s2.receiptamount desc) as ranklastyear,  s2.programname programlastyear, s2.receiptamount receiptamountlastyear 
from rpt_execdash_proj_summary_vw s2 where s2.GivingType = 'CAP' and s2.reportyear = cast( year(getdate())-1 as varchar)) b
where rank = ranklastyear
order by receiptamount desc
GO
