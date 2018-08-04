SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [rpt].[vwSeatDetail] 

AS 


SELECT DISTINCT
	c.accountnumber
	,cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc)
		THEN pc.tixsyspricecodedesc+':'+sec.tixseatgroupdesc+':'+rw.tixseatgroupdesc+':'+MIN(tixseatdesc)
		ELSE pc.tixsyspricecodedesc+':'+sec.tixseatgroupdesc+':'+rw.tixseatgroupdesc+':'+MIN(tixseatdesc)+'--'+MAX(a.tixseatdesc) 
	END AS seatblock  --2015.10.09 Broke out seatblock into individual columns
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
	,CASE WHEN MIN(tixseatdesc)=MAX(a.tixseatdesc) THEN MIN(tixseatdesc) ELSE MIN(tixseatdesc)+'-'+MAX(a.tixseatdesc) END AS seatseat
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X' ELSE '' END AS paid
	,CASE WHEN MIN(a.tixseatprinted) = 1 THEN 'X' ELSE '' END AS sent
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
	ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS NVARCHAR(200))
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = CAST(e.tixeventid AS NVARCHAR(200))
JOIN [ods].[VTXordergroups] og 
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(200))
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
	ON a.tixeventid = ecr.tixeventid
LEFT JOIN [ods].[VTXcategory] cat 
	ON ecr.categoryid = cat.categoryid
WHERE 1=1 
	AND cat.categorytypeid = 1
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
GO
