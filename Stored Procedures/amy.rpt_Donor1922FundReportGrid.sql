SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_Donor1922FundReportGrid]
(@includepastprograms bit = null)

AS

--DECLARE @CurrentYear VARCHAR(20)
--DECLARE @CurrentYearDT int
--Declare @yearstartdate date
--DECLARE @MEMBID INTp

--SET @CurrentYear   = cast( year (@startdate) as varchar);
--SET @CurrentYearDT = year (@startdate) ;
--Set @yearstartdate = cast ('01/01/' + @CurrentYear AS DATE);

select c.adnumber, c.firstname, c.lastname, c.email, c.status, c.lifetimegiving, c.StaffAssigned, mgstatus udf1,  ttall.* , 
               careof Address1,
               addr1 Address2,
                c.addr2 address3,
               City,
               State,
               Zip,
               Salutation, c.udf4 MajorGiftName from 
amy.patronextendedinfo_vw c join 
  ( select acct,  
      max( minPledgeDate) LastPledgeDate,    
      min(pledgetotaltotal) PledgeTotal,
      min(case when pledgerunningtotal >= 25000  and pledgetotaltotal >=25000 then minpledgedate else null end) [PGTR25000],
      min(case when pledgerunningtotal >= 50000  and pledgetotaltotal >=50000 then minpledgedate else null end) [PGTR50000],
      min(case when pledgerunningtotal >= 100000 and pledgetotaltotal >=100000  then minpledgedate else null end) [PGTR100000],
      min(case when pledgerunningtotal >= 250000 and pledgetotaltotal >=250000 then minpledgedate else null end) [PGTR250000],
      min(case when pledgerunningtotal >= 500000 and pledgetotaltotal >=500000 then minpledgedate else null end) [PGTR500000],
      max(minpaymentdate) LastReceiptDate,   
      min(paymenttotaltotal) ReceiptTotal,
      min(case when paymentrunningtotal >= 25000  and paymenttotaltotal >=25000 then minpaymentdate else null end) [RGTR25000],
      min(case when paymentrunningtotal >= 50000  and paymenttotaltotal >=50000 then minpaymentdate else null end) [RGTR50000],
      min(case when paymentrunningtotal >= 100000 and paymenttotaltotal >=100000 then minpaymentdate else null end) [RGTR100000],
      min(case when paymentrunningtotal >= 250000 and paymenttotaltotal >=250000 then minpaymentdate else null end) [RGTR250000],
      min(case when paymentrunningtotal >= 500000 and paymenttotaltotal >=500000 then minpaymentdate else null end) [RGTR500000],
      min(case when paymentrunningtotal >= 20000  and paymenttotaltotal >=20000 then minpaymentdate else null end) [PGTR20000],
      min(case when paymentrunningtotal >= 20000  and paymenttotaltotal >=20000 then minpaymentdate else null end) [RGTR20000]
      from (
  select acct,pledgerunningtotal,pledgetotaltotal, paymentrunningtotal, paymenttotaltotal, min(minpledgedate)  minpledgedate, min(minpaymentdate)  minpaymentdate from (
  select acct,
  receiveddate,
  case when pledgeamt <>0 then ReceivedDate else null end    minpledgedate,
  case when paymentamt <>0 then ReceivedDate else  null end   minpaymentdate,
  sum(PledgeAmt + matchingPledgeAmt) as Pledgeamt,
  sum( sum(PledgeAmt + matchingPledgeAmt)) over ( partition by acct  order by  ReceivedDate  ) as PledgeRunningTotal,
    sum( sum(PledgeAmt + matchingPledgeAmt)) over ( partition by acct) as PledgeTotalTotal, 
      sum(PaymentAmt + matchingPaymentAmt) as Paymentamt,
  sum( sum(PaymentAmt + matchingPaymentAmt)) over ( partition by acct
    order by  ReceivedDate
  ) as PaymentRunningTotal,
    sum( sum(PaymentAmt + matchingPaymentAmt)) over ( partition by acct) as PaymentTotalTotal
from pactranitem_alt_vw where  (   driveyear = 0)
                             and   ((@includepastprograms =1  and 
                            allocationid  in (select programid  collate DATABASE_DEFAULT from  amy.vw_CategoryAllocationList where categoryid in ( 777000001, 778000001)) 
                             )
                            or
                             (isnull(@includepastprograms,0) =0  and allocationid  in (select programid  collate DATABASE_DEFAULT from  amy.vw_CategoryAllocationList where categoryid in ( 777000001)))                           
                             )                      
group by acct,ReceivedDate,
  case when pledgeamt <>0 then ReceivedDate else null end    ,
  case when paymentamt <>0 then ReceivedDate else  null end  
)y  group by acct,pledgerunningtotal,pledgetotaltotal, paymentrunningtotal, paymenttotaltotal) tall
group by acct ) ttall on c.patron = ttall.acct
where pledgetotal  >= 20000 
/*

select c.adnumber, c.firstname, c.lastname, c.email, c.status, c.lifetimegiving, c.StaffAssigned, c.udf1,  ttall.* , 
               ca.Address1,
               ca.Address2,
               ca.address3,
               ca.City,
               ca.State,
               ca.Zip,
               ca.Salutation, c.udf4 MajorGiftName from 
 advcontact c join 
  ( select contactid,  
      max(case when transtype like '%Pledge%' then  mindate else null end) LastPledgeDate,    
      min(case when transtype like '%Pledge%' then  totaltotal else null end) PledgeTotal,
      min(case when transtype like '%Pledge%' and  runningtotal >= 25000  and totaltotal >=25000 then mindate else null end) [PGTR25000],
      min(case when transtype like '%Pledge%' and  runningtotal >= 50000  and totaltotal >=50000 then mindate else null end) [PGTR50000],
      min(case when transtype like '%Pledge%' and  runningtotal >= 100000 and totaltotal >=100000  then mindate else null end) [PGTR100000],
      min(case when transtype like '%Pledge%' and  runningtotal >= 250000 and totaltotal >=250000 then mindate else null end) [PGTR250000],
      min(case when transtype like '%Pledge%' and  runningtotal >= 500000 and totaltotal >=500000 then mindate else null end) [PGTR500000],
            max(case when transtype like '%Receipt%' then  mindate else null end) LastReceiptDate,   
      min(case when transtype like '%Receipt%' then  totaltotal else null end) ReceiptTotal,
      min(case when transtype like '%Receipt%' and  runningtotal >= 25000  and totaltotal >=25000 then mindate else null end) [RGTR25000],
      min(case when transtype like '%Receipt%' and  runningtotal >= 50000  and totaltotal >=50000 then mindate else null end) [RGTR50000],
      min(case when transtype like '%Receipt%' and  runningtotal >= 100000 and totaltotal >=100000 then mindate else null end) [RGTR100000],
      min(case when transtype like '%Receipt%' and  runningtotal >= 250000 and totaltotal >=250000 then mindate else null end) [RGTR250000],
      min(case when transtype like '%Receipt%' and  runningtotal >= 500000 and totaltotal >=500000 then mindate else null end) [RGTR500000],
      min(case when transtype like '%Pledge%' and  runningtotal >= 20000  and totaltotal >=20000 then mindate else null end) [PGTR20000],
      min(case when transtype like '%Receipt%' and  runningtotal >= 20000  and totaltotal >=20000 then mindate else null end) [RGTR20000]
      from (
  select contactid, transtype,runningtotal, totaltotal, min(transdate)  mindate from (
  select contactid, transtype,
  transdate ,
  sum(transamount+matchamount) as amt,
  sum( sum(transamount+matchamount)) over ( partition by contactid, transtype
    order by  transDate
  ) as RunningTotal,
    sum( sum(transamount+matchamount)) over ( partition by contactid, transtype
  ) as TotalTotal
from dbo.advContactTransHeader h
                       INNER JOIN dbo.advContactTransLineItems l
                          ON     h.transid = l.transid
                             AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear  = 'CAP')
                             and  ((@includepastprograms =1  and 
                             l.programid in (select programid from  amy.vw_CategoryAllocationList where categoryid in ( 777000001, 778000001)) )
                             or
                             (isnull(@includepastprograms,0) =0  and l.programid in (select programid from  amy.vw_CategoryAllocationList where categoryid in ( 777000001)))                           
                             )                      
group by contactid,transDate, transtype
--order by contactid,transDate
)y  group by contactid, transtype ,runningtotal, totaltotal
) tall
group by contactid ) ttall on c.contactid = ttall.contactid
left join amy.advcontactaddresses_unique_primary_vw  ca on (c.contactid = ca.contactid)
where pledgetotal  >= 20000 */
GO
