SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [rpt].[rpt_TicketSales_Season_Bkp] @CYTELID NVARCHAR(48), @LYTELID NVARCHAR(48)
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

DECLARE @CYEvent INT SET @CYEvent = (select tixeventid FROM #EventListCY)
DECLARE @LYEvent INT SET @LYEvent = (SELECT tixeventid from #EventListLY)



	SELECT c.PriceGroupName, c.CYQty, c.CYRevenue, p.LYQty, p.LYRevenue, 
		CASE WHEN ISNULL(p.LYQty, 0) = 0 THEN 0 ELSE 1.00 + (CAST(c.CYQty AS FLOAT) - CAST(p.LYQty AS FLOAT)) / CAST(p.LYQty AS FLOAT) END AS PctRenew
FROM 
(
SELECT 
	pg.PriceGroupName,
	SUM(a.Qty) CYQty,
	SUM(a.Rev) CYRevenue
--SELECT DISTINCT a.tixeventid, pg.PriceGroupName, sum(a.Qty) Qty, SUM(a.Rev) Rev
FROM (
SELECT DISTINCT e.tixeventid, vpc.tixsyspricecodecode, pg.PriceGroupName
FROM  #EventListCY e 
INNER JOIN amy.vw_SportCodeDetail pe 
	ON e.tixeventlookupid = pe.CurSeason
				--fix This (pe.SportCode+CAST(pe.CurrentSeason_TwoDigit AS VARCHAR(2))) = LEFT(e.tixeventlookupid,CHARINDEX('-',e.tixeventlookupid)-1)
INNER JOIN amy.Sport s ON pe.sporttype = s.SportType
INNER JOIN amy.PriceGroup pg ON pg.SportType = s.SportType
INNER JOIN amy.PriceCodebyYear apc ON apc.PriceGroupID = pg.PriceGroupID
INNER JOIN ods.VTXtixsyspricecodes vpc ON vpc.tixsyspricecodedesc = apc.PriceCodeCode 
WHERE  vpc.ETL_IsDeleted = 0
	) pg
	INNER JOIN 
	(
SELECT DISTINCT tixeventid, CAST(t.tixseatpricecode AS NUMERIC) tixseatpricecode, SUM(t.sold) Qty, SUM(rev) Rev
FROM (
SELECT c.tixeventid, q.tixseatpricecode, q.sold, c.tixevtznpricecharged, q.sold*c.tixevtznpricecharged AS rev
FROM (

SELECT z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid, COUNT(*) sold
FROM ods.vtxTixEventZoneSeats z 
WHERE tixseatsold = 1 AND z.tixeventid = @CYEvent
	AND ETL_IsDeleted = 0
GROUP BY z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid
) q
INNER JOIN 
(
SELECT DISTINCT z.tixeventid, tixeventzoneid, tixseatgroupid, tixseatgrouppricelevel
FROM ods.VTXtixeventzoneseatgroups z 
WHERE ETL_IsDeleted = 0  AND z.tixeventid = @CYEvent
) r ON r.tixeventid = q.tixeventid AND r.tixeventzoneid = q.tixeventzoneid AND r.tixseatgroupid = q.tixseatgroupid
INNER JOIN 
ods.VTXtixeventzonepricechart c ON c.tixeventid = q.tixeventid AND c.tixeventzoneid = q.tixeventzoneid AND c.tixevtznpricelevelcode = r.tixseatgrouppricelevel AND c.tixevtznpricecodecode = q.tixseatpricecode
WHERE c.ETL_IsDeleted = 0
) t
GROUP BY t.tixeventid ,
         t.tixseatpricecode
	) a ON a.tixeventid = pg.tixeventid AND pg.tixsyspricecodecode = a.tixseatpricecode
GROUP BY a.tixeventid ,
         pg.PriceGroupName
) c
LEFT JOIN 
(
SELECT 
	pg.PriceGroupName,
	SUM(a.Qty) LYQty,
	SUM(a.Rev) LYRevenue
--SELECT DISTINCT a.tixeventid, pg.PriceGroupName, sum(a.Qty) Qty, SUM(a.Rev) Rev
FROM (
SELECT DISTINCT e.tixeventid, vpc.tixsyspricecodecode, pg.PriceGroupName
FROM  #EventListLY e 
INNER JOIN amy.SportCodes pe ON (pe.SportCode+CAST(pe.PriorSeason_TwoDigit AS VARCHAR(2))) = LEFT(e.tixeventlookupid,CHARINDEX('-',e.tixeventlookupid)-1)
				--fix This
INNER JOIN amy.Sport s ON pe.sporttype = s.SportType
INNER JOIN amy.PriceGroup pg ON pg.SportType = s.SportType
INNER JOIN amy.PriceCodebyYear apc ON apc.PriceGroupID = pg.PriceGroupID
INNER JOIN ods.VTXtixsyspricecodes vpc ON vpc.tixsyspricecodedesc = apc.PriceCodeCode 
WHERE  vpc.ETL_IsDeleted = 0
	) pg
	INNER JOIN 
	(
SELECT DISTINCT tixeventid, CAST(t.tixseatpricecode AS NUMERIC) tixseatpricecode, SUM(t.sold) Qty, SUM(rev) Rev
FROM (
SELECT c.tixeventid, q.tixseatpricecode, q.sold, c.tixevtznpricecharged, q.sold*c.tixevtznpricecharged AS rev
FROM (

SELECT z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid, COUNT(*) sold
FROM ods.vtxTixEventZoneSeats z 
WHERE tixseatsold = 1 AND z.tixeventid = @LYEvent
	AND ETL_IsDeleted = 0
GROUP BY z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid
) q
INNER JOIN 
(
SELECT DISTINCT z.tixeventid, tixeventzoneid, tixseatgroupid, tixseatgrouppricelevel
FROM ods.VTXtixeventzoneseatgroups z 
WHERE ETL_IsDeleted = 0  AND z.tixeventid = @LYEvent
) r ON r.tixeventid = q.tixeventid AND r.tixeventzoneid = q.tixeventzoneid AND r.tixseatgroupid = q.tixseatgroupid
INNER JOIN 
ods.VTXtixeventzonepricechart c ON c.tixeventid = q.tixeventid AND c.tixeventzoneid = q.tixeventzoneid AND c.tixevtznpricelevelcode = r.tixseatgrouppricelevel AND c.tixevtznpricecodecode = q.tixseatpricecode
WHERE c.ETL_IsDeleted = 0
) t
GROUP BY t.tixeventid ,
         t.tixseatpricecode
	) a ON a.tixeventid = pg.tixeventid AND pg.tixsyspricecodecode = a.tixseatpricecode
GROUP BY a.tixeventid ,
         pg.PriceGroupName
) p ON c.PriceGroupName = p.PriceGroupName 





END
GO
