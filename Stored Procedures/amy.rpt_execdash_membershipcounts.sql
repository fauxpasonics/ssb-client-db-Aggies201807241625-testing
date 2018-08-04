SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_membershipcounts] as 
select   levelname,  minamount,  maxamount,
sum(case when Year  = year(getdate()) then YTD_cnt else 0 end)  ThisYear,
sum(case when Year  = year(getdate())-1 then YTD_cnt else 0 end)  LastYear
from rpt_execdash_MembershipCounts_tb
group by  levelname,  minamount,  maxamount
order by minamount
GO
