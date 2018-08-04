SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_SeatReconReport_table_pac] (
@pacseason varchar(30), @pacitem varchar(30)
--@tixeventlookupid varchar(50)
)

AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
reporttype 3 = all
*/

DECLARE @percent1 decimal
DECLARE @percent2 decimal
declare @percentdue decimal
--Declare @tixeventlookupid varchar(50)
Declare @sporttype varchar(20) 
Declare @ticketyear varchar(4)
Declare @tixeventlookupid varchar(20)

--set @sporttype= (select sporttype from amy.PriorityEvents pe1 where tixeventlookupid = @tixeventlookupid);
select  @sporttype= sporttype, @ticketyear = ticketyear , @tixeventlookupid = tixeventlookupid from amy.PriorityEvents pe1 where  pacseason = @pacseason and pacitem = @pacitem

delete from  amy.rpt_seatrecon_tb  where tixeventlookupid =  @tixeventlookupid

insert into amy.rpt_seatrecon_tb
select
--percentdue, 
adnumber, accountname, status, --   --seatregionname, seatregionid,
---*****-----cap_amount, annual_amount,
@sporttype sporttype,
"Ticket Total", 
isnull(CAP, 0) CAP, isnull(Annual,0) Annual,  CAPCredit, AnnualCredit,
isnull("Advantage Adjusted CAP Pledge",0)
"Advantage Adjusted CAP Pledge",
isnull("Adv CAP Pledge",0)
"Adv CAP Pledge",
isnull("Adv CAP Receipt AMount",0)
"Adv CAP Receipt AMount",
isnull("Adv CAP Match Pledge",0)
"Adv CAP Match Pledge",
isnull("Adv CAP Match Receipt",0)
"Adv CAP Match Receipt",
isnull("Adv CAP Credit",0)
"Adv CAP Credit",
isnull("Advantage Adjusted Annual Pledge",0) 
"Advantage Adjusted Annual Pledge" ,
isnull("Adv Annual  Pledge",0) 
"Adv Annual  Pledge",
isnull("Adv Annual Receipt",0)
"Adv Annual Receipt",
isnull("Adv Annual Match Pledge",0) 
"Adv Annual Match Pledge",
isnull("Adv Annual Match Receipt",0)
"Adv Annual Match Receipt", 
isnull("Adv Annual Credit",0)
"Adv Annual Credit", 
AnnualScheduledPayments scheduledpayments,
 capital_ada_credit_amount , ticketpaidpercent  ,ticketscheduledpercent , 
 isnull(CAP,0) - isnull( "Advantage Adjusted CAP Pledge", 0) 
 capdifference,
isnull(Annual,0) -  isnull("Advantage Adjusted Annual Pledge", 0)  annualdifference , 
isnull(CAP, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0) ) caprecdifference,
isnull(ANNUAL,0) - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) annualrecdifference  
--other fields
,ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, "Ticket Count", ALL_TICKETS, 
AnnualScheduledPayments, 
KFCScheduledPayments,
min_annual_receipt_date,
 -- @sporttype Sporttype, 
 @ticketyear Ticketyear, @tixeventlookupid TixEventLookupID, getdate() updatedate,
   cap_20, CAP_40,CAP_60, CAP_80, CAP_100, CAP_OTHER,  isnull(CAP_DUE, 0) CAP_DUE, LinealTransfer, 
 case when  isnull(CAP_DUE, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Pledge" ,0) +isnull(  "Adv CAP Credit",0) ) > 0 then 
 isnull(CAP_DUE, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Pledge" ,0) +isnull(  "Adv CAP Credit",0) ) else 0 end
 CapStillDue, 
 ordernumber, seatlastupdated , getdate() lastupdated ,
 ordergroupbottomlinegrandtotal,ordergrouptotalpaymentscleared,ordergrouptotalpaymentsonhold ,
 (select Type from dbo.TK_CUSTOMER  where customer = cast(adnumber as varchar)) vtxcusttype, 
 email, renewal_date, newtickets, min_ticketpaymentdate,
 null Renewable ,  null Renewed ,null Cancelled ,   null AddedItems , null NewItems , null renewal_complete, @pacseason pacseason, @pacitem pacitem
  from 
----------------------------------------------list
( select 
--isnull((select percentdue from amy.capital_percent cp where cp.adnumber = alltickets.adnumber and cp.sporttype = alltickets.sporttype and cp.ticketyear = @ticketyear), null) percentdue,
alltickets.adnumber, alltickets.accountname, alltickets.status,
--alltickets.seatregionname,
alltickets.sporttype,
--alltickets.seatregionid,
------**---- cap_amount, annual_amount,
ticketcount "Ticket Total",
 ticketing.CAP + advdata.new_cap_exp CAP,    ticketing.Annual,   ticketing.CAPCredit ,    ticketing.AnnualCredit,
 advdata.capital_pledge_trans_amount +  advdata.capital_pledge_match_amount+  advdata.capital_credit_amount "Advantage Adjusted CAP Pledge", 
 advdata.capital_pledge_trans_amount "Adv CAP Pledge",
  advdata.capital_receipt_trans_amount "Adv CAP Receipt AMount", 
  advdata.capital_pledge_match_amount "Adv CAP Match Pledge",
  advdata.capital_receipt_match_amount "Adv CAP Match Receipt", 
  advdata.capital_credit_amount "Adv CAP Credit",
  advdata.annual_pledge_trans_amount +  advdata.annual_pledge_match_amount+  advdata.annual_credit_amount  "Advantage Adjusted Annual Pledge",   
  advdata.annual_pledge_trans_amount "Adv Annual  Pledge",  
  advdata.annual_receipt_trans_amount "Adv Annual Receipt",
  advdata.annual_pledge_match_amount "Adv Annual Match Pledge",  
  advdata.annual_receipt_match_amount "Adv Annual Match Receipt",
  advdata.annual_credit_amount "Adv Annual Credit",
 ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, 
 ticketcount "Ticket Count"   , 
--  (select sum(qty) from seatdetail_flat where accountnumber =  alltickets.adnumber and tixeventlookupid =  @tixeventlookupid )
 ticketcount  ALL_TICKETS,
 isnull((  SELECT  sum(pmt_amount) sch_pay FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct  @sporttype sporttype, --seatregionid ,
programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL and t.transyear IN ( @ticketyear)
 AND t.contactid =  (select contactid from advcontact v where  v.adnumber= advdata.adnumber)
 and sa1.sporttype = alltickets.sporttype
 ), 0)  + 
isnull( (SELECT sum (transamount) ScheduledPayments
          FROM  dbo.advPaymentSchedule ps, 
          ( select  distinct @sporttype sporttype, --seatregionid , 
          programid from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ( @ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  (select contactid from advcontact v where  v.adnumber= advdata.adnumber)
               and sa1.sporttype = alltickets.sporttype
               ), 0) +
               isnull( (SELECT  sum(applyamount) ScheduledPayments
          FROM  amy.pac_ScheduledPaymentAllocation_vw ps, 
          ( select  distinct @sporttype sporttype, --seatregionid , 
       programcode from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0) sa1   
         WHERE     ps.allocationid= sa1.Programcode  collate database_default
               AND driveyear IN ( @ticketyear )    AND ps.accountid =  advdata.adnumber
               and sa1.sporttype = alltickets.sporttype
               ), 0)  +               
               + tkdonationscheduled   
               AnnualScheduledPayments , 
isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct @sporttype sporttype,  programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype  and isnull(sa.inactive_ind,0) =0) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL  and t.transyear IN ( @ticketyear)
 AND t.contactid =  (select contactid from advcontact v where  v.adnumber= advdata.adnumber)
 and sa1.sporttype= alltickets.sporttype
 ),0)  
 + 
 isnull( (SELECT sum (transamount) ScheduledPayments
          FROM advPaymentSchedule ps, 
  ( select  distinct @sporttype sporttype,   programid  from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ('CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =   (select contactid from advcontact v where  v.adnumber= advdata.adnumber)
               and sa1.sporttype = alltickets.sporttype                            
               ),0) KFCScheduledPayments,
                advdata.min_annual_receipt_date, 
                advdata.capital_ada_credit_amount,               
                 case when ordergroupbottomlinegrandtotal = 0 then 1 else ordergrouptotalpaymentscleared/ordergroupbottomlinegrandtotal end ticketpaidpercent  ,
                 case when ordergroupbottomlinegrandtotal <> 0 then ordergrouptotalpaymentsonhold/ordergroupbottomlinegrandtotal else 0 end ticketscheduledpercent, 
                 cap_20, CAP_40,CAP_60, CAP_80, CAP_100, CAP_OTHER, ticketing.CAP_DUE +advdata.new_cap_due CAP_DUE, 
                 LinealTransfer, 
                 case when ordernumbercount > 1 then -1 else ordernumber end ordernumber , seatlastupdated,
                ordergroupbottomlinegrandtotal,ordergrouptotalpaymentscleared,ordergrouptotalpaymentsonhold  , renewal_date ,
                alltickets.email, newtickets,min_ticketpaymentdate, advdata.new_cap_exp, advdata.new_cap_due, 
 donationbalance, tkdonationscheduled
--sregion.*
from 
-----------------------alltickets----------------------------------------------
(
select distinct @sporttype sporttype, --seatregionname, seatregionid,
pt.adnumber  , --cap_amount, annual_amount, 
 patron.mail_name accountname , patron.status, email.phone email
from (  ----pt
 select SportType, --sr.seatregionname, sr.seatregionid,
 acct adnumber --, sr.cap_amount, sr.annual_amount
from PacTranItem_alt_vw  p,
 (select  distinct
 sarea.sporttype, --  seatregionid, 
 programcode programcode  ,  ProgramTypeName, 
 programtypecode  --, programname
 from amy.SeatArea Sarea,  amy.SeatAllocation SAlloc1  ---with suites this is an issue since seatareas map to same seatallocation
    WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID and sarea.sporttype =  @sporttype and isnull(salloc1.inactive_ind,0) =0 
    ---and Sarea.SeatingType <> 'Suite'
    ) salloc   
      where p.AllocationID  = salloc.programcode   COLLATE DATABASE_DEFAULT  AND p.DriveYear =@ticketyear
      and (abs(p.MatchingPledgeAmt) +  abs(p.PledgeAmt) +  abs(p.MatchingPaymentAmt) + abs(p.PaymentAmt) + abs(p.CreditAmt)) <> 0
group by salloc.sporttype, acct
union all
select  distinct  @sporttype,   --sr.seatregionname, ct.seatregionid,
cast(ct.accountnumber as int) adnumber --,cap_amount, annual_amount
 from  seatdetail_individual_history ct    
          where  ct.tixeventlookupid =  @tixeventlookupid  
                 and ct.cancel_ind is null
 union all                
select  distinct  sporttype,   --sr.seatregionname, ct.seatregionid,
 adnumber --,cap_amount, annual_amount
 from  suiteallocations    where sporttype = @sporttype and renewalyear = @ticketyear
               ---- and accountnumber = 12
--group by  @sporttype, --sr.seatregionname,  ct.seatregionid, 
--cast(ct.accountnumber as int)  ,cap_amount, annual_amount
) pt  left join pd_patron patron on patron.patron =cast( pt.adnumber   as varchar)
left join dbo.PD_PATRON_PHONE_TYPE  email on phone_type = 'E' and email.patron = cast( pt.adnumber as varchar)
) alltickets
-----               end of all tickets
/************** ticketing ****************************/
left join 
    (   select  sporttype,
     adnumber, 
    sum(round(CAP,0) ) CAP,  
    sum(round(Annual,0)) Annual, 
    sum(round(CAPCredit,0) ) CAPCredit ,  
    sum(round(AnnualCredit,0))  AnnualCredit,
    sum(ADA) ADA,
    sum(E) E, 
    sum(EC) EC, 
    sum("ZC E") "ZC E",
    sum(Lettermen) Lettermen,  
    sum(FacultyAD) FacultyAD, 
    sum(Faculty) Faculty, 
    sum(DC) DC, 
    sum(Comp) Comp,
    sum(UO) UO,
    sum([UO-R]) [UO-R], 
    sum(singleseason ) singleseason, 
    sum(ticketcount) ticketcount , 
     sum(CAP_20) CAP_20, 
    sum( CAP_40) CAP_40, 
    sum( CAP_60) CAP_60, 
    sum( CAP_80) CAP_80, 
    sum( CAP_100) CAP_100,
    sum( CAP_Other) CAP_Other, 
    sum(round(CAP_DUE,0) ) CAP_DUE  ,
        sum( LinealTransfer) LinealTransfer, 
       max(ordernumber) ordernumber,  count(distinct ordernumber) ordernumbercount, 
        max(seatlastupdated) seatlastupdated, min(renewal_date) renewal_date, sum(newtickets) newtickets, 
        min(min_ticketpaymentdate) min_ticketpaymentdate 
        from (
 select -- seatregionname,
  --ct.seatregionid, 
  isnull(py.sporttype, @sporttype) sporttype, min(renewal_date) renewal_date,
  accountnumber adnumber, 
  --  sum(py.CAP * 1) /*qty*/   post cap move
0 CAP,  
    sum(py.Annual * 1 /*qty*/ ) Annual, 
    sum(py.CAPCredit * 1 /*qty*/ ) CAPCredit ,  
    sum(py.AnnualCredit * 1 /*qty*/ )  AnnualCredit,
    sum(case when seatpricecode like '%ADA%' or seatpricecode like '%WC%'  or seatpricecode in (
'NDA','NDA2','NDW','NFA','NFA2','NFW','NLA','NLA2','NLW','NNGA1','NNGW1','PA','PAV','PEA','PEAV','PSA','QRECA','QRECA2','QRECW','RDA','RDA2','RDAX','RDW','REA','REA2','RECA','RECA2','RECW','REW','RFA','RFA2','RFW','RLA','RLA2','RLW','RNGA2','RNGA3','RNGA4','RNGA5','RNGW2','RNGW3','RNGW4','RNGW5')  then  1 /*qty*/  else 0 end ) ADA,
    sum(case when seatpricecode in ('E','E Hold', 'E ADA','E ADA2', 'REA', 'REA2',  'RECH','RECW','REH', 'REW') then  1 /*qty*/  else 0 end ) E, 
    sum(case when seatpricecode in ('EC','EC Hold', 'EC ADA','EC ADA2' ,'EC WC',  'IEC', 'NSUEC', 'QIEC', 'QNSUEC', 'QREC', 'QRECA', 'QRECA2', 'QRECH', 'QRECW', 'QRSUEC', 'RECA', 'RECA2', 'RECH','RECW', 'RSUEC'  ) then  1 /*qty*/  else 0 end) EC, 
    sum(case when seatpricecode in ('ZC E','EC ZC') then  1 /*qty*/  else 0 end) "ZC E",
    sum(case when seatpricecode like 'Lettermen%'  or seatpricecode in ('NLA2','NLW','NL','NLA','RL','RLA','RLA2','RLW','RTDL') then 1 /*qty*/ else 0 end) Lettermen,  
    sum(case when seatpricecode in ( 'Faculty&Staff (AD)','RFAD','NFAD' )then  1 /*qty*/ else 0 end) FacultyAD, 
    sum(case when seatpricecode in ( 'Faculty&Staff','Faculty WC' ,'Faculty ADA','Faculty ADA2','RFA','RFA2','RF','RFW','RTDF','NF','NFA','NFA2','NFW')then  1 /*qty*/ else 0 end) Faculty, 
    sum(case when seatpricecode in ( 'DC' ,'QDC','QCDE')then  1 /*qty*/ else 0 end) DC, 
    sum(case when seatpricecode in ( 'Comp','Comp - Ann & Cap Donation Exempt','C','QC','CACDE','QCACDE','CDE' ,'QCSU') then  1 /*qty*/ else 0 end) Comp,
    sum(case when seatpricecode in ( 'UO','RU','NU','QRU') then  1 /*qty*/ else 0 end) UO,
    sum(case when seatpricecode in ( 'UO-R' ,'RUR','QRUR','NUR' ) then  1 /*qty*/ else 0 end) [UO-R], 
    sum(case when seatpricecode in ( '2015 Season Only (Non Renewable)' ) then  1 /*qty*/ else 0 end) singleseason, 
    sum(1) ticketcount , 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.2 then  1 /*qty*/ else 0 end) CAP_20, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.4 then  1 /*qty*/ else 0 end) CAP_40, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.6 then  1 /*qty*/ else 0 end) CAP_60, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.8 then  1 /*qty*/ else 0 end) CAP_80, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 1 then  1 /*qty*/ else 0 end) CAP_100,
    sum( case when  ct.CAP_Percent_Owe_ToDate not in (.2,.4,.6,.8,1) then  1 /*qty*/ else 0 end) CAP_Other, 
   -- sum(py.CAP * ct.CAP_Percent_Owe_ToDate )  Post CAP Move
   0  CAP_DUE  ,
        sum( case when  ct.lineal_transfer_received_ind = 1 then  1 /*qty*/ else 0 end) LinealTransfer, 
       ct.ordernumber ordernumber, -- count(distinct ordernumber) ordernumbercount, 
        max(ct.seatlastupdated) seatlastupdated,      
   sum(case when seatpricecode like  '%Request%'  or seatpricecode like 'N%' then  1 /*qty*/ else 0 end) NewTickets ,
     min(min_ticketpaymentdate) min_ticketpaymentdate
      from  amy.seatdetail_individual_history  ct  
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  @sporttype  and py.ticketyear =  @ticketyear
           where  ct.tixeventlookupid =  @tixeventlookupid   
          and cancel_ind is null   and 
         (ct.seatareaid is null or
          ct.seatareaid  in (select seatareaid from  seatarea  where  --((@sporttype = 'FB' and  isnull(seatingtype,'') <> 'Suite') or sporttype <> 'FB' )
            isnull(seatingtype,'') <> 'Suite' and sporttype = @sporttype
          )) 
       group by      isnull(py.sporttype,@sporttype),accountnumber ,   ct.ordernumber 
   union all
    select  --suite,
    isnull(pyq.sporttype, @sporttype) sporttype,
    min(renewal_date) renewal_date,
    isnull(cast( accountnumber as int), pyq.adnumber)  adnumber,
    isnull(CapitalTOTALamount,0) +isnull(CapitalOPTTOTALamount,0)  CAP, 
    isnull(AnnualTOTALamount,0) Annual,
    isnull( ECCCapitalTOTALamount,0) CAPCredit ,  
    isnull( ECCAnnualTOTALamount,0)  AnnualCredit,
sum(case when seatpricecode like '%ADA%' or seatpricecode like '%WC%'  or seatpricecode in (
'NDA','NDA2','NDW','NFA','NFA2','NFW','NLA','NLA2','NLW','NNGA1','NNGW1','PA','PAV','PEA','PEAV','PSA','QRECA','QRECA2','QRECW','RDA','RDA2','RDAX','RDW','REA','REA2','RECA','RECA2','RECW','REW','RFA','RFA2','RFW','RLA',
'RLA2','RLW','RNGA2','RNGA3','RNGA4','RNGA5','RNGW2','RNGW3','RNGW4','RNGW5')  then  1 /*qty*/  else 0 end ) ADA,
    sum(case when seatpricecode in ('E','E Hold', 'E ADA','E ADA2', 'REA', 'REA2',  'RECH','RECW','REH', 'REW') then  1 /*qty*/  else 0 end ) E, 
    sum(case when seatpricecode in ('EC','EC Hold', 'EC ADA','EC ADA2' ,'EC WC',  'IEC', 'NSUEC', 'QIEC', 'QNSUEC', 'QREC', 'QRECA', 'QRECA2', 'QRECH', 'QRECW', 'QRSUEC', 'RECA', 'RECA2', 'RECH','RECW', 'RSUEC'  ) then  1 /*qty*/  else 0 end) EC, 
    sum(case when seatpricecode in ('ZC E','EC ZC') then  1 /*qty*/  else 0 end) "ZC E",
    sum(case when seatpricecode like 'Lettermen%'  or seatpricecode in ('NLA2','NLW','NL','NLA','RL','RLA','RLA2','RLW','RTDL') then 1 /*qty*/ else 0 end) Lettermen,  
    sum(case when seatpricecode in ( 'Faculty&Staff (AD)','RFAD','NFAD' ) then  1 /*qty*/ else 0 end) FacultyAD, 
    sum(case when seatpricecode in ( 'Faculty&Staff','Faculty WC' ,'Faculty ADA','Faculty ADA2','RFA','RFA2','RF','RFW','RTDF','NF','NFA','NFA2','NFW') then  1 /*qty*/ else 0 end) Faculty, 
    sum(case when seatpricecode in ( 'DC' ,'QDC','QCDE')then  1 /*qty*/ else 0 end) DC, 
    sum(case when seatpricecode in ( 'Comp','Comp - Ann & Cap Donation Exempt','C','QC','CACDE','QCACDE','CDE' ,'QCSU') then  1 /*qty*/ else 0 end) Comp,
    sum(case when seatpricecode in ( 'UO','RU','NU','QRU')then  1 /*qty*/ else 0 end) UO,
    sum(case when seatpricecode in ( 'UO-R' ,'RUR','QRUR','NUR' )then  1 /*qty*/ else 0 end) [UO-R], 
    sum(case when seatpricecode in ( '2015 Season Only (Non Renewable)' )then  1 /*qty*/ else 0 end) singleseason, 
    sum(1)  ticketcount ,
     sum( case when  ct.CAP_Percent_Owe_ToDate = 0.2 then  1 /*qty*/ else 0 end) CAP_20, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.4 then  1 /*qty*/ else 0 end) CAP_40, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.6 then  1 /*qty*/ else 0 end) CAP_60, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.8 then  1 /*qty*/ else 0 end) CAP_80, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 1 then  1 /*qty*/ else 0 end) CAP_100,
    sum( case when  ct.CAP_Percent_Owe_ToDate not in (.2,.4,.6,.8,1) then  1 /*qty*/ else 0 end) CAP_Other, 
    isnull(pyq.Capitalamountexpected,0) + isnull(pyq.CapitalOPTamountexpected,0)  CAP_DUE  ,
        sum( case when  ct.lineal_transfer_received_ind = 1 then  1 /*qty*/ else 0 end) LinealTransfer, 
       ct.ordernumber ordernumber, -- count(distinct ordernumber) ordernumbercount, 
        max(ct.seatlastupdated) seatlastupdated,
       sum(case when seatpricecode like  '%Request%' then  1 /*qty*/ else 0 end) NewTickets ,
         min(min_ticketpaymentdate) min_ticketpaymentdate
from [amy].[playbookpricegroupseatarea_suite] pyq 
       left  join  amy.seatdetail_individual_history  ct  on  ct.seatsection = pyq.suite and cast(ct.accountnumber as int) = pyq.adnumber   --and pyq.pricecodecode = ct.seatpricecode  
       and cancel_ind is null 
       and ct.seatareaid  in (select seatareaid from seatarea where sporttype =@sporttype   and isnull(seatingtype,'')  = 'Suite')  
           and ct.tixeventlookupid =  @tixeventlookupid   
                  where     pyq.sporttype =  @sporttype  and pyq.ticketyear =  @ticketyear
    group by    -- suite,
    isnull(pyq.sporttype,@sporttype), isnull(cast( accountnumber as int), pyq.adnumber),   ct.ordernumber, 
       isnull(CapitalTOTALamount,0) +isnull(CapitalOPTTOTALamount,0)  , 
       isnull(AnnualTOTALamount,0) ,  isnull(ECCCapitalTOTALamount,0)  ,     isnull(ECCAnnualTOTALamount,0) ,isnull(pyq.Capitalamountexpected ,0)+ isnull(pyq.CapitalOPTamountexpected ,0)
        )  orderlevel group by adnumber, sporttype       
       ) ticketing       
       ------------------ticketing end----------------
  on alltickets.sporttype= ticketing.sporttype and alltickets.adnumber = ticketing.adnumber
    ---------ticketingordertotals
left join   (
select adnumber,
--case when  ordergroupbottomlinegrandtotal > 0  then  ordergrouptotalpaymentscleared /ordergroupbottomlinegrandtotal else 0 end tickpaidpercent, 
--case when  ordergroupbottomlinegrandtotal > 0  then  isnull(bamt,0) /ordergroupbottomlinegrandtotal else 0 end  ticketscheduledpercent,
ordergroupbottomlinegrandtotal,  ordergrouptotalpaymentscleared ,
case when isnull(bamt,0) < donationbalance then 0 else  isnull(bamt,0)  -donationbalance end  ordergrouptotalpaymentsonhold,
donationbalance,
case when isnull(bamt,0) < donationbalance then  isnull(bamt,0) else donationbalance end  tkdonationscheduled
from 
 (  select customer adnumber, season,   sum( case when odet.item not in ('DON','FSD', 'DFS','DWS','DMS','MSD','WSD') then  (i_pay + i_bal + i_cpay) else 0 end ) ordergroupbottomlinegrandtotal,
 sum( case when odet.item not in ('DON','FSD', 'DFS','DWS','DMS','MSD','WSD') then (i_pay + i_cpay) else 0 end ) ordergrouptotalpaymentscleared ,
 sum(case when odet.item  in ('DON','FSD', 'DFS','DWS','DMS','MSD','WSD') then (i_bal )  else 0 end) donationbalance
from dbo.tk_odet odet  
where  odet.season = @pacseason  --and odet.item not in ('DON','FSD', 'DFS','DWS','DMS','MSD','WSD')
group by customer, season) odetsum
left join  (select season, customer, sum(bamt) bamt from tk_bplan where season = @pacseason and bdate > getdate() and vmc <> 1
group by season, customer ) b 
on b.season = odetsum.season and b.customer =  odetsum.adnumber) ticketingtotals
     on alltickets.adnumber = ticketingtotals.adnumber
  -------------------advdata start-----------------------------------------
left join (
 select salloc.sporttype,   --seatregionid,
 acct adnumber, --receiptid,
   min (case when SAlloc.ProgramTypeCode = 'Annual' then Receiveddate else null end) min_annual_receipt_date,
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' THEN isnull(PledgeAmt,0) ELSE 0 END) annual_pledge_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' THEN isnull(PaymentAmt,0) ELSE 0 END) annual_receipt_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' THEN isnull(MatchingPledgeAmt,0) ELSE 0 END) annual_pledge_match_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' THEN isnull(MatchingPaymentAmt,0) ELSE 0 END) annual_receipt_match_amount, 
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Annual Credit%') or (SAlloc.ProgramTypeName LIKE 'Annual' and CreditAmt <> 0 ) THEN  isnull(CreditAmt,0)  ELSE    0   END)  annual_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' THEN isnull(PledgeAmt,0) ELSE 0 END) capital_pledge_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' THEN isnull(PaymentAmt,0) ELSE 0 END) capital_receipt_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' THEN isnull(MatchingPledgeAmt,0) ELSE 0 END) capital_pledge_match_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' THEN isnull(MatchingPaymentAmt,0) ELSE 0 END) capital_receipt_match_amount,   
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Capital Credit%' ) or (SAlloc.ProgramTypeName ='Capital' and CreditAmt <> 0 ) THEN   isnull(CreditAmt,0)  ELSE  0  END) capital_credit_amount,
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE 'ADA Capital Credit' ) THEN   isnull(CreditAmt,0) ELSE  0  END) capital_ada_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' and seattype= 'Regular' THEN isnull(PledgeAmt,0)+ isnull(MatchingPledgeAmt,0) ELSE 0 END) new_cap_exp,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' and seattype= 'Regular' and capyearstart<= @ticketyear THEN isnull(PledgeAmt,0)+ isnull(MatchingPledgeAmt,0) ELSE 0 END) new_cap_due  
from PacTranItem_alt_vw  p,
 (select  distinct  case when  Sarea.SeatingType = 'Suite' then 'Suite' else 'Regular' end Seattype,
 sarea.sporttype, --  seatregionid, 
 trim(programcode) programcode  ,  ProgramTypeName, 
 programtypecode  --, programname
 , isnull(capyearstart, @ticketyear) capyearstart
 from amy.SeatArea Sarea,  amy.SeatAllocation SAlloc1  ---with suites this is an issue since seatareas map to same seatallocation
    WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID and sarea.sporttype =  @sporttype and isnull(salloc1.inactive_ind,0) =0 
   -- and Sarea.SeatingType <> 'Suite'
    ) salloc 
      where p.AllocationID  = salloc.programcode   COLLATE DATABASE_DEFAULT  AND p.DriveYear IN ( @ticketyear, 0)
group by salloc.sporttype, acct
) advdata 
------------advdata end----------------------
on alltickets.sporttype = advdata.sporttype and alltickets.adnumber= advdata.adnumber
-------------------------------------------------------------------------
-------------------------------------------------------------------------
) list
--and accountname is not null

   MERGE amy.rpt_seatrecon_tb  sih
 USING ( select adnumber, tixeventlookupid, tt.email from amy.rpt_seatrecon_tb  tb, amy.email_feed_vw  tt  where cast(tb.adnumber as varchar) = tt.accountnumber 
 and tixeventlookupid =@tixeventlookupid and tb.email is null ) rr
ON sih.adnumber = rr.adnumber  and sih.tixeventlookupid = rr.tixeventlookupid
 WHEN MATCHED THEN UPDATE SET sih.email = rr.email ;
 
   MERGE amy.rpt_seatrecon_tb  sih
 USING (
 select accountnumber, tixeventlookupid,
 max(1) renewal_complete,
 SUM(CASE WHEN s.renewal_ticket = 1  THEN 1 ELSE 0 END ) Renewable , 
 SUM (CASE WHEN renewal_ticket = 1  AND CANCEL_IND IS NULL THEN 1 ELSE 0 END ) Renewed ,

 SUM (CASE WHEN s.addonticket = 1    AND CANCEL_IND IS NULL THEN 1 ELSE 0 END ) AddedItems ,
 SUM (CASE WHEN  new_ticket = 1   AND CANCEL_IND IS NULL THEN 1 ELSE 0 END ) NewItems 
 FROM seatdetail_individual_history s
 where tixeventlookupid = @tixeventlookupid
 and accountnumber in ( select  adnumber 
  from rpt_seatrecon_tb y  where tixeventlookupid = @tixeventlookupid
  and   case when  renewal_date is not null then 1 
  when isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   <= 0  and 
  y.ordergroupbottomlinegrandtotal - y.ordergrouptotalpaymentscleared-  y.ordergrouptotalpaymentsonhold <=0 then 1 else 0 end  =1
)
 group by accountnumber, tixeventlookupid) rr
ON sih.adnumber = rr.accountnumber  and sih.tixeventlookupid = rr.tixeventlookupid
 WHEN MATCHED THEN UPDATE SET sih.renewal_complete = rr.renewal_complete,
 --sih.Renewable = rr.renewable , 
 sih.Renewed  = rr.renewed, 
 sih.AddedItems  = rr.addeditems,
 sih.NewItems = rr.newitems ;
 
    MERGE amy.rpt_seatrecon_tb  sih
 USING (
 select accountnumber, tixeventlookupid,
 SUM(CASE WHEN s.renewal_ticket = 1  AND RELOCATION_START_IND IS NULL   THEN 1 ELSE 0 END ) Renewable,
SUM (CASE WHEN renewal_ticket = 1  AND RELOCATION_RELEASE_IND IS NULL  AND CANCEL_IND IS NOT  NULL THEN 1 ELSE 0 END ) Cancelled  
 FROM seatdetail_individual_history S
 where tixeventlookupid = @tixeventlookupid
AND ISNULL(S.relocation_start_ind,0) = 0
 group by accountnumber, tixeventlookupid) rr
ON sih.adnumber = rr.accountnumber  and sih.tixeventlookupid = rr.tixeventlookupid
 WHEN MATCHED THEN UPDATE SET 
 sih.Renewable = rr.renewable,
  sih.Cancelled  = rr.cancelled;
GO
