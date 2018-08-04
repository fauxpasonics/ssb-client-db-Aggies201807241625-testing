SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [amy].[rpt_DonorProfileEvents]
@ADNumber int
AS        
select ei.start_date [Date],  sum(qty) [QTY],
--o.acct, replace(eg.title, '<br />', ' ') + ' - ' + 
replace( replace(ei.title, '<br />', ' '), '<br>', ' ') longtitle
from advevents_tbl_event_group eg, 
 advevents_tbl_event_item ei,
 advevents_tbl_order o  , 
 advevents_tbl_order_line ol
 where eg.id = ei.event_group_id   and 
o.id = ol.order_id
 and ei.id = ol.event_item_id
 and submit_date is not null
 and o.acct = @ADNumber
 group by o.acct,start_date, -- replace(eg.title, '<br />', ' ') + ' - ' + 
 replace( replace(ei.title, '<br />', ' '), '<br>', ' ')
 order by start_date desc
GO
