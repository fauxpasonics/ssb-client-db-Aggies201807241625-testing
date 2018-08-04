SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_SeatDetail_by_adnumber]  (@adnumber int,
 @ticketyear numeric= 2017)
AS


-- Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')
 
 
 --Set @tixeventlookupid   = (select tixeventlookupid from priorityevents pe where pe.sporttype = @sporttype and pe.ticketyear = @ticketyear);

 WITH cte AS (
(select sh.* , 
 case when isnull(u.cap_due,0)  <> 0  then round( (u.[Adv CAP Receipt AMount] + u.[Adv CAP Match Pledge] + u.[Adv CAP Credit])/ u.CAP,2)
 else  null end  cappercentpaid,
case when isnull(u.annual,0)  <> 0  and sh.seatpricecode not like '%Suite%'
then  round( ( isnull(u."Adv Annual Receipt",0) + isnull(u."Adv Annual Match Pledge",0) +  isnull(u.AnnualScheduledPayments,0) + isnull(u."Adv Annual Credit",0))/isnull(u.Annual,0) ,2)
 else  null end  annualpercentpaid,u.email, pe.sporttype
  from   amy.seatdetail_individual_history sh
 left join 
  amy.rpt_seatrecon_tb u on u.TixEventLookupID = sh.tixeventlookupid and cast(sh.accountnumber as int) =  u.adnumber
 join 
 priorityevents pe on  (pe.ticketyear = @ticketyear  or pe.LoadDateExpired is null)    and pe.tixeventlookupid = sh.tixeventlookupid
where sh.accountnumber  = @adnumber and cancel_ind is null
 ))
 select * from (
  select 
 adnumber, sporttype, seatareaname, TicketCount, seatpricecode, seatsection, seatrow, seperateseats, CAPPercent, CAP, CAP_DUE, ordernumber, cappercentpaid, Annual, annualpercentpaid, ticketpercentpaid, accountname, email
 from 
(
select tall.*, 
--isnull(CAP,0)* isnull(CAPPErcent,0) 
case when not(seatareaname  like '%Suite%' and tall.sporttype = 'FB')  then isnull(CAP,0)* isnull(CAPPErcent,0) else 0 end
CAP_DUE, 
k.accountname, 
k.email from   (
SELECT accountnumber adnumber, isnull( seatareaname, categoryname)  seatareaname, a.sporttype, count(tixseatid) TicketCount,
sum(isnull(case when  not(seatareaname  like '%Suite%' and a.sporttype = 'FB') then CAP else 0 end,0)) CAP,
sum(isnull(case when  not(seatareaname  like '%Suite%' and a.sporttype = 'FB') then Annual else 0 end,0)) Annual ,
seatpricecode, 
	seatsection, seatrow,   STUFF((
       SELECT ',' + seatseat  FROM  CTE z
       WHERE z.accountnumber = a.accountnumber AND
            z.categoryname = a.categoryname AND
            z.tixeventlookupid = a.tixeventlookupid AND
            z.tixeventtitleshort = a.tixeventtitleshort AND
            z.tixeventid = a.tixeventid AND	
            z.[YEAR] = a.[YEAR] AND
            z.seatpricecode = a.seatpricecode AND
            z.tixsyspricecode = a.tixsyspricecode AND
            z.seatsection = a.seatsection AND
            z.seatrow = a.seatrow AND
            z.paid = a.paid AND
            z.[SENT] = a.[SENT] and 
            isnull(z.CAP_Percent_Owe_ToDate,0) = isnull(a.CAP_Percent_Owe_ToDate,0)
            and z.ordernumber = a.ordernumber
            order by cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   seperateseats ,
       -- paid, [sent],
	--StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid), 
   CAP_Percent_Owe_ToDate CAPPercent, ordernumber,    paidpercent ticketpercentpaid  ,  cappercentpaid, annualpercentpaid
 --rn, rn2,  paidpercent  ,  schpercent ,  ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode , 
		seatsection, seatrow, tixseatid, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, ordernumber
    --       , rn2=cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int) -ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year],   seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int))
    --    ,rn=tixseatid-ROW_NUMBER() OVER   (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
        , CTE.CAP_Percent_Owe_ToDate, seatareaid,  cappercentpaid, annualpercentpaid, cte.email, cte.sporttype
    FROM   CTE
    ) a left join  amy.playbookpricegroupseatarea py
          on (
         --  a.tixeventlookupid =  @tixeventlookupid   
         py.sporttype = a.sporttype  and py.ticketyear =  @ticketyear 
          and py.PriceCodeCode    = a.seatpricecode                  
          and  py.SeatAreaID  =  a.seatareaid 
          and tixeventlookupid in (select tixeventlookupid from priorityevents where ticketyear = @ticketyear)
        --  and sapg.pricegroupid = py.PriceGroupID  
        --  and sapg.sporttype =  @sporttype   and sapg.ticketyear =  @ticketyear   
        )
GROUP BY accountnumber,  categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], 
seatpricecode, isnull( seatareaname, categoryname),
			seatsection, seatrow , tixsyspricecode, paid, [sent],-- rn,
      paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared , ordernumber,
      --rn2,
     CAP_Percent_Owe_ToDate,  cappercentpaid, annualpercentpaid, email, a.sporttype  ) tall  left join advcontact k on k.adnumber = tall.adnumber
     union all
          select    y.adnumber, seatregionname seatareaname,  --[Ticket Total]
        y.sporttype  ,
        null  TicketCount, 
 CAP,
Annual , --tixeventlookupid,  [year], 
null seatpricecode, 
	suite seatsection,null seatrow,   null  seperateseats ,
  cappercent CAPPercent, ordernumber,   
  case when ordergroupbottomlinegrandtotal <> 0 then  ordergrouptotalpaymentscleared/ordergroupbottomlinegrandtotal else null end ticketpercentpaid  , 
  case when cap <> 0 then (y.[Adv CAP Receipt AMount] + y.[Adv CAP Match Pledge] + y.[Adv CAP Credit])/ y.CAP else null end  cappercentpaid,
  case when Annual<> 0 then (y.[Adv Annual Receipt] + y.[Adv Annual Match Pledge] + y.[Adv Annual Credit] )/  annual_sum else null end    annualpercentpaid,
  isnull(CAP,0)* isnull(CAPPErcent,0) CAP_DUE,
 accountname, y.email
   from RPT_SUITESEATREGION_TB  y
   left join (select adnumber,sum( Annual) annual_sum from RPT_SUITESEATREGION_TB  yy where yy.seatregionname like '%Suite%'  and ticketyear =  @ticketyear  group by adnumber) asum on asum.adnumber = y.adnumber
   where seatregionname like '%Suite%' and y.sporttype = 'FB'
and  ticketyear =  @ticketyear 
and  y.adnumber  = @adnumber
) reportall) reportfilter where  TicketCount is not null
GO
