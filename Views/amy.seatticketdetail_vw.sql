SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[seatticketdetail_vw] as
 select a.*, case when paid = 'X' then itemvalue else  paidpercent * (itemvalue) end itempaid  from  (
   SELECT  --DISTINCT
                c.accountnumber,
                ecr.categoryname,
                e.tixeventlookupid,
                e.tixeventtitleshort,
                a.tixeventid--,COUNT(DISTINCT a.tixseatdesc) AS qty
                ,
                DATEPART (yyyy, e.tixeventstartdate) year,
                pc.tixsyspricecodedesc AS seatpricecode,
                sec.tixseatgroupdesc AS seatsection,
                rw.tixseatgroupdesc AS seatrow,
                a.tixseatdesc AS seatseat,
                CAST (a.tixseatid AS INT) tixseatid,
                pc.tixsyspricecodecode AS tixsyspricecode,
                CASE
                   WHEN og.ordergrouppaymentstatus IN (2, 3) THEN 'X'
                   WHEN og.ordergrouppaymentstatus IN (1) THEN 'P'
                   ELSE ''
                END
                   AS paid,
                CASE WHEN a.tixseatprinted = 1 THEN 'X' ELSE '' END AS sent,
                CASE
                   WHEN ordergroupbottomlinegrandtotal <> 0
                   THEN
                        ordergrouptotalpaymentscleared
                      / ordergroupbottomlinegrandtotal
                   ELSE
                      0
                END
                   paidpercent,
                CASE
                   WHEN ordergroupbottomlinegrandtotal <> 0
                   THEN
                        ordergrouptotalpaymentsonhold
                      / ordergroupbottomlinegrandtotal
                   ELSE
                      0
                END
                   schpercent,
                ordergroupbottomlinegrandtotal,
                ordergrouptotalpaymentsonhold,
                ordergrouptotalpaymentscleared,
                getdate () update_date,
                tixseatlastupdate,
                og.ordergroup ordernumber,
                og.ordergroupdate,
                og.ordergrouplastupdated, 
                a.tixseatgroupid ,
                rw.tixseatgroupparentgroup, 
                rw.tixseatgrouppricelevel ,
                --oi.id orderitemid,oi.[value] itemvalue, oi.paid_amount  itempaid,
              --  a.tixseatvaluebeforediscounts,
                a.tixseatpriceafterdiscounts itemvalue,
                   pc.tixsyspricecodedesc ,
  sc.tixsysseatstatusdesc,
 pl.tixsyspriceleveldesc,
 pct.tixsyspricecodetypedesc
                /*,CASE
                   WHEN og.ordergrouppaymentstatus IN (2, 3) THEN 0.00
                   WHEN og.ordergrouppaymentstatus IN (1) THEN  cast(a.tixseatpriceafterdiscounts as decimal)
                   ELSE 0.000
                END
                   AS     itempaid 
                   */
                   --, a.tixseatsold,  a.tixseatpaid , a.tixseatofferid  --, rw.*
               -- , a.*
               -- sec.tixseatgroupid,
               -- a.tixseatgroupid,
               -- a.tixseatgroupid , a.*
          /*      a.tixeventid,   -- numeric(10,0)
                a.tixseatgroupid,   --nvarchar(255)
                rw.tixseatgrouppricelevel,  -- numeric(10,0)
                a.tixseatofferid     -- nvarchar(255)
                */
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
 left  join tixsysseatstatuscodes sc on sc.tixsysseatstatuscode = a.tixseatcurrentstatus
 left join ods.VTXtixsyspricelevels pl on rw.tixseatgrouppricelevel = pl.tixsyspricelevelcode
 left join ods.VTXtixsyspricecodetypes pct on pct.tixsyspricecodetype = pc.tixsyspricecodetype
                /*LEFT JOIN [ods].[VTXeventcategoryrelation] ecr
                 ON a.tixeventid = ecr.tixeventid
                LEFT JOIN [ods].[VTXcategory] cat
                 ON ecr.categoryid = cat.categoryid */
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
   /*    JOIN ods.VTXorder_items oi
                   ON   oi.order_id =
                         CAST (og.ordergroup AS NVARCHAR (255))
                      --   and  oi.number3  =  a.tixseatid 
                         and number1  = a.tixeventid
 and number3 = a.tixseatgroupid
and number4  = tixseatid
and number8   =  rw.tixseatgrouppricelevel
and number5 =  a.tixseatofferid
and canceled =0 */
          WHERE 1 = 1 -- AND cat.categorytypeid = 1
                  --     AND c.accountnumber IN ('10007','10008')
             --   AND e.tixeventlookupid = 'BS18-Season' 
        --    and    og.ordergroup = 40850837  -- and tixseatid = 9 and e.tixeventid =  4404 
   ) a
GO
