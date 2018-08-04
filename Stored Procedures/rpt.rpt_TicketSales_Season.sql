SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [rpt].[rpt_TicketSales_Season] @CYTELID NVARCHAR(48), @LYTELID NVARCHAR(48)
AS


BEGIN
	
	/*
	declare @CYTELID nvarchar(48)
	declare @LYTELID nvarchar(48)

	set @CYTELID = 'F16-Season'
	set @LYTELID = 'F15-Season'
	--*/
	
IF OBJECT_ID('tempdb..#EventListCY') IS NOT NULL
    DROP TABLE #EventListCY

CREATE TABLE #EventListCY
(
    tixeventid NUMERIC,
    tixeventlookupid NVARCHAR(48)
)

INSERT INTO #EventListCY
        ( tixeventid, tixeventlookupid )
SELECT DISTINCT e.tixeventid, e.tixeventlookupid
FROM ods.VTXtixevents e 
INNER JOIN amy.GameList_Season el ON el.tixeventid = e.tixeventid
WHERE  e.tixeventlookupid = @CYTELID AND  e.ETL_IsDeleted = 0

IF OBJECT_ID('tempdb..#EventListLY') IS NOT NULL
    DROP TABLE #EventListLY

CREATE TABLE #EventListLY
(
    tixeventid NUMERIC,
    tixeventlookupid NVARCHAR(48)
)

INSERT INTO #EventListLY
        ( tixeventid, tixeventlookupid )
SELECT DISTINCT e.tixeventid, e.tixeventlookupid
FROM ods.VTXtixevents e
INNER JOIN amy.GameList_Season el ON el.tixeventid = e.tixeventid
WHERE e.tixeventlookupid = @LYTELID AND e.ETL_IsDeleted = 0

DECLARE @CYEvent INT SET @CYEvent = (SELECT tixeventid FROM #EventListCY)
DECLARE @LYEvent INT SET @LYEvent = (SELECT tixeventid FROM #EventListLY)



	SELECT c.PriceGroupName, c.CYQty, c.CYRevenue, p.LYQty, p.LYRevenue, 
		CASE WHEN ISNULL(p.LYQty, 0) = 0 THEN 0 ELSE 1.00 + (CAST(c.CYQty AS FLOAT) - CAST(p.LYQty AS FLOAT)) / CAST(p.LYQty AS FLOAT) END AS PctRenew
FROM 
(
SELECT 
	a.tixsyspricecodetypedesc PriceGroupName,
	SUM(a.Qty) CYQty,
	SUM(a.Rev) CYRevenue
--SELECT DISTINCT a.tixeventid, pg.PriceGroupName, sum(a.Qty) Qty, SUM(a.Rev) Rev
FROM 
	(
SELECT DISTINCT tixeventid, tixsyspricecodetypedesc, SUM(t.sold) Qty, SUM(rev) Rev
FROM (
SELECT c.tixeventid, q.tixsyspricecodetypedesc, q.sold, c.tixevtznpricecharged, q.sold*c.tixevtznpricecharged AS rev
FROM (

SELECT z.tixeventid, tixeventzoneid, vpc.tixsyspricecodecode, vpt.tixsyspricecodetypedesc, tixseatgroupid, COUNT(*) sold
FROM ods.vtxTixEventZoneSeats z 
	INNER JOIN ods.VTXtixsyspricecodes vpc on z.tixseatpricecode = vpc.tixsyspricecodecode
	INNER JOIN ods.VTXtixsyspricecodetypes vpt ON vpc.tixsyspricecodetype =   vpt.tixsyspricecodetype and  vpt.ETL_IsDeleted = 0
WHERE tixseatsold = 1 AND z.tixeventid = @CYEvent
	AND z.ETL_IsDeleted = 0 AND vpc.ETL_IsDeleted = 0 AND vpt.ETL_IsDeleted = 0
GROUP BY z.tixeventid, tixeventzoneid, vpc.tixsyspricecodecode, vpt.tixsyspricecodetypedesc, tixseatgroupid
) q
INNER JOIN 
(
SELECT DISTINCT z.tixeventid, tixeventzoneid, tixseatgroupid, tixseatgrouppricelevel
FROM ods.VTXtixeventzoneseatgroups z 
WHERE ETL_IsDeleted = 0  AND z.tixeventid = @CYEvent
) r ON r.tixeventid = q.tixeventid AND r.tixeventzoneid = q.tixeventzoneid AND r.tixseatgroupid = q.tixseatgroupid
INNER JOIN 
ods.VTXtixeventzonepricechart c ON c.tixeventid = q.tixeventid AND c.tixeventzoneid = q.tixeventzoneid AND c.tixevtznpricelevelcode = r.tixseatgrouppricelevel AND c.tixevtznpricecodecode = q.tixsyspricecodecode
WHERE c.ETL_IsDeleted = 0
) t
GROUP BY t.tixeventid ,
         t.tixsyspricecodetypedesc
	) a 
GROUP BY a.tixeventid , a.tixsyspricecodetypedesc
) c
LEFT JOIN 
(
SELECT 
	a.tixsyspricecodetypedesc PriceGroupName,
	SUM(a.Qty) LYQty,
	SUM(a.Rev) LYRevenue
--SELECT DISTINCT a.tixeventid, pg.PriceGroupName, sum(a.Qty) Qty, SUM(a.Rev) Rev
FROM 
	(
SELECT DISTINCT tixeventid, tixsyspricecodetypedesc, SUM(t.sold) Qty, SUM(rev) Rev
FROM (
SELECT c.tixeventid, q.tixsyspricecodetypedesc, q.sold, c.tixevtznpricecharged, q.sold*c.tixevtznpricecharged AS rev
FROM (

SELECT z.tixeventid, tixeventzoneid, vpc.tixsyspricecodecode, vpt.tixsyspricecodetypedesc, tixseatgroupid, COUNT(*) sold
FROM ods.vtxTixEventZoneSeats z 
	INNER JOIN ods.VTXtixsyspricecodes vpc on z.tixseatpricecode = vpc.tixsyspricecodecode
	INNER JOIN ods.VTXtixsyspricecodetypes vpt ON vpc.tixsyspricecodetype =   vpt.tixsyspricecodetype and  vpt.ETL_IsDeleted = 0
WHERE tixseatsold = 1 AND z.tixeventid = @LYEvent
	AND z.ETL_IsDeleted = 0 AND vpc.ETL_IsDeleted = 0 AND vpt.ETL_IsDeleted = 0
GROUP BY z.tixeventid, tixeventzoneid, vpc.tixsyspricecodecode, vpt.tixsyspricecodetypedesc, tixseatgroupid
) q
INNER JOIN 
(
SELECT DISTINCT z.tixeventid, tixeventzoneid, tixseatgroupid, tixseatgrouppricelevel
FROM ods.VTXtixeventzoneseatgroups z 
WHERE ETL_IsDeleted = 0  AND z.tixeventid = @LYEvent
) r ON r.tixeventid = q.tixeventid AND r.tixeventzoneid = q.tixeventzoneid AND r.tixseatgroupid = q.tixseatgroupid
INNER JOIN 
ods.VTXtixeventzonepricechart c ON c.tixeventid = q.tixeventid AND c.tixeventzoneid = q.tixeventzoneid AND c.tixevtznpricelevelcode = r.tixseatgrouppricelevel AND c.tixevtznpricecodecode = q.tixsyspricecodecode
WHERE c.ETL_IsDeleted = 0
) t
GROUP BY t.tixeventid ,
         t.tixsyspricecodetypedesc
	) a 
GROUP BY a.tixeventid , a.tixsyspricecodetypedesc
) p ON c.PriceGroupName = p.PriceGroupName 





END
GO
