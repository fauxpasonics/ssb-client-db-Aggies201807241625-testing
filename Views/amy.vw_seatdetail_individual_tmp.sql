SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view  [amy].[vw_seatdetail_individual_tmp] as
SELECT distinct
	c.accountnumber
	,null categoryname  --cat.categoryname
	,e.tixeventlookupid
	,e.tixeventtitleshort
	,a.tixeventid
	--,COUNT(DISTINCT a.tixseatdesc) AS qty
	,DATEPART(yyyy,e.tixeventstartdate) year
	,pc.tixsyspricecodedesc AS seatpricecode
	,sec.tixseatgroupdesc AS seatsection
	,rw.tixseatgroupdesc AS seatrow
	,a.tixseatdesc AS seatseat
	,CAST(a.tixseatid AS INT) tixseatid
	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X'
        WHEN og.ordergrouppaymentstatus IN (1) THEN 'P' ELSE '' END AS paid
	, CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent ,
  case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentscleared/  ordergroupbottomlinegrandtotal  else 0 end paidpercent  , 
  case when  ordergroupbottomlinegrandtotal    <>0 then ordergrouptotalpaymentsonhold/  ordergroupbottomlinegrandtotal   else 0 end schpercent ,
    ordergroupbottomlinegrandtotal , ordergrouptotalpaymentsonhold, ordergrouptotalpaymentscleared, getdate() update_date ,  tixseatlastupdate,
    og.ordergroup ordernumber --, 
FROM [ods].[VTXtixeventzoneseats] a
JOIN [ods].[VTXtixeventzoneseatgroups] rw 
	ON a.tixseatgroupid = rw.tixseatgroupid 
	AND a.tixeventid = rw.tixeventid 
	AND a.tixeventzoneid = rw.tixeventzoneid
JOIN [ods].[VTXtixeventzoneseatgroups] sec 
	ON rw.tixseatgroupparentgroup = sec.tixseatgroupid 
	AND a.tixeventid = sec.tixeventid 
	AND a.tixeventzoneid = sec.tixeventzoneid
JOIN [ods].[VTXtixsyspricecodes] pc 
	ON a.tixseatpricecode = CAST(pc.tixsyspricecodecode AS NVARCHAR(255))
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid
JOIN [ods].[VTXordergroups] og 
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(255))
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
--LEFT JOIN [ods].[VTXeventcategoryrelation] ecr 
--	ON a.tixeventid = ecr.tixeventid
--LEFT JOIN [ods].[VTXcategory] cat 
--	ON ecr.categoryid = cat.categoryid
GO
