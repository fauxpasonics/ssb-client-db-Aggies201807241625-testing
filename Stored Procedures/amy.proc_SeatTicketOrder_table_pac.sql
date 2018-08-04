SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [amy].[proc_SeatTicketOrder_table_pac] (@tixeventlookupid varchar(50) = 'F18-Season')
AS
Declare @pacseason varchar(30)
Declare @pacitem varchar(30)
declare @tixeventtitleshort varchar(50)
select @pacseason = pacseason, @pacitem = pacitem , @tixeventtitleshort = tixeventtitleshort  from PriorityEvents where tixeventlookupid =    @tixeventlookupid

delete from  amy.RPT_TICKETORDER_TB where tixeventlookupid =  @tixeventlookupid   
insert into amy.RPT_TICKETORDER_TB
 select odet.customer accountnumber,   case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], 1, charindex(',', P.[NAME] ) -1 )  else P.[Name] end  lastname,
 case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], charindex(',', P.[NAME] ) +1,50)  else null end firstname,
  p.mail_name fullname, null customerid,null, null,  @tixeventlookupid tixeventlookupid,  @tixeventtitleshort tixeventtitleshort, 
 sum(i_pay + i_bal + i_cpay) ordergroupbottomlinegrandtotal, 
  sum(i_bal)  ordergrouppaymentbalance,
 sum(  i_pay + i_cpay) ordergrouptotalpaymentscleared,
 (select sum(bamt)  from dbo.TK_BPLAN bp  where bp.SEASON = odet.season and bp.CUSTOMER = odet.customer and  bdate > getdate())  ordergrouptotalpaymentsonhold,
 getdate() updatedate , null ordernumber
 from dbo.pd_patron p
  join dbo.tk_odet odet on  p.patron = odet.customer
  where odet.season =  @pacseason and odet.item =  @pacitem
  group by  odet.customer ,   case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], 1, charindex(',', P.[NAME] ) -1 )  else P.[Name] end  ,
 case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], charindex(',', P.[NAME] ) +1,50)  else null end ,
  p.mail_name ,  odet.season 
  
  /*select c.accountnumber, c.lastname, c.firstname, c.fullname,  orderg.customerid,
 ordergrouppaymentstatus, orderg.ordergroupstatus  ,tixeventlookupid, tixeventtitleshort,ordergroupbottomlinegrandtotal ,orderg.ordergrouppaymentbalance,orderg.ordergrouptotalpaymentscleared   ,  
orderg.ordergrouptotalpaymentsonhold , getdate() updatedate ,   orderg.ordergroup ordernumber
   from  [ods].[VTXordergroups] orderg    join  (select distinct events.tixeventlookupid ,events.tixeventtitleshort,  seats.tixseatordergroupid  from [ods].[VTXtixevents] events
                        join [ods].[VTXtixeventzoneseats] seats 	ON seats.tixeventid = events.tixeventid 
                        --join amy.PriorityEvents pe on pe.tixeventlookupid = events.tixeventlookupid
                       where  events.tixeventlookupid =  @tixeventlookupid   
            )	zoneseats ON zoneseats.tixseatordergroupid = CAST(orderg.ordergroup AS NVARCHAR(255))
 join ods.VTXcustomers c on c.id = orderg.customerid*/
GO
