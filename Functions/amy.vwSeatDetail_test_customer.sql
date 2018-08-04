SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [amy].[vwSeatDetail_test_customer] (@accountnumber NVARCHAR(48))
RETURNS TABLE
AS
RETURN

WITH cte AS (
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
	,CAST(a.tixseatid AS INT) tixseatid
	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END AS paid
	,CASE WHEN MIN(a.tixseatprinted) = 1 THEN 'X' ELSE '' END AS sent

FROM [ods].[VTXtixeventzoneseats] a
JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
JOIN [ods].[VTXtixeventzoneseatgroups] sec 
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
	AND c.accountnumber = @accountnumber
	--AND e.tixeventlookupid = @tixeventlookupid
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
        ,rn=tixseatid-ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, seatsection, seatrow, tixsyspricecode, paid, [sent] ORDER BY tixseatid)
    FROM cte) a
GROUP BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], seatpricecode, 
			seatsection, seatrow, tixsyspricecode, paid, [sent], rn ) x
INNER JOIN cte y ON 
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
