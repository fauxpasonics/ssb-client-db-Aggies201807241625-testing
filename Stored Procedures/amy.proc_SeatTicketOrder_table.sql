SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [amy].[proc_SeatTicketOrder_table] (@tixeventlookupid varchar(50) = 'F16-Season')
AS


delete from  amy.RPT_TICKETORDER_TB where tixeventlookupid =  @tixeventlookupid   
insert into amy.RPT_TICKETORDER_TB
select c.accountnumber, c.lastname, c.firstname, c.fullname,  orderg.customerid,
 ordergrouppaymentstatus, orderg.ordergroupstatus  ,
tixeventlookupid, tixeventtitleshort,
ordergroupbottomlinegrandtotal ,
orderg.ordergrouppaymentbalance,
orderg.ordergrouptotalpaymentscleared   ,  
orderg.ordergrouptotalpaymentsonhold , getdate() updatedate ,   orderg.ordergroup ordernumber
   from  [ods].[VTXordergroups] orderg
         join  (select distinct events.tixeventlookupid ,events.tixeventtitleshort,  seats.tixseatordergroupid  from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid 
                        --join amy.PriorityEvents pe on pe.tixeventlookupid = events.tixeventlookupid
                       where  events.tixeventlookupid =  @tixeventlookupid   
            )	zoneseats ON zoneseats.tixseatordergroupid = CAST(orderg.ordergroup AS NVARCHAR(255))
 join ods.VTXcustomers c on c.id = orderg.customerid
GO
