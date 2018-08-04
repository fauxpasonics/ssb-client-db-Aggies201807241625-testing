SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_seatdetail_individual_tmp] (
   @tixeventlookupid    VARCHAR (50))
AS
   BEGIN
      DELETE FROM seatdetail_individual_tmp
       WHERE tixeventlookupid = @tixeventlookupid

      INSERT INTO seatdetail_individual_tmp
       select seat.*, case when paid = 'X' then ticketvalue else  paidpercent * (ticketvalue) end ticketpaid  from  (
         SELECT DISTINCT
                c.accountnumber,
                ecr.categoryname,
                e.tixeventlookupid,
                e.tixeventtitleshort,             --  a.tixeventid--,COUNT(DISTINCT a.tixseatdesc) AS qty
               -- ,
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
                 a.tixeventid,   -- numeric(10,0)
                a.tixseatgroupid,   --nvarchar(255)
                rw.tixseatgrouppricelevel,  -- numeric(10,0)
                a.tixseatofferid,     -- nvarchar(255)
                 a.tixseatpriceafterdiscounts ticketvalue
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
                      -- AND c.accountnumber IN ('12982', '14122', '22671409','21426','1','10023','10089','92530','96547')
                AND e.tixeventlookupid = @tixeventlookupid
                ) seat


      DELETE FROM seatdetail_flat
       WHERE tixeventlookupid = @tixeventlookupid

      --insert into seatdetail_flat select * from aggies.rpt.vwSeatDetail r where tixeventlookupid = @tixeventlookupid
      INSERT INTO seatdetail_flat
         SELECT accountnumber,
                categoryname,
                tixeventlookupid,
                tixeventtitleshort,
                tixeventid,
                qty,
                seatblock,
                year,
                seatpricecode,
                tixsyspricecode,
                seatsection,
                seatrow,
                seatseat,
                paid,
                sent,
                getdate () updatedate,
                paidpercent,
                schpercent,
                ordergroupbottomlinegrandtotal,
                ordergrouptotalpaymentsonhold,
                ordergrouptotalpaymentscleared,
                ordernumber
           FROM [amy].[vwSeatDetail_test_event_paidpercent] (
                   @tixeventlookupid)
   END
GO
