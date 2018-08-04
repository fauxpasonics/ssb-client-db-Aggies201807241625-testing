SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec [amy].[Proc_SeatUpdate]'F17-Season','F16-Season'
-- exec [amy].[Proc_SeatUpdate]'B16-WB','B15-WB'
--exec amy.rpt_SportSeatRefresh
--exec [amy].[Proc_SeatUpdate_t]'F17-PK','F16-PK'
CREATE PROCEDURE [amy].[Proc_SeatUpdate_t]
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
declare @sportyear int 
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

Declare @renewalcategory varchar(20)
Declare @renewalproductid  int
Declare @ordergroupdate datetime2(6)
Declare @ordergrouplastupdated datetime2(6)
Declare @renewalorderstart datetime2(6)
Declare @renewalorderend datetime2(6)

select  @sporttype =sporttype, @sportyear = ticketyear,
@renewalproductid = renewalproductid, @renewalcategory = renewalcategory, @tixeventtitleshort = tixeventtitleshort,  @renewalorderstart =  renewalorderstart,  @renewalorderend =  renewalorderend
from amy.PriorityEvents pe1 where tixeventlookupid  = @currenttixeventlookupid ;


declare tixcursor CURSOR LOCAL FAST_FORWARD FOR  select  accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
ordergrouptotalpaymentscleared, tixseatlastupdate,  (select  'X' tst from amy.seatdetail_individual_history t where 
tixeventlookupid = @currenttixeventlookupid  and J.accountnumber = t.accountnumber
and  J.tixeventlookupid = t.tixeventlookupid  and  
J.[year] = t.[year] 
and J.seatsection  = t.seatsection
and isnull(J.seatrow, '') = isnull(t.seatrow, '')
and isnull(J.seatseat, '') = isnull(t.seatseat , '')
and j.tixseatid =t.tixseatid 
 ) existingrecord, 
 ordernumber, ordergroupdate, ordergrouplastupdated
from  (
select * from 
(select   accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
ordergrouptotalpaymentscleared, tixseatlastupdate, ordernumber, ordergroupdate, ordergrouplastupdated
from amy.seatdetail_individual_tmp where tixeventlookupid = @currenttixeventlookupid 
except
select  accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
ordergrouptotalpaymentscleared, tixseatlastupdate,ordernumber, ordergroupdate, ordergrouplastupdated
from amy.seatdetail_individual_history where tixeventlookupid = @currenttixeventlookupid  
--and isnull(cancel_ind,0) = 0
) A ) J 

/*
declare tixcursor_cancel CURSOR LOCAL FAST_FORWARD FOR  select * from (
select  accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode , -- paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
--ordergrouptotalpaymentscleared, tixseatlastupdate,
(select  'X' tst from amy.seatdetail_individual_tmp t where 
tixeventlookupid = @currenttixeventlookupid  and J.accountnumber = t.accountnumber
and  J.tixeventlookupid = t.tixeventlookupid  and  
J.[year] = t.[year] 
and isnull(J.seatsection,'')  = isnull(t.seatsection,'')
and isnull(J.seatrow,'') = isnull(t.seatrow,'')
and isnull(J.seatseat,'') = isnull(t.seatseat,'')
and isnull(j.tixseatid,'') =isnull(t.tixseatid,'') ) existingrecord
from  (
select * from 
(select   accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode --,-- paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
--ordergrouptotalpaymentscleared, tixseatlastupdate
from amy.seatdetail_individual_history where tixeventlookupid = @currenttixeventlookupid  and isnull(cancel_ind,0) = 0
except
select  accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode --, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
--ordergrouptotalpaymentscleared, tixseatlastupdate
from amy.seatdetail_individual_tmp where tixeventlookupid = @currenttixeventlookupid 
) A ) J ) T
where existingrecord is null


declare tixcursor_lineal CURSOR LOCAL FAST_FORWARD FOR  
select accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, year, seatpricecode, seatsection,
                    seatrow, seatseat, tixseatid, tixsyspricecode,  
                    seatdetail_individual_history_id,TransferCredit,TransferDate,
                    pastaccountnumber, pastseatdetail_individual_history_id,PreviousCAPTERMSTARTDATE, PreviousCapPercent,PreviousCAPTERMSTARTYEAR,
                    previousseatterm from (
select  sh.*,
cast(sh.tixseatlastupdate as datetime) dt,
( 
select  distinct 'X' from advcontact c, advcontacttransheader h, advcontacttranslineitems li,
(select sarea.SeatregionID,
programid from seatarea sarea,
seatallocation sa where  sarea.SeatAreaID = sa.SeatAreaID  and programtypecode = 'LC_C' and isnull(sa.inactive_ind,0) =0) sa1
where c.contactid = h.contactid and  h.transid = li.transid  and li.ProgramID  = sa1.programid
and transtype like '%Credit%' and c.adnumber =  sh.accountnumber and ks.seatregionid = sa1.seatregionid  ) TransferCredit,
( 
select  min(transdate) from advcontact c, advcontacttransheader h, advcontacttranslineitems li,
(select sarea.SeatregionID,
programid from seatarea sarea,
seatallocation sa where  sarea.SeatAreaID = sa.SeatAreaID  and programtypecode = 'LC_C' and isnull(sa.inactive_ind,0) =0) sa1
where c.contactid = h.contactid and  h.transid = li.transid  and li.ProgramID  = sa1.programid
and transtype like '%Credit%'
and c.adnumber =  sh.accountnumber and ks.seatregionid = sa1.seatregionid ) TransferDate , 
shpast.accountnumber pastaccountnumber, shpast.seatdetail_individual_history_id pastseatdetail_individual_history_id, 
shpast.CAPTERMSTARTDATE PreviousCAPTERMSTARTDATE, shpast.CAP_Percent_Owe_ToDate PreviousCapPercent, shpast.CAPTERMSTARTYEAR  PreviousCAPTERMSTARTYEAR ,
shpast.seatterm previousseatterm
from amy.seatdetail_individual_history sh 
     join amy.VenueSectionsbyYear  ks  on  ks.sporttype =  'FB' and sh.seatsection   = ks.sectionnum   and sh.year between ks.startyear and ks.endyear 
                           and ((ks.rows is not null and ks.rows like '%;'+cast(sh.seatrow as varchar) +';%' )   or (ks.rows is null) )
     join amy.SeatRegion sr on     sr.seatregionid= ks.seatregionid     
     left join   amy.seatdetail_individual_history shpast  on  shpast.tixeventlookupid =  @previoustixeventlookupid  and sh.seatsection = shpast.seatsection   
     and sh.seatseat = shpast.seatseat and sh.seatrow = shpast.seatrow
         where  sh.tixeventlookupid =  @currenttixeventlookupid 
          ) y where transfercredit = 'X'  and lineal_transfer_received_ind is null

  ---------------------relocateouter
 declare tixcursor_relocate_outer CURSOR LOCAL FAST_FORWARD FOR  
 select accountnumber relocate_accountnumber_loopid from 
 (select accountnumber, 
sum(case when cancel_date >= getdate()-3  and lineal_transfer_release_ind is null and relocation_release_ind is null then 1  else 0 end) cancels,
sum(case when create_date >= getdate()-3  and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('Request Pending')  then 1  else 0 end) creates
from  amy.seatdetail_individual_history  where tixeventlookupid = @currenttixeventlookupid and
((cancel_date >= getdate()-3  and lineal_transfer_release_ind is null and relocation_release_ind is null
) or 
(create_date >= getdate()-3 and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null and seatsection not in ('Request Pending') 
))
group by accountnumber) T where cancels >0 and creates >0 

*/


begin 



         OPEN tixCursor
         FETCH NEXT FROM TixCursor
              INTO  @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, @existingrecord, @ordernumber,  @ordergroupdate, @ordergrouplastupdated
              
   
         WHILE @@FETCH_STATUS = 0
         BEGIN           
         
               if @existingrecord = 'X'  BEGIN
 select getdate()
 /*
              update amy.seatdetail_individual_history set 
              categoryname = @categoryname, 
              tixeventlookupid = tixeventlookupid, 
              tixeventtitleshort = @tixeventtitleshort,
              tixeventid = @tixeventid, 
              [year] = @year, 
              seatpricecode = @seatpricecode, 
              tixsyspricecode = @tixsyspricecode, 
              paid = @paid, 
              sent = @sent,
              paidpercent = @paidpercent, 
              schpercent = @schpercent, 
              ordergroupbottomlinegrandtotal = @ordergroupbottomlinegrandtotal,
              ordergrouptotalpaymentsonhold = @ordergrouptotalpaymentsonhold,
              ordergrouptotalpaymentscleared = @ordergrouptotalpaymentscleared ,
              tixseatlastupdate = @tixseatlastupdate ,
              cancel_ind = null, 
              cancel_date = null,
              update_date =getdate(),
              ordernumber = @ordernumber,
              ordergroupdate =   @ordergroupdate,
              ordergrouplastupdated = @ordergrouplastupdated
              where tixeventlookupid = @currenttixeventlookupid  and accountnumber = @accountnumber
              and  [year] = @year
              and seatsection  = @seatsection
              and isnull(seatrow,'') = isnull(@seatrow,'')
              and isnull(seatseat,'') = isnull(@seatseat,'')
              and tixseatid = @tixseatid
*/
	            END
		          ELSE BEGIN
              
                set @newyearpercent    = null
                set @CAPTERMSTARTYEAR  = null
                set @CAPTERMSTARTDATE  = null  
                set @ticket_start_date = null
                set @ticket_start_year = null
                set @PreviousCAPTERMSTARTYEAR = null
                set @PreviousCAPTERMSTARTDATE = null
                set @Previous_ticket_start_date = null 
                set @Previous_ticket_start_year = null
                set @PreviousCapPercent = null 
                set @Previousseatterm = null 
                
              if @currenttixeventlookupid  like 'F%-Season'
              begin
              
   
               select  @PreviousCAPTERMSTARTYEAR = CAPTERMSTARTYEAR, @PreviousCAPTERMSTARTDATE =  CAPTERMSTARTDATE , @Previous_ticket_start_date = ticket_start_date, 
                       @Previous_ticket_start_year = ticket_start_year , @PreviousCapPercent = hh.CAP_Percent_Owe_ToDate,
                       @previousseatterm =  seatterm
              from amy.seatdetail_individual_history hh
              where accountnumber =  @accountnumber and isnull(seatsection,'') =  isnull(@seatsection,'') 
              and  isnull(seatrow,'') = isnull(@seatrow,'') and isnull(seatseat,'') = isnull(@seatseat,'') 
              and tixeventlookupid = @previoustixeventlookupid
 

              if @Previous_ticket_start_date is not null and @@ROWCOUNT >=1 and isnull(@seatsection,'') not like 'Request%'
                   begin 
                     set @CAPTERMSTARTYEAR = @PreviousCAPTERMSTARTYEAR
                     set @CAPTERMSTARTDATE = @PreviousCAPTERMSTARTDATE
                     set @ticket_start_date = @Previous_ticket_start_date
                     set @ticket_start_year =  @Previous_ticket_start_year 
                     set @newyearpercent  = 0.20 + isnull(@PreviousCapPercent,0)
                     set @seatterm=    @previousseatterm
                   end
                  else
                   begin
                     set @newyearpercent  = 0.20
                     set @CAPTERMSTARTYEAR  = @year
                     set @CAPTERMSTARTDATE  = cast(@tixseatlastupdate as datetime) 
                     set @ticket_start_date = cast(@tixseatlastupdate as datetime) 
                     set @ticket_start_year = @year
                     set @seatterm=    null
                   end  -- end of else for if @Previous_ticket_start_date is not null
        
                  
               end    --if end of if @currenttixeventlookupid  like 'F%-Season'
              else 
              begin
                set @newyearpercent    = null
                set @CAPTERMSTARTYEAR  = null
                set @CAPTERMSTARTDATE  = null  
                set @ticket_start_date = isnull(cast(@tixseatlastupdate as datetime)  ,year(getdate()))
                set @ticket_start_year = @year
                set @seatterm=    null
              end   --if end of if @currenttixeventlookupid  like 'F%-Season'
              
   
/*

              		insert into amy.seatdetail_individual_history (accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
              seatrow, seatseat, tixseatid, tixsyspricecode, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
              ordergrouptotalpaymentscleared, tixseatlastupdate, update_date, create_date , CAPTERMSTARTYEAR ,CAPTERMSTARTDATE , cap_percent_owe_todate,
              ticket_start_date, ticket_start_year, seatterm, ordernumber, ordergroupdate,ordergrouplastupdated )
              values ( @accountnumber, @categoryname, @currenttixeventlookupid , @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, getdate(),  getdate(), @CAPTERMSTARTYEAR, @CAPTERMSTARTDATE  ,  @newyearpercent,
              @ticket_start_date, @ticket_start_year, @seatterm, @ordernumber, @ordergroupdate,@ordergrouplastupdated)
          */    


	            END

             
              FETCH NEXT FROM TixCursor
              INTO @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, @existingrecord, @ordernumber, @ordergroupdate,@ordergrouplastupdated
              
         end
  close tixCursor
  deallocate  tixCursor
 /* 
---Run Cancels
  OPEN tixcursor_cancel
         FETCH NEXT FROM tixcursor_cancel
              INTO  @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
                    @seatrow, @seatseat, @tixseatid, @tixsyspricecode,  @existingrecord                     
   
         WHILE @@FETCH_STATUS = 0
         BEGIN       

         update amy.seatdetail_individual_history set 
          cancel_ind = 1,
          cancel_date = getdate(),
          update_date =getdate()
         where accountnumber = @accountnumber
         and  tixeventlookupid = @currenttixeventlookupid  
         and  [year] = @year
         and seatsection  = @seatsection
         and isnull(seatrow,'') = isnull(@seatrow,'')
         and isnull(seatseat,'') = isnull(@seatseat,'')
         and tixseatid= @tixseatid
             
              FETCH NEXT FROM  tixcursor_cancel
              INTO  @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
                    @seatrow, @seatseat, @tixseatid, @tixsyspricecode,  @existingrecord             
              
         end
         
  close tixcursor_cancel
  deallocate tixcursor_cancel
 

 
 --Football  only 
   if @currenttixeventlookupid like 'F%-Season'
     begin
              
 ---Run Lineal
  OPEN tixcursor_lineal
         FETCH NEXT FROM tixcursor_lineal
              INTO  @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
                    @seatrow, @seatseat, @tixseatid, @tixsyspricecode,  
                    @seatdetail_individual_history_id,@TransferCredit,@TransferDate,
                    @pastaccountnumber,@pastseatdetail_individual_history_id,@PreviousCAPTERMSTARTDATE, @PreviousCapPercent, @PreviousCAPTERMSTARTYEAR, @previousseatterm

---- @Previous_ticket_start_date datetime
---- @Previous_ticket_start_year int

         WHILE @@FETCH_STATUS = 0
         BEGIN       

         update amy.seatdetail_individual_history set 
          lineal_transfer_received_ind = 1,
          lineal_transfer_date = @TransferDate,    
          lineal_transfer_parent = @pastseatdetail_individual_history_id,
          lineal_transfer_parent_acct = @pastaccountnumber,
          CAPTERMSTARTDATE = @PreviousCAPTERMSTARTDATE,
          CAP_Percent_Owe_ToDate = .20 + @PreviousCapPercent, 
          CAPTERMSTARTYEAR = @PreviousCAPTERMSTARTYEAR,
          update_date =getdate(), 
          seatterm =  @previousseatterm
         where accountnumber = @accountnumber
         and tixeventlookupid = @currenttixeventlookupid  
         and seatdetail_individual_history_id = @seatdetail_individual_history_id
         
         
        update amy.seatdetail_individual_history set 
          lineal_transfer_release_ind = 1,
          lineal_transfer_date = @TransferDate   ,
          update_date =getdate()
         where tixeventlookupid = @previoustixeventlookupid  
         and seatdetail_individual_history_id = @pastseatdetail_individual_history_id
         
 
             
              FETCH NEXT FROM  tixcursor_lineal
              INTO  @accountnumber, @categoryname, @tixeventlookupid, @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
                    @seatrow, @seatseat, @tixseatid, @tixsyspricecode,  
                    @seatdetail_individual_history_id,@TransferCredit,@TransferDate,
                    @pastaccountnumber,@pastseatdetail_individual_history_id,@PreviousCAPTERMSTARTDATE, @PreviousCapPercent, @PreviousCAPTERMSTARTYEAR, @previousseatterm
    
              
         end
         
 close tixcursor_lineal
 deallocate tixcursor_lineal
 
 
open tixcursor_relocate_outer
 fetch next from tixcursor_relocate_outer into @relocate_accountnumber_loopid 
 set @relocate_outer_fetch =  @@FETCH_STATUS
    WHILE @relocate_outer_fetch =0
       BEGIN
             
     
declare tixcursor_relocate_inner CURSOR  LOCAL FAST_FORWARD
FOR  
select  cancel.cancel_accountnumber, 
cancel.cancel_captermstartdate, cancel.cancel_captermstartyear, 
case when  cancel.cancel_cap <= creates.cap_amount then .20 else cancel.cancel_cap_percent_owe_todate end cancel_cap_percent_owe_todate ,cancel_seatdetail_individual_history_id, 
creates.create_seatdetail_individual_history_id
from
( select   accountnumber cancel_accountnumber, tixeventlookupid cancel_tixeventlookupid,
seatpricecode cancel_seatpricecode, seatsection cancel_seatsection, seatrow cancel_seatrow, seatseat cancel_seatseat,  year cancel_year, 
seatdetail_individual_history_id cancel_seatdetail_individual_history_id,
captermstartdate cancel_captermstartdate, captermstartyear cancel_captermstartyear , 
cap_percent_owe_todate cancel_cap_percent_owe_todate, 
ticket_start_year cancel_ticket_start_year, cancel_date cancel_cancel_date,  create_date cancel_create_date, cap cancel_cap,
ROW_NUMBER() OVER(ORDER BY accountnumber, cap desc, seatsection,cap_percent_owe_todate desc, seatrow,seatseat) AS CancelRowNumber 
from 
(select  s.*, p.CAP 
from amy.seatdetail_individual_history s left join  playbookpricegroupsection p on p.seatareaid = s.seatareaid and s.seatpricecode = p.PriceCodeName
and p.sporttype =@sporttype AND p.ticketyear =  @sportyear 
where accountnumber  = @relocate_accountnumber_loopid 
and tixeventlookupid = @currenttixeventlookupid and (cancel_date >= getdate()-3  and lineal_transfer_release_ind is null   and relocation_release_ind is null and seatpricecode not in ('Suite SRO')
)
) g
)
cancel,
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
and tixeventlookupid = @currenttixeventlookupid and (create_date >= getdate()-3 and lineal_transfer_received_ind is null  and  relocation_start_ind is null  and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('Request Pending') 
)
) creates where cancel.cancel_accountnumber= creates.create_accountnumber AND cancel.CancelRowNumber = creates.CreateRowNumber

       OPEN tixcursor_relocate_inner
         FETCH NEXT FROM tixcursor_relocate_inner
              INTO  @relocate_accountnumber,  @relocate_CAPTERMSTARTDATE, @relocate_CAPTERMSTARTYEAR, @relocate_percent, 
                   @relocate_from_seatdetail_individual_history_id, @relocate_to_seatdetail_individual_history_id 
          set @relocate_inner_fetch =  @@FETCH_STATUS
         WHILE @relocate_inner_fetch = 0
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
 


    
   end  ---end football only if
  */
  /*
 MERGE amy.seatdetail_individual_history AS sih
 USING (select  ct.seatdetail_individual_history_id,  ks.SeatAreaID, sr.seatregionname, ks.seatregionid,  cast(ct.accountnumber as int) adnumber
  from   amy.seatdetail_individual_history ct, 
               amy.VenueSectionsbyyear  ks ,        
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @currenttixeventlookupid   and
          ks.sporttype     =  @sporttype  
          and ct.seatsection      = ks.sectionnum and ct.year between ks.startyear and ks.endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.seatareaid = regarea.seatareaid, sih.seatregionid = regarea.seatregionid;
 
 -- set term
   MERGE amy.seatdetail_individual_history AS sih
 USING ( select seatdetail_individual_history_id, term seatterm from (
select h.*, (select termpost06012014 from seatarea sa where sa.seatareaid = h.seatareaid)  term
from amy.seatdetail_individual_history h where seatterm is  null
and h.tixeventlookupid in ( @currenttixeventlookupid )  ) tt   ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.seatterm = regarea.seatterm ;
 
 -- set seatlastupdated 
 update  seatdetail_individual_history set seatlastupdated = 
  case when  isnull(lineal_transfer_date, '01/01/1900')  >=   isnull(cancel_date, '01/01/1900') and 
   isnull(lineal_transfer_date, '01/01/1900')  >=   isnull(relocation_date, '01/01/1900') 
   and  isnull(lineal_transfer_date, '01/01/1900') >= isnull(create_date, '01/01/1900')  then  lineal_transfer_date
   when  isnull(relocation_date, '01/01/1900')  >=   isnull(cancel_date, '01/01/1900') and 
      isnull(relocation_date, '01/01/1900') >= isnull(create_date, '01/01/1900') then relocation_date
      when    isnull(cancel_date, '01/01/1900') >= isnull(create_date, '01/01/1900') then cancel_date
      else create_date end , renewal_order  = case when ordergroupdate between @renewalorderstart and @renewalorderend  or renewal_order = 1 then 1 else 0 end,
      renewal_ticket  = case when( create_date  between @renewalorderstart and @renewalorderend and seatpricecode not like '%Request%')  or renewal_ticket  = 1 then 1 else 0 end,
      new_ticket  = case when( seatpricecode like '%Request%')  or new_ticket  = 1 then 1 else 0 end
 where tixeventlookupid in ( @currenttixeventlookupid )   
 
     MERGE amy.seatdetail_individual_history AS sih
 USING ( select seatdetail_individual_history_id,  renewal_date_new renewal_date from (
select h.*, (  select max(submit_date)  
 from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = @renewalcategory and renewal_descr like @tixeventtitleshort +'%'    and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and   product_id  = @renewalproductid and o.acct = h.accountnumber) renewal_date_new 
from amy.seatdetail_individual_history h where  --seatterm is  null and
 h.tixeventlookupid in ( @currenttixeventlookupid )  and renewal_date is null ) tt   ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.renewal_date = regarea.renewal_date  ;
 
    if @currenttixeventlookupid like 'F%-Season'
     begin
     update seatdetail_individual_history set creditamount = 0 where tixeventlookupid =@currenttixeventlookupid
              
        MERGE amy.seatdetail_individual_history AS sih
 USING (  select top 10000 d.*, 
    case when isnull(finalcreditoptionprevious,0) + tempcredit<=Fullcredit then tempcredit
    when isnull(finalcreditoptionprevious,0) + tempcredit > Fullcredit and isnull(finalcreditoptionprevious,0) < fullcredit then fullcredit-isnull(finalcreditoptionprevious,0)
    else 0 end Credittoapply
    from (
      select c.*,  finalcreditoption  = SUM(tempcredit) OVER  (PARTITION BY accountnumber   ORDER BY accountnumber , seatprioritylist  ROWS BETWEEN UNBOUNDED PRECEDING  AND CURRENT ROW   ),
      finalcreditoptionprevious = SUM(tempcredit) OVER (PARTITION BY  accountnumber   ORDER BY accountnumber , seatprioritylist   ROWS BETWEEN UNBOUNDED PRECEDING   AND  1 preceding   )
      from (
      select b.*,  case when      countAnnualAmt > 0 then  ( FullCredit /     countAnnualAmt) else 0 end t, 
      case 
      --when annual >= 2000 and annual <= fullcredit then  2000 
      --when annual < 2000 and annual <= fullcredit then  annual
       when annual <= fullcredit then  annual
      else fullcredit
      end tempcredit
      from 
    (  select accountnumber, seatdetail_individual_history_id  , seatpricecode, seatsection, seatrow,  seatseat ,  seatprioritylist, annual,SumAnnualAmt,      countAnnualAmt,
      (select  sum(transamount) Credit from adv_transaction_vw v 
      where transtype = 'Credit' and transyear = cast(@sportyear  as varchar)
     -- and programid  not in (260,131, 679,678) 
    --  and programid not in (select programid from amy.SeatAllocation where programtypecode ='ADAAC')
      and programid in (select programid from seatallocation where  sporttype = 'FB') and v.adnumber = sportlist.accountnumber) FullCredit      
      from (
               select accountnumber, seatdetail_individual_history_id  , seatpricecode, seatsection, seatrow,  seatseat , 
               case when seatpricecode like 'E%' or seatpricecode like 'Suite E%' then 1
               when seatpricecode like '%ADA%' or seatpricecode like '%WC%' or seatpricecode like '%Wheel Chair%' then 2 else 3 end seatprioritylist,  py.Annual,
                  s.tixeventlookupid ,SumAnnualAmt = SUM(Annual) OVER   (PARTITION BY accountnumber           ORDER BY accountnumber        ),
                   countAnnualAmt =count(Annual) OVER   (PARTITION BY accountnumber            ORDER BY accountnumber          )
               from seatdetail_individual_history s 
             left join amy.playbookpricegroupseatarea   py on  s.seatareaid = py.seatareaid and py.pricecodecode = s.seatpricecode  and
      py.sporttype =  @sporttype and py.ticketyear = @sportyear 
           where  s.tixeventlookupid =  @currenttixeventlookupid
           and cancel_ind is null
      and accountnumber   in      (select adnumber from adv_transaction_vw v  where transtype = 'Credit' and transyear =  cast(@sportyear  as varchar)  and programid in (select programid from seatallocation where  sporttype = @sporttype))           
          ) sportlist )b ) c ) d
          order by accountnumber, seatprioritylist
 ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.creditamount= regarea.Credittoapply;
 
 end
  */
end
GO
