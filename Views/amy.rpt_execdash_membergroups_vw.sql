SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[rpt_execdash_membergroups_vw] as
select yy1.*, cast( cast( (donorcount -lastyearsum) as numeric) / cast(lastyearsum as numeric)*100 as numeric(10,2)) percentchange from (
select yy.*, (select sum(donorcount) from advqadonorgroupbyyear gby1, ADVQAGroup g1 
where gby1.GroupID = g1.GroupID and g1.groupid = yy.groupid and isnull(gby1.ComplimentaryMembership,0) =0
and gby1.memberyear = yy.memberyear-1) lastyearsum
from (
select g.groupid,  g.GroupName,  isnull(gby.ComplimentaryMembership,0)  ComplimentaryMembership,  gby.MemberYear, sum(donorcount) donorcount 
from advqadonorgroupbyyear gby, ADVQAGroup g where gby.GroupID = g.GroupID and g.groupid in (1,2,4,7) and isnull(gby.ComplimentaryMembership,0) =0
and memberyear between year(getdate()) -5 and year(getdate())
group by g.groupid,g.GroupName, isnull(gby.ComplimentaryMembership,0) ,  gby.MemberYear
) yy ) yy1
GO
