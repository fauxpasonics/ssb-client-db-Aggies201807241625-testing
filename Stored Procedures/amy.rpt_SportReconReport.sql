SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[rpt_SportReconReport] 'BB-MB', '2016', 3, null,null
--DROP PROCEDURE [amy].[rpt_SportReconReport]
CREATE PROCEDURE [amy].[rpt_SportReconReport] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2015', 
 @reporttype int = 1,
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
AS

/*reporttype 1 = Pledge Recon (annual/cap
reporttype 2 = balance due
reporttype 3 = all
*/

DECLARE @percent1 decimal
DECLARE @percent2 decimal
declare @percentdue decimal
Declare @tixeventlookupid varchar(50)



set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

if @ticketyear = '2015'
begin
SET @percent1   = .4;
SET @percent2   = .2;
end


select  
list.*,  isnull(CAP,0) -isnull( "Advantage Adjusted CAP Pledge", 0)   capdifference,
isnull(Annual,0)   -  isnull("Advantage Adjusted Annual Pledge", 0)  annualdifference , 
isnull(CAP, 0) -isnull( "Adv CAP Receipt AMount" +"Adv CAP Match Receipt" , 0)   caprecdifference,
(isnull(ANNUAL,0)   - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Pledge",0)+ isnull("Adv Annual Credit", 0) + scheduledpayments)) annualrecdifference 
from ( select alltickets.adnumber, (select accountname from dbo.advcontact c1 where c1.adnumber = alltickets.adnumber) accountname,
(select status from dbo.advcontact c1 where c1.adnumber = alltickets.adnumber) status,
alltickets.sporttype,
ticketcount "Ticket Total",
 CAP,  
 Annual, 
 CAPCredit ,  
 AnnualCredit,
 capital_pledge_trans_amount + capital_pledge_match_amount+ capital_credit_amount "Advantage Adjusted CAP Pledge", 
 capital_pledge_trans_amount "Adv CAP Pledge",
 capital_receipt_trans_amount "Adv CAP Receipt AMount", 
 capital_pledge_match_amount "Adv CAP Match Pledge",
 capital_receipt_match_amount "Adv CAP Match Receipt", 
 capital_credit_amount "Adv CAP Credit",
 annual_pledge_trans_amount + annual_pledge_match_amount+ annual_credit_amount  "Advantage Adjusted Annual Pledge",   
 annual_pledge_trans_amount "Adv Annual  Pledge",  
 annual_receipt_trans_amount "Adv Annual Receipt",
 annual_pledge_match_amount "Adv Annual Match Pledge",  
 annual_receipt_match_amount "Adv Annual Match Receipt",
 annual_credit_amount "Adv Annual Credit" ,
 ( isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans t
join (select distinct  sarea.sporttype, programid from amy.seatarea sarea, amy.SeatAllocation sa1  
where  sarea.seatareaid = sa1.seatareaid and sarea.sporttype =@sporttype  and ProgramTypeName = 'Annual') sa ON t.programid  = sa.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid = (select contactid from dbo.advcontact where adnumber = alltickets.adnumber)), 0)  + 
       isnull( (SELECT sum (transamount) Annual_ScheduledPayments
          FROM dbo.advPaymentSchedule ps, (select distinct  programid from amy.seatarea sarea, amy.SeatAllocation sa1  
where  sarea.seatareaid = sa1.seatareaid and sarea.sporttype =@sporttype) sa
         WHERE     ps.ProgramID = sa.ProgramId
               AND transyear IN (@ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid =  alltickets.adnumber ), 0)) scheduledpayments,
               capital_ada_credit_amount, paidpercent ticketpaidpercent, schpercent ticketscheduledpercent
from 
(select distinct sporttype , adnumber from (
    select 
     salloc.sporttype, adnumber FROM 
     dbo.advcontact c,dbo.advcontacttransheader h,dbo.advcontacttranslineitems l,dbo.advProgram p,
   ( select distinct sarea.sporttype, programid from amy.SeatArea Sarea ,amy.SeatAllocation SAlloc1
         WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID     and sarea.sporttype = @sporttype) SAlloc
    where l.ProgramID = SAlloc.ProgramID
    AND c.contactid = h.contactid
    AND h.TransID = l.TransID
    AND p.ProgramID = l.ProgramID
    AND transyear IN (@ticketyear, 'CAP')
    group by salloc.sporttype, adnumber
    having sum(transamount) <> 0 
    union all
  --  (
    select  sporttype,adnumber 
    from (
    select  distinct l.sporttype, ticketnumber  adnumber 
    from (
    select ks.sporttype,    (select distinct seatregionname from amy.seatregion s where s.seatregionid= ks.seatregionid) seatregionname,
      ks.seatregionid, ks.seatareaid, pg.PriceGroupName, py.PriceGroupID,  cast(ct.accountnumber as int) ticketnumber,seatsection section,  ct.seatpricecode  i_pt_name, qty,
      pe.priorityeventsid
   from    amy.priorityevents pe, 
     seatdetail_flat ct, 
     amy.PriceCodebyYear py,
     amy.PriceGroup pg   , 
     amy.VenueSectionsbyyear  ks 
where pe.sporttype = @sporttype and pe.ticketyear = @ticketyear and
ct.tixeventlookupid = pe.tixeventlookupid 
and py.priorityeventsid = pe.priorityeventsid
and py.PriceCodeCode = ct.seatpricecode
and py.PriceGroupID = pg.PriceGroupID 
and  ct.seatsection     = ks.sectionnum  and  ct.year between ks.startyear and ks.endyear
and ks.sportid = pe.sportid
  and (    (rows is not null and rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (rows is null) )
    ) l join  amy.seatareapricegroup sapg  on  sapg.SeatAreaID = l.SeatAreaID
    and sapg.pricegroupid = l.PriceGroupID and sapg.priorityeventsid = l.priorityeventsid 
    group by    l.sporttype, ticketnumber 
    ) y
    group by sporttype,  adnumber 
  ) pt
) alltickets
left join (
select sapg.SportType ,
cast( ticketnumber as int) adnumber, 
 sum(case when seatsincluded = 1 then sapg.CAP else sapg.CAP * qty end) CAP,  
 sum(case when seatsincluded = 1 then sapg.Annual else sapg.Annual * qty end) Annual, 
 sum(case when seatsincluded = 1 then sapg.CAPCredit else sapg.CAPCredit * qty end) CAPCredit ,  
 sum(case when seatsincluded = 1 then sapg.AnnualCredit else sapg.AnnualCredit * qty end)  AnnualCredit,
  sum(case when i_pt_name like '%ADA%' or i_pt_name like '%WC%' then qty else 0 end ) ADA,
  sum(case when i_pt_name in ('E','E Hold', 'E ADA','E ADA2' ) then qty else 0 end ) E, 
  sum(case when i_pt_name in ('EC','EC Hold', 'EC ADA','EC ADA2' ,'EC WC') then qty else 0 end) EC, 
  sum(case when i_pt_name in ('ZC E') then qty else 0 end) "ZC E",
  sum(case when i_pt_name like 'Lettermen%' then qty else 0 end) Lettermen,  
  sum(case when i_pt_name in ( 'Faculty&Staff (AD)' )then qty else 0 end) FacultyAD, 
  sum(case when i_pt_name in ( 'Faculty&Staff','Faculty WC' )then qty else 0 end) Faculty, 
  sum(case when i_pt_name in ( 'Faculty&Staff','Faculty WC' )then qty else 0 end) DC, 
  sum(case when i_pt_name in ( 'Comp' )then qty else 0 end) Comp,
  sum(case when i_pt_name in ( 'UO' )then qty else 0 end) UO,
  sum( case when i_pt_name in ( 'UO-R' )then qty else 0 end) [UO-R], 
  sum(case when i_pt_name in ( '2015 Season Only (Non Renewable)' )then qty else 0 end) singleseason, 
  sum(qty ) ticketcount , paidpercent, schpercent
from (
select   (select distinct seatregionname from amy.seatregion s where s.seatregionid= ks.seatregionid and sporttype = @sporttype) seatregionname,
    ks.seatregionid, ks.seatareaid, pg.PriceGroupName, py.PriceGroupID,  cast(ct.accountnumber as int) ticketnumber,seatsection section,  ct.seatpricecode  i_pt_name, qty,
    pe.priorityeventsid, ct.paidpercent, ct.schpercent
   from amy.priorityevents pe,
     seatdetail_flat ct, 
     amy.PriceCodebyYear py,
     amy.PriceGroup pg   , 
     amy.VenueSectionsbyyear  ks 
where  pe.sporttype = @sporttype and pe.ticketyear = @ticketyear and
ct.tixeventlookupid = pe.tixeventlookupid 
and py.priorityeventsid = pe.priorityeventsid
and py.PriceCodeCode = ct.seatpricecode
and py.TicketYear = pe.ticketyear
and py.PriceGroupID = pg.PriceGroupID 
and  ct.seatsection     = ks.sectionnum  and ct.year between ks.startyear and ks.endyear 
and ks.sportid = pe.sportid
  and (    (rows is not null and rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (rows is null) )
  ) l join  amy.seatareapricegroup sapg  on sapg.SeatAreaID = l.seatareaid
and sapg.pricegroupid = l.PriceGroupID and sapg.priorityeventsid = l.priorityeventsid 
group by  sapg.SportType  ,  ticketnumber ,  paidpercent, schpercent
) ticketing 
  on alltickets.sporttype= ticketing.sporttype and alltickets.adnumber = ticketing.adnumber
left join (
 select  salloc.sporttype, adnumber, h.contactid,  
 min(case when  SAlloc.ProgramTypeName = 'Annual' and  transtype = 'Cash Receipt' then l.programid else null end) cpt,
 sum (CASE WHEN     SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%' THEN    l.TransAmount ELSE  0 END)  annual_pledge_trans_amount,   
   sum (CASE WHEN     SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN    l.TransAmount ELSE  0 END)  annual_receipt_trans_amount,   
   sum (   CASE WHEN     SAlloc.ProgramTypeCode = 'Annual'      AND transtype LIKE '%Pledge%' THEN     l.MatchAmount ELSE    0   END)   annual_pledge_match_amount,   
  sum (CASE WHEN     SAlloc.ProgramTypeCode = 'Annual'      AND transtype LIKE '%Receipt%' THEN     l.matchamount ELSE    0   END)  annual_receipt_match_amount, 
  sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Annual Credit%') or (SAlloc.ProgramTypeName LIKE 'Annual'   and transtype = 'Credit') THEN  l.TransAmount+ l.MatchAmount  ELSE    0   END)  annual_credit_amount,
  sum (CASE WHEN     SAlloc.ProgramTypeName = 'Capital'      AND transtype LIKE '%Pledge%' THEN    l.TransAmount  ELSE    0   END)   capital_pledge_trans_amount,  
  sum (CASE WHEN     SAlloc.ProgramTypeName = 'Capital'      AND transtype LIKE '%Receipt%' THEN    l.TransAmount  ELSE    0   END)   capital_receipt_trans_amount,  
  sum (CASE WHEN     SAlloc.ProgramTypeName = 'Capital'      AND transtype LIKE '%Pledge%' THEN    l.matchamount ELSE    0   END)   capital_pledge_match_amount,
  sum (CASE WHEN     SAlloc.ProgramTypeName = 'Capital'      AND transtype LIKE '%Receipt%' THEN    l.matchamount ELSE    0   END)   capital_receipt_match_amount,   
 sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Capital Credit%' ) or (SAlloc.ProgramTypeName LIKE 'Capital'   and transtype = 'Credit' )   THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_credit_amount,
 sum (CASE WHEN (SAlloc.ProgramTypeName LIKE 'ADA Capital Credit' and transtype = 'Credit') THEN  l.TransAmount + l.MatchAmount  ELSE  0  END) capital_ada_credit_amount
  FROM dbo.advcontact c,dbo.advcontacttransheader h,dbo.advcontacttranslineitems l,dbo.advProgram p,
 (select distinct  --seatregionid, seatregionname,
 programid, ProgramTypeName, programtypecode , sarea.sporttype
 from amy.SeatArea Sarea,amy.SeatAllocation SAlloc1
         WHERE     Sarea.SeatAreaID = SAlloc1.SeatAreaID and sarea.sporttype = @sporttype  ) salloc 
where l.ProgramID = SAlloc.ProgramID
AND c.contactid = h.contactid  
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND transyear IN (@ticketyear, 'CAP')
and (matchinggift = 0 or matchinggift is null)
and salloc.sporttype = @sporttype
group by  salloc.sporttype,  adnumber, 
h.contactid 
having sum(l.transamount+l.matchamount) <> 0 
) advdata 
on alltickets.sporttype = advdata.sporttype and alltickets.adnumber= advdata.adnumber ) list
where  
(
(@reporttype = 1 and ((isnull(ANNUAL,0) -isnull( "Advantage Adjusted Annual Pledge", 0)  <>0)) )
 or
 (@reporttype =2 and (isnull(ANNUAL,0)  - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)+ isnull("Adv Annual Credit", 0)+scheduledpayments) >0))
 or
 (@reporttype = 3)
 or
  (@reporttype =4 and (isnull(ANNUAL,0)  - (isnull("Adv Annual Receipt",0) +isnull("Adv Annual Match Receipt",0)+ isnull("Adv Annual Credit", 0)+scheduledpayments) <=0))
  or
 ( @reporttype =5 and 1=2)
   or  -- Receipt higher than pledge
 ( @reporttype =6 and 
 (isnull("Adv Annual  Pledge",0) <  isnull("Adv Annual Receipt",0) or isnull("Adv Annual Match Pledge",0) < isnull("Adv Annual Match Receipt",0))
  )
  
     or  -- CAP Receipt higher than pledge
 ( @reporttype =7 and 
 ( isnull( "Adv CAP Pledge", 0) < isnull( "Adv CAP Receipt AMount",0)  or isnull("Adv CAP Match Pledge" ,0) <isnull( "Adv CAP Match Receipt" ,0))
  )
  )
  and (@ADNUMBERLIST  is null or   ','+@ADNUMBERLIST  +',' like '%,' + cast(adnumber as varchar) +',%')
and  (@accountname  is null or  accountname like '%' + @accountname  +'%')
--and accountname is not null
GO
