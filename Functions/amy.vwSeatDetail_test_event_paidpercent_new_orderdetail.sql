SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [amy].[vwSeatDetail_test_event_paidpercent_new_orderdetail] (@tixeventlookupid NVARCHAR(48))
RETURNS TABLE
AS
RETURN



  WITH cte AS (
 select *  from  seatdetail_individual_tmp where tixeventlookupid = @tixeventlookupid
)


SELECT x.accountnumber, x.categoryname, x.tixeventlookupid, x.tixeventtitleshort, x.tixeventid, (x.EndSeqNo - x.StartSeqNo) +1 AS qty,
 (select  max(Sarea.seatareacode)
 from amy.SeatArea Sarea, amy.PriorityEvents pe,
   amy.VenueSectionsbyyear  ks    
          where 
          ks.sporttype     = pe.sporttype 
          and x.seatsection      = ks.sectionnum  and pe.ticketyear between ks.startyear and ks.endyear
          and sarea.seatareaid = ks.SeatAreaID
          and ((ks.rows is not null and ks.rows like '%;'+cast(x.seatrow as varchar) +';%' )   or (ks.rows is null) )
         and  sarea.sporttype = pe.sporttype  and pe.tixeventlookupid =          @tixeventlookupid ) + 
CASE WHEN y.seatseat = z.seatseat
		THEN ':'+x.seatsection+':'+x.seatrow+':'+y.seatseat
		ELSE
     case when cast(replace(replace(replace(z.seatseat, 'W',''),'GA',''),'A','') as int) - cast(replace(replace(replace(y.seatseat, 'W',''),'GA',''),'A','') as int) +1 = ckcount  or 
      cast(replace(replace(replace(y.seatseat, 'W',''),'GA',''),'A','') as int) - cast(replace(replace(replace(z.seatseat, 'W',''),'GA',''),'A','') as int) +1 =ckcount then
           ':'+x.seatsection+':'+x.seatrow+':'+y.seatseat+'--'+z.seatseat
     else  ':'+x.seatsection+':'+x.seatrow+':'+seperateseats 
     end
	END AS seatblock,
x.[year], x.seatpricecode, x.tixsyspricecode, 
	x.seatsection, x.seatrow, -- ckcount,
CASE WHEN y.seatseat = z.seatseat
		THEN y.seatseat
		ELSE     
     case when cast(replace(replace(replace(z.seatseat, 'W',''),'GA',''),'A','') as int) - cast(replace(replace(replace(y.seatseat, 'W',''),'GA',''),'A','') as int) +1 = ckcount or 
      cast(replace(replace(replace(y.seatseat, 'W',''),'GA',''),'A','') as int) - cast(replace(replace(replace(z.seatseat, 'W',''),'GA',''),'A','') as int) +1 =ckcount  then
            y.seatseat+'--'+z.seatseat
     else  seperateseats 
     end
	END AS seatseat,
	x.paid, x.[sent], x.paidpercent  ,  x.schpercent , x.ordergroupbottomlinegrandtotal , x.ordergrouptotalpaymentsonhold, x.ordergrouptotalpaymentscleared
, x.ordernumber 
FROM 
(
 SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
	seatsection, seatrow, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent ,  ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared,
	StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid), ordernumber, count(tixseatid) ckcount,
  STUFF((
       SELECT ',' + seatseat  FROM  cte z
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
            z.[SENT] = a.[SENT]
            order by cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   seperateseats , rn, rn2
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
		seatsection, seatrow, tixseatid, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, ordernumber
           , rn2=cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int) -ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year],
                     seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int))
        ,rn=tixseatid-ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
    FROM cte
    ) a
GROUP BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
			seatsection, seatrow, tixsyspricecode, paid, [sent], rn, paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared , ordernumber, rn2
      ) x
INNER JOIN cte  y ON 
y.accountnumber = x.accountnumber AND
y.categoryname = x.categoryname AND
y.tixeventlookupid = x.tixeventlookupid AND
y.tixeventtitleshort = x.tixeventtitleshort AND
y.tixeventid = x.tixeventid AND	
y.[YEAR] = x.[YEAR] AND
y.seatpricecode = x.seatpricecode AND
y.tixsyspricecode = x.tixsyspricecode AND
y.seatsection = x.seatsection AND
y.seatrow = x.seatrow AND
y.paid = x.paid AND
y.[SENT] = x.[SENT] AND 
y.tixseatid = x.StartSeqNo
INNER JOIN cte z ON 
z.accountnumber = x.accountnumber AND
z.categoryname = x.categoryname AND
z.tixeventlookupid = x.tixeventlookupid AND
z.tixeventtitleshort = x.tixeventtitleshort AND
z.tixeventid = x.tixeventid AND	
z.[YEAR] = x.[YEAR] AND
z.seatpricecode = x.seatpricecode AND
z.tixsyspricecode = x.tixsyspricecode AND
z.seatsection = x.seatsection AND
z.seatrow = x.seatrow AND
z.paid = x.paid AND
z.[SENT] = x.[SENT] AND 
z.tixseatid = x.EndSeqNo
GO
