SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[eventtickets] as
select c.accountnumber, te.tixeventid, tixeventlookupid,pc.tixsyspricecodecode, pc.tixsyspricecodedesc pricecode, sum(oi.paid_amount ) paidamount,
  sg2.tixseatgroupdesc Neighborhood,    sg1.tixseatgroupdesc seatsection, 
  sg.tixseatgroupdesc seatrow, count(isnull(seat.tixseatdesc,1)) qty
   from  ods.VTXtixevents te  --join
--ods.VTXordergroups og  
join ods.VTXorder_items oi on  oi.number1 = te.tixeventid
join ods.VTXordergroups og  on oi.order_id = og.ordergroup
 join ods.VTXcustomers c on c.id = og.customerid
 join ods.VTXtixsyspricecodes pc on pc.tixsyspricecodecode = oi.number7
 join ods.VTXtixeventzoneseatgroups sg on sg.tixseatgroupid = oi.number3 and sg.tixeventid = oi.number1
 left join ods.VTXtixeventzoneseatgroups sg1 on sg1.tixseatgroupid = sg.tixseatgroupparentgroup and sg1.tixeventid = oi.number1 AND sg1.tixeventzoneid = sg.tixeventzoneid
 left join ods.VTXtixeventzoneseatgroups sg2 on sg2.tixseatgroupid = sg.tixseatgroupgrandparent and sg2.tixeventid = oi.number1 AND sg2.tixeventzoneid = sg.tixeventzoneid
 --join  ods.VTXtixeventzoneseats seat  on seat.tixseatid = oi.number4 and seat.tixeventid = oi.number1 and seat.tixseatgroupid = oi.number3  
 left join  ods.VTXtixeventzoneseats seat on seat.tixseatgroupid = sg.tixseatgroupid 	AND seat.tixeventid = sg.tixeventid AND seat.tixeventzoneid = sg.tixeventzoneid  and seat.tixseatid  = oi.number4 
where -- og.ordergroup = 27965547
--te.tixeventid =3473 and 
oi.canceled =0
group by c.accountnumber, te.tixeventid, tixeventlookupid,pc.tixsyspricecodecode, pc.tixsyspricecodedesc,
  sg2.tixseatgroupdesc ,    sg1.tixseatgroupdesc, sg.tixseatgroupdesc
GO
