SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[rpt_SeatUpdate] 'F16-Season','F15-Season'

--select * from amy.seatdetail_individual_history where tixeventlookupid = 'F16-Season' and update_date >= getdate()-1
--select * into amy.seatdetail_individual_history_BK from amy.seatdetail_individual_history where tixeventlookupid = 'F16-Season'
--exec [amy].[rpt_SeatUpdate_reltest] 'F16-Season','F15-Season'

CREATE PROCEDURE [amy].[rpt_SeatUpdate_reltest]
(@currenttixeventlookupid nvarchar(48),
 @previoustixeventlookupid nvarchar(48))
AS



declare @relocate_accountnumber varchar(1)
declare @relocate_percent numeric(10,2)
declare @relocate_CAPTERMSTARTYEAR int
declare @relocate_CAPTERMSTARTDATE datetime
declare @relocate_from_seatdetail_individual_history_id int
declare @relocate_to_seatdetail_individual_history_id int

declare tixcursor_relocate CURSOR LOCAL FAST_FORWARD FOR  
select  cancel.cancel_accountnumber, 
cancel.cancel_captermstartdate, cancel.cancel_captermstartyear, cancel.cancel_cap_percent_owe_todate,cancel_seatdetail_individual_history_id, 
creates.create_seatdetail_individual_history_id
from
( select   accountnumber cancel_accountnumber, tixeventlookupid cancel_tixeventlookupid,
seatpricecode cancel_seatpricecode, seatsection cancel_seatsection, seatrow cancel_seatrow, seatseat cancel_seatseat,  year cancel_year, 
seatdetail_individual_history_id cancel_seatdetail_individual_history_id,
captermstartdate cancel_captermstartdate, captermstartyear cancel_captermstartyear , 
cap_percent_owe_todate cancel_cap_percent_owe_todate, 
ticket_start_year cancel_ticket_start_year, cancel_date cancel_cancel_date,  create_date cancel_create_date,
ROW_NUMBER() OVER(ORDER BY cap_percent_owe_todate desc, seatsection,seatrow,seatseat) AS CancelRowNumber  from amy.seatdetail_individual_history where accountnumber in (
select accountnumber from (select accountnumber, sum(case when cancel_date >= getdate()-1 then 1  else 0 end) cancels,
sum(case when create_date >= getdate()-1 then 1  else 0 end) creates
from  amy.seatdetail_individual_history  where tixeventlookupid = @currenttixeventlookupid and
((cancel_date >= getdate()-1  -- and lineal_transfer_release_ind is null
) or (create_date >= getdate()-1 and lineal_transfer_received_ind is null  --and relocation_release_ind is null
))
group by accountnumber) T where cancels >0 and creates >0 ) 
and tixeventlookupid = @currenttixeventlookupid and (cancel_date >= getdate()-1  and lineal_transfer_release_ind is null   --and relocation_release_ind is null
) ) cancel,
( select  accountnumber create_accountnumber,tixeventlookupid create_tixeventlookupid,seatpricecode create_seatpricecode, 
seatsection create_seatsection, seatrow create_seatrow, seatseat create_seatseat,  year create_year, 
seatdetail_individual_history_id create_seatdetail_individual_history_id,
captermstartdate create_captermstartdate, captermstartyear create_captermstartyear , 
cap_percent_owe_todate create_cap_percent_owe_todate, ticket_start_year create_ticket_start_year, 
cancel_date create_cancel_date, create_date create_create_date, cap_amount,
ROW_NUMBER() OVER(ORDER BY cap_amount desc, seatsection,seatrow,seatseat) AS CreateRowNumber from 
amy.seatdetail_individual_history ct , amy.VenueSectionsbyyear  ks ,        
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @currenttixeventlookupid and  ks.sporttype  = 'FB' and ct.seatsection   = ks.sectionnum and ct.year between ks.startyear and endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid 
and accountnumber in (
select accountnumber from (select accountnumber, sum(case when cancel_date >= getdate()-1 then 1  else 0 end) cancels,
sum(case when create_date >= getdate()-1 then 1  else 0 end) creates
from  amy.seatdetail_individual_history  where tixeventlookupid = @currenttixeventlookupid and
((cancel_date >= getdate()-1  and lineal_transfer_release_ind is null  --and relocation_release_ind is null
) or (create_date >= getdate()-1 and lineal_transfer_received_ind is null  --and  relocation_start_ind is null
))
group by accountnumber) T where cancels >0 and creates >0 ) 
and tixeventlookupid = @currenttixeventlookupid and (create_date >= getdate()-1 and lineal_transfer_received_ind is null -- and  relocation_start_ind is null
)
) creates where cancel.cancel_accountnumber= creates.create_accountnumber AND cancel.CancelRowNumber = creates.CreateRowNumber


--select * from  amy.seatdetail_individual_history where seatdetail_individual_history_id in ( 414638, 414639, 271285, 271286)


 begin

               
 -- if  @currenttixeventlookupid like 'F%-Season'
  -- begin
   
  OPEN tixcursor_relocate
         FETCH NEXT FROM tixcursor_relocate
              INTO  @relocate_accountnumber,  @relocate_CAPTERMSTARTDATE, @relocate_CAPTERMSTARTYEAR, @relocate_percent, 
                   @relocate_from_seatdetail_individual_history_id, @relocate_to_seatdetail_individual_history_id 

         WHILE @@FETCH_STATUS = 0
         BEGIN       


         update amy.seatdetail_individual_history set 
          relocation_release_ind= 1,
          relocation_date = getdate(),
          update_date =getdate()
         where --accountnumber = @relocate_accountnumber
         --and tixeventlookupid = @currenttixeventlookupid  
         --and 
         seatdetail_individual_history_id = @relocate_from_seatdetail_individual_history_id         
         
        update amy.seatdetail_individual_history set 
          relocation_start_ind = 1,
          relocation_date = getdate()   ,
          relocation_parent_id  = @relocate_from_seatdetail_individual_history_id       ,
          update_date =getdate(), 
          CAPTERMSTARTDATE =  @relocate_CAPTERMSTARTDATE, 
          CAPTERMSTARTYEAR = @relocate_CAPTERMSTARTYEAR, 
          cap_percent_owe_todate = @relocate_percent
         where --accountnumber = @relocate_accountnumber
         --and tixeventlookupid = @previoustixeventlookupid  
         --and 
         seatdetail_individual_history_id = @relocate_to_seatdetail_individual_history_id 
                   
              FETCH NEXT FROM  tixcursor_relocate
              INTO  @relocate_accountnumber,  @relocate_CAPTERMSTARTDATE, @relocate_CAPTERMSTARTYEAR, @relocate_percent, 
                   @relocate_from_seatdetail_individual_history_id, @relocate_to_seatdetail_individual_history_id 
              
         end
         
   close tixcursor_relocate
   deallocate tixcursor_relocate
 
  --end

 
 end
GO
