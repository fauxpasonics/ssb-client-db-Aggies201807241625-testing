SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec [amy].[Proc_seatrelocate] 'F16-Season','F15-Season'

CREATE  PROCEDURE [amy].[Proc_seatrelocate]
(@currenttixeventlookupid nvarchar(48),
 @previoustixeventlookupid nvarchar(48))
AS


--declare @percentdue decimal
--Declare @tixeventlookupid varchar(50)


declare @accountnumber nvarchar(36)
declare @categoryname nvarchar(150)
declare @tixeventlookupid nvarchar(48)
declare @tixeventtitleshort nvarchar(MAX)
declare @tixeventid numeric(10, 0) 
declare @year int 
declare @seatpricecode nvarchar(150)
declare @seatsection nvarchar(150)
declare @seatrow nvarchar(150)
declare @seatseat nvarchar(150)
declare @tixseatid int 
declare @tixsyspricecode numeric(10, 0)
declare @paid varchar(1)
declare @sent varchar(1)
declare @paidpercent numeric(38, 19)
declare @schpercent numeric(38, 19)
declare @ordergroupbottomlinegrandtotal numeric(19, 4)
declare @ordergrouptotalpaymentsonhold numeric(19, 4)
declare @ordergrouptotalpaymentscleared numeric(19, 4)
declare @tixseatlastupdate nvarchar(255)
declare @existingrecord varchar(1)
declare @ordernumber numeric(10,0)

declare @newyearpercent numeric(10,2)
declare @CAPTERMSTARTYEAR int
declare @CAPTERMSTARTDATE datetime
declare @ticket_start_date datetime
declare @ticket_start_year int

declare @PreviousCAPTERMSTARTYEAR int
declare @PreviousCAPTERMSTARTDATE datetime
declare @Previous_ticket_start_date datetime
declare @Previous_ticket_start_year int
declare @PreviousCapPercent numeric(10,2)

declare @seatdetail_individual_history_id int
declare @TransferCredit varchar(1)
declare @TransferDate datetime
declare @pastaccountnumber int
declare @pastseatdetail_individual_history_id int

declare @relocate_accountnumber nvarchar(36)
declare @relocate_percent numeric(10,2)
declare @relocate_CAPTERMSTARTYEAR int
declare @relocate_CAPTERMSTARTDATE datetime
declare @relocate_from_seatdetail_individual_history_id int
declare @relocate_to_seatdetail_individual_history_id int
Declare @sporttype varchar(50)
declare @relocate_accountnumber_loopid nvarchar(36)
declare @relocate_outer_fetch int
declare @relocate_inner_fetch int

declare @seatterm int 
declare @previousseatterm int

set @sporttype = (select sporttype from amy.PriorityEvents pe1 where tixeventlookupid  = @currenttixeventlookupid );


  ---------------------relocateouter
 declare tixcursor_relocate_outer CURSOR LOCAL FAST_FORWARD FOR  
 select accountnumber relocate_accountnumber_loopid from 
 (select accountnumber, 
sum(case when cancel_date >= getdate()-4  and lineal_transfer_release_ind is null and relocation_release_ind is null then 1  else 0 end) cancels,
sum(case when create_date >= getdate()-4  and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('Request Pending')  then 1  else 0 end) creates
from  amy.seatdetail_individual_history  where tixeventlookupid = @currenttixeventlookupid and
((cancel_date >= getdate()-4  and lineal_transfer_release_ind is null and relocation_release_ind is null
) or 
(create_date >= getdate()-4 and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null and seatsection not in ('Request Pending') 
))
group by accountnumber) T where cancels >0 and creates >0 





begin 


 
 open tixcursor_relocate_outer
 fetch next from tixcursor_relocate_outer into @relocate_accountnumber_loopid 
 set @relocate_outer_fetch =  @@FETCH_STATUS
    WHILE @relocate_outer_fetch =0
       BEGIN
         
         print     @relocate_accountnumber_loopid 
         
         
declare tixcursor_relocate_inner CURSOR  LOCAL FAST_FORWARD
FOR  
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
ROW_NUMBER() OVER(ORDER BY accountnumber,cap_percent_owe_todate desc, seatsection,seatrow,seatseat) AS CancelRowNumber 
from amy.seatdetail_individual_history where accountnumber  = @relocate_accountnumber_loopid 
and tixeventlookupid = @currenttixeventlookupid and (cancel_date >= getdate()-3  and lineal_transfer_release_ind is null   and relocation_release_ind is null and seatpricecode not in ('Suite SRO')
) ) cancel,
( select  accountnumber create_accountnumber,tixeventlookupid create_tixeventlookupid,seatpricecode create_seatpricecode, 
seatsection create_seatsection, seatrow create_seatrow, seatseat create_seatseat,  year create_year, 
seatdetail_individual_history_id create_seatdetail_individual_history_id,
captermstartdate create_captermstartdate, captermstartyear create_captermstartyear , 
cap_percent_owe_todate create_cap_percent_owe_todate, ticket_start_year create_ticket_start_year, 
cancel_date create_cancel_date, create_date create_create_date, cap_amount,
ROW_NUMBER() OVER(ORDER BY  accountnumber, cap_amount desc, seatsection,seatrow,seatseat) AS CreateRowNumber from 
amy.seatdetail_individual_history ct , amy.VenueSectionsbyyear  ks ,        
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @currenttixeventlookupid and  ks.sporttype  = 'FB' and ct.seatsection   = ks.sectionnum  and ct.year between ks.startyear and ks.endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid 
and accountnumber = @relocate_accountnumber_loopid 
and tixeventlookupid = @currenttixeventlookupid and (create_date >= getdate()-4 and lineal_transfer_received_ind is null  and  relocation_start_ind is null  and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('Request Pending') 
)
) creates where cancel.cancel_accountnumber= creates.create_accountnumber AND cancel.CancelRowNumber = creates.CreateRowNumber

       OPEN tixcursor_relocate_inner
         FETCH NEXT FROM tixcursor_relocate_inner
              INTO  @relocate_accountnumber,  @relocate_CAPTERMSTARTDATE, @relocate_CAPTERMSTARTYEAR, @relocate_percent, 
                   @relocate_from_seatdetail_individual_history_id, @relocate_to_seatdetail_individual_history_id 
          set @relocate_inner_fetch =  @@FETCH_STATUS
         WHILE @relocate_inner_fetch = 0
         BEGIN       
  print 'shid' + cast (   @relocate_from_seatdetail_individual_history_id as varchar)
  
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
                   
          FETCH NEXT FROM  tixcursor_relocate_inner
          INTO  @relocate_accountnumber,  @relocate_CAPTERMSTARTDATE, @relocate_CAPTERMSTARTYEAR, @relocate_percent, 
                @relocate_from_seatdetail_individual_history_id, @relocate_to_seatdetail_individual_history_id
                
          set @relocate_inner_fetch =  @@FETCH_STATUS    
          
         end   --end inner
         
           close tixcursor_relocate_inner
   deallocate tixcursor_relocate_inner
              

         fetch next from tixcursor_relocate_outer into @relocate_accountnumber_loopid 
          set @relocate_outer_fetch =  @@FETCH_STATUS
          
        end  -- end outer
        
    close tixcursor_relocate_outer
    deallocate tixcursor_relocate_outer
 

   
 
 -- set term

 
 -- set seatlastupdated 
end
GO
