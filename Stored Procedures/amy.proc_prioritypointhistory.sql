SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[proc_prioritypointhistory]  as
Declare @maxentrydate date

begin
set @maxentrydate = (select  max(EntryDate) maxentrydate   FROM  ADVHistoricalPriorityPoints)

delete from amy.ADVContactPointsSummaryHistory where entrydate = (select  max(EntryDate) maxentrydate   FROM  ADVHistoricalPriorityPoints)  --@maxentrydate 

insert into ADVContactPointsSummaryHistory  (contactid, entrydate, cash_basis_ppts, linked_ppts_given_up, linked_ppts, Rank, Points_values, updatedate)
select contactid, entrydate, cash_basis_ppts, linked_ppts_given_up, linked_ppts, Rank, Points_values, getdate() 
from (
SELECT  
  ss1.contactid, entrydate, SS1.cash_basis_ppts, SS1.linked_ppts_given_up, SS1.linked_ppts, SS1.[Rank],
   STUFF((SELECT '; ' + SS.Description +  ' (' +  cast ( Points as varchar) +  ' / ' + cast ( Value as varchar) + ')'
          FROM ADVHistoricalPriorityPoints HP,  ADVContactPointsSummary SS WHERE  HP.CONTACTID = SS.CONTACTID 
          and ss1.contactid = ss.contactid
                  AND ENTRYDATE =  (select  max(EntryDate) maxentrydate   FROM  ADVHistoricalPriorityPoints)  --@maxentrydate
          FOR XML PATH('')), 1, 1, '') [Points_values]
  FROM ADVHistoricalPriorityPoints SS1 WHERE ENTRYDATE  =  (select  max(EntryDate) maxentrydate   FROM  ADVHistoricalPriorityPoints) --@maxentrydate
  ) t where rank is not null


end
GO
