SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_FootballDashboard_TORDERS_SUM] as
declare @currentseason char(4)
declare @tixeventlookupid varchar(20)

set @currentseason = (select max(currentseason) from advcurrentyear)

set  @tixeventlookupid= (select tixeventlookupid from PriorityEvents where ticketyear = @currentseason  and sporttype = 'FB')

select t.*, convert(varchar,OrderPaymentReceived,1) + ' ('+ Cast(perReceived as varchar)  + '%)'  "Tickets Received",
 convert(varchar,OrderReceiptsPlanned,1) + ' ('+ Cast(perPlannedReceipts as varchar)  + '%)'  "Tickets Planned"
from (
select tixeventlookupid, tixeventtitleshort,
 '$' + convert(VARCHAR,cast(OrderGrandTotal as money),1) OrderGrandTotal,
 '$' + convert(VARCHAR,cast(OrderBalance as money),1) OrderBalance,
 '$' + convert(VARCHAR,cast(OrderPaymentReceived as money),1) OrderPaymentReceived ,
 '$' + convert(VARCHAR,cast(OrderScheduledPayments as money),1) OrderScheduledPayments,
 '$' + convert(VARCHAR,cast((OrderPaymentReceived+OrderScheduledPayments) as money),1) OrderReceiptsPlanned,
round( ( cast(OrderPaymentReceived as float) /cast(OrderGrandTotal  as  float))*100,2)   perReceived,
round( cast((OrderPaymentReceived+OrderScheduledPayments) as float) /cast(OrderGrandTotal as float)*100,2)  perPlannedReceipts from (
select -- c.accountnumber, c.lastname, c.firstname, c.fullname,  orderg.customerid,
 --ordergrouppaymentstatus, orderg.ordergroupstatus  
tixeventlookupid, tixeventtitleshort,
sum(ordergroupbottomlinegrandtotal ) OrderGrandTotal,
sum(ordergrouppaymentbalance ) OrderBalance,
sum(ordergrouptotalpaymentscleared ) OrderPaymentReceived  ,  
sum(ordergrouptotalpaymentsonhold) OrderScheduledPayments
   from  /*[ods].[VTXordergroups] orderg
         join  (select distinct events.tixeventlookupid ,events.tixeventtitleshort,  seats.tixseatordergroupid  from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid 
                        --join amy.PriorityEvents pe on pe.tixeventlookupid = events.tixeventlookupid
                       where  events.tixeventlookupid = 'F16-Season'
            )	zoneseats ON zoneseats.tixseatordergroupid = CAST(orderg.ordergroup AS NVARCHAR(255))
 join ods.VTXcustomers c on c.id = orderg.customerid */
 RPT_TICKETORDER_TB totb where totb.tixeventlookupid = @tixeventlookupid
 group by tixeventlookupid, tixeventtitleshort
 ) TK ) t
GO
