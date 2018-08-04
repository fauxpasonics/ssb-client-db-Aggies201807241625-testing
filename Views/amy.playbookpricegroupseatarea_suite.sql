SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[playbookpricegroupseatarea_suite] as 
select distinct   -- pg.pricegroupid, PriceGROUPNAME ,
sal.* --, -- t.pricecodecode 
from 
(
select adnumber, suite, seatareaname, renewalyear ticketyear,
max(case when donationtype ='CAP' then programid else null end) Capitalseatallocation, 
max(case when donationtype ='CAP' then programname else null end)CapitalProgramName,
max(case when donationtype ='CAPOPT' then programid else null end) CapitalOPTseatallocation,
max(case when donationtype ='CAPOPT' then programname else null end) CapitalOPTProgramName,
max(case when donationtype = 'Annual' then programid else null end) Annualseatallocation, 
max(case when donationtype = 'Annual' then programname else null end) AnnualProgramName, 
max(case when donationtype = 'CAPCredit' then programid else null end) ECCCapitalseatallocation, 
max(case when donationtype = 'CAPCredit' then programname else null end) ECCCapitalProgramName, 
max(case when donationtype = 'AnnCredit' then programid else null end) ECCAnnualseatallocation,
max(case when donationtype = 'AnnCredit' then programname else null end) ECCAnnualProgramName,
--totalamount
max(case when donationtype ='CAP' then totaldue else null end) CapitalTOTALamount  , 
max(case when donationtype  = 'CAPOPT' then totaldue else null end) CapitalOPTTOTALamount,
max(case when donationtype = 'Annual' then totaldue else null end) AnnualTOTALamount, 
max(case when donationtype = 'CAPCredit' then totaldue else null end) ECCCapitalTOTALamount, 
max(case when donationtype = 'AnnCredit' then totaldue else null end) ECCAnnualTOTALamount, 
--amountexpected
max(case when donationtype ='CAP' then amountexpected else null end) Capitalamountexpected  , 
max(case when donationtype  = 'CAPOPT' then amountexpected else null end) CapitalOPTamountexpected,
max(case when donationtype = 'Annual' then amountexpected else null end) Annualamountexpected, 
max(case when donationtype = 'CAPCredit' then amountexpected else null end) ECCCapitalamountexpected, 
max(case when donationtype = 'AnnCredit' then amountexpected else null end) ECCAnnualamountexpected, 
max(case when donationtype ='CAP' then percentexpected else null end) Capitalpercentexpected  , 
max(case when donationtype  = 'CAPOPT' then percentexpected else null end) CapitalOPTpercentexpected, sa.seatareaid,
sa.sporttype from 
suiteallocations sal1, seatarea sa where sal1.seatareaid = sa.seatareaid 
group by adnumber, suite, seatareaname, renewalyear, sa.seatareaid,sa.sporttype) sal
GO
