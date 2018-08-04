SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO

CREATE PROCEDURE [rpt].[MBB_Attendance_Load]
	--@parameter_name AS scalar_data_type ( = default_value ), ...
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
	--	statements

TRUNCATE TABLE rpt.MBB_Attendance

SELECT * 
INTO #EventList
FROM (
SELECT LEFT(e.tixeventlookupid,6) AS Season, e.tixeventid, e.tixeventtitleshort, e.tixeventstartdate, e.tixeventlookupid, 
	LTRIM(RIGHT(tixeventtitleshort,LEN(tixeventtitleshort)-CHARINDEX(' vs', tixeventtitleshort) - 3)) AS opponent
--INTO #EventList
 FROM ods.VTXtixevents e
WHERE e.tixeventlookupid LIKE 'B14-MB%' AND e.tixeventtitleshort LIKE '%vs%' 
	AND e.tixeventtitleshort NOT LIKE '%Atlantis%'  AND e.tixeventtitleshort NOT LIKE '%@%' AND e.tixeventtitleshort NOT LIKE '% at %'
	AND e.tixeventvisible = 1 AND e.ETL_IsDeleted = 0
UNION
SELECT LEFT(e.tixeventlookupid,6) AS Season, e.tixeventid, e.tixeventtitleshort, e.tixeventstartdate, e.tixeventlookupid, 
	LTRIM(RIGHT(tixeventtitleshort,LEN(tixeventtitleshort)-CHARINDEX(' vs', tixeventtitleshort) - 3)) AS opponent
--INTO #EventList
 FROM ods.VTXtixevents e
WHERE e.tixeventlookupid LIKE 'B15-MB%' AND e.tixeventtitleshort LIKE '%vs%' 
	AND e.tixeventtitleshort NOT LIKE '%Atlantis%'  AND e.tixeventtitleshort NOT LIKE '%@%' AND e.tixeventtitleshort NOT LIKE '% at %'
	AND e.tixeventvisible = 1 AND e.ETL_IsDeleted = 0 ) x
ORDER BY tixeventstartdate

CREATE UNIQUE INDEX IDX01 ON #EventList(tixeventid) 

INSERT INTO rpt.MBB_Attendance
        ( season,
		  tixeventtitleshort ,
          tixeventstartdate ,
          tixeventlookupid ,
          opponent ,
          tixsyspricecodedesc ,
          tixsyspricecodetypedesc ,
          tixsyspriceleveldesc ,
          attend ,
		  pricecodegroup
        )

SELECT * FROM (
SELECT 
	e.season,
	--e.tixeventid, 
	e.tixeventtitleshort, e.tixeventstartdate, e.tixeventlookupid , 
	LTRIM(RIGHT(tixeventtitleshort,LEN(tixeventtitleshort)-CHARINDEX(' vs', tixeventtitleshort) - 3)) AS opponent,
	--pc.tixsyspricecodecode, 
	pc.tixsyspricecodedesc, 
	--pct.tixsyspricecodetype, 
	pct.tixsyspricecodetypedesc,
	--pl.tixsyspricelevelcode, 
	pl.tixsyspriceleveldesc,
	COUNT(*) attend ,
	CASE WHEN pct.tixsyspricecodetypedesc LIKE '%student%' THEN 'Student' ELSE 'Main' END AS pricecodegroup

--INTO rpt.MBB_Attendance	
--truncate table rpt.MBB_Attendance
--SELECT * from rpt.MBB_Attendance	
FROM [ods].[VTXtixeventzoneseats] a
JOIN	#EventList e ON e.tixeventid = a.tixeventid --AND a.tixseatbarcode <> ''

JOIN [ods].[VTXtixsyspricecodes] pc 
	ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS NVARCHAR(200))
JOIN ods.VTXtixsyspricecodetypes pct
	ON pc.tixsyspricecodetype = CAST(pct.tixsyspricecodetype AS NVARCHAR(200))

JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid

--JOIN [ods].[VTXtixeventzonepricelevels] ezpl
--	 ON 

JOIN	ods.VTXtixsyspricelevels pl
	ON rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode

--LEFT JOIN [ods].[VTXtixeventzoneseatbarcodes] bc 
--	ON 	a.tixseatid = bc.tixseatid


WHERE a.tixseatbarcode <> ''
GROUP BY e.season, --e.tixeventid, 
	e.tixeventtitleshort, e.tixeventstartdate, e.tixeventlookupid,
         pc.tixsyspricecodedesc ,
         pct.tixsyspricecodetypedesc ,
         pl.tixsyspriceleveldesc
) x
UNION ALL
SELECT * FROM (
SELECT el.season, el.tixeventtitleshort, el.tixeventstartdate, el.tixeventlookupid ,
	LTRIM(RIGHT(el.tixeventtitleshort,LEN(el.tixeventtitleshort)-CHARINDEX(' vs', el.tixeventtitleshort) - 3)) AS opponent, 
  x.tixsyspricecodedesc, x.tixsyspricecodetypedesc, 'Hidden' AS tixsyspriceleveldesc, x.attend, x.pricecodegroup
FROM #EventList el,
	(SELECT 'Band' tixsyspricecodedesc, 'Band' tixsyspricecodetypedesc, 75 attend, 'BDAY' pricecodegroup
	 UNION ALL
	 SELECT 'Dance Team' tixsyspricecodedesc, 'Dance Team' tixsyspricecodetypedesc, 21 attend, 'BDAY' pricecodegroup
	 UNION ALL
	 SELECT 'Aggie Angels' tixsyspricecodedesc, 'Aggie Angels' tixsyspricecodetypedesc, 39 attend, 'BDAY' pricecodegroup
	 UNION ALL
	 SELECT 'Yell Leaders' tixsyspricecodedesc, 'Yell Leaders' tixsyspricecodetypedesc, 5 attend, 'BDAY' pricecodegroup
	 UNION ALL
	 SELECT 'Staff/Media/Teams' tixsyspricecodedesc, 'Staff/Media/Teams' tixsyspricecodetypedesc, 300 attend, 'Main' pricecodegroup
	 UNION ALL
	 SELECT 'Scan Count' tixsyspricecodedesc, 'Scan Count' tixsyspricecodetypedesc, 0 attend, 'Scan' pricecodegroup
	 UNION ALL
	 SELECT 'Flash Seats' tixsyspricecodedesc, 'Flash Seats' tixsyspricecodetypedesc, 0 attend, 'Flash' pricecodegroup
	 ) x
) e
GO
