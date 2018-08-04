SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[eventticketsummary] as
select c.accountnumber, te.tixeventid, te.tixeventlookupid, pc.tixsyspricecodedesc pricecode,
sg2.tixseatgroupdesc Neighborhood,    sg1.tixseatgroupdesc seatsection,  sg.tixseatgroupdesc seatROW, 
--sum(oi.paid_amount) paidamount, sum(oi.value) amountdue, 
sum(1) qty  
--c.accountnumber, c.firstname, c.lastname , categoryname Sport, te.tixeventtitleshort Event, te.tixeventlookupid 'Event Lookup ID', prod.productdescription Item, pc.tixsyspricecodedesc PriceCode,
--oi.[value]  ,oi.paid_amount, te.tixeventtitleshort, cat.categoryname,pl.tixsyspricelevelcode, pl.tixsyspriceleveldesc,    sg2.tixseatgroupdesc Neighborhood,    sg1.tixseatgroupdesc section,  sg.tixseatgroupdesc ROW,
--seat.tixseatdesc Seat, number4 seatid,
----og.ordergroup, prod.id, prod.productid, prod.producttype,
-- prod.productdetails2, prod.productdetails3, prod.productqty,
--og.customerid, oi.[value], oi.paid_amount, oi.order_id, oi.id, oi.product_id, oi.inventory_type, oi.primary_product_id,
--oi.number1, oi.number2, oi.number3, oi.number4 seat, 
--oi.number5, oi.number6,oi.number7 pricecodeid,oi.number8 pricelevelid,
--oi.number9, oi.number10, oi.number11, oi.number12, oi.number13, oi.number14, oi.number15,
--oi.canceled, oi.cancel_date, oi.cancel_channel ,te.tixeventtitlelong, te.tixeventid, te.tixeventcategoryid, te.tixeventtype,
--cat.categoryid, cat.categorytypeid,  cat.categorydescription, cat.categorystatus,
--cat.parentid, pc.tixsyspricecodecode, pc.printable,pc.tixsyspricecodetype,
 --pl.tixsyspriceleveltype,prodtype.producttype, prodtype.producttypedescription, sg.tixseatgroupid,  sg.tixseatgrouptype, sg1.*
 from ods.VTXordergroups og  
 join ods.VTXcustomers c on c.id = og.customerid
join ods.VTXorder_items oi on  oi.order_id = og.ordergroup 
join ods.VTXproducts prod on oi.primary_product_id = prod.id
join ods.VTXtixevents te on oi.number1 = te.tixeventid
join ods.VTXtixeventzoneseatgroups sg on sg.tixseatgroupid = oi.number3 and sg.tixeventid = oi.number1
join ods.VTXtixeventzoneseatgroups sg1 on sg1.tixseatgroupid = sg.tixseatgroupparentgroup and sg1.tixeventid = oi.number1
join ods.VTXtixeventzoneseatgroups sg2 on sg2.tixseatgroupid = sg.tixseatgroupgrandparent and sg2.tixeventid = oi.number1
join ods.VTXeventcategoryrelation ecr on te.tixeventid = ecr.tixeventid
join ods.VTXcategory cat on ecr.categoryid = cat.categoryid and categorytypeid = 1
join ods.VTXtixsyspricecodes pc on pc.tixsyspricecodecode = oi.number7
join ods.VTXtixsyspricelevels pl on pl.tixsyspricelevelcode = oi.number8
join ods.VTXproducttypes prodtype on prodtype.producttype = prod.producttype 
join  ods.VTXtixeventzoneseats seat on seat.tixseatid = oi.number4 and seat.tixeventid = oi.number1 and seat.tixseatgroupid = oi.number3  
where -- og.ordergroup = 27965547
--te.tixeventid = 3412
--tixeventlookupid = 'B15-MB'
--and 
--tixeventtitleshort = '2015 Men''s Basketball Season'
--and c.accountnumber = '10023'
--and 
oi.canceled = 0
group by  c.accountnumber, te.tixeventid, te.tixeventlookupid, pc.tixsyspricecodedesc , sg2.tixseatgroupdesc,    sg1.tixseatgroupdesc,  sg.tixseatgroupdesc
GO
