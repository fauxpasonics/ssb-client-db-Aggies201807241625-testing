SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  view [amy].[rpt_transaction_aging_vw] as
select l.*, case when agedate between 1 and 60 then '1. Day 1-60'
   when agedate between 61 and 120 then  '2. Day 61-120'
  when agedate between 121 and 180 then '3. Day 121-180'
 when agedate between 181 and 365 then  '4. Day 181-365'
 when agedate between 366 and 730 then '5. Over 1 Years' 
  when agedate between 731 and 1095 then '6. Over 2 Years' 
    when agedate between 1096 and 1460 then '7. Over 3 Years' 
        when agedate between 1461 and 1825 then '8. Over 4 Years'
 else '9. Over 5 Years' end aginggroup  from (
select t.*, runningpledgetotal - runningreceipttotal balance ,datediff(day,transdate, getdate() ) agedate from (
SELECT  sumrec.*,
  RunningPledgeTotal = SUM(pledge) OVER ( partition by contactid,adnumber,programid,transyear  ORDER BY transdate rows between unbounded preceding and current row ),
  RunningReceiptTotal = SUM(receipt) OVER ( partition by contactid,adnumber,programid,transyear  ORDER BY transdate rows between unbounded preceding and current row ),
  PrevRunningPledgeTotal = SUM(pledge) OVER ( partition by contactid,adnumber,programid,transyear  ORDER BY transdate rows between unbounded preceding and 1 preceding ),
  PrevRunningReceiptTotal = SUM(receipt) OVER ( partition by contactid,adnumber,programid,transyear ORDER BY transdate rows between unbounded preceding and 1 preceding),
  --postRunningPledgeTotal = SUM(pledge) OVER ( partition by contactid,adnumber,programid,transyear  ORDER BY transdate rows between unbounded following and 1 following ),
 -- postRunningReceiptTotal = SUM(receipt) OVER ( partition by contactid,adnumber,programid,transyear ORDER BY transdate rows between unbounded following and 1 following ) ,
  PledgeTotal = SUM(pledge) OVER ( partition by contactid,adnumber,programid,transyear ),
  ReceiptTotal = SUM(receipt) OVER ( partition by contactid,adnumber,programid,transyear  )
  from 
  (select h1.contactid, adnumber,accountname, transdate,transyear,li1.programid,  p1.programname,
     sum( case when transtype like '%Pledge%' then isnull(Transamount,0) + isnull(MatchAmount,0) else 0 end) pledge , 
     sum( case when transtype like '%Receipt%' then isnull(Transamount,0) + isnull(MatchAmount,0) else 0 end) receipt
     FROM advcontact c1,  
     advcontacttransheader h1, 
     advcontacttranslineitems li1 , 
     advprogram p1 
     where c1.contactid = h1.contactid and 
     h1.transid = li1.transid and 
     li1.programid = p1.programid and 
     (matchinggift = 0 OR matchinggift IS NULL) 
     and transyear = 'CAP'
    -- and adnumber = 10376
    -- and p1.programid = 341
     group by h1.contactid, adnumber,accountname,  transdate,transyear,li1.programid, p1.programname
     ) SumRec
) t
  where pledgetotal>receipttotal   and RunningPledgeTotal >ReceiptTotal and pledge >0  and pledgetotal >= runningpledgetotal
  ) l where balance > 1
GO
