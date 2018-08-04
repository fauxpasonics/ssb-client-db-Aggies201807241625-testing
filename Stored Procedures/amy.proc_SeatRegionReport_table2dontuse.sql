SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_SeatRegionReport_table2dontuse] (@sporttype varchar(20) = 'FB', @ticketyear varchar(4)= '2016', @reporttype int =2 )
AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
*/

DECLARE @percent1 numeric (1,1)
DECLARE @percent2 numeric (1,1)
declare @percentdue numeric (1,1)
Declare @tixeventlookupid varchar(50)



set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

if @ticketyear = '2015'
begin
SET @percent1   = .4;
SET @percent2   = .2;
end


if @ticketyear = '2016'
begin
SET @percent1   = .6;
SET @percent2   = .4;
end

if @ticketyear = '2017'
begin
SET @percent1   = .8;
SET @percent2   = .6;
end

if @ticketyear = '2018'
begin
SET @percent1   = 1;
SET @percent2   = .8;
end

if @ticketyear >= '2019'
begin
SET @percent1   = 1;
SET @percent2   = 1;
end

--delete from  RPT_SEATREGION_TB where sporttype = @sporttype and ticketyear = @ticketyear;

--insert into RPT_SEATREGION_TB
select
percentdue, 
adnumber, accountname, status, seatregionname, seatregionid, cap_amount, annual_amount, "Ticket Total", 
CAP, Annual, CAPCredit, AnnualCredit,"Advantage Adjusted CAP Pledge","Adv CAP Pledge","Adv CAP Receipt AMount","Adv CAP Match Pledge","Adv CAP Match Receipt",
"Adv CAP Credit","Advantage Adjusted Annual Pledge","Adv Annual  Pledge","Adv Annual Receipt","Adv Annual Match Pledge","Adv Annual Match Receipt","Adv Annual Credit", 
ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, "Ticket Count", ALL_TICKETS, 
isnull(CAP,0) - isnull( "Advantage Adjusted CAP Pledge", 0)   capdifference,
isnull(Annual,0) -  isnull("Advantage Adjusted Annual Pledge", 0)  annualdifference , 
isnull(CAP, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0) ) caprecdifference,
isnull(ANNUAL,0) - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) annualrecdifference ,
AnnualScheduledPayments, KFCScheduledPayments,
 min_annual_receipt_date,
 capital_ada_credit_amount , @sporttype Sporttype, @ticketyear Ticketyear, @tixeventlookupid TixEventLookupID, getdate() updatedate,
 ticketpaidpercent  ,  
  ticketscheduledpercent,
 cap_20, CAP_40,CAP_60, CAP_80, CAP_100, CAP_OTHER, CAP_DUE, LinealTransfer, 
 isnull(CAP_DUE, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0) ) CapStillDue, 
 ordernumber,
 seatlastupdated  into   RPT_SEATREGION_TB2 from 
----------------------------------------------list
( select 
isnull((select percentdue from amy.capital_percent cp where cp.adnumber = alltickets.adnumber and cp.seatregionid  = alltickets.seatregionid and cp.ticketyear = @ticketyear), null) percentdue,
alltickets.adnumber, alltickets.accountname, alltickets.status,
alltickets.seatregionname, alltickets.seatregionid,
cap_amount, annual_amount,
ticketcount "Ticket Total",
 ticketing.CAP,    ticketing.Annual,   ticketing.CAPCredit ,    ticketing.AnnualCredit,
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
 ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, ticketcount "Ticket Count"   , 
--  (select sum(qty) from seatdetail_flat where accountnumber =  alltickets.adnumber and tixeventlookupid =  @tixeventlookupid )
null ALL_TICKETS,
 isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct seatregionid , programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = advdata.ContactID 
 and sa1.SeatRegionID = alltickets.seatregionid 
 ), 0)  + 
isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM  dbo.advPaymentSchedule ps, 
          ( select  distinct seatregionid , programid from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype ) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ( @ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sa1.seatregionid = alltickets.seatregionid
               ), 0) AnnualScheduledPayments , 
isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct seatregionid , programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype  ) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = advdata.ContactID 
 and sa1.SeatRegionID = alltickets.seatregionid 
 ),0)  
 + 
 isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM advPaymentSchedule ps, 
  ( select  distinct seatregionid , programid  from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype ) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ('CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sa1.seatregionid = alltickets.seatregionid                             
               ),0) KFCScheduledPayments,
                advdata.min_annual_receipt_date, 
                advdata.capital_ada_credit_amount,
 case when (ordergroupbottomlinegrandtotal) <> 0 then  ordergrouptotalpaymentscleared  /ordergroupbottomlinegrandtotal else 0 end  ticketpaidpercent  ,  
 case when (ordergroupbottomlinegrandtotal) <> 0 then  ordergrouptotalpaymentsonhold  /ordergroupbottomlinegrandtotal else 0 end      ticketscheduledpercent,
                 cap_20, CAP_40,CAP_60, CAP_80, CAP_100, CAP_OTHER, CAP_DUE, LinealTransfer, 
                 case when ordernumbercount > 1 then -1 else ordernumber end ordernumber , 
                 seatlastupdated
--sregion.*
from 
-----------------------alltickets----------------------------------------------
(select distinct seatregionname, seatregionid, pt.adnumber ,cap_amount, annual_amount, accountname, status
from (  ----pt
 select sr.seatregionname, sr.seatregionid, adnumber, sr.cap_amount, sr.annual_amount FROM 
 advcontact c,advcontacttransheader h,advcontacttranslineitems l,
 advProgram p,
amy.SeatArea Sarea,
amy.seatregion sr, 
amy.SeatAllocation SAlloc
         WHERE  Sarea.SeatAreaID = SAlloc.SeatAreaID
                AND l.ProgramID = SAlloc.ProgramID
                AND c.contactid = h.contactid
                AND h.TransID = l.TransID
                AND p.ProgramID = l.ProgramID
                AND transyear IN ( @ticketyear, 'CAP')
                and (matchinggift = 0 or matchinggift is null)
                and Sarea.SportType =  @sporttype 
                and Sarea.SeatRegionID = sr.SeatRegionID
group by sr.seatregionname, sr.seatregionid, adnumber ,sr.cap_amount, sr.annual_amount
having sum(transamount) <> 0 
union all
select     sr.seatregionname, ct.seatregionid, cast(ct.accountnumber as int) adnumber,cap_amount, annual_amount
  from  seatdetail_individual_history ct,   
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @tixeventlookupid  and
                 sr.seatregionid= ct.seatregionid 
                 and ct.cancel_ind is null
group by sr.seatregionname,  ct.seatregionid, cast(ct.accountnumber as int)  ,cap_amount, annual_amount
) pt  left join advcontact con on con.adnumber = pt.adnumber 
) alltickets
-----               end of all tickets
/************** ticketing ****************************/
left join (
select  seatregionid,
     adnumber, 
    sum(CAP ) CAP,  
    sum(Annual) Annual, 
    sum(CAPCredit ) CAPCredit ,  
    sum(AnnualCredit)  AnnualCredit,
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
    sum(CAP_DUE ) CAP_DUE  ,
        sum( LinealTransfer) LinealTransfer, 
       max(ordernumber) ordernumber,  count(distinct ordernumber) ordernumbercount,       
        max(seatlastupdated) seatlastupdated, min(renewal_date) renewal_date,
            sum(ordergroupbottomlinegrandtotal) ordergroupbottomlinegrandtotal, 
    sum(ordergrouptotalpaymentscleared) ordergrouptotalpaymentscleared, 
    sum(ordergrouptotalpaymentsonhold) ordergrouptotalpaymentsonhold
  from  (
  --orderlevel
  select -- seatregionname,
  ct.seatregionid,  cast(accountnumber as int)  adnumber, ct.ordernumber, ct.ordergroupbottomlinegrandtotal, ct.ordergrouptotalpaymentsonhold, ct.ordergrouptotalpaymentscleared,
    sum(sapg.CAP * 1 /*qty*/ ) CAP,  
    sum(sapg.Annual * 1 /*qty*/ ) Annual, 
    sum(sapg.CAPCredit * 1 /*qty*/ ) CAPCredit ,  
    sum(sapg.AnnualCredit * 1 /*qty*/ )  AnnualCredit,
    sum(case when seatpricecode like '%ADA%' or seatpricecode like '%WC%' then  1 /*qty*/  else 0 end ) ADA,
    sum(case when seatpricecode in ('E','E Hold', 'E ADA','E ADA2' ) then  1 /*qty*/  else 0 end ) E, 
    sum(case when seatpricecode in ('EC','EC Hold', 'EC ADA','EC ADA2' ,'EC WC') then  1 /*qty*/  else 0 end) EC, 
    sum(case when seatpricecode in ('ZC E','EC ZC') then  1 /*qty*/  else 0 end) "ZC E",
    sum(case when seatpricecode like 'Lettermen%' then 1 /*qty*/ else 0 end) Lettermen,  
    sum(case when seatpricecode in ( 'Faculty&Staff (AD)' )then  1 /*qty*/ else 0 end) FacultyAD, 
    sum(case when seatpricecode in ( 'Faculty&Staff','Faculty WC' ,'Faculty ADA','Faculty ADA2')then  1 /*qty*/ else 0 end) Faculty, 
    sum(case when seatpricecode in ( 'DC' )then  1 /*qty*/ else 0 end) DC, 
    sum(case when seatpricecode in ( 'Comp','Comp - Ann & Cap Donation Exempt' )then  1 /*qty*/ else 0 end) Comp,
    sum(case when seatpricecode in ( 'UO' )then  1 /*qty*/ else 0 end) UO,
    sum( case when seatpricecode in ( 'UO-R' )then  1 /*qty*/ else 0 end) [UO-R], 
    sum(case when seatpricecode in ( '2015 Season Only (Non Renewable)','Season Only (Non Renewable)' )then  1 /*qty*/ else 0 end) singleseason,  
    sum(1) ticketcount ,  
  --  min(ct.paidpercent) ticketpaidpercent  ,  
   -- min(ct.schpercent) ticketscheduledpercent,
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.2 then  1 /*qty*/ else 0 end) CAP_20, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.4 then  1 /*qty*/ else 0 end) CAP_40, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.6 then  1 /*qty*/ else 0 end) CAP_60, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 0.8 then  1 /*qty*/ else 0 end) CAP_80, 
    sum( case when  ct.CAP_Percent_Owe_ToDate = 1 then  1 /*qty*/ else 0 end) CAP_100,
        sum( case when  ct.CAP_Percent_Owe_ToDate not in (.2,.4,.6,.8,1) then  1 /*qty*/ else 0 end) CAP_Other,
    sum(sapg.CAP * ct.CAP_Percent_Owe_ToDate ) CAP_DUE  ,
        sum( case when  ct.lineal_transfer_received_ind = 1 then  1 /*qty*/ else 0 end) LinealTransfer, 
     --   max(ct.ordernumber) ordernumber, count(distinct ordernumber) ordernumbercount, 
        max(ct.seatlastupdated) seatlastupdated,  min(renewal_date) renewal_date
        from   amy.seatdetail_individual_history  ct, 
               amy.PriceCodebyYear py,
               amy.seatareapricegroup sapg
          where
          ct.tixeventlookupid =  @tixeventlookupid   
          and py.sporttype =  @sporttype  and py.ticketyear =  @ticketyear 
          and py.PriceCodeCode    = ct.seatpricecode        
          and  sapg.SeatAreaID  =  cast(ct.seatareaid as int)
          and sapg.pricegroupid = py.PriceGroupID  
          and sapg.sporttype =  @sporttype   and sapg.ticketyear =  @ticketyear   
          and cancel_ind is null
       group by         ct.seatregionid, cast( accountnumber as int) ,  
              ct.schpercent , ct.paidpercent  ,  ct.ordergroupbottomlinegrandtotal, ct.ordergrouptotalpaymentscleared, ct.ordergrouptotalpaymentsonhold,  ct.ordernumber
              )  orderlevel group by adnumber, seatregionid  
       ) ticketing       
       ------------------ticketing end----------------
  on alltickets.seatregionid = ticketing.seatregionid and alltickets.adnumber = ticketing.adnumber
  -------------------advdata start-----------------------------------------
left join (
 select  seatregionid, adnumber, h.contactid, --receiptid,
   min (case when  SAlloc.ProgramTypeName = 'Annual' and transtype = 'Cash Receipt' then transdate else null end) min_annual_receipt_date,
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%'  THEN l.TransAmount ELSE 0 END) annual_pledge_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN l.TransAmount ELSE 0 END) annual_receipt_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%'  THEN l.MatchAmount ELSE 0 END) annual_pledge_match_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN l.matchamount ELSE 0 END) annual_receipt_match_amount, 
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Annual Credit%') or (SAlloc.ProgramTypeName LIKE 'Annual' and transtype = 'Credit') THEN  l.TransAmount+ l.MatchAmount  ELSE    0   END)  annual_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Pledge%'   THEN l.TransAmount ELSE 0 END) capital_pledge_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Receipt%'  THEN l.TransAmount ELSE 0 END) capital_receipt_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Pledge%'   THEN l.matchamount ELSE 0 END) capital_pledge_match_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital'  AND transtype LIKE '%Receipt%' THEN l.matchamount ELSE 0 END) capital_receipt_match_amount,   
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Capital Credit%' ) or (SAlloc.ProgramTypeName ='Capital' and transtype = 'Credit') THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_credit_amount,
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE 'ADA Capital Credit' and transtype = 'Credit') THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_ada_credit_amount
 FROM advcontact c,advcontacttransheader h,advcontacttranslineitems l,advProgram p,
 (select distinct seatregionid,  programid, ProgramTypeName, programtypecode 
 from amy.SeatArea Sarea,  amy.SeatAllocation SAlloc1  ---with suites this is an issue since seatareas map to same seatallocation
         WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID and sarea.sporttype =  @sporttype ) salloc 
where l.ProgramID = SAlloc.ProgramID
AND c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND transyear IN ( @ticketyear, 'CAP')
and (matchinggift = 0 or matchinggift is null)
group by seatregionid, adnumber,h.contactid 
having sum(l.transamount+l.matchamount) <> 0 
) advdata 
------------advdata end----------------------
on alltickets.seatregionid = advdata.seatregionid and alltickets.adnumber= advdata.adnumber
-------------------------------------------------------------------------
-------------------------------------------------------------------------
) list
--where  seatregionname not like '%Suite%'  



--alter table RPT_SEATREGION_TB add ticketpaidpercent  numeric(19, 4), ticketscheduledpercent  numeric(19, 4)
/*insert into  RPT_SEATREGION_TB
select
percentdue, 
adnumber, accountname, status, seatregionname, seatregionid, cap_amount, annual_amount, "Ticket Total", 
CAP, Annual, CAPCredit, AnnualCredit,"Advantage Adjusted CAP Pledge","Adv CAP Pledge","Adv CAP Receipt AMount","Adv CAP Match Pledge","Adv CAP Match Receipt",
"Adv CAP Credit","Advantage Adjusted Annual Pledge","Adv Annual  Pledge","Adv Annual Receipt","Adv Annual Match Pledge","Adv Annual Match Receipt","Adv Annual Credit", 
ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, "Ticket Count", ALL_TICKETS, 
isnull(CAP,0) - isnull( "Advantage Adjusted CAP Pledge", 0)   capdifference,
isnull(Annual,0) -  isnull("Advantage Adjusted Annual Pledge", 0)  annualdifference , 
isnull(CAP, 0)   - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0) ) caprecdifference,
isnull(ANNUAL,0) - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) annualrecdifference ,
AnnualScheduledPayments, KFCScheduledPayments,
 min_annual_receipt_date,
 capital_ada_credit_amount , @sporttype Sporttype, @ticketyear Ticketyear, @tixeventlookupid TixEventLookupID, getdate() updatedate,
 ticketpaidpercent  ,ticketscheduledpercent  from 
----------------------------------------------list
( select 
isnull((select percentdue from amy.capital_percent cp where cp.adnumber = alltickets.adnumber and cp.seatregionid  = alltickets.seatregionid and cp.ticketyear = @ticketyear), @percent1) percentdue,
alltickets.adnumber, alltickets.accountname, alltickets.status,
alltickets.seatregionname, alltickets.seatregionid,
cap_amount, annual_amount,
ticketcount "Ticket Total",
 ticketing.CAP,    ticketing.Annual,   ticketing.CAPCredit ,    ticketing.AnnualCredit,
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
 ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, ticketcount "Ticket Count"   , 
--  (select sum(qty) from seatdetail_flat where accountnumber =  alltickets.adnumber and tixeventlookupid =  @tixeventlookupid )
null ALL_TICKETS,
 isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct seatregionid , programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = advdata.ContactID 
 and sa1.SeatRegionID = alltickets.seatregionid 
 ), 0)  + 
isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM  dbo.advPaymentSchedule ps, 
          ( select  distinct seatregionid , programid from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype ) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ( @ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sa1.seatregionid = alltickets.seatregionid
               ), 0) AnnualScheduledPayments , 
isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct seatregionid , programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype  ) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = advdata.ContactID 
 and sa1.SeatRegionID = alltickets.seatregionid 
 ),0)  
 + 
 isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM advPaymentSchedule ps, 
  ( select  distinct seatregionid , programid  from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype ) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ('CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sa1.seatregionid = alltickets.seatregionid                             
               ),0) KFCScheduledPayments,
                advdata.min_annual_receipt_date, 
                advdata.capital_ada_credit_amount,
                 ticketpaidpercent  ,ticketscheduledpercent
--sregion.*
from 
-----------------------alltickets----------------------------------------------
(select distinct seatregionname, seatregionid, pt.adnumber ,cap_amount, annual_amount, accountname, status
from (  ----pt
 select sr.seatregionname, sr.seatregionid, adnumber, sr.cap_amount, sr.annual_amount FROM 
 advcontact c,advcontacttransheader h,advcontacttranslineitems l,
 advProgram p,
amy.SeatArea Sarea,
amy.seatregion sr, 
amy.SeatAllocation SAlloc
         WHERE  Sarea.SeatAreaID = SAlloc.SeatAreaID
                AND l.ProgramID = SAlloc.ProgramID
                AND c.contactid = h.contactid
                AND h.TransID = l.TransID
                AND p.ProgramID = l.ProgramID
                AND transyear IN ( @ticketyear, 'CAP')
                and (matchinggift = 0 or matchinggift is null)
                and Sarea.SportType =  @sporttype 
                and Sarea.SeatRegionID = sr.SeatRegionID
group by sr.seatregionname, sr.seatregionid, adnumber ,sr.cap_amount, sr.annual_amount
having sum(transamount) <> 0 
union all
select     sr.seatregionname, ks.seatregionid, cast(ct.accountnumber as int) adnumber,cap_amount, annual_amount
  from  seatdetail_flat ct, 
               amy.VenueSections  ks ,        
               amy.SeatRegion sr
          where  ct.tixeventlookupid =  @tixeventlookupid  and
          ks.sporttype     =  @sporttype  
          and ct.seatsection      = ks.sectionnum 
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid 
group by sr.seatregionname,  ks.seatregionid, cast(ct.accountnumber as int)  ,cap_amount, annual_amount
) pt join advcontact con on con.adnumber = pt.adnumber 
) alltickets
-----               end of all tickets
/************** ticketing ****************************/
left join (
  select -- seatregionname,
  ks.seatregionid,  cast(accountnumber as int)  adnumber, 
    sum(sapg.CAP * qty ) CAP,  
    sum(sapg.Annual * qty) Annual, 
    sum(sapg.CAPCredit * qty) CAPCredit ,  
    sum(sapg.AnnualCredit * qty)  AnnualCredit,
    sum(case when seatpricecode like '%ADA%' or seatpricecode like '%WC%' then qty else 0 end ) ADA,
    sum(case when seatpricecode in ('E','E Hold', 'E ADA','E ADA2' ) then qty else 0 end ) E, 
    sum(case when seatpricecode in ('EC','EC Hold', 'EC ADA','EC ADA2' ,'EC WC') then qty else 0 end) EC, 
    sum(case when seatpricecode in ('ZC E','EC ZC') then qty else 0 end) "ZC E",
    sum(case when seatpricecode like 'Lettermen%' then qty else 0 end) Lettermen,  
    sum(case when seatpricecode in ( 'Faculty&Staff (AD)' )then qty else 0 end) FacultyAD, 
    sum(case when seatpricecode in ( 'Faculty&Staff','Faculty WC' ,'Faculty ADA','Faculty ADA2')then qty else 0 end) Faculty, 
    sum(case when seatpricecode in ( 'DC' )then qty else 0 end) DC, 
    sum(case when seatpricecode in ( 'Comp','Comp - Ann & Cap Donation Exempt' )then qty else 0 end) Comp,
    sum(case when seatpricecode in ( 'UO' )then qty else 0 end) UO,
    sum( case when seatpricecode in ( 'UO-R' )then qty else 0 end) [UO-R], 
    sum(case when seatpricecode in ( '2015 Season Only (Non Renewable)' )then qty else 0 end) singleseason, 
    sum(qty) ticketcount ,  ct.paidpercent ticketpaidpercent  ,  ct.schpercent ticketscheduledpercent
               from   
               seatdetail_flat ct, 
               amy.PriceCodebyYear py,
               amy.VenueSections  ks  ,
               amy.seatareapricegroup sapg
          where
          ct.tixeventlookupid =  @tixeventlookupid   
          and py.sporttype =  @sporttype  and py.ticketyear =  @ticketyear 
          and py.PriceCodeCode    = ct.seatpricecode
          and ct.seatsection      = ks.sectionnum  
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and  sapg.SeatAreaID  =  cast(ks.seatareaid as int)
          and sapg.pricegroupid = py.PriceGroupID  
          and sapg.sporttype =  @sporttype   and sapg.ticketyear =  @ticketyear         
       group by         ks.seatregionid, cast( accountnumber as int), ct.paidpercent  ,  ct.schpercent  ) ticketing       
       ------------------ticketing end----------------
  on alltickets.seatregionid = ticketing.seatregionid and alltickets.adnumber = ticketing.adnumber
  -------------------advdata start-----------------------------------------
left join (
 select  seatregionid, adnumber, h.contactid, --receiptid,
   min (case when  SAlloc.ProgramTypeName = 'Annual' and transtype = 'Cash Receipt' then transdate else null end) min_annual_receipt_date,
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%'  THEN l.TransAmount ELSE 0 END) annual_pledge_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN l.TransAmount ELSE 0 END) annual_receipt_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%'  THEN l.MatchAmount ELSE 0 END) annual_pledge_match_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN l.matchamount ELSE 0 END) annual_receipt_match_amount, 
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Annual Credit%') or (SAlloc.ProgramTypeName LIKE 'Annual' and transtype = 'Credit') THEN  l.TransAmount+ l.MatchAmount  ELSE    0   END)  annual_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Pledge%'   THEN l.TransAmount ELSE 0 END) capital_pledge_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Receipt%'  THEN l.TransAmount ELSE 0 END) capital_receipt_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Pledge%'   THEN l.matchamount ELSE 0 END) capital_pledge_match_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital'  AND transtype LIKE '%Receipt%' THEN l.matchamount ELSE 0 END) capital_receipt_match_amount,   
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Capital Credit%' ) or (SAlloc.ProgramTypeName ='Capital' and transtype = 'Credit') THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_credit_amount,
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE 'ADA Capital Credit' and transtype = 'Credit') THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_ada_credit_amount
 FROM advcontact c,advcontacttransheader h,advcontacttranslineitems l,advProgram p,
 (select distinct seatregionid,  programid, ProgramTypeName, programtypecode 
 from amy.SeatArea Sarea,  amy.SeatAllocation SAlloc1  ---with suites this is an issue since seatareas map to same seatallocation
         WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID and sarea.sporttype =  @sporttype ) salloc 
where l.ProgramID = SAlloc.ProgramID
AND c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND transyear IN ( @ticketyear, 'CAP')
and (matchinggift = 0 or matchinggift is null)
group by seatregionid, adnumber,h.contactid 
having sum(l.transamount+l.matchamount) <> 0 
) advdata 
------------advdata end----------------------
on alltickets.seatregionid = advdata.seatregionid and alltickets.adnumber= advdata.adnumber
-------------------------------------------------------------------------
-------------------------------------------------------------------------
) list
--where  seatregionname not like '%Suite%'  
*/
GO
