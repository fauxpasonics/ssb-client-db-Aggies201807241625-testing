SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



------ [rpt].[rpt_DonorProfileTicketingAndParkingCurrent] '10023'

CREATE PROCEDURE [rpt].[rpt_DonorProfileTicketingAndParkingCurrent] (@ADNumber NVARCHAR(200))

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

;WITH cte AS (
SELECT DISTINCT
	c.accountnumber
	,cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,a.tixseatdesc
	,CAST(a.tixseatid AS INT) tixseatid
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
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
	,DATEPART(yyyy,e.tixeventstartdate)
	,a.tixseatdesc
	,CAST(a.tixseatid AS INT)
	,cat.categoryname
	,og.ordergrouppaymentstatus
	,pc.tixsyspricecodedesc
	,sec.tixseatgroupdesc
	,rw.tixseatgroupdesc
	,e.tixeventlookupid
	,e.tixeventtitleshort
--ORDER BY DATEPART(yyyy, e.tixeventstartdate) DESC
)



SELECT x.accountnumber, x.categoryname, x.tixeventlookupid, x.tixeventtitleshort, (x.EndSeqNo - x.StartSeqNo) +1 AS qty, x.[year],
CASE WHEN y.tixseatdesc = z.tixseatdesc
		THEN x.seatpricecode+':'+x.seatsection+':'+x.seatrow+':'+y.tixseatdesc
		ELSE x.seatpricecode+':'+x.seatsection+':'+x.seatrow+':'+y.tixseatdesc+'--'+z.tixseatdesc
	END AS seatblock,
 x.seatpricecode, 
	x.seatsection, x.seatrow, 
CASE WHEN y.tixseatdesc = z.tixseatdesc
		THEN y.tixseatdesc
		ELSE y.tixseatdesc+'--'+z.tixseatdesc
	END AS seatseat,
	x.paid, x.[sent]

FROM 
(
 SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, [year], seatpricecode, 
	seatsection, seatrow, paid, [sent], 
	StartSeqNo=MIN(tixseatid), EndSeqNo=MAX(tixseatid)
FROM (
    SELECT accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, [year], seatpricecode, 
		seatsection, seatrow, tixseatid, paid, [sent]
        ,rn=tixseatid-ROW_NUMBER() OVER (PARTITION BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, [year], seatpricecode, seatsection, seatrow, paid, [sent] ORDER BY tixseatid)
    FROM cte) a
GROUP BY accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, [year], seatpricecode, 
			seatsection, seatrow, paid, [sent], rn ) x
INNER JOIN cte y ON 
y.accountnumber = x.accountnumber AND
y.categoryname = x.categoryname AND
y.tixeventlookupid = x.tixeventlookupid AND
y.tixeventtitleshort = x.tixeventtitleshort AND
y.[YEAR] = x.[YEAR] AND
y.seatpricecode = x.seatpricecode AND
y.seatsection = x.seatsection AND
y.seatrow = x.seatrow AND
y.paid = x.paid AND
y.[SENT] = x.[SENT] AND 
y.tixseatid = x.StartSeqNo
INNER JOIN cte z ON 
z.accountnumber = x.accountnumber AND
z.categoryname = x.categoryname AND
z.tixeventlookupid = x.tixeventlookupid AND
z.tixeventtitleshort = x.tixeventtitleshort AND
z.[YEAR] = x.[YEAR] AND
z.seatpricecode = x.seatpricecode AND
z.seatsection = x.seatsection AND
z.seatrow = x.seatrow AND
z.paid = x.paid AND
z.[SENT] = x.[SENT] AND 
z.tixseatid = x.EndSeqNo
ORDER BY YEAR desc





















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
