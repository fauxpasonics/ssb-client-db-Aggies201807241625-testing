SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [kpi].[sp_KPI_DailyRun_AzureRemote]
AS

DECLARE @SQL NVARCHAR(3900), @ParmDefinition NVARCHAR(100), @Count BIGINT	

DECLARE @KPITableQueue TABLE (
UID INT PRIMARY KEY IDENTITY(1,1)
, KPIID INT
, ClientID INT
, CatId int
, DBName VARCHAR(50)
, DateId Date
)

DECLARE @QueueCatch TABLE (
KPIID INT
, ClientID INT
, CatId int
, DateId DATE
, KPIValue BIGINT	
)

INSERT INTO @KPITableQueue
        ( KPIID, ClientId, DBName, CatId, DateId )
SELECT KPIID, a.ClientId, c.Proc_DBName, a.CATID, CAST(GETDATE() AS DATE) 
FROM KPI.KPI_List a 
	INNER JOIN kpi.Categories b ON a.CATID = b.CATID
	INNER JOIN KPI.CLIENTS c ON a.ClientId = c.ClientID
WHERE b.Enabled = 1 AND a.Enabled = 1 AND c.Active = 1
AND a.[ClientSpecific] = 1
AND c.ServerName = @@SERVERNAME


INSERT INTO @KPITableQueue
        ( KPIID, ClientId, DBName, CatId, DateId )
SELECT a.KPIID, c.ClientId, CASE WHEN a.[ClientId] = -1 THEN d.Proc_DBName ELSE d.[CI_DBName] END DBName, a.CATID, CAST(GETDATE() AS DATE)  
FROM KPI.[KPI_List] a
	INNER JOIN KPI.[Categories] b ON [b].[CATID] = [a].[CATID]
	INNER JOIN KPI.[KPIClientList] c ON [c].[KPIID] = [a].[KPIID]
	INNER JOIN KPI.[CLIENTS] d ON [d].[ClientID] = [c].[ClientID]
WHERE a.[Enabled] = 1 AND b.[Enabled] = 1 AND c.[Enabled] = 1 AND d.[Active] = 1
AND a.[ClientSpecific] = 0
AND d.ServerName = @@SERVERNAME

DECLARE @Loops INT, @LoopCounter INT, @KPIID INT, @DBName VARCHAR(50)
, @ClientID INT, @CATID INT, @DateId DATE
SET @Loops = (SELECT MAX(UID) FROM @KPITableQueue)
SET @LoopCounter = 1
SET @ParmDefinition = N'@CountOUT varchar(30) OUTPUT';
SET @KPIID = 0

WHILE @Loops >= @LoopCounter
BEGIN
SET @KPIID = (SELECT KPIID FROM @KPITableQueue WHERE UID = @LoopCounter)
SET @DBName = DB_NAME() --(SELECT DBName FROM @KPITableQueue WHERE UID = @LoopCounter)
SET @ClientID = (SELECT ClientID FROM @KPITableQueue WHERE UID = @LoopCounter)
SET @CATID = (SELECT CatId FROM @KPITableQueue WHERE UID = @LoopCounter)
SET @DateId = (SELECT DateId FROM @KPITableQueue WHERE UID = @LoopCounter)


--SELECT @SQL = 'Use [' + @DBName + '] ' + KPIDetail_Query + ' SET @CountOUT = @@ROWCOUNT ' FROM CentralIntelligence.KPI.KPI_List WHERE KPIID = @KPIID
SELECT @SQL = 'Use [' + @DBName + '] SET @CountOUT = (Select COUNT(*) FROM (' + KPIDetail_Query + ') z) ' FROM KPI.KPI_List WHERE KPIID = @KPIID

--SET @SQL =  @SQL
PRINT @SQL

EXEC sp_executeSQL @SQL, @ParmDefinition, @CountOUT=@Count OUTPUT;
--SET @Count = @CountOUT;
--SELECT @Count


INSERT INTO @QueueCatch
        ( ClientID
        , CatId
        , KPIID
		, DateId
        , KPIValue
        )
VALUES (@ClientID, @CATID, @KPIID, @DateId, @Count)

SET @LoopCounter = @LoopCounter + 1
END

MERGE KPI.DailyCount TARGET
USING @QueueCatch SOURCE ON Target.KPIID = SOURCE.KPIID AND TARGET.ClientID = SOURCE.ClientID AND Target.DateID = SOURCE.DateId
WHEN MATCHED THEN UPDATE SET
TARGET.KPIID = SOURCE.KPIID
, TARGET.ClientID = SOURCE.ClientID
, TARGET.CATID = SOURCE.CATID
, TARGET.DateId = SOURCE.DateId
, TARGET.KPIValue = SOURCE.KPIValue
WHEN NOT MATCHED THEN
INSERT 
( ClientID
, CATID
, KPIID
, DateID
, KPIValue
)
VALUES ( SOURCE.ClientId
		, SOURCE.CATID
		, SOURCE.KPIID
		, SOURCE.DAteId
		, SOURCE.KPIValue
		);

SELECT * FROM KPI.DailyCount
GO
