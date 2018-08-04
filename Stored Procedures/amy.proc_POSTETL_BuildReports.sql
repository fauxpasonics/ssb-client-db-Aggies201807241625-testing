SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_POSTETL_BuildReports]
AS
   DECLARE @percentdue   DECIMAL
   DECLARE @tixeventlookupid   VARCHAR (50)
   DECLARE @pasttixeventlookupid   VARCHAR (50)
   DECLARE @pacseason   VARCHAR (50)
   DECLARE @pacitem  VARCHAR (50)
   DECLARE
      tixcursor CURSOR LOCAL FAST_FORWARD FOR -- select tixeventlookupid from amy.priorityevents u  where u.LoadDateExpired is null  and loadstartdate < getdate();
         SELECT u.tixeventlookupid,
                uhist.tixeventlookupid pasttixeventlookupid, u.pacseason, u.pacitem 
           FROM amy.priorityevents u
                LEFT JOIN amy.priorityevents uhist
                   ON     u.sporttype = uhist.sporttype
                      AND u.ticketyear = uhist.ticketyear + 1
          WHERE u.LoadDateExpired IS NULL AND u.loadstartdate < getdate ()
         UNION
         SELECT u.pktixeventlookupid,
                uhist.pktixeventlookupid pasttixeventlookupid, u.pacseason, u.pacparkingitem
           FROM amy.priorityevents u
                LEFT JOIN amy.priorityevents uhist
                   ON     u.sporttype = uhist.sporttype
                      AND u.ticketyear = uhist.ticketyear + 1
          WHERE     u.LoadDateExpired IS NULL
                AND u.loadstartdate < getdate ()
                AND u.pktixeventlookupid IS NOT NULL 


   BEGIN
   
      OPEN tixCursor
      FETCH NEXT FROM TixCursor
           INTO @tixeventlookupid, @pasttixeventlookupid, @pacseason , @pacitem


      WHILE @@FETCH_STATUS = 0
      BEGIN
    ---     EXEC [amy].[proc_seatdetail_individual_tmp] @tixeventlookupid  No longer needed

      --   EXEC [amy].[PROC_SeatUpdate] @tixeventlookupid,     @pasttixeventlookupid -- replaced 052018
           EXEC  [amy].[Proc_SeatUpdate_pac] @pacseason , @pacitem 

         IF @tixeventlookupid NOT LIKE '%PK%'
            BEGIN
               EXEC [amy].[proc_SeatReconReport_table_pac] @pacseason , @pacitem 
               EXEC [amy].[proc_SeatTicketOrder_table_pac] @tixeventlookupid
            END

         FETCH NEXT FROM TixCursor
              INTO @tixeventlookupid, @pasttixeventlookupid, @pacseason , @pacitem
      END

      EXEC [amy].[proc_SUITE_table] 'FB', 2018        
      EXEC amy.proc_SUITESEATREGION_table 'FB', 2018  
      
    --  EXEC [amy].[proc_SeatUpdate] 'F17-Season', 'F16-Season'
   --!--   EXEC [amy].[proc_SeatRegionReport_table] 'FB', '2018', 3
   EXEC [amy].[proc_FB_order_list] NULL  -- need to update
   EXEC [amy].[proc_update_allfootball] 2018 -- need to update
    --  EXEC [amy].[proc_prioritypointhistory]       --- addback in July 2018
    --  EXEC [amy].[proc_SUITE_table] 'BSB', 2018         --- Should add for 2019
   --   EXEC amy.proc_SUITESEATREGION_table 'BSB', 2018    --- Should add for 2019

      CLOSE TixCursor
      DEALLOCATE TixCursor 
   END
GO
