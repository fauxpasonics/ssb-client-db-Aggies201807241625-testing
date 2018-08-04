SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[rpt_SeatRegionReport] 'FB','2017',3, '21426,10008'
CREATE PROCEDURE [amy].[rpt_SeatRegionReport] (@sporttype varchar(20) = 'FB', 
 @ticketyear varchar(4)= '2016',
 @reporttype int =2 ,
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
*/

DECLARE @percent1 numeric (1,1)
DECLARE @percent2 numeric (1,1)
declare @percentdue numeric (1,1)
Declare @tixeventlookupid varchar(50)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)

 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')


set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);






/*select
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
 capital_ada_credit_amount from 
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
/*
 isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join  amy.SeatAllocation sa ON t.programid  = sa.programid 
join amy.seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
WHERE resp_code IS NULL AND resp_text IS NULL and ProgramTypeName = 'Annual'
 AND t.contactid = advdata.ContactID 
 AND sa.seatareaid   = sarea2.seatareaid
 and sarea2.SeatRegionID = alltickets.seatregionid 
 and sarea2.sporttype =  @sporttype ), 0)  + 
isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM  dbo.advPaymentSchedule ps, 
          amy.seatarea sarea1,
          amy.SeatAllocation sa1         
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ( @ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sarea1.seatregionid =alltickets.seatregionid
               AND sa1.seatareaid  = sarea1.seatareaid
               and sarea1.sporttype =  @sporttype ), 0) AnnualScheduledPayments , 
isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join  amy.SeatAllocation sa ON t.programid  = sa.programid 
join amy.seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
WHERE resp_code IS NULL AND resp_text IS NULL and ProgramTypeName = 'Capital'
 AND t.contactid = advdata.ContactID 
 AND sa.seatareaid   = sarea2.seatareaid
 and sarea2.SeatRegionID = alltickets.seatregionid 
 and sarea2.sporttype =  @sporttype ),0)  
 + 
 isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM advPaymentSchedule ps, 
          amy.seatarea sarea1,
          amy.SeatAllocation sa1         
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ('CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  advdata.contactid
               and sarea1.seatregionid =alltickets.seatregionid              
               AND sa1.seatareaid  = sarea1.seatareaid
               and sarea1.sporttype =  @sporttype ),0) KFCScheduledPayments, */
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
                advdata.capital_ada_credit_amount
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
    sum(qty) ticketcount 
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
       group by         ks.seatregionid, cast( accountnumber as int)  ) ticketing       
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
) list where */
select percentdue, 
adnumber, accountname, status, seatregionname, seatregionid, cap_amount, annual_amount, "Ticket Total", 
CAP, Annual, CAPCredit, AnnualCredit,"Advantage Adjusted CAP Pledge","Adv CAP Pledge","Adv CAP Receipt AMount","Adv CAP Match Pledge","Adv CAP Match Receipt",
"Adv CAP Credit","Advantage Adjusted Annual Pledge","Adv Annual  Pledge","Adv Annual Receipt","Adv Annual Match Pledge","Adv Annual Match Receipt","Adv Annual Credit", 
ADA, E, EC, "ZC E", Lettermen, FacultyAD, Faculty, DC, Comp, "UO", "UO-R", SingleSeason, "Ticket Count", ALL_TICKETS, 
 capdifference, annualdifference , 
 Case when @reporttype in (6,7) then  (isnull("Adv CAP Pledge",0) + isnull("Adv CAP Match Pledge",0)  )   - (isnull("Adv CAP Receipt AMount",0) +isnull("Adv CAP Match Receipt",0)) 
 else caprecdifference end caprecdifference, 
 --Case when @reporttype in (6,7) then  (isnull("Adv Annual  Pledge",0) + isnull("Adv Annual Match Pledge",0)  )   - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)) else annualrecdifference end
 null annualrecdifference ,
AnnualScheduledPayments, KFCScheduledPayments, min_annual_receipt_date,
 capital_ada_credit_amount, ticketpaidpercent, ticketscheduledpercent ,    cap_20, CAP_40 cap_40,CAP_60 cap_60, CAP_80 cap_80, CAP_100 cap_100, CAP_OTHER, CAP_DUE, LinealTransfer, 
 case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > 0
 then isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0) - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0 )  else 0 end CapStillDue, 
 isnull(CAP,0) - isnull("Adv CAP Pledge",0) - isnull("Adv CAP Match Pledge",0)  - isnull("Adv CAP Credit",0)  EG_CapPledgeDifference,
-- isnull(Annual,0)- isnull("Adv Annual  Pledge",0) - isnull("Adv Annual Match Pledge",0)  - isnull("Adv Annual Credit",0) 
 null EG_AnnualPledgeDifference, 
 --case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 
--then  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0  end
null EG_CurrentYearAnnualPastDue,
 case when 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) > 0 
 then 1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) else 0 end 
 EG_TicketOrderPerPastDue,
 case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > .5  then 1 else 0 end EG_CapDue, 
 null --case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > .5 then 1 else 0 end
 EG_AnnualDue, 
case when   1 -  isnull(ticketpaidpercent,0) -  isnull(ticketscheduledpercent,0) > 0 then 1 else 0 end EG_TicketsDue, 
  /*( case when  isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)   > 0 then 
 isnull(Annual,0)-  isnull("Adv Annual Receipt",0) - isnull("Adv Annual Match Pledge",0) -  isnull(AnnualScheduledPayments,0) - isnull("Adv Annual Credit",0)  else 0 
 end ) +
 ( case when isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > 0
 then isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0) - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0 )  else 0 end)
 */ null EG_ItemsDue,
 ordernumber, seatlastupdated, vtxcusttype, 
 case when isnull(annual,0)  <> 0  
then  round( ( isnull("Adv Annual Receipt",0) + isnull("Adv Annual Match Pledge",0) +  isnull(AnnualScheduledPayments,0) + isnull("Adv Annual Credit",0))/isnull(Annual,0) ,2)
 else  null end  annualpercentpaid, email
 from RPT_SEATREGION_TB  list where sporttype = @sporttype and ticketyear = @ticketyear and 
 -- seatregionname not like '%Suite%'   and -- seatregionname not like '%Loge%' and
(
( @reporttype = 3) or
( @reporttype = 1 and (isnull(CAP,0)    - isnull( "Advantage Adjusted CAP Pledge", 0)<>  0  or
                     (isnull(ANNUAL,0) - isnull( "Advantage Adjusted Annual Pledge", 0)  <> 0 and isnull(Annual,0) - isnull("Adv Annual  Pledge",0) - isnull("Adv Annual Match Pledge",0) <>0))
 )
 --or
 --( @reporttype =2 and (isnull(CAP_Due,0) - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0) )  >  0 
--or 
--(isnull(ANNUAL,0)  - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) >0))
 --)
 or
 (@reporttype =2 and
  (
  (isnull(ANNUAL,0)  - ((isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) )>.5) 
  or (isnull(ticketpaidpercent,0) <> 1 ) 
 -- or (isnull(ordergroupbottomlinegrandtotal,0) - isnull(ordergrouptotalpaymentscleared,0)- isnull(ordergrouptotalpaymentsonhold ,0)  > 0 )  
  or (isnull(CAP_DUE, 0)   - isnull( "Adv CAP Receipt AMount",0)  - isnull("Adv CAP Match Pledge",0)   - isnull(  "Adv CAP Credit",0)  -  isnull(KFCScheduledPayments ,0) > .5 )
 )
 ) or
 (  @reporttype = 4 and (isnull(ANNUAL,0)  - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0)+ isnull(AnnualScheduledPayments,0)) <=0 and list.min_annual_receipt_date is not null ))

  or
 ( @reporttype =5 and --  ((isnull("Advantage Adjusted CAP Pledge",0) -isnull(capital_ada_credit_amount,0))*percentdue - (isnull( "Adv CAP Receipt AMount",0) +isnull( "Adv CAP Match Receipt" ,0) +isnull(  "Adv CAP Credit",0)-isnull(capital_ada_credit_amount,0))  >  0 )
 isnull(capstilldue,0) > .5
 )
   or  -- Receipt higher than pledge
 ( @reporttype =6 and 
 (isnull("Adv Annual  Pledge",0) <  isnull("Adv Annual Receipt",0) or isnull("Adv Annual Match Pledge",0) < isnull("Adv Annual Match Receipt",0))
  )
  
     or  -- CAP Receipt higher than pledge
 ( @reporttype =7 and 
 ( isnull( "Adv CAP Pledge", 0) < isnull( "Adv CAP Receipt AMount",0)  or isnull("Adv CAP Match Pledge" ,0) <isnull( "Adv CAP Match Receipt" ,0))
  )
  )
--and ((singleseason = 0 or singleseason is null)  )
--and accountname is not null
and isnull(status,'') <> ('Deceased')
and (@ADNUMBERLISTCLEAN  is null or   ','+@ADNUMBERLISTCLEAN  +',' like '%,' + cast(adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%')
--and seatregionname not like '%Suite%'
GO
