SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_ticketorder_list] @ADNumber int as
select c.accountnumber, orderg.ordergroup ordernumber,
orderg.ordergroupdate OrderDate,  --c.lastname, c.firstname, c.fullname,  orderg.customerid,
 ordergrouppaymentstatus, orderg.ordergroupstatus  ,
--tixeventlookupid, tixeventtitleshort,
ordergroupbottomlinegrandtotal OrderTotal ,
orderg.ordergrouptotalpaymentscleared  OrderReceived  ,  
orderg.ordergrouptotalpaymentsonhold  OrderScheduled, --getdate() updatedate ,   
orderg.ordergrouppaymentbalance  OrderDue,
STUFF((SELECT N', ' + tixeventtitleshort
  FROM (select distinct events.tixeventlookupid ,events.tixeventtitleshort,  seats.tixseatordergroupid  
                        from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid                      
            )	zoneseats2 
   WHERE zoneseats2.tixseatordergroupid = CAST(orderg.ordergroup AS NVARCHAR(255))
   ORDER BY tixeventlookupid desc
   FOR XML PATH(N'')), 1, 2, N'') EventsIncluded
   from  [ods].[VTXordergroups] orderg
  join ods.VTXcustomers c on c.id = orderg.customerid
  where   c.accountnumber = cast( @ADNumber as varchar) and
  CAST(orderg.ordergroup AS NVARCHAR(255)) in  (select distinct  seats.tixseatordergroupid  
                        from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid      
                        where tixeventinitdate >= getdate() - 365             
              and orderg.ordergroup not in (select isnull(ordernumber,0) from amy.rpt_seatrecon_tb   where adnumber= @ADNumber)       
            )	 order by ordernumber desc
GO
