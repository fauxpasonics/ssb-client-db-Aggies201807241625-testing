SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


----------------------prod. rpt table in use

--EXEC  [rpt].[rpt_PickListTickets] '3531'


CREATE    PROCEDURE [rpt].[rpt_PickListTickets]  (@EventID NUMERIC) WITH RECOMPILE  AS  

BEGIN

--IF OBJECT_ID('tempdb..#eventcustomer') IS NOT NULL DROP TABLE #eventcustomer
--IF OBJECT_ID('tempdb..#prioritypoints') IS NOT NULL DROP TABLE #prioritypoints


--DROP tabe E #EventCustomer

--DROP tabe E #PriorityPoints



DECLARE @EventCustomer TABLE(contactID INT, ADNumber INT)
DECLARE @PriorityPoints TABLE(ADNumber INT, PriorityPoints FLOAT)
DECLARE @EntryDate DATETIME
SET @EntryDate = (SELECT MAX(CAST(EntryDate AS DATE)) AS EntryDate FROM dbo.ADVHistoricalPriorityPoints)
--DECLARE @EventID AS NUMERIC 
--SET @EventID = 1495

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE TABLE #EventCustomer (contactID INT, ADNumber INT)

INSERT INTO #EventCustomer(contactID, ADNumber)
SELECT DISTINCT 
	con.ContactID
	,con.ADNumber
--INTO #eventcustomer
FROM ods.VTXtixeventzoneseats ezs
JOIN ods.VTXordergroups og
	ON  ezs.tixseatordergroupid   = og.ordergroup
JOIN ods.VTXcustomers c
	ON og.customerid = c.id
JOIN ods.ADVContact con
	ON c.accountnumber = con.ADNumber
WHERE tixeventid = @EventID
 AND ezs.tixseatordergroupid <> '' 
AND c.accountnumber NOT LIKE '%[A-Z]%'


CREATE UNIQUE INDEX IDX01 ON #EventCustomer(contactID, ADNumber) 



CREATE TABLE  #PriorityPoints (ADNumber INT, PriorityPoints FLOAT)
INSERT INTO #PriorityPoints( ADNumber, PriorityPoints )
SELECT 
	hpp.ContactID
	--,hpp.curr_yr_cash_pts AS prioritypoints
	,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  --2015.10.29 Updated calculation per Amy - DT
--INTO #prioritypoints
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN #EventCustomer ec 
	ON hpp.ContactID = ec.ContactID
WHERE CONVERT (date, EntryDate)  =  @EntryDate AND curr_yr_cash_pts <> 0


CREATE UNIQUE INDEX IDX02 ON #PriorityPoints (ADNumber) 


SELECT
	 accountnumber
	,OrderID
	,CustomerName
	,CustomerType
	,PriorityPoints
	,EventDesc
	,tixsyspricecodedesc
	,'' AS DeliveryMethod
	,section
	,[row]
	,seats
	,tixsyspriceleveldesc
	,[Description]

FROM   TixHistoryTest a  LEFT JOIN #PriorityPoints hpp  ON a.accountnumber = hpp.ADNumber 

WHERE 1=1 

	AND tixeventid = @EventID
	AND accountnumber NOT LIKE '%[A-Z]%'

GROUP BY 
	 accountnumber
	,OrderID
	,CustomerName
	,CustomerType
	,PriorityPoints
	,EventDesc
	,tixsyspricecodedesc
	,section
	,[row]
	,seats
	,tixsyspriceleveldesc
	,[Description]

ORDER BY hpp.prioritypoints DESC


END
GO
