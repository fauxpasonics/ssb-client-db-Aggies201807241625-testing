SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [kpi].[sp_IncomingKPIStore]
@ClientID INT, @KPIID INT, @KPIValue FLOAT
AS
DECLARE @ClientIDValid BIT, @KPIIDValid BIT
DECLARE @CATIDLookup INT

--SET @ClientID = 7
--SET @KPIID = 1
--SET @KPIValue = 10001

SET @ClientIDValid = (SELECT CASE WHEN COUNT(*) = 1 THEN 1 ELSE 0 END FROM [Audit_CFG].[CLIENTS] WHERE [ClientID] = @ClientID)

IF @ClientIDValid = 0
BEGIN
	PRINT 'INVALID CLIENTID'
	RETURN
END

SET @KPIIDValid = (SELECT CASE WHEN COUNT(*) = 1 THEN 1 ELSE 0 END FROM KPI.[KPI_List] WHERE [KPIID] = @KPIID)

IF @KPIIDValid = 0
BEGIN
	PRINT 'INVALID KPIID'
	RETURN
END

SET @CATIDLookup = (SELECT CATID FROM KPI.[KPI_List] WHERE KPIID = @KPIID)

DECLARE @Hold TABLE (
DateID DATE
, CLIENTID INT
, KPIID INT
, CATID INT
, KPIVALUE FLOAT
)

INSERT INTO @Hold
        ( [DateID] ,
          [CLIENTID] ,
          [KPIID] ,
          [CATID] ,
          [KPIVALUE]
        )
VALUES  ( GETDATE()
          , @CLIENTID
          , @KPIID
          , @CATIDLookup
          , @KPIValue
        )

MERGE INTO KPI.[DailyCount] TARGET
USING @Hold SOURCE 
ON SOURCE.[CLIENTID] = TARGET.[ClientID]
AND SOURCE.[KPIID] = TARGET.[KPIID]
AND SOURCE.[DateID] = TARGET.[DateID]
WHEN MATCHED THEN UPDATE SET 
CATID = SOURCE.[CATID]
, [KPIVALUE] = Source.[KPIVALUE]
WHEN NOT MATCHED THEN
INSERT ([DateID], [CLIENTID],[KPIID], [CATID], [KPIVALUE])
VALUES( SOURCE.[DateID], SOURCE.[CLIENTID],SOURCE.[KPIID], SOURCE.[CATID], SOURCE.[KPIVALUE]);
GO