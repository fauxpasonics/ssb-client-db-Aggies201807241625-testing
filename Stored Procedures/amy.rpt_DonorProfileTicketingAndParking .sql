SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec [rpt_DonorProfileTicketingAndParkingtry ] 315397
-- exec [rpt_DonorProfileTicketingAndParking ] 315397
CREATE PROCEDURE [amy].[rpt_DonorProfileTicketingAndParking ]
@ADNumber int, 
@TRANSYEAR nvarchar(100) = null
AS

select * from (
select  distinct
accountnumber, categoryname,  tixeventtitleshort tixeventlookupid, tixeventtitleshort, qty, year, seatblock, seatpricecode, seatsection, seatrow, seatseat, paid, sent, ordernumber, 'X' Premium
from seatdetail_flat where  -- year = year(getdate()) and 
accountnumber = @ADNumber
AND (
(@TRANSYEAR is not null and @TRANSYEAR  like '%'+ ltrim(rtrim(year))+ '%') or
(@TRANSYEAR is  null)) and categoryname <>  cast(year as varchar)
and tixeventlookupid in  (select tixeventlookupid from priorityevents)
--order by year desc
union
select 	accountnumber, categoryname,  tixeventlookupid	,tixeventtitleshort  , qty  ,year ,  seatblock	, seatpricecode	,    
  seatsection	,seatrow, 
	/* STUFF((
       SELECT ',' +  a.tixseatdesc
       FROM [ods].[VTXtixeventzoneseats] a
       where  a.tixseatordergroupid =ordernumber  
       	AND a.tixeventid = tickall.tixeventid 
        and a.tixeventzoneid = tickall.tixeventzoneid --section
       and  a.tixseatgroupid =  tickall.tixseatgroupid  --row
 and      a.tixseatpricecode =   tickall.tixseatpricecode 
            order by cast(replace(replace(replace(tixseatdesc , 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   */ 
 'Qty:'+ cast(qty as varchar) seatseat
	, paid	, sent  ,ordernumber , Premium 
  from (
SELECT -- distinct
	c.accountnumber
	,ecr.categoryname
	,e.tixeventtitleshort  tixeventlookupid
	,e.tixeventtitleshort
	,a.tixeventid
  ,sum(1) qty
  ,parentname year
 ,  --	isnull(pc.tixsyspricecodedesc,'')  + ':' +  isnull(sec.tixseatgroupdesc,'') + ':' +  	isnull(rw.tixseatgroupdesc,'') --+ ':' + isnull(a.tixseatdesc,'') 
  null seatblock--,DATEPART(yyyy,e.tixeventstartdate)
	,pc.tixsyspricecodedesc AS seatpricecode
	,    sec.tixseatgroupdesc AS
 -- null  
  seatsection
	,   rw.tixseatgroupdesc
 --null
 AS seatrow
	,--    a.tixseatdesc AS 
  null 
  seatseat
--	,CAST(a.tixseatid AS INT) tixseatid
--	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X'
        WHEN og.ordergrouppaymentstatus IN (1) THEN 'P' ELSE '' END AS paid
	, CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent
    ,og.ordergroup ordernumber ,
    null Premium,
    a.tixeventzoneid,a.tixseatgroupid ,  a.tixseatpricecode 
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
	ON  a.tixseatpricecode =CAST(pc.tixsyspricecodecode AS NVARCHAR(255))
JOIN [ods].[VTXtixevents] e 
	ON a.tixeventid = e.tixeventid and tixeventlookupid not in (select tixeventlookupid from PriorityEvents)
JOIN [ods].[VTXordergroups] og 
	ON a.tixseatordergroupid = CAST(og.ordergroup AS NVARCHAR(255))
JOIN [ods].[VTXcustomers] c 
	ON og.customerid = c.id
 left  join (select  ce.tixeventid, catchild.categoryname,  catchild.categoryid  , catchild.parentid, parent.categoryname parentname
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catchild   on  catchild.categoryid = ce.categoryid 
                             and catchild.parentid is not null and catchild.categorytypeid = 1  
                           join ods.VTXcategory parent    on catchild.parentid  = parent.categoryid    ) ecr on ecr.tixeventid = e.tixeventid
WHERE 1=1 
	--AND cat.categorytypeid = 1
--	AND c.accountnumber IN ('12982', '14122', '22671409','21426','1','10023','10089','92530','96547') 
	--AND e.tixeventlookupid = 'F16-F01'
  and accountnumber = cast(@adnumber as varchar)
  and e.tixeventinitdate > getdate()-365
 -- and    og.ordergroup not in (select isnull(ordernumber,0) from seatdetail_flat where accountnumber =@adnumber)
 --and e.tixeventlookupid not in (select distinct tixeventlookupid from seatdetail_flat where accountnumber =@adnumber)
  group by 	c.accountnumber
	,ecr.categoryname
	,e.tixeventtitleshort 
  ,a.tixeventid
  ,parentname 
	,pc.tixsyspricecodedesc 
 	,sec.tixseatgroupdesc
	,rw.tixseatgroupdesc 
 , a.tixseatpricecode 
	-- ,a.tixseatdesc  --remove seat level
--	,CAST(a.tixseatid AS INT) tixseatid
--	,pc.tixsyspricecodecode AS tixsyspricecode
	,CASE WHEN og.ordergrouppaymentstatus IN (2,3) THEN 'X'
        WHEN og.ordergrouppaymentstatus IN (1) THEN 'P' ELSE '' END 
	, CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END , og.ordergroup  ,
  a.tixeventzoneid,a.tixseatgroupid  ,  rw.tixseatgroupparentgroup 
  ) tickall
  /*union 
 -- order by year desc, tixeventlookupid
  select  -- distinct
accountnumber,
categoryname, 
tixeventtitleshort tixeventlookupid, 
tixeventtitleshort,
qty,
year, 
seatblock,
seatpricecode,

seatsection, 
seatrow, 
seatseat,
paid, 
sent,
ordernumber
from seatdetail_flat where  -- year = year(getdate()) and 
accountnumber = @adnumber
AND ((@TRANSYEAR is not null and @TRANSYEAR  like '%'+ ltrim(rtrim(year))+ '%') or(@TRANSYEAR is  null)) and categoryname <>  cast(year as varchar)
*/
) yyy
order by year desc, tixeventlookupid
--order by year desc
  
  
  --select top 10000 * from rpt.rpt_PickListHistory_Hist where accountnumber = '10023'
GO
