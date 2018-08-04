SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec [amy].[SeatDetail_by_event] 

CREATE procedure [amy].[SeatDetail_by_event]  (@sporttype varchar(20) = 'FB', 
 @ticketyear varchar(4)= '2016',
 @reporttype int =2 ,
 @ADNUMBERLIST nvarchar(MAX) = null,
 @accountname nvarchar(100) = null)
AS
Declare @tixeventlookupid  varchar(50)

 Set @tixeventlookupid   = (select tixeventlookupid from priorityevents pe where pe.sporttype = 'FB' and pe.ticketyear = '2016');

 WITH cte AS (
(select *  from   seatdetail_individual_history  where tixeventlookupid = @tixeventlookupid and cancel_ind is null
and     (@ADNUMBERLIST  is null or   ','+@ADNUMBERLIST  +',' like '%,' + cast(accountnumber as varchar) +',%') 
and  (@accountname  is null or  (select accountname from advcontact where adnumber = accountnumber)  like '%' + @accountname  +'%')))
select tall.*, CAP* CAPPErcent Dueamount, (select accountname from advcontact where adnumber = tall.adnumber) accountname from (
SELECT accountnumber adnumber, seatareaname, count(tixseatid) TicketCount, sum(CAP) CAP, sum(Annual) Annual , --tixeventlookupid,  [year], 
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
            z.CAP_Percent_Owe_ToDate = a.CAP_Percent_Owe_ToDate
            order by cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   seperateseats ,
       -- paid, [sent],
	--StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid), 
   CAP_Percent_Owe_ToDate CAPPercent, ordernumber --, 
 --rn, rn2,  paidpercent  ,  schpercent ,  ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode , 
		seatsection, seatrow, tixseatid, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, ordernumber
           , rn2=cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int) -ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year],
                     seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int))
        ,rn=tixseatid-ROW_NUMBER() OVER   (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
        , CTE.CAP_Percent_Owe_ToDate, seatareaid
    FROM   CTE
    ) a, amy.playbookpricegroupseatarea py
          where
         --  a.tixeventlookupid =  @tixeventlookupid   
         py.sporttype =  @sporttype  and py.ticketyear =  @ticketyear 
          and py.PriceCodeCode    = a.seatpricecode                  
          and  py.SeatAreaID  =  a.seatareaid 
        --  and sapg.pricegroupid = py.PriceGroupID  
        --  and sapg.sporttype =  @sporttype   and sapg.ticketyear =  @ticketyear   
GROUP BY accountnumber,  categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], 
seatpricecode, seatareaname,
			seatsection, seatrow , tixsyspricecode, paid, [sent], rn, paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared , ordernumber, rn2
     ,CAP_Percent_Owe_ToDate  ) tall
/*
SELECT x.accountnumber adnumber, x.categoryname, x.tixeventlookupid, x.tixeventtitleshort, x.tixeventid, (x.EndSeqNo - x.StartSeqNo) +1 AS qty,
 isnull((select  max(Sarea.seatareacode)
 from amy.SeatArea Sarea, amy.PriorityEvents pe,
   amy.VenueSections  ks    
          where 
          ks.sporttype     = pe.sporttype 
          and x.seatsection      = ks.sectionnum 
          and sarea.seatareaid = ks.SeatAreaID
          and ((ks.rows is not null and ks.rows like '%;'+cast(x.seatrow as varchar) +';%' )   or (ks.rows is null) )
         and  sarea.sporttype = pe.sporttype  and pe.tixeventlookupid =          'F16-Season'),'') + 
CASE WHEN  isnull(y.seatseat,'TBA') = isnull(z.seatseat,'TBA')
		THEN ':'+x.seatsection+':'+x.seatrow+':'+isnull(y.seatseat,'TBA')
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
, x.ordernumber ,x.CAP_Percent_Owe_ToDate
FROM 
(
 SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
	seatsection, seatrow, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent ,  ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared,
	StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid), ordernumber, count(tixseatid) ckcount, CAP_Percent_Owe_ToDate,
 /* count(case when CAP_Percent_Owe_ToDate = 0.20 then tixeventid else null end) cap20,
   count(case when CAP_Percent_Owe_ToDate = 0.40 then tixeventid else null end) cap40,
     count(case when CAP_Percent_Owe_ToDate = 0.60 then tixeventid else null end) cap60,
       count(case when CAP_Percent_Owe_ToDate = 0.80 then tixeventid else null end) cap80,
         count(case when CAP_Percent_Owe_ToDate = 1.00 then tixeventid else null end) cap100,      */    
  STUFF((
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
            z.CAP_Percent_Owe_ToDate = a.CAP_Percent_Owe_ToDate
            order by cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   seperateseats , rn, rn2
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode , 
		seatsection, seatrow, tixseatid, tixsyspricecode, paid, [sent], paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, ordernumber
           , rn2=cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int) -ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year],
                     seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int))
        ,rn=tixseatid-ROW_NUMBER() OVER   (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
        , CTE.CAP_Percent_Owe_ToDate
    FROM   CTE
    ) a
GROUP BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
			seatsection, seatrow, tixsyspricecode, paid, [sent], rn, paidpercent  ,  schpercent , ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared , ordernumber, rn2
     ,CAP_Percent_Owe_ToDate
      ) x
INNER JOIN CTE  y ON 
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
and y.CAP_Percent_Owe_ToDate = x.CAP_Percent_Owe_ToDate
INNER JOIN CTE z ON 
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
and  z.CAP_Percent_Owe_ToDate = x.CAP_Percent_Owe_ToDate 
where (@ADNUMBERLIST  is null or   ','+@ADNUMBERLIST  +',' like '%,' + cast(x.accountnumber as varchar) +',%')
and  (@accountname  is null or  (select accountname from advcontact where adnumber = x.accountnumber)  like '%' + @accountname  +'%') */
GO
