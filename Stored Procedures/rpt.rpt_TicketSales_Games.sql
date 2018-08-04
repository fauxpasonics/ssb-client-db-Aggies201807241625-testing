SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [rpt].[rpt_TicketSales_Games] @CYTELPrefix VARCHAR(10)
AS


BEGIN
	
	/*
	declare @CYTELPrefix varchar(10)
	set @CYTELPrefix = 'F15-F'

	--set @CYTELPrefix = 'F16-F
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
INNER JOIN amy.GameList_Single el ON el.tixeventid = e.tixeventid
	AND LEFT(e.tixeventlookupid,LEN(e.tixeventlookupid)-2) = @CYTELPrefix
WHERE  e.ETL_IsDeleted = 0

--select * from #EventListCY

IF OBJECT_ID('tempdb..#EventPC') IS NOT NULL
    DROP TABLE #EventPC

CREATE TABLE #EventPC
(
    tixeventid NUMERIC,
    tixeventzoneid SMALLINT, 
	tixseatpricecode NUMERIC, 
	tixseatgroupid int, 
	sold int
)
INSERT INTO #EventPC
        ( tixeventid ,
          tixeventzoneid ,
          tixseatpricecode ,
          tixseatgroupid ,
          sold
        )
SELECT z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid, COUNT(*) sold
FROM ods.vtxTixEventZoneSeats z  INNER JOIN #EventListCY c ON c.tixeventid = z.tixeventid
WHERE tixseatsold = 1 
	AND ETL_IsDeleted = 0
GROUP BY z.tixeventid, tixeventzoneid, tixseatpricecode, tixseatgroupid

IF OBJECT_ID('tempdb..#EventPL') IS NOT NULL
    DROP TABLE #EventPL

CREATE TABLE #EventPL
(
    tixeventid NUMERIC,
    tixeventzoneid smallint,
	tixseatgroupid int, 
	tixseatgrouppricelevel NUMERIC
)
INSERT INTO #EventPL
        ( tixeventid ,
          tixeventzoneid ,
          tixseatgroupid ,
          tixseatgrouppricelevel
        )
SELECT DISTINCT z.tixeventid, tixeventzoneid, tixseatgroupid, tixseatgrouppricelevel
FROM ods.VTXtixeventzoneseatgroups z INNER JOIN #EventListCY c ON c.tixeventid = z.tixeventid
WHERE ETL_IsDeleted = 0  


CREATE NONCLUSTERED INDEX idx_EventPL
ON #EventPL ([tixeventid],[tixeventzoneid],[tixseatgroupid],[tixseatgrouppricelevel])


--SELECT * FROM #EventListCY
--SELECT * FROM #EventPC
--SELECT * FROM #EventPL


SELECT a.tixeventid,
	vpt.tixsyspricecodetypedesc PriceGroupName,
	SUM(a.Qty) CYQty,
	SUM(a.Rev) CYRevenue,
	CASE WHEN SUM(a.Qty) IS NULL THEN 0 ELSE SUM(a.Rev) / CAST(SUM(a.Qty) AS NUMERIC) END AS TicketPrice
--SELECT DISTINCT a.tixeventid, pg.PriceGroupName, sum(a.Qty) Qty, SUM(a.Rev) Rev
FROM  
	(
SELECT DISTINCT tixeventid, CAST(t.tixseatpricecode AS NUMERIC) tixseatpricecode, SUM(t.sold) Qty, SUM(rev) Rev
FROM (
SELECT c.tixeventid, q.tixseatpricecode, q.sold, c.tixevtznpricecharged, q.sold*c.tixevtznpricecharged AS rev
FROM #EventPC q
INNER JOIN 
#EventPL r ON r.tixeventid = q.tixeventid AND r.tixeventzoneid = q.tixeventzoneid AND r.tixseatgroupid = q.tixseatgroupid
INNER JOIN 
ods.VTXtixeventzonepricechart c ON c.tixeventid = q.tixeventid AND c.tixeventzoneid = q.tixeventzoneid AND c.tixevtznpricelevelcode = r.tixseatgrouppricelevel AND c.tixevtznpricecodecode = q.tixseatpricecode
WHERE c.ETL_IsDeleted = 0
) t
GROUP BY t.tixeventid ,
         t.tixseatpricecode
	) a --ON a.tixeventid = pg.tixeventid AND pg.tixsyspricecodecode = a.tixseatpricecode
INNER JOIN ods.VTXtixsyspricecodes vpc
	ON a.tixseatpricecode = vpc.tixsyspricecodecode
INNER JOIN ods.VTXtixsyspricecodetypes vpt
	ON vpc.tixsyspricecodetype = vpt.tixsyspricecodetype 
WHERE vpc.ETL_IsDeleted = 0 AND vpt.ETL_IsDeleted = 0 AND vpt.tixsyspricecodetypedesc NOT LIKE '%Season%'
GROUP BY a.tixeventid ,
         vpt.tixsyspricecodetypedesc 

END
GO
