SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_Annual_project_top10_lastYear] as 
select top 10 rank() OVER (ORDER BY receiptamount desc) as rank,   programname, receiptamount from rpt_execdash_proj_summary_vw where GivingType = 'Annual' and reportyear = cast( year(getdate())-1 as varchar)
order by receiptamount desc
GO
