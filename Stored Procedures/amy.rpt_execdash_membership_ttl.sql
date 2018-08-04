SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_membership_ttl] as
select *, cast(ThisYear as decimal)/cast(LastYear  as decimal) Percentchange from (
select  'Membership' rptmembership,  -- levelname,  minamount,  maxamount,
sum(case when Year  = year(getdate()) then YTD_cnt else 0 end)  ThisYear,
sum(case when Year  = year(getdate())-1 then YTD_cnt else 0 end)  LastYear
from rpt_execdash_MembershipCounts_tb
union 
select  'New Grad' rptmembership,  -- levelname,  minamount,  maxamount,
sum(case when Year  = year(getdate()) then YTD_cnt else 0 end)  ThisYear,
sum(case when Year  = year(getdate())-1 then YTD_cnt else 0 end)  LastYear
from
rpt_execdash_NewGrad_MembershipCounts_tb
union 
select  'Student' rptmembership,  -- levelname,  minamount,  maxamount,
sum(case when Year  = year(getdate()) then YTD_cnt else 0 end)  ThisYear,
sum(case when Year  = year(getdate())-1 then YTD_cnt else 0 end)  LastYear
from
rpt_execdash_Student_MembershipCounts_tb
) t
GO
