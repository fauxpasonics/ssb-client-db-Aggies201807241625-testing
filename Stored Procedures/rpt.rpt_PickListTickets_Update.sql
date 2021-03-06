SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--EXEC  [rpt].[rpt_PickListTickets_Dan111815] '3531'
--EXEC  [rpt].[rpt_PickListTickets] '3531'


CREATE  PROCEDURE [rpt].[rpt_PickListTickets_Update]  --(@EventID NUMERIC, @EntryDatePick DATE) 
WITH RECOMPILE  AS  

BEGIN

--IF OBJECT_ID('tempdb..#eventcustomer') IS NOT NULL DROP TABLE #eventcustomer
--IF OBJECT_ID('tempdb..#prioritypoints') IS NOT NULL DROP TABLE #prioritypoints


--DROP tabe E #EventCustomer

--DROP tabe E #PriorityPoints



--DECLARE @EventCustomer TABLE(contactID INT, ADNumber INT)
--DECLARE @PriorityPoints TABLE(ADNumber INT, PriorityPoints FLOAT)

/*
DECLARE @EntryDate DATETIME
SET @EntryDate = (SELECT MAX(CAST(EntryDate AS DATE)) AS EntryDate FROM dbo.ADVHistoricalPriorityPoints WHERE EntryDate < @EntryDatePick )

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
	--hpp.ContactID, switching to ADNumber
	ec.ADNumber
	--,hpp.curr_yr_cash_pts AS prioritypoints
	,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  --2015.10.29 Updated calculation per Amy - DT
--INTO #prioritypoints
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN #EventCustomer ec 
	ON hpp.ContactID = ec.ContactID
WHERE CONVERT (date, EntryDate)  =  @EntryDate 
	-- AND curr_yr_cash_pts <> 0 --removed to match Amy's logic
	

CREATE UNIQUE INDEX IDX02 ON #PriorityPoints (ADNumber) 


*/
truncate table rpt.rpt_PickListHistory_Hist

INSERT INTO rpt.rpt_PickListHistory_Hist
( tixeventid ,
          accountnumber ,
          OrderID ,
          CustomerName ,
		  FirstName ,
		  LastName ,
          CustomerType ,
          EventDesc ,
          tixsyspricecodedesc ,
          tixsyspricecodecode ,
          DeliveryMethod ,
          section ,
          row ,
          seats ,
          Qty ,
          tixsyspriceleveldesc ,
          Description
        )

SELECT
	e.tixeventid
	,c.accountnumber
	,og.ordergroup AS OrderID
	,ISNULL(c.fullname, c.firstname+' '+c.lastname) AS CustomerName
	,c.firstname
	,c.lastname
	,pc.tixsyspricecodealtprintdesc AS CustomerType
	--,hpp.PriorityPoints AS PriorityPoints
	--,hpp.Rank AS Rank
	,e.tixeventtitleshort AS EventDesc
	,pc.tixsyspricecodedesc
	,pc.tixsyspricecodecode
	,'' AS DeliveryMethod
	,sec.tixseatgroupdesc AS section
	,rw.tixseatgroupdesc AS row
	,CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc)
		THEN MIN(tixseatdesc)
		ELSE MIN(tixseatdesc)+'-'+MAX(a.tixseatdesc) 
	END AS seats
	, CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc)
		THEN 1
		ELSE MAX(CAST(a.tixseatid AS INT)) - MIN(CAST(a.tixseatid AS INT)) +1
	END AS Qty
	,pl.tixsyspriceleveldesc
	,com.[Description]
	--, rank() over (partition by con.contactID order by hpp.entryDate desc) as daterank 
	--,hpp.curr_yr_cash_pts as prioritypoints



FROM [ods].[VTXtixeventzoneseats] a
JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
JOIN [ods].[VTXtixsysseatgrouptypes] gt1 
	ON rw.tixseatgrouptype = gt1.tixsysseatgrouptypecode
LEFT JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
LEFT JOIN [ods].[VTXtixsysseatgrouptypes] gt2 
	ON sec.tixseatgrouptype = gt2.tixsysseatgrouptypecode
--JOIN [ods].[VTXtixeventzoneseatgroups] hood 
--	ON sec.tixseatgroupparentgroup = hood.tixseatgroupid 
--	AND a.tixeventid = hood.tixeventid 
--	AND a.tixeventzoneid = hood.tixeventzoneid
--JOIN [ods].[VTXtixsysseatgrouptypes] gt3 
--	ON hood.tixseatgrouptype = gt3.tixsysseatgrouptypecode
JOIN [ods].[VTXtixsyspricecodes] pc 
	--ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS VARCHAR(100))
	ON CAST(CASE WHEN a.tixseatpricecode = '' THEN NULL ELSE a.tixseatpricecode END AS NUMERIC) = pc.tixsyspricecodecode
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid
	--	AND e.tixeventid = @EventID -- moved here for LJ
JOIN [ods].[VTXordergroups] og 
	--ON a.tixseatordergroupid = CAST(og.ordergroup AS VARCHAR(100))
	ON CAST(CASE WHEN a.tixseatordergroupid = '' THEN NULL ELSE a.tixseatordergroupid END AS NUMERIC) = og.ordergroup
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id 
		AND c.accountnumber NOT LIKE '%[A-Z]%' -- moved here for LJ
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
LEFT JOIN [ods].[VTXcomments] com
	ON og.commentid = com.commentid
LEFT JOIN [ods].[VTXtixsyspricelevels] pl
	ON rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode

--LEFT JOIN #PriorityPoints hpp  
--	ON c.accountnumber = hpp.ADNumber

WHERE 1=1 

	--AND e.tixeventid = 3770
	--AND c.accountnumber = '101009642'

GROUP BY 
	e.tixeventid
	,c.accountnumber
	,og.ordergroup
	,c.fullname
	,pc.tixsyspricecodealtprintdesc
	,e.tixeventtitleshort
	,pc.tixsyspricecodedesc
	,pc.tixsyspricecodecode
	,sec.tixseatgroupdesc
	,rw.tixseatgroupdesc
	,pl.tixsyspriceleveldesc
	,com.[Description]
	--,hpp.PriorityPoints
	,c.firstname
	,c.lastname

--ORDER BY hpp.prioritypoints DESC
--ORDER BY c.accountnumber


END
GO
