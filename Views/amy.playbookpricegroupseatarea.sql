SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[playbookpricegroupseatarea] as select distinct sapc.sporttype, pg.pricegroupid, PriceGROUPNAME, --PRICECODECODE ,
sa.seatareaid, seatareaname, CAP, Annual, CAPCRedit, AnnualCredit  ,
--(select programid from seatallocation salloc1
--where programtypename = 'Capital' and primaryallocation = 1 and salloc1.seatareaid = sa.seatareaid)
sapc.Capital_Programid
Capitalseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc2
where programtypename = 'Capital' and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc2.seatareaid = sa.seatareaid) CapitalProgramName,
--(select programid from seatallocation salloc3
--where programtypename = 'Annual' and primaryallocation = 1 and salloc3.seatareaid = sa.seatareaid) 
sapc.Annual_Programid
Annualseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc4
where programtypename = 'Annual' and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc4.seatareaid = sa.seatareaid) AnnualProgramName,
(select programid from seatallocation salloc5
where programtypecode = 'EC_C'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc5.seatareaid = sa.seatareaid) ECCCapitalseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc6
where programtypecode = 'EC_C'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc6.seatareaid = sa.seatareaid) ECCCapitalProgramName,
(select programid from seatallocation salloc7
where programtypecode = 'EC_A'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc7.seatareaid = sa.seatareaid) ECCAnnualseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc8
where programtypecode = 'EC_A'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc8.seatareaid = sa.seatareaid) ECCAnnualProgramName,
(select programid from seatallocation salloc9
where programtypecode = 'FSLC'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc9.seatareaid = sa.seatareaid) FSLCAnnualseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc10
where programtypecode = 'FSLC'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc10.seatareaid = sa.seatareaid) FSLCAnnualProgramName,
(select programid  from seatallocation salloc11
where programtypecode = 'LC_C'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc11.seatareaid = sa.seatareaid) LCAnnualseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc12
where programtypecode = 'LC_C'   and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc12.seatareaid = sa.seatareaid) LCAnnualProgramName,
(select programid  from seatallocation salloc13
where programtypecode = 'ADAAC'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc13.seatareaid = sa.seatareaid) ADACAnnualseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc13
where programtypecode = 'ADAAC'   and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc13.seatareaid = sa.seatareaid)  ADACAnnualProgramName,
(select programid  from seatallocation salloc14
where programtypecode = 'ADACC'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc14.seatareaid = sa.seatareaid) ADACCapitalseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc14
where programtypecode = 'ADACC'   and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc14.seatareaid = sa.seatareaid)  ADACCapitalProgramName,
sapc.ticketyear, t.PriceCodeCode,
(select programid from seatallocation salloc9
where programtypecode = 'FSLC_C'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc9.seatareaid = sa.seatareaid) FSLCCAPseatallocation, 
(select programcode + ' -  ' + programname from seatallocation salloc10
where programtypecode = 'FSLC_C'  and sapc.ticketyear between primarystartyear and primaryendyear and isnull(inactive_ind,0) = 0  and salloc10.seatareaid = sa.seatareaid) FSLCCAPProgramName,
sapc.Ticket_Amount,
sa.Annual_Amount market_annual
from pricecodebyyear t, pricegroup pg,
SeatAreaPriceGroup sapc,
seatarea sa 
where pg.pricegroupid = sapc.PriceGroupid and sapc.seatareaid = sa.seatareaid
 and t.pricegroupid = pg.pricegroupid and sapc.ticketyear = t.ticketyear
GO
