SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [rpt].[rpt_DonorProfileTicketingAndParkingCurrent_BKP] (@ADNumber NVARCHAR(200))

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT DISTINCT
	c.accountnumber
	,cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc)
		THEN pc.tixsyspricecodedesc+':'+sec.tixseatgroupdesc+':'+rw.tixseatgroupdesc+':'+MIN(tixseatdesc)
		ELSE pc.tixsyspricecodedesc+':'+sec.tixseatgroupdesc+':'+rw.tixseatgroupdesc+':'+CAST(MIN(CASE WHEN tixseatdesc NOT LIKE '%[a-z]%' THEN CAST(tixseatdesc AS INT) ELSE tixseatdesc END) AS VARCHAR(20))+'--'+CAST(MAX(CASE WHEN tixseatdesc NOT LIKE '%[a-z]%' THEN CAST(tixseatdesc AS INT) ELSE tixseatdesc END) AS VARCHAR(20))
	END AS seatblock  --2015.10.09 Broke out seatblock into individual columns
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
	,CAST(MIN(CASE WHEN tixseatdesc NOT LIKE '%[a-z]%' THEN CAST(tixseatdesc AS INT) ELSE tixseatdesc END) AS VARCHAR(20))+'--'+CAST(MAX(CASE WHEN tixseatdesc NOT LIKE '%[a-z]%' THEN CAST(tixseatdesc AS INT) ELSE tixseatdesc END) AS VARCHAR(20)) AS seatseat
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END AS paid
	,CASE WHEN MIN(a.tixseatprinted) = 1 THEN 'X' ELSE '' END AS sent

--SELECT *
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
	ON a.tixseatpricecode = pc.tixsyspricecodecode
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid
JOIN [ods].[VTXordergroups] og 
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(200))
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1 
	AND c.accountnumber = @ADNumber
	AND DATEPART(yyyy,e.tixeventstartdate) >= @CurrentYear
	AND cat.categorytypeid = 1
	AND CAST(a.tixseatpriceafterdiscounts AS FLOAT) > 0
GROUP BY 
	c.accountnumber
	,pc.tixsyspricecodedesc+':'+sec.tixseatgroupdesc+':'+rw.tixseatgroupdesc
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,e.tixeventstartdate
	,cat.categoryname
	,og.ordergrouppaymentstatus
	,pc.tixsyspricecodedesc
	,sec.tixseatgroupdesc
	,rw.tixseatgroupdesc
	,e.tixeventlookupid
	,e.tixeventtitleshort
ORDER BY DATEPART(yyyy, e.tixeventstartdate) DESC

/*
--2015.09.23 Old Version - Updated with neighborhood/section/row from Veritix - DT
SELECT DISTINCT
	--a.customerid
	--,b.order_id
	--,b.primary_product_id
	--,b.product_id
	--,b.primary_product_id
	'' AS sport
	,COUNT(b.order_id) AS Qty
	,c.productdescription
	,c.producttype
	--,*
FROM ods.VTXordergroups a WITH(NOLOCK)
JOIN ods.VTXorder_items b WITH(NOLOCK)
ON a.ordergroup = b.order_id
JOIN ods.VTXcustomers cust WITH(NOLOCK)
ON a.customerid = cust.id
JOIN ods.VTXproducts c WITH(NOLOCK)
--ON b.product_id = c.id
ON b.primary_product_id = c.id
LEFT JOIN ods.VTXtixeventzoneseatgroups d
ON a.ordergroup = d.tixseatgroupsaleorder
LEFT JOIN ods.VTXeventcategoryrelation e
ON d.tixeventid = e.tixeventid
LEFT JOIN ods.VTXcategory f
ON e.categoryid = f.categoryid
where 1=1
--AND customerid = '11175367.0000000000'
AND CAST(cust.accountnumber AS NVARCHAR (200)) = @ADNumber
AND DATEPART(yyyy,ordergroupdate) = @CurrentYear
--AND b.order_id = '21086271'
AND b.canceled = 0
GROUP BY 
	--a.customerid
	--,b.order_id
	--,b.primary_product_id
	--,b.product_id
	--,b.primary_product_id
	c.productdescription
	,c.producttype
--ORDER BY b.id
*/
GO
