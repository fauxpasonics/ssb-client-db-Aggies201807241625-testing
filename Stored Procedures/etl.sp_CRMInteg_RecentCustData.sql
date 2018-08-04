SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[sp_CRMInteg_RecentCustData]
AS
-- Truncate Table etl.SFDCProcess_RecentCustData 
--INSERT INTO etl.SFDCProcess_RecentCustData (SSID, MaxTransDate, Team)
--SELECT CAST(a.SSID AS VARCHAR(100)) SSID, MAX([SSUpdatedDate]) MaxTransDate,'Coyotes-TM' Team
--FROM coyotes.dbo.dimCustomer a 
--WHERE a.SourceSystem='TM'
--GROUP BY a.SSID

TRUNCATE TABLE etl.CRMProcess_RecentCustData

DECLARE @Client VARCHAR(50)
SET @Client = 'Chiefs-TM'

SELECT x.dimcustomerid, MAX(x.maxtransdate) maxtransdate, x.team
INTO #tmpTicketSales
FROM (
SELECT f.DimCustomerID, MAX(dd.CalDate) MaxTransDate , @Client Team
--Select * 
FROM dbo.FactTicketSales f WITH(NOLOCK)
INNER JOIN dbo.DimDate  dd WITH(NOLOCK) ON dd.DimDateId = f.DimDateId
WHERE dd.CalDate >= DATEADD(YEAR, -2, GETDATE()+2)
GROUP BY f.[DimCustomerId]
) x
GROUP BY x.[DimCustomerId], x.Team

INSERT INTO etl.CRMProcess_RecentCustData (SSID, MaxTransDate, Team)
SELECT SSID, [MaxTransDate], Team FROM [#tmpTicketSales] a 
INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [b].[DimCustomerId] = [a].[DimCustomerId]



/*

SELECT b.DimCustomerId, MAX(b.UpdatedDate) Max_MDM_Date, 'Coyotes-TM' Team
INTO #tmpSFDC_Sourced
FROM ProdCopy.Account a WITH(NOLOCK)
INNER JOIN dbo.DimCustomer b WITH(NOLOCK) ON a.archtics_ID__c = CAST(b.AccountId AS NVARCHAR(20)) AND b.SourceSystem = 'TM'
WHERE Archtics_ID__c IS NOT NULL 
GROUP BY b.DimCustomerId
-- DROP TABLE #tmpSFDC_Sourced

SELECT b.DimCustomerId, MAX(a.InsertDate) MaxCDate, 'Coyotes-TM' Team
INTO #tmpNote_Sourced
FROM (
SELECT acct_id,InsertDate FROM ods.tm_note WITH (NOLOCK) WHERE task_stage_status = 'open'
) a
INNER JOIN dbo.DimCustomer b WITH(NOLOCK) ON a.acct_id = b.AccountId AND b.SourceSystem = 'TM'
GROUP BY b.DimCustomerId

SELECT b.DimCustomerId, MAX(Event_Date) MaxEventDate, 'Coyotes-TM' Team
INTO #tmpTE_Sourced
FROM (
SELECT Buyer_Archtics_ID, Event_Date FROM ods.vw_SFDC_Ticket_Exchange WITH(NOLOCK)
) a
INNER JOIN dbo.DimCustomer b WITH(NOLOCK) ON a.Buyer_Archtics_ID = b.AccountId AND b.SourceSystem = 'TM'
GROUP BY b.DimCustomerId
-- DROP TABLE #tmpTE_Sourced

SELECT b.DimCustomerId, MAX(LoadDate) MaxEventDate, 'Coyotes-TM' Team
INTO #tmpTemp_Srcd
FROM (
SELECT Temporary_Archtics_ID__c, LoadDate FROM Raiders_SFDC.stg.TempArchticsIDs WITH(NOLOCK) WHERE Archtics_ID__c IS NULL
) a
INNER JOIN dbo.DimCustomer b WITH(NOLOCK) ON a.Temporary_Archtics_ID__c = b.AccountId AND b.SourceSystem = 'TM'
GROUP BY b.DimCustomerId
-- DROP TABLE #tmpTE_Sourced
*/
-- 267,484
-- 264,541
GO
