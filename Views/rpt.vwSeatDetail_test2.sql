SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create VIEW [rpt].[vwSeatDetail_test2]
AS

WITH 
ctesub AS (
SELECT *
FROM (
SELECT 
a.accountnumber,
a.categoryname,
a.tixeventlookupid,
a.tixeventtitleshort,
a.tixeventid,
(CAST(b.tixseatid AS INT)-CAST(a.tixseatid AS INT)) + 1 AS qty, -------------------------------------------
a.[YEAR],
--	CASE WHEN a.seatseat = b.seatseat
--		THEN a.seatpricecode+':'+a.seatsection+':'+a.seatrow+':'+a.seatseat
--		ELSE a.seatpricecode+':'+a.seatsection+':'+a.seatrow+':'+a.seatseat+'--'+b.seatseat 
--	END AS seatblock,
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
FROM rpt.SeatDetail_Tbl a
	 INNER JOIN rpt.SeatDetail_Tbl b ON
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
--WHERE y.diff = y.part --AND y.diff = 1
WHERE (y.qty > 0 AND y.diff = y.part) OR (y.qty > 0 AND diff = 0 AND part = 1)
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
xx.year,
xx.seatpricecode,
xx.tixsyspricecode,
xx.seatsection,
xx.seatrow,
CASE WHEN xx.seatseatA = xx.seatseatB
		THEN xx.seatseatA
		ELSE xx.seatseatA+'--'+xx.seatseatB
	END AS seatseat,
xx.paid,
xx.sent

FROM ctesub xx
INNER JOIN 
(SELECT yy.accountnumber, yy.categoryname, yy.tixeventlookupid, yy.tixeventid, yy.tixeventtitleshort, MAX(qty) qty, yy.year, yy.seatpricecode, yy.tixsyspricecode, yy.seatsection, yy.seatrow, yy.paid, yy.sent
 FROM ctesub yy 
 GROUP BY yy.accountnumber ,
          yy.categoryname ,
          yy.tixeventlookupid ,
          yy.tixeventtitleshort ,
		  yy.tixeventid ,
		  yy.year,
          yy.seatpricecode ,
          yy.tixsyspricecode ,
          yy.seatsection ,
          yy.seatrow ,
          yy.paid ,
          yy.sent) zz 
	ON	zz.accountnumber = xx.accountnumber AND
		zz.categoryname = xx.categoryname AND
        zz.tixeventlookupid = xx.tixeventlookupid AND
        zz.tixeventtitleshort = xx.tixeventtitleshort AND
		zz.tixeventid = xx.tixeventid AND	
        zz.qty = xx.qty AND
        zz.year = xx.year AND
        zz.seatpricecode = xx.seatpricecode AND
        zz.tixsyspricecode = xx.tixsyspricecode AND
        zz.seatsection = xx.seatsection AND
		zz.seatrow = xx.seatrow AND
		zz.paid = xx.paid AND
        zz.sent = xx.sent
GO
