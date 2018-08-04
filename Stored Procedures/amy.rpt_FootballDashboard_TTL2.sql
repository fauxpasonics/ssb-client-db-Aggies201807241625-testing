SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_TTL2] as

declare @currentseason char(4)
declare @tixeventlookupid varchar(20)

set @currentseason = (select max(currentseason) from advcurrentyear)

set  @tixeventlookupid= (select tixeventlookupid from PriorityEvents where ticketyear = @currentseason  and sporttype = 'FB')


select  'Add Ons' RequestType  , sum(addedItems) Quantity from  amy.rpt_seatrecon_tb  t where  sporttype = 'FB' and ticketyear =  @currentseason  and addeditems >0
union all
 select  'New Items' RequestType  , sum(newitems) Quantity from  amy.rpt_seatrecon_tb  t where  sporttype = 'FB' and ticketyear =  @currentseason and newitems >0
GO
