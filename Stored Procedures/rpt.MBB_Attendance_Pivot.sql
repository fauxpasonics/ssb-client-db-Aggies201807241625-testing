SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[MBB_Attendance_Pivot] (@eventlookupid NVARCHAR(25))
AS
    BEGIN

--DECLARE	@eventlookupid NVARCHAR(25)
--SET @eventlookupid = 'B15-MB05'

DECLARE @season NVARCHAR(15)
SET @season = (
SELECT DISTINCT season FROM rpt.MBB_Attendance r WHERE r.tixeventlookupid = @eventlookupid )


	SELECT * FROM 
	(SELECT TOP 100 PERCENT CASE WHEN tixsyspricecodetypedesc = 'Price Level Total' THEN 'Total' ELSE 'Detail' END AS DataType
	, x.* 
	
	FROM (
SELECT  DISTINCT
	@season season, 
	--tixeventtitleshort, 
	--tixeventstartdate, 
	--tixeventlookupid, 
	--opponent, 
	--tixsyspricecodedesc, 
	 
	 --exec rpt.MBB_Attendance_Pivot 'B15-MB04'

	CASE WHEN (GROUPING(tixsyspricecodetypedesc) = 1) THEN 'Price Level Total'
            ELSE ISNULL(tixsyspricecodetypedesc, 'UNKNOWN')
       END AS tixsyspricecodetypedesc ,

	SUM(ISNULL([Hidden],0)) + 
	SUM(ISNULL([Floor],0)) + 
	SUM(ISNULL([Court],0)) + 
	SUM(ISNULL([Prime Sideline Mezzanine],0)) + 
	SUM(ISNULL([Sideline Mezzanine],0)) + 
	SUM(ISNULL([Prime Baseline Mezzanine],0)) + 
	SUM(ISNULL([Baseline Mezzanine],0)) + 
	SUM(ISNULL([Prime Balcony],0)) + 
	SUM(ISNULL([Balcony],0)) + 
	SUM(ISNULL([Baseline Balcony],0)) + 
	SUM(ISNULL([Public GA],0)) + 
	SUM(ISNULL([Student],0)) + 
	SUM(ISNULL([Reserved],0)) AS Total,

	SUM([Floor]) AS [Floor], 
	SUM([Court]) AS [Court], 
	SUM([Prime Sideline Mezzanine]) AS [Prime Sideline Mezzanine], 
	SUM([Sideline Mezzanine]) AS [Sideline Mezzanine], 
	SUM([Prime Baseline Mezzanine]) AS [Prime Baseline Mezzanine], 
	SUM([Baseline Mezzanine]) AS [Baseline Mezzanine], 
	SUM([Prime Balcony]) AS [Prime Balcony],
	SUM([Balcony]) AS [Balcony], 
	SUM([Baseline Balcony]) AS [Baseline Balcony], 
	SUM([Public GA]) AS [Public GA], 
	SUM([Student]) AS [Student], 
	SUM([Reserved]) AS [Reserved]
FROM (SELECT season, 
			 tixeventtitleshort, 
			 tixeventstartdate, 
			 tixeventlookupid, 
			 opponent, 
			 tixsyspricecodetypedesc,
			 tixsyspriceleveldesc,
			 SUM(r.attend) attend 
			 FROM rpt.MBB_Attendance r 
			 WHERE r.pricecodegroup NOT IN ('Scan', 'Flash')
			 GROUP BY r.season ,
                      r.tixeventtitleshort ,
                      r.tixeventstartdate ,
                      r.tixeventlookupid ,
                      r.opponent ,
                      r.tixsyspricecodetypedesc ,
					  r.tixsyspriceleveldesc) a
PIVOT
(SUM(attend) FOR tixsyspriceleveldesc IN ([Hidden], [Floor], [Court], [Prime Sideline Mezzanine], [Sideline Mezzanine], [Prime Baseline Mezzanine], [Baseline Mezzanine], [Prime Balcony], 
											[Balcony], [Baseline Balcony], [Public GA], [Student], [Reserved])) p

WHERE tixeventlookupid = @eventlookupid

GROUP BY tixsyspricecodetypedesc WITH ROLLUP

) x

UNION ALL

SELECT 'Blank', @season season, NULL, NULL,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
UNION ALL

SELECT 'Blank', @season season, NULL, NULL,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Scan Count', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup = 'Scan'  AND tixeventlookupid = @eventlookupid

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Flash Seats', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup = 'Flash' AND tixeventlookupid = @eventlookupid

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Band, Aggie Angels, Dance Team, Yell Leaders', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup = 'BDAY' AND tixeventlookupid = @eventlookupid

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Student Scan', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup = 'Student' AND tixeventlookupid = @eventlookupid

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Student Click Entry', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup = 'Student' AND tixeventlookupid = @eventlookupid

UNION ALL

SELECT 'SubSection' AS DataType, @season season, 'Drop Count', SUM(r.attend) AS Total,
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
FROM rpt.MBB_Attendance r 
WHERE r.pricecodegroup IN ('Student','BDAY','Flash','Scan') AND tixeventlookupid = @eventlookupid
) z

ORDER BY CASE z.DataType
			WHEN 'Detail' THEN 1
			WHEN 'Total' THEN 2
			WHEN 'Blank' THEN 3
			ELSE 4 END

END
GO
