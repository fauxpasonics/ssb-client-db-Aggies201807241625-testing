SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_2] as 
declare @currentseason char(4)
declare @tixeventlookupid varchar(20)

set @currentseason = (select max(currentseason) from advcurrentyear)
select @tixeventlookupid = tixeventlookupid from PriorityEvents  where sporttype ='FB' and ticketyear =@currentseason


 select s.seatregionname, 
round(cast( renewedtickets as float)/cast( alltickets as float) *100,0)  percentrenewed,
round(cast( renewedtickets as float)/cast( alltickets as float)  *100,0)  [Annual Received],
round(cast( renewedtickets as float)/cast( alltickets as float) * 100,0) [Planned Receipts], 
100 TTL
 from (
 select sectiongroup  seatregionname, 
 count(  case when  renewal_ticket =1 and u.renewal_complete = 1  then   sh.tixseatid else null end  )  renewedtickets, 
  count(  case when  renewal_ticket =1 and isnull(sh.relocation_release_ind,0) =0 then   sh.tixseatid else null end  )  alltickets
  from   amy.seatdetail_individual_history sh
  join  seatregion sr  on sh.seatregionid = sr.SeatRegionID
 left join 
  amy.rpt_seatrecon_tb u on u.TixEventLookupID = sh.tixeventlookupid and cast(sh.accountnumber as int) =  u.adnumber
where sh.tixeventlookupid = @tixeventlookupid and sr.sectiongroup  not in ( 'New Seat','Student','Pressbox')
  group by sectiongroup 
   ) s order by seatregionname desc
GO
