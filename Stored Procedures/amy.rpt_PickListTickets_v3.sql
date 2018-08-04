SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--EXEC  amy.[rpt_PickListTickets_v3] '3531', '04/01/2016 23:59:59',1,'stuff(111)','stuff(111)','stuff(111)','0'
--EXEC  [rpt].[rpt_PickListTickets] '3531'
--select substring('stuff(111)', charindex('(','stuff(111)')+1,Len('stuff(111)') - charindex('(','stuff(111)')-1)  

CREATE  PROCEDURE [amy].[rpt_PickListTickets_v3]  (@EventID NUMERIC, @EntryDatePick DATETIME,@PromptComments INT, @Custom1 varchar(max) ='0',@Custom2 varchar(max) ='0', @Custom3 varchar(max)  ='0', @Custom4 varchar(max)  ='0')  AS  

BEGIN

--IF OBJECT_ID('tempdb..#eventcustomer') IS NOT NULL DROP TABLE #eventcustomer
--IF OBJECT_ID('tempdb..#prioritypoints') IS NOT NULL DROP TABLE #prioritypoints

declare @tixeventlookupid varchar(50)
--DROP table  #EventCustomer
--DROP table  #PriorityPoints
--DECLARE @EventCustomer TABLE(contactID INT, ADNumber INT)
--DECLARE @PriorityPoints TABLE(ADNumber INT, PriorityPoints FLOAT)
--DECLARE @EventID AS NUMERIC = 3531
--DECLARE @EntryDatePick DATE = '11/9/15'
--DECLARE @PromptComments int = 0
--DECLARE @EntryDate DATETIME
--SET @EntryDate = (SELECT MAX(CAST(EntryDate AS DATE)) AS EntryDate FROM dbo.ADVHistoricalPriorityPoints WHERE EntryDate < @EntryDatePick )

set @tixeventlookupid = (select  tixeventlookupid from ods.VTXtixevents where tixeventid = @EventID);

--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/*
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
*/


/*CREATE TABLE  #PriorityPoints (ADNumber INT, PriorityPoints FLOAT)
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
WHERE CONVERT (DATE, EntryDate)  =  @EntryDate 
       -- AND curr_yr_cash_pts <> 0 --removed to match Amy's logic
       

CREATE UNIQUE INDEX IDX02 ON #PriorityPoints (ADNumber) 

select top * from rpt.rpt_PickListHistory_Hist  */
--select ascii('>')
-- select distinct Colname from vtxticketordercustomcomments 
--update vtxticketordercustomcomments  set colname = 'FB2016_RG_Rank' where colname ='FB2016_RoadGameComments_Rank'
 WITH cte AS (
  SELECT DISTINCT
                c.accountnumber, c.fullname CustomerName, c.firstname, c.lastname, c.email,
                ecr.categoryname,
                e.tixeventlookupid,
                e.tixeventtitleshort,
                a.tixeventid ,
                DATEPART (yyyy, e.tixeventstartdate) year,
                pc.tixsyspricecodedesc AS tixsyspricecodedesc,
                sec.tixseatgroupdesc AS section,
                rw.tixseatgroupdesc AS seatrow,
                a.tixseatdesc AS seatseat,
                CAST (a.tixseatid AS INT) tixseatid,
                pc.tixsyspricecodecode AS tixsyspricecodecode,
              tixsyspriceleveldesc,
                CASE
                   WHEN og.ordergrouppaymentstatus IN (2, 3) THEN 'X'
                   WHEN og.ordergrouppaymentstatus IN (1) THEN 'P'
                   ELSE ''
                END
                   AS paid,
                CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent,
                CASE  WHEN ordergroupbottomlinegrandtotal <> 0
                   THEN ordergrouptotalpaymentscleared    / ordergroupbottomlinegrandtotal
                   ELSE   0  END  paidpercent,
                CASE  WHEN ordergroupbottomlinegrandtotal <> 0   THEN
                        ordergrouptotalpaymentsonhold   / ordergroupbottomlinegrandtotal
                   ELSE   0   END    schpercent,
                ordergroupbottomlinegrandtotal,
                ordergrouptotalpaymentsonhold,
                ordergrouptotalpaymentscleared,
                getdate () update_date,
                tixseatlastupdate,
                og.ordergroup ordernumber,
                og.ordergroupdate,
                og.ordergrouplastupdated,
                pl.tixsyspricelevelcode
           FROM [ods].[VTXtixeventzoneseats] a
                JOIN [ods].[VTXtixeventzoneseatgroups] rw
                   ON     a.tixseatgroupid = rw.tixseatgroupid
                      AND a.tixeventid = rw.tixeventid
                      AND a.tixeventzoneid = rw.tixeventzoneid
                JOIN [ods].[VTXtixeventzoneseatgroups] sec
                   ON     rw.tixseatgroupparentgroup = sec.tixseatgroupid 
                      AND a.tixeventid = sec.tixeventid
                      AND a.tixeventzoneid = sec.tixeventzoneid
                JOIN [ods].[VTXtixsyspricecodes] pc
                   ON a.tixseatpricecode =
                         CAST (pc.tixsyspricecodecode AS NVARCHAR (255)) 
                JOIN [ods].[VTXtixevents] e ON a.tixeventid = e.tixeventid
                JOIN [ods].[VTXordergroups] og
                   ON a.tixseatordergroupid =
                         CAST (og.ordergroup AS NVARCHAR (255))
                JOIN [ods].[VTXcustomers] c
                   ON     og.customerid = c.id
                      AND c.accountnumber NOT LIKE '%[A-Z,a-z]%'
            left join ods.VTXtixsyspricelevels pl on rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
                LEFT JOIN
                (SELECT ce.tixeventid,
                        catchild.categoryname,
                        catchild.categoryid,
                        catchild.parentid,
                        parent.categoryname parentname
                   FROM ods.VTXeventcategoryrelation ce
                        JOIN ods.VTXcategory catchild
                           ON     catchild.categoryid = ce.categoryid
                              AND catchild.parentid IS NOT NULL
                              AND catchild.categorytypeid = 1
                        JOIN ods.VTXcategory parent
                           ON catchild.parentid = parent.categoryid) ecr
                   ON ecr.tixeventid = e.tixeventid
          WHERE 1 = 1 
                AND e.tixeventlookupid = @tixeventlookupid
                )
select * from (
SELECT
       c.accountnumber
       ,c.OrderID
       ,c.CustomerName
       ,c.FirstName
       ,c.LastName
       ,ct.CustomerType
       ,hpp.PriorityPoints AS PriorityPoints
       ,hpp.Rank AS Rank
       ,c.EventDesc
       ,c.tixsyspricecodedesc
     ,c.tixsyspricecodecode
  --     ,c.DeliveryMethod
       ,c.section
       ,c.seatrow [row]
       ,c.seats
       ,c.Qty
       ,c.tixsyspriceleveldesc,
      -- APIUser, <APIUser>, 12/1/2017: Processed by : system
     -- case when   isnull( replace(replace(ocomment.[Description],'APIUser, <APIUser>, ',''),': Processed by : system','') ,'')    like '12/%/2017'  and isnull( replace(replace(ocomment.[Description],'APIUser, <APIUser>, ',''),': Processed by : system','') ,'') not like '%<%' then null
     -- else
       isnull( replace(replace(ocomment.[Description],'APIUser, <APIUser>, ',''),': Processed by : system','') ,'')  + case when isnull( ocomment.[Description] ,'') <>'' then char(13) else '' end +
      isnull ( ( SELECT      STUFF((    SELECT ', ' + 
         case when  coldesc is not null then   colname  else '' end +': '+ coldesc --as -- AS [text()]
                                              FROM vtxticketordercustomcomments cc
                        WHERE
                       -- cc.ordernumber = c.OrderID
                        cc.tixeventlookupid = @tixeventlookupid
                        and  cc.accountnumber =  cast (c.accountnumber as int)
                        FOR XML PATH('') 
                        ), 1, 1, '' ) )   ,'')  -- end
                        [Description] 
       ,y.phone1
       ,y.email   
       , cr.RequestNotes       RenewalComments
       , cust1.customvalue custom1
      , cust2.customvalue custom2
       , cust3.customvalue custom3 
       , cust4.customvalue custom4
       from (
                select tall.* from   (
SELECT accountnumber , CustomerName,  Firstname, lastname, count(tixseatid) qty,
section, seatrow,  STUFF((
       SELECT ',' + seatseat  FROM  CTE z
       WHERE z.accountnumber = a.accountnumber AND
         --   z.categoryname = a.categoryname AND
         --   z.tixeventlookupid = a.tixeventlookupid AND
         --   z.tixeventtitleshort = a.tixeventtitleshort AND
         --   z.tixeventid = a.tixeventid AND	
          --  z.[YEAR] = a.[YEAR] AND
           -- z.seatpricecode = a.seatpricecode AND
            z.tixsyspricecodecode = a.tixsyspricecodecode AND
            z.section = a.section AND
            z.seatrow = a.seatrow 
            and z.ordernumber = a.ordernumber
            order by cast(replace(replace(replace(seatseat, 'W',''),'GA',''),'A','') as int)
       FOR XML	PATH('')), 1, 1, '')   seats ,
       ordernumber orderid, tixeventtitleshort EventDesc, tixsyspricecodedesc
       ,tixsyspricecodecode,tixsyspriceleveldesc
FROM cte a
GROUP BY accountnumber, Customername,   Firstname, lastname, --categoryname, tixeventlookupid, tixeventtitleshort, tixeventid, [year], 
 	section, seatrow ,ordernumber, tixeventtitleshort, tixsyspricecodedesc ,tixsyspricecodecode,tixsyspriceleveldesc
       ) tall  )  c
Left join ods.VTXcustomers y  on c.accountnumber = y.accountnumber
left join -- amy.vtxcustomertypes 
(select C.accountnumber, cfd.stringvalue CustomerType from ods.VTXcustomers C, ods.VTXcustomerfielddata CFD where  c.id = CFD.customerid  and CFD.customerfieldid = '111')
ct on ct.accountnumber = c.accountnumber 
left join -- amy.vtxCustomerRequests 
(select C.accountnumber, cfd.stringvalue RequestNotes  from ods.VTXcustomers C,  ods.VTXcustomerfields cf, ods.VTXcustomerfielddata CFD 
where  c.id = CFD.customerid and  cf.id = CFD.customerfieldid  and cf.name = 'F16 Request Notes' 
) cr on (c.accountnumber = cr.accountnumber )
LEFT JOIN  --#PriorityPoints 
(SELECT 
       --hpp.ContactID, switching to ADNumber
       ec.ADNumber, isnull(hpp.[Rank],99999) [Rank]
       ,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  
FROM advhistoricalprioritypoints hpp
JOIN advcontact ec 
       ON hpp.ContactID = ec.ContactID
WHERE  --convert(varchar,EntryDate,101)
EntryDate=  @EntryDatePick
) hpp  
       ON hpp.ADNumber = cast ( c.accountnumber as int) 
left join  --#Custom1
(select CFD.customerid, cfd.stringvalue customvalue from ods.VTXcustomerfielddata CFD 
where  CFD.customerfieldid = cast(substring(@Custom1, charindex('(',@Custom1)+1,Len(@Custom1)-charindex('(',@Custom1)-1)  as int)
) cust1 on ( y.id = cust1.customerid ) and @Custom1 <> '0' 
left join  --#Custom2
(select CFD.customerid, cfd.stringvalue customvalue from ods.VTXcustomerfielddata CFD 
where  CFD.customerfieldid = cast(substring(@Custom2, charindex('(',@Custom2)+1,Len(@Custom2)-charindex('(',@Custom2)-1) as int)
) cust2 on ( y.id = cust2.customerid )  and @Custom2 <> '0'
left join  --#Custom3
(select CFD.customerid, cfd.stringvalue customvalue from ods.VTXcustomerfielddata CFD 
where  CFD.customerfieldid = cast( substring(@Custom3, charindex('(',@Custom3)+1,Len(@Custom3)-charindex('(',@Custom3)-1) as int)
) cust3 on ( y.id = cust3.customerid )  and @Custom3 <> '0' 
left join  --#Custom4
(select CFD.customerid, cfd.stringvalue customvalue from ods.VTXcustomerfielddata CFD 
where  CFD.customerfieldid = cast( substring(@Custom4, charindex('(',@Custom4)+1,Len(@Custom4)-charindex('(',@Custom4)-1) as int)
) cust4 on ( y.id = cust4.customerid )  and @Custom4 <> '0' 
left join (select ordergroup, ods.VTXcomments.[description] from ods.VTXordergroups  og,ods.VTXcomments  where og.commentid = ods.VTXcomments.commentid) ocomment
on c.OrderID = ocomment.ordergroup
--WHERE 
--tixeventid = @EventID 
) listall
where ( 
(([Description] IS NOT NULL) 
--or ( RenewalComments is not null)
or (@Custom1 <> '0'  and  custom1  is not null)
or (@Custom2 <> '0'  and  custom2 is not null)
or (@Custom3 <> '0'  and  custom3 is not null)
or (@Custom4 <> '0'  and  custom4 is not null))
OR @PromptComments=1)
ORDER BY prioritypoints DESC
--ORDER BY c.accountnumber


END 

/*
select  c.accountnumber
       ,c.OrderID
       ,c.CustomerName
       ,c.FirstName
       ,c.LastName
        ,ct.CustomerType
       ,hpp.PriorityPoints AS PriorityPoints
       ,hpp.Rank AS Rank
       ,c.EventDesc
       ,c.tixsyspricecodedesc
       ,c.tixsyspricecodecode
       ,c.DeliveryMethod
       ,c.section
       ,c.[row]
       ,c.seats
       ,c.Qty
       ,c.tixsyspriceleveldesc
       ,c.[Description]
       ,y.phone1
       ,y.email   
       , cr.RequestNotes RenewalComments
       FROM rpt.rpt_PickListHistory_Hist c
Left join ods.VTXcustomers y  on c.accountnumber = y.accountnumber
left join amy.vtxcustomertypes ct on  cast ( c.accountnumber as int) = ct.accountnumber
left join amy.vtxCustomerRequests cr on ( cast ( c.accountnumber as int)= cr.accountnumber and cr.RequestType = 'F16 Request Notes')
LEFT JOIN  --#PriorityPoints 
(SELECT 
       ec.ADNumber, hpp.[Rank]
       ,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN advcontact ec 
       ON hpp.ContactID = ec.ContactID
WHERE  EntryDate =  :EntryDatePick
) hpp  
       ON hpp.ADNumber =  cast ( c.accountnumber as int)
WHERE 
tixeventid = :EventID
AND ((c.[Description] IS NOT NULL or cr.RequestNotes is not null) OR :PromptComments=1)
ORDER BY hpp.prioritypoints DESC
--ORDER BY c.accountnumber
*/
GO
