SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_RefreshFBonly]
AS


declare @percentdue decimal
Declare @tixeventlookupid varchar(50)
Declare @pasttixeventlookupid varchar(50)

declare tixcursor CURSOR LOCAL FAST_FORWARD FOR  -- select tixeventlookupid from amy.priorityevents u  where u.LoadDateExpired is null  and loadstartdate < getdate();
select u.tixeventlookupid,  uhist.tixeventlookupid pasttixeventlookupid 
from amy.priorityevents u left join 
amy.priorityevents uhist on u.sporttype = uhist.sporttype and u.ticketyear = uhist.ticketyear+1
where u.LoadDateExpired is null  and u.loadstartdate < getdate() and u.sporttype = 'FB'
union
select u.pktixeventlookupid,  uhist.pktixeventlookupid pasttixeventlookupid 
from amy.priorityevents u left join 
amy.priorityevents uhist on u.sporttype = uhist.sporttype and u.ticketyear = uhist.ticketyear+1
where u.LoadDateExpired is null  and u.loadstartdate < getdate() and  u.pktixeventlookupid is not null and u.sporttype = 'FB'


begin 

         OPEN tixCursor
         FETCH NEXT FROM TixCursor
              INTO @tixeventlookupid, @pasttixeventlookupid
              
   
         WHILE @@FETCH_STATUS = 0
         BEGIN           
         
         EXEC [amy].[proc_seatdetail_individual_tmp] @tixeventlookupid

         EXEC [amy].[PROC_SeatUpdate] @tixeventlookupid,
                                      @pasttixeventlookupid

           if @tixeventlookupid not like '%PK%'
           begin
             exec [amy].[proc_SeatReconReport_table] @tixeventlookupid
             exec [amy].[proc_SeatTicketOrder_table] @tixeventlookupid
           end 
              FETCH NEXT FROM TixCursor
              INTO @tixeventlookupid,@pasttixeventlookupid
              
         end
         
       --  exec [amy].[proc_SeatUpdate] 'F17-Season','F16-Season'
         exec [amy].[proc_SeatRegionReport_table] 'FB','2018',3
         exec proc_FB_order_list null
         exec  [amy].[proc_update_allfootball] 2018
                  
         close TixCursor
         deallocate TixCursor
end
GO
