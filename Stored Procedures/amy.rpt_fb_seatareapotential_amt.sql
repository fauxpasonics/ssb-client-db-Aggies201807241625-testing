SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_fb_seatareapotential_amt](@ticketyear  int)
 AS

declare @tixeventlookupid varchar(25)


begin

set @tixeventlookupid = (select tixeventlookupid from priorityevents where sporttype = 'FB' and ticketyear = @ticketyear)

 select fm.Side, fm.[Level],  --[Seating Option], Category, 
--seats.*, suiteprice.annual  ,  annual_exp.Annual_Expected, annual_exp.original_annual_expected , annual_exp.creditapplied
--seats.premium_ind,
seats.SeatAreaName,-- seats.seatareaid,
sas.ticketpricewofee [Ticket Price Per Seat], sas.annual_amount [Annual Per Seat], -- annual_amount_alt alternateannualperticket,
totalseats 	[Total Seats], unsoldseats	[Unsold Seats], sumsold [Sold Seats], 
--seats.seatareaid, unsoldseats, sumsold, 
case when -- isnull([annual] ,0) > 0 
 suiteprice.[annual] is not null
then  suiteprice.[annual] else seats.annual_amount end  [Potential_Annual], 
[Annual_Expected] [Net_Annual_Expected],
[original_annual_expected] [Gross Annual Expected],
creditapplied [Credit Applied],
FSLMCredit [FS LM Credit],
 Ticket_Amount_potential  [Ticket Amount potential (Std Price No Discount)],
 Ticket_Amount_actual [Ticket Amount Expected],
 case when  suiteprice.[annual] is not null then  suiteprice.[annual] else seats.annual_amount end +  Ticket_Amount_potential  Revenue_Potential ,
[Annual_Expected] + Ticket_Amount_actual  Revenue_Expected,
[Season - Donor], [Season - Donor (E/EC)], [Season - Comp], [Season - Public], 
--[Season - Non-Renewable], [Individual - Donor], [Inventory],
 [Student], [Discount], [OtherSold],
 --[Students], [To Be Allocated], [Visiting Team], [Student Groups], 
--[Season], [Corps], [Problem], [Recruits], [Student Athletes], [Player Comp], [Donor Individual Sales], [Public Individual Sales], 
--[Mini Pack], [Wheelchair], [Groups 5], [Kill], [Special Needs], [Ath Dept], [High School Coaches], [Consignment], [TicketOfficeHolds], [OtherUnsold],
[DonorAvailable], [Problem],[StudentsAvailable], [StudentsComps],
  [Athletic Comp], [ADA/Wheelchair],[Visiting Team], [Obstructed View],[OtherUnsold], [Student Pass], [Student Groups]

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
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Donor' and replace(p.seatpricecode,'Suite ','') not like 'E%'
  then 1 else 0 end ) [Season - Donor], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Donor' and replace(p.seatpricecode,'Suite ','') like 'E%'  then 1 else 0 end ) [Season - Donor (E/EC)], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Comp'  then 1 else 0 end ) [Season - Comp], 
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Public'  then 1 else 0 end ) [Season - Public],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Season - Non-Renewable'  then 1 else 0 end ) [Season - Non-Renewable],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Individual - Donor'  then 1 else 0 end ) [Individual - Donor],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Inventory'  then 1 else 0 end ) [Inventory],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Student'  then 1 else 0 end ) [Student],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype = 'Discount'  then 1 else 0 end ) [Discount],
sum (case when tixseatcurrentstatus= 2 and  Pricecodetype not in ( 'Discount', 'Student', 'Inventory', 'Individual - Donor' ,  'Season - Non-Renewable',
'Season - Public','Season - Comp', 'Season - Donor' )  then 1 else 0 end ) [OtherSold],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  ( tixsysseatstatusdesc in ('Amy','Students','Student Groups','Special Needs','Galveston','Student Athletes') or (tixsyspriceleveldesc like 'Students%' and tixsysseatstatusdesc not in ('Band', 'Corps')  )  )    then 1 else 0 end ) [StudentsAvailable],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  ( tixsysseatstatusdesc in ('Band', 'Corps')  )    then 1 else 0 end ) [StudentsComps],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ( 'Cancelled','Cancelled during Renewal','Cancelled PreRenewal','Season','Season Single Seat','New Grad Season',
'Deposits','Faculty&Staff','Lettermen Seasons','To Be Allocated','Special' )  and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [DonorAvailable], 
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ('Problem','Carole','Carole Special','Katelyn','Sylvia','Tracy','Brendan')  and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [Problem],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Visiting Team'  and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [Visiting Team],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc  in ( 'Recruits' ,'Player Comp','Ath Dept','High School Coaches'   )  and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [Athletic Comp],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ('ADA','Wheelchair','Wheelchair Attendant','Consideration','Wheelchair' )   and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [ADA/Wheelchair],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ( 'Kill','Limited View','Obstructed Seating')   and tixsyspriceleveldesc  not like 'Students%' then 1 else 0 end ) [Obstructed View],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc not in ('Amy','Students','Student Groups','Student Athletes','Special Needs','Galveston','Band', 'Corps', 'Cancelled','Cancelled during Renewal','Cancelled PreRenewal','Season','Season Single Seat','New Grad Season',
'Deposits','Faculty&Staff','Lettermen Seasons','To Be Allocated','Special','Problem','Carole','Carole Special','Katelyn','Sylvia','Tracy','Brendan', 'Visiting Team', 'Problem' ,'Recruits' ,'Player Comp','Ath Dept','High School Coaches' ,
'ADA','Wheelchair','Wheelchair Attendant','Consideration','Wheelchair' ,'Kill','Limited View','Obstructed Seating' )  then 1 else 0 end ) [OtherUnsold],
sum(case when tixsyspriceleveldesc like 'Students%' or (tixsyspriceleveldesc not like 'Students%' and tixsysseatstatusdesc = 'Students') then 1 else 0 end) [Student Pass],
sum(case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc ='Student Groups' then 1 else 0 end) [Student Groups]
/*sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Students'  then 1 else 0 end ) [Students], 
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'To Be Allocated'  then 1 else 0 end ) [To Be Allocated], 
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Visiting Team'  then 1 else 0 end ) [Visiting Team],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Student Groups'  then 1 else 0 end ) [Student Groups],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Season'  then 1 else 0 end ) [Season],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Corps'  then 1 else 0 end ) [Corps],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Problem'  then 1 else 0 end ) [Problem],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Recruits'  then 1 else 0 end ) [Recruits],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Student Athletes'  then 1 else 0 end ) [Student Athletes],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Player Comp'  then 1 else 0 end ) [Player Comp],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Donor Individual Sales'  then 1 else 0 end ) [Donor Individual Sales],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Public Individual Sales'  then 1 else 0 end ) [Public Individual Sales],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Mini Pack'  then 1 else 0 end ) [Mini Pack],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Wheelchair'  then 1 else 0 end ) [Wheelchair],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Groups 5'  then 1 else 0 end ) [Groups 5],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Kill'  then 1 else 0 end ) [Kill],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Special Needs'  then 1 else 0 end ) [Special Needs],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Ath Dept'  then 1 else 0 end ) [Ath Dept],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'High School Coaches'  then 1 else 0 end ) [High School Coaches],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc = 'Consignment'  then 1 else 0 end ) [Consignment],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc in ('Amy','Carole','Carole Special','Katelyn','Sylvia','Tracy')  then 1 else 0 end ) [TicketOfficeHolds],
sum (case when isnull(tixseatcurrentstatus,0)<>2 and  tixsysseatstatusdesc not in ('Students','To Be Allocated','Visiting Team','Student Groups','Season','Corps','Problem','Band','Recruits','Student Athletes','Player Comp',
'Donor Individual Sales','Public Individual Sales','Mini Pack','Galveston','Wheelchair','Groups 5','Kill','Special Needs','Ath Dept','High School Coaches','Consignment','Amy','Carole','Carole Special','Katelyn','Sylvia','Tracy' )  then 1 else 0 end ) [OtherUnsold]
*/
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
	--,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X'
  --      WHEN og.ordergrouppaymentstatus IN (1) THEN 'P' ELSE '' END AS paid
	--, CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent ,
  ----,case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentscleared/  ordergroupbottomlinegrandtotal  else 0 end paidpercent  , 
-- case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentsonhold/  ordergroupbottomlinegrandtotal   else 0 end schpercent 
 --   ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, getdate() update_date ,
 --tixseatlastupdate,
   -- og.ordergroup ordernumber, og.ordergroupdate, og.ordergrouplastupdate 
FROM  --new 3/21/2018
[ods].[VTXtixevents] e
join ods.VTXtixeventzones zone on zone.tixeventid = e.tixeventid and tixeventzonetype = 0  --and tixeventzonedesc  = 'Admissions'  use if not wanting pending
--join [ods].[VTXtixeventzoneseats] a	ON a.tixeventid = e.tixeventid   and  a.tixeventzoneid =zone.tixeventzoneid   and isnull(a.ETL_DeletedDate,0) = 0   /*REAL TABLE*/
join zz_tixeventzoneseatsF18Season a	ON a.tixeventid = e.tixeventid   and  a.tixeventzoneid =zone.tixeventzoneid   /**** THIS IS A STAND IN FOR REAL TABLE***/
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
--JOIN [ods].[VTXtixevents] e 	ON a.tixeventid = e.tixeventid --removed 3/21/2018
 left  join tixsysseatstatuscodes sc on sc.tixsysseatstatuscode = a.tixseatcurrentstatus
 left join ods.VTXtixsyspricelevels pl on rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
   left join ods.VTXtixsyspricecodetypes pct on pct.tixsyspricecodetype = pc.tixsyspricecodetype
      left join 
   ods.VTXtixeventzonepricechart pchart  on pchart.tixeventid  = e.tixeventid  
   AND pchart.tixevtznpricelevelcode = pl.tixsyspricelevelcode AND pchart.tixevtznpricecodecode = pc.tixsyspricecodecode 
--JOIN [ods].[VTXordergroups] og 
--	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(255))
--JOIN [ods].[VTXcustomers] c 
--	ON og.customerid = c.id and c.accountnumber not like  '%[A-Z,a-z]%'
/*LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid */
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
--	AND cat.categorytypeid = 1
--	AND c.accountnumber IN ('12982', '14122', '22671409','21426','1','10023','10089','92530','96547') 
	AND e.tixeventlookupid = @tixeventlookupid
  and --tixsyspricecodedesc  like '%SRO%'
isnull(rw.tixseatgroupdesc,'') not in ( 'SRO','Suite Member','ADMIN')   and tixsysseatstatusdesc <>  'Kill'
  --and sec.tixseatgroupdesc = '120'
  ) p  --left (select  from rpt_seatrecon_tb where sporttype = 'F17-Season'
  group by  SeatAreaName , seatareaid ,premium_ind   --, tixsyspriceleveldesc
  --,
-- case when tixseatcurrentstatus= 2 then 'Sold' else 'Unsold'  end   ,
 --case when tixseatcurrentstatus= 2 then tixsyspricecodedesc else tixsysseatstatusdesc end 
  --tixseatcurrentstatus ,   tixsyspricecodedesc,
  --tixsyspricecodedesc --, seatrow,seatareaid
  ) seats
 left join (  
  select seatareaname, seatareaid,  sum( adjusted_annual)   Annual_Expected , sum(annual_expected ) original_annual_expected , 
 sum(creditapplied) creditapplied, sum( FSLMCredit)  FSLMCredit from (
  select  --tt.adnumber,
 tt.seatareaid, seatareaname, premium_ind,annual_expected ,  isnull( credit, 0) creditapplied ,
  isnull(FSLMCredit, 0)  FSLMCredit,
 case when  isnull( credit, 0) <>0 then annual_expected -  isnull( credit, 0) else annual_expected end adjusted_annual
from (
select  -- adnumber, 
seatareaname, seatareaid , premium_ind,  sum(annual_expected) annual_expected , sum(credit) credit, sum(FSLMCredit) FSLMCredit
-- ,  sum(nonpremium_annual_expected )  nonpremium_annual_expected 
from (
select accountnumber adnumber, sa.seatareaname, sa.seatareaid , premium_ind,
sum( py.Annual) annual_expected, 
sum( ct.creditamount ) credit,
sum(case when py.PriceCodeCode like 'Fac%' or py.pricecodecode like 'Let%' then py.annualcredit else 0 end) FSLMCredit
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
--sum(amountexpected) premium_annual_expected, 
--sum(0) nonpremium_annual_expected 
sum(0) credit,
sum(0) FSLMCredit
from suiteallocations suite , seatarea sa where suite.seatareaid = sa.seatareaid and renewalyear = @ticketyear and donationtype = 'Annual' and Suite <> '#N/A' and suite.sporttype = 'FB'
group by  adnumber, sa.seatareaname, sa.seatareaid , premium_ind
union all
select accountnumber adnumber, sa.seatareaname, sa.seatareaid , premium_ind, 
sum( 0) annual_expected, 
sum( ct.creditamount ) credit,
sum(0) FSLMCredit
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
          isnull(seatingtype,'') ='Suite'
          group by accountnumber, sa.seatareaname, premium_ind, sa.seatareaid
          )  pre_tt
group by -- adnumber,
seatareaname, seatareaid , premium_ind
          ) tt           

        ) annualamt
        group by seatareaname, seatareaid  ) annual_exp  on  annual_exp.seatareaid = seats.seatareaid
        left join (select seatareaid, sum(annual) annual from suitepricing where cast(@ticketyear as varchar) between startyear and endyear
        group by seatareaid) suiteprice on    suiteprice.seatareaid = seats.seatareaid
         left join seatarea sas on sas.seatareaid = seats.seatareaid
         left join fundingmodel fm on sas.fundingreportid = fm.fundingreportid
        end
GO
