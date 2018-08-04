SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[Proc_SeatUpdate_pac]
(@pacseason nvarchar(48),
 @pacitem nvarchar(48))
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
declare @tixseatgroupid nvarchar(255)
declare @tixseatgrouppricelevel numeric(10,0)
declare @tixseatofferid  nvarchar(255)
declare @ticketvalue numeric(19, 4)
declare @ticketpaid numeric(19, 4)
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
Declare @previoustixeventlookupid varchar(30)
Declare @seq varchar(10)
Declare @i_pl varchar(10)
Declare @tevent varchar(10)

select  @sporttype =sporttype, @sportyear = ticketyear, @categoryname = categoryname, 
@tixeventlookupid = case when pacitem = @pacitem  then pe1.tixeventlookupid else pe1.pktixeventlookupid end , 
@renewalproductid = renewalproductid, @renewalcategory = renewalcategory,  @tixeventid = tixeventid,
@tixeventtitleshort = tixeventtitleshort,  @renewalorderstart =  renewalorderstart,  @renewalorderend =  renewalorderend,
@tevent  = case when pacitem = @pacitem  then pacevent else pacparkingevent end 
from amy.PriorityEvents pe1 where  pacseason = @pacseason and  (pacitem = @pacitem or pacparkingitem= @pacitem )



  SELECT @previoustixeventlookupid =  tixeventlookupid 
           FROM amy.priorityevents where  sporttype =  @sporttype
                      AND ticketyear = @sportyear - 1 and @pacitem <> 'P'
                      



declare tixcursor CURSOR LOCAL FAST_FORWARD FOR 
select  accountnumber,  tixeventlookupid, tixeventtitleshort, [year], NULL seatpricecode, seatsection,
seatrow, seatseat, tixseatid, tixsyspricecode,
'' paid,''   sent, NULL paidpercent, NULL schpercent,NULL  ordergroupbottomlinegrandtotal, NULL ordergrouptotalpaymentsonhold,
NULL ordergrouptotalpaymentscleared,NULL  tixseatlastupdate,  
(select distinct 'X' tst from amy.seatdetail_individual_history t where 
t.pacseason = @pacseason and t.pacitem = @pacitem  and J.accountnumber = t.accountnumber
and  J.tixeventlookupid = t.tixeventlookupid  and  
J.[year] = t.[year] 
and isnull(J.seatsection,'RequestPending')  = isnull(replace(t.seatsection, ' ', ''),'RequestPending')  COLLATE DATABASE_DEFAULT 
and isnull(J.seatrow,0) = isnull(replace(t.seatrow, ' ',''),0)  COLLATE DATABASE_DEFAULT
and isnull(J.seatseat,0) = isnull(t.seatseat,0) --  COLLATE DATABASE_DEFAULT
--and j.i_pl = t.i_pl COLLATE DATABASE_DEFAULT
 --and j.seq = t.seq 
--and isnull(j.tixseatid , '') =isnull(t.tixseatid  , '')
 ) existingrecord, 
NULL  ordernumber,NULL  ordergroupdate, NULL ordergrouplastupdated ,  NULL tixseatgroupid ,NULL tixseatgrouppricelevel,NULL  tixseatofferid ,NULL ticketvalue,NULL ticketpaid ,NULL  seq, NULL i_pl
from  (select * from 
(select  distinct odet.customer accountnumber,  
  @tixeventlookupid tixeventlookupid, @tixeventtitleshort tixeventtitleshort, 
  @sportyear [year]  ,
   --odet.i_pt  COLLATE DATABASE_DEFAULT seatpricecode, 
 isnull(sb.section,'RequestPending') COLLATE DATABASE_DEFAULT seatsection
 , isnull(sb.row,odet.i_pl)  COLLATE DATABASE_DEFAULT seatrow , num.num seatseat, num.num  tixseatid, null tixsyspricecode --, 
--case when i_bal <= 0 then 'X' when i_pay+ i_cpay > 0 then 'P' else '' end paid, '' sent ,
--case when i_pay + i_bal + i_cpay <> 0 then (i_pay +  i_cpay)/(i_pay + i_bal + i_cpay) else 0 end paidpercent, null schpercent ,
--i_pay + i_bal + i_cpay ordergroupbottomlinegrandtotal, 
-- 0 ordergrouptotalpaymentsonhold,i_pay + i_cpay ordergrouptotalpaymentscleared, 
---format(odet.last_datetime, 'MM/dd/yyyy') tixseatlastupdate ,
--null ordernumber, origts_datetime ordergroupdate, odet.last_datetime ordergrouplastupdated, null tixseatgroupid ,
--null tixseatgrouppricelevel, null tixseatofferid ,i_price ticketvalue, case when i_oqty  <> 0 then  ( i_pay )/ i_oqty else 0 end ticketpaid , 
--odet.seq, odet.i_pl COLLATE DATABASE_DEFAULT   i_pl
from tk_odet odet 
left join TK_ODET_EVENT_SBLS sb on  sb.season = odet.season and sb.item = odet.item and  sb.[EVENT] = @tevent  
--and sb.ZID = odet.ZID
and sb.CUSTOMER = odet.CUSTOMER and sb.SEQ = odet.SEQ
join tk_prtype ptype on  ptype.prtype = odet.I_PT and ptype.season = odet.season
 left    join amy.VenueSectionsbyYear  ks  on  ks.sporttype = @sporttype  and replace(sb.SECTION ,' ','')  = replace(ks.sectionnum ,' ','')  COLLATE DATABASE_DEFAULT  
 and  @sportyear between ks.startyear and ks.endyear 
                           and ((ks.rows is not null and replace(ks.rows,' ','') like '%;'+ sb.[ROW]  +';%'   COLLATE DATABASE_DEFAULT
                            )   or (ks.rows is null) )
--left join amy.playbookpricegroupseatarea   py on  ks.seatareaid = py.seatareaid and py.pricecodecode = odet.I_PT  COLLATE DATABASE_DEFAULT
--and  py.sporttype =  @sporttype  and py.ticketyear =  @sportyear   
left join  number_tbl num on  num.num between isnull(sb.first_seat,1 + odet.SEQ*100) and isnull( sb.last_seat ,i_oqty+ odet.SEQ*100)
where  odet.season = @pacseason  and odet.item = @pacitem
except
select  accountnumber, 
 tixeventlookupid, tixeventtitleshort,  [year] , 
 --seatpricecode,
 replace(seatsection,' ','') seatsection ,
replace(seatrow,' ','') seatrow, seatseat,  tixseatid, null tixsyspricecode 
--paid,  '' sent , paidpercent, schpercent , ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
--ordergrouptotalpaymentscleared, 
--format(cast(tixseatlastupdate as datetime), 'MM/dd/yyyy') tixseatlastupdate ,ordernumber, ordergroupdate, 
--ordergrouplastupdated, tixseatgroupid ,tixseatgrouppricelevel, tixseatofferid ,ticketvalue,ticketpaid , seq, i_pl
from amy.seatdetail_individual_history where pacseason  = @pacseason and pacitem = @pacitem  
--and isnull(cancel_ind,0) = 0
) A ) J 


declare tixcursor_cancel CURSOR LOCAL FAST_FORWARD FOR 
select * from (
select  accountnumber,   seatsection,
seatrow, seatseat, tixseatid, -- paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
--ordergrouptotalpaymentscleared, tixseatlastupdate,
(select  'X' tst  from tk_odet odet left join TK_ODET_EVENT_SBLS sb on  sb.season = odet.season and sb.item = odet.item and  sb.[EVENT] = @tevent   and sb.CUSTOMER = odet.CUSTOMER and sb.SEQ = odet.SEQ
left join  number_tbl num on  num.num between isnull(sb.first_seat,1+ odet.SEQ*100) and isnull( sb.last_seat,i_oqty+ odet.SEQ*100)
where odet.season = @pacseason and odet.item = @pacitem   and J.accountnumber =odet.customer -- and  odet.season = J.season and odet.item = J.item
--and  J.tixeventlookupid = @tixeventlookupid  and  J.[year] = @sportyear 
and isnull(J.seatsection,'RequestPending')  = isnull(sb.section,'RequestPending')  COLLATE DATABASE_DEFAULT 
and isnull(J.seatrow,0) = isnull(sb.row,odet.i_pl)  COLLATE DATABASE_DEFAULT
and isnull(J.seatseat,0) = isnull(num.num,0)
and isnull(j.tixseatid,0) =isnull(num.num,0) 
) existingrecord 
from  (
select A.* from 
(select   accountnumber ,  
replace(seatsection, ' ' ,'') seatsection, replace(seatrow, ' ' ,'') seatrow, seatseat , tixseatid
from amy.seatdetail_individual_history where pacseason = @pacseason and pacitem = @pacitem and isnull(cancel_ind,0) = 0
except
select  odet.customer accountnumber, 
 isnull(sb.section,'RequestPending') COLLATE DATABASE_DEFAULT seatsection, isnull(sb.row,odet.i_pl)  COLLATE DATABASE_DEFAULT seatrow , num.num seatseat , num.num seatseat 
from tk_odet odet 
left join TK_ODET_EVENT_SBLS sb on  sb.season = odet.season and sb.item = odet.item and  sb.[EVENT] = @tevent
and sb.CUSTOMER = odet.CUSTOMER and sb.SEQ = odet.SEQ
left join  number_tbl num on  num.num  between isnull(sb.first_seat,1 + odet.SEQ*100) and isnull( sb.last_seat, i_oqty+ odet.SEQ*100)
where odet.season = @pacseason and odet.item = @pacitem 
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
case when tlc.acct is not null then 'X' else null end  TransferCredit, transferdate,
shpast.accountnumber pastaccountnumber, shpast.seatdetail_individual_history_id pastseatdetail_individual_history_id, 
shpast.CAPTERMSTARTDATE PreviousCAPTERMSTARTDATE, shpast.CAP_Percent_Owe_ToDate PreviousCapPercent, shpast.CAPTERMSTARTYEAR  PreviousCAPTERMSTARTYEAR ,
shpast.seatterm previousseatterm
from amy.seatdetail_individual_history sh 
     join amy.VenueSectionsbyYear  ks  on  ks.sporttype =  'FB' and sh.seatsection   = ks.sectionnum   and sh.year between ks.startyear and ks.endyear 
                           and ((ks.rows is not null and ks.rows like '%;'+cast(sh.seatrow as varchar) +';%' )   or (ks.rows is null) )
     join amy.SeatRegion sr on     sr.seatregionid= ks.seatregionid     
     left join   amy.seatdetail_individual_history shpast  on  shpast.tixeventlookupid =  @previoustixeventlookupid  and sh.seatsection = shpast.seatsection   
     and sh.seatseat = shpast.seatseat and sh.seatrow = shpast.seatrow
     left join (  
               select  acct,  min(Receiveddate) transferdate 
                    from pactranitem_alt_vw c,
                        (select sarea.SeatregionID,
                        programcode from seatarea sarea,
                        seatallocation sa where  sarea.SeatAreaID = sa.SeatAreaID  and programtypecode = 'LC_C' and isnull(sa.inactive_ind,0) =0) sa1
                        where c.allocationid COLLATE DATABASE_DEFAULT = sa1.programcode
                        and creditamt <> 0  and driveyear = 0  group by acct ) TLC  on  TLC.acct=  sh.accountnumber -- and TLC.seatregionid = sa1.seatregionid 
         where  sh.tixeventlookupid =  @tixeventlookupid 
          ) y where transfercredit = 'X'  and lineal_transfer_received_ind is null


  ---------------------relocateouter
 declare tixcursor_relocate_outer CURSOR LOCAL FAST_FORWARD FOR  
 select accountnumber relocate_accountnumber_loopid from 
 (select accountnumber, 
sum(case when cancel_date >= getdate()-15  and lineal_transfer_release_ind is null and relocation_release_ind is null then 1  else 0 end) cancels,
sum(case when create_date >= getdate()-15  and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('RequestPending','Request Pending')  then 1  else 0 end) creates
from  amy.seatdetail_individual_history  where tixeventlookupid = @tixeventlookupid and
((cancel_date >= getdate()-15  and lineal_transfer_release_ind is null and relocation_release_ind is null
) or 
(create_date >= getdate()-15 and lineal_transfer_received_ind is null and  relocation_start_ind is null and cancel_ind is  null and relocation_release_ind is null and seatsection not in ('RequestPending','Request Pending') 
))
group by accountnumber) T where cancels >0 and creates >0 



begin 



         OPEN tixCursor
         FETCH NEXT FROM TixCursor
              INTO  @accountnumber,  @tixeventlookupid, @tixeventtitleshort,  @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, @existingrecord, @ordernumber,  @ordergroupdate, @ordergrouplastupdated, 
               @tixseatgroupid ,   @tixseatgrouppricelevel , @tixseatofferid , @ticketvalue ,   @ticketpaid, @seq, @i_pl
              
   
         WHILE @@FETCH_STATUS = 0
         BEGIN           
         
               if @existingrecord = 'X'  BEGIN

 
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
              ordergrouplastupdated = @ordergrouplastupdated,
              tixseatgroupid = @tixseatgroupid ,
              tixseatgrouppricelevel = @tixseatgrouppricelevel,
              tixseatofferid  = @tixseatofferid ,
              ticketvalue = @ticketvalue, 
              ticketpaid = @ticketpaid,
              tixseatid = @tixseatid
              where tixeventlookupid = @tixeventlookupid  and accountnumber = @accountnumber
              and  [year] = @year
              and seatsection  = @seatsection
              and isnull(seatrow,'') = isnull(@seatrow,'')
              and isnull(seatseat,'') = isnull(@seatseat,'')
              and isnull(i_pl,'') = @i_pl 
              and isnull(seq,'') = @seq
              and pacseason = @pacseason and pacitem = @pacitem          

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
                
              if @tixeventlookupid  like 'F%-Season'
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
                     set @newyearpercent  =  isnull(@PreviousCapPercent,0)
                     set @seatterm=    @previousseatterm
                   end
                  else
                   begin
                     set @newyearpercent  = 0.00
                     set @CAPTERMSTARTYEAR  = @year
                     set @CAPTERMSTARTDATE  = cast(@tixseatlastupdate as datetime) 
                     set @ticket_start_date = cast(@tixseatlastupdate as datetime) 
                     set @ticket_start_year = @year
                     set @seatterm=    null
                   end  -- end of else for if @Previous_ticket_start_date is not null
        
                  
               end    --if end of if @tixeventlookupid  like 'F%-Season'
              else 
              begin
                set @newyearpercent    = null
                set @CAPTERMSTARTYEAR  = null
                set @CAPTERMSTARTDATE  = null  
                set @ticket_start_date = isnull(cast(@tixseatlastupdate as datetime)  ,year(getdate()))
                set @ticket_start_year = @year
                set @seatterm=    null
              end   --if end of if @tixeventlookupid  like 'F%-Season'
              
   


              		insert into amy.seatdetail_individual_history (accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection,
              seatrow, seatseat, tixseatid, tixsyspricecode, paid, sent, paidpercent, schpercent, ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold,
              ordergrouptotalpaymentscleared, tixseatlastupdate, update_date, create_date , CAPTERMSTARTYEAR ,CAPTERMSTARTDATE , cap_percent_owe_todate,
              ticket_start_date, ticket_start_year, seatterm, ordernumber, ordergroupdate,ordergrouplastupdated ,  
              tixseatgroupid ,   tixseatgrouppricelevel , tixseatofferid , ticketvalue ,   ticketpaid, pacseason, pacitem, seq, i_pl )
              values ( @accountnumber, @categoryname, @tixeventlookupid , @tixeventtitleshort, @tixeventid, @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, getdate(),  getdate(), @CAPTERMSTARTYEAR, @CAPTERMSTARTDATE  ,  @newyearpercent,
              @ticket_start_date, @ticket_start_year, @seatterm, @ordernumber, @ordergroupdate,@ordergrouplastupdated,
              @tixseatgroupid ,   @tixseatgrouppricelevel , @tixseatofferid , @ticketvalue ,   @ticketpaid, @pacseason, @pacitem, @seq, @i_pl)
              


	            END

             
              FETCH NEXT FROM TixCursor
              INTO @accountnumber,  @tixeventlookupid, @tixeventtitleshort,  @year, @seatpricecode, @seatsection,
              @seatrow, @seatseat, @tixseatid, @tixsyspricecode, @paid, @sent, @paidpercent, @schpercent, @ordergroupbottomlinegrandtotal, @ordergrouptotalpaymentsonhold,
              @ordergrouptotalpaymentscleared, @tixseatlastupdate, @existingrecord, @ordernumber, @ordergroupdate,@ordergrouplastupdated, 
              @tixseatgroupid ,   @tixseatgrouppricelevel , @tixseatofferid , @ticketvalue ,   @ticketpaid, @seq, @i_pl
              
         end
  close tixCursor
  deallocate  tixCursor
  
---Run Cancels

OPEN tixcursor_cancel
         FETCH NEXT FROM tixcursor_cancel
              INTO  @accountnumber,  @seatsection, @seatrow, @seatseat, @tixseatid, @existingrecord                     
   
         WHILE @@FETCH_STATUS = 0
         BEGIN       

         update amy.seatdetail_individual_history set 
          cancel_ind = 1,
          cancel_date = getdate(),
          update_date =getdate()
         where accountnumber = @accountnumber
         and  tixeventlookupid = @tixeventlookupid  
         and  [year] = @year
         and replace(seatsection, ' ','')  = @seatsection
         and isnull(replace(seatrow, ' ',''),'') = isnull(@seatrow,'')
         and isnull(seatseat,'') = isnull(@seatseat,'')
         and isnull(tixseatid,'')= isnull(@tixseatid,'')
             
              FETCH NEXT FROM  tixcursor_cancel
              INTO @accountnumber,  @seatsection, @seatrow, @seatseat, @tixseatid, @existingrecord            
              
         end
         
  close tixcursor_cancel
  deallocate tixcursor_cancel
 

   
 --Football  only 
   if @tixeventlookupid like 'F%-Season'
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
          CAP_Percent_Owe_ToDate =  @PreviousCapPercent, 
          CAPTERMSTARTYEAR = @PreviousCAPTERMSTARTYEAR,
          update_date =getdate(), 
          seatterm =  @previousseatterm
         where accountnumber = @accountnumber
         and tixeventlookupid = @tixeventlookupid  
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
case when  cancel.cancel_cap <= creates.cap_amount then 0 else cancel.cancel_cap_percent_owe_todate end cancel_cap_percent_owe_todate ,cancel_seatdetail_individual_history_id, 
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
and tixeventlookupid = @tixeventlookupid and (cancel_date >= getdate()-15  and lineal_transfer_release_ind is null   and relocation_release_ind is null and seatpricecode not in ('Suite SRO' ,'CSUSR','QCSUSR','ISUSR',
'NSUSR','RSUSR','RSUSRI')
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
          where  ct.tixeventlookupid =  @tixeventlookupid and  ks.sporttype  = 'FB' and ct.seatsection   = ks.sectionnum  and ct.year between ks.startyear and ks.endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid 
and accountnumber = @relocate_accountnumber_loopid 
and tixeventlookupid = @tixeventlookupid and (create_date >= getdate()-15 and lineal_transfer_received_ind is null  and  relocation_start_ind is null  and cancel_ind is  null and relocation_release_ind is null  and seatsection not in ('Request Pending') 
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
         --and tixeventlookupid = @tixeventlookupid  
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
    
  
 MERGE amy.seatdetail_individual_history AS sih
 USING (select   --  seatdetail_individual_history_id , count(*)
  ct.seatdetail_individual_history_id,  ks.SeatAreaID, sr.seatregionname, ks.seatregionid,  cast(ct.accountnumber as int) adnumber
  from   amy.seatdetail_individual_history ct, 
               amy.VenueSectionsbyyear  ks ,        
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @tixeventlookupid   and
          ks.sporttype     =  @sporttype  
          and replace(ct.seatsection, ' ','')      = replace(ks.sectionnum, ' ','')   and ct.year between ks.startyear and ks.endyear
          and ((ks.rows is not null and replace(ks.rows, ' ','') like '%;'+cast(replace(ct.seatrow,' ' ,'') as varchar) +';%' )   or (replace(ks.rows, ' ','') is null) )
          and sr.seatregionid= ks.seatregionid 
          ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.seatareaid = regarea.seatareaid, sih.seatregionid = regarea.seatregionid;
 -- set term
   MERGE amy.seatdetail_individual_history AS sih
 USING ( select seatdetail_individual_history_id, term seatterm from (
select h.*, (select termpost06012014 from seatarea sa where sa.seatareaid = h.seatareaid)  term
from amy.seatdetail_individual_history h where seatterm is  null
and h.tixeventlookupid in ( @tixeventlookupid )  ) tt   ) AS regarea
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
      renewal_ticket  = case when( create_date  between @renewalorderstart and @renewalorderend and seatpricecode not like '%Request%'and seatpricecode not like 'N%')  or renewal_ticket  = 1 then 1 else 0 end,
      new_ticket  = case when( seatpricecode like '%Request%' or seatpricecode like 'N%' )  or new_ticket  = 1 then 1 else 0 end
 where tixeventlookupid in ( @tixeventlookupid )   
 
     MERGE amy.seatdetail_individual_history AS sih
 USING ( select seatdetail_individual_history_id,  renewal_date_new renewal_date from (
select h.*, (  select max(submit_date)  
 from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = @renewalcategory and renewal_descr like @tixeventtitleshort +'%'    -- and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and   product_id  = @renewalproductid and o.acct = h.accountnumber) renewal_date_new 
from amy.seatdetail_individual_history h where  --seatterm is  null and
 h.tixeventlookupid in ( @tixeventlookupid )  and renewal_date is null ) tt   ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.renewal_date = regarea.renewal_date  ;
 
    if @tixeventlookupid like 'F%-Season'
     begin
 
     update seatdetail_individual_history set creditamount = 0 where tixeventlookupid =@tixeventlookupid
              
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
      (select  sum(creditamt) Credit from PacTranItem_alt_vw   where creditamt <> 0 and driveyear   =  @sportyear
     -- and programid  not in (260,131, 679,678) 
    --  and programid not in (select programid from amy.SeatAllocation where programtypecode ='ADAAC')
      and allocationid  COLLATE DATABASE_DEFAULT in (select programcode from seatallocation where  sporttype = 'FB') and acct  COLLATE DATABASE_DEFAULT = sportlist.accountnumber) FullCredit      
      from ( 
               select accountnumber, seatdetail_individual_history_id  , seatpricecode, seatsection, seatrow,  seatseat , 
              case when seatpricecode like 'E%' or seatpricecode like 'Suite E%'  or seatpricecode in ('IEC', 'NSUEC', 'QIEC', 'QNSUEC', 'QREC', 'QRECA', 'QRECA2', 'QRECH', 'QRECW', 'QRSUEC', 'REA', 'REA2', 'RECA', 'RECA2', 'RECH','RECW','REH', 'REW', 'RSUEC')  then 1
               when seatpricecode like '%ADA%' or seatpricecode like '%WC%' or seatpricecode like '%Wheel Chair%' or seatpricecode in(
'NDA','NDA2','NDW','NFA','NFA2','NFW','NLA','NLA2','NLW','NNGA1','NNGW1','PA','PAV','PEA','PEAV','PSA','QRECA','QRECA2','QRECW','RDA','RDA2','RDAX','RDW','REA','REA2','RECA','RECA2','RECW','REW','RFA','RFA2','RFW','RLA',
'RLA2','RLW','RNGA2','RNGA3','RNGA4','RNGA5','RNGW2','RNGW3','RNGW4','RNGW5') then 2 else 3 end seatprioritylist,  py.Annual,
                  s.tixeventlookupid ,SumAnnualAmt = SUM(Annual) OVER   (PARTITION BY accountnumber           ORDER BY accountnumber        ),
                   countAnnualAmt =count(Annual) OVER   (PARTITION BY accountnumber            ORDER BY accountnumber          )
               from seatdetail_individual_history s 
             left join amy.playbookpricegroupseatarea   py on  s.seatareaid = py.seatareaid and py.pricecodecode = s.seatpricecode  and
      py.sporttype =  @sporttype and py.ticketyear = @sportyear 
           where  s.tixeventlookupid =  @tixeventlookupid
           and cancel_ind is null
      and accountnumber   in      (select acct  from PacTranItem_alt_vw   where creditamt <> 0 and driveyear =  @sportyear   and allocationid  COLLATE DATABASE_DEFAULT in (select programcode from seatallocation where  sporttype = @sporttype))           
          ) sportlist )b ) c ) d
          order by accountnumber, seatprioritylist
 ) AS regarea
ON sih.seatdetail_individual_history_id = regarea.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET sih.creditamount= regarea.Credittoapply; 
 

 end


merge seatdetail_individual_history r using (
select 
  case when renewal_ordernew = 1 and renewal_ticketnew = 0 and relocation_renewal_ticketnew = 0 and paid is not null  and seatpricecode not like 'R%' then 1 else 0 end addonticket, 
  case when renewal_ordernew = 0 and renewal_ticketnew = 0 and paid is not null  and seatpricecode not like 'R%' then 1 else 0 end newticketnew, 
  case when renewal_ordernew = 1 and (renewal_ticketnew = 1 or relocation_renewal_ticketnew = 1 or seatpricecode like 'R%')  then 1 else 0 end renewalticketfinal,
a.* from (
select  isnull((select distinct  1 from  seatdetail_individual_history s1 where tixeventlookupid =@previoustixeventlookupid  and s1.accountnumber = s.accountnumber
and replace(s1.seatsection, 'Floor ', 'FL')=  s.seatsection and s1.seatrow = s.seatrow and s1.seatseat = s.seatseat
and s1.seatpricecode not like '%SRO%' and s.seatpricecode not like '%SRO%' and s.seatpricecode not in ('CSUSR','ISUSR','NSUSR','QCSUSR','RSUSR','RSUSRI')),0) renewal_ticketnew,
isnull((select distinct 1 from  seatdetail_individual_history s1 where tixeventlookupid = @previoustixeventlookupid  and s1.accountnumber = s.accountnumber

),0) renewal_ordernew,
 isnull((select distinct 1 from  seatdetail_individual_history s1, seatdetail_individual_history s2 where s2.seatdetail_individual_history_id = s.relocation_parent_id
and s1.tixeventlookupid = @previoustixeventlookupid  and s1.accountnumber = s2.accountnumber and 
 replace(s1.seatsection, 'Floor ', 'FL') =  s2.seatsection and s1.seatrow = s2.seatrow and s1.seatseat = s2.seatseat
 and s1.seatpricecode not like '%SRO%' and s2.seatpricecode not like '%SRO%' and s2.seatpricecode not in ('CSUSR','ISUSR','NSUSR','QCSUSR','RSUSR','RSUSRI')),0) relocation_renewal_ticketnew,
renewal_order, 
 renewal_ticket, 
new_ticket,
--and 
paid,
s.accountnumber, s.categoryname, s.tixeventlookupid, s.tixeventtitleshort, s.tixeventid, s.[year], s.seatpricecode, s.seatsection, s.seatrow, s.seatseat, s.tixseatid, s.tixsyspricecode ,
s.ticketvalue,
s.ticketpaid , seatdetail_individual_history_id
from seatdetail_individual_history s where tixeventlookupid = @tixeventlookupid   and cancel_ind is  null  --and accountnumber = 252557
--and seatpricecode not like '%SRO%'
) a ) tk 
on r.seatdetail_individual_history_id = tk.seatdetail_individual_history_id 
when matched 
then update
 set r.renewal_ticket= tk.renewalticketfinal, 
     r.new_ticket = tk.newticketnew,
     r.renewal_order = tk.renewal_ordernew,
     r. addonticket = tk.addonticket
     ;
   

merge seatdetail_individual_history t using ( 
select  --s.seatdetail_individual_history_id, count(*)
  s.seatdetail_individual_history_id, 
  seats.customer accountnumber,  
  seats.seatpricecodea, 
  seatsectiona,
  seatrowa ,
  seatseata,
  seats.i_pl I_PL, 
  seats.seq SEQ,
  s.seatsection ,
  s.seatrow, 
  s.seatseat  ,
  seats.ordergroupbottomlinegrandtotal, 
 seats.ordergrouptotalpaymentsonhold,
 seats.ordergrouptotalpaymentscleared,
 seats.tixseatlastupdate 
from 
(SELECT ODET.CUSTOMER, ODET.SEASON, ODET.ITEM, EVENT, 
 isnull(sb.section,'RequestPending') COLLATE DATABASE_DEFAULT seatsectiona,
 isnull(sb.row,odet.i_pl)  COLLATE DATABASE_DEFAULT seatrowa ,
 num.num seatseata,
 MAX(odet.i_pl) I_PL, 
 MAX(odet.seq) SEQ,
 sum(i_pay + i_bal + i_cpay) ordergroupbottomlinegrandtotal, 
 0 ordergrouptotalpaymentsonhold,
 sum(i_pay + i_cpay) ordergrouptotalpaymentscleared,
 max(format(odet.last_datetime, 'MM/dd/yyyy'))  tixseatlastupdate ,
 max(odet.i_pt  COLLATE DATABASE_DEFAULT) seatpricecodea
 FROM  tk_odet  ODET
left join TK_ODET_EVENT_SBLS sb on  sb.season = odet.season and sb.item = odet.item and  sb.[EVENT] = @tevent
and sb.CUSTOMER = odet.CUSTOMER and sb.SEQ = odet.SEQ
left join  number_tbl num on  num.num between isnull(sb.first_seat,1 +odet.seq*100) and isnull( sb.last_seat,i_oqty+odet.seq*100)
where  odet.season = @pacseason   and odet.item = @pacitem 
GROUP BY ODET.CUSTOMER, ODET.SEASON, ODET.ITEM, EVENT, 
 isnull(sb.section,'RequestPending') COLLATE DATABASE_DEFAULT ,
  isnull(sb.row,odet.i_pl)  COLLATE DATABASE_DEFAULT ,
 num.num 
) SEATS
left join seatdetail_individual_history s on s.tixeventlookupid = @tixeventlookupid and  
isnull(replace(seatsection, ' ',''),'RequestPending') = seats.seatsectiona COLLATE DATABASE_DEFAULT 
and seats.seatrowa = replace(s.seatrow, ' ','')  COLLATE DATABASE_DEFAULT and  seats.seatseata  = s.seatseat and seats.customer = s.accountnumber COLLATE DATABASE_DEFAULT 
--and s.seatpricecode = odet.I_PT COLLATE DATABASE_DEFAULT 
where seats.season = @pacseason and seats.item = @pacitem 
 --and seatdetail_individual_history_id is not null
--group by  s.seatdetail_individual_history_id
) r
on t.seatdetail_individual_history_id = r.seatdetail_individual_history_id
 WHEN MATCHED THEN UPDATE SET  
 t.i_pl = r.i_pl,
 t.seq = r.seq, 
 t.ordergroupbottomlinegrandtotal = r.ordergroupbottomlinegrandtotal, 
 t.ordergrouptotalpaymentsonhold = r.ordergrouptotalpaymentsonhold,
 t.ordergrouptotalpaymentscleared = r.ordergrouptotalpaymentscleared,
 t.tixseatlastupdate  =  r.tixseatlastupdate ,
 t.seatpricecode = r.seatpricecodeA
 ; 
 
 
 --case when i_bal <= 0 then 'X' when i_pay+ i_cpay > 0 then 'P' else '' end paid, '' sent ,
--case when i_pay + i_bal + i_cpay <> 0 then (i_pay +  i_cpay)/(i_pay + i_bal + i_cpay) else 0 end paidpercent,null schpercent ,
--null ordernumber, origts_datetime ordergroupdate, odet.last_datetime ordergrouplastupdated, null tixseatgroupid ,
--null tixseatgrouppricelevel, null tixseatofferid ,i_price ticketvalue, case when i_oqty  <> 0 then  ( i_pay )/ i_oqty else 0 end ticketpaid , 
 
 
 
 
 merge seatdetail_individual_history r using 
(select seatdetail_individual_history_id, renewal_complete, renewal_date, min_ticketpaymentdate,ordergroupbottomlinegrandtotal, ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared , c.*,
case when c.min_trans_date is not null  or  ordergroupbottomlinegrandtotal - ordergrouptotalpaymentsonhold- ordergrouptotalpaymentscleared  <= 0 then 1 else 0 end new_renewal_complete
from 
(select ttl.CustomerID, -- AllocationID, --,
Season, 
min( [TransactionDate]) min_trans_date
 from
(
select 'Event' type,
     tkTransEv.Customer CustomerID
    ,tkItem.KEYWORD AllocationID
    ,tkTrans.[Date] as [TransactionDate]
    ,tktransEv.Date eventdate
    , tkTransEv.Season Season
    , tkTransEv.[Event] EventCode
    , tkTransEv.E_ITEM
    , tkTransEvPM.E_PAY_PAYMODE  [PaymentModeCode]  --!PD!--
    , sum(tkTransEvPM.E_PAY_PAMT) as [PaymentAmount] 
    , sum(case when tkTransEvPM.E_PAY_PAYMODE = 'PD' then tkTransEvPM.E_PAY_PAMT else 0 end) PD_PAID
    , sum(case when tkTransEvPM.E_PAY_PAYMODE = 'AXS' then tkTransEvPM.E_PAY_PAMT else 0 end) AXS_PAID
    , sum(case when tkTransEvPM.E_PAY_PAYMODE = 'PD' then 0 else tkTransEvPM.E_PAY_PAMT end) Other_PAID
   FROM  TK_Trans_Item_Event_PayMode(nolock) as tkTransEvPM
   LEFT OUTER JOIN TK_Trans_Item_Event(nolock) tkTransEv ON (tkTransEv.Season = tkTransEvPM.Season)
		and tkTransEV.Trans_No = tkTransEvPM.Trans_No
		and tkTransEV.VMC = tkTransEvPM.VMC
		and tkTransEV.SVMC = tkTransEvPM.SVMC
   LEFT OUTER JOIN  TK_Trans(nolock) tkTrans ON (tkTrans.Season = tkTransEvPM.Season)
		and tkTrans.Trans_no = tkTransEvPM.Trans_No
   JOIN  TK_ITEM (nolock) tkItem on tkItem.Season =  tkTransEvPM.Season  and tkTransEv.E_ITEM = tkItem.ITem 
               and  tag = 'DON-SYS'
    WHERE
      --and  (@SEASON = 'ALL' or (@SEASON <> 'ALL' AND TkTransEvPM.Season = @SEASON) )  
      TkTransEvPM.Season  = @pacseason
      and NOT(tkTrans.SOURCE like 'TK.ERES.SH.PURCHASE%')
      and NOT(tkTrans.SOURCE like 'ERES.ACCEPT.TRANSFER%')
      and ISNULL(tkTransEv.E_PT ,'emptypricetype')<>'emptypricetype'
      and tkItem.Basis in ('C', 'S') 
 group by  
    tkTrans.[Date]
    ,tktransEV.Date 
    ,tkTransEv.Season
    ,tkTransEv.[Event]
    ,tkTransEvPM.E_PAY_PAYMODE
    ,tkTransEv.Customer
    ,tkTransEv.E_ITEM
    ,tkItem.KEYWORD
UNION
  select 'Item' type,
          tkTransItem.Customer CustomerID
        , tkItem.KEYWORD AllocationID
        , tkTrans.[Date] as [TransactionDate]
        , tktransItem.Date eventdate
	, tkTransItem.Season Season
	, null EventCode
        , tkTransItem.ITEM
	, tkTransItemPM.I_PAY_PAYMODE  [PaymentModeCode]  --!PD!--
	, sum(tkTransItemPM.I_PAY_PAMT) as [PaymentAmount] 
        , sum(case when tkTransItemPM.I_PAY_PAYMODE = 'PD' then tkTransItemPM.I_PAY_PAMT else 0 end) PD_PAID
        , sum(case when tkTransItemPM.I_PAY_PAYMODE = 'AXS' then tkTransItemPM.I_PAY_PAMT else 0 end) AXS_PAID
        , sum(case when tkTransItemPM.I_PAY_PAYMODE = 'PD' then 0 else tkTransItemPM.I_PAY_PAMT end) Other_PAID 
  FROM   TK_Trans_Item_PayMode(nolock) as tkTransItemPM
	LEFT OUTER JOIN  TK_Trans_Item(nolock) tkTransItem ON (tkTransItem.Season = tkTransItemPM.Season)
		and tkTransItem.Trans_No = tkTransItemPM.Trans_No
		and tkTransItem.VMC = tkTransItemPM.VMC
	LEFT OUTER JOIN  TK_Trans(nolock) tkTrans ON (tkTrans.Season = tkTransItemPM.Season)
		and tkTrans.Trans_no = tkTransItemPM.Trans_No
       JOIN  TK_ITEM (nolock) tkItem on tkItem.Season = tkTransItemPM.Season 
                and tkTransItem.ITEM = tkItem.ITem and  tag = 'DON-SYS'
   WHERE
     -- (@SEASON = 'ALL' or (@SEASON <> 'ALL' AND tkTransItemPM.Season = @SEASON)) 
     tkTransItemPM.Season  = @pacseason
     and NOT(tkTrans.Source like 'TK.ERES.SH.PURCHASE%')
     and NOT(tkTrans.Source like 'ERES.ACCEPT.TRANSFER%')
     and NOT(tkItem.Basis  in ('C','S')) 
 group by 
    tkTrans.[Date]
    ,tktransItem.Date 
    ,tkTransItem.Season
    ,tkTransItemPM.I_PAY_PAYMODE
    ,tkTransItem.Customer
    ,tkTransItem.ITEM
    ,tkItem.KEYWORD
     ) ttl	group by ttl.CustomerID, sEASON --AllocationID 
     ) c join seatdetail_individual_history r1 on r1.accountnumber = c.customerid COLLATE DATABASE_DEFAULT and r1.pacseason = c.season COLLATE DATABASE_DEFAULT
     where r1.tixeventlookupid = @tixeventlookupid and cancel_ind is null
 ) tk 
on r.seatdetail_individual_history_id = tk.seatdetail_individual_history_id 
when matched 
then update
 set r.min_ticketpaymentdate= isnull(r.min_ticketpaymentdate,tk.min_trans_date),
 renewal_complete = isnull(r.renewal_complete,tk.new_renewal_complete),
 renewal_date = isnull(r.renewal_date ,tk.min_ticketpaymentdate)
     ; 
end
GO
