SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[playbookpricegroupsection_allallocations] as
select distinct pg.sporttype,  sapc.ticketyear, pg.pricegroupid, PriceGROUPNAME, --PRICECODECODE ,
pc.PriceCodeName,
sa.seatareaid, sa.seatareaname, vs.SectionNum, vs.Rows ,  case when programtypecode = 'CAP' then CAP 
                                                                 when programtypecode = 'ANNUAL' then Annual 
                                                                 when Programtypecode = 'FSLC' then AnnualCredit
                                                                 else null end Amount, -- CAP, Annual, CAPCRedit, AnnualCredit  ,
salloc.primaryallocation, salloc.ProgramTypeCode, salloc.ProgramTypeName,
 salloc.programid seatallocationprogramid, 
salloc.programcode + ' -  ' + salloc.programname ProgramName,
sa.Annual_Amount market_annual
from pricecodebyyear t, pricegroup pg,
SeatAreaPriceGroup sapc,
seatarea sa , 
amy.PriceCode pc, 
amy.VenueSectionsbyYear vs,
amy.SeatAllocation salloc
where pg.pricegroupid = sapc.PriceGroupid and sapc.seatareaid = sa.seatareaid and pc.PriceCodeID =t.PriceCodeID 
and sa.SeatAreaID = vs.SeatAreaID and t.TicketYear between vs.startyear and vs.endyear
and sa.seatareaid = salloc.SeatAreaID 
and isnull(salloc.inactive_ind,'0') =0
and t.pricegroupid = pg.pricegroupid and sapc.ticketyear = t.ticketyear
GO
