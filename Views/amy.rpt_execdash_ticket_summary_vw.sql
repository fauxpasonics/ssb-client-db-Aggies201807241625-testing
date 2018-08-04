SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[rpt_execdash_ticket_summary_vw] as
select 	zoneseats.tixeventlookupid ,
year(orderg.ordergroupdate) rptyear,
sum(ordergroupbottomlinegrandtotal) ordergroupbottomlinegrandtotal ,
sum(orderg.ordergrouppaymentbalance) ordergrouppaymentbalance,
sum(orderg.ordergrouptotalpaymentscleared)  ordergrouptotalpaymentscleared  , 
sum(case when orderg.ordergroupdate <=  cast (cast( month(getdate()) as varchar) + '/'+ cast( day(getdate()) as varchar) + '/' +cast(year(orderg.ordergroupdate) as varchar) as date)  
     then  ordergrouptotalpaymentscleared  else 0 end)  YTDordergrouptotalpaymentscleared  , 
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
 --where c.accountnumber = @ADNumberChar
 where year(orderg.ordergroupdate) >= year(getdate())-2
 group by  	zoneseats.tixeventlookupid ,year(orderg.ordergroupdate)
GO
