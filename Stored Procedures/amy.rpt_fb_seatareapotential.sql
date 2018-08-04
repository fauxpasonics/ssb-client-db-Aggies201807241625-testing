SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_fb_seatareapotential]
( @tixeventzone_ind  int,
@price_level_ind  int,
@seatarea_ind int,
@premium_ind int,
@seatsection_ind int,
@Seatstatus_ind int,
@pricecode_ind int,
@pricecodetype_ind int) AS

begin


select 
case when @tixeventzone_ind =1 then tixeventzoneid else null end tixeventzoneid,
 case when @price_level_ind =1 then tixsyspriceleveldesc else null end Price_Level,
  case when @seatarea_ind  =1 then SeatAreaName else null end SeatAreaName,
  case when @premium_ind  =1 then premium_ind else null end premium_ind,  
  case when @seatsection_ind  =1 then seatsection else null end seatsection, -- tixseatcurrentstatus,
  case when @seatstatus_ind  =1 then case when tixseatcurrentstatus= 2 then 'Sold' else 'Unsold'  end  else null end Seatstatus,
  case when @pricecode_ind =1 then case when tixseatcurrentstatus= 2 then tixsyspricecodedesc else tixsysseatstatusdesc end else null end  PriceCode_status,
   case when @pricecodetype_ind =1 then case when tixseatcurrentstatus= 2 then Pricecodetype else tixsysseatstatusdesc  end else null end  Pricecodetype,
--tixsysseatstatusdesc, tixsyspricecodedesc, 
count(*) count  , sum(cast(tixseatsold as int)) sumsold ,
--, sum(cast(tixseatpaidtodate as money)) paidtodate
--, seatrow,seatareaid
--sum(cap_amount) CAP_Amount,
sum(case when annual_amount_alt is not null then annual_amount_alt else Annual_Amount end) Annual_Amount, 
sum(Ticket_Amount) Ticket_Amount ,
sum(ticketpricewofee) Ticket_Amount_potential ,
sum(tixevtznpricecharged) Ticket_Amount_actual 
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
  ks.SeatAreaID, ks.SeatingArea, ks.SeatingDescription, sa.CAP_Amount, sa.Annual_Amount, sa.Ticket_Amount, sa.TicketPrice, annual_amount_alt ,
  case when  sa.premium_ind = 1 then 'Premium' else 'Non-Premium' end premium_ind,
  sa.SeatAreaName, 
  sc.tixsysseatstatusdesc,
  pl.tixsyspriceleveldesc, 
  pct.tixsyspricecodetypedesc Pricecodetype,
sa.ticketpricewofee ,
pchart.tixevtznpricecharged
	--,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X'
  --      WHEN og.ordergrouppaymentstatus IN (1) THEN 'P' ELSE '' END AS paid
	--, CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent ,
  ----,case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentscleared/  ordergroupbottomlinegrandtotal  else 0 end paidpercent  , 
-- case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentsonhold/  ordergroupbottomlinegrandtotal   else 0 end schpercent 
 --   ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, getdate() update_date ,
 --tixseatlastupdate,
   -- og.ordergroup ordernumber, og.ordergroupdate, og.ordergrouplastupdate 
FROM [ods].[VTXtixeventzoneseats] a
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
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid
 left  join tixsysseatstatuscodes sc on sc.tixsysseatstatuscode = a.tixseatcurrentstatus
 left join ods.VTXtixsyspricelevels pl on rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
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
  left join ods.VTXtixsyspricecodetypes pct on pct.tixsyspricecodetype = pc.tixsyspricecodetype
WHERE 1=1 
--	AND cat.categorytypeid = 1
--	AND c.accountnumber IN ('12982', '14122', '22671409','21426','1','10023','10089','92530','96547') 
	AND e.tixeventlookupid = 'F17-Season'
  and --tixsyspricecodedesc  like '%SRO%'
isnull(rw.tixseatgroupdesc,'') not in ( 'SRO','Suite Member','ADMIN') 
  --and sec.tixseatgroupdesc = '120'
  ) p  --left (select  from rpt_seatrecon_tb where sporttype = 'F17-Season'
  group by  case when @tixeventzone_ind =1 then tixeventzoneid else null end,
 case when @price_level_ind =1 then tixsyspriceleveldesc else null end ,
  case when @seatarea_ind  =1 then SeatAreaName else null end ,
  case when @premium_ind  =1 then premium_ind else null end,  
  case when @seatsection_ind  =1 then seatsection else null end , -- tixseatcurrentstatus,
  case when @seatstatus_ind  =1 then case when tixseatcurrentstatus= 2 then 'Sold' else 'Unsold'  end  else null end ,
  case when @pricecode_ind =1 then case when tixseatcurrentstatus= 2 then tixsyspricecodedesc else tixsysseatstatusdesc end else null end  ,
  case when @pricecodetype_ind =1 then case when tixseatcurrentstatus= 2 then Pricecodetype else tixsysseatstatusdesc  end else null end 
  --tixseatcurrentstatus ,   tixsyspricecodedesc,
  --tixsyspricecodedesc --, seatrow,seatareaid
  
    end
GO
