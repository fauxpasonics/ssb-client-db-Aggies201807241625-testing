SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_SUITE_table] (@sporttype varchar(20) = 'FB', @ticketyear varchar(4)= '2016')
AS

--declare @sporttype varchar(20)
--declare @ticketyear varchar(4)
Declare @tixeventlookupid varchar(50)
Declare @pktixeventlookupid varchar(50)

--set @sporttype  = 'FB'
--set @ticketyear = '2017'

select @tixeventlookupid= tixeventlookupid, @pktixeventlookupid = pktixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear

delete from RPT_SUITE_TB where sporttype = @sporttype and ticketyear = @ticketyear

insert into RPT_SUITE_TB
select  
--null percentdue, -- suiteinfo.adnumber adnumber, 
suite, 
--null status,
(select sr.seatregionname from seatregion sr,  seatarea  sa where sr.seatregionid = sa.seatregionid and sa.seatareaid = suiteinfo.seatareaid )  seatregionname, 
(select  seatregionid  from seatarea  sa where sa.seatareaid = suiteinfo.seatareaid ) seatregionid,
round(CAPTOTAL,0) cap_amount,
round(annual,0) annual_amount, 
round(ticketcount,0) [Ticket Total],
round(CAPCOMBTTLExpected,0) CAP,
round(AnnualAmountExpected,0)  Annual, 
null CAPCredit, null AnnualCredit, 
round(( capital_pledge_trans_amount   + capital_pledge_match_amount ),0)  [Advantage Adjusted CAP Pledge],
round( capital_pledge_trans_amount,0)  [Adv CAP Pledge], 
round(capital_receipt_trans_amount,0) [Adv CAP Receipt AMount],
round(capital_pledge_match_amount,0) [Adv CAP Match Pledge],
round(capital_receipt_match_amount,0) [Adv CAP Match Receipt],
round(cap_credit_amount,0) [Adv CAP Credit], 
round(( annual_pledge_trans_amount + annual_pledge_match_amount + annual_credit_amount),0) [Advantage Adjusted Annual Pledge], 
round( annual_pledge_trans_amount,0) [Adv Annual  Pledge], 
round(annual_receipt_trans_amount,0)  [Adv Annual Receipt], 
round(annual_pledge_match_amount,0) [Adv Annual Match Pledge], 
round(annual_receipt_match_amount,0) [Adv Annual Match Receipt], 
round(annual_credit_amount,0) [Adv Annual Credit],
ADA, E, EC, [ZC E],Lettermen, FacultyAD, Faculty, DC, Comp, UO, [UO-R], SingleSeason,ticketcount  [Ticket Count], ticketcount  ALL_TICKETS,
round((CAPTOTAL- capital_pledge_trans_amount   -capital_pledge_match_amount - cap_credit_amount),0)  capdifference, 
round((annual -  annual_pledge_trans_amount   -annual_pledge_match_amount - annual_credit_amount ),0) annualdifference, 
null caprecdifference,
null annualrecdifference,
 isnull((  SELECT  sum(pmt_amount) sch_pay FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct  @sporttype sporttype, --seatregionid ,
programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid  and sarea2.SeatingType = 'Suite'
where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0) sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid in (select contactid from  advcontact m , SuiteAllocations saa where m.adnumber = saa.adnumber and renewalyear = @ticketyear and  saa.Suite = suiteinfo.suite
 and saa.sporttype = @sporttype  )
 and sa1.sporttype =  @sporttype
 ), 0)  + 
isnull( (SELECT sum (transamount) ScheduledPayments
          FROM  dbo.advPaymentSchedule ps, 
          ( select  distinct @sporttype sporttype, --seatregionid , 
          programid from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid  and sarea2.SeatingType = 'Suite'
                where  ProgramTypeName = 'Annual' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0
                ) sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ( @ticketyear)
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid  in 
               (select contactid from  advcontact m ,
               SuiteAllocations saa 
               where m.adnumber = saa.adnumber and renewalyear = @ticketyear and  saa.Suite = suiteinfo.suite 
               and saa.sporttype = @sporttype )
               and sa1.sporttype =  @sporttype
               ), 0) 
 AnnualScheduledPayments,
isnull((  SELECT  sum(pmt_amount) FROM dbo.ADVEvents_tbl_trans  t
join ( select  distinct @sporttype sporttype,  programid from SeatAllocation sa 
join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype  and isnull(sa.inactive_ind,0) =0 and sarea2.SeatingType ='Suite') sa1 on  t.programid  = sa1.programid 
WHERE resp_code IS NULL AND resp_text IS NULL 
 AND t.contactid in (select contactid from  advcontact m , SuiteAllocations saa where m.adnumber = saa.adnumber and renewalyear = @ticketyear and  saa.Suite = suiteinfo.suite and saa.sporttype = @sporttype  )
 and sa1.sporttype= @sporttype
 ),0)  
 + 
 isnull( (SELECT sum (transamount) ScheduledPayments
          FROM advPaymentSchedule ps, 
  ( select  distinct @sporttype sporttype,   programid  from SeatAllocation sa 
            join seatarea sarea2 on sarea2.SeatareaID = sa.seatareaid
                where  ProgramTypeName = 'Capital' and  sarea2.sporttype = @sporttype and isnull(sa.inactive_ind,0) =0  and sarea2.SeatingType ='Suite') sa1   
         WHERE     ps.ProgramID = sa1.ProgramId
               AND transyear IN ('CAP')
               AND MethodOfPayment <> 'Invoice'
               AND dateofpayment >= getdate()
               AND ps.contactid  in (select contactid from  advcontact m , SuiteAllocations saa where m.adnumber = saa.adnumber and renewalyear = @ticketyear and  saa.Suite = suiteinfo.suite and saa.sporttype = @sporttype  )
               and sa1.sporttype = @sporttype                            
               ),0) KFCScheduledPayments,
null min_annual_receipt_date, null capital_ada_credit_amount,
suiteinfo.Sporttype, suiteinfo.Ticketyear ,
 @tixeventlookupid TixEventLookupID,
getdate() updatedate, 
 ticketing.ticketpaidpercent ticketpaidpercent, 
ticketscheduledpercent,
cap_20, CAP_40, CAP_60, CAP_80, CAP_100, CAP_OTHER, 
CAPCOMBAMOUNTEXPECTED CAP_DUE, 
null LinealTransfer, 
case when CAPCOMBAMOUNTEXPECTED -isnull(capital_receipt_trans_amount,0) - isnull(capital_receipt_match_amount,0)  -  isnull(cap_credit_amount,0)  < 0 then 0 else
round((CAPCOMBAMOUNTEXPECTED -isnull(capital_receipt_trans_amount,0) - isnull(capital_receipt_match_amount,0)  -  isnull(cap_credit_amount,0) ),0) end CapStillDue,
ordernumber, 
seatlastupdated , 
null vtxcusttype, 
ordergroupbottomlinegrandtotal, ordergrouptotalpaymentscleared, ordergrouptotalpaymentsonhold
from 
(
select @sporttype Sporttype, @ticketyear Ticketyear,
sp.sectionnum, sp.CAPTOTAL, sp.annual , sp.seatareaid,
t.*  
from suitepricing sp,
(
 select  
 SUITEACCT.suite ,  --  SUITEACCT.adnumber,
sum(AnnualAMOUNTEXPECTED) AnnualAmountExpected,
--sum(CAPAMOUNTEXPECTED) CAPAmountExpected,
--sum(CAPOPTAMOUNTEXPECTED) CAPOPTAmountExpected,
sum(CAPCOMBAMOUNTEXPECTED) CAPCOMBAmountExpected,
--sum(CAPTTLTEXPECTED) CAPTTLTExpected,
--sum(CAPOPTTTLEXPECTED) CAPOPTTTLExpected,
sum(CAPCOMBTTLEXPECTED ) CAPCOMBTTLExpected ,
sum(annual_pledge_trans_amount +annual_pledge_match_amount + annual_credit_amount) annual_ttl_pledge ,
sum(annual_credit_amount) annual_credit_amount,
sum(annual_pledge_trans_amount ) annual_pledge_trans_amount ,
sum(annual_receipt_trans_amount ) annual_receipt_trans_amount ,
sum(annual_pledge_match_amount ) annual_pledge_match_amount ,
sum(annual_receipt_match_amount ) annual_receipt_match_amount ,
sum(capital_pledge_trans_amount ) capital_pledge_trans_amount ,
sum(capital_receipt_trans_amount ) capital_receipt_trans_amount ,
sum(capital_pledge_match_amount ) capital_pledge_match_amount ,
sum(capital_receipt_match_amount ) capital_receipt_match_amount ,
sum(cap_credit_amount) cap_credit_amount,
sum(cap_20) cap_20,
sum(cap_40) CAP_40, 
sum(cap_60) CAP_60, 
sum(cap_80) CAP_80, 
sum(cap_100) CAP_100, 
sum(cap_other) CAP_OTHER  
 from
(select suite ,  -- adnumber, 
        -- sum(case when  donationtype = 'CAP'  then   b.programid else null end ) CAPPROGRAMID,
       --  sum(case when  donationtype = 'Annual'  then  b.programid else null end ) AnnualPROGRAMID,
       --  sum(case when  donationtype = 'CAPOPT'  then  b.programid  else null end ) CAPOPTPROGRAMID,
         sum(case when  donationtype = 'Annual'  then   amountexpected  else 0 end ) AnnualAMOUNTEXPECTED,
         sum(case when  donationtype = 'CAP'  then   amountexpected  else 0 end ) CAPAMOUNTEXPECTED,
         sum(case when  donationtype = 'CAPOPT'  then   amountexpected  else 0 end ) CAPOPTAMOUNTEXPECTED,
         sum(case when  donationtype in ('CAP','CAPOPT')  then   amountexpected  else 0 end ) CAPCOMBAMOUNTEXPECTED,
       --  sum(case when  donationtype = 'CAP'  then   totaldue  else 0 end ) CAPTTLTEXPECTED,
       --  sum(case when  donationtype = 'CAPOPT'  then   totaldue   else 0 end ) CAPOPTTTLEXPECTED,
         sum(case when  donationtype in ('CAP','CAPOPT')  then   totaldue   else 0 end ) CAPCOMBTTLEXPECTED  , 
         sum(case when donationtype = 'CAP' and  percentexpected = .2 then 1 else 0 end) cap_20,
         sum(case when donationtype = 'CAP' and  percentexpected = .4 then 1 else 0 end) CAP_40, 
         sum(case when donationtype = 'CAP' and  percentexpected = .6 then 1 else 0 end) CAP_60, 
         sum(case when donationtype = 'CAP' and  percentexpected = .8 then 1 else 0 end) CAP_80, 
         sum(case when donationtype = 'CAP' and  percentexpected = 1 then 1 else 0 end) CAP_100, 
         sum(case when donationtype = 'CAP' and  percentexpected not in (1.0,0.2,0.4,0.6,0.8) then 1 else 0 end) CAP_OTHER  
        from SuiteAllocations b  where renewalyear = @ticketyear and suite not in ( '#N/A', 'Cancelled?') and b.sporttype = @sporttype 
         group by suite -- , adnumber
         ) SUITEACCT,  
 ( select salloc.suite,   
   -- c.adnumber, h.contactid, 
      sum (CASE WHEN  SAlloc.ProgramTypeName = 'Annual'   THEN isnull(PledgeAmt,0) ELSE 0 END) annual_pledge_trans_amount,    
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Annual' THEN isnull(PaymentAmt,0) ELSE 0 END) annual_receipt_trans_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Annual' THEN isnull(MatchingPledgeAmt,0) ELSE 0 END) annual_pledge_match_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Annual' THEN isnull(MatchingPaymentAmt,0) ELSE 0 END) annual_receipt_match_amount, 
   sum (CASE WHEN (SAlloc.ProgramTypeName in('Annual', 'AnnCredit')  and CreditAmt <> 0  ) THEN  isnull(CreditAmt,0)  ELSE    0   END)  annual_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName in ( 'CAP', 'CAPOPT') THEN isnull(PledgeAmt,0) ELSE 0 END) capital_pledge_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName in ( 'CAP', 'CAPOPT') THEN isnull(PaymentAmt,0) ELSE 0 END) capital_receipt_trans_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName in ( 'CAP', 'CAPOPT') THEN isnull(MatchingPledgeAmt,0) ELSE 0 END) capital_pledge_match_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName in ( 'CAP', 'CAPOPT') THEN isnull(MatchingPaymentAmt,0) ELSE 0 END) capital_receipt_match_amount, 
   sum (CASE WHEN (SAlloc.ProgramTypeName in ( 'CAPCredit','CAP','CAPOPT')  and CreditAmt <> 0 ) THEN  isnull(CreditAmt,0)  ELSE    0   END)  cap_credit_amount 
   from PacTranItem_alt_vw  p
  join  (select suite, adnumber, donationtype programtypename   ,programcode  programcode,  amountexpected AMOUNTEXPECTED, percentexpected, seatareaid   from SuiteAllocations
    where renewalyear = @ticketyear  and sporttype = @sporttype) salloc  
    on  p.AllocationID  = salloc.programcode   COLLATE DATABASE_DEFAULT   
    and p.acct= salloc.adnumber  
where p.DriveYear IN ( @ticketyear, 0)
group by salloc.suite  --,c.adnumber,h.contactid 
 ) amounts
where amounts.suite = SUITEACCT.suite -- and  amounts.adnumber = SUITEACCT.adnumber
group by SUITEACCT.suite --, suiteacct.adnumber
) t where sp.sectionnum = t.suite ) suiteinfo
left join 
 (
select  sporttype,
  --   adnumber, 
     seatsection ,  
    --sum(CAP ) CAP,  
   -- sum(Annual) Annual, 
   -- sum(CAPCredit ) CAPCredit ,  
   -- sum(AnnualCredit)  AnnualCredit,
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
    sum(ordergroupbottomlinegrandtotal) ordergroupbottomlinegrandtotal, 
    sum(ordergrouptotalpaymentscleared) ordergrouptotalpaymentscleared, 
    sum(ordergrouptotalpaymentsonhold) ordergrouptotalpaymentsonhold,
     --sum(CAP_20) CAP_20, 
   -- sum( CAP_40) CAP_40, 
   -- sum( CAP_60) CAP_60, 
   -- sum( CAP_80) CAP_80, 
   -- sum( CAP_100) CAP_100,
   -- sum( CAP_Other) CAP_Other, 
   -- sum(CAP_DUE ) CAP_DUE  ,
        sum( LinealTransfer) LinealTransfer, 
       max(ordernumber) ordernumber,  count(distinct ordernumber) ordernumbercount, 
        max(seatlastupdated) seatlastupdated, min(renewal_date) renewal_date,  min(ticketpaidpercent) ticketpaidpercent,   min(ticketscheduledpercent) ticketscheduledpercent
        from  (
  select -- seatregionname,  --ct.seatregionid, 
  seatsection , isnull(py.sporttype, @sporttype) sporttype, min(renewal_date) renewal_date,  --cast(accountnumber as int)  adnumber, 
   -- sum(sapg.CAP * 1 /*qty*/ ) CAP,       sum(sapg.Annual * 1 /*qty*/ ) Annual,     sum(sapg.CAPCredit * 1 /*qty*/ ) CAPCredit ,  
  --  sum(sapg.AnnualCredit * 1 /*qty*/ )  AnnualCredit,
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
    ct.paidpercent ticketpaidpercent  ,  ct.schpercent ticketscheduledpercent, ct.ordergroupbottomlinegrandtotal, ct.ordergrouptotalpaymentscleared, ct.ordergrouptotalpaymentsonhold,
    sum(sapg.CAP * ct.CAP_Percent_Owe_ToDate ) CAP_DUE  ,
        sum( case when  ct.lineal_transfer_received_ind = 1 then  1 /*qty*/ else 0 end) LinealTransfer, 
       ct.ordernumber ordernumber,
        max(ct.seatlastupdated) seatlastupdated
     from amy.seatdetail_individual_history  ct 
         left join amy.PriceCodebyYear py on ( py.sporttype =  @sporttype  and py.ticketyear =  @ticketyear 
          and py.PriceCodeCode    = ct.seatpricecode      )
          left join       amy.seatareapricegroup sapg on (sapg.SeatAreaID  =  ct.seatareaid 
          and sapg.pricegroupid = py.PriceGroupID  
          and sapg.sporttype =  @sporttype   and sapg.ticketyear =  @ticketyear   )
          where  ct.tixeventlookupid =  @tixeventlookupid    and cancel_ind is null  
          and ct.seatareaid in (select seatareaid from seatarea where seatingtype = 'Suite')
       group by     seatsection,  --  ct.seatregionid, 
       isnull(py.sporttype,@sporttype),      --  cast( accountnumber as int), 
       ct.paidpercent  , 
       ct.schpercent , ct.paidpercent  ,  ct.schpercent , ct.ordergroupbottomlinegrandtotal, ct.ordergrouptotalpaymentscleared, ct.ordergrouptotalpaymentsonhold,  ct.ordernumber 
       )  orderlevel group by-- adnumber, 
       sporttype    , seatsection   
       ) ticketing   on  --  suiteinfo.adnumber = ticketing.adnumber and 
       suiteinfo.suite = ticketing.seatsection
GO
