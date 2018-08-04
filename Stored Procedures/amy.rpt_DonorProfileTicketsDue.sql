SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileTicketsDue]
@ADNumber int
AS 

declare @ADNumberChar varchar(20)

set @ADNumberChar = cast(@ADNumber as varchar)

select c.accountnumber, -- c.lastname, c.firstname, c.fullname,  orderg.customerid,
 --ordergrouppaymentstatus, orderg.ordergroupstatus  ,
--tixeventlookupid, tixeventtitleshort,
sum(ordergroupbottomlinegrandtotal) ordergroupbottomlinegrandtotal ,
sum(orderg.ordergrouppaymentbalance) ordergrouppaymentbalance,
sum(orderg.ordergrouptotalpaymentscleared)  ordergrouptotalpaymentscleared  ,  
sum(orderg.ordergrouptotalpaymentsonhold) ordergrouptotalpaymentsonhold ,
getdate() updatedate 
   from  [ods].[VTXordergroups] orderg
         join  (select distinct events.tixeventlookupid ,events.tixeventtitleshort,  seats.tixseatordergroupid  from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid 
                        --join amy.PriorityEvents pe on pe.tixeventlookupid = events.tixeventlookupid
                       where  events.tixeventlookupid  in
                       ( select ve.tixeventlookupid  from  amy.veritix_events  ve where  category not in ('Highschool Events','Base') and subcategory in ('SeasonParking','Season') 
                  and subcategory not in ('Non-Event') and subcategoryalt not in ('Non-Event') )
            )	zoneseats ON zoneseats.tixseatordergroupid = CAST(orderg.ordergroup AS NVARCHAR(255))
 join ods.VTXcustomers c on c.id = orderg.customerid
 where c.accountnumber = @ADNumberChar
 group by c.accountnumber
GO
