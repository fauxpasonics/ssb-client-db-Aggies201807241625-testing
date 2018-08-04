SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [rpt].[rpt_PickListTicketsTest] (@EventID NUMERIC) AS 

--IF OBJECT_ID('tempdb..#eventcustomer') IS NOT NULL DROP TABLE #eventcustomer
--IF OBJECT_ID('tempdb..#prioritypoints') IS NOT NULL DROP TABLE #prioritypoints

DECLARE @EventCustomer TABLE(contactID INT, ADNumber INT)
DECLARE @PriorityPoints TABLE(ADNumber INT, PriorityPoints FLOAT)
DECLARE @EntryDate DATETIME
SET @EntryDate = (SELECT MAX(CAST(EntryDate AS DATE)) AS EntryDate FROM dbo.ADVHistoricalPriorityPoints)

/*INSERT INTO @EventCustomer(contactID, ADNumber)
SELECT DISTINCT 
	con.ContactID
	,con.ADNumber
--INTO #eventcustomer
FROM ods.VTXtixeventzoneseats ezs
JOIN ods.VTXordergroups og
	ON CAST(CASE WHEN ezs.tixseatordergroupid = '' THEN NULL ELSE ezs.tixseatordergroupid END AS numeric) = og.ordergroup
JOIN ods.VTXcustomers c
	ON og.customerid = c.id
JOIN ods.ADVContact con
	ON c.accountnumber = con.ADNumber
WHERE tixeventid = @EventID
--WHERE tixeventid = '3156'--@EventID
AND c.accountnumber NOT LIKE '%[A-Z]%'
*/

INSERT INTO @PriorityPoints( ADNumber, PriorityPoints )
SELECT 
	hpp.ContactID
	--,hpp.curr_yr_cash_pts AS prioritypoints
	,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  --2015.10.29 Updated calculation per Amy - DT
--INTO #prioritypoints
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN @EventCustomer ec 
	ON hpp.ContactID = ec.ContactID
WHERE CAST(EntryDate AS DATE)=@EntryDate AND curr_yr_cash_pts <> 0


SELECT
	c.accountnumber
	,og.ordergroup AS OrderID
	,ISNULL(c.fullname, c.firstname+' '+c.lastname) AS CustomerName
	,pc.tixsyspricecodealtprintdesc AS CustomerType
	,hpp.PriorityPoints AS PriorityPoints
	--,hpp.Rank AS Rank
	,e.tixeventtitleshort AS EventDesc
	,pc.tixsyspricecodedesc
	,'' AS DeliveryMethod
	,sec.tixseatgroupdesc as section
	,rw.tixseatgroupdesc AS row
	,CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc)
		THEN MIN(tixseatdesc)
		ELSE MIN(tixseatdesc)+'-'+MAX(a.tixseatdesc) 
	END AS seats
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
JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
JOIN [ods].[VTXtixsysseatgrouptypes] gt2 
	ON sec.tixseatgrouptype = gt2.tixsysseatgrouptypecode
JOIN [ods].[VTXtixeventzoneseatgroups] hood 
	ON sec.tixseatgroupparentgroup = hood.tixseatgroupid 
	AND a.tixeventid = hood.tixeventid 
	AND a.tixeventzoneid = hood.tixeventzoneid
JOIN [ods].[VTXtixsysseatgrouptypes] gt3 
	ON hood.tixseatgrouptype = gt3.tixsysseatgrouptypecode
JOIN [ods].[VTXtixsyspricecodes] pc 
	--ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS VARCHAR(100))
	ON CAST(CASE WHEN a.tixseatpricecode = '' THEN NULL ELSE a.tixseatpricecode END AS NUMERIC) = pc.tixsyspricecodecode
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid
JOIN [ods].[VTXordergroups] og 
	--ON a.tixseatordergroupid = CAST(og.ordergroup AS VARCHAR(100))
	ON CAST(CASE WHEN a.tixseatordergroupid = '' THEN NULL ELSE a.tixseatordergroupid END AS numeric) = og.ordergroup
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
LEFT JOIN [ods].[VTXcomments] com
	ON og.commentid = com.commentid
LEFT JOIN [ods].[VTXtixsyspricelevels] pl
	ON rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
LEFT JOIN @PriorityPoints hpp
	ON c.accountnumber = hpp.ADNumber
--LEFT JOIN ods.ADVContact con
--	ON c.accountnumber = con.ADNumber
--LEFT JOIN (SELECT ContactID, curr_yr_cash_pts AS prioritypoints FROM ods.ADVHistoricalPriorityPoints WHERE CAST(EntryDate AS DATE)=@EntryDate AND curr_yr_cash_pts <>0) hpp
--	ON con.ContactID = hpp.ContactID
--LEFT JOIN 
--	(
--		SELECT b.ADNumber, rank() over (partition by a.contactID order by a.entryDate desc) as daterank ,a.entryDate, a.rank, a.curr_yr_cash_pts as prioritypoints
--		FROM dbo.ADVHistoricalPriorityPoints a
--		JOIN dbo.ADVContact b
--		ON a.ContactID = b.ContactID
--		AND b.ADNumber = c.AccountNumber
--	) ppts
--ON --ppts.ADnumber = c.accountnumber
----AND 
--ppts.daterank = 1
WHERE 1=1 
	--AND e.tixeventtitleshort = @Event--'F15-F12 at LSU'
	AND e.tixeventid = @EventID
	AND c.accountnumber NOT LIKE '%[A-Z]%'
GROUP BY 
	c.accountnumber
	,og.ordergroup
	,c.fullname
	,pc.tixsyspricecodealtprintdesc
	,e.tixeventtitleshort
	,pc.tixsyspricecodedesc
	,sec.tixseatgroupdesc
	,rw.tixseatgroupdesc
	,pl.tixsyspriceleveldesc
	,com.[Description]
	,hpp.PriorityPoints
	--,hpp.rank
	,c.firstname
	,c.lastname
	--,con.contactID
	--,hpp.EntryDate
	--,hpp.curr_yr_cash_pts
ORDER BY hpp.prioritypoints desc
--ORDER BY DATEPART(yyyy,e.tixeventstartdate) DESC
GO
