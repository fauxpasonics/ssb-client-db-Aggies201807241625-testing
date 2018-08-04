SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----- select * from rpt.vwSeatDetail_test2_event('F15-Season')

create FUNCTION [rpt].[vwSeatDetail_test3_event] (@tixeventlookupid NVARCHAR(48))
RETURNS TABLE
AS
RETURN

WITH skipseatblocks AS
( 
		SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '1' AS seatrow, 15 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '2' AS seatrow, 15 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '3' AS seatrow, 15 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '4' AS seatrow, 15 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '5' AS seatrow, 17 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS221' AS seatsection, '6' AS seatrow, 17 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS128' AS seatsection, '1' AS seatrow, 13 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS128' AS seatsection, '2' AS seatrow, 13 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, 'WS128' AS seatsection, '3' AS seatrow, 13 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, '323' AS seatsection, '14W' AS seatrow, 10 AS seatseat
UNION	SELECT 'F15-Season' AS tixeventlookupid, '3473' AS tixeventid, '418' AS seatsection,   '3' AS seatrow, 15 AS seatseat  
)

, cte AS (
SELECT 
	c.accountnumber
	,cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,a.tixeventid
	--,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
	,a.tixseatdesc AS seatseat
	,CAST(a.tixseatid AS INT) AS tixseatid
	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END AS paid
	,CASE WHEN MIN(a.tixseatprinted) = 1 THEN 'X' ELSE '' END AS sent

FROM [ods].[VTXtixeventzoneseats] a
LEFT JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
LEFT JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
JOIN [ods].[VTXtixsyspricecodes] pc 
	ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS NVARCHAR(255))
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid

JOIN [ods].[VTXordergroups] og 
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(255))
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1 
	AND cat.categorytypeid = 1
	--AND c.accountnumber IN ('12982', '14122', '22671409') 
	AND e.tixeventlookupid = @tixeventlookupid
	AND (CAST(a.tixseatdesc AS int) - a.tixseatid)>1
GROUP BY 
	c.accountnumber
	,cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,a.tixeventid
	,DATEPART(yyyy,e.tixeventstartdate) 
	,pc.tixsyspricecodedesc
	,sec.tixseatgroupdesc 
	,rw.tixseatgroupdesc 
	,a.tixseatdesc 
	,a.tixseatid
	,pc.tixsyspricecodecode 
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END
)
, ctemod AS (
SELECT 
	c.accountnumber
	,c.categoryname
	,c.tixeventlookupid
	,c.tixeventtitleshort
	,c.tixeventid
	,c.[year]
	,c.seatpricecode
	,c.seatsection
	,c.seatrow
	,c.seatseat
	--,CASE WHEN s.seatseat IS NULL THEN  CAST(c.tixseatid AS INT) 
	--	  WHEN s.seatseat < CAST(c.seatseat AS INT) THEN CAST(c.tixseatid AS INT)+1 
	--	  ELSE CAST(c.tixseatid AS INT) END AS tixseatid
	,c.tixseatid
	,c.tixsyspricecode
	,c.paid
	,c.[sent]
FROM cte c LEFT JOIN skipseatblocks s 
	ON s.tixeventid = c.tixeventid AND
       s.tixeventlookupid = c.tixeventlookupid AND
       s.seatrow = c.seatrow AND
	   s.seatsection = c.seatsection
WHERE s.seatseat is null
)

SELECT x.accountnumber, x.categoryname, x.tixeventlookupid, x.tixeventtitleshort, x.tixeventid, (x.EndSeqNo - x.StartSeqNo) +1 AS qty,
CASE WHEN y.seatseat = z.seatseat
		THEN x.seatpricecode+':'+x.seatsection+':'+x.seatrow+':'+y.seatseat
		ELSE x.seatpricecode+':'+x.seatsection+':'+x.seatrow+':'+y.seatseat+'--'+z.seatseat
	END AS seatblock,
x.[year], x.seatpricecode, x.tixsyspricecode, 
	x.seatsection, x.seatrow, 
CASE WHEN y.seatseat = z.seatseat
		THEN y.seatseat
		ELSE y.seatseat+'--'+z.seatseat
	END AS seatseat,
	x.paid, x.[sent]

FROM 
(
 SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
	seatsection, seatrow, tixsyspricecode, paid, [sent], 
	StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid)
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
		seatsection, seatrow, tixseatid, tixsyspricecode, paid, [sent]
        ,rn=tixseatid-ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, 
													[year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
    FROM ctemod) a
GROUP BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
			seatsection, seatrow, tixsyspricecode, paid, [sent], rn ) x
INNER JOIN ctemod y ON 
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
INNER JOIN ctemod z ON 
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
