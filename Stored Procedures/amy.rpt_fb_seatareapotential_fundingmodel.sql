SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_fb_seatareapotential_fundingmodel] (@ticketyear  int)
 AS

declare @tixeventlookupid varchar(25)


begin

set @tixeventlookupid = (select tixeventlookupid from priorityevents where sporttype = 'FB' and ticketyear = @ticketyear)

select fm.Side, fm.[Level], [Seating Option], Category, [Total Seats], [Annual Contribution], [Total Annual] [Funding Model Annual], dtl.[Potential_Annual], 
dtl.[Net_Annual_Expected],  
dtl.[Gross_Annual_Expected] ,
dtl.[credit_applied],
dtl.[Total_Seats],
dtl.[Unsold_Seats], 
dtl.[Sold_Seats]
from 
(
select  fundingreportid, 
--seats.*, suiteprice.annual  ,  annual_exp.Annual_Expected, annual_exp.original_annual_expected , annual_exp.creditapplied
--seats.premium_ind, seats.SeatAreaName, seats.seatareaid,
sum(totalseats) [Total_Seats],
sum(unsoldseats) [Unsold_Seats], 
sum(sumsold) [Sold_Seats], 
--sas.ticketpricewofee ticketpriceperseat, sas.annual_amount annualperticket, annual_amount_alt alternateannualperticket,
--seats.seatareaid,unsoldseats,sumsold, 
sum(Annual_Amount) [Potential_Annual], 
sum([Annual_Expected]) [Net_Annual_Expected],  
sum([original_annual_expected])[Gross_Annual_Expected] ,
sum([creditapplied]) [credit_applied]
/* Ticket_Amount_potential ,
 Ticket_Amount_actual ,
[Season - Donor], [Season - Donor (E/EC)], [Season - Comp], [Season - Public], 
[Season - Non-Renewable],
 [Individual - Donor], [Inventory], [Student], [Discount], [OtherSold], [Students], [To Be Allocated], [Visiting Team], [Student Groups], 
[Season], [Corps], [Problem], [Recruits], [Student Athletes], [Player Comp], [Donor Individual Sales], [Public Individual Sales], 
[Mini Pack], [Wheelchair], [Groups 5], [Kill], [Special Needs], [Ath Dept], [High School Coaches], [Consignment], [TicketOfficeHolds], [OtherUnsold] */
--, [annual], [Annual_Expected], [original_annual_expected], [creditapplied]
from ( 
select   sas.fundingreportid, 
--seats.*, suiteprice.annual  ,  annual_exp.Annual_Expected, annual_exp.original_annual_expected , annual_exp.creditapplied
seats.premium_ind, seats.SeatAreaName, seats.seatareaid,totalseats, unsoldseats, sumsold, 
sas.ticketpricewofee ticketpriceperseat, sas.annual_amount annualperticket, annual_amount_alt alternateannualperticket,
--seats.seatareaid, unsoldseats, sumsold, 
case when -- isnull([annual] ,0) > 0 
 suiteprice.[annual] is not null
then  suiteprice.[annual] else seats.annual_amount end Annual_Amount, [Annual_Expected],  
[original_annual_expected],
[creditapplied],
 Ticket_Amount_potential ,
 Ticket_Amount_actual ,
[Season - Donor], [Season - Donor (E/EC)], [Season - Comp], [Season - Public], 
[Season - Non-Renewable],
 [Individual - Donor], [Inventory], [Student], [Discount], [OtherSold], [StudentsAvailable], [StudentsComps],
 [DonorAvailable], [Problem], [Visiting Team], [Athletic Comp], [ADA/Wheelchair], [Obstructed View],[OtherUnsold], [Student Pass]
--, [annual], [Annual_Expected], [original_annual_expected], [creditapplied]
from 
(
select 
premium_ind ,
SeatAreaName ,
seatareaid,
--tixsyspriceleveldesc,
  --case when tixseatcurrentstatus= 2 then 'Sold' else 'Unsold'  end  Seatstatus,
 --case when tixseatcurrentstatus= 2 then tixsyspricecodedesc else tixsysseatstatusdesc end   PriceCode_status,
 sum( case when tixseatcurrentstatus<> 2  then 1 else 0 end ) unsoldseats,
--tixsysseatstatusdesc, tixsyspricecodedesc, 
count(*) totalseats  , 
sum(cast(tixseatsold as int)) sumsold ,
--, sum(cast(tixseatpaidtodate as money)) paidtodate
--, seatrow,seatareaid
--sum(cap_amount) CAP_Amount,
sum(case when annual_amount_alt is not null then annual_amount_alt else Annual_Amount end) Annual_Amount,
max(annual_amount_alt) annual_amount_alt,
sum(ticketpricewofee) Ticket_Amount_potential ,
sum(tixevtznpricecharged) Ticket_Amount_actual ,
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Donor' and p.seatpricecode not in ('E','E ADA','EC','EC ADA','EC ADA2','EC Hold')
  then 1 else 0 end ) [Season - Donor], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Donor' and p.seatpricecode  in ('E','E ADA','EC','EC ADA','EC ADA2','EC Hold')  then 1 else 0 end ) [Season - Donor (E/EC)], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Comp'  then 1 else 0 end ) [Season - Comp], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Public'  then 1 else 0 end ) [Season - Public],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Non-Renewable'  then 1 else 0 end ) [Season - Non-Renewable],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Individual - Donor'  then 1 else 0 end ) [Individual - Donor],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Inventory'  then 1 else 0 end ) [Inventory],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Student'  then 1 else 0 end ) [Student],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Discount'  then 1 else 0 end ) [Discount],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype not in ( 'Discount', 'Student', 'Inventory', 'Individual - Donor' ,  'Season - Non-Renewable',
'Season - Public','Season - Comp', 'Season - Donor' )  then 1 else 0 end ) [OtherSold],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  ( tixsysseatstatusdesc in ('Amy','Students','Student Groups','Special Needs','Galveston')  )    then 1 else 0 end ) [StudentsAvailable],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  ( tixsysseatstatusdesc in ('Band', 'Corps')  )    then 1 else 0 end ) [StudentsComps],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ( 'Cancelled','Cancelled during Renewal','Cancelled PreRenewal','Season','Season Single Seat','New Grad Season',
'Deposits','Faculty&Staff','Lettermen Seasons','To Be Allocated','Special' ) then 1 else 0 end ) [DonorAvailable], 
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ('Problem','Carole','Carole Special','Katelyn','Sylvia','Tracy','Brendan')  then 1 else 0 end ) [Problem],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Visiting Team'  then 1 else 0 end ) [Visiting Team],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc  in ( 'Recruits' ,'Player Comp','Ath Dept','High School Coaches'   ) then 1 else 0 end ) [Athletic Comp],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ('ADA','Wheelchair','Wheelchair Attendant','Consideration','Wheelchair' ) then 1 else 0 end ) [ADA/Wheelchair],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ( 'Kill','Limited View','Obstructed Seating')   then 1 else 0 end ) [Obstructed View],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc not in ('Amy','Students','Student Groups','Special Needs','Galveston','Band', 'Corps', 'Cancelled','Cancelled during Renewal','Cancelled PreRenewal','Season','Season Single Seat','New Grad Season',
'Deposits','Faculty&Staff','Lettermen Seasons','To Be Allocated','Special','Problem','Carole','Carole Special','Katelyn','Sylvia','Tracy','Brendan', 'Visiting Team', 'Problem' ,'Recruits' ,'Player Comp','Ath Dept','High School Coaches' ,
'ADA','Wheelchair','Wheelchair Attendant','Consideration','Wheelchair' ,'Kill','Limited View','Obstructed Seating' )  then 1 else 0 end ) [OtherUnsold],
sum(case when tixsyspriceleveldesc like 'Students%' or (tixsyspriceleveldesc not like 'Students%' and tixsysseatstatusdesc = 'Students') then 1 else 0 end) [Student Pass]
from (
SELECT distinct  a.tixeventzoneid,
a.tixseatcurrentstatus, a.tixseatsold, a.tixseatpaidtodate, tixseatrenewable, a.tixseatsoldfromoutlet,
--	c.accountnumber,
	ecr.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,a.tixeventid
	--,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
	,a.tixseatdesc AS seatseat
	,CAST(a.tixseatid AS INT) tixseatid
	,pc.tixsyspricecodecode AS tixsyspricecode
  , pc.tixsyspricecodedesc,
  ks.SeatAreaID, ks.SeatingArea, ks.SeatingDescription, sa.CAP_Amount, sa.Annual_Amount, sa.Ticket_Amount, sa.ticketpricewofee,  ks.annual_amount_alt,
  case when  sa.premium_ind = 1 then 'Premium' else 'Non-Premium' end premium_ind,
  sa.SeatAreaName, 
  sc.tixsysseatstatusdesc,
  pl.tixsyspriceleveldesc, 
  pct.tixsyspricecodetypedesc Pricecodetype,
    pchart.tixevtznpricecharged
FROM--new 3/21/2018
[ods].[VTXtixevents] e
join ods.VTXtixeventzones zone on zone.tixeventid = e.tixeventid and tixeventzonetype = 0  --and tixeventzonedesc  = 'Admissions'  use if not wanting pending
join [ods].[VTXtixeventzoneseats] a	ON a.tixeventid = e.tixeventid   and  a.tixeventzoneid =zone.tixeventzoneid   
and isnull(a.ETL_DeletedDate,0) = 0 
--end of new 3/21/2018
--[ods].[VTXtixeventzoneseats] a   --removed 3/21/2018
JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
left JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
 left JOIN [ods].[VTXtixsyspricecodes] pc 
	ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS NVARCHAR(255))
--JOIN [ods].[VTXtixevents] e 	ON a.tixeventid = e.tixeventid      --removed 3/21/2018
 left  join tixsysseatstatuscodes sc on sc.tixsysseatstatuscode = a.tixseatcurrentstatus
 left join ods.VTXtixsyspricelevels pl on rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
   left join ods.VTXtixsyspricecodetypes pct on pct.tixsyspricecodetype = pc.tixsyspricecodetype
      left join 
   ods.VTXtixeventzonepricechart pchart  on pchart.tixeventid  = e.tixeventid  
   AND pchart.tixevtznpricelevelcode = pl.tixsyspricelevelcode AND pchart.tixevtznpricecodecode = pc.tixsyspricecodecode 
   left  join (select  ce.tixeventid, catchild.categoryname,  catchild.categoryid  , catchild.parentid, parent.categoryname parentname
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catchild   on  catchild.categoryid = ce.categoryid 
                             and catchild.parentid is not null and catchild.categorytypeid = 1  
                           join ods.VTXcategory parent    on catchild.parentid  = parent.categoryid    ) ecr on ecr.tixeventid = e.tixeventid
 left join  amy.VenueSectionsbyyear  ks
          on ks.sporttype  = 'FB' and sec.tixseatgroupdesc    = ks.sectionnum  and DATEPART(yyyy,e.tixeventstartdate) between ks.startyear and ks.endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(rw.tixseatgroupdesc as varchar) +';%' )   or (ks.rows is null) )
  left join SeatArea     sa on ks.seatareaid = sa.seatareaid    
WHERE 1=1 
	AND e.tixeventlookupid = @tixeventlookupid
  and isnull(rw.tixseatgroupdesc,'') not in ( 'SRO','Suite Member','ADMIN')  and tixsysseatstatusdesc <>  'Kill'

  ) p  
  group by  SeatAreaName , seatareaid ,premium_ind   
  ) seats
 left join (  
  select seatareaname, seatareaid,  sum( adjusted_annual)   Annual_Expected , sum(annual_expected ) original_annual_expected , 
 sum(creditapplied) creditapplied from (
  select  --tt.adnumber,
 tt.seatareaid, seatareaname, premium_ind,annual_expected ,  isnull( credit, 0) creditapplied ,
 case when  isnull( credit, 0) <>0 then annual_expected -  isnull( credit, 0) else annual_expected end adjusted_annual
from (
select  -- adnumber, 
seatareaname, seatareaid , premium_ind,  sum(annual_expected) annual_expected , sum(credit) credit
-- ,  sum(nonpremium_annual_expected )  nonpremium_annual_expected 
from (
select accountnumber adnumber, sa.seatareaname, sa.seatareaid , premium_ind,
sum( py.Annual) annual_expected, 
sum( ct.creditamount ) credit
--sum(case when sa.premium_ind = 1 then  py.Annual else 0 end) premium_annual_expected, 
--sum(case when isnull(sa.premium_ind,0) = 0 then  py.Annual else 0 end) nonpremium_annual_expected 
  from  amy.seatdetail_individual_history  ct  
  left join 
 seatarea sa 
  on ct.seatareaid = sa.seatareaid
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  'FB'  and py.ticketyear = @ticketyear
           where  ct.tixeventlookupid =  @tixeventlookupid
          and cancel_ind is null   and 
          isnull(seatingtype,'') <> 'Suite'
          group by accountnumber, sa.seatareaname, premium_ind, sa.seatareaid
union  all
select adnumber, sa.seatareaname, sa.seatareaid , premium_ind, 
sum(amountexpected) annual_expected, 
sum(0) credit
from suiteallocations suite , seatarea sa where suite.seatareaid = sa.seatareaid and renewalyear = @ticketyear and donationtype = 'Annual' and Suite <> '#N/A' and suite.sporttype = 'FB'
group by  adnumber, sa.seatareaname, sa.seatareaid , premium_ind
union all
select accountnumber adnumber, sa.seatareaname, sa.seatareaid , premium_ind, 
sum( 0) annual_expected, 
sum( ct.creditamount ) credit
  from  amy.seatdetail_individual_history  ct  
  left join 
 seatarea sa 
  on ct.seatareaid = sa.seatareaid
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  'FB'  and py.ticketyear = @ticketyear
           where  ct.tixeventlookupid =   @tixeventlookupid
          and cancel_ind is null   and 
          isnull(seatingtype,'') ='Suite'
          group by accountnumber, sa.seatareaname, premium_ind, sa.seatareaid
          )  pre_tt
group by 
seatareaname, seatareaid , premium_ind
          ) tt        
        ) annualamt
        group by seatareaname, seatareaid  ) annual_exp  on  annual_exp.seatareaid = seats.seatareaid
        left join (select seatareaid, sum(annual) annual from suitepricing where @ticketyear between startyear and endyear
        group by seatareaid) suiteprice on    suiteprice.seatareaid = seats.seatareaid
         left join seatarea sas on sas.seatareaid = seats.seatareaid 
 ) fmsum group by fundingreportid ) dtl ,
fundingmodel fm where fm.fundingreportid = dtl.fundingreportid

        
        end
GO
