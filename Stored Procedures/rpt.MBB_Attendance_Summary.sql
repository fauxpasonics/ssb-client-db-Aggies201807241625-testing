SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[MBB_Attendance_Summary] (@season NVARCHAR(10)) as
BEGIN

--exec [rpt].[MBB_Attendance_Summary] 'B14-MB'

--DECLARE @season NVARCHAR(10)
--SET @season = 'B14-MB'

IF OBJECT_ID('tempdb..#games') IS NOT NULL
    DROP TABLE #games

CREATE TABLE #games  (id INT IDENTITY(1,1), opponent NVARCHAR(max), tixeventlookupid NVARCHAR(max), tixeventstartdate DATETIME2)
INSERT INTO #games
        ( tixeventstartdate, tixeventlookupid, opponent )
SELECT DISTINCT
tixeventstartdate,
tixeventlookupid,
opponent
FROM rpt.MBB_Attendance r
WHERE r.season = @season

UNION ALL
(
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
SELECT NULL, NULL, NULL
)


--SELECT * FROM @games

DECLARE @columns NVARCHAR(MAX)
SET @columns = N'';
SELECT @columns += N', p.' + QUOTENAME(tixeventlookupid)
  FROM (SELECT TOP 25 ISNULL(tixeventlookupid,'NoGame'+CAST(id AS NVARCHAR(2))) tixeventlookupid FROM #games
) AS x ;

set @columns = REPLACE(@columns, 'p.[NoGame', 'NULL as [NoGame')

--SELECT @columns

DECLARE @opponents NVARCHAR(MAX)
SET @opponents = N'';
SELECT @opponents += N', p.' + QUOTENAME(opponent)
  FROM (SELECT TOP 25 ISNULL(opponent,'NoGame'+CAST(id AS NVARCHAR(2))) opponent FROM #games
) AS x ;

--SELECT @opponents
set @opponents = REPLACE(@opponents, 'p.[NoGame', 'NULL as [NoGame')



DECLARE @lookupidrow NVARCHAR(max)
SET @lookupidrow = STUFF(REPLACE(@columns,'p.',''), 1, 2, '')

SET @lookupidrow = REPLACE(REPLACE(@lookupidrow,'[',''''),']','''')

SET @lookupidrow = 'SELECT ''HeaderLink'' as DataType, NULL as tixsyspricecodetypedesc, ' + @lookupidrow

--SELECT @lookupidrow

DECLARE @opponentrow NVARCHAR(max)
SET @opponentrow = STUFF(REPLACE(@opponents,'p.',''), 1, 2, '')

SET @opponentrow = REPLACE(REPLACE(@opponentrow,'[',''''),']','''')

SET @opponentrow = 'SELECT ''Header'' as DataType, ''Price Code/Promotion'' as tixsyspricecodetypedesc, ' + @opponentrow




DECLARE @dyncolumns NVARCHAR(MAX)
SET @dyncolumns = N'';
SELECT @dyncolumns += N', p.' + QUOTENAME(tixeventlookupid)
  FROM (SELECT tixeventlookupid FROM #games WHERE tixeventlookupid IS NOT NULL
) AS x ;

DECLARE @sql NVARCHAR(max)
SET @sql = N'IF OBJECT_ID(''tempdb..#summary'') IS NOT NULL
    DROP TABLE #summary

CREATE TABLE #summary  
	(DataType nvarchar(max),
	 tixsyspricecodetypedesc NVARCHAR(max),
	 game01 nvarchar(25),
	 game02 nvarchar(25),
	 game03 nvarchar(25),
	 game04 nvarchar(25),
	 game05 nvarchar(25),
	 game06 nvarchar(25),
	 game07 nvarchar(25),
	 game08 nvarchar(25),
	 game09 nvarchar(25),
	 game10 nvarchar(25),
	 game11 nvarchar(25),
	 game12 nvarchar(25),
	 game13 nvarchar(25),
	 game14 nvarchar(25),
	 game15 nvarchar(25),
	 game16 nvarchar(25),
	 game17 nvarchar(25),
	 game18 nvarchar(25),
	 game19 nvarchar(25),
	 game20 nvarchar(25),
	 game21 nvarchar(25),
	 game22 nvarchar(25),
	 game23 nvarchar(25),
	 game24 nvarchar(25),
	 game25 nvarchar(25))

INSERT INTO #summary
        ( DataType ,
		  tixsyspricecodetypedesc ,
          game01 ,
          game02 ,
          game03 ,
          game04 ,
          game05 ,
          game06 ,
          game07 ,
          game08 ,
          game09 ,
          game10 ,
          game11 ,
          game12 ,
          game13 ,
          game14 ,
          game15 ,
          game16 ,
          game17 ,
          game18 ,
          game19 ,
          game20 ,
          game21 ,
          game22 ,
          game23 ,
          game24 ,
          game25
        )
'+
@lookupidrow +
'
union ' +
@opponentrow +
'

INSERT INTO #summary
        ( DataType ,
		  tixsyspricecodetypedesc ,
          game01 ,
          game02 ,
          game03 ,
          game04 ,
          game05 ,
          game06 ,
          game07 ,
          game08 ,
          game09 ,
          game10 ,
          game11 ,
          game12 ,
          game13 ,
          game14 ,
          game15 ,
          game16 ,
          game17 ,
          game18 ,
          game19 ,
          game20 ,
          game21 ,
          game22 ,
          game23 ,
          game24 ,
          game25
        )

SELECT CASE WHEN tixsyspricecodetypedesc IN (''Scan Count'', ''Flash Seats'') THEN ''SubSection'' ELSE ''Detail'' END
	, tixsyspricecodetypedesc, ' + STUFF(@columns, 1, 2, '') + '
FROM
(
  SELECT 
tixeventlookupid,  
tixsyspricecodetypedesc,
SUM(r.attend) attend 
FROM rpt.MBB_Attendance r
WHERE r.season = ''' + @season + '''
-- AND r.pricecodegroup NOT IN (''Scan'', ''Flash'')
GROUP BY 
r.tixeventlookupid ,
r.tixsyspricecodetypedesc
) AS j
PIVOT
(
  SUM(attend) FOR tixeventlookupid IN ('
  + STUFF(REPLACE(@dyncolumns, ', p.[', ',['), 1, 1, '')
  + ')
) AS p;

select s.*, 
case when DataType = ''Detail'' then isnull(cast(game01 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game02 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game03 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game04 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game05 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game06 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game07 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game08 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game09 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game10 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game11 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game12 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game13 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game14 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game15 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game16 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game17 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game18 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game19 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game20 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game21 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game22 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game23 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game24 as int),0) else NULL end +
case when DataType = ''Detail'' then isnull(cast(game25 as int),0) else NULL end Total
from #summary s


'
; 
--PRINT @sql;

IF OBJECT_ID('tempdb..#sum') IS NOT NULL
    DROP TABLE #sum

CREATE TABLE #sum  
	(DataType nvarchar(max),
	 tixsyspricecodetypedesc NVARCHAR(max),
	 game01 nvarchar(25),
	 game02 nvarchar(25),
	 game03 nvarchar(25),
	 game04 nvarchar(25),
	 game05 nvarchar(25),
	 game06 nvarchar(25),
	 game07 nvarchar(25),
	 game08 nvarchar(25),
	 game09 nvarchar(25),
	 game10 nvarchar(25),
	 game11 nvarchar(25),
	 game12 nvarchar(25),
	 game13 nvarchar(25),
	 game14 nvarchar(25),
	 game15 nvarchar(25),
	 game16 nvarchar(25),
	 game17 nvarchar(25),
	 game18 nvarchar(25),
	 game19 nvarchar(25),
	 game20 nvarchar(25),
	 game21 nvarchar(25),
	 game22 nvarchar(25),
	 game23 nvarchar(25),
	 game24 nvarchar(25),
	 game25 nvarchar(25),
	 total  NVARCHAR(25) )

INSERT INTO #sum
        ( DataType ,
          tixsyspricecodetypedesc ,
          game01 ,
          game02 ,
          game03 ,
          game04 ,
          game05 ,
          game06 ,
          game07 ,
          game08 ,
          game09 ,
          game10 ,
          game11 ,
          game12 ,
          game13 ,
          game14 ,
          game15 ,
          game16 ,
          game17 ,
          game18 ,
          game19 ,
          game20 ,
          game21 ,
          game22 ,
          game23 ,
          game24 ,
          game25 ,
		  total
        )
  
EXEC sp_executesql @sql

SELECT DataType ,
          tixsyspricecodetypedesc ,
          game01 ,
          game02 ,
          game03 ,
          game04 ,
          game05 ,
          game06 ,
          game07 ,
          game08 ,
          game09 ,
          game10 ,
          game11 ,
          game12 ,
          game13 ,
          game14 ,
          game15 ,
          game16 ,
          game17 ,
          game18 ,
          game19 ,
          game20 ,
          game21 ,
          game22 ,
          game23 ,
          game24 ,
          game25 ,
		  CASE WHEN tixsyspricecodetypedesc = 'Price Code/Promotion' THEN 'Season' ELSE total END AS 
		  total 
FROM #sum
WHERE DataType <> 'SubSection'

UNION ALL

SELECT * 
FROM (
SELECT 'Total'  AS DataType,
CASE WHEN (GROUPING(tixsyspricecodetypedesc) = 1) THEN 'Total'
            ELSE ISNULL(tixsyspricecodetypedesc, 'UNKNOWN')
       END AS tixsyspricecodetypedesc,

cast(sum(case when x.DataType = 'Detail' then cast(game01 as int) else NULL end) as nvarchar(25)) as game01,
cast(sum(case when x.DataType = 'Detail' then cast(game02 as int) else NULL end) as nvarchar(25)) as game02,
cast(sum(case when x.DataType = 'Detail' then cast(game03 as int) else NULL end) as nvarchar(25)) as game03,
cast(sum(case when x.DataType = 'Detail' then cast(game04 as int) else NULL end) as nvarchar(25)) as game04,
cast(sum(case when x.DataType = 'Detail' then cast(game05 as int) else NULL end) as nvarchar(25)) as game05,
cast(sum(case when x.DataType = 'Detail' then cast(game06 as int) else NULL end) as nvarchar(25)) as game06,
cast(sum(case when x.DataType = 'Detail' then cast(game07 as int) else NULL end) as nvarchar(25)) as game07,
cast(sum(case when x.DataType = 'Detail' then cast(game08 as int) else NULL end) as nvarchar(25)) as game08,
cast(sum(case when x.DataType = 'Detail' then cast(game09 as int) else NULL end) as nvarchar(25)) as game09,
cast(sum(case when x.DataType = 'Detail' then cast(game10 as int) else NULL end) as nvarchar(25)) as game10,
cast(sum(case when x.DataType = 'Detail' then cast(game11 as int) else NULL end) as nvarchar(25)) as game11,
cast(sum(case when x.DataType = 'Detail' then cast(game12 as int) else NULL end) as nvarchar(25)) as game12,
cast(sum(case when x.DataType = 'Detail' then cast(game13 as int) else NULL end) as nvarchar(25)) as game13,
cast(sum(case when x.DataType = 'Detail' then cast(game14 as int) else NULL end) as nvarchar(25)) as game14,
cast(sum(case when x.DataType = 'Detail' then cast(game15 as int) else NULL end) as nvarchar(25)) as game15,
cast(sum(case when x.DataType = 'Detail' then cast(game16 as int) else NULL end) as nvarchar(25)) as game16,
cast(sum(case when x.DataType = 'Detail' then cast(game17 as int) else NULL end) as nvarchar(25)) as game17,
cast(sum(case when x.DataType = 'Detail' then cast(game18 as int) else NULL end) as nvarchar(25)) as game18,
cast(sum(case when x.DataType = 'Detail' then cast(game19 as int) else NULL end) as nvarchar(25)) as game19,
cast(sum(case when x.DataType = 'Detail' then cast(game20 as int) else NULL end) as nvarchar(25)) as game20,
cast(sum(case when x.DataType = 'Detail' then cast(game21 as int) else NULL end) as nvarchar(25)) as game21,
cast(sum(case when x.DataType = 'Detail' then cast(game22 as int) else NULL end) as nvarchar(25)) as game22,
cast(sum(case when x.DataType = 'Detail' then cast(game23 as int) else NULL end) as nvarchar(25)) as game23,
cast(sum(case when x.DataType = 'Detail' then cast(game24 as int) else NULL end) as nvarchar(25)) as game24,
cast(sum(case when x.DataType = 'Detail' then cast(game25 as int) else NULL end) as nvarchar(25)) as game25,
cast(sum(case when x.DataType = 'Detail' then cast(total  as int) else NULL end) as nvarchar(25)) as total

FROM #sum x
WHERE x.DataType = 'Detail'
GROUP BY x.tixsyspricecodetypedesc WITH ROLLUP ) b
WHERE tixsyspricecodetypedesc = 'Total'

UNION ALL

SELECT * 
FROM (
SELECT 'Total'  AS DataType,
CASE WHEN (GROUPING(tixsyspricecodetypedesc) = 1) THEN 'Announced Total'
            ELSE ISNULL(tixsyspricecodetypedesc, 'UNKNOWN')
       END AS tixsyspricecodetypedesc,

cast(sum(case when x.DataType = 'Detail' then cast(game01 as int) else NULL end) as nvarchar(25)) as game01,
cast(sum(case when x.DataType = 'Detail' then cast(game02 as int) else NULL end) as nvarchar(25)) as game02,
cast(sum(case when x.DataType = 'Detail' then cast(game03 as int) else NULL end) as nvarchar(25)) as game03,
cast(sum(case when x.DataType = 'Detail' then cast(game04 as int) else NULL end) as nvarchar(25)) as game04,
cast(sum(case when x.DataType = 'Detail' then cast(game05 as int) else NULL end) as nvarchar(25)) as game05,
cast(sum(case when x.DataType = 'Detail' then cast(game06 as int) else NULL end) as nvarchar(25)) as game06,
cast(sum(case when x.DataType = 'Detail' then cast(game07 as int) else NULL end) as nvarchar(25)) as game07,
cast(sum(case when x.DataType = 'Detail' then cast(game08 as int) else NULL end) as nvarchar(25)) as game08,
cast(sum(case when x.DataType = 'Detail' then cast(game09 as int) else NULL end) as nvarchar(25)) as game09,
cast(sum(case when x.DataType = 'Detail' then cast(game10 as int) else NULL end) as nvarchar(25)) as game10,
cast(sum(case when x.DataType = 'Detail' then cast(game11 as int) else NULL end) as nvarchar(25)) as game11,
cast(sum(case when x.DataType = 'Detail' then cast(game12 as int) else NULL end) as nvarchar(25)) as game12,
cast(sum(case when x.DataType = 'Detail' then cast(game13 as int) else NULL end) as nvarchar(25)) as game13,
cast(sum(case when x.DataType = 'Detail' then cast(game14 as int) else NULL end) as nvarchar(25)) as game14,
cast(sum(case when x.DataType = 'Detail' then cast(game15 as int) else NULL end) as nvarchar(25)) as game15,
cast(sum(case when x.DataType = 'Detail' then cast(game16 as int) else NULL end) as nvarchar(25)) as game16,
cast(sum(case when x.DataType = 'Detail' then cast(game17 as int) else NULL end) as nvarchar(25)) as game17,
cast(sum(case when x.DataType = 'Detail' then cast(game18 as int) else NULL end) as nvarchar(25)) as game18,
cast(sum(case when x.DataType = 'Detail' then cast(game19 as int) else NULL end) as nvarchar(25)) as game19,
cast(sum(case when x.DataType = 'Detail' then cast(game20 as int) else NULL end) as nvarchar(25)) as game20,
cast(sum(case when x.DataType = 'Detail' then cast(game21 as int) else NULL end) as nvarchar(25)) as game21,
cast(sum(case when x.DataType = 'Detail' then cast(game22 as int) else NULL end) as nvarchar(25)) as game22,
cast(sum(case when x.DataType = 'Detail' then cast(game23 as int) else NULL end) as nvarchar(25)) as game23,
cast(sum(case when x.DataType = 'Detail' then cast(game24 as int) else NULL end) as nvarchar(25)) as game24,
cast(sum(case when x.DataType = 'Detail' then cast(game25 as int) else NULL end) as nvarchar(25)) as game25,
cast(sum(case when x.DataType = 'Detail' then cast(total  as int) else NULL end) as nvarchar(25)) as total

FROM #sum x
WHERE x.DataType = 'Detail'
GROUP BY x.tixsyspricecodetypedesc WITH ROLLUP ) b
WHERE tixsyspricecodetypedesc = 'Announced Total'

UNION ALL
SELECT
'Detail' AS DataType ,
' ' AS tixsyspricecodetypedesc ,
NULL AS game01 ,
NULL AS game02 ,
NULL AS game03 ,
NULL AS game04 ,
NULL AS game05 ,
NULL AS game06 ,
NULL AS game07 ,
NULL AS game08 ,
NULL AS game09 ,
NULL AS game10 ,
NULL AS game11 ,
NULL AS game12 ,
NULL AS game13 ,
NULL AS game14 ,
NULL AS game15 ,
NULL AS game16 ,
NULL AS game17 ,
NULL AS game18 ,
NULL AS game19 ,
NULL AS game20 ,
NULL AS game21 ,
NULL AS game22 ,
NULL AS game23 ,
NULL AS game24 ,
NULL AS game25 ,
NULL AS total

UNION ALL
SELECT
'Detail' AS DataType ,
'.' AS tixsyspricecodetypedesc ,
NULL AS game01 ,
NULL AS game02 ,
NULL AS game03 ,
NULL AS game04 ,
NULL AS game05 ,
NULL AS game06 ,
NULL AS game07 ,
NULL AS game08 ,
NULL AS game09 ,
NULL AS game10 ,
NULL AS game11 ,
NULL AS game12 ,
NULL AS game13 ,
NULL AS game14 ,
NULL AS game15 ,
NULL AS game16 ,
NULL AS game17 ,
NULL AS game18 ,
NULL AS game19 ,
NULL AS game20 ,
NULL AS game21 ,
NULL AS game22 ,
NULL AS game23 ,
NULL AS game24 ,
NULL AS game25 ,
NULL AS total

UNION ALL
SELECT * FROM (
SELECT TOP 100 PERCENT
'SubSection' AS DataType,
CASE WHEN (GROUPING(tixsyspricecodetypedesc) = 1) THEN 'Drop Count'
            ELSE ISNULL(tixsyspricecodetypedesc, 'UNKNOWN')
       END AS tixsyspricecodetypedesc,
	cast(sum(Cast(game01 as int)) as nvarchar(25)) as game01,
	cast(sum(Cast(game02 as int)) as nvarchar(25)) as game02,
	cast(sum(Cast(game03 as int)) as nvarchar(25)) as game03,
	cast(sum(Cast(game04 as int)) as nvarchar(25)) as game04,
	cast(sum(Cast(game05 as int)) as nvarchar(25)) as game05,
	cast(sum(Cast(game06 as int)) as nvarchar(25)) as game06,
	cast(sum(Cast(game07 as int)) as nvarchar(25)) as game07,
	cast(sum(Cast(game08 as int)) as nvarchar(25)) as game08,
	cast(sum(Cast(game09 as int)) as nvarchar(25)) as game09,
	cast(sum(Cast(game10 as int)) as nvarchar(25)) as game10,
	cast(sum(Cast(game11 as int)) as nvarchar(25)) as game11,
	cast(sum(Cast(game12 as int)) as nvarchar(25)) as game12,
	cast(sum(Cast(game13 as int)) as nvarchar(25)) as game13,
	cast(sum(Cast(game14 as int)) as nvarchar(25)) as game14,
	cast(sum(Cast(game15 as int)) as nvarchar(25)) as game15,
	cast(sum(Cast(game16 as int)) as nvarchar(25)) as game16,
	cast(sum(Cast(game17 as int)) as nvarchar(25)) as game17,
	cast(sum(Cast(game18 as int)) as nvarchar(25)) as game18,
	cast(sum(Cast(game19 as int)) as nvarchar(25)) as game19,
	cast(sum(Cast(game20 as int)) as nvarchar(25)) as game20,
	cast(sum(Cast(game21 as int)) as nvarchar(25)) as game21,
	cast(sum(Cast(game22 as int)) as nvarchar(25)) as game22,
	cast(sum(Cast(game23 as int)) as nvarchar(25)) as game23,
	cast(sum(Cast(game24 as int)) as nvarchar(25)) as game24,
	cast(sum(Cast(game25 as int)) as nvarchar(25)) as game25,
	cast(sum(Cast(total  as int)) as nvarchar(25)) as total   
FROM (
SELECT DataType ,
          tixsyspricecodetypedesc ,
          game01 ,
          game02 ,
          game03 ,
          game04 ,
          game05 ,
          game06 ,
          game07 ,
          game08 ,
          game09 ,
          game10 ,
          game11 ,
          game12 ,
          game13 ,
          game14 ,
          game15 ,
          game16 ,
          game17 ,
          game18 ,
          game19 ,
          game20 ,
          game21 ,
          game22 ,
          game23 ,
          game24 ,
          game25 ,
		  total 
FROM #sum
WHERE DataType = 'SubSection'

UNION ALL

SELECT 'SubSection' AS DataType ,
          'Band, Aggie Angels, Dance Team, Yell Leaders' as	tixsyspricecodetypedesc ,
          cast(sum(case when x.DataType = 'Detail' then cast(game01 as int) else NULL end) as nvarchar(25)) as game01,
cast(sum(case when x.DataType = 'Detail' then cast(game02 as int) else NULL end) as nvarchar(25)) as game02,
cast(sum(case when x.DataType = 'Detail' then cast(game03 as int) else NULL end) as nvarchar(25)) as game03,
cast(sum(case when x.DataType = 'Detail' then cast(game04 as int) else NULL end) as nvarchar(25)) as game04,
cast(sum(case when x.DataType = 'Detail' then cast(game05 as int) else NULL end) as nvarchar(25)) as game05,
cast(sum(case when x.DataType = 'Detail' then cast(game06 as int) else NULL end) as nvarchar(25)) as game06,
cast(sum(case when x.DataType = 'Detail' then cast(game07 as int) else NULL end) as nvarchar(25)) as game07,
cast(sum(case when x.DataType = 'Detail' then cast(game08 as int) else NULL end) as nvarchar(25)) as game08,
cast(sum(case when x.DataType = 'Detail' then cast(game09 as int) else NULL end) as nvarchar(25)) as game09,
cast(sum(case when x.DataType = 'Detail' then cast(game10 as int) else NULL end) as nvarchar(25)) as game10,
cast(sum(case when x.DataType = 'Detail' then cast(game11 as int) else NULL end) as nvarchar(25)) as game11,
cast(sum(case when x.DataType = 'Detail' then cast(game12 as int) else NULL end) as nvarchar(25)) as game12,
cast(sum(case when x.DataType = 'Detail' then cast(game13 as int) else NULL end) as nvarchar(25)) as game13,
cast(sum(case when x.DataType = 'Detail' then cast(game14 as int) else NULL end) as nvarchar(25)) as game14,
cast(sum(case when x.DataType = 'Detail' then cast(game15 as int) else NULL end) as nvarchar(25)) as game15,
cast(sum(case when x.DataType = 'Detail' then cast(game16 as int) else NULL end) as nvarchar(25)) as game16,
cast(sum(case when x.DataType = 'Detail' then cast(game17 as int) else NULL end) as nvarchar(25)) as game17,
cast(sum(case when x.DataType = 'Detail' then cast(game18 as int) else NULL end) as nvarchar(25)) as game18,
cast(sum(case when x.DataType = 'Detail' then cast(game19 as int) else NULL end) as nvarchar(25)) as game19,
cast(sum(case when x.DataType = 'Detail' then cast(game20 as int) else NULL end) as nvarchar(25)) as game20,
cast(sum(case when x.DataType = 'Detail' then cast(game21 as int) else NULL end) as nvarchar(25)) as game21,
cast(sum(case when x.DataType = 'Detail' then cast(game22 as int) else NULL end) as nvarchar(25)) as game22,
cast(sum(case when x.DataType = 'Detail' then cast(game23 as int) else NULL end) as nvarchar(25)) as game23,
cast(sum(case when x.DataType = 'Detail' then cast(game24 as int) else NULL end) as nvarchar(25)) as game24,
cast(sum(case when x.DataType = 'Detail' then cast(game25 as int) else NULL end) as nvarchar(25)) as game25,
cast(sum(case when x.DataType = 'Detail' then cast(total  as int) else NULL end) as nvarchar(25)) as total
FROM #sum x
WHERE tixsyspricecodetypedesc IN ('Aggie Angels', 'Band', 'Dance Team', 'Yell Leaders')

UNION ALL

SELECT 'SubSection' AS DataType ,
          'Student Scan' as	tixsyspricecodetypedesc ,
          cast(sum(case when x.DataType = 'Detail' then cast(game01 as int) else NULL end) as nvarchar(25)) as game01,
cast(sum(case when x.DataType = 'Detail' then cast(game02 as int) else NULL end) as nvarchar(25)) as game02,
cast(sum(case when x.DataType = 'Detail' then cast(game03 as int) else NULL end) as nvarchar(25)) as game03,
cast(sum(case when x.DataType = 'Detail' then cast(game04 as int) else NULL end) as nvarchar(25)) as game04,
cast(sum(case when x.DataType = 'Detail' then cast(game05 as int) else NULL end) as nvarchar(25)) as game05,
cast(sum(case when x.DataType = 'Detail' then cast(game06 as int) else NULL end) as nvarchar(25)) as game06,
cast(sum(case when x.DataType = 'Detail' then cast(game07 as int) else NULL end) as nvarchar(25)) as game07,
cast(sum(case when x.DataType = 'Detail' then cast(game08 as int) else NULL end) as nvarchar(25)) as game08,
cast(sum(case when x.DataType = 'Detail' then cast(game09 as int) else NULL end) as nvarchar(25)) as game09,
cast(sum(case when x.DataType = 'Detail' then cast(game10 as int) else NULL end) as nvarchar(25)) as game10,
cast(sum(case when x.DataType = 'Detail' then cast(game11 as int) else NULL end) as nvarchar(25)) as game11,
cast(sum(case when x.DataType = 'Detail' then cast(game12 as int) else NULL end) as nvarchar(25)) as game12,
cast(sum(case when x.DataType = 'Detail' then cast(game13 as int) else NULL end) as nvarchar(25)) as game13,
cast(sum(case when x.DataType = 'Detail' then cast(game14 as int) else NULL end) as nvarchar(25)) as game14,
cast(sum(case when x.DataType = 'Detail' then cast(game15 as int) else NULL end) as nvarchar(25)) as game15,
cast(sum(case when x.DataType = 'Detail' then cast(game16 as int) else NULL end) as nvarchar(25)) as game16,
cast(sum(case when x.DataType = 'Detail' then cast(game17 as int) else NULL end) as nvarchar(25)) as game17,
cast(sum(case when x.DataType = 'Detail' then cast(game18 as int) else NULL end) as nvarchar(25)) as game18,
cast(sum(case when x.DataType = 'Detail' then cast(game19 as int) else NULL end) as nvarchar(25)) as game19,
cast(sum(case when x.DataType = 'Detail' then cast(game20 as int) else NULL end) as nvarchar(25)) as game20,
cast(sum(case when x.DataType = 'Detail' then cast(game21 as int) else NULL end) as nvarchar(25)) as game21,
cast(sum(case when x.DataType = 'Detail' then cast(game22 as int) else NULL end) as nvarchar(25)) as game22,
cast(sum(case when x.DataType = 'Detail' then cast(game23 as int) else NULL end) as nvarchar(25)) as game23,
cast(sum(case when x.DataType = 'Detail' then cast(game24 as int) else NULL end) as nvarchar(25)) as game24,
cast(sum(case when x.DataType = 'Detail' then cast(game25 as int) else NULL end) as nvarchar(25)) as game25,
cast(sum(case when x.DataType = 'Detail' then cast(total  as int) else NULL end) as nvarchar(25)) as total
FROM #sum x
WHERE tixsyspricecodetypedesc LIKE '%Student%'

UNION ALL

SELECT 'SubSection' AS DataType ,
          'Student Click Entry' as	tixsyspricecodetypedesc ,
          cast(sum(case when x.DataType = 'Detail' then cast(game01 as int) else NULL end) as nvarchar(25)) as game01,
cast(sum(case when x.DataType = 'Detail' then cast(game02 as int) else NULL end) as nvarchar(25)) as game02,
cast(sum(case when x.DataType = 'Detail' then cast(game03 as int) else NULL end) as nvarchar(25)) as game03,
cast(sum(case when x.DataType = 'Detail' then cast(game04 as int) else NULL end) as nvarchar(25)) as game04,
cast(sum(case when x.DataType = 'Detail' then cast(game05 as int) else NULL end) as nvarchar(25)) as game05,
cast(sum(case when x.DataType = 'Detail' then cast(game06 as int) else NULL end) as nvarchar(25)) as game06,
cast(sum(case when x.DataType = 'Detail' then cast(game07 as int) else NULL end) as nvarchar(25)) as game07,
cast(sum(case when x.DataType = 'Detail' then cast(game08 as int) else NULL end) as nvarchar(25)) as game08,
cast(sum(case when x.DataType = 'Detail' then cast(game09 as int) else NULL end) as nvarchar(25)) as game09,
cast(sum(case when x.DataType = 'Detail' then cast(game10 as int) else NULL end) as nvarchar(25)) as game10,
cast(sum(case when x.DataType = 'Detail' then cast(game11 as int) else NULL end) as nvarchar(25)) as game11,
cast(sum(case when x.DataType = 'Detail' then cast(game12 as int) else NULL end) as nvarchar(25)) as game12,
cast(sum(case when x.DataType = 'Detail' then cast(game13 as int) else NULL end) as nvarchar(25)) as game13,
cast(sum(case when x.DataType = 'Detail' then cast(game14 as int) else NULL end) as nvarchar(25)) as game14,
cast(sum(case when x.DataType = 'Detail' then cast(game15 as int) else NULL end) as nvarchar(25)) as game15,
cast(sum(case when x.DataType = 'Detail' then cast(game16 as int) else NULL end) as nvarchar(25)) as game16,
cast(sum(case when x.DataType = 'Detail' then cast(game17 as int) else NULL end) as nvarchar(25)) as game17,
cast(sum(case when x.DataType = 'Detail' then cast(game18 as int) else NULL end) as nvarchar(25)) as game18,
cast(sum(case when x.DataType = 'Detail' then cast(game19 as int) else NULL end) as nvarchar(25)) as game19,
cast(sum(case when x.DataType = 'Detail' then cast(game20 as int) else NULL end) as nvarchar(25)) as game20,
cast(sum(case when x.DataType = 'Detail' then cast(game21 as int) else NULL end) as nvarchar(25)) as game21,
cast(sum(case when x.DataType = 'Detail' then cast(game22 as int) else NULL end) as nvarchar(25)) as game22,
cast(sum(case when x.DataType = 'Detail' then cast(game23 as int) else NULL end) as nvarchar(25)) as game23,
cast(sum(case when x.DataType = 'Detail' then cast(game24 as int) else NULL end) as nvarchar(25)) as game24,
cast(sum(case when x.DataType = 'Detail' then cast(game25 as int) else NULL end) as nvarchar(25)) as game25,
cast(sum(case when x.DataType = 'Detail' then cast(total  as int) else NULL end) as nvarchar(25)) as total
FROM #sum x
WHERE tixsyspricecodetypedesc LIKE '%Student%'
) ss
GROUP BY tixsyspricecodetypedesc WITH ROLLUP
ORDER BY
	CASE tixsyspricecodetypedesc
		WHEN 'Scan Count' THEN 1
		WHEN 'Flash Seats' THEN 2
		WHEN 'Band, Aggie Angels, Dance Team, Yell Leaders' THEN 3
		WHEN 'Student Click Entry' THEN 4
		WHEN 'Student Scan' THEN 5
		 END ) zz

END

--exec [rpt].[MBB_Attendance_Summary] 'B14-MB'
GO
