SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [rpt].[vwSeatDetail_oldtest]
	--WITH SCHEMABINDING
AS

WITH cte AS (
SELECT DISTINCT
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
	,a.tixseatid
	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END AS paid
	,CASE WHEN MIN(a.tixseatprinted) = 1 THEN 'X' ELSE '' END AS sent

FROM [ods].[VTXtixeventzoneseats] a
JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
------JOIN [ods].[VTXtixsysseatgrouptypes] gt1 
------	ON rw.tixseatgrouptype = gt1.tixsysseatgrouptypecode
JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
------JOIN [ods].[VTXtixsysseatgrouptypes] gt2 
------	ON sec.tixseatgrouptype = gt2.tixsysseatgrouptypecode
------JOIN [ods].[VTXtixeventzoneseatgroups] hood 
------	ON sec.tixseatgroupparentgroup = hood.tixseatgroupid 
------	AND a.tixeventid = hood.tixeventid 
------	AND a.tixeventzoneid = hood.tixeventzoneid
------JOIN [ods].[VTXtixsysseatgrouptypes] gt3 
------	ON hood.tixseatgrouptype = gt3.tixsysseatgrouptypecode
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
--AND c.accountnumber IN ( '17058' , '1003634', '12184') AND e.tixeventlookupid = 'B15-MB'
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

--SELECT * FROM cte

, 
ctesub AS (
SELECT 
	accountnumber,
	categoryname,
	tixeventlookupid,
	tixeventtitleshort,
	tixeventid,
	qty, 
	[YEAR],
	seatpricecode,
	tixsyspricecode,
	seatsection,
	seatrow,
	seatseatA,
	seatseatB,
	paid,
	sent,
	diff,
	part
FROM (
SELECT 
a.accountnumber,
a.categoryname,
a.tixeventlookupid,
a.tixeventtitleshort,
a.tixeventid,
(CAST(b.tixseatid AS INT)-CAST(a.tixseatid AS INT)) + 1 AS qty, -------------------------------------------
a.[YEAR],
a.seatpricecode,
a.tixsyspricecode,
a.seatsection,
a.seatrow,
a.seatseat seatseatA,
b.seatseat seatseatB,
a.paid,
a.sent,
(CAST(b.tixseatid AS INT)-CAST(a.tixseatid AS INT)) AS diff,   ----------------------------------------------------------------
ROW_NUMBER() OVER (PARTITION BY
	a.accountnumber,
	a.categoryname,
	a.tixeventlookupid,
	a.tixeventtitleshort,
	a.tixeventid,
	a.[YEAR],
	a.seatpricecode,
	a.tixsyspricecode,
	a.seatsection,
	a.seatrow,
	a.tixseatid,
	a.paid,
	a.sent
ORDER BY a.tixseatid, b.tixseatid) AS part
FROM cte a
	 INNER JOIN cte b ON
		a.accountnumber = b.accountnumber AND
        a.categoryname = b.categoryname AND
        a.tixeventlookupid = b.tixeventlookupid AND
        a.tixeventtitleshort = b.tixeventtitleshort AND
		a.tixeventid = b.tixeventid AND
        a.year = b.year AND
        a.seatpricecode = b.seatpricecode AND
		a.tixsyspricecode = b.tixsyspricecode AND
        a.seatsection = b.seatsection AND
        a.seatrow = b.seatrow AND
        a.paid = b.paid AND
        a.SENT = b.sent
--WHERE a.tixseatid <= b.tixseatid --AND (CAST(b.seatseat AS INT) - CAST(a.seatseat AS INT)) = 1
) y
WHERE qty > 0
--WHERE y.diff = y.part --AND y.diff = 1
--WHERE (y.qty > 0 AND y.diff = y.part) OR (y.qty > 0 AND diff = 0 AND part = 1)
)

--SELECT * FROM ctesub

SELECT 
xx.accountnumber,
xx.categoryname,
xx.tixeventlookupid,
xx.tixeventtitleshort,
xx.tixeventid,
xx.qty,
	CASE WHEN xx.seatseatA = xx.seatseatB
		THEN xx.seatpricecode+':'+xx.seatsection+':'+xx.seatrow+':'+xx.seatseatA
		ELSE xx.seatpricecode+':'+xx.seatsection+':'+xx.seatrow+':'+xx.seatseatA+'--'+xx.seatseatB
	END AS seatblock,
xx.YEAR,
xx.seatpricecode,
xx.tixsyspricecode,
xx.seatsection,
xx.seatrow,
CASE WHEN xx.seatseatA = xx.seatseatB
		THEN xx.seatseatA
		ELSE xx.seatseatA+'--'+xx.seatseatB
	END AS seatseat,
xx.paid,
xx.SENT

FROM ctesub xx
INNER JOIN 
(SELECT yy.accountnumber, yy.categoryname, yy.tixeventlookupid, yy.tixeventid, yy.tixeventtitleshort, MAX(qty) qty, yy.YEAR, yy.seatpricecode, yy.tixsyspricecode, yy.seatsection, yy.seatrow, yy.paid, yy.SENT
 FROM ctesub yy 
 GROUP BY yy.accountnumber ,
          yy.categoryname ,
          yy.tixeventlookupid ,
          yy.tixeventtitleshort ,
		  yy.tixeventid ,
		  yy.YEAR,
          yy.seatpricecode ,
          yy.tixsyspricecode ,
          yy.seatsection ,
          yy.seatrow ,
          yy.paid ,
          yy.SENT) zz 
	ON	zz.accountnumber = xx.accountnumber AND
		zz.categoryname = xx.categoryname AND
        zz.tixeventlookupid = xx.tixeventlookupid AND
        zz.tixeventtitleshort = xx.tixeventtitleshort AND
		zz.tixeventid = xx.tixeventid AND	
        zz.qty = xx.qty AND
        zz.YEAR = xx.YEAR AND
        zz.seatpricecode = xx.seatpricecode AND
        zz.tixsyspricecode = xx.tixsyspricecode AND
        zz.seatsection = xx.seatsection AND
		zz.seatrow = xx.seatrow AND
		zz.paid = xx.paid AND
        zz.SENT = xx.SENT
GO
